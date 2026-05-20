require("evangelion").setup({
  transparent = false,
  overrides = {
    Directory = { bg = "NONE" },
    Comment = { fg = "#6D8086", bg = "NONE" },
    StatusLine = { fg = "#B968FC", bg = "#39274D", bold = true },
    StatusLineNC = { fg = "#666666", bg = "#39274D", bold = true },
  },
})
vim.cmd.colorscheme("evangelion")

-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme retrobox")
-- vim.cmd("colorscheme unokai")
