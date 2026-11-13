-- Troca o vim.notify padrão (que só usa :messages/echo) por toasts no
-- canto da tela. Pega mensagens de LSP, erros de plugin, e qualquer
-- vim.notify(...) que você mesmo chamar.
return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  opts = {
    timeout = 3000,
    render = "compact",
    stages = "fade_in_slide_out",
  },
  config = function(_, opts)
    require("notify").setup(opts)
    vim.notify = require("notify")
  end,
}
