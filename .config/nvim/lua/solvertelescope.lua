local ts = require("telescope")
local actions_layout = require('telescope.actions.layout')

local temp_showtabline, temp_laststatus

function _G.global_telescope_find_pre()
  temp_showtabline  = vim.o.showtabline
  temp_laststatus   = vim.o.laststatus
  vim.o.showtabline = 0
  vim.o.laststatus  = 0
end

function _G.global_telescope_leave_prompt()
  vim.o.laststatus  = temp_laststatus
  vim.o.showtabline = temp_showtabline
end

local aug = vim.api.nvim_create_augroup('MyAutocmds', { clear = true })
vim.api.nvim_create_autocmd('User', {
  group = aug, pattern = 'TelescopeFindPre',
  callback = _G.global_telescope_find_pre,
})
vim.api.nvim_create_autocmd('FileType', {
  group = aug, pattern = 'TelescopePrompt',
  callback = function()
    vim.api.nvim_create_autocmd('BufLeave', {
      buffer = 0, callback = _G.global_telescope_leave_prompt,
    })
  end,
})

local sb     = { '─', '│', '─', '│', '┌', '┐', '┘', '└' }
local eb     = { '', '', '', '', '', '', '', '' }
local full   = { width = 999, height = 999 }
local padded = { width = { padding = 0 }, height = { padding = 0 }, preview_width = 0.5 }

local function ivy(layout, preview_bc, extra)
  local t = { theme = "ivy", layout_config = layout, borderchars = { preview = preview_bc } }
  if extra then for k, v in pairs(extra) do t[k] = v end end
  return t
end

ts.setup {
  extensions = {
    fzy_native = { override_generic_sorter = false, override_file_sorter = true },
  },
  defaults = {
    file_ignore_patterns = { "%.png", "%.jpg", "%.jpeg", "%.exe", "%.bin", "%.zip", "%.jar", "%.class" },
    initial_mode = "normal",
    border = 'single',
    mappings = {
      i = { ['<C-p>'] = actions_layout.toggle_preview },
      n = { ['<C-p>'] = actions_layout.toggle_preview },
    },
  },
  pickers = {
    keymaps               = ivy(full,   sb),
    git_commits           = ivy(full,   sb),
    git_branches          = ivy(full,   sb),
    git_files             = ivy(full,   sb),
    git_status            = ivy(full,   sb),
    lsp_incoming_calls    = ivy(full,   sb),
    lsp_outgoing_calls    = ivy(full,   sb),
    lsp_document_symbols  = ivy(full,   eb),
    lsp_workspace_symbols = ivy(full,   eb),
    jumplist              = ivy(padded, sb),
    marks                 = ivy(padded, sb),
    lsp_references        = ivy(padded, sb),
    lsp_definitions       = ivy(padded, sb),
    lsp_implementations   = ivy(padded, sb),
    diagnostics           = ivy(padded, sb),
    buffers               = ivy(padded, eb),
    grep_string           = ivy(padded, eb),
    highlights            = ivy(padded, eb),
    live_grep             = ivy(padded, eb, { initial_mode = "insert" }),
    find_files            = ivy(padded, eb, { initial_mode = "insert" }),
    command_history = {
      theme = "dropdown",
      initial_mode = "normal",
      layout_config = full,
      borderchars = {
        prompt  = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
        results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = sb,
      },
    },
  },
}
ts.load_extension('fzy_native')
