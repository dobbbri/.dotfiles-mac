-- Árvore de arquivos: só carrega no primeiro <leader>e / "-".
-- "keys" já registra o mapeamento E serve de gatilho de carregamento.
local ignore_files = require("config.ignore")

return {
  "nvim-tree/nvim-tree.lua",
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Abrir/fechar árvore de arquivos" },
    { "-", "<cmd>NvimTreeToggle<CR>", desc = "Abrir/fechar árvore de arquivos" },
  },
  opts = {
    view = { width = 32 },
    renderer = { group_empty = true, highlight_git = "all" },
    filters = { dotfiles = false, custom = ignore_files },
    git = { ignore = false },
    actions = { open_file = { quit_on_open = true } },
  },
}
