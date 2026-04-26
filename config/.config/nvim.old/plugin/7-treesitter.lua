vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main", data = {
    run = function() vim.cmd("TSUpdate") end,
  } },
  "https://github.com/windwp/nvim-ts-autotag",
  -- "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  -- "https://github.com/gaelph/logsitter.nvim",
}, { confirm = false })

local filetypes = {
  "astro",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "scss",
  "json",
  "vue",
  "c",
  "lua",
  "php",
  "python",
  "rust",
  "bash",
  "markdown_inline",
  "markdown",
  }

require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

require("nvim-treesitter").install(filetypes)

-- Indentation
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

-- Folds
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldmethod = "expr"

-- Highlighting
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "<filetype>" },
  callback = function() vim.treesitter.start() end,
})

require("nvim-ts-autotag").setup()

-- require("render-markdown").setup({ latex = { enabled = false } })

-- local logss = require("logsitter")
-- logss.setup({ path_format = "fileonly", prefix = "[Log]->", separator = "->" })
-- vim.keymap.set("n", "<leader>l", function() logss.log() end, { desc = "Logsitter: log current" })
