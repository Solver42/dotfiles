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
      -- layout_strategy = "horizontal",
      -- layout_config = {
      --   horizontal = {
      --     prompt_position = "top",
      --     width = { padding = 0 },
      --     height = { padding = 0 },
      --     preview_width = 0.5,
      --   },
      -- },
      sorting_strategy = "ascending",
    },
  },
}
