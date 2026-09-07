--╔══════════════════════════════════════════════════════════════════════╗
--║  init-com-pack.lua — Mesma config, SEM nenhum módulo do mini.nvim.    ║
--║  Cada mini.* foi trocado pelo plugin "clássico" equivalente, pra você ║
--║  comparar as duas abordagens lado a lado.                            ║
--║  Gerenciador de plugins: vim.pack (nativo, requer Neovim >= 0.12)     ║
--║  Requisitos externos: git, ripgrep (rg), fd, node + npm, nerd font    ║
--╚══════════════════════════════════════════════════════════════════════╝

-------------------------------------------------------
-- 0. LEADER KEY (precisa vir antes de configurar plugins)
-------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Recomendação do próprio nvim-ts-context-commentstring: pula o carregamento
-- do módulo antigo (baseado em nvim-treesitter.configs, que não existe mais
-- no branch "main"), já que vamos integrar via pre_hook manualmente.
vim.g.skip_ts_context_commentstring_module = true

-------------------------------------------------------
-- 1. OPÇÕES GERAIS (options)
-------------------------------------------------------
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
-- (sem opt.signcolumn: o statuscol.nvim, configurado mais abaixo, assume
-- a coluna esquerda via 'statuscolumn' e essa opção nativa deixa de ter efeito)
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

-- Fold: o Neovim recente já usa treesitter pra fold automaticamente quando
-- há parser disponível, e sem isso ele fecha o arquivo inteiro num "+" só
-- ao abrir (foldlevel=0). foldlevel/foldlevelstart altos evitam isso —
-- necessário pro segmento de fold do statuscol.nvim funcionar como esperado.
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1" -- statuscol.nvim assume o controle visual dessa coluna

-- Visual
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.conceallevel = 0
-- (sem opt.laststatus manual aqui: o lualine, configurado mais abaixo com
-- globalstatus = true, já cuida disso sozinho)

-------------------------------------------------------
-- 2. INSTALAÇÃO DOS PLUGINS COM vim.pack (nativo)
-------------------------------------------------------
-- vim.pack.add baixa (na primeira vez) e carrega os plugins.
-- Não existe lazy-loading por evento/comando como no lazy.nvim: tudo é
-- carregado no start, então a config abaixo chama os "setup()" na hora.
-- Para atualizar depois: :lua vim.pack.update()
-- Para ver o que está instalado: :lua vim.print(vim.pack.get())

local ignore_files = { ".DS_Store", ".git", ".astro", "dist", "package-lock.json", "node_modules" }

vim.pack.add({
  -- Tema + ícones
  { src = "https://github.com/catppuccin/nvim",                     name = "catppuccin" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- Interface: statusline (lualine) + abas (bufferline) + indent guides + dicas de tecla
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },

  -- Árvore de arquivos
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },

  -- Busca (Telescope) + replace em massa (grug-far)
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/MagicDuck/grug-far.nvim" },

  -- Treesitter (highlight/parsing, incluindo Astro) — branch "main"
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },
  { src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },

  -- LSP
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/brenoprata10/nvim-highlight-colors" },
  { src = "https://github.com/folke/lazydev.nvim" },

  -- Autocomplete: blink.cmp + LuaSnip (em vez de mini.snippets)
  { src = "https://github.com/Saghen/blink.cmp",                    version = "v1" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },

  -- Formatação
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/zapling/mason-conform.nvim" },

  -- Produtividade
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/numToStr/Comment.nvim" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/folke/trouble.nvim" },
  { src = "https://github.com/yaocccc/visual-multi.nvim" },
  { src = "https://github.com/luukvbaal/statuscol.nvim" },
}, { confirm = false })

-- telescope-fzf-native precisa ser compilado (make) na primeira instalação
do
  local fzf_native_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/telescope-fzf-native.nvim"
  if vim.fn.isdirectory(fzf_native_path) == 1
      and vim.fn.filereadable(fzf_native_path .. "/build/libfzf.so") == 0
      and vim.fn.filereadable(fzf_native_path .. "/build/libfzf.dylib") == 0 then
    vim.fn.jobstart({ "make" }, { cwd = fzf_native_path })
  end
end

-------------------------------------------------------
-- 3. CONFIGURAÇÃO DE CADA PLUGIN
-------------------------------------------------------

-- Tema + ícones
require("catppuccin").setup({ flavour = "mocha", transparent_background = false })
vim.cmd.colorscheme("catppuccin")
require("nvim-web-devicons").setup({})

-- Interface
require("lualine").setup({
  options = { theme = "catppuccin-mocha", globalstatus = true },
  extensions = { "nvim-tree", "trouble", "lazy" },
})
require("bufferline").setup({ options = { diagnostics = "nvim_lsp", separator_style = "slant" } })
require("ibl").setup({ indent = { char = "│" }, scope = { enabled = true } })

-- which-key: mostra dicas de tecla enquanto você segura o leader, "g" etc.
local wk = require("which-key")
wk.setup({})
wk.add({
  { "<leader>f", group = "buscar" },
  { "<leader>s", group = "search & replace" },
  { "<leader>c", group = "código" },
  { "<leader>x", group = "diagnósticos" },
  { "<leader>h", group = "git hunks" },
})

-- Árvore de arquivos: fecha sozinha ao abrir um arquivo (quit_on_open),
-- e ignora as mesmas pastas/arquivos que o resto da config já ignora.
require("nvim-tree").setup({
  view = { width = 32 },
  renderer = { group_empty = true, highlight_git = "all" },
  filters = { dotfiles = false, custom = ignore_files },
  git = { ignore = false },
  actions = { open_file = { quit_on_open = true } },
})
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Abrir/fechar árvore de arquivos" })

-- Telescope: busca fuzzy
local telescope = require("telescope")
telescope.setup({
  defaults = { file_ignore_patterns = ignore_files },
})
pcall(telescope.load_extension, "fzf")

local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Buscar arquivos" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Buscar texto no projeto (grep)" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Buscar entre buffers abertos" })
vim.keymap.set("n", "<leader>fh", tb.help_tags, { desc = "Buscar na ajuda" })
vim.keymap.set("n", "<leader>fr", tb.oldfiles, { desc = "Arquivos recentes" })
vim.keymap.set("n", "<leader>fd", tb.diagnostics, { desc = "Buscar diagnósticos (erros/avisos)" })

-- grug-far: search & replace em massa no projeto. Reaproveita o mesmo
-- ignore_files do explorer/telescope pra montar os --glob do ripgrep.
local rg_glob_excludes = {}
for _, name in ipairs(ignore_files) do
  table.insert(rg_glob_excludes, string.format("--glob '!%s'", name))
end

require("grug-far").setup({
  engines = {
    ripgrep = { extraArgs = table.concat(rg_glob_excludes, " ") },
  },
})
vim.keymap.set("n", "<leader>sr", function() require("grug-far").open() end, { desc = "Search & Replace (grug-far)" })
vim.keymap.set("n", "<leader>sw", function()
  require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Substituir palavra sob o cursor" })

-- Treesitter (branch "main"): instala os parsers e liga highlight/indent
-- via API nativa do Neovim, já que o módulo antigo "nvim-treesitter.configs"
-- não existe mais nessa versão do plugin.
require("nvim-treesitter").install({
  "typescript", "tsx", "javascript", "astro",
  "html", "css", "json", "yaml", "markdown", "markdown_inline",
  "lua", "vim", "vimdoc", "bash", "graphql", "query",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local ft = ev.match
    if ft == "" then return end
    -- Filetypes "de interface" de plugins (árvore, telescope, etc.) não têm
    -- parser de verdade; o pcall abaixo já protege contra erro nesses casos,
    -- então não precisamos de uma lista de exclusão explícita aqui.
    local lang = vim.treesitter.language.get_lang(ft) or ft
    if not pcall(vim.treesitter.language.add, lang) then return end
    if pcall(vim.treesitter.start, ev.buf, lang) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      -- Sem isso, foldmethod fica em "manual" (padrão do Vim) e não existe
      -- fold nenhum pra clicar — era essa a causa do clique do statuscol
      -- "não fazer nada". foldexpr do treesitter cria folds de verdade
      -- (funções, blocos, tags) baseados na árvore sintática.
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

require("nvim-ts-autotag").setup({})
vim.filetype.add({ extension = { astro = "astro" } })

-- lazydev.nvim: ensina o lua_ls sobre vim.*/plugins instalados ao editar
-- o próprio config. Resolve o warning "undefined global `vim`".
require("lazydev").setup({})

-- LSP
require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls", "astro", "tailwindcss", "cssls", "html", "jsonls", "emmet_ls", "lua_ls",
    "biome",
  },
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

local on_attach = function(_, bufnr)
  local map = function(keys, fn, desc)
    vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = desc })
  end
  map("gd", vim.lsp.buf.definition, "Ir para definição")
  map("gr", vim.lsp.buf.references, "Ver referências")
  map("K", vim.lsp.buf.hover, "Documentação (hover)")
  map("<leader>rn", vim.lsp.buf.rename, "Renomear símbolo")
  map("<leader>ca", vim.lsp.buf.code_action, "Ações de código")
end

vim.lsp.config("*", { capabilities = capabilities, on_attach = on_attach })

-- Ícones usados na config (diagnóstico por enquanto; centralizado aqui pra
-- reaproveitar em outro lugar que precise dos mesmos glifos).
local icons = {
  error = "󰅚 ", -- U+F015A
  warn  = "󰀪 ", -- U+F002A
  info  = "󰋽 ", -- U+F02FD
  hint  = "󰌶 ", -- U+F0336
}

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.error,
      [vim.diagnostic.severity.WARN] = icons.warn,
      [vim.diagnostic.severity.INFO] = icons.info,
      [vim.diagnostic.severity.HINT] = icons.hint,
    },
  },
  virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
  float = { border = "rounded", source = true },
})
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
})

-- "biome" só "ativa de verdade" em projetos que tenham biome.json/biome.jsonc
-- na raiz (comportamento padrão do root_dir/root_markers do nvim-lspconfig).
local servers = {
  "ts_ls", "astro", "cssls", "html", "jsonls", "lua_ls", "biome", "tailwindcss", "emmet_ls",
}

vim.lsp.config("tailwindcss", {
  filetypes = {
    "html", "css", "astro", "javascript", "javascriptreact",
    "typescript", "typescriptreact",
  },
  init_options = { userLanguages = { astro = "html" } },
})

vim.lsp.config("emmet_ls", {
  filetypes = { "html", "css", "astro", "javascriptreact", "typescriptreact" },
})

vim.lsp.enable(servers)

require("nvim-highlight-colors").setup({ render = "background" })

-- LuaSnip: motor de snippets (substitui o mini.snippets)
require("luasnip.loaders.from_vscode").lazy_load()

-- blink.cmp: autocompletar. Usa o LuaSnip como fonte de snippet em vez do
-- mini.snippets.
require("blink.cmp").setup({
  keymap = { preset = "default" }, -- <C-y> aceita, <C-n>/<C-p> navega, <C-space> abre docs
  appearance = { nerd_font_variant = "mono" },
  completion = { documentation = { auto_show = true } },
  sources = {
    default = { "lsp", "path", "buffer", "snippets" },
    per_filetype = { lua = { "lazydev", "lsp", "path", "buffer", "snippets" } },
    providers = { lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" } },
  },
  snippets = { preset = "luasnip" },
  fuzzy = { implementation = "lua" },
})

-- Formatação: biome cobre JS/TS/JSX/TSX/JSON.
require("conform").setup({
  formatters_by_ft = {
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    json = { "biome" },
    jsonc = { "biome" },
    lua = { "stylua" },
  },
  format_on_save = { timeout_ms = 1000, lsp_fallback = true },
})
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Formatar código" })

require("mason-conform").setup()

-- Produtividade
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local map = function(mode, keys, fn, desc)
      vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = desc })
    end
    map("n", "]c", gs.next_hunk, "Próximo hunk git")
    map("n", "[c", gs.prev_hunk, "Hunk git anterior")
    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame da linha")
  end,
})

-- Comment.nvim + nvim-ts-context-commentstring: substitui o mini.comment.
-- O pre_hook detecta o commentstring certo via treesitter (ex: <script>
-- dentro de um .astro, ou JSX dentro de .tsx).
-- (missing-fields é só o lua_ls reclamando que não passamos TODOS os campos
-- do CommentConfig; o plugin mescla com os defaults dele normalmente em
-- runtime, então o disable abaixo é seguro.)
---@diagnostic disable-next-line: missing-fields
require("Comment").setup({
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})

-- nvim-autopairs: substitui o mini.pairs
require("nvim-autopairs").setup({})

require("trouble").setup({})
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Lista de diagnósticos" })

-- statuscol.nvim: coluna à esquerda customizada juntando fold + sinais
-- (git/diagnóstico) + número de linha.
local statuscol_builtin = require("statuscol.builtin")
require("statuscol").setup({
  relculright = true,
  segments = {
    { text = { statuscol_builtin.foldfunc }, click = "v:lua.ScFa" },
    { text = { "%s" }, click = "v:lua.ScSa" },
    { text = { statuscol_builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
  },
})

-- visual-multi.nvim: múltiplos cursores (reescrita em Lua do vim-visual-multi)
require("visual-multi").setup({})

-------------------------------------------------------
-- 4. ATALHOS GERAIS EXTRAS
-------------------------------------------------------
local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Sair do modo insert" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Salvar arquivo" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Fechar janela" })
map("n", "<leader>nh", "<cmd>nohl<CR>", { desc = "Limpar destaque de busca" })

-- Navegação entre janelas
map("n", "<C-h>", "<C-w>h", { desc = "Ir para janela à esquerda" })
map("n", "<C-l>", "<C-w>l", { desc = "Ir para janela à direita" })
map("n", "<C-j>", "<C-w>j", { desc = "Ir para janela abaixo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ir para janela acima" })

-- Manter cursor centralizado ao navegar
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Mover linha(s)/seleção (sem plugin — comando :m nativo do Vim)
map("n", "<M-j>", ":m .+1<CR>==", { desc = "Mover linha atual pra baixo" })
map("n", "<M-k>", ":m .-2<CR>==", { desc = "Mover linha atual pra cima" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover seleção pra baixo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover seleção pra cima" })
