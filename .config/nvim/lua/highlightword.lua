-- HIGHLIGHT WORD UNDER CURSOR
local M = {
  enabled = true,
  last_word = "",
  match_id = nil,
}

-- Create highlight group
vim.api.nvim_set_hl(0, 'HLCurrentWord', { link = 'Search', default = true })

local function is_excluded_filetype()
  local ft = vim.bo.filetype
  local excluded = {
    'minifiles',
    'TelescopePrompt',
    'TelescopeResults',
  }

  for _, excluded_ft in ipairs(excluded) do
    if ft == excluded_ft then
      return true
    end
  end

  return false
end

local function highlight_word(word)
  local escaped = vim.fn.escape(word, '\\/')
  local pattern = '\\<' .. escaped .. '\\>'

  -- Clear only our previous match (safely)
  if M.match_id then
    pcall(vim.fn.matchdelete, M.match_id)
    M.match_id = nil
  end

  -- Add new match and store its ID
  M.match_id = vim.fn.matchadd('HLCurrentWord', '\\V' .. pattern, -1)
end

local function clear_highlight()
  if M.match_id then
    pcall(vim.fn.matchdelete, M.match_id)
    M.match_id = nil
  end
end

local function on_cursor_moved()
  -- Early returns for performance
  if not M.enabled or not vim.bo.modifiable or is_excluded_filetype() then
    return
  end

  local word = vim.fn.expand('<cword>')

  -- Skip if word hasn't changed
  if word == M.last_word then
    return
  end

  M.last_word = word

  if word == "" then
    clear_highlight()
  else
    highlight_word(word)
  end
end

local function toggle_highlight()
  M.enabled = not M.enabled
  if not M.enabled then
    clear_highlight()
    M.last_word = ""
  else
    -- Trigger highlight on current word when re-enabled
    M.last_word = ""
    on_cursor_moved()
  end
end

-- Set up autocommands
local group = vim.api.nvim_create_augroup('HighlightWordUnderCursor', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = group,
  callback = on_cursor_moved,
})

-- Clear highlight when leaving buffer to avoid stale match IDs
vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
  group = group,
  callback = function()
    M.last_word = ""
    clear_highlight()
  end,
})

-- Set up keybinding
vim.keymap.set('n', '<leader>ah', toggle_highlight, { desc = 'Toggle highlight word under cursor' })
