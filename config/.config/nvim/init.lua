vim.loader.enable() -- Lua bytecode cache for faster startup

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    target = "cmd",
    pager = { height = 0.5 },
    dialog = { height = 0.5 },
    cmd = { height = 0.5 },
    msg = { height = 0.5, timeout = 4500 },
  },
})

require("options")
require("commands")
require("keymaps")
require("pack")
require("lsp")
