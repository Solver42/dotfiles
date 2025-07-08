-- vim.api.nvim_set_hl(0, 'MiniJump2dSpot', { reverse = true})
require('mini.jump2d').setup(
  {
    spotter = function(line, opts)
      -- Get the current buffer
      local buf = vim.api.nvim_get_current_buf()
      -- Retrieve the line content (convert the line index to 0-based indexing)
      local line_content = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
      if not line_content then
        return {}
      end
      -- Ignore lines that start with comment characters: --, //, #, or ;
      -- if line_content:match("^[%s]*[%-%/%#;]") then
      --   return {} -- No spots on comment lines
      -- end
      -- Find all matches of words with at least 3 characters
      local spots = {}
      for match_start in line_content:gmatch("()[_%w][_%w][_%w]+") do
        table.insert(spots, match_start)
      end
      return spots
    end,
    -- Characters used for labels of jump spots (in supplied order)
    labels = 'abcdefghijklmnopqrstuvwxyz',
    -- labels = 'abcdefghijklmnopqrstuvwxyzABCDEFGHJIJKLMNOPQRSTUVWXYZ1234567890!"#%&()=?@',
    -- Options for visual effects
    view = {
      -- Whether to dim lines with at least one jump spot
      dim = true,
      -- How many steps ahead to show. Set to big number to show all steps.
      n_steps_ahead = 99,
    },
    -- Which lines are used for computing spots
    allowed_lines = {
      blank = false,        -- Blank line (not sent to spotter even if `true`)
      cursor_before = true, -- Lines before cursor line
      cursor_at = true,     -- Cursor line
      cursor_after = true,  -- Lines after cursor line
      fold = true,          -- Start of fold (not sent to spotter even if `true`)
    },
    -- Which windows from current tabpage are used for visible lines
    allowed_windows = {
      current = true,
      not_current = true,
    },
    -- Functions to be executed at certain events
    hooks = {
      before_start = nil, -- Before jump start
      after_jump = nil,   -- After jump was actually done
    },
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      start_jumping = '<CR>',
    },
    -- Whether to disable showing non-error feedback
    -- This also affects (purely informational) helper messages shown after
    -- idle time if user input is required.
    silent = false,
  })
