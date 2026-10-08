require('vis')

local dummy_lexer = {
    _name = 'none',
    _TAGS = {},
    property = setmetatable({}, {
        __index = function() return "" end
    }),
    lex = function(self, text, style)
        return {}
    end
}

if vis.lexers then
    vis.lexers.load = function(name)
        return dummy_lexer
    end
end

local cursors = require('plugins/vis-cursors')
cursors.path = os.getenv("HOME") .. "/.cache/vis_cursors"

local hi_word = true
local word_style

local function is_kw(b)
    if not b then return false end
    return (b >= 48 and b <= 57) or (b >= 65 and b <= 90)
        or (b >= 97 and b <= 122) or b == 95 or b >= 128
end

local function lower_ascii(s)
    return (s:gsub("[A-Z]", function(c)
        return string.char(c:byte() + 32)
    end))
end

local function screen_col(text, byte_off, tabw)
    local col, i, target = 0, 1, byte_off + 1
    while i < target do
        local b = text:byte(i)
        if not b or b == 10 then break end
        if b == 9 then
            col = col + (tabw - (col % tabw))
            i = i + 1
        elseif b < 128 then
            col = col + 1
            i = i + 1
        else
            i = i + 1
            while i < target do
                local c = text:byte(i)
                if not c or c < 128 or c >= 192 then break end
                i = i + 1
            end
            col = col + 1
        end
    end
    return col
end

-- word, line text, line start, cursor line spans {rel_s, rel_e} inclusive
local function matches(win)
    if not hi_word then return nil end
    if vis.mode == vis.modes.VISUAL or vis.mode == vis.modes.VISUAL_LINE then return nil end
    local file, sel = win.file, win.selection
    if not file or not sel or not sel.pos or sel.pos >= file.size then return nil end

    local lstart = file:offset_from_line_column(sel.line)
    if not lstart then return nil end
    local lend = file:offset_from_line_column(sel.line + 1) or file.size
    local line_text = file:content(lstart, lend - lstart)
    if not line_text then return nil end

    local rel = sel.pos - lstart
    if rel < 0 or rel >= #line_text or not is_kw(line_text:byte(rel + 1)) then return nil end
    local s, e = rel + 1, rel + 1
    while s > 1 and is_kw(line_text:byte(s - 1)) do s = s - 1 end
    while e < #line_text and is_kw(line_text:byte(e + 1)) do e = e + 1 end
    local word = line_text:sub(s, e)
    if word == "" then return nil end

    local vp = win.viewport and win.viewport.bytes
    if not vp then return nil end
    local from = vp.start - #word
    if from < 0 then from = 0 end
    local to = vp.finish + #word
    if to > file.size then to = file.size end
    local data = file:content(from, to - from)
    if not data then return nil end

    if not word_style then
        word_style = vis.ui:style_push('fore:16,back:28')
    end
    if not word_style then return nil end

    local needle, hay = lower_ascii(word), lower_ascii(data)
    local spans, i = {}, 1
    while true do
        local a, b = hay:find(needle, i, true)
        if not a then break end
        local prev = a > 1 and data:byte(a - 1) or nil
        local nxt = b < #data and data:byte(b + 1) or nil
        if (not prev or not is_kw(prev)) and (not nxt or not is_kw(nxt)) then
            local abs, abs_end = from + a - 1, from + b - 1
            win:style(word_style, abs, abs_end)
            if abs >= lstart and abs_end < lend then
                spans[#spans + 1] = { abs - lstart, abs_end - lstart }
            end
        end
        i = a + 1
    end
    return line_text, spans, sel.pos - lstart, sel.line
end

local function apply_cursorline_styles()
    local ids = vis.ui.style_ids
    local typing = vis.mode == vis.modes.INSERT or vis.mode == vis.modes.REPLACE
    vis.ui:style_define(ids.CURSOR_LINE, 'fore:7,back:22')
    if typing then
        vis.ui:style_define(ids.CURSOR_PRIMARY, 'back:15')
    else
        vis.ui:style_define(ids.CURSOR_PRIMARY, vis.lexers.STYLE_CURSOR_PRIMARY or 'reverse')
    end
end

-- Cursorline is painted after WIN_HIGHLIGHT and would cover the word.
-- UI_DRAW runs after that, so the current line is painted again on top.
local function overlay_cursor_line(win)
    if not win.options.cursorline or #win.selections ~= 1 then return end
    local line_text, spans, cursor_rel, line = matches(win)
    if not line_text or not win.viewport.lines then return end
    local row = line - win.viewport.lines.start
    if row < 0 or row >= win.viewport.height then return end
    local tabw = win.options.tabwidth or 8
    if tabw < 1 then tabw = 8 end
    local sidebar = win.width - win.viewport.width
    if sidebar < 0 then sidebar = 0 end
    local skip = screen_col(line_text, cursor_rel, tabw)
    for _, sp in ipairs(spans) do
        local col = screen_col(line_text, sp[1], tabw)
        local i, last = sp[1] + 1, sp[2] + 1
        while i <= last do
            local b = line_text:byte(i)
            local width = 1
            if b == 9 then
                width = tabw - (col % tabw)
                i = i + 1
            elseif b >= 128 then
                i = i + 1
                while i <= last do
                    local c = line_text:byte(i)
                    if not c or c < 128 or c >= 192 then break end
                    i = i + 1
                end
            else
                i = i + 1
            end
            for dx = 0, width - 1 do
                if col + dx ~= skip then
                    win:style_pos(word_style, sidebar + col + dx, row)
                end
            end
            col = col + width
        end
    end
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command('set tabwidth 4')
    vis:command('set expandtab')
    vis:command('set cursorline')
    apply_cursorline_styles()
end)

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
    apply_cursorline_styles()
    matches(win)
end)

vis.events.subscribe(vis.events.UI_DRAW, function()
    local win = vis.win
    if not win or not hi_word then return end
    if vis.mode == vis.modes.VISUAL or vis.mode == vis.modes.VISUAL_LINE then return end
    overlay_cursor_line(win)
end)

vis:map(vis.modes.NORMAL, ' dn', function()
    vis:command('set nu!')
end)

vis:map(vis.modes.NORMAL, ' dc', function()
    vis:command('set cursorline!')
end)

vis:map(vis.modes.NORMAL, ' dh', function()
    hi_word = not hi_word
    vis:feedkeys('<vis-redraw>')
end)

vis:map(vis.modes.NORMAL, ' w', function()
    vis:command('w')
end)

vis:map(vis.modes.INSERT, 'jkj', '<Escape>')
