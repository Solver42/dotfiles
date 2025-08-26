require('paths')
require('remap')
require('lazy').setup('plugins', { --looking for returns in /lua/plugins/
  ui = {
    size = { width = 0.97, height = 0.9 },
    border = 'single'
  }
})
require('options')

-- vim.cmd('colorscheme solverbox')
vim.cmd('colorscheme box')
require('solvertelescope')
require('solvermason')
require('solverlsp')
require('solverminifiles')
require('solverminimove')
require('solverminijump2d')
require('mini.ai').setup()
require('mini.jump').setup()
require 'colorizer'.setup()
require('gitsigns').setup {
  preview_config = {
    border = 'single'
  },
  signs = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '-' },
    topdelete    = { text = '-' },
    changedelete = { text = '~' },
  },
  signs_staged = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '-' },
    topdelete    = { text = '-' },
    changedelete = { text = '~' },
  },
}

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      vim.cmd [[hi! helpSectionDelim guifg=#559955 guibg=NONE]]
      vim.cmd [[hi! GitSignsAddPreview guifg=#55DD55 guibg=NONE]]
      vim.cmd [[hi! GitSignsDeletePreview guifg=#DD5555 guibg=NONE]]
      vim.cmd [[hi! GitSignsDeledInline guifg=#000000 guibg=#DD5555]]
      vim.cmd [[hi! GitSignsDeleteInline guifg=#000000 guibg=#DD5555]]
      vim.cmd [[hi! GitSignsDeleteVirtLn guifg=#000000 guibg=#DD5555]]
      vim.cmd [[hi! GitSignsAddInline guifg=#000000 guibg=#55DD55]]
      vim.cmd [[hi! GitSignsAddeInline guifg=#000000 guibg=#55DD55]]
      vim.cmd [[hi! GitSignsAddeLnInline guifg=#000000 guibg=#55DD55]]
    end, 100) -- Delay by 100ms to ensure it applies after everything else
  end
})
