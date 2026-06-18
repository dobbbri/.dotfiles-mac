vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/owallb/mason-auto-install.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/MagicDuck/grug-far.nvim",
  "https://github.com/mg979/vim-visual-multi",
  "https://github.com/catgoose/nvim-colorizer.lua",
  "https://github.com/SantosAlarcon/fancyline.nvim",
  "https://github.com/xero/evangelion.nvim",
}, { confirm = false })

--- colorscheme ---
require("evangelion").setup({
 transparent = false,
 overrides = {
   Directory = { bg = "NONE" },
   Comment = { fg = "#6D8086", bg = "NONE" },
   StatusLine = { fg = "#B968FC", bg = "#39274D", bold = true },
   StatusLineNC = { fg = "#666666", bg = "#39274D", bold = true },
 },
})
vim.cmd.colorscheme("evangelion")

-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme retrobox") -- gruvbox clone
-- vim.cmd("colorscheme unokai") -- monokai clone

-- mini files ----
local MiniFiles = require("mini.files")
MiniFiles.setup({
  mappings = {
    go_in = "<CR>",
    go_out = "-",
  },
})

vim.keymap.set("n", "-", "<cmd>lua MiniFiles.open()<CR>", { desc = "Toggle mini file explorer" })
vim.keymap.set("n", "<leader>-", function()
  MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
  MiniFiles.reveal_cwd()
end, { desc = "Toggle into currently opened file" })

---- mini notify ----
require("mini.notify").setup({
  content = { -- only show messages
    format = function(notif)
      return notif.msg
    end,
  },
})

--- mini pairs ---
require('mini.pairs').setup()
require('mini.indentscope').setup()

--- mini cmdline completion ---
require("mini.cmdline").setup({
  autocorrect = { enable = false }
})

local imap_expr = function(lhs, rhs)
  vim.keymap.set('i', lhs, rhs, { expr = true })
end
imap_expr('<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr('<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

--- mini picker ---
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
MiniPick.setup()
MiniExtra.setup()

-- keymaps
vim.keymap.set("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Mini File Picker" })
vim.keymap.set("n", "<leader>ps", function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
  { desc = "Grep word/Search word" })
vim.keymap.set("n", "<leader>vh", function() MiniPick.builtin.help() end, { desc = "Mini Help" })

vim.keymap.set("n", "<leader>xx", function() MiniExtra.pickers.diagnostic() end, { desc = "Mini Picker Diagnostics" })
vim.keymap.set("n", "<leader>pk", function() MiniExtra.pickers.keymaps() end, { desc = 'Search keymaps' })

--- mini completions ---
require("mini.completion").setup({
  lsp_completion = {
    auto_setup = true,
  }
})

--- mini snippets ---
local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
  snippets = {
    MiniSnippets.gen_loader.from_lang(), -- loads friendly-snippets
  },
})
MiniSnippets.start_lsp_server({ match = false })

--- mini diff and fugitive ---
local MiniDiff = require("mini.diff")
MiniDiff.setup({
  source = MiniDiff.gen_source.git({ index = false }),
})

vim.keymap.set("n", "<leader>gg", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive Full Page New Tab" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff split", })

--- fancyline ---
require("fancyline").setup({
  preset = "vscode",
  sections = {
    left = { "mode", "file", "git_branch", "git_diff" },
    right = { "diagnostics", "filetype", "lsp", "position" },
  },
})

--- grug-far ---
local GrugFar = require("grug-far")
GrugFar.setup({
  showCompactInputs = true,
})

vim.keymap.set("n", "<leader>rp", function() GrugFar.open({ transient = true }) end, { desc = "Replace in project" })
vim.keymap.set("n", "<leader>rb", function() GrugFar.open({ prefills = { paths = vim.fn.expand(" % ") } }) end,
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
