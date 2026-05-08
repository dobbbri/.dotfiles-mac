vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 3,
  },
  float = {
    source = "if_many",
    focusable = true,
    style = "minimal",
  },
  severity_sort = true,
  update_in_insert = false,
  jump = { float = true },
})
