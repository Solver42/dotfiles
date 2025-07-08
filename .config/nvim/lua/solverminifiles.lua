require('mini.files').setup({
  content = {
    filter = nil,
    sort = nil,
  },
  mappings = {
    close = '-',
    go_in = 'l',
    go_in_plus = '<cr>',
    go_out = 'h',
    go_out_plus = 'H',
    mark_goto = "'",
    mark_set = 'm',
    reset = '<BS>',
    reveal_cwd = '@',
    show_help = 'g?',
    synchronize = '=',
    trim_left = '<',
    trim_right = '>',
  },
  options = {
    permanent_delete = true,
    use_as_default_explorer = true,
  },
  windows = {
    max_number = 2,
    preview = true,
    width_focus = 50,
    -- width_nofocus = 100,
    -- width_preview = 80,
    width_preview = vim.o.columns - 54,
  },
})
