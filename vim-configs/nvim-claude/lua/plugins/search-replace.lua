-- Search & replace em massa no projeto: só carrega no primeiro <leader>s*.
local ignore_files = require("config.ignore")

return {
  "MagicDuck/grug-far.nvim",
  keys = {
    { "<leader>sr", function() require("grug-far").open() end, desc = "Search & Replace (grug-far)" },
    {
      "<leader>sw",
      function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
      desc = "Substituir palavra sob o cursor",
    },
  },
  config = function()
    local rg_glob_excludes = {}
    for _, name in ipairs(ignore_files) do
      table.insert(rg_glob_excludes, string.format("--glob '!%s'", name))
    end
    require("grug-far").setup({
      engines = { ripgrep = { extraArgs = table.concat(rg_glob_excludes, " ") } },
    })
  end,
}
