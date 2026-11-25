-- Busca: só carrega no primeiro <leader>f*.
local ignore_files = require("config.ignore")

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Buscar arquivos" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Buscar texto no projeto (grep)" },
    { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buscar entre buffers abertos" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Buscar na ajuda" },
    { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Arquivos recentes" },
    { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Buscar diagnósticos (erros/avisos)" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({ defaults = { file_ignore_patterns = ignore_files } })
    pcall(telescope.load_extension, "fzf")
  end,
}
