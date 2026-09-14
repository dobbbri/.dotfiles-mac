-- Autocomplete: InsertEnter é o gatilho clássico pra isso.
return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = {
		{ "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },
	},
	config = function()
		require("luasnip.loaders.from_vscode").lazy_load()
		require("blink.cmp").setup({
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = true } },
			sources = {
				default = { "lsp", "path", "buffer", "snippets" },
				per_filetype = { lua = { "lsp", "path", "buffer", "snippets" } },
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
		})
	end,
}
