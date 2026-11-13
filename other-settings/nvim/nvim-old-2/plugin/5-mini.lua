vim.pack.add({
  "https://github.com/echasnovski/mini.nvim",
}, { confirm = false })

require("mini.diff").setup({
  config = { view = { style = vim.go.number and "number" } },
})

require("mini.move").setup({
  mappings = { left = "H", right = "L", down = "J", up = "K" },
})

require("mini.pairs").setup()
require("mini.icons").setup()
require("mini.trailspace").setup()
require('mini.cmdline').setup()
-- require("mini.git").setup()

-- require("mini.notify").setup({
--   lsp_progress = { enable = false },
-- --   window = { config = utils.window_notify_config() },
-- })

local files = require("mini.files")

local ignore_files = {
  ".DS_Store",
  ".git",
  ".astro",
  ".vscode",
  ".gitignore",
  -- "dist",
  "lazy-lock.json",
  "package-lock.json",
  "node_modules",
  "pnpm-lock.yaml",
}

files.setup({
  content = { filter = function(entry) return not vim.tbl_contains(ignore_files, entry.name) end },
  mappings = { close = "q", go_in_plus = "<CR>", go_out_plus = "<left>" },
})
vim.keymap.set("n", "-", function() files.open() end, { desc = "Show File Manager" })
vim.keymap.set("n", "<leader>e", function() files.open() end, { desc = "Show File Manager" })

local pick = require("mini.pick")

local window_config = function()
  local height = 16 -- math.floor(0.618 * vim.o.lines)
  local width = math.floor(0.618 * vim.o.columns)
  local row = 1 -- math.floor(0.5 * (vim.o.lines - height))
  local col = math.floor(0.5 * (vim.o.columns - width))
  return { anchor = "NW", height = height, width = width, row = row, col = col }
end

pick.setup({
  options = { use_cache = true },
  window = { config = window_config() },
})

vim.ui.select = pick.ui_select

-- vim.keymap.set("n", "-", "<cmd>Pick files<CR>", { desc = "List files" })
vim.keymap.set("n", "<leader>f", "<cmd>Pick files<CR>", { desc = "List files" })
vim.keymap.set("n", "<leader>m", "<cmd>Pick resume<CR>", { desc = "List Pick resume" })
vim.keymap.set("n", "<leader>w", "<cmd>Pick grep_live<CR>", { desc = "Search by word" })
vim.keymap.set("n", "<leader><space>", "<cmd>Pick buffers<CR>", { desc = "List opened buffers" })

