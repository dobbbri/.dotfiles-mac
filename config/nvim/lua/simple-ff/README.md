# simple-ff.nvim

A tiny, dependency-free fuzzy file finder for Neovim, inspired by
[ff-lua.nvim](https://github.com/). ~250 lines, one Lua file for the logic.

## Features
- Floating prompt + results window (like ff-lua.nvim's UI)
- Fuzzy subsequence matching with a lightweight scoring heuristic
  (rewards consecutive matches and matches after `/`, `-`, `_`, space)
- Uses `fd` or `ripgrep` for fast file listing if installed, otherwise
  falls back to a pure-Lua recursive directory walk — no external
  dependency required
- Live filtering as you type
- Simple keymaps: arrows / `<C-j>` `<C-k>` to move, `<CR>` to open,
  `<Esc>`/`<C-c>` to cancel

## Install (lazy.nvim)

```lua
{
  dir = "~/path/to/simple-ff", -- or your git repo once published
  cmd = "FF",
  keys = {
    { "<leader>ff", "<cmd>FF<cr>", desc = "Find files" },
  },
}
```

## Install (packer.nvim)

```lua
use { "~/path/to/simple-ff" }
```

## Usage

```
:FF
```

Opens the finder rooted at the current working directory (`:pwd`).
Type to filter, `<CR>` opens the file under the highlighted line.

## Configuration

Call `setup` yourself if you want to override defaults (this replaces the
call the plugin file makes automatically):

```lua
require("simple-ff").setup({
  width = 0.6,        -- fraction of editor width
  height = 0.6,        -- fraction of editor height
  max_results = 200,   -- cap on displayed matches
  ignore_dirs = { ".git", "node_modules", ".venv", "__pycache__", "target", "dist", "build" },
})
```

## How it differs from ff-lua.nvim

This is a minimal, single-purpose reimplementation of the core idea
(fuzzy find + open) without the extra pickers (grep, buffers, git
status, etc.), extension system, or Rust-backed fuzzy matcher. It's
meant to be short enough to read start to finish and easy to extend
yourself — the whole implementation lives in
`lua/simple-ff/init.lua`.

## License

MIT
