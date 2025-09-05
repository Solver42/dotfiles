vim.g.mapleader = " "

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<cr>', "<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character) <cr>")
map('n', '<leader>f', "<cmd>lua vim.lsp.buf.format()<cr>")
map('n', '-', '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>')
map('n', '/', '/\\v\\c')
map('n', '<leader>/', '/\\V\\C')

map('n', '<C-t>', '<cmd>tabnew<CR>')
map('n', 'L', '<cmd>tabnext<CR>')
map('n', 'H', '<cmd>tabprev<CR>')
map('n', '<leader>l', '<cmd>bnext<CR>')
map('n', '<leader>h', '<cmd>bprev<CR>')
map('n', '<leader>gd', '<cmd>lua print(vim.fn.getcwd())<CR>')
map("n", "ss", "<cmd>split<Return>")
map("n", "sv", "<cmd>vsplit<Return>")
map("n", "sq", "ZQ")
map("n", "sh", "<C-w>h")
map("n", "s<left>", "<C-w>h")
map("n", "sj", "<C-w>j")
map("n", "s<down>", "<C-w>j")
map("n", "sk", "<C-w>k")
map("n", "s<up>", "<C-w>k")
map("n", "sl", "<C-w>l")
map("n", "s<right>", "<C-w>l")
map('n', 'sa', '<cmd>silent vert ball<CR>')
map('n', 'so', '<cmd>only<CR>')

map('n', '<leader>w', '<cmd>w<CR>')
map('n', '<leader>q', '<cmd>bd<CR>')
-- map("n", "<leader>rr", "<cmd>Rest run<CR>")
-- map("n", "<leader>rl", "<cmd>Rest last<CR>")
-- map("n", "<leader>ro", "<cmd>Rest open<CR>")
map('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<leader>e', '<cmd>Gitsigns blame<CR>')

--  insert mode
map('i', 'jkj', '<esc>')
map('i', 'jkw', '<esc>ZZ')
map('i', 'jkq', '<esc>ZQ')
map('i', 'jkf', '<esc><cmd>w<cr>')
map('i', '<c-h>', '<esc>cw')

-- TOGGLE
function ToggleLs()
  if vim.opt.laststatus:get() == 0 then
    vim.opt.laststatus = 3
  else
    vim.opt.laststatus = 0
  end
end

map("n", "<A-m>", "<cmd>lua ToggleLs()<cr>")

-- map("n", "<A-v>", "<cmd>Markview Toggle<cr>")
map("n", "<A-n>", "<cmd>set nu!<cr>")
map("n", "<A-u>", "<cmd>UndotreeToggle<cr>")
map("n", "<A-d>", "<cmd>Gitsigns preview_hunk<cr>")
-- map("n", "<A-x>", "<cmd>HexToggle<cr>")
map("n", "<A-w>", "<cmd>set wrap!<cr>")
map("n", "<A-a>", "<cmd>lua require(\"dapui\").toggle()<cr>")
map("n", "<A-r>", "<cmd>TroubleToggle<cr>")
map("n", "<A-s>", "<cmd>Outline<cr>")
map("n", "<A-c>", "<cmd>set cursorline!<cr>")
map("n", "<A-i>", "<cmd>Gitsigns toggle_signs<cr>")

-- Custom toggle for :Ex
_G.toggle_explorer = function()
  local is_explorer_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
    if string.find(bufname, "NetrwTreeListing") then
      is_explorer_open = true
      break
    end
  end

  if is_explorer_open then
    vim.cmd('bd')
  else
    vim.cmd('Ex')
  end
end

-- Map Alt + f to toggle explorer
map('n', '<A-f>', ":lua toggle_explorer()<CR>")

--  terminal
-- vim.cmd([[
--   tnoremap <Esc> <C-\><C-n>
--   tnoremap <A-t> <C-\><C-n>:ToggleTerm<cr>
-- ]])
--
map('n', '<M-t>', '<cmd>ToggleTerm<cr>')

map('n', '<leader>j', '<cmd>lua vim.diagnostic.goto_next()<cr>')
map('n', '<leader>k', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
map("n", "<leader>gg", "<cmd>Neogit<cr>")
map('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')

--  telescope
map("n", "<leader>u", "<cmd>Telescope find_files find_command=rg,--no-ignore,--files<cr>")
map("n", "<leader>U", "<cmd>Telescope find_files find_command=rg,--no-ignore,--hidden,--files<cr>")
-- map("n", "<leader>U", "<cmd>Telescope find_files hidden=true<cr>")
map("n", "<leader>i", "<cmd>Telescope live_grep <cr>")
map("n", "<leader>I", "<cmd>Telescope live_grep hidden=true <cr>")
map("n", "<leader>o", "<cmd>Telescope grep_string <cr>")
map("n", "<leader>O", "<cmd>Telescope grep_string hidden=true <cr>")
map("n", "<leader>.", "<cmd>Telescope command_history<cr>")
map("n", "<leader>gf", "<cmd>Telescope git_files<cr>")
map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>")
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>")
map("n", "<leader>tm", "<cmd>Telescope jumplist<cr>")
-- map("n", "<leader>s", "<cmd>Telescope lsp_document_symbols<cr>")
map("n", "<leader><leader>s", "<cmd>Telescope lsp_workspace_symbols<cr>")
map("n", "gr", "<cmd>Telescope lsp_references<cr>")
-- map("n", "<leader>gi", "<cmd>Telescope lsp_incoming_calls<cr>")
-- map("n", "<leader>go", "<cmd>Telescope lsp_outgoing_calls<cr>")
map("n", "<leader>b", "<cmd>Telescope buffers<cr>")
--  telescope extenstions
--map("n", "<leader>,", "<cmd>Telescope file_browser<cr>")
map("n", "<leader>th", "<cmd>Telescope highlights<cr>")
map("n", "<leader>td", "<cmd>Telescope diff diff_current<cr>")
-- map("n", "<leader>td", "<cmd>Telescope diff diff_files<cr>")
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>")

--  DAP
map("n", "<leader>8", "<cmd>DapToggleBreakpoint<cr>")
map("n", "<leader>5", "<cmd>DapContinue<cr>")
map("n", "<leader>7", "<cmd>DapStepOver<cr>")
map("n", "<leader>9", "<cmd>DapStepInto<cr>")
map("n", "<leader>0", "<cmd>DapStepOut<cr>")
map("n", "<leader>dq", "<cmd>DapTerminate<cr>")

-- map('n', '<leader>r', 'viw"hy:%s/\\<<C-r>h\\>//gI<left><left><left>')
-- visual
map("v", "<leader>r", "\"hy:%s/\\<<C-r>h\\>//gI<left><left><left>")

-- map("v", "<C-j>", ":m '>+1<CR>gv=gv")

-- vim.keymap.set("n", "mw", function()
--   local surround_char = vim.fn.nr2char(vim.fn.getchar())
--
--   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--   local line = vim.api.nvim_get_current_line()
--
--   local s = vim.fn.expand("<cword>")
--   local start_col = string.find(line, s, 1, true)
--   if not start_col then
--     vim.notify("No word found under cursor", vim.log.levels.WARN)
--     return
--   end
--
--   local end_col = start_col + #s
--   local new_line =
--     line:sub(1, start_col - 1)
--     .. surround_char .. s .. surround_char
--     .. line:sub(end_col)
--
--   vim.api.nvim_set_current_line(new_line)
--   vim.api.nvim_win_set_cursor(0, { row, col + 1 })
-- end, { desc = "Add surrounding characters" })
--
-- vim.keymap.set("n", "mW", function()
--   local surround_char = vim.fn.nr2char(vim.fn.getchar())
--
--   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--   local line = vim.api.nvim_get_current_line()
--
--   local s = vim.fn.expand("<cWORD>")
--   local start_col = string.find(line, s, 1, true)
--   if not start_col then
--     vim.notify("No word found under cursor", vim.log.levels.WARN)
--     return
--   end
--
--   local end_col = start_col + #s
--   local new_line =
--     line:sub(1, start_col - 1)
--     .. surround_char .. s .. surround_char
--     .. line:sub(end_col)
--
--   vim.api.nvim_set_current_line(new_line)
--   vim.api.nvim_win_set_cursor(0, { row, col + 1 })
-- end, { desc = "Add surrounding characters" })
--
-- vim.keymap.set("n", "mc", function()
--   local find_char = vim.fn.nr2char(vim.fn.getchar())
--   local replace_char = vim.fn.nr2char(vim.fn.getchar())
--
--   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--   local line = vim.api.nvim_get_current_line()
--
--   -- Lua string indexing is 1-based
--   local left = col
--   while left > 0 and line:sub(left, left) ~= find_char do
--     left = left - 1
--   end
--
--   local right = col + 1
--   while right <= #line and line:sub(right, right) ~= find_char do
--     right = right + 1
--   end
--
--   if left > 0 and right <= #line then
--     local new_line =
--       line:sub(1, left - 1)
--       .. replace_char
--       .. line:sub(left + 1, right - 1)
--       .. replace_char
--       .. line:sub(right + 1)
--
--     vim.api.nvim_set_current_line(new_line)
--     vim.api.nvim_win_set_cursor(0, { row, math.min(col + 1, #new_line) })
--   else
--     vim.notify("Could not find both surrounding characters", vim.log.levels.WARN)
--   end
-- end, { desc = "Change surrounding characters" })
--
-- vim.keymap.set("n", "mx", function()
--   local target = vim.fn.nr2char(vim.fn.getchar())
--
--   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--   local line = vim.api.nvim_get_current_line()
--
--   local left = col
--   while left > 0 and line:sub(left, left) ~= target do
--     left = left - 1
--   end
--
--   local right = col + 1
--   while right <= #line and line:sub(right, right) ~= target do
--     right = right + 1
--   end
--
--   if left > 0 and right <= #line then
--     local new_line =
--       line:sub(1, left - 1)
--       .. line:sub(left + 1, right - 1)
--       .. line:sub(right + 1)
--
--     vim.api.nvim_set_current_line(new_line)
--     vim.api.nvim_win_set_cursor(0, { row, math.min(col, #new_line) })
--   else
--     vim.notify("Could not find both surrounding characters", vim.log.levels.WARN)
--   end
-- end, { desc = "Delete surrounding characters" })



local pairs = {
  ["("] = ")",
  ["{"] = "}",
  ["["] = "]",
  ["<"] = ">",
  [")"] = "(",
  ["}"] = "{",
  ["]"] = "[",
  [">"] = "<",
}

local function get_pair(c)
  return pairs[c]
end

vim.keymap.set("n", "mw", function()
  local left = vim.fn.nr2char(vim.fn.getchar())
  local right = get_pair(left) or left

  local word = vim.fn.expand("<cword>")
  local line = vim.api.nvim_get_current_line()
  local col = string.find(line, word, 1, true)

  if not col then return end

  local prefix = line:sub(1, col - 1)
  local suffix = line:sub(col + #word)
  local new_line = prefix .. left .. word .. right .. suffix

  vim.api.nvim_set_current_line(new_line)
end, { desc = "Add surrounding character pair" })

vim.keymap.set("n", "mW", function()
  local left = vim.fn.nr2char(vim.fn.getchar())
  local right = get_pair(left) or left

  local word = vim.fn.expand("<cWORD>")
  local line = vim.api.nvim_get_current_line()
  local col = string.find(line, word, 1, true)

  if not col then return end

  local prefix = line:sub(1, col - 1)
  local suffix = line:sub(col + #word)
  local new_line = prefix .. left .. word .. right .. suffix

  vim.api.nvim_set_current_line(new_line)
end, { desc = "Add surrounding character pair" })

vim.keymap.set("n", "mx", function()
  local c = vim.fn.nr2char(vim.fn.getchar())
  local left = c
  local right = get_pair(c) or c

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local l = col
  while l > 0 and line:sub(l, l) ~= left do l = l - 1 end

  local r = col + 1
  while r <= #line and line:sub(r, r) ~= right do r = r + 1 end

  if l > 0 and r <= #line then
    local new_line = line:sub(1, l - 1) .. line:sub(l + 1, r - 1) .. line:sub(r + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, math.min(col, #new_line) })
  else
    vim.notify("Could not find both surrounding characters", vim.log.levels.WARN)
  end
end, { desc = "Delete smart surrounding characters" })

vim.keymap.set("n", "mc", function()
  local find_char = vim.fn.nr2char(vim.fn.getchar())
  local replace_char = vim.fn.nr2char(vim.fn.getchar())

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  -- Lua string indexing is 1-based
  local left = col
  while left > 0 and line:sub(left, left) ~= find_char do
    left = left - 1
  end

  local right = col + 1
  while right <= #line and line:sub(right, right) ~= find_char do
    right = right + 1
  end

  if left > 0 and right <= #line then
    local new_line =
      line:sub(1, left - 1)
      .. replace_char
      .. line:sub(left + 1, right - 1)
      .. replace_char
      .. line:sub(right + 1)

    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, math.min(col + 1, #new_line) })
  else
    vim.notify("Could not find both surrounding characters", vim.log.levels.WARN)
  end
end, { desc = "Change surrounding characters" })

