vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.cmd([[autocmd FileType * set noexpandtab]])

-- Find project root (looks for main.odin)
local function find_project_root()
    local current_file = vim.fn.expand('%:p')
    local current_dir = vim.fn.fnamemodify(current_file, ':h')

    -- Search up the directory tree for main.odin
    while current_dir ~= '/' do
        if vim.fn.filereadable(current_dir .. '/main.odin') == 1 then
            return current_dir
        end
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
    end

    -- If not found, return directory of current file
    return vim.fn.fnamemodify(current_file, ':h')
end

-- Check command - validate code without building
local function odin_check()
    if vim.bo.modified then
        vim.cmd('silent write')
    end

    local current_file = vim.fn.expand('%:p')
    local dir = find_project_root()
    local output

    -- If current file is not main.odin, check just this file
    if vim.fn.expand('%:t') ~= 'main.odin' then
        output = vim.fn.system('odin check ' .. vim.fn.shellescape(current_file) .. ' 2>&1')
    else
        -- If in main.odin, check the whole project
        output = vim.fn.system('cd ' .. vim.fn.shellescape(dir) .. ' && odin check . 2>&1')
    end

    vim.cmd('redraw!')

    -- Check for first error: filepath(line:column) message
    local filepath, line, col, message = output:match('([^(]+)%((%d+):(%d+)%)%s*([^\n]*)')

    if filepath then
        -- Found an error - jump to it
        vim.cmd('edit ' .. filepath)
        vim.fn.cursor(tonumber(line), tonumber(col))
        -- Center cursor in the window
        vim.cmd('normal! zz')
        -- Display error message
        vim.cmd('echohl OdinBuildError')
        vim.api.nvim_echo({{message}}, false, {})
        vim.cmd('echohl None')
    else
        vim.cmd('highlight OdinBuildSuccess ctermfg=46 ctermbg=NONE')
        vim.cmd('echohl OdinBuildSuccess')
        vim.api.nvim_echo({{'odin check successful'}}, false, {})
        vim.cmd('echohl None')
    end
end

-- Run command - compile and run without creating executable
local function odin_run()
    if vim.bo.modified then
        vim.cmd('silent write')
    end

    local dir = find_project_root()

    -- First check for errors
    local check_output = vim.fn.system('cd ' .. vim.fn.shellescape(dir) .. ' && odin check . 2>&1')
    local filepath, line, col, message = check_output:match('([^(]+)%((%d+):(%d+)%)%s*([^\n]*)')

    if filepath then
        vim.cmd('edit ' .. filepath)
        vim.fn.cursor(tonumber(line), tonumber(col))
        vim.cmd('normal! zz')
        vim.cmd('redraw!')
        vim.cmd('echohl OdinBuildError')
        vim.api.nvim_echo({{message}}, false, {})
        vim.cmd('echohl None')
    else
        -- No errors - run the program
        vim.cmd('!cd ' .. vim.fn.shellescape(dir) .. ' && odin run .')
    end
end

-- Key mappings
vim.keymap.set('n', '<leader>n', odin_check, { buffer = true, desc = 'Odin check' })
vim.keymap.set('n', '<leader>m', odin_run, { buffer = true, desc = 'Odin run' })
vim.keymap.set('n', '<leader>p', 'A fmt.println("', { buffer = true, desc = 'Insert fmt.println' })

-- Insert mode mapping
vim.keymap.set('i', 'jkp', 'fmt.println("', { buffer = true, desc = 'Insert fmt.println' })

-- Commands
vim.api.nvim_buf_create_user_command(0, 'OdinCheck', odin_check, {})
vim.api.nvim_buf_create_user_command(0, 'OdinRun', odin_run, {})
