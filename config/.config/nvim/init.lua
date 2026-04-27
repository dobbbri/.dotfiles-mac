-- ▄█▀▀▄ ▄█▀█ ▄█▀▀▄ ▄█ █ ▄█ ▄█▄ ▄█
-- ▓█  █ ▓█▄  ▓█  █ ▓█ █ ▓█ ▓█ ▀ █
-- ▓█  █ ▓█ ▄ ▓█  █ ▓█ █ ▓█ ▓█   █
-- ▓█  █ ▓█▄█ ▀█▄▄▀ ▀█▄▀ ▓█ ▓█   █

vim.g.mapleader = " " -- Set space as the leader key for custom mappings
vim.g.maplocalleader = " " -- Set space as the local leader key for buffer-local mappings

require("cfg.options")
require("vim._core.ui2").enable()
require("cfg.autocmd")

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
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/MagicDuck/grug-far.nvim",
  "https://github.com/3rd/image.nvim",
  "https://github.com/luukvbaal/statuscol.nvim",
  "https://github.com/mg979/vim-visual-multi",
	"https://github.com/xero/evangelion.nvim",
}, { confirm = false })

vim.cmd.colorscheme("evangelion")
-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme retrobox")
-- vim.cmd("colorscheme unokai")

require("ui.oil")
require("ui.diagnostic")
require("ui.statuscol")

require("core.blink")

require("lsp.mason")
require("lsp.lsp")


-- =============================================================================

-- =============================================================================
require("fzf-lua").setup({
  winopts = { split = "belowright new" },
})

-- =============================================================================
require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "│" },
    topdelete = { text = "│" },
    changedelete = { text = "│" },
    untracked = { text = "┆" },
  },
})

-- =============================================================================
require("nvim-treesitter.config").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
  ensure_installed = { "astro", "javascript", "typescript", "tsx", "html", "css", "json", "lua", "toml" },
  sync_install = false,
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },
  autotag = { enable = true },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "<filetype>" },
  callback = function() vim.treesitter.start() end,
})

-- ===========================================================================
--
require("nvim-ts-autotag").setup({})

-- ===========================================================================
require("nvim-autopairs").setup({
  check_ts = true,
  fast_wrap = {},
})

-- ===========================================================================
require("grug-far").setup({
  headerMaxWidth = 80,
  showCompactInputs = true,
})

-- =============================================================================
require("image").setup({
  backend = "sixel",
})

-- =============================================================================
local wk = require("which-key")
wk.setup()

wk.add({
  { "-", "<CMD>Oil<CR>", desc = "Edit Files (Oil)" },

  { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
  { "gr", vim.lsp.buf.references, desc = "Show References" },
  { "K", vim.lsp.buf.hover, desc = "Hover Docs" },

  { "<leader>d", group = "Diagnostics" },
  { "<leader>dl", vim.diagnostic.setloclist, desc = "List Diagnostics" },
  { "<leader>df", vim.diagnostic.open_float, desc = "Float Error" },

  { "<leader>c", group = "Code" },
  { "<leader>cf", "<CMD>Format<CR>", desc = "Format File" },
  { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Symbol" },

  { "<leader>f", group = "Find" }, -- Grouping for your fzf-lua
  { "<leader>ff", "<CMD>FzfLua files<CR>", desc = "Find Files" },
  { "<leader>fg", "<CMD>FzfLua live_grep<CR>", desc = "Grep Text" },
  { "<leader><space>", "<CMD>FzfLua buffers<CR>", desc = "Opened Buffers" },

  { "<leader>g", group = "Git" },
  { "<leader>gs", "<CMD>Gitsigns stage_hunk<CR>", desc = "Stage Hunk" },
  { "<leader>gr", "<CMD>Gitsigns reset_hunk<CR>", desc = "Reset Hunk" },
  { "<leader>gp", "<CMD>Gitsigns preview_hunk<CR>", desc = "Preview Hunk" },
  { "<leader>gb", "<CMD>Gitsigns blame_line --full'<CR>", desc = "Blame Line" },

  { "<leader>r", group = "Replace" },
  { "<leader>ra", "<CMD>GrugFar<CR>", desc = "Replace in projec", mode = { "n", "v" } },
  { "<leader>rr", ":%s///gcI<Left><Left><Left><Left><Left>", desc = "replace in current buffer" },

  { "<leader>?", "<CMD>WhichKey<CR>", desc = "Show all keymaps" },

  { "<leader>x", "<CMD>bd<CR>", desc = "Close current buffer" },
  { "<leader>X", "<CMD>%bd<CR>", desc = "Close all buffers" },

  { "<leader>q", "<CMD>q<CR>", desc = "Quit" },
  { "<leader>Q", "<CMD>qa<CR>", desc = "Quit All" },

  { "<Esc>", "<CMD>nohlsearch<CR>", desc = "Clear Highlight", silent = true },

  { "<C-h>", "<C-w>h", desc = "Go Left" },
  { "<C-j>", "<C-w>j", desc = "Go Down" },
  { "<C-k>", "<C-w>k", desc = "Go Up" },
  { "<C-l>", "<C-w>l", desc = "Go Right" },

  { "<C-Up>", "<CMD>resize +2<CR>", desc = "Increase Height" },
  { "<C-Down>", "<CMD>resize -2<CR>", desc = "Decrease Height" },
  { "<C-Left>", "<CMD>vertical resize -2<CR>", desc = "Decrease Width" },
  { "<C-Right>", "<CMD>vertical resize +2<CR>", desc = "Increase Width" },

  { "J", ":m '>+1<CR>gv=gv", desc = "Move Lines Down", mode = "v" },
  { "K", ":m '<-2<CR>gv=gv", desc = "Move Lines Up", mode = "v" },
  { "k", "v:count == 0 ? 'gk' : 'k'", expr = true, desc = "Up (wrapped)" },
  { "j", "v:count == 0 ? 'gj' : 'j'", expr = true, desc = "Down (wrapped)" },

  { "H", "^", desc = "Start of Line", mode = { "n", "x", "o" } },
  { "L", "g_", desc = "End of Line", mode = { "n", "x", "o" } },

  { "<Tab>", "<CMD>bprevious<CR>", desc = "Prev Buffer" },
  { "<S-Tab>", "<CMD>bnext<CR>", desc = "Next Buffer" },

  { "YY", "va{Vy", desc = "Yank Block {}" },
  { "<C-a>", "ggVG", desc = "Select All" },

  { "<", "<gv", desc = "Indent Left", mode = "v" },
  { ">", ">gv", desc = "Indent Right", mode = "v" },

  { "p", '"_dP', desc = "Paste (no yank)", mode = "v" },

  { "<Esc><Esc>", "<C-\\><C-n>", desc = "Exit Terminal Mode", mode = "t" },
  { "<C-h>", "<CMD>wincmd h<CR>", desc = "Go Left", mode = "t" },
  { "<C-j>", "<CMD>wincmd j<CR>", desc = "Go Down", mode = "t" },
  { "<C-k>", "<CMD>wincmd k<CR>", desc = "Go Up", mode = "t" },
  { "<C-l>", "<CMD>wincmd l<CR>", desc = "Go Right", mode = "t" },
})

