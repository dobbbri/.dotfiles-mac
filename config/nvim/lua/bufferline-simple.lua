-- ~/.config/nvim/lua/bufferline-simple.lua (or paste into init.lua)

local M = {}

function M.build_tabline()
  local bufs = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_loaded(b) and vim.fn.buflisted(b) == 1
  end, vim.api.nvim_list_bufs())

  local current = vim.api.nvim_get_current_buf()
  local parts = {}

  for i, b in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(b)
    name = name ~= '' and vim.fn.fnamemodify(name, ':t') or '[No Name]'

    local hl = (b == current) and '%#TabLineSel#' or '%#TabLine#'
    local modified = vim.api.nvim_buf_get_option(b, 'modified') and ' ●' or ''

    parts[#parts + 1] = string.format(
      '%s %d:%s%s %%X',
      hl, i, name, modified
    )
  end

  return table.concat(parts, '') .. '%#TabLineFill#'
end

vim.o.showtabline = 2 -- always show
vim.o.tabline = '%!v:lua.require("bufferline-simple").build_tabline()'

return M
