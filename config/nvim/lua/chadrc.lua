-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.mason = {
  pkgs = { "stylua", "shellcheck", "shfmt", "prettier", "taplo", "yamlfmt" },
}

M.ui = {
  statusline = { theme = "minimal" },
  tabufline = { treeOffsetFt = "NvimTree" },
}

return M
