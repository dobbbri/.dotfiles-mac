-- ▄█▀▀▄ ▄█▀█ ▄█▀▀▄ ▄█  █ ▄█ ▄█▄ ▄█ --
-- ▓█  █ ▓█▄  ▓█  █ ▓█  █ ▓█ ▓█ ▀ █ --
-- ▓█  █ ▓█ ▄ ▓█  █ ▓█  █ ▓█ ▓█   █ --
-- ▓█  █ ▓█▄█ ▓█▄▄▀ ▓█▄▀  ▓█ ▓█   █ --

vim.g.mapleader = " "      -- Set space as the leader key for custom mappings
vim.g.maplocalleader = " " -- Set space as the local leader key for buffer-local mappings

require('vim._core.ui2').enable({
  enable = true,
  msg = {
    target = "cmd",
    pager  = { height = 0.5 },
    dialog = { height = 0.5 },
    cmd    = { height = 0.5 },
    msg    = { height = 0.5, timeout = 4500 },
  },
})

vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/owallb/mason-auto-install.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/arborist-ts/arborist.nvim",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/MagicDuck/grug-far.nvim",
  "https://github.com/3rd/image.nvim",
  "https://github.com/luukvbaal/statuscol.nvim",
  "https://github.com/mg979/vim-visual-multi",
  "https://github.com/SantosAlarcon/fancyline.nvim",
  "https://github.com/xero/evangelion.nvim",
  "https://github.com/brenoprata10/nvim-highlight-colors"
}, { confirm = false })


-- :undotree
-- vim.cmd("packadd nvim.difftool")
-- :difftool

require("cfg.options")
require("cfg.autocmd")

require("nvim-highlight-colors").setup({ "*" })

require("ui.colorscheme")
require("ui.oil")
require("ui.fancyline")
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
-- require("core.blink")
require("core.conform")

require("lsp.mason")
require("lsp.lsp")
