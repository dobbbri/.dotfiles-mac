require("nvim-treesitter.config").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
  ensure_installed = { "astro", "javascript", "typescript", "tsx", "html", "css", "json", "lua", "toml" },
  sync_install = false,
  indent = { enable = true },
  autotag = { enable = true },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
})
