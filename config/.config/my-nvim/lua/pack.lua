vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/owallb/mason-auto-install.nvim",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/MagicDuck/grug-far.nvim",
  "https://github.com/mg979/vim-visual-multi",
  "https://github.com/catgoose/nvim-colorizer.lua",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/folke/trouble.nvim",
  "https://github.com/dobbbri/statusline.nvim",
  -- colorschemes
  "https://github.com/ryovoid/dracula-night",
  "https://codeberg.org/brargenzilian/darcula-solid.nvim",
  "https://github.com/xero/evangelion.nvim",
}, { confirm = false })

local colorschemes = { 
  "dracula-night", 
  "darcula-solid", 
  "evangelion" 
}
vim.cmd.colorscheme(colorschemes[2])

require("plugins.treesitter")
require("plugins.lsp")
require("plugins.mini")
require("plugins.gitsigns")
require("plugins.grugfar")
require("plugins.colorizer")
require("plugins.conform")
require("plugins.statusline")
require("plugins.undotree")
require("plugins.trouble")

