-- Interface "sempre visível": VeryLazy = carrega logo depois da UI inicial
-- aparecer, não durante o boot (não bloqueia o primeiro frame).
local icons = require("config.icons")

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "catppuccin-mocha", globalstatus = true },
      extensions = { "nvim-tree", "trouble", "lazy" },
    },
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        -- mesmos ícones do vim.diagnostic.config (config/diagnostics.lua),
        -- pra não ter um glifo diferente na aba vs. na gutter/float.
        diagnostics_indicator = function(count, level)
          local icon = (level == "error") and icons.error or icons.warn
          return icon .. count
        end,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({})
      wk.add({
        { "<leader>f", group = "buscar" },
        { "<leader>s", group = "search & replace" },
        { "<leader>c", group = "código" },
        { "<leader>x", group = "diagnósticos" },
        { "<leader>h", group = "git hunks" },
        { "<leader>d", group = "debug" },
      })
    end,
  },
}
