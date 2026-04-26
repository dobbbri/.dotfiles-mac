-- ============================================================================
vim.g.mapleader = " " -- Set space as the leader key for custom mappings
vim.g.maplocalleader = " " -- Set space as the local leader key for buffer-local mappings

-- Disable Built-in Plugins
vim.g.loaded_netrw = 1 -- Disable netrw file explorer (using a different file explorer)
vim.g.loaded_netrwPlugin = 1 -- Disable netrw plugin component

-- Disable Providers (silence health check warnings)
vim.g.loaded_node_provider = 0 -- Disable Node.js provider
vim.g.loaded_perl_provider = 0 -- Disable Perl provider
vim.g.loaded_python3_provider = 0 -- Disable Python 3 provider
vim.g.loaded_ruby_provider = 0 -- Disable Ruby provider

-- Editor Behavior
vim.opt.mouse = "a" -- Enable mouse support in all modes
vim.opt.clipboard = "unnamedplus" -- Use system clipboard for all yank/paste operations
vim.opt.undofile = true -- Persist undo history to disk between sessions
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Directory to store undo files
vim.opt.updatetime = 100 -- Time in ms before CursorHold event triggers (affects plugins)
vim.opt.timeoutlen = 1000 -- Time in ms to wait for a mapped key sequence to complete
vim.opt.confirm = true -- Prompt for confirmation instead of failing on unsaved changes
vim.opt.autoread = true -- Automatically reload files changed outside of Neovim

-- UI/Display
vim.opt.termguicolors = true -- Enable 24-bit RGB colors in the terminal
vim.opt.number = true -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers (hybrid with number=true)
vim.opt.numberwidth = 2 -- Minimum width of number column
vim.opt.signcolumn = "yes" -- Always show sign column with width of 1
vim.opt.cursorline = true -- Don't highlight the current line
vim.opt.wrap = false -- Don't wrap long lines
vim.opt.breakindent = false -- Wrapped lines preserve indentation
vim.opt.showmode = false -- Don't show mode in command line (shown in statusline)
vim.opt.showcmd = false -- Don't show partial command in command line
vim.opt.ruler = true -- Show cursor position in command line
vim.opt.showtabline = 0 -- Never show the tab line
vim.opt.cmdheight = 1 -- Height of command line area
vim.opt.pumheight = 10 -- Maximum height of popup menu
vim.opt.winborder = "none" -- Use rounded borders for floating windows

-- Search
vim.opt.hlsearch = true -- Highlight all search matches
vim.opt.incsearch = true -- Show search matches as you type
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true -- Override ignorecase if pattern contains uppercase

-- Indentation
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.shiftwidth = 2 -- Number of spaces for each indentation level
vim.opt.smartindent = true -- Auto-indent new lines based on syntax

-- Splits
vim.opt.splitbelow = true -- Open horizontal splits below current window
vim.opt.splitright = true -- Open vertical splits to the right of current window

-- Files
vim.opt.fileencoding = "utf-8" -- File encoding for new files
vim.opt.backup = false -- Don't create backup files before overwriting
vim.opt.writebackup = false -- Don't create backup while editing
vim.opt.swapfile = false -- Don't create swap files

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Completion menu options
vim.opt.conceallevel = 0 -- Show all text normally (no concealment)

-- folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldmethod = "expr"
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.fillchars = {
  foldopen = "󰅀", -- "",
  foldclose = "󰅂", --"󰅂",-- "",--"",
  foldsep = "│",
}

require("vim._core.ui2").enable()

-- =============================================================================
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- =============================================================================
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  float = { focusable = true, style = "minimal" },
})

-- =============================================================================
-- packages
vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/stevearc/conform.nvim",
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
}, { confirm = false })

-- =============================================================================
-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme retrobox")
vim.cmd("colorscheme unokai")

-- =============================================================================
local builtin = require("statuscol.builtin")

require("statuscol").setup({
  relculright = true,
  segments = {
    { text = { builtin.foldfunc, "" }, click = "v:lua.ScFa" },
    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
    { text = { "%s" }, click = "v:lua.ScSa" },
  },
})

-- =============================================================================
require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, _) return name == ".git/" end,
  },
  keymaps = {
    ["<ESC>"] = "actions.close",
    ["q"] = "actions.close",
  },
})

-- =============================================================================
require("blink.cmp").setup({
  fuzzy = {
    implementation = "prefer_rust",
    prebuilt_binaries = { force_version = "v*", download = true },
  },
  signature = { enabled = true },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  completion = {
    documentation = { auto_show = true },
    menu = { auto_show = true },
    list = { selection = { preselect = true, auto_insert = false } },
  },
  keymap = {
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
})

-- =============================================================================
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "astro-language-server",
    "bash-language-server",
    "json-lsp",
    "biome",
    "prettier",
    "shfmt",
    "stylua",
    "taplo",
    "tailwindcss-language-server",
    "lua-language-server",
    "typescript-language-server",
    "yamlfmt",
    "dockerls",
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = { diagnostics = { globals = { "vim" } }, telemetry = { enable = false } },
  },
})
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
vim.lsp.enable({ "astro", "bashls", "jsonls", "lua_ls", "tailwindcss", "ts_ls", "dockerls" })

-- =============================================================================
require("conform").setup({
  formatters_by_ft = {
    sh = { "shfmt" },
    lua = { "stylua" },
    toml = { "taplo" },
    yaml = { "yamlfmt" },
    yml = { "yamlfmt" },
    astro = { "biome" },
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    css = { "biome" },
    html = { "biome" },
    json = { "biome" },
    jsonc = { "biome" },
    markdown = { "prettier" },
    graphql = { "prettier" },
  },
  default_format_opts = { lsp_fallback = true, async = false, timeout_ms = 500 },
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

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
  backend = "kitty",
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

