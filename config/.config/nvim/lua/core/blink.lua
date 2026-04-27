local cmp = require("blink.cmp")

cmp.build():wait(60000)
cmp.setup({
  fuzzy = {
    implementation = "rust",
  },
  signature = {
    enabled = true,
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  completion = {
    documentation = {
      auto_show = true,
      window = { border = "single" },
    },
    menu = { auto_show = true },
    list = { selection = {
      preselect = true,
      auto_insert = false,
    } },
  },
  keymap = {
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
})
