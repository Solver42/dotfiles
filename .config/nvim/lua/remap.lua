vim.g.mapleader = " "

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<cr>', "<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character) <cr>")
-- Single character from user input
map('n', '<leader>f', "<cmd>lua vim.lsp.buf.format()<cr>")
map('n', '-', '<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>')
map('n', '/', '/\\v\\c')
map('n', '<leader>/', '/\\V\\C')

map('n', '<C-t>', '<cmd>tabnew<CR>')
map('n', 'L', '<cmd>tabnext<CR>')
map('n', 'H', '<cmd>tabprev<CR>')
-- map('n', '<leader>l', '<cmd>BufferLineCycleNext<CR>')
-- map('n', '<leader>h', '<cmd>BufferLineCyclePrev<CR>')
-- map("n", "<leader>p", "<cmd>Triptych<cr>")
map('n', '<leader>l', '<cmd>bnext<CR>')
map('n', '<leader>h', '<cmd>bprev<CR>')
map('n', '<leader>gd', '<cmd>lua print(vim.fn.getcwd())<CR>')
-- map('n', '<leader><leader>h', '<cmd>BufferLineMovePrev<CR>')
-- map('n', '<leader><leader>l', '<cmd>BufferLineMoveNext<CR>')
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

map('n', '<leader>w', '<cmd>w<CR>')
-- map('n', '<leader>q', '<cmd>q<CR>')
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
-- map("n", "<A-k>", "<cmd>NvimTreeToggle<cr>")
-- map("n", "<leader>n", "<cmd>NvimTreeFindFile<cr>")
map("n", "<A-d>", "<cmd>Gitsigns preview_hunk<cr>")
-- map("n", "<A-x>", "<cmd>HexToggle<cr>")
-- map("n", "<A-l>", "<cmd>lua toggleLs()<cr>")
-- map("n", "<A-f>", "<cmd>lua togglefdc()<cr>")
map("n", "<A-w>", "<cmd>set wrap!<cr>")
-- map("n", "<A-t>", "<cmd>:ToggleTerm<cr>")
-- map("n", "<A-8>", "<cmd>cr>")
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
vim.cmd([[
  tnoremap <Esc> <C-\><C-n>
  tnoremap <A-t> <C-\><C-n>:ToggleTerm<cr>
]])

-- map('n', '<leader>j', '<cmd>ALENextWrap<cr>')
-- map('n', '<leader>k', '<cmd>ALEPreviousWrap<cr>')
map('n', '<leader>j', '<cmd>lua vim.diagnostic.goto_next()<cr>')
map('n', '<leader>k', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
map("n", "<leader>gg", "<cmd>Neogit<cr>")
-- map('n', '<leader>a', '<cmd>CodeActionMenu<cr>')
-- map('n', '<leader>a', '<cmd>CodeActionMenu<cr>')
map('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')

--  telescope
map("n", "<leader>u", "<cmd>Telescope find_files<cr>")
map("n", "<leader>U", "<cmd>Telescope find_files hidden=true<cr>")
map("n", "<leader>i", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>I", "<cmd>Telescope live_grep hidden=true<cr>")
map("n", "<leader>o", "<cmd>Telescope grep_string<cr>")
map("n", "<leader>O", "<cmd>Telescope grep_string hidden=true<cr>")
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
