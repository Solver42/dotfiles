return {
  'nvim-telescope/telescope.nvim',
  -- branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    defaults = {
      path_display = {
        filename_first = {
          reverse_directories = true
        }
      },
      sorting_strategy = "ascending",
    },
  },
}
