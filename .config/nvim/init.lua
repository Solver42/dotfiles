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
-- vim.cmd('colorscheme box')
vim.cmd('colorscheme green')
require('solvertelescope')
require('solvermason')
require('solverlsp')
require('solverminifiles')
require('solverminimove')
require('solverminijump2d')
require('mini.ai').setup()
require('mini.jump').setup()
require 'colorizer'.setup()
require('highlightword')
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
