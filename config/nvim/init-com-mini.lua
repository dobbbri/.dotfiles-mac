--╔══════════════════════════════════════════════════════════════════════╗
--║  init.lua — Config Neovim para dev TS / JS / Astro / TailwindCSS      ║
--║  Gerenciador de plugins: vim.pack (nativo, requer Neovim >= 0.12)     ║
--║  Requisitos externos: git, ripgrep (rg), fd, node + npm, nerd font    ║
--╚══════════════════════════════════════════════════════════════════════╝

-------------------------------------------------------
-- 0. LEADER KEY (precisa vir antes de configurar plugins)
-------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-------------------------------------------------------
-- 1. OPÇÕES GERAIS (options)
-------------------------------------------------------
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
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

-- Visual
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.conceallevel = 0
opt.laststatus = 3 -- statusline única pra todas as janelas (era "globalstatus" no lualine)

-------------------------------------------------------
-- 2. INSTALAÇÃO DOS PLUGINS COM vim.pack (nativo)
-------------------------------------------------------
-- vim.pack.add baixa (na primeira vez) e carrega os plugins.
-- Não existe lazy-loading por evento/comando como no lazy.nvim: tudo é
-- carregado no start, então a config abaixo chama os "setup()" na hora.
-- Para atualizar depois: :lua vim.pack.update()
-- Para ver o que está instalado: :lua vim.print(vim.pack.get())

vim.pack.add({
  -- Tema
  { src = "https://github.com/catppuccin/nvim",                     name = "catppuccin" },

  -- mini.nvim: usamos vários módulos independentes dele (ver seção 3:
  -- mini.icons, mini.files, mini.pick, mini.extra, mini.comment, mini.pairs,
  -- mini.clue, mini.move, mini.tabline, mini.indentscope)
  { src = "https://github.com/nvim-mini/mini.nvim" },

  -- Search & replace em massa no projeto
  { src = "https://github.com/MagicDuck/grug-far.nvim" },

  -- Treesitter (highlight/parsing, incluindo Astro) — branch "main" (a
  -- reescrita atual; o antigo branch "master" está congelado/descontinuado)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },

  -- LSP
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/brenoprata10/nvim-highlight-colors" },
  -- Ensina o lua_ls sobre os globals/tipos do Neovim (vim.*, plugins
  -- instalados etc.) ao editar o próprio init.lua. Resolve o warning
  -- "undefined global `vim`" sem precisar mexer manualmente nas settings
  -- do lua_ls.
  { src = "https://github.com/folke/lazydev.nvim" },

  -- Autocomplete: blink.cmp (LSP/buffer/path) + mini.snippets (mini.nvim)
  -- pra snippets. friendly-snippets fica como fonte de snippets prontos
  -- (mini.snippets sabe ler o formato dele nativamente).
  { src = "https://github.com/Saghen/blink.cmp",                    version = "v1" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },

  -- Formatação (biome cobre o lint via LSP, então nvim-lint saiu)
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/zapling/mason-conform.nvim" },

  -- Produtividade
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },
  { src = "https://github.com/yaocccc/visual-multi.nvim" }, -- múltiplos cursores
  { src = "https://github.com/luukvbaal/statuscol.nvim" },  -- coluna de número/sinais/fold customizada
}, { confirm = false })

-------------------------------------------------------
-- 3. CONFIGURAÇÃO DE CADA PLUGIN
-------------------------------------------------------

-- Tema
require("catppuccin").setup({ flavour = "mocha", transparent_background = false })
vim.cmd.colorscheme("catppuccin")

-- mini.icons: substitui o nvim-web-devicons. O mock() cria um shim do módulo
-- "nvim-web-devicons" pra qualquer plugin que ainda peça ícone por esse nome
-- (ex: mini.tabline consegue usar mini.icons direto, mas isso cobre extras).
require("mini.icons").setup({})
require("mini.icons").mock_nvim_web_devicons()

-- mini.statusline: substitui o lualine.nvim. Já vem com git/diagnósticos/
-- filetype/posição do cursor prontos e usa os mesmos ícones do mini.icons.
require("mini.statusline").setup({ use_icons = true })

-- mini.tabline: substitui o bufferline.nvim (mostra os buffers abertos no
-- topo). É mais simples visualmente — sem diagnósticos ricos por aba nem
-- separadores estilizados — mas cobre navegação entre buffers de sobra.
require("mini.tabline").setup({ show_icons = true })

-- mini.indentscope: substitui o indent-blankline. Diferença de conceito:
-- em vez de desenhar guias verticais em todos os níveis de indentação, ele
-- destaca (com animação) só o escopo/bloco onde o cursor está agora.
require("mini.indentscope").setup({
  symbol = "│",
  options = { try_as_border = true },
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "dashboard", "mason", "minifiles", "minipick" },
  callback = function() vim.b.miniindentscope_disable = true end,
})

-- mini.clue: substitui o which-key (mostra dicas de tecla enquanto você
-- segura o leader, "g", janelas, registradores etc.)
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },
  clues = {
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
  window = { delay = 300 },
})

-- mini.files: explorer de arquivos (substitui o snacks.nvim explorer).
-- Funciona como um "buffer editável" da árvore: renomear é editar o texto,
-- criar é escrever uma linha nova, deletar é apagar a linha e salvar (Z Z).
local ignore_files = { ".DS_Store", ".git", ".astro", "dist", "package-lock.json", "node_modules" }

require("mini.files").setup({
  windows = { preview = true, width_focus = 30, width_preview = 40 },
  content = {
    filter = function(fs_entry) return not vim.tbl_contains(ignore_files, fs_entry.name) end,
  },
  mappings = {
    close = "<Esc>",
    go_in = "<CR>",
    go_out = "-",
    show_help = "?",
  },
})

local function toggle_mini_files(path)
  if not MiniFiles.close() then
    MiniFiles.open(path, false)
  end
end

vim.keymap.set("n", "<leader>e", function() toggle_mini_files(vim.fn.getcwd()) end,
  { desc = "Abrir/fechar explorer de arquivos" })
vim.keymap.set("n", "<leader>ef", function() toggle_mini_files(vim.api.nvim_buf_get_name(0)) end,
  { desc = "Localizar arquivo atual no explorer" })

-- Fecha o explorer automaticamente ao abrir um arquivo (entrar em pasta
-- continua normal, só fecha quando o alvo é mesmo um arquivo).
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "<CR>", function()
      require("mini.files").go_in({ close_on_file = true })
    end, { buffer = args.data.buf_id })
  end,
})

-- mini.pick + mini.extra: busca fuzzy (substitui o picker do snacks.nvim).
-- Precisa de "rg" (grep_live) e, opcionalmente, "fd" (files, mais rápido).
require("mini.pick").setup({})
require("mini.extra").setup({})

vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Buscar arquivos" })
vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Buscar texto no projeto (grep)" })
vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Buscar entre buffers abertos" })
vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "Buscar na ajuda" })
vim.keymap.set("n", "<leader>fr", function() MiniExtra.pickers.oldfiles() end, { desc = "Arquivos recentes" })
vim.keymap.set("n", "<leader>fd", function() MiniExtra.pickers.diagnostic() end, { desc = "Buscar diagnósticos (erros/avisos)" })

-- grug-far: search & replace em massa no projeto (substitui o nvim-spectre)
require("grug-far").setup({})
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
    -- Filetypes "de interface" de plugins (mini.files, mini.pick etc.) não
    -- são linguagens de verdade — pular direto evita erro no vim.treesitter.start().
    if ft == "" or ft:match("^mini") then return end

    local lang = vim.treesitter.language.get_lang(ft) or ft
    if not pcall(vim.treesitter.language.add, lang) then return end
    if pcall(vim.treesitter.start, ev.buf, lang) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require("nvim-ts-autotag").setup({})
vim.filetype.add({ extension = { astro = "astro" } })

-- lazydev.nvim: quando você edita um arquivo .lua dentro do config do
-- Neovim (ou de um plugin), ele injeta os tipos/globals certos (vim.*,
-- APIs de plugins instalados) nas settings do lua_ls automaticamente —
-- é isso que faz o warning "undefined global `vim`" sumir.
require("lazydev").setup({})

-- LSP
require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls", "astro", "tailwindcss", "cssls", "html", "jsonls", "emmet_ls", "lua_ls",
    "biome",
  },
})

-- API nativa do Neovim 0.11+ (substitui require('lspconfig')[server].setup(),
-- que está deprecado e sai na v3.0.0 do nvim-lspconfig). O nvim-lspconfig
-- continua instalado só pra fornecer as configs padrão de cada servidor
-- (comando, root_markers, etc.) que o vim.lsp.config() usa por baixo.
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
  map("[d", vim.diagnostic.goto_prev, "Diagnóstico anterior")
  map("]d", vim.diagnostic.goto_next, "Próximo diagnóstico")
end

-- Aplica capabilities + on_attach como padrão pra TODOS os servidores.
vim.lsp.config("*", { capabilities = capabilities, on_attach = on_attach })

local servers = { "ts_ls", "astro", "cssls", "html", "jsonls", "emmet_ls", "lua_ls" }

-- Biome: LSP de lint/format ultra-rápido para JS/TS/JSON.
-- Só "ativa de verdade" em projetos que tenham biome.json ou biome.jsonc
-- na raiz (comportamento padrão do root_dir/root_markers do nvim-lspconfig).
table.insert(servers, "biome")

-- Tailwind precisa reconhecer classes dentro de .astro, .tsx, .jsx etc.
vim.lsp.config("tailwindcss", {
  filetypes = {
    "html", "css", "astro", "javascript", "javascriptreact",
    "typescript", "typescriptreact",
  },
  init_options = { userLanguages = { astro = "html" } },
})
table.insert(servers, "tailwindcss")

vim.lsp.enable(servers)

require("nvim-highlight-colors").setup({ render = "background" })

-- mini.snippets: motor de snippets (parte do mini.nvim). O gen_loader.from_lang()
-- já sabe ler o formato do friendly-snippets automaticamente por filetype.
require("mini.snippets").setup({
  snippets = { require("mini.snippets").gen_loader.from_lang() },
})

-- blink.cmp: autocompletar (substitui nvim-cmp + cmp-nvim-lsp/buffer/path +
-- LuaSnip). Usa o mini.snippets como fonte de snippet.
require("blink.cmp").setup({
  keymap = { preset = "default" }, -- <C-y> aceita, <C-n>/<C-p> navega, <C-space> abre docs
  appearance = { nerd_font_variant = "mono" },
  completion = { documentation = { auto_show = true } },
  sources = {
    default = { "lsp", "path", "buffer", "snippets" },
    per_filetype = { lua = { "lazydev", "lsp", "path", "buffer", "snippets" } },
    providers = { lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" } },
  },
  snippets = { preset = "mini_snippets" },
  fuzzy = { implementation = "lua" }, -- não baixa binário Rust; troque pra "prefer_rust_with_warning" se quiser mais performance
})

-- Formatação: biome cobre JS/TS/JSX/TSX/JSON; prettier e eslint saíram.
-- Astro/CSS/HTML/YAML/Markdown o biome ainda não formata, então ficam sem
-- formatter automático aqui (o LSP de cada um ainda dá highlight/diagnóstico
-- normalmente). O lint desses arquivos também vem do LSP do biome direto,
-- então o nvim-lint saiu da config.
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

-- mason-conform: instala automaticamente (via mason) os formatters usados
-- acima (biome, stylua) sem precisar listar "ensure_installed" à mão.
require("mason-conform").setup()

-- Produtividade
require("gitsigns").setup({})

-- mini.comment: substitui Comment.nvim + nvim-ts-context-commentstring.
-- Já detecta sozinho o "commentstring" certo via treesitter (ex: dentro de
-- um bloco <script> num .astro, ou JSX dentro de .tsx).
require("mini.comment").setup({})

-- mini.pairs: substitui nvim-autopairs (fecha parênteses/colchetes/aspas)
require("mini.pairs").setup({})

-- mini.move: mover linha(s)/seleção. J/K descem/sobem (igual ao mapeamento
-- manual antigo); Alt+h/l move a seleção pra esquerda/direita (indenta).
require("mini.move").setup({
  mappings = {
    left = "<M-h>", right = "<M-l>", down = "J", up = "K",
    line_left = "<M-h>", line_right = "<M-l>", line_down = "J", line_up = "K",
  },
})

require("trouble").setup({})
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Lista de diagnósticos" })

-- statuscol.nvim: coluna à esquerda customizada juntando fold + sinais
-- (git/diagnóstico) + número de linha num único lugar, com clique funcional.
local statuscol_builtin = require("statuscol.builtin")
require("statuscol").setup({
  relculright = true,
  segments = {
    { text = { statuscol_builtin.foldfunc }, click = "v:lua.ScFa" },
    { text = { "%s" }, click = "v:lua.ScSa" }, -- sinais: git, diagnósticos etc.
    { text = { statuscol_builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
  },
})

-- visual-multi.nvim: múltiplos cursores (reescrita em Lua do vim-visual-multi).
-- Mantém os atalhos padrão do plugin original:
--   Ctrl-n        seleciona a palavra sob o cursor / próxima ocorrência igual
--   Ctrl-Down/Up  cria um cursor na linha abaixo/acima
--   \\A           seleciona TODAS as ocorrências da palavra no arquivo
--   Tab           alterna entre modo "cursor" e modo "seleção estendida"
-- Customização de mapeamentos: ver README do plugin (usa vim.g.VM_maps).
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
