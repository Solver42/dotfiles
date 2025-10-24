local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Font
config.font = wezterm.font('Fira Code Nerd Font', { weight = 'Bold', style = 'Normal' })
config.font_size = 14.0
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

local gruvbox = wezterm.color.get_builtin_schemes()['GruvboxDarkHard']
gruvbox.background = "#000000"
config.color_schemes = {
  ['solverbox'] = gruvbox
}
config.color_scheme = 'solverbox'
--config.color_scheme = 'GruvboxDark'


-- Transparency
config.window_background_opacity = 0.6

-- Tab bar
config.use_fancy_tab_bar = false
config.colors = {
  tab_bar = {
    background = 'NONE',
    active_tab = {
      bg_color = '#00ff00',
      fg_color = 'NONE',
    },
    inactive_tab_hover = {
      bg_color = 'yellow',
      fg_color = '000000',
    },
    inactive_tab = {
      bg_color = 'NONE',
      fg_color = '00ff00',
    },
  },
}

config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
-- config.tab_bar_at_bottom = true

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local process_name = tab.active_pane.foreground_process_name
  if process_name then
    process_name = process_name:match("([^/\\]+)$") -- Extract just the filename
  end
  return " " .. (process_name or "tab") .. " "
end)

-- Keybindings
config.keys = {
  -- Tab navigation
  {
    key = 'l',
    mods = 'ALT',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'h',
    mods = 'ALT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
}

config.default_prog = { '/bin/bash', '-l', '-c', 'source ~/.bashrc; exec bash' }

return config
