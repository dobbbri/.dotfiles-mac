vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
}, { confirm = false })

require("mason").setup()

local mr = require("mason-registry")
mr.refresh(function()
  local ensure_installed = {
    "astro-language-server",
    "bash-language-server",
    "json-lsp",
    "biome", --"prettier",
    "shfmt",
    "stylua",
    "taplo",
    "tailwindcss-language-server",
    "lua-language-server",
    "typescript-language-server",
    "yamlfmt",
  }

  for _, tool in ipairs(ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end)
