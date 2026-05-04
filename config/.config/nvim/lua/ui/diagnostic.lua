vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
  },
  float = {
    source = "if_many", -- nicer look for floats and show source if multiple sources (ex. ruff and ty)
    focusable = true,
    style = "minimal",
  },
  severity_sort = true,
  update_in_insert = false,
  jump = { float = true }, -- automatically open the diagnostic float if you jump with [d ]d
})
