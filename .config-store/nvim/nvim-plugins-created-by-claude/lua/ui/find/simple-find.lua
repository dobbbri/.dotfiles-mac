if vim.g.loaded_simple_ff then
  return
end
vim.g.loaded_simple_ff = true

-- Auto-register the :FF command with default config.
-- Users who want custom config should call require('simple-ff').setup({...})
-- in their own config instead of relying on this default.
require("simple-ff").setup({})
