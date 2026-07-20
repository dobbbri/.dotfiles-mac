vim.api.nvim_set_hl(0, "StModeNormal", { bg = "NONE", fg = "#83c092", bold = true })
vim.api.nvim_set_hl(0, "StModeInsert", { bg = "NONE", fg = "#F7F1DE", bold = true })
vim.api.nvim_set_hl(0, "StModeVisual", { bg = "NONE", fg = "#d699b6", bold = true })
vim.api.nvim_set_hl(0, "StModeOther", { bg = "NONE", fg = "#e67e80", bold = true })
vim.api.nvim_set_hl(0, "StGitBranch", { fg = "#F7F1DE", bg = "NONE" })
vim.api.nvim_set_hl(0, "FileName", { fg = "#FFFFFF", bg = "NONE" })
vim.api.nvim_set_hl(0, "StGitAdd", { fg = "#a7c080", bg = "NONE" })
vim.api.nvim_set_hl(0, "StGitChange", { fg = "#dbbc7f", bg = "NONE" })
vim.api.nvim_set_hl(0, "StGitDelete", { fg = "#e67e80", bg = "NONE" })
vim.api.nvim_set_hl(0, "FileModifiedIcon", { fg = "#8DC07C", bg = "NONE" })
vim.api.nvim_set_hl(0, "ErrorHl", { fg = "#e67e80", bg = "NONE" })
vim.api.nvim_set_hl(0, "WarningHl", { fg = "#dbbc7f", bg = "NONE" })
vim.api.nvim_set_hl(0, "HintsHl", { fg = "#A5E9DD", bg = "NONE" })
vim.api.nvim_set_hl(0, "InfoHl", { fg = "#B0BA99", bg = "NONE" })
vim.api.nvim_set_hl(0, "StBase", { bg = "NONE" }) -- Transparent background
vim.api.nvim_set_hl(0, "Statusline", { reverse = false }) -- Transparent background

local function get_mode()
  local mode_map = {
    n = { " Normal ", "StModeNormal" },
    i = { " Insert ", "StModeInsert" },
    v = { " Visual ", "StModeVisual" },
    V = { " V-line ", "StModeVisual" },
    ["\22"] = { " V-block ", "StModeVisual" },
    c = { " Command ", "StModeOther" },
    r = { " R-pending ", "StModeOther" }, -- r-pending
    R = { " Replace ", "StModeOther" }, -- replace
    t = { " Terminal", "StModeOther" },
  }
  local mode = vim.api.nvim_get_mode().mode
  local m = mode_map[mode] or { " " .. mode .. " ", "StModeOther" }
  return "%#" .. m[2] .. "#" .. m[1] .. "%#StBase#"
end

local function get_git()
  local dict = vim.b.gitsigns_status_dict
  if not dict then
    return ""
  end

  local branch = dict.head and ("%#StGitDelete#  %#StGitBranch#" .. dict.head .. " ") or ""
  local added = dict.added and dict.added > 0 and ("%#StGitAdd#+" .. dict.added .. " ") or ""
  local changed = dict.changed and dict.changed > 0 and ("%#StGitChange#~" .. dict.changed .. " ") or ""
  local removed = dict.removed and dict.removed > 0 and ("%#StGitDelete#-" .. dict.removed .. " ") or ""

  local diff = added .. changed .. removed
  if branch == "" and diff == "" then
    return ""
  end
  return branch .. diff .. ""
end

local function get_lsp_diagnostic_count()
  local counts = vim.diagnostic.count(0)

  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warnings = counts[vim.diagnostic.severity.WARN] or 0
  local hints = counts[vim.diagnostic.severity.HINT] or 0
  local info = counts[vim.diagnostic.severity.INFO] or 0

  local error_icon = errors > 0 and "  " .. errors or ""
  local warnings_icon = warnings > 0 and "  " .. warnings or ""
  local hints_icon = hints > 0 and "  " .. hints or ""
  local info_icon = info > 0 and "  " .. info or ""

  return "%#ErrorHl#" .. error_icon .. "%#WarningHl#" .. warnings_icon .. "%#HintsHl#" .. hints_icon .. "%#InfoHl#" .. info_icon
end

local function get_icon()
  local icon, icon_hl = vim.g.miniIcons.get("file", vim.fn.expand("%:t"))
  if not icon then
    return ""
  end
  return "%#" .. icon_hl .. "# " .. icon .. " %#StBase#"
end

local function get_lsp_clients()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if next(clients) == nil then
    return ""
  end
  local client_names = {}
  for _, client in ipairs(clients) do
    local alt_text = string.gsub(client.name, "mini.", "")
    table.insert(client_names, alt_text)
  end
  return "   " .. table.concat(client_names, ", ")
end

-- local function get_progress()
--   -- LSP progress (e.g. "indexing…" from language servers)
--   local progress = vim.ui.progress_status and vim.ui.progress_status() or ""
--   if progress ~= "" then
--     return "%#StBase# " .. progress .. " %#StBase#"
--   end
--   return ""
-- end

function _G.CustomStatusLine()
  local is_active = vim.g.statusline_winid == vim.fn.win_getid()
  local is_modified = vim.api.nvim_get_option_value("modified", { buf = 0 })
  local modified_icon = is_modified and "●" or ""
  local filename = "%t"
  local right_align = "%="
  if not is_active then
    return "%#StBase#" .. filename .. right_align
  end
  return "%#StBase#"
    .. get_mode()
    .. " "
    .. get_git()
    .. "%#StBase#"
    .. " "
    .. get_icon()
    .. "%#FileName#"
    .. filename
    .. " "
    .. "%#FileModifiedIcon#"
    .. modified_icon
    .. " "
    .. get_lsp_diagnostic_count()
    .. "%#StBase#"
    .. right_align
    -- .. "%#StBase#"
    -- .. get_progress()
    .. "%#StGitChange#"
    .. get_lsp_clients()
    .. "  %#InfoHl# "
    .. vim.bo.fileencoding
    .. " "
    .. vim.bo.fileformat
    .. " "
    .. "%#HintsHl#   "
    .. "%#FileName# %l:%c"
    .. "%#InfoHl# %p%% "
end

vim.opt.statusline = "%!v:lua.CustomStatusLine()"

vim.cmd("redrawstatus") -- no need if not using any floating window from dashboard

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave", "CmdlineLeave" }, {
  callback = function()
    vim.schedule(function() vim.cmd("redrawstatus") end)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function() vim.cmd("redrawstatus") end,
})
