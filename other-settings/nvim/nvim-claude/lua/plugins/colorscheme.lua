-- Tema + ícones: carregam eager (sem event/cmd/keys/ft) — precisam estar
-- prontos antes de qualquer outra UI desenhar.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha", transparent_background = false })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  -- custo irrisório, e várias coisas VeryLazy/lazy dependem dele — mais
  -- simples deixar sempre disponível.
  { "nvim-tree/nvim-web-devicons", opts = {} },
}
