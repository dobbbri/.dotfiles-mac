-- simple-ff: a tiny fuzzy file finder for Neovim, inspired by ff-lua.nvim
-- Single-file, no dependencies (uses `fd` or `rg` if available, else pure-Lua fallback).

local M = {}

M.config = {
  width = 0.6,     -- fraction of editor width
  height = 0.6,    -- fraction of editor height
  max_results = 200,
  ignore_dirs = { ".git", "node_modules", ".venv", "__pycache__", "target", "dist", "build" },
}

local state = {
  buf = nil,
  win = nil,
  prompt_buf = nil,
  prompt_win = nil,
  files = {},      -- full file list for cwd
  filtered = {},   -- currently filtered+sorted list
  selected = 1,
  ns = vim.api.nvim_create_namespace("simple_ff"),
}

--------------------------------------------------------------------------
-- File collection
--------------------------------------------------------------------------

local function collect_with_cmd(cmd)
  local ok, lines = pcall(vim.fn.systemlist, cmd)
  if not ok or vim.v.shell_error ~= 0 then
    return nil
  end
  return lines
end

-- Pure-Lua fallback: walk the cwd recursively.
local function collect_fallback(root, ignore)
  local results = {}
  local ignore_set = {}
  for _, d in ipairs(ignore) do
    ignore_set[d] = true
  end

  local function scan(dir)
    if #results >= 20000 then return end
    local fd = vim.loop.fs_scandir(dir)
    if not fd then return end
    while true do
      local name, typ = vim.loop.fs_scandir_next(fd)
      if not name then break end
      if not ignore_set[name] and name:sub(1, 1) ~= "." then
        local path = dir .. "/" .. name
        if typ == "directory" then
          scan(path)
        else
          results[#results + 1] = path:sub(#root + 2)
        end
      end
    end
  end

  scan(root)
  return results
end

function M.refresh_files()
  local cwd = vim.fn.getcwd()
  local ignore_globs = {}
  for _, d in ipairs(M.config.ignore_dirs) do
    ignore_globs[#ignore_globs + 1] = "--exclude " .. d
  end

  local files = nil

  if vim.fn.executable("fd") == 1 then
    files = collect_with_cmd("fd --type f --hidden --strip-cwd-prefix "
      .. table.concat(ignore_globs, " "))
  elseif vim.fn.executable("rg") == 1 then
    files = collect_with_cmd("rg --files --hidden "
      .. table.concat(vim.tbl_map(function(d) return "--glob '!" .. d .. "'" end, M.config.ignore_dirs), " "))
  end

  if not files then
    files = collect_fallback(cwd, M.config.ignore_dirs)
  end

  state.files = files or {}
end

--------------------------------------------------------------------------
-- Fuzzy matching (subsequence match with simple scoring)
--------------------------------------------------------------------------

-- Returns score (higher = better) or nil if `pattern` is not a subsequence of `str`.
local function fuzzy_score(str, pattern)
  if pattern == "" then return 0 end
  local s, p = str:lower(), pattern:lower()
  local si, pi = 1, 1
  local score = 0
  local prev_match = -2
  local slen, plen = #s, #p

  while si <= slen and pi <= plen do
    if s:sub(si, si) == p:sub(pi, pi) then
      -- reward consecutive matches and matches at word boundaries
      if si == prev_match + 1 then
        score = score + 8
      else
        score = score + 1
      end
      if si == 1 or s:sub(si - 1, si - 1):match("[/_%-%s]") then
        score = score + 5
      end
      prev_match = si
      pi = pi + 1
    end
    si = si + 1
  end

  if pi <= plen then
    return nil -- not all pattern chars matched, no match
  end

  -- prefer shorter overall strings (less noise)
  score = score - (slen * 0.01)
  return score
end

function M.filter(query)
  if query == "" then
    local out = {}
    for i = 1, math.min(#state.files, M.config.max_results) do
      out[#out + 1] = { path = state.files[i], score = 0 }
    end
    return out
  end

  local scored = {}
  for _, f in ipairs(state.files) do
    local sc = fuzzy_score(f, query)
    if sc then
      scored[#scored + 1] = { path = f, score = sc }
    end
  end

  table.sort(scored, function(a, b) return a.score > b.score end)

  local out = {}
  for i = 1, math.min(#scored, M.config.max_results) do
    out[#out + 1] = scored[i]
  end
  return out
end

--------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------

local function editor_geometry()
  local width = math.floor(vim.o.columns * M.config.width)
  local height = math.floor(vim.o.lines * M.config.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  return width, height, row, col
end

local function render_results()
  local lines = {}
  for _, item in ipairs(state.filtered) do
    lines[#lines + 1] = item.path
  end
  if #lines == 0 then
    lines = { "-- no matches --" }
  end

  vim.api.nvim_buf_set_option(state.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(state.buf, "modifiable", false)

  vim.api.nvim_buf_clear_namespace(state.buf, state.ns, 0, -1)
  if #state.filtered > 0 then
    local idx = state.selected - 1
    vim.api.nvim_buf_add_highlight(state.buf, state.ns, "PmenuSel", idx, 0, -1)
    vim.api.nvim_win_set_cursor(state.win, { state.selected, 0 })
  end
end

local function update_prompt_title()
  local total = #state.filtered
  local count_str = string.format(" %d/%d ", total, #state.files)
  pcall(vim.api.nvim_win_set_config, state.prompt_win, { title = { { " Files ", "FloatTitle" }, { count_str, "Comment" } } })
end

local function do_filter()
  local query = vim.api.nvim_buf_get_lines(state.prompt_buf, 0, 1, false)[1] or ""
  state.filtered = M.filter(query)
  state.selected = 1
  render_results()
  update_prompt_title()
end

local function close()
  if state.prompt_win and vim.api.nvim_win_is_valid(state.prompt_win) then
    vim.api.nvim_win_close(state.prompt_win, true)
  end
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.prompt_win = nil, nil
end

local function open_selected()
  local item = state.filtered[state.selected]
  close()
  if item then
    vim.cmd("edit " .. vim.fn.fnameescape(item.path))
  end
end

local function move_selection(delta)
  if #state.filtered == 0 then return end
  state.selected = state.selected + delta
  if state.selected < 1 then state.selected = 1 end
  if state.selected > #state.filtered then state.selected = #state.filtered end
  render_results()
end

function M.open()
  M.refresh_files()
  state.filtered = M.filter("")
  state.selected = 1

  local width, height, row, col = editor_geometry()
  local results_h = height - 3

  -- results window
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(state.buf, "buftype", "nofile")
  state.win = vim.api.nvim_open_win(state.buf, false, {
    relative = "editor",
    width = width,
    height = results_h,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- prompt window (below results, small)
  state.prompt_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(state.prompt_buf, "buftype", "nofile")
  state.prompt_win = vim.api.nvim_open_win(state.prompt_buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row + results_h + 2,
    col = col,
    style = "minimal",
    border = "rounded",
    title = { { " Files ", "FloatTitle" } },
  })

  vim.api.nvim_buf_set_option(state.prompt_buf, "modifiable", true)
  vim.cmd("startinsert")

  render_results()
  update_prompt_title()

  local opts = { buffer = state.prompt_buf, nowait = true, silent = true }
  vim.keymap.set({ "i", "n" }, "<CR>", open_selected, opts)
  vim.keymap.set({ "i", "n" }, "<Esc>", close, opts)
  vim.keymap.set({ "i", "n" }, "<C-c>", close, opts)
  vim.keymap.set({ "i", "n" }, "<C-j>", function() move_selection(1) end, opts)
  vim.keymap.set({ "i", "n" }, "<C-k>", function() move_selection(-1) end, opts)
  vim.keymap.set({ "i", "n" }, "<Down>", function() move_selection(1) end, opts)
  vim.keymap.set({ "i", "n" }, "<Up>", function() move_selection(-1) end, opts)

  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    buffer = state.prompt_buf,
    callback = do_filter,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = state.prompt_buf,
    once = true,
    callback = close,
  })
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  vim.api.nvim_create_user_command("FF", M.open, {})
end

return M
