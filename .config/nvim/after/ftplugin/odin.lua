vim.opt.tabstop     = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth  = 4
vim.cmd('autocmd FileType * set noexpandtab')

local function find_project_root()
  local file = vim.fn.expand('%:p')
  local dir  = vim.fn.fnamemodify(file, ':h')
  while dir ~= '/' do
    if vim.fn.filereadable(dir .. '/main.odin') == 1 then return dir end
    dir = vim.fn.fnamemodify(dir, ':h')
  end
  return vim.fn.fnamemodify(file, ':h')
end

local function show_build_error(output)
  local filepath, line, col, message = output:match('([^(]+)%((%d+):(%d+)%)%s*([^\n]*)')
  if not filepath then return false end
  vim.cmd('edit ' .. filepath)
  vim.fn.cursor(tonumber(line), tonumber(col))
  vim.cmd('normal! zz')
  vim.cmd('redraw!')
  vim.cmd('echohl OdinBuildError')
  vim.api.nvim_echo({ { message } }, false, {})
  vim.cmd('echohl None')
  return true
end

local function odin_check()
  if vim.bo.modified then vim.cmd('silent write') end
  local file   = vim.fn.expand('%:p')
  local dir    = find_project_root()
  local output
  if vim.fn.expand('%:t') ~= 'main.odin' then
    output = vim.fn.system('odin check ' .. vim.fn.shellescape(file) .. ' 2>&1')
  else
    output = vim.fn.system('cd ' .. vim.fn.shellescape(dir) .. ' && odin check . 2>&1')
  end
  vim.cmd('redraw!')
  if not show_build_error(output) then
    vim.cmd('highlight OdinBuildSuccess ctermfg=46 ctermbg=NONE')
    vim.cmd('echohl OdinBuildSuccess')
    vim.api.nvim_echo({ { 'odin check successful' } }, false, {})
    vim.cmd('echohl None')
  end
end

local function odin_run()
  if vim.bo.modified then vim.cmd('silent write') end
  local dir   = find_project_root()
  local check = vim.fn.system('cd ' .. vim.fn.shellescape(dir) .. ' && odin check . 2>&1')
  if not show_build_error(check) then
    vim.cmd('!cd ' .. vim.fn.shellescape(dir) .. ' && odin run .')
  end
end

vim.keymap.set('n', '<leader>n', odin_check,        { buffer = true, desc = 'Odin check' })
vim.keymap.set('n', '<leader>m', odin_run,           { buffer = true, desc = 'Odin run' })
vim.keymap.set('n', '<leader>p', 'A fmt.println("', { buffer = true, desc = 'Insert fmt.println' })
vim.keymap.set('i', 'jkp',       'fmt.println("',   { buffer = true, desc = 'Insert fmt.println' })
vim.api.nvim_buf_create_user_command(0, 'OdinCheck', odin_check, {})
vim.api.nvim_buf_create_user_command(0, 'OdinRun',   odin_run,   {})
