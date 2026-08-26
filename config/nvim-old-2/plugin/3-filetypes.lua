-- https://github.com/gennaro-tedesco/dotfiles/blob/28be096a90a7c1fbadde62bdac3fd2a78492fcde/nvim/lua/filetype.lua#L7
vim.filetype.add({
  extension = {
    mdx = "markdown",
    conf = "config",
    ejs = "html",
  },
  filename = {
    [".env"] = "config",
    ["config"] = "config",
  },
  pattern = {
    ["gitconf.*"] = "gitconfig",
  },
})
