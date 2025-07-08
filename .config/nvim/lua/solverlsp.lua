vim.diagnostic.config({
  virtual_text = true,
  float = { border = 'single' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = "󰋼 ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
    texthl = {
      [vim.diagnostic.severity.ERROR] = "Error",
      [vim.diagnostic.severity.WARN] = "Error",
      [vim.diagnostic.severity.HINT] = "Hint",
      [vim.diagnostic.severity.INFO] = "Info",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})

local function bordered_hover(opts)
  opts = opts or {}
  opts.border = opts.border or "single"
  return vim.lsp.buf.hover(opts)
end

vim.keymap.set("n", "K", bordered_hover, { desc = "Show hover docs" })

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
    vim.keymap.set("n", "<leader>s", "<cmd>Telescope lsp_document_symbols<cr>")
    vim.keymap.set("n", "<leader><leader>s", "<cmd>Telescope lsp_workspace_symbols<cr>")
    -- vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>")
    -- vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>')
    vim.keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_incoming_calls<cr>")
    vim.keymap.set("n", "<leader>go", "<cmd>Telescope lsp_outgoing_calls<cr>")

    -- vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    -- vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    -- vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

vim.lsp.enable('luals')
vim.lsp.enable('jdtls')
vim.lsp.enable('ols')
vim.lsp.enable('rust-analyzer')
vim.lsp.enable('biome')
