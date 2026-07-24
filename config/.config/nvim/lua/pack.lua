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
  -- colorschemes
  "https://github.com/ryovoid/dracula-night",
  "https://codeberg.org/brargenzilian/darcula-solid.nvim",
  "https://github.com/xero/evangelion.nvim",
}, { confirm = false })

--- colorschemes ---
vim.cmd.colorscheme("dracula-night")
-- vim.cmd.colorscheme("darcula-solid")
-- vim.cmd.colorscheme("evangelion")
-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme retrobox") -- gruvbox clone
-- vim.cmd("colorscheme unokai") -- monokai clone

--- treesitter ---
local parses = { "bash", "http", "astro", "javascript", "typescript", "tsx", "json", "lua" }
require("nvim-treesitter").install(parses)

--- mini files ---
local ignore_files = { ".DS_Store", ".git", ".astro", "dist", "package-lock.json", "node_modules" }

local MiniFiles = require("mini.files")
MiniFiles.setup({
  content = { filter = function(entry) return not vim.tbl_contains(ignore_files, entry.name) end },
  mappings = {
    close = "<ESC>",
    go_in = "<CR>",
    go_in_plus = "<right>",
    go_out = "-",
    go_out_plus = "<left>",
  },
})
vim.keymap.set("n", "-", function() MiniFiles.open() end, { desc = "Show File Manager" })
vim.keymap.set("n", "<leader>e", function() MiniFiles.open() end, { desc = "Show File Manager" })

---- mini icons ----
local miniIcons = require("mini.icons")
miniIcons.setup()
miniIcons.mock_nvim_web_devicons()
vim.g.miniIcons = miniIcons

--- mini pairs ---
require("mini.pairs").setup()
require("mini.indentscope").setup()

--- mini picker ---
local MiniPick = require("mini.pick")
MiniPick.setup()

vim.keymap.set("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Show File Picker" })
vim.keymap.set(
  "n",
  -- "https://github.com/folke/which-key.nvim",
  "<leader>pg",
  function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
  { desc = "Grep word/Search word" }
)
vim.keymap.set("n", "<leader><space>", function() MiniPick.builtin.buffers() end, { desc = "Show opened buffer" })
vim.keymap.set("n", "<leader>ph", function() MiniPick.builtin.help() end, { desc = "Show Help" })
vim.keymap.set("n", "<leader>pm", "<cmd>Pick resume<CR>", { desc = "Show Pick resume" })

--- mini completions ---
require("mini.completion").setup({
  lsp_completion = {
    auto_setup = true,
  },
})

--- mini cmdline completion ---
require("mini.cmdline").setup({
  autocorrect = { enable = false },
})

--- mini snippets ---
local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
  snippets = {
    MiniSnippets.gen_loader.from_lang(), -- loads friendly-snippets
  },
})
MiniSnippets.start_lsp_server({ match = false })

--- mini clue ---
require("mini.clue").setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
  },
  clues = {
    { mode = "n", keys = "<Leader>d", desc = "+Diagnostics" },
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    { mode = "n", keys = "<Leader>p", desc = "+Pickers" },
    { mode = "n", keys = "<Leader>r", desc = "+Search/Replace" },
    { mode = "n", keys = "<Leader>x", desc = "+Close Buffer" },
  },
})

--- mini notify ---
require("mini.notify").setup({
  content = {
    format = function(notif) return notif.msg end,
  },
  window = {
    config = function()
      return {
        title = "",
        -- anchor = "SE",
        row = vim.o.lines - 2,
        col = vim.o.columns,
        border = "none",
      }
    end,
  },
})

-- gitsigns ---
local _signs = {
  add = { text = "▎" },
  change = { text = "▎" },
  delete = { text = "" },
  topdelete = { text = "" },
  changedelete = { text = "▎" },
  untracked = { text = "▎" },
}

require("gitsigns").setup({
  signs = _signs,
  signs_staged = _signs,
})

vim.keymap.set("n", "<leader>gg", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive Full Page New Tab" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff split" })
vim.keymap.set({ "n", "v" }, "<leader>gS", ":Gitsigns stage_hunk<CR>", { desc = "Git Stage Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>gs", ":Gitsigns stage_buffer<CR>", { desc = "Git Stage Buffer" })
vim.keymap.set({ "n", "v" }, "<leader>gR", ":Gitsigns reset_hunk<CR>", { desc = "Git Reset Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>gr", ":Gitsigns reset_buffer<CR>", { desc = "Git Reset Buffer" })

--- grug-far ---
local GrugFar = require("grug-far")
GrugFar.setup({
  showCompactInputs = true,
})

vim.keymap.set("n", "<leader>rp", function() GrugFar.open({ transient = true }) end, { desc = "Replace in project" })
vim.keymap.set(
  "n",
  "<leader>rb",
  function() GrugFar.open({ prefills = { paths = vim.fn.expand(" % ") } }) end,
  { desc = "Replace in buffer" }
)

--- colorizer ---
require("colorizer").setup({
  options = {
    parsers = {
      tailwind = { enable = true, lsp = true },
      names = { enable = true },
    },
  },
})

--- conform ---
require("conform").setup({
  formatters_by_ft = {
    sh = { "shfmt" },
    lua = { "stylua" },
    toml = { "taplo" },
    yaml = { "yamlfmt" },
    astro = { "biome" },
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    css = { "biome" },
    html = { "biome" },
    json = { "biome" },
    jsonc = { "biome" },
    markdown = { "biome" },
  },
  default_format_opts = { lsp_fallback = true, async = false, timeout_ms = 500 },
  format_on_save = { lsp_format = "fallback" },
})

--- native undotree ---
vim.keymap.set("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Show Undotree" })
