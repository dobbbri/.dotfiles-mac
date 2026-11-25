-- Formatação: BufWritePre é o gatilho recomendado pelo próprio conform pra
-- format-on-save — o lazy.nvim carrega o plugin e refaz o evento, então o
-- primeiro save já formata. <leader>cf também dispara o load.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ lsp_fallback = true }) end,
      mode = { "n", "v" },
      desc = "Formatar código",
    },
  },
  dependencies = { "zapling/mason-conform.nvim" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        sh = { "shfmt" },
        lua = { "stylua" },
        toml = { "taplo" },
        yaml = { "yamlfmt" },
        astro = { "biome" },
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        css = { "biome" },
        html = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        markdown = { "biome" },
      },
      format_on_save = { timeout_ms = 1000, lsp_fallback = true },
    })
    -- precisa rodar DEPOIS do conform.setup() acima, pra saber quais
    -- formatters instalar via mason.
    require("mason-conform").setup()
  end,
}
