-- Interface "sempre visível": VeryLazy = carrega logo depois da UI inicial
-- aparecer, não durante o boot (não bloqueia o primeiro frame).
local icons = require("config.icons")
local ignore_files = require("config.ignore")

return {

	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				-- separator_style = "slope",
				-- mesmos ícones do vim.diagnostic.config (config/diagnostics.lua),
				-- pra não ter um glifo diferente na aba vs. na gutter/float.
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "center",
						separator = true,
					},
				},
				diagnostics_indicator = function(count, level)
					local icon = (level == "error") and icons.error or icons.warn
					return icon .. count
				end,
			},
		},
	},

	{
		"nvim-tree/nvim-tree.lua",
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Abrir/fechar árvore de arquivos" },
			{ "-", "<cmd>NvimTreeToggle<CR>", desc = "Abrir/fechar árvore de arquivos" },
		},
		opts = {
			view = { width = 32 },
			renderer = { group_empty = true, highlight_git = "all" },
			filters = { dotfiles = false, custom = ignore_files },
			git = { ignore = false },
			actions = { open_file = { quit_on_open = true } },
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				theme = "catppuccin-mocha",
				globalstatus = true,
				component_separators = { left = "│", right = "│" },
				section_separators = { left = "", right = "" },
			},
			extensions = { "nvim-tree", "trouble", "lazy" },
		},
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "VeryLazy",
		opts = { indent = { char = "│" }, scope = { enabled = true } },
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({})
			wk.add({
				{ "<leader>f", group = "buscar" },
				{ "<leader>s", group = "search & replace" },
				{ "<leader>c", group = "código" },
				{ "<leader>x", group = "diagnósticos" },
				{ "<leader>h", group = "git hunks" },
				{ "<leader>d", group = "debug" },
			})
		end,
	},
}
