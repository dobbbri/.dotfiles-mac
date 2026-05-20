local g = vim.g
local opt = vim.opt

-- mapleader
g.mapleader = " "
g.maplocalleader = ","
--------------------------------------------------------------------------------------------------------------------

-- Matchparen (Highlight matching brackets)
g.matchparen_timeout = 20 -- Timeout in ms for highlight calculation
g.matchparen_insert_timeout = 20 -- Timeout in ms during insert mode

-- Editorconfig
g.EditorConfig_core_mode = "external_command"

-- Fix markdown indentation settings
g.markdown_recommended_style = 2
g.markdown_fenced_languages = {
  "html",
  "javascript",
  "typescript",
  "css",
  "scss",
  "lua",
  "vim",
  "bash",
  "python",
  "json",
}

-- disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- opt.colorcolumn = "101"
opt.termguicolors = true

-- use rounded borders on all floating windows
opt.winborder = "rounded" -- "rounded" --"solid"  --"single"

-- nice confirmation dialog
opt.confirm = true

-- options
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

opt.swapfile = false
opt.undofile = false

opt.timeoutlen = 700
opt.updatetime = 250

opt.cursorline = false
-- opt.cursorlineopt = "both"
opt.cursorlineopt = "screenline,number" -- Show cursor line per screen line

-- Indenting
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = 2

-- folding - ufo
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

--
opt.list = false
opt.listchars = "nbsp:⍽,trail:·,extends:→,precedes:←"

opt.fillchars = {
  foldopen = "󰅀", -- "",
  foldclose = "󰅂", --"󰅂",-- "",--"",
  foldsep = "│",
}

-- linebreak
opt.wrap = false
opt.breakindent = true
opt.whichwrap = "h,l,<,>,[,],~"
opt.showbreak = "󱞪 "

opt.ignorecase = true
opt.smartcase = true

opt.mouse = "a"
opt.mousescroll = "ver:25,hor:6" -- Customize mouse scroll
opt.switchbuf = "usetab" -- Use already opened buffers when switching
opt.clipboard = "unnamedplus"

-- Numbers
opt.number = true
opt.numberwidth = 2

-- disable nvim intro
opt.shortmess = "CFOSWaco" -- Disable some built-in completion messages

opt.splitbelow = true
opt.splitright = true

opt.conceallevel = 2

-- title
opt.title = true
opt.titlestring = '%t%( %M%)%( (%{expand("%:~:h")})%)%a [nvim]'

-- statusline
opt.laststatus = 3
opt.cmdheight = 1

-- Disabling unused built-in plugins improves startup time.
local disabled_built_ins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
  "netrw", -- Keep netrw disabled if you use NvimTree
  "netrwPlugin",
  "netrwSettings",
}

for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end
