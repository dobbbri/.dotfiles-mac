-------------------------------------------------------
-- DIAGNÓSTICO (aparência + comportamento) — nativo, sem plugin
-------------------------------------------------------
local icons = require("config.icons")

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.error,
      [vim.diagnostic.severity.WARN] = icons.warn,
      [vim.diagnostic.severity.INFO] = icons.info,
      [vim.diagnostic.severity.HINT] = icons.hint,
    },
  },
  virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
  float = { border = "rounded", source = true },
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
})
