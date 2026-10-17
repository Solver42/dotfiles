require('vis')

-- No syntax highlighting. A lexer loader must still exist, otherwise `:set theme` returns early.
local plain_text_lexer = {
    _name = 'none',
    _TAGS = {},
    property = setmetatable({}, { __index = function() return '' end }),
    lex = function() return {} end,
}
if vis.lexers then vis.lexers.load = function() return plain_text_lexer end end

local remembered_cursor_positions = require('plugins/vis-cursors')
require('plugins/vis-rg')
local home_directory = os.getenv('HOME')
if home_directory then remembered_cursor_positions.path = home_directory .. '/.cache/vis_cursors' end

vis.events.subscribe(vis.events.WIN_OPEN, function()
    vis:command('set tabwidth 4')
    vis:command('set expandtab')
end)

-- System clipboard: the unnamed register is copied to xsel after every draw. p/P paste straight
-- from xsel through function mappings, so no keys are fed back and nothing can loop.
local last_synced_register_text

local function read_unnamed_register() return vis.registers['"'] end

local function copy_unnamed_register_to_system_clipboard()
    local succeeded, slots = pcall(read_unnamed_register)
    local text = succeeded and type(slots) == 'table' and table.concat(slots, '\n') or ''
    if last_synced_register_text == nil then
        last_synced_register_text = text -- whatever the register holds at startup is not a yank
    elseif text ~= '' and text ~= last_synced_register_text then
        last_synced_register_text = text
        local xsel = io.popen('xsel --input --clipboard', 'w')
        if xsel then xsel:write(text); xsel:close() end
    end
end
vis.events.subscribe(vis.events.UI_DRAW, copy_unnamed_register_to_system_clipboard)

local function paste_system_clipboard(before_cursor)
    local window = vis.win
    local file, selection = window and window.file, window and window.selection
    if not (file and selection) then return end

    local xsel = io.popen('xsel --output --clipboard 2>/dev/null')
    local text = xsel and xsel:read('*a')
    if xsel then xsel:close() end
    if not text or text == '' then
        vis:info('clipboard empty')
        return
    end

    if text:byte(-1) == 10 then -- linewise: below the current line (p) or above it (P)
        local paste_at = file:offset_from_line_column(selection.line + (before_cursor and 0 or 1)) or file.size
        if not before_cursor and paste_at >= file.size and file.size > 0
            and file:content(file.size - 1, 1) ~= '\n' then
            file:insert(file.size, '\n' .. text:sub(1, -2)) -- the last line has no newline to paste after
            selection.pos = file.size - #text + 1
        else
            file:insert(paste_at, text)
            selection.pos = paste_at
        end
    else -- characterwise: after the character under the cursor (p) or before it (P)
        local paste_at = selection.pos
        if not before_cursor then
            local byte = (file:content(paste_at, 1) or ''):byte(1)
            if byte and byte ~= 10 then
                paste_at = paste_at + (byte >= 240 and 4 or byte >= 224 and 3 or byte >= 192 and 2 or 1)
            end
        end
        file:insert(paste_at, text)
        local last_character_start = #text
        while last_character_start > 1 and text:byte(last_character_start) >= 128
            and text:byte(last_character_start) < 192 do
            last_character_start = last_character_start - 1
        end
        selection.pos = paste_at + last_character_start - 1
    end
    vis:feedkeys('a<Escape>') -- leaving insert mode makes vis close this paste as its own undo step
end
vis:map(vis.modes.NORMAL, 'p', function() paste_system_clipboard(false) end)
vis:map(vis.modes.NORMAL, 'P', function() paste_system_clipboard(true) end)

-- Occurrences of the word under the cursor and the bracket or quote matching the cursor share one
-- style. vis paints that matching character with its selection style, so outside visual mode the
-- selection style is redefined to it.
local MATCH_HIGHLIGHT_STYLE = 'fore:16,back:28'
local CURSOR_LINE_STYLE = 'fore:7,back:22'
local INSERT_MODE_CURSOR_STYLE = 'back:252'
local VISUAL_MODES = { [vis.modes.VISUAL] = true, [vis.modes.VISUAL_LINE] = true }
local TYPING_MODES = { [vis.modes.INSERT] = true, [vis.modes.REPLACE] = true }
local VIEWPORT_PADDING_BYTES = 128 -- lets words cut off by the viewport edges still match

local IS_KEYWORD_BYTE = {}
for byte = 0, 255 do
    IS_KEYWORD_BYTE[byte] = byte >= 128 or string.char(byte):find('[%w_]') ~= nil
end

local word_highlighting_enabled = true
local match_highlight_style_id
local pending_cursor_line_repaint

local function apply_mode_dependent_styles(mode)
    local style_ids, lexers = vis.ui.style_ids, vis.lexers or {}
    vis.ui:style_define(style_ids.CURSOR_LINE, CURSOR_LINE_STYLE)
    vis.ui:style_define(style_ids.SELECTION,
        VISUAL_MODES[mode] and (lexers.STYLE_SELECTION or 'reverse') or MATCH_HIGHLIGHT_STYLE)
    vis.ui:style_define(style_ids.CURSOR_PRIMARY,
        TYPING_MODES[mode] and INSERT_MODE_CURSOR_STYLE or lexers.STYLE_CURSOR_PRIMARY or 'reverse')
end

-- Styles every whole-word, case-insensitive occurrence of the word under the cursor in the viewport.
-- Returns their byte offsets and the word length, or nothing when the cursor is not on a word.
local function highlight_occurrences_of_word_under_cursor(window)
    local file, selection, viewport = window.file, window.selection, window.viewport.bytes
    local cursor = selection and selection.pos
    if not (cursor and viewport) or cursor >= file.size then return end
    match_highlight_style_id = match_highlight_style_id or vis.ui:style_push(MATCH_HIGHLIGHT_STYLE)
    if not match_highlight_style_id then return end

    local text_start = math.max(viewport.start - VIEWPORT_PADDING_BYTES, 0)
    local text_end = math.min(viewport.finish + VIEWPORT_PADDING_BYTES, file.size)
    local text = file:content(text_start, text_end - text_start)
    local cursor_index = cursor - text_start + 1
    if not text or cursor_index < 1 or not IS_KEYWORD_BYTE[text:byte(cursor_index)] then return end

    local word_first, word_last = cursor_index, cursor_index
    while word_first > 1 and IS_KEYWORD_BYTE[text:byte(word_first - 1)] do word_first = word_first - 1 end
    while IS_KEYWORD_BYTE[text:byte(word_last + 1)] do word_last = word_last + 1 end
    local word_length = word_last - word_first + 1
    local lowercase_word, lowercase_text = text:sub(word_first, word_last):lower(), text:lower()

    local offsets, search_from = {}, 1
    while true do
        local first = lowercase_text:find(lowercase_word, search_from, true)
        if not first then break end
        local last = first + word_length - 1
        if (first > 1 and IS_KEYWORD_BYTE[text:byte(first - 1)]) or IS_KEYWORD_BYTE[text:byte(last + 1)] then
            search_from = first + 1 -- part of a longer word
        else
            local offset = text_start + first - 1
            window:style(match_highlight_style_id, offset, offset + word_length - 1)
            offsets[#offsets + 1] = offset
            search_from = last + 1
        end
    end
    return offsets, word_length
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(window)
    local mode = vis.mode
    apply_mode_dependent_styles(mode)
    if VISUAL_MODES[mode] or not word_highlighting_enabled then return end
    local offsets, word_length = highlight_occurrences_of_word_under_cursor(window)
    if offsets and window == vis.win and window.options.cursorline and #window.selections == 1 then
        pending_cursor_line_repaint = { window = window, offsets = offsets, word_length = word_length }
    end
end)

-- `tput smcup` and Ctrl-L put vis back on its alternate screen after less has left it.
local function show_git_diff_in_pager(git_diff_arguments)
    vis:feedkeys(':!git --no-pager diff --color=always ' .. git_diff_arguments
        .. ' | diff-so-fancy | LESS= less --tabs=4 -R; tput smcup<Enter>\x0c')
end

vis:map(vis.modes.NORMAL, ' w', ':w<Enter>')
vis:map(vis.modes.NORMAL, ' k', ':Rg<Enter>')

vis:map(vis.modes.NORMAL, ' gd', function() show_git_diff_in_pager('') end)

vis:map(vis.modes.NORMAL, ' gj', function()
    local file_name = vis.win and vis.win.file and vis.win.file.name
    if not file_name then
        vis:info('no file name')
        return
    end
    show_git_diff_in_pager("-- '" .. file_name:gsub("'", "'\\''") .. "'")
end)

vis:map(vis.modes.NORMAL, ' dn', ':set nu!<Enter>')
vis:map(vis.modes.NORMAL, ' dc', ':set cursorline!<Enter>')
vis:map(vis.modes.NORMAL, ' dh', function()
    word_highlighting_enabled = not word_highlighting_enabled
    vis:feedkeys('\x0c')
end)
