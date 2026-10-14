require('vis')

--------------------------------------------------------------------------------
-- Plain text only: replace every lexer with a no-op one
--------------------------------------------------------------------------------

local dummy_lexer = {
    _name = 'none',
    _TAGS = {},
    property = setmetatable({}, { __index = function() return '' end }),
    lex = function() return {} end,
}

if vis.lexers then
    vis.lexers.load = function() return dummy_lexer end
end

--------------------------------------------------------------------------------
-- Remember cursor positions
--------------------------------------------------------------------------------

local cursors = require('plugins/vis-cursors')
local home = os.getenv('HOME')
if home then cursors.path = home .. '/.cache/vis_cursors' end

--------------------------------------------------------------------------------
-- System clipboard
--   yank/delete -> xsel (checked after every redraw)
--   p / P       -> insert the xsel clipboard directly (function mapping,
--                  so no keys are fed back and nothing can loop)
--------------------------------------------------------------------------------

local last_reg

local function sync_clipboard()
    local ok, vals = pcall(function() return vis.registers['"'] end)
    local text = (ok and type(vals) == 'table') and table.concat(vals, '\n') or ''
    if last_reg == nil then last_reg = text; return end -- state at startup, even if empty
    if text == '' or text == last_reg then return end
    last_reg = text
    local p = io.popen('xsel --input --clipboard', 'w')
    if p then p:write(text); p:close() end
end

vis.events.subscribe(vis.events.UI_DRAW, sync_clipboard)

local function paste_clipboard(before)
    local win = vis.win
    local file, sel = win and win.file, win and win.selection
    if not file or not sel then return end

    local h = io.popen('xsel --output --clipboard 2>/dev/null', 'r')
    if not h then vis:info('xsel failed'); return end
    local text = h:read('*a')
    h:close()
    if not text or text == '' then vis:info('clipboard empty'); return end

    local pos = sel.pos
    if text:sub(-1) == '\n' then
        -- linewise: below (p) or above (P) the current line
        local lstart = file:offset_from_line_column(sel.line) or 0
        if before then
            file:insert(lstart, text)
            sel.pos = lstart
        else
            local nxt = file:offset_from_line_column(sel.line + 1) or file.size
            if nxt >= file.size and file.size > 0
                and file:content(file.size - 1, 1) ~= '\n' then
                file:insert(file.size, '\n' .. text:sub(1, -2))
                sel.pos = file.size - #text + 1
            else
                file:insert(nxt, text)
                sel.pos = nxt
            end
        end
    else
        -- characterwise: after (p) or before (P) the cursor character
        local at = pos
        if not before and file.size > 0 then
            local c = file:content(pos, 1)
            local b = c and c:byte(1)
            if b and b ~= 10 then
                at = pos + ((b >= 240 and 4) or (b >= 224 and 3) or (b >= 192 and 2) or 1)
            end
        end
        file:insert(at, text)
        local last = #text
        while last > 1 and text:byte(last) >= 128 and text:byte(last) < 192 do
            last = last - 1
        end
        sel.pos = at + last - 1
    end

    -- Close this paste as its own undo step: leaving insert mode makes vis
    -- take a snapshot, and a<Escape> ends up on the same cursor position.
    vis:feedkeys('a<Escape>')
end

vis:map(vis.modes.NORMAL, 'p', function() paste_clipboard(false) end)
vis:map(vis.modes.NORMAL, 'P', function() paste_clipboard(true) end)

--------------------------------------------------------------------------------
-- Highlight every occurrence of the word under the cursor
--------------------------------------------------------------------------------

local WORD_STYLE        = 'fore:16,back:28'
local CURSOR_LINE_STYLE = 'fore:7,back:22'
local TYPING_CURSOR     = 'back:252'

-- false: vis draws the cursor line (full width bar) and the matches on that
--        line are re-styled afterwards in UI_DRAW, by byte offset.
-- true:  vis' own cursorline is turned off; the cursor line is styled here in
--        WIN_HIGHLIGHT (before the matches), by byte offset.
local OWN_CURSORLINE = true

local max, min = math.max, math.min

local hi_word = true
local cl_on = true
local word_style, cl_style

-- Scan results per window: written in WIN_HIGHLIGHT, consumed in UI_DRAW.
-- `false` means "scanned, nothing to paint"; `nil` means "not scanned".
local pending = setmetatable({}, { __mode = 'k' })

-- Keyword bytes: [0-9A-Za-z_] and everything >= 128 (UTF-8). Indexing with
-- nil (no byte) yields nil, so callers need no bounds checks.
local KW = {}
for b = 0, 255 do
    KW[b] = (b >= 48 and b <= 57) or (b >= 65 and b <= 90)
        or (b >= 97 and b <= 122) or b == 95 or b >= 128
end

-- Finds the word under the cursor and every whole-word, case-insensitive
-- occurrence of it in the viewport. Marks them with `win:style` when `paint`
-- is set. Returns nil when there is nothing to highlight, otherwise
--   word, line_text, lstart, rel (cursor offset in line),
--   spans (0-based line offsets of matches on the cursor line), nspans
local function scan(win, paint)
    if not hi_word then return nil end
    local mode = vis.mode
    if mode == vis.modes.VISUAL or mode == vis.modes.VISUAL_LINE then return nil end

    local file, sel = win.file, win.selection
    local pos = sel and sel.pos
    if not file or not pos or pos >= file.size then return nil end
    local vp = win.viewport and win.viewport.bytes
    if not vp then return nil end

    -- word under the cursor
    local lstart = file:offset_from_line_column(sel.line)
    if not lstart then return nil end
    local lend = file:offset_from_line_column(sel.line + 1) or file.size
    local line_text = file:content(lstart, lend - lstart)
    if not line_text then return nil end

    local rel = pos - lstart
    if rel < 0 or rel >= #line_text or not KW[line_text:byte(rel + 1)] then return nil end
    local s, e = rel + 1, rel + 1
    while s > 1 and KW[line_text:byte(s - 1)] do s = s - 1 end
    while e < #line_text and KW[line_text:byte(e + 1)] do e = e + 1 end
    local word = line_text:sub(s, e)
    local wlen = #word

    -- viewport text, padded so matches cut by the edges are still seen
    local from = max(vp.start - wlen, 0)
    local to = min(vp.finish + wlen, file.size)
    local data = file:content(from, to - from)
    if not data then return nil end

    if not word_style then
        word_style = vis.ui:style_push(WORD_STYLE)
        if not word_style then return nil end
    end

    local needle, hay = word:lower(), data:lower()
    local spans, n = {}, 0
    local i = 1
    while true do
        local a = hay:find(needle, i, true)
        if not a then break end
        local b = a + wlen - 1
        if KW[data:byte(a - 1)] or KW[data:byte(b + 1)] then
            i = a + 1
        else
            local abs = from + a - 1
            if paint then win:style(word_style, abs, abs + wlen - 1) end
            if abs >= lstart and abs + wlen <= lend then
                n = n + 1
                spans[n] = abs - lstart
            end
            i = b + 1
        end
    end
    if n == 0 then return nil end

    return { word = word, line_text = line_text, lstart = lstart,
             rel = rel, spans = spans, nspans = n }
end

-- Used only when OWN_CURSORLINE is false: re-style matches on the cursor line
-- by byte range, leaving the character under the cursor alone.
local function paint_cursor_line(win, st)
    local wlen = #st.word
    local cur = st.lstart + st.rel
    local b = st.line_text:byte(st.rel + 1)
    local clen = (b >= 240 and 4) or (b >= 224 and 3) or (b >= 192 and 2) or 1
    local cur_last = cur + clen - 1

    for k = 1, st.nspans do
        local a = st.lstart + st.spans[k]
        local z = a + wlen - 1
        if cur > z or cur_last < a then
            win:style(word_style, a, z)
        else
            if cur > a then win:style(word_style, a, cur - 1) end
            if cur_last < z then win:style(word_style, cur_last + 1, z) end
        end
    end
end

-- OWN_CURSORLINE mode: style the whole cursor line by byte range.
local function own_cursorline(win)
    local file, sel = win.file, win.selection
    if not file or not sel then return end
    local lstart = file:offset_from_line_column(sel.line)
    if not lstart then return end
    local lend = file:offset_from_line_column(sel.line + 1) or file.size
    if lend <= lstart then return end
    if not cl_style then
        cl_style = vis.ui:style_push(CURSOR_LINE_STYLE)
        if not cl_style then return end
    end
    win:style(cl_style, lstart, lend - 1)
end

local function apply_cursorline_styles()
    local ui = vis.ui
    local ids = ui.style_ids
    local typing = vis.mode == vis.modes.INSERT or vis.mode == vis.modes.REPLACE
    local lexers = vis.lexers
    ui:style_define(ids.CURSOR_LINE, CURSOR_LINE_STYLE)
    ui:style_define(ids.CURSOR_PRIMARY,
        typing and TYPING_CURSOR or (lexers and lexers.STYLE_CURSOR_PRIMARY) or 'reverse')
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command('set tabwidth 4')
    vis:command('set expandtab')
    if OWN_CURSORLINE then
        win.options.cursorline = false
    else
        vis:command('set cursorline')
    end
    apply_cursorline_styles()
end)

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
    apply_cursorline_styles()
    if OWN_CURSORLINE and cl_on then own_cursorline(win) end
    pending[win] = scan(win, true) or false
end)

vis.events.subscribe(vis.events.UI_DRAW, function()
    local win = vis.win
    if not win then return end
    local st = pending[win]
    pending[win] = nil
    if OWN_CURSORLINE then return end
    if not hi_word or not win.options.cursorline or #win.selections ~= 1 then return end
    if st == nil then st = scan(win, false) end -- highlight did not run for this draw
    if st then paint_cursor_line(win, st) end
end)

--------------------------------------------------------------------------------
-- Git diff in a pager (diff-so-fancy + less without -F)
--------------------------------------------------------------------------------

-- Run a diff pipeline in a pager, then put the terminal back into the state
-- vis expects (alternate screen) and repaint everything.
local function paged_diff(args)
    local cmd = ':!git --no-pager diff --color=always ' .. args
        .. ' | diff-so-fancy | LESS= less --tabs=4 -R; tput smcup<Enter>\x0c'
    vis:feedkeys(cmd)
end

--------------------------------------------------------------------------------
-- Key bindings
--------------------------------------------------------------------------------

vis:map(vis.modes.NORMAL, ' dn', ':set nu!<Enter>')

vis:map(vis.modes.NORMAL, ' dc', function()
    if OWN_CURSORLINE then
        cl_on = not cl_on
        vis:feedkeys('\x0c')
    else
        vis:command('set cursorline!')
    end
end)

vis:map(vis.modes.NORMAL, ' w', ':w<Enter>')

vis:map(vis.modes.NORMAL, ' gd', function()
    paged_diff('')
end)

vis:map(vis.modes.NORMAL, ' gj', function()
    local name = vis.win and vis.win.file and vis.win.file.name
    if not name then
        vis:info('no file name')
        return
    end
    local quoted = "'" .. name:gsub("'", "'\\''") .. "'"
    paged_diff('-- ' .. quoted)
end)

vis:map(vis.modes.NORMAL, ' dh', function()
    hi_word = not hi_word
    vis:feedkeys('\x0c')
end)

vis:map(vis.modes.INSERT, 'jkj', '<Escape>')
