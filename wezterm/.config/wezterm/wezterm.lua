local wezterm = require("wezterm")

return {
	automatically_reload_config = true,
	adjust_window_size_when_changing_font_size = false,
	hide_tab_bar_if_only_one_tab = true,
	macos_window_background_blur = 7,
	audible_bell = "Disabled",
	native_macos_fullscreen_mode = true,
	window_decorations = "TITLE | RESIZE",
	window_close_confirmation = "NeverPrompt",
	window_background_opacity = 0.8,
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },

	initial_rows = 30,
	initial_cols = 126,

	font = wezterm.font_with_fallback({
		"TX-02",
		"Berkeley Mono",
		"TX-02 Condensed",
		"SF Mono",
		"MonoLisa",
		"JetBrainsMono Nerd Font",
		"Noto Color Emoji",
	}),
	font_size = 16,
	line_height = 1.2,

	color_scheme = "Dark+",
	colors = { background = "#000000" },
}
