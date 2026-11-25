-- LSP: VeryLazy — precisa estar pronto cedo (capabilities/on_attach), mas
-- não precisa bloquear o primeiro frame igual o treesitter.
return {
	{ "williamboman/mason.nvim", event = "VeryLazy", opts = {} },
	{
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"ts_ls",
				"astro",
				"tailwindcss",
				"cssls",
				"html",
				"jsonls",
				"emmet_ls",
				"lua_ls",
				"biome",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = { "williamboman/mason-lspconfig.nvim", "saghen/blink.cmp" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local on_attach = function(_, bufnr)
				local map = function(keys, fn, desc)
					vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = desc })
				end
				map("gd", vim.lsp.buf.definition, "Ir para definição")
				map("gr", vim.lsp.buf.references, "Ver referências")
				map("K", vim.lsp.buf.hover, "Documentação (hover)")
				map("<leader>rn", vim.lsp.buf.rename, "Renomear símbolo")
				map("<leader>ca", vim.lsp.buf.code_action, "Ações de código")
			end

			vim.lsp.config("*", { capabilities = capabilities, on_attach = on_attach })

			-- Tailwind precisa reconhecer classes dentro de .astro, .tsx, .jsx etc.
			vim.lsp.config("tailwindcss", {
				filetypes = {
					"html",
					"css",
					"astro",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				init_options = { userLanguages = { astro = "html" } },
			})

			-- emmet_ls por padrão só ativa em html/css.
			vim.lsp.config("emmet_ls", {
				filetypes = { "html", "css", "astro", "javascriptreact", "typescriptreact" },
			})

			vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim", "require" } } } } })

			-- "biome" só "ativa de verdade" em projetos com biome.json/biome.jsonc
			-- na raiz (root_dir/root_markers padrão do nvim-lspconfig).
			vim.lsp.enable({
				"ts_ls",
				"astro",
				"cssls",
				"html",
				"jsonls",
				"lua_ls",
				"biome",
				"tailwindcss",
				"emmet_ls",
			})
		end,
	},
	{ "brenoprata10/nvim-highlight-colors", event = { "BufReadPre", "BufNewFile" }, opts = { render = "background" } },
}
