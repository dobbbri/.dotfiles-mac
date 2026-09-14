-- Treesitter: carrega só quando um buffer de arquivo real abre (pula o
-- custo no scratch buffer inicial vazio do Neovim).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter").install({
        "typescript", "tsx", "javascript", "astro",
        "html", "css", "json", "yaml", "markdown", "markdown_inline",
        "lua", "vim", "vimdoc", "bash", "graphql", "query",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local ft = ev.match
          if ft == "" then return end
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if not pcall(vim.treesitter.language.add, lang) then return end
          if pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "astro", "javascript", "javascriptreact", "typescript", "typescriptreact", "xml" },
    opts = {},
  },
}
