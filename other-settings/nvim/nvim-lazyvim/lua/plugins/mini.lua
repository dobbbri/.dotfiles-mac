--- mini files ---
local ignore_files = { ".DS_Store", ".git", ".astro", "dist", "package-lock.json", "node_modules" }

local MiniFiles = require("mini.files")
MiniFiles.setup({
  content = { filter = function(entry) return not vim.tbl_contains(ignore_files, entry.name) end },
  mappings = { close = "<ESC>", go_in = "<CR>", go_out = "-", show_help = '?',},
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

--- mini snippets ---
local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
  snippets = {
    MiniSnippets.gen_loader.from_lang(), -- loads friendly-snippets
  },
})
MiniSnippets.start_lsp_server({ match = false })

--- mini cmdline completion ---
require("mini.cmdline").setup({
  autocorrect = { enable = false },
})

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
    { mode = "n", keys = "<Leader>t", desc = "+Tools" },
  },
})

--- mini notify ---
require("mini.notify").setup({
  content = {
    format = function(notif) return notif.msg end,
  },
})
