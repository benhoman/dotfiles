local wezterm = require("wezterm")

return {
	-- Spawn a fish shell in login mode
	default_prog = { "/usr/bin/env", "fish", "-l" },
	-- default_prog = { "/usr/bin/zsh" },

	-- Appearance
	font = wezterm.font_with_fallback({
		"JetBrainsMono Nerd Font",
		"Noto Color Emoji",
	}),
	font_size = 12.0,
	warn_about_missing_glyphs = false,
	color_scheme = "tokyonight",

	-- Tab Bar
	hide_tab_bar_if_only_one_tab = true,

	-- Scrollback
	scrollback_lines = 10000,
	enable_scroll_bar = false,

	-- Hyperlink Rules
	hyperlink_rules = require("hyperlink_rules"),
}
