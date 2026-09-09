-------------------------------------------------------
-- OPÇÕES GERAIS (options)
-------------------------------------------------------
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
-- Fallback pra janela entre o boot e o statuscol.nvim carregar (VeryLazy);
-- depois que ele assume a coluna via 'statuscolumn', essas duas opções
-- deixam de ter efeito visual, mas evitam "pulo" de layout antes disso.
opt.numberwidth = 2 -- largura mínima da coluna de número
opt.signcolumn = "yes" -- sempre mostra a coluna de sinal, largura 1
opt.termguicolors = true
opt.mouse = "a"
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Indentação (2 espaços, padrão do ecossistema JS/TS/Astro)
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Busca
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Área de transferência e arquivos
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 200
opt.timeoutlen = 400

-- Divisões de tela
opt.splitright = true
opt.splitbelow = true

-- Fold: sem foldlevel/foldlevelstart altos, o arquivo abre com tudo
-- colapsado num "+" só (assim que o treesitter liga o foldexpr, em
-- lua/plugins/treesitter.lua). foldcolumn=1 é o que o statuscol.nvim usa
-- pra saber a largura do ícone de fold.
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"

-- Visual
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.conceallevel = 0
-- (sem opt.laststatus manual: o lualine com globalstatus=true já cuida disso)

vim.filetype.add({ extension = { astro = "astro" } })
