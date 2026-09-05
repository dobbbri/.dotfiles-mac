-- ~/.config/nvim/lua/statusline.lua
-- Statusline customizada e nativa para o Neovim (sem plugins)
-- Contém: modo (status), branch git, nome do arquivo, diagnósticos, linha e coluna
--
-- Para usar: coloque este arquivo em ~/.config/nvim/lua/statusline.lua
-- e adicione no seu init.lua:
--   require("statusline")

local M = {}

-- ===========================================================
-- Cores / Highlight groups
-- ===========================================================
local function set_highlights()
  local hl = vim.api.nvim_set_hl

  hl(0, "StNormal",   { fg = "#1e1e2e", bg = "#89b4fa", bold = true }) -- azul
  hl(0, "StInsert",   { fg = "#1e1e2e", bg = "#a6e3a1", bold = true }) -- verde
  hl(0, "StVisual",   { fg = "#1e1e2e", bg = "#f9e2af", bold = true }) -- amarelo
  hl(0, "StReplace",  { fg = "#1e1e2e", bg = "#f38ba8", bold = true }) -- vermelho
  hl(0, "StCommand",  { fg = "#1e1e2e", bg = "#cba6f7", bold = true }) -- roxo
  hl(0, "StTerminal", { fg = "#1e1e2e", bg = "#94e2d5", bold = true }) -- ciano
  hl(0, "StInactive", { fg = "#1e1e2e", bg = "#6c7086", bold = true }) -- cinza

  hl(0, "StGit",      { fg = "#f9e2af", bg = "#313244" })
  hl(0, "StFile",     { fg = "#cdd6f4", bg = "#313244", bold = true })
  hl(0, "StDiagError",{ fg = "#f38ba8", bg = "#313244" })
  hl(0, "StDiagWarn", { fg = "#f9e2af", bg = "#313244" })
  hl(0, "StDiagInfo", { fg = "#89b4fa", bg = "#313244" })
  hl(0, "StDiagHint", { fg = "#94e2d5", bg = "#313244" })
  hl(0, "StPos",      { fg = "#1e1e2e", bg = "#89b4fa", bold = true })
  hl(0, "StMid",      { fg = "#cdd6f4", bg = "#181825" })
end

-- ===========================================================
-- Modo (status) atual
-- ===========================================================
local modes = {
  ["n"]    = { "NORMAL",    "StNormal",   "" },
  ["no"]   = { "N-PENDING", "StNormal",   "" },
  ["i"]    = { "INSERT",    "StInsert",   "" },
  ["ic"]   = { "INSERT",    "StInsert",   "" },
  ["v"]    = { "VISUAL",    "StVisual",   "" },
  ["V"]    = { "V-LINE",    "StVisual",   "" },
  [""]   = { "V-BLOCK",   "StVisual",   "" },
  ["R"]    = { "REPLACE",   "StReplace",  "" },
  ["Rv"]   = { "V-REPLACE", "StReplace",  "" },
  ["c"]    = { "COMMAND",   "StCommand",  "" },
  ["cv"]   = { "EX",        "StCommand",  "" },
  ["ce"]   = { "EX",        "StCommand",  "" },
  ["t"]    = { "TERMINAL",  "StTerminal", "" },
  ["s"]    = { "SELECT",    "StVisual",   "" },
  ["S"]    = { "S-LINE",    "StVisual",   "" },
}

local function mode_component()
  local m = vim.api.nvim_get_mode().mode
  local info = modes[m] or { m:upper(), "StNormal", "" }
  local label, hl, icon = info[1], info[2], info[3]
  return string.format("%%#%s# %s %s %%*", hl, icon, label)
end

-- ===========================================================
-- Git branch
-- ===========================================================
-- Usa vim.b.gitsigns_head se o gitsigns.nvim estiver instalado,
-- ou faz fallback lendo o arquivo .git/HEAD manualmente.
local function get_git_branch()
  if vim.b.gitsigns_head then
    return vim.b.gitsigns_head
  end

  local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
  if git_dir == "" then
    return nil
  end

  local head_file = git_dir .. "/HEAD"
  local ok, lines = pcall(vim.fn.readfile, head_file)
  if not ok or not lines or #lines == 0 then
    return nil
  end

  local head = lines[1]
  local branch = head:match("ref: refs/heads/(.+)")
  return branch or head:sub(1, 7) -- detached HEAD: mostra hash curto
end

local function git_component()
  local branch = get_git_branch()
  if not branch then
    return ""
  end
  return string.format("%%#StGit#  %s %%*", branch)
end

-- -- ===========================================================
-- -- Nome do arquivo (com ícone do tipo de arquivo)
-- -- ===========================================================
-- -- Usa nvim-web-devicons se estiver instalado; caso contrário,
-- -- cai em uma tabela pequena de ícones por extensão.
-- local fallback_icons = {
--   lua   = "",
--   py    = "",
--   js    = "",
--   ts    = "",
--   jsx   = "",
--   tsx   = "",
--   json  = "",
--   md    = "",
--   html  = "",
--   css   = "",
--   sh    = "",
--   yml   = "",
--   yaml  = "",
--   toml  = "",
--   go    = "",
--   rs    = "",
--   c     = "",
--   h     = "",
--   cpp   = "",
--   java  = "",
--   rb    = "",
--   php   = "",
--   vim   = "",
--   git   = "",
--   txt   = "",
--   sql   = "",
--   dockerfile = "",
-- }

local function file_icon(filename, filetype)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local icon = devicons.get_icon(filename, filename:match("^.+%.(.+)$"), { default = true })
    if icon then
      return icon
    end
  end

  return ""
  -- local ext = filename:match("^.+%.(.+)$") or filetype
  -- return fallback_icons[ext] or ""
end

local function file_component()
  local name = vim.fn.expand("%:t")
  local ft = vim.bo.filetype

  local icon = file_icon(name == "" and "unnamed" or name, ft)

  if name == "" then
    name = "[Sem Nome]"
  end

  local status_icon = ""
  if vim.bo.modified then
    status_icon = " ●"
  elseif vim.bo.readonly then
    status_icon = " "
  end

  return string.format("%%#StFile# %s %s%s %%*", icon, name, status_icon)
end

-- ===========================================================
-- Diagnósticos (LSP)
-- ===========================================================
local function diagnostics_component()
  local buf = vim.api.nvim_get_current_buf()
  local counts = {
    [vim.diagnostic.severity.ERROR] = 0,
    [vim.diagnostic.severity.WARN]  = 0,
    [vim.diagnostic.severity.INFO]  = 0,
    [vim.diagnostic.severity.HINT]  = 0,
  }

  for _, d in ipairs(vim.diagnostic.get(buf)) do
    counts[d.severity] = (counts[d.severity] or 0) + 1
  end

  local parts = {}
  if counts[vim.diagnostic.severity.ERROR] > 0 then
    table.insert(parts, string.format("%%#StDiagError#󰅚 %d%%*", counts[vim.diagnostic.severity.ERROR]))
  end
  if counts[vim.diagnostic.severity.WARN] > 0 then
    table.insert(parts, string.format("%%#StDiagWarn#󰀪 %d%%*", counts[vim.diagnostic.severity.WARN]))
  end
  if counts[vim.diagnostic.severity.INFO] > 0 then
    table.insert(parts, string.format("%%#StDiagInfo#󰋽 %d%%*", counts[vim.diagnostic.severity.INFO]))
  end
  if counts[vim.diagnostic.severity.HINT] > 0 then
    table.insert(parts, string.format("%%#StDiagHint#󰌵 %d%%*", counts[vim.diagnostic.severity.HINT]))
  end

  if #parts == 0 then
    return "%#StDiagInfo#  ok%*"
  end

  return table.concat(parts, " ")
end

-- ===========================================================
-- Linha e coluna
-- ===========================================================
local function position_component()
  return "%#StPos#  %l:%c  󰉸 %p%% %*"
end

-- ===========================================================
-- Monta a statusline completa
-- ===========================================================
function M.statusline()
  return table.concat({
    mode_component(),
    " ",
    git_component(),
    " ",
    file_component(),
    "%#StMid#%=%*",           -- espaço flexível que empurra o resto p/ direita
    diagnostics_component(),
    " ",
    position_component(),
  })
end

-- ===========================================================
-- Setup
-- ===========================================================
function M.setup()
  set_highlights()

  vim.opt.laststatus = 3 -- statusline global (uma só, na parte inferior)
  vim.o.statusline = "%!v:lua.require'statusline'.statusline()"

  local group = vim.api.nvim_create_augroup("CustomStatusline", { clear = true })

  -- Recarrega cores caso o colorscheme mude
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = set_highlights,
  })

  -- Atualiza diagnósticos/branch ao entrar em buffers, salvar, etc.
  vim.api.nvim_create_autocmd(
    { "DiagnosticChanged", "BufEnter", "BufWritePost", "InsertLeave" },
    {
      group = group,
      callback = function()
        vim.cmd("redrawstatus")
      end,
    }
  )
end

M.setup()

return M
