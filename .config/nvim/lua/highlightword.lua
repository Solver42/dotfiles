-- HIGHLIGHT WORD UNDER CURSOR
vim.g.hiword = 1
local last_word = ""
local timer = nil
local function highlight_word(word)
  local escaped = vim.fn.escape(word, '\\/')
  local pattern = '\\<' .. escaped .. '\\>'
  vim.fn.clearmatches()
  vim.fn.matchadd('HLCurrentWord', '\\V' .. pattern, 10, -1)
end
local function hw_cursor_moved()
  if vim.g.hiword ~= 1 or not vim.bo.modifiable then
    return
  end
  -- Skip in mini.files and other special buffers
  if vim.bo.buftype ~= "" then
    return
  end
  -- Skip in visual modes
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then -- \22 is <C-v> (visual block)
    vim.fn.clearmatches()
    last_word = ""
    return
  end
  -- Debounce: cancel existing timer and create new one
  if timer then
    timer:stop()
  end
  timer = vim.defer_fn(function()
    local word = vim.fn.expand('<cword>')
    if word == last_word then
      return
    end
    last_word = word
    if word == "" then
      vim.fn.clearmatches()
    else
      highlight_word(word)
    end
  end, 0) -- ms of delay
end
local function toggle_highlight_word()
  vim.g.hiword = vim.g.hiword == 1 and 0 or 1
  if vim.g.hiword ~= 1 then
    vim.fn.clearmatches()
    last_word = ""
  else
    -- Immediately highlight current word when toggling on
    hw_cursor_moved()
  end
end
-- Create autocommand group
local group = vim.api.nvim_create_augroup('HighlightWordUnderCursor', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = group,
  callback = hw_cursor_moved
})
-- Highlight on buffer enter
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  group = group,
  callback = hw_cursor_moved
})
-- Clear highlights when entering visual mode, restore when leaving
vim.api.nvim_create_autocmd('ModeChanged', {
  group = group,
  callback = function()
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' or mode == '\22' then
      vim.fn.clearmatches()
    elseif vim.g.hiword == 1 then
      -- Restore highlight when leaving visual mode
      hw_cursor_moved()
    end
  end
})
-- Optional: Create a command to toggle the feature
vim.api.nvim_create_user_command('ToggleHighlightWord', toggle_highlight_word, {})
