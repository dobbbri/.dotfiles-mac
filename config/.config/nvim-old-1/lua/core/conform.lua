require("conform").setup({
  formatters_by_ft = {
    sh = { "shfmt" },
    toml = { "taplo" },
    yaml = { "yamlfmt" },
    yml = { "yamlfmt" },
    markdown = { "prettier" },
  },
  default_format_opts = { lsp_fallback = true, async = false, timeout_ms = 500 },
  format_on_save = { lsp_format = "fallback" },
})
