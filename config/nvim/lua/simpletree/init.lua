-- simpletree.nvim
-- Uma árvore de arquivos minimalista para Neovim, inspirada no nvim-tree.lua.
-- Comandos básicos: navegar, abrir/fechar pastas, criar, renomear e excluir
-- arquivos e pastas. Ícones via nvim-web-devicons (opcional).

local M = {}

---------------------------------------------------------------------------
-- Dependência opcional: nvim-web-devicons
---------------------------------------------------------------------------
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

---------------------------------------------------------------------------
-- Configuração
---------------------------------------------------------------------------
local config = {
  keymap = "<leader>e",
  close_on_open = false, -- fecha a árvore ao abrir um arquivo
  icons = nil,           -- sobrescreve default_icons/fallback_icons via setup()
}

-- Ícones padrão (Nerd Font). Sobrescrevíveis via setup({ icons = {...} }).
local default_icons = {
  folder_closed = "",
  folder_open = "",
  folder_empty = "",
  folder_empty_open = "",
}

-- Fallback ASCII usado quando não há Nerd Font/devicons disponível.
local fallback_icons = {
  folder_closed = ">",
  folder_open = "v",
  folder_empty = ">",
  folder_empty_open = "v",
}

local function folder_icon(is_empty, expanded)
  local base = has_devicons and default_icons or fallback_icons
  local icons = config.icons or base
  local hl = has_devicons and "SimpleTreeFolderIcon" or nil

  if is_empty then
    return (expanded and icons.folder_empty_open or icons.folder_empty), hl
  end
  return (expanded and icons.folder_open or icons.folder_closed), hl
end

local function file_icon(name)
  if has_devicons then
    local ext = name:match("^.+%.(.+)$")
    local icon, hl = devicons.get_icon(name, ext, { default = true })
    if icon then
      return icon, hl
    end
  end
  return "", nil
end

---------------------------------------------------------------------------
-- Estado interno
---------------------------------------------------------------------------
local state = {
  buf = nil,      -- buffer da árvore
  win = nil,      -- janela da árvore
  root = nil,     -- caminho raiz sendo exibido
  expanded = {},  -- set de pastas expandidas: [caminho] = true
  entries = {},   -- lista de nós visíveis atualmente (exceto a raiz)
}

local ns = vim.api.nvim_create_namespace("simpletree_icons")

---------------------------------------------------------------------------
-- Utilitários de caminho
---------------------------------------------------------------------------
local function normalize(path)
  return (path:gsub("//+", "/"))
end

local function join(a, b)
  if a:sub(-1) == "/" then
    return normalize(a .. b)
  end
  return normalize(a .. "/" .. b)
end

---------------------------------------------------------------------------
-- Leitura do sistema de arquivos
---------------------------------------------------------------------------
local function sorted_children(path)
  local ok, names = pcall(vim.fn.readdir, path)
  if not ok or not names then
    return {}
  end

  local dirs, files = {}, {}
  for _, name in ipairs(names) do
    local full = join(path, name)
    if vim.fn.isdirectory(full) == 1 then
      table.insert(dirs, name)
    else
      table.insert(files, name)
    end
  end

  table.sort(dirs, function(a, b) return a:lower() < b:lower() end)
  table.sort(files, function(a, b) return a:lower() < b:lower() end)

  local out = {}
  for _, n in ipairs(dirs) do table.insert(out, n) end
  for _, n in ipairs(files) do table.insert(out, n) end
  return out
end

local function build_entries(path, depth, out)
  for _, name in ipairs(sorted_children(path)) do
    local full = join(path, name)
    local is_dir = vim.fn.isdirectory(full) == 1
    local is_empty = is_dir and (#sorted_children(full) == 0)
    table.insert(out, { path = full, name = name, is_dir = is_dir, is_empty = is_empty, depth = depth })
    if is_dir and state.expanded[full] then
      build_entries(full, depth + 1, out)
    end
  end
end

---------------------------------------------------------------------------
-- Renderização
---------------------------------------------------------------------------
local function set_icon_highlight(bufnr, line0, col_start, col_end, hl_group)
  if not hl_group then return end
  vim.api.nvim_buf_set_extmark(bufnr, ns, line0, col_start, {
    end_col = col_end,
    hl_group = hl_group,
  })
end

local function render()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end

  local entries = {}
  build_entries(state.root, 0, entries)
  state.entries = entries

  vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)

  -- linha da raiz
  local root_is_empty = #sorted_children(state.root) == 0
  local root_icon, root_hl = folder_icon(root_is_empty, true)
  local root_line = root_icon .. " " .. state.root .. "/"
  local lines = { root_line }
  local icon_ranges = { { line0 = 0, col_start = 0, col_end = #root_icon, hl = root_hl } }

  for i, e in ipairs(entries) do
    local indent = string.rep("  ", e.depth)
    local icon, hl
    if e.is_dir then
      icon, hl = folder_icon(e.is_empty, state.expanded[e.path])
    else
      icon, hl = file_icon(e.name)
    end

    local prefix = indent .. icon .. " "
    local suffix = e.is_dir and "/" or ""
    table.insert(lines, prefix .. e.name .. suffix)

    table.insert(icon_ranges, {
      line0 = i, -- linha 0-indexed no buffer (root ocupa linha 0)
      col_start = #indent,
      col_end = #indent + #icon,
      hl = hl,
    })
  end

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false

  for _, r in ipairs(icon_ranges) do
    set_icon_highlight(state.buf, r.line0, r.col_start, r.col_end, r.hl)
  end
end

local function entry_at_cursor()
  local lnum = vim.api.nvim_win_get_cursor(state.win)[1]
  if lnum == 1 then
    return { path = state.root, is_dir = true, name = ".", is_root = true }
  end
  return state.entries[lnum - 1]
end

---------------------------------------------------------------------------
-- Ações
---------------------------------------------------------------------------
local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

local function open_file_in_other_window(path)
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= state.win then
      target_win = win
      break
    end
  end

  if target_win then
    vim.api.nvim_set_current_win(target_win)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  else
    vim.cmd("vsplit " .. vim.fn.fnameescape(path))
  end

  if config.close_on_open then
    close()
  end
end

local function action_enter()
  local e = entry_at_cursor()
  if not e then return end
  if e.is_dir then
    state.expanded[e.path] = not state.expanded[e.path]
    render()
  else
    open_file_in_other_window(e.path)
  end
end

local function dir_of(e)
  if e.is_dir then return e.path end
  return vim.fn.fnamemodify(e.path, ":h")
end

-- Cria um novo arquivo ou pasta.
-- Se o nome terminar com "/", cria uma pasta; caso contrário, um arquivo.
local function action_create()
  local e = entry_at_cursor()
  local base = e and dir_of(e) or state.root
  local name = vim.fn.input("Criar (termine com / para pasta): ", base .. "/")
  if name == "" then return end

  if name:sub(-1) == "/" then
    local ok = vim.fn.mkdir(name, "p")
    if ok == 0 then
      vim.notify("Falha ao criar pasta: " .. name, vim.log.levels.ERROR)
      return
    end
    state.expanded[vim.fn.fnamemodify(name, ":h")] = true
  else
    if vim.fn.filereadable(name) == 1 or vim.fn.isdirectory(name) == 1 then
      vim.notify("Já existe: " .. name, vim.log.levels.ERROR)
      return
    end
    local parent = vim.fn.fnamemodify(name, ":h")
    vim.fn.mkdir(parent, "p")
    vim.fn.writefile({}, name)
    state.expanded[parent] = true
  end

  render()
end

-- Renomeia (ou move) um arquivo/pasta.
local function action_rename()
  local e = entry_at_cursor()
  if not e or e.is_root then return end

  local new_name = vim.fn.input("Renomear para: ", e.path)
  if new_name == "" or new_name == e.path then return end

  local ok = vim.fn.rename(e.path, new_name)
  if ok ~= 0 then
    vim.notify("Falha ao renomear", vim.log.levels.ERROR)
  elseif state.expanded[e.path] ~= nil then
    state.expanded[new_name] = state.expanded[e.path]
    state.expanded[e.path] = nil
  end

  render()
end

-- Exclui um arquivo ou pasta (pede confirmação).
local function action_delete()
  local e = entry_at_cursor()
  if not e or e.is_root then return end

  local choice = vim.fn.confirm("Excluir '" .. e.name .. "'?", "&Sim\n&Não", 2)
  if choice ~= 1 then return end

  local flags = e.is_dir and "rf" or ""
  local ok = vim.fn.delete(e.path, flags)
  if ok ~= 0 then
    vim.notify("Falha ao excluir: " .. e.path, vim.log.levels.ERROR)
  else
    state.expanded[e.path] = nil
  end

  render()
end

---------------------------------------------------------------------------
-- Setup do buffer/janela
---------------------------------------------------------------------------
local function setup_highlights()
  -- Cor padrão para o ícone de pasta (sobrescreva no seu colorscheme se quiser)
  vim.api.nvim_set_hl(0, "SimpleTreeFolderIcon", { link = "Directory", default = true })
end

local function setup_buffer()
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false
  vim.bo[state.buf].filetype = "simpletree"
  vim.api.nvim_buf_set_name(state.buf, "SimpleTree")

  local opts = { buffer = state.buf, nowait = true, silent = true }
  vim.keymap.set("n", "<CR>", action_enter, opts)
  vim.keymap.set("n", "o", action_enter, opts)
  vim.keymap.set("n", "a", action_create, opts)
  vim.keymap.set("n", "r", action_rename, opts)
  vim.keymap.set("n", "d", action_delete, opts)
  vim.keymap.set("n", "R", render, opts)
  vim.keymap.set("n", "q", close, opts)
end

---------------------------------------------------------------------------
-- API pública
---------------------------------------------------------------------------
function M.open(path)
  local target = path or vim.fn.getcwd()
  state.root = normalize(vim.fn.fnamemodify(target, ":p"):gsub("/$", ""))
  if state.root == "" then state.root = "/" end

  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    setup_buffer()
  end

  vim.cmd("topleft 35vsplit")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = "no"
  vim.wo[state.win].wrap = false

  render()
end

function M.toggle(path)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    close()
  else
    M.open(path)
  end
end

function M.setup(opts)
  opts = opts or {}
  config.keymap = opts.keymap
  if opts.close_on_open ~= nil then
    config.close_on_open = opts.close_on_open
  end
  if opts.icons then
    local base = has_devicons and default_icons or fallback_icons
    config.icons = vim.tbl_deep_extend("force", {}, base, opts.icons)
  end

  setup_highlights()

  vim.api.nvim_create_user_command("SimpleTreeOpen", function(cmdopts)
    M.open(cmdopts.args ~= "" and cmdopts.args or nil)
  end, { nargs = "?", complete = "dir" })

  vim.api.nvim_create_user_command("SimpleTreeToggle", function(cmdopts)
    M.toggle(cmdopts.args ~= "" and cmdopts.args or nil)
  end, { nargs = "?", complete = "dir" })

  if config.keymap ~= false then
    vim.keymap.set("n", config.keymap or "<leader>e", "<cmd>SimpleTreeToggle<cr>",
      { desc = "Abrir/fechar SimpleTree" })
  end
end

return M
