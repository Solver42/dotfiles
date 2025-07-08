vim.opt.autoindent=true
vim.opt.expandtab=false
vim.opt.tabstop=2
vim.opt.shiftwidth=2

-- local port = os.getenv('GDScript_Port') or '6005'
-- local pipe = '/tmp/godot.pipe'
-- local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
-- vim.api.nvim_create_autocmd("BufReadPost", {
--   pattern = "*.gd",
--   callback = function()
--     vim.lsp.start({
--       name = 'Godot',
--       cmd = cmd,
--       root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
--       on_attach = function(client, bufnr)
--         vim.fn.serverstart(pipe)
--       end
--     })
--   end
-- })

