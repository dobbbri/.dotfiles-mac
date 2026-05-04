-- ▄█▀▀▄ ▄█▀█ ▄█▀▀▄ ▄█ █ ▄█ ▄█▄ ▄█
-- ▓█  █ ▓█▄  ▓█  █ ▓█ █ ▓█ ▓█ ▀ █
-- ▓█  █ ▓█ ▄ ▓█  █ ▓█ █ ▓█ ▓█   █
-- ▓█  █ ▓█▄█ ▀█▄▄▀ ▀█▄▀ ▓█ ▓█   █

vim.g.mapleader = " " -- Set space as the leader key for custom mappings
vim.g.maplocalleader = " " -- Set space as the local leader key for buffer-local mappings

vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/saghen/blink.lib",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  -- "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/arborist-ts/arborist.nvim",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/MagicDuck/grug-far.nvim",
  "https://github.com/3rd/image.nvim",
  "https://github.com/luukvbaal/statuscol.nvim",
  "https://github.com/mg979/vim-visual-multi",
  "https://github.com/xero/evangelion.nvim",
}, { confirm = false })

vim.cmd("packadd nvim.undotree")
require("vim._core.ui2").enable()

require("cfg.options")
require("cfg.autocmd")

require("ui.colorscheme")
require("ui.oil")
require("ui.diagnostic")
require("ui.statuscol")
require("ui.fzflua")
require("ui.grugfar")
require("ui.gitsigns")
require("ui.wichkey")

-- require("core.treesitter")
require("core.arborist")
require("core.autotag")
require("core.autopairs")
require("core.blink")
require("core.conform")

require("lsp.mason")
require("lsp.lsp")
