local wezterm = require("wezterm")

return {
  automatically_reload_config = true,
  adjust_window_size_when_changing_font_size = false,
  hide_tab_bar_if_only_one_tab = true,

  allow_square_glyphs_to_overflow_width = "Never",
  freetype_load_target = "HorizontalLcd",
  freetype_render_target = "HorizontalLcd",
  use_cap_height_to_scale_fallback_fonts = true,
  warn_about_missing_glyphs = false,

  initial_rows = 35,
  initial_cols = 127,

  window_decorations = "TITLE | RESIZE",
  window_background_opacity = 0.8,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  audible_bell = "Disabled",
  visual_bell = {
    fade_in_duration_ms = 5,
    fade_out_duration_ms = 5,
    target = "CursorColor",
  },


  hyperlink_rules = {},
  disable_default_key_bindings = true,
  keys = {
    { key = "c", mods = "CTRL|SHIFT", action = wezterm.action({ CopyTo = "Clipboard" }) },
    { key = "v", mods = "CTRL|SHIFT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
    { key = "phys:Equal", mods = "CTRL|SHIFT", action = "IncreaseFontSize" },
    { key = "phys:Minus", mods = "CTRL|SHIFT", action = "DecreaseFontSize" },
    { key = "phys:Backspace", mods = "CTRL|SHIFT", action = "ResetFontSize" },
  },

  font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font",
    "Noto Color Emoji",
  }),
  font_size = 15,
  line_height = 1,

  colors = {
    background = "#191b1f",
    foreground = "#d3d5d8",
    cursor_fg = "#191b1f",
    cursor_bg = "#ffffff",
    cursor_border = "#eeeeee",
    selection_bg = "#303233",
    selection_fg = "#cacecd",
    scrollbar_thumb = "#16161d",
    split = "#16161d",
    ansi = {
      "#282c34",
      "#c2290a",
      "#66b814",
      "#f2b90d",
      "#06a8f9",
      "#e06ef7",
      "#0ac2c2",
      "#d5d7dd",
    },
    brights = {
      "#595e68",
      "#f2330d",
      "#80e619",
      "#f5c73d",
      "#38b9fa",
      "#eb9efa",
      "#0df2f2",
      "#e3e5e8",
    },
  },

  color_scheme = "Violet Dark",
}
