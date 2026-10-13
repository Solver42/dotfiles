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
-- Highlight every occurrence of the word under the cursor
--------------------------------------------------------------------------------

local WORD_STYLE        = 'fore:16,back:28'
local CURSOR_LINE_STYLE = 'fore:7,back:22'
local TYPING_CURSOR     = 'back:252'

-- false: vis draws the cursor line (full width bar) and the matches on that
--        line are re-styled afterwards in UI_DRAW, by byte offset.
-- true:  vis' own cursorline is turned off; the cursor line is styled here in
--        WIN_HIGHLIGHT (before the matches), by byte offset. Use this if the
--        word on the cursor line is not highlighted with `false`.
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

-- vis draws the cursor line after WIN_HIGHLIGHT, which covers the matches on
-- it. They are styled again here, by byte range, so vis maps them to screen
-- cells itself (wrapping, tabs, wide characters, split width, line numbers).
-- The character under the cursor is left out so it keeps the cursor style.
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

vis:map(vis.modes.NORMAL, ' gj', function()
    local name = vis.win and vis.win.file and vis.win.file.name
    if not name then
        vis:info('no file name')
        return
    end
    -- single-quote the name for the shell
    local quoted = "'" .. name:gsub("'", "'\\''") .. "'"
    vis:feedkeys(':!git --no-pager diff --color=always -- ' .. quoted
        .. ' | diff-so-fancy | LESS= less --tabs=4 -R<Enter>')
end)

vis:map(vis.modes.NORMAL, ' gd', ':!git --no-pager diff --color=always | diff-so-fancy | LESS= less --tabs=4 -R<Enter>')

vis:map(vis.modes.NORMAL, ' dh', function()
    hi_word = not hi_word
    vis:feedkeys('\x0c')
end)

vis:map(vis.modes.INSERT, 'jkj', '<Escape>')
