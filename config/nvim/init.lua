vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------
local opt = vim.opt;

opt.hlsearch = false
opt.expandtab = true
opt.shiftwidth = 2
--opt.autocomplete = true

opt.pumheight = 10
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.ignorecase = true
opt.smartcase = true
opt.winborder = 'rounded'
opt.cursorline = true

opt.fillchars = { fold = " " }
opt.foldmethod = "indent"
opt.foldenable = false
opt.foldlevel = 99

--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------
-- Enable diagnostics
vim.diagnostic.config({
  virtual_text = true,       -- Show inline diagnostics
  signs = true,              -- Show signs in the gutter
  underline = true,          -- Underline errors
  update_in_insert = true,   -- Don't update diagnostics in insert mode
  severity_sort = true,      -- Sort diagnostics by severity
})

opt.cmdheight = 0
opt.shortmess:append { I = true, c = false, F = false }
shell = "/bin/zsh"


vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {})


--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------
vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/lewis6991/gitsigns.nvim",
}, { confirm = false })


--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------
require("simpletree").setup({
  close_on_open = true,
  icons = {
    folder_closed     = "",
    folder_open       = "",
    folder_empty      = "",
    folder_empty_open = "",
  },
})

 
--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------
require('bufferline-simple')

-- navigate buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { silent = true })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { silent = true })

-- close current buffer
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { silent = true })

-- jump to buffer N by number, e.g. <leader>1, <leader>2, ...
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    local bufs = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_is_loaded(b) and vim.fn.buflisted(b) == 1
    end, vim.api.nvim_list_bufs())
    if bufs[i] then vim.api.nvim_set_current_buf(bufs[i]) end
  end, { silent = true })
end


--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------
require("simple-ff").setup({
  width = 0.6,        -- fraction of editor width
  height = 0.6,        -- fraction of editor height
  max_results = 200,   -- cap on displayed matches
  ignore_dirs = { ".git", "node_modules", ".venv", "__pycache__", "target", "dist", "build" },
})


--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------
require("statusline")
