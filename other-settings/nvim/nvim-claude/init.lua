--╔══════════════════════════════════════════════════════════════════════╗
--║  Requisitos externos: git, ripgrep (rg), fd, node + npm, nerd font   ║
--╚══════════════════════════════════════════════════════════════════════╝

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.diagnostics")

-------------------------------------------------------
-- Bootstrap do lazy.nvim
-------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins" }, -- lê tudo dentro de lua/plugins/*.lua
	},
	ui = { border = "rounded" },
})

require("config.keymaps")
require("config.autocmds")
