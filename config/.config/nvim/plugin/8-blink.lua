vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/rafamadriz/friendly-snippets",
  -- "https://github.com/OXY2DEV/markview.nvim",
}, { confirm = false })

require("blink.cmp").setup({
  keymap = { preset = "enter" },
  cmdline = { enabled = false },
  completion = {
    trigger = { show_in_snippet = false },
    list = { selection = { preselect = function() return not require("blink.cmp").snippet_active({ direction = 1 }) end } },
    menu = { auto_show = true, border = "none" },
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    ghost_text = { enabled = true },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  signature = { enabled = true },
  fuzzy = {
    implementation = "prefer_rust",
    prebuilt_binaries = { ignore_version_mismatch = true },
  },
})

-- require("markview").setup({
--   preview = {
--     icon_provider = "internal",
--     enable = false,
--   },
-- })
--
-- vim.api.nvim_set_keymap("n", "<leader>m", "<CMD>Markview<CR>", { desc = "Toggles `markview` previews globally." })
