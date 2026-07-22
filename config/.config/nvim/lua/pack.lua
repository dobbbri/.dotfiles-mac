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
  "https://github.com/folke/which-key.nvim",
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
require("nvim-treesitter").install({
  "bash",
  "http",
  "astro",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "json",
  "lua",
  "toml",
})

--- mini files ---
local MiniFiles = require("mini.files")
MiniFiles.setup({
  mappings = {
    close = "<ESC>",
    go_in = "<CR>",
    go_in_plus = "<CR>",
    go_out = "-",
  },
})

vim.keymap.set("n", "-", "<cmd>lua MiniFiles.open()<CR>", { desc = "Toggle mini file explorer" })
vim.keymap.set("n", "<leader>-", function()
  MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
  MiniFiles.reveal_cwd()
end, { desc = "Toggle into currently opened file" })

---- mini icons ----
local miniIcons = require("mini.icons")
miniIcons.setup()
miniIcons.mock_nvim_web_devicons()
vim.g.miniIcons = miniIcons

--- mini pairs ---
require("mini.pairs").setup()
require("mini.indentscope").setup()

local imap_expr = function(lhs, rhs) vim.keymap.set("i", lhs, rhs, { expr = true }) end
imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

--- mini picker ---
local MiniPick = require("mini.pick")
MiniPick.setup()

vim.keymap.set("n", "<leader>f", function() MiniPick.builtin.files() end, { desc = "Mini File Picker" })
vim.keymap.set(
  "n",
  "<leader>F",
  function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
  { desc = "Grep word/Search word" }
)
vim.keymap.set("n", "<leader>h", function() MiniPick.builtin.help() end, { desc = "Mini Help" })

--- mini extra ---
local MiniExtra = require("mini.extra")
MiniExtra.setup()

vim.keymap.set("n", "<leader>x", function() MiniExtra.pickers.diagnostic() end, { desc = "Mini Picker Diagnostics" })
vim.keymap.set("n", "<leader>k", function() MiniExtra.pickers.keymaps() end, { desc = "Search keymaps" })

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

--- mini notify ---
require("mini.notify").setup({
  content = {
    format = function(notif) return notif.msg end,
  },
  window = {
    config = function()
      return {
        title = "",
        anchor = "SE",
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

vim.keymap.set("n", "<leader>p", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive Full Page New Tab" })
vim.keymap.set("n", "<leader>P", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff split" })
vim.keymap.set({ "n", "v" }, "<leader>S", ":Gitsigns stage_hunk<CR>", { desc = "Git Stage Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>s", ":Gitsigns stage_buffer<CR>", { desc = "Git Stage Buffer" })
vim.keymap.set({ "n", "v" }, "<leader>T", ":Gitsigns reset_hunk<CR>", { desc = "Git Reset Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>t", ":Gitsigns reset_buffer<CR>", { desc = "Git Reset Buffer" })

--- grug-far ---
local GrugFar = require("grug-far")
GrugFar.setup({
  showCompactInputs = true,
})

vim.keymap.set("n", "<leader>R", function() GrugFar.open({ transient = true }) end, { desc = "Replace in project" })
vim.keymap.set(
  "n",
  "<leader>r",
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

--- which-key ---
-- local whichkey = require("which-key").setup({ preset = "modern" })
--
-- vim.keymap.set(
--   "n",
--   "<leader>?",
--   function() whichkey.show({ global = false }) end,
--   { desc = "Buffer Local Keymaps (which-key)" }
-- )

-- native undotree
vim.keymap.set("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Toggle Builtin Undotree" })
