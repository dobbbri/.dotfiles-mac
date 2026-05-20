vim.pack.add({
  "https://github.com/kevinhwang91/nvim-ufo",
  "https://github.com/kevinhwang91/promise-async",
  "https://github.com/luukvbaal/statuscol.nvim",
}, { confirm = false })

local builtin = require("statuscol.builtin")

require("statuscol").setup({
  relculright = true,
  segments = {
    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
    { text = { "%s" }, click = "v:lua.ScSa" },
    { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
  },
})

local ufo = require("ufo")

ufo.setup({
  provider_selector = function() return { "treesitter", "indent" } end,
})

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "<leader>z", ufo.openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "<leader>Z", ufo.closeAllFolds, { desc = "Close all folds" })
