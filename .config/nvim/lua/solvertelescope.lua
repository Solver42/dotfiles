local ts = require("telescope")

-- keeps track of current `tabline` and `statusline`, so we can restore it after closing telescope
local temp_showtabline
local temp_laststatus

function _G.global_telescope_find_pre()
  temp_showtabline = vim.o.showtabline
  temp_laststatus = vim.o.laststatus
  vim.o.showtabline = 0
  vim.o.laststatus = 0
end

function _G.global_telescope_leave_prompt()
  vim.o.laststatus = temp_laststatus
  vim.o.showtabline = temp_showtabline
end

vim.cmd([[
  augroup MyAutocmds
    autocmd!
    autocmd User TelescopeFindPre lua global_telescope_find_pre()
    autocmd FileType TelescopePrompt autocmd BufLeave <buffer> lua global_telescope_leave_prompt()
  augroup END
]])

-- ts.load_extension('media_files')
ts.setup {
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
  },
  defaults = {
    file_ignore_patterns = { "%.png", "%.jpg", "%.jpeg", "%.exe", "%.bin", "%.zip", "%.jar", "%.class" },
    initial_mode = "normal",
    border = 'single',
    mappings = {
      i = {
        ['<C-p>'] = require('telescope.actions.layout').toggle_preview
      },
      n = {
        ['<C-p>'] = require('telescope.actions.layout').toggle_preview
      }

    },
  },
  pickers = {
    keymaps = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    buffers = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        --     results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = { '', '', '', '', '', '', '', '' },
      },
      hidden = false
    },
    git_commits = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
      hidden = false
    },
    -- git_bcommits = {
    --   theme = "ivy",
    --   borderchars = {
    --     preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    --   },
    --   hidden = false
    -- },
    git_branches = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
      hidden = false
    },
    git_files = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
      hidden = false
    },
    git_status = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
      hidden = false
    },
    command_history = {
      theme = "dropdown",
      initial_mode = "normal",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
        results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    jumplist = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        --     results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
      hidden = false
    },
    marks = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
      hidden = false
    },
    grep_string = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        -- preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        preview = { '', '', '', '', '', '', '', '' },
      },
      hidden = false
    },
    live_grep = {
      initial_mode = "insert",
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        -- preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        preview = { '', '', '', '', '', '', '', '' },
      },
      hidden = false
    },
    find_files = {
      initial_mode = "insert",
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        -- preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        preview = { '', '', '', '', '', '', '', '' },
      },
      --   -- no_ignore = true,
    },
    lsp_references = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        --     results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    lsp_definitions = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        --     results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    lsp_implementations = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        --     results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    diagnostics = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        --     results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    lsp_document_symbols = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '', '', '', '', '', '', '', '' },
      },
    },
    lsp_workspace_symbols = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '', '', '', '', '', '', '', '' },
      },
    },
    lsp_incoming_calls = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    lsp_outgoing_calls = {
      theme = "ivy",
      layout_config = {
        width = 999,
        height = 999,
      },
      borderchars = {
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      },
    },
    highlights = {
      theme = "ivy",
      layout_config = {
        width = { padding = 0 },
        height = { padding = 0 },
        preview_width = 0.5,
      },
      borderchars = {
        -- preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        preview = { '', '', '', '', '', '', '', '' },
      },
    },
  },
  -- file_browser = {
  --   theme = "ivy",
  --   layout_config = {
  --     width = 999,
  --     height = 999,
  --   },
  --   borderchars = {
  --     preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  --   },
  --   hidden = false,
  --   -- disables netrw and use telescope-file-browser in its place
  --   hijack_netrw = true,
  --   mappings = {
  --     ["i"] = {
  --       -- your custom insert mode mappings
  --     },
  --     ["n"] = {
  --       -- your custom normal mode mappings
  --       -- ["h"] = ts.goto_parent_dir
  --       ["P"] = ts.goto_parent_dir,
  --       [","] = ts.goto_parent_dir,
  --     },
  --   },
  -- },
  -- media_files = {
  --   -- filetypes whitelist
  --   -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
  --   filetypes = { "png", "webp", "jpg", "jpeg" },
  --   -- find command (defaults to `fd`)
  --   find_cmd = "rg"
  -- },
  -- git_worktree = {
  -- theme = "ivy",
  -- layout_config = {
  -- width = 999,
  -- height = 999,
  -- },
  -- borderchars = {
  -- preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  -- },
  -- }
}
-- ts.load_extension "file_browser"
ts.load_extension('fzy_native')
-- ts.load_extension("diff")
-- ts.load_extension("git_worktree")
