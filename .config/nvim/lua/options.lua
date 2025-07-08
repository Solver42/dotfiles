-- vim.loader.enable()
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "*",
--   desc = "prevent colorscheme clears self-defined DAP icon colors.",
--   callback = function()
--     vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939' })
--     vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef' })
--     vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379' })
--   end
-- })

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    if vim.bo.filetype == "help" then
      vim.cmd("only")
    end
  end,
})

-- vim.cmd([[command! -nargs=1 TH tab help <args>]])
-- vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = 'DapBreakpoint' })
-- vim.fn.sign_define('DapBreakpointCondition', { text = ' ﳁ', texthl = 'DapBreakpoint' })
-- vim.fn.sign_define('DapBreakpointRejected', { text = ' ', texthl = 'DapBreakpoint' })
-- vim.fn.sign_define('DapLogPoint', { text = ' ', texthl = 'DapLogPoint' })
-- vim.fn.sign_define('DapStopped', { text = ' ', texthl = 'DapStopped' })
vim.opt.fillchars      = {
  eob = ' ',
  lastline = ' ',
  fold = ' ',
  foldopen = ' ',
  foldclose = ' ',
  foldsep = ' ',
  diff =
  ' '
}
-- vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.backupdir      = vim.fn.expand("~/tmp/nvimbackup")
vim.opt.backup         = true
vim.opt.swapfile       = false
vim.opt.undodir        = vim.fn.expand("~/tmp/nvimundo")
vim.opt.undofile       = true
-- vim.opt.guitablabel="%t"
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.termguicolors  = true
vim.opt.errorbells     = false
vim.opt.visualbell     = true
vim.opt.hidden         = true
-- vim.opt.fileformats    = "unix,mac,dos"
-- vim.opt.encoding       = "utf-8"
vim.opt.clipboard      = "unnamedplus"
vim.opt.wildignorecase = true
vim.opt.wildignore     =
".git/**,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
-- vim.opt.history        = 4000
-- vim.opt.shada          = "!,'300,<50,@100,s10,h"
-- vim.opt.backupskip     = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"
vim.opt.smarttab       = true
vim.opt.smartindent    = true
vim.opt.shiftround     = true
vim.opt.lazyredraw     = false
vim.opt.timeout        = true
vim.opt.ttimeout       = true
vim.opt.timeoutlen     = 500
vim.opt.ttimeoutlen    = 10
vim.opt.updatetime     = 500
-- vim.opt.redrawtime     = 100
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.infercase      = true
vim.opt.incsearch      = true
vim.opt.wrap           = false
vim.opt.wrapscan       = true
vim.opt.complete       = ".,w,b,k"
vim.opt.inccommand     = "nosplit"
vim.opt.grepprg        = 'rg --hidden --vimgrep --smart-case --glob "!{.git,node_modules,*~}/*" --'
vim.opt.breakat        = [[\ \	;:,!?]]
vim.opt.startofline    = false
--vim.opt.virtualedit = "onemore"
--vim.opt.whichwrap      = "h,l,<,>,[,],~"
vim.opt.splitbelow     = true
vim.opt.splitright     = true

vim.opt.switchbuf      = "useopen"
vim.opt.backspace      = "indent,eol,start"
vim.opt.diffopt        = "filler,iwhite,internal,algorithm:patience"
vim.opt.completeopt    = "menuone,noselect,noinsert"
vim.opt.jumpoptions    = "stack"
vim.opt.showmode       = false
vim.opt.shortmess      = "aotTIcFC"
vim.opt.scrolloff      = 2
vim.opt.sidescrolloff  = 5
--vim.opt.foldcolumn = "9"
-- vim.opt.foldlevel      = 99
-- vim.opt.foldlevelstart = 99
vim.opt.ruler          = false
vim.opt.list           = true
vim.opt.showtabline    = 1
vim.opt.winwidth       = 30
vim.opt.winminwidth    = 10
vim.opt.pumheight      = 15
vim.opt.helpheight     = 12
vim.opt.previewheight  = 12
vim.opt.showcmd        = false
vim.opt.cmdwinheight   = 5
vim.opt.equalalways    = true
vim.opt.laststatus     = 0
vim.opt.display        = "lastline"
vim.opt.showbreak      = "﬌  "
vim.opt.listchars      = "tab:  ,nbsp:+,trail:·,extends:→,precedes:←"
vim.opt.pumblend       = 0
vim.opt.winblend       = 0
vim.opt.syntax         = "off"
-- vim.opt.re             = 0
vim.opt.title          = true
vim.opt.background     = "dark"

vim.opt.ttyfast        = true
vim.opt.fileencoding   = "utf-8"
vim.opt.mouse          = "a"
vim.opt.textwidth      = 120
vim.opt.hlsearch       = true
vim.opt.autowrite      = true
vim.opt.autoread       = true
vim.opt.breakindent    = true
vim.opt.breakindentopt = "shift:2,min:20"
vim.opt.showmatch      = true
vim.opt.numberwidth    = 3
vim.opt.conceallevel   = 0
vim.opt.concealcursor  = "niv"
vim.cmd('set guicursor=n:block,i-c:ver25,v:hor25')
vim.opt.linebreak      = true
vim.opt.foldenable     = true
vim.opt.signcolumn     = "yes:1"
vim.opt.cursorline     = true
vim.opt.cursorcolumn   = false
vim.opt.number         = false
vim.opt.relativenumber = false
vim.opt.splitkeep      = "screen"

--netrw
vim.g.netrw_banner     = 0
vim.g.netrw_keepdir    = 0
vim.g.netrw_winsize    = 30
vim.g.netrw_altv       = 1
vim.g.netrw_liststyle  = 3

local fn               = vim.fn
local api              = vim.api

local M                = {}

-- highlight groups
M.colors               = {
  active       = '%#PmenuSel#',
  inactive     = '%#PmenuSel#',
  mode         = '%#TabLineSel#',
  mode_alt     = '%#TabLineSel#',
  git          = '%#PmenuSel#',
  git_alt      = '%#PmenuSel#',
  filetype     = '%#PmenuSel#',
  filetype_alt = '%#PmenuSel#',
  line_col     = '%#TabLineSel#',
  line_col_alt = '%#TabLineSel#',
}

M.trunc_width          = setmetatable({
  mode       = 80,
  git_status = 90,
  filename   = 140,
  line_col   = 60,
}, {
  __index = function()
    return 80
  end
})

M.is_truncated         = function(_, width)
  local current_width = api.nvim_win_get_width(0)
  return current_width < width
end

M.modes                = setmetatable({
  ['n']  = { 'Normal', 'N' },
  ['no'] = { 'N·Pending', 'N·P' },
  ['v']  = { 'Visual', 'V' },
  ['V']  = { 'V·Line', 'V·L' },
  ['']  = { 'V·Block', 'V·B' }, -- this is not ^V, but it's , they're different
  ['s']  = { 'Select', 'S' },
  ['S']  = { 'S·Line', 'S·L' },
  ['']  = { 'S·Block', 'S·B' }, -- same with this one, it's not ^S but it's 
  ['i']  = { 'Insert', 'I' },
  ['ic'] = { 'Insert', 'I' },
  ['R']  = { 'Replace', 'R' },
  ['Rv'] = { 'V·Replace', 'V·R' },
  ['c']  = { 'Command', 'C' },
  ['cv'] = { 'Vim·Ex ', 'V·E' },
  ['ce'] = { 'Ex ', 'E' },
  ['r']  = { 'Prompt ', 'P' },
  ['rm'] = { 'More ', 'M' },
  ['r?'] = { 'Confirm ', 'C' },
  ['!']  = { 'Shell ', 'S' },
  ['t']  = { 'Terminal ', 'T' },
}, {
  __index = function()
    return { 'Unknown', 'U' } -- handle edge cases
  end
})

M.get_current_mode     = function(self)
  local current_mode = api.nvim_get_mode().mode

  if self:is_truncated(self.trunc_width.mode) then
    return string.format(' %s ', self.modes[current_mode][2]):upper()
  end
  return string.format(' %s ', self.modes[current_mode][1]):upper()
end

M.get_git_status       = function(self)
  -- use fallback because it doesn't set this variable on the initial `BufEnter`
  local signs = vim.b.gitsigns_status_dict or { head = '', added = 0, changed = 0, removed = 0 }
  local is_head_empty = signs.head ~= ''

  if self:is_truncated(self.trunc_width.git_status) then
    return is_head_empty and string.format('  %s ', signs.head or '') or ''
  end

  return is_head_empty and string.format(
    ' +%s ~%s -%s   %s ',
    signs.added, signs.changed, signs.removed, signs.head
  ) or ''
end

M.get_filename         = function(self)
  if self:is_truncated(self.trunc_width.filename) then return " %<%f " end
  return " %<%F "
end

M.get_filetype         = function()
  local file_name, file_ext = fn.expand("%:t"), fn.expand("%:e")
  local icon = require 'nvim-web-devicons'.get_icon(file_name, file_ext, { default = true })
  local filetype = vim.bo.filetype
  if filetype == '' then return '' end
  return string.format(' %s %s ', icon, filetype):lower()
end

M.get_line_col         = function(self)
  if self:is_truncated(self.trunc_width.line_col) then return ' %l:%c ' end
  return ' %l:%c '
end

M.set_active           = function(self)
  local colors = self.colors

  local mode = colors.mode .. self:get_current_mode()
  local mode_alt = colors.mode_alt
  local git = colors.git .. self:get_git_status()
  local git_alt = colors.git_alt
  local filename = colors.inactive .. self:get_filename()
  local filetype_alt = colors.filetype_alt
  local filetype = colors.filetype .. self:get_filetype()
  local line_col = colors.line_col .. self:get_line_col()
  local line_col_alt = colors.line_col_alt

  return table.concat({
    colors.active, mode, mode_alt, git, git_alt,
    "%=", filename, "%=",
    filetype_alt, filetype, line_col_alt, line_col
  })
end

M.set_inactive         = function(self)
  return self.colors.inactive .. '%= %F %='
end

M.set_explorer         = function(self)
  local title = self.colors.mode .. '   '
  local title_alt = self.colors.mode_alt

  return table.concat({ self.colors.active, title, title_alt })
end

Statusline             = setmetatable(M, {
  __call = function(statusline, mode)
    if mode == "active" then return statusline:set_active() end
    if mode == "inactive" then return statusline:set_inactive() end
    if mode == "explorer" then return statusline:set_explorer() end
  end
})

-- set statusline
-- TODO: replace this once we can define autocmd using lua
api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline('explorer')
  augroup END
]], false)
