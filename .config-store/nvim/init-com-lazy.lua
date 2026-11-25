--╔══════════════════════════════════════════════════════════════════════╗
--║  init-com-lazy.lua — Mesmos plugins do init-com-pack.lua, mas com     ║
--║  lazy-loading DE VERDADE: cada plugin só carrega no evento/comando/   ║
--║  tecla/filetype que efetivamente precisa dele, em vez de tudo no      ║
--║  start. A config de cada plugin agora mora dentro do próprio spec     ║
--║  (config = function() ... end), não mais numa seção separada.        ║
--║  Requisitos externos: git, ripgrep (rg), fd, node + npm, nerd font    ║
--╚══════════════════════════════════════════════════════════════════════╝

-------------------------------------------------------
-- 0. LEADER KEY (precisa vir antes de carregar plugins)
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
-- colapsado num "+" só (assim que o treesitter liga o foldexpr, lá na
-- config do nvim-treesitter). foldcolumn=1 é o que o statuscol.nvim usa
-- pra saber a largura do ícone de fold.
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"

-- Visual
opt.wrap = false
opt.list = true
opt.listchars = { trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12
opt.conceallevel = 0
-- (sem opt.laststatus manual: o lualine com globalstatus=true já cuida disso)

-------------------------------------------------------
-- 2. CONFIG NATIVA (não depende de plugin nenhum, roda sempre)
-------------------------------------------------------
local ignore_files = { ".DS_Store", ".git", ".astro", "dist", "package-lock.json", "node_modules" }

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

vim.filetype.add({ extension = { astro = "astro" } })

-------------------------------------------------------
-- 3. BOOTSTRAP + PLUGINS (lazy.nvim, com lazy-loading real)
-------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  ---------------------------------------------------------------------
  -- Tema: carrega eager (sem event/cmd/keys/ft) — precisa estar pronto
  -- antes de qualquer outra UI desenhar. priority alto garante que ele
  -- é o primeiro a carregar entre os eager.
  ---------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha", transparent_background = false })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  -- Ícones: eager também (custo irrisório, e várias coisas VeryLazy/lazy
  -- dependem dele — mais simples deixar sempre disponível).
  { "nvim-tree/nvim-web-devicons", opts = {} },

  ---------------------------------------------------------------------
  -- Interface "sempre visível": não bloqueia o primeiro frame (VeryLazy
  -- = carrega logo depois da UI inicial aparecer, não durante o boot).
  ---------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "catppuccin-mocha", globalstatus = true },
      extensions = { "nvim-tree", "trouble", "lazy" },
    },
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        -- mesmos ícones do vim.diagnostic.config (seção 2), pra não ter
        -- um glifo diferente na aba vs. na gutter/float.
        diagnostics_indicator = function(count, level)
          local icon = (level == "error") and icons.error or icons.warn
          return icon .. count
        end,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({})
      wk.add({
        { "<leader>f", group = "buscar" },
        { "<leader>s", group = "search & replace" },
        { "<leader>c", group = "código" },
        { "<leader>x", group = "diagnósticos" },
        { "<leader>h", group = "git hunks" },
      })
    end,
  },

  ---------------------------------------------------------------------
  -- Árvore de arquivos: só carrega no primeiro <leader>e / "-".
  -- "keys" já registra o mapeamento E serve de gatilho de carregamento.
  ---------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Abrir/fechar árvore de arquivos" },
      { "-", "<cmd>NvimTreeToggle<CR>", desc = "Abrir/fechar árvore de arquivos" },
    },
    opts = {
      view = { width = 32 },
      renderer = { group_empty = true, highlight_git = "all" },
      filters = { dotfiles = false, custom = ignore_files },
      git = { ignore = false },
      actions = { open_file = { quit_on_open = true } },
    },
  },

  ---------------------------------------------------------------------
  -- Busca: só carrega no primeiro <leader>f*.
  ---------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Buscar arquivos" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Buscar texto no projeto (grep)" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buscar entre buffers abertos" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Buscar na ajuda" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Arquivos recentes" },
      { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Buscar diagnósticos (erros/avisos)" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({ defaults = { file_ignore_patterns = ignore_files } })
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Search & replace em massa: só carrega no primeiro <leader>s*.
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, desc = "Search & Replace (grug-far)" },
      {
        "<leader>sw",
        function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
        desc = "Substituir palavra sob o cursor",
      },
    },
    config = function()
      local rg_glob_excludes = {}
      for _, name in ipairs(ignore_files) do
        table.insert(rg_glob_excludes, string.format("--glob '!%s'", name))
      end
      require("grug-far").setup({
        engines = { ripgrep = { extraArgs = table.concat(rg_glob_excludes, " ") } },
      })
    end,
  },

  ---------------------------------------------------------------------
  -- Treesitter: carrega só quando um buffer de arquivo real abre (pula
  -- o custo no scratch buffer inicial vazio do Neovim).
  ---------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter").install({
        "typescript", "tsx", "javascript", "astro",
        "html", "css", "json", "yaml", "markdown", "markdown_inline",
        "lua", "vim", "vimdoc", "bash", "graphql", "query",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local ft = ev.match
          if ft == "" then return end
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if not pcall(vim.treesitter.language.add, lang) then return end
          if pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "astro", "javascript", "javascriptreact", "typescript", "typescriptreact", "xml" },
    opts = {},
  },

  ---------------------------------------------------------------------
  -- LSP: VeryLazy — precisa estar pronto cedo (capabilities/on_attach),
  -- mas não precisa bloquear o primeiro frame igual o treesitter.
  ---------------------------------------------------------------------
  { "williamboman/mason.nvim", event = "VeryLazy", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "ts_ls", "astro", "tailwindcss", "cssls", "html", "jsonls", "emmet_ls", "lua_ls", "biome",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = { "williamboman/mason-lspconfig.nvim", "saghen/blink.cmp" },
    config = function()
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

      -- Tailwind precisa reconhecer classes dentro de .astro, .tsx, .jsx etc.
      vim.lsp.config("tailwindcss", {
        filetypes = {
          "html", "css", "astro", "javascript", "javascriptreact",
          "typescript", "typescriptreact",
        },
        init_options = { userLanguages = { astro = "html" } },
      })

      -- emmet_ls por padrão só ativa em html/css.
      vim.lsp.config("emmet_ls", {
        filetypes = { "html", "css", "astro", "javascriptreact", "typescriptreact" },
      })

      -- "biome" só "ativa de verdade" em projetos com biome.json/biome.jsonc
      -- na raiz (root_dir/root_markers padrão do nvim-lspconfig).
      vim.lsp.enable({
        "ts_ls", "astro", "cssls", "html", "jsonls", "lua_ls", "biome", "tailwindcss", "emmet_ls",
      })
    end,
  },
  { "brenoprata10/nvim-highlight-colors", event = { "BufReadPre", "BufNewFile" }, opts = { render = "background" } },
  -- lazydev: só é relevante editando .lua (config/plugins do Neovim).
  { "folke/lazydev.nvim", ft = "lua", opts = {} },

  ---------------------------------------------------------------------
  -- Autocomplete: InsertEnter é o gatilho clássico pra isso.
  ---------------------------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("blink.cmp").setup({
        keymap = { preset = "default" },
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
    end,
  },

  ---------------------------------------------------------------------
  -- Formatação: BufWritePre é o gatilho recomendado pelo próprio conform
  -- pra format-on-save — o lazy.nvim carrega o plugin e refaz o evento,
  -- então o primeiro save já formata. <leader>cf também dispara o load.
  ---------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ lsp_fallback = true }) end,
        mode = { "n", "v" },
        desc = "Formatar código",
      },
    },
    dependencies = { "zapling/mason-conform.nvim" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          sh = { "shfmt" },
          lua = { "stylua" },
          toml = { "taplo" },
          yaml = { "yamlfmt" },
          astro = { "biome" },
          javascript = { "biome" },
          javascriptreact = { "biome" },
          typescript = { "biome" },
          typescriptreact = { "biome" },
          css = { "biome" },
          html = { "biome" },
          json = { "biome" },
          jsonc = { "biome" },
          markdown = { "biome" },
        },
        format_on_save = { timeout_ms = 1000, lsp_fallback = true },
      })
      -- precisa rodar DEPOIS do conform.setup() acima, pra saber quais
      -- formatters instalar via mason.
      require("mason-conform").setup()
    end,
  },

  ---------------------------------------------------------------------
  -- Produtividade
  ---------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, keys, fn, desc)
          vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function() gs.nav_hunk("next") end, "Próximo hunk git")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Hunk git anterior")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame da linha")
      end,
    },
  },
  -- ts-comments.nvim: estende o "gc"/"gcc" NATIVO do Neovim (0.10+) com
  -- commentstring correto via treesitter em contexto embutido (ex: <script>
  -- dentro de .astro, JSX dentro de .tsx). Substitui Comment.nvim +
  -- nvim-ts-context-commentstring — não precisa de engine própria porque o
  -- Neovim já comenta nativamente, só faltava a detecção de linguagem certa.
  { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  -- nvim-notify: troca o vim.notify padrão (que só usa :messages/echo) por
  -- toasts no canto da tela. Pega mensagens de LSP, erros de plugin, e
  -- qualquer vim.notify(...) que você mesmo chamar.
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      timeout = 3000,
      render = "compact",
      stages = "fade_in_slide_out",
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Lista de diagnósticos" },
    },
    opts = {},
  },
  -- visual-multi/statuscol têm keymaps/gutter próprios definidos no load
  -- do plugin (não dá pra prever toda tecla de antemão pra usar "keys"),
  -- então VeryLazy é o gatilho seguro aqui.
  { "yaocccc/visual-multi.nvim", event = "VeryLazy", opts = {} },
  {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
      })
    end,
  },
}, {
  ui = { border = "rounded" },
})

-------------------------------------------------------
-- 4. ATALHOS GERAIS EXTRAS (não dependem de plugin nenhum)
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

-------------------------------------------------------
-- 5. AUTOCMDS DE QUALIDADE DE VIDA (nativas, sem plugin)
-------------------------------------------------------

--- save cursor position ---
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restaurar cursor na última posição ao reabrir um arquivo",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

--- TextYankPost ---
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  callback = function() vim.hl.hl_op() end,
})

--- redimensiona os splits proporcionalmente quando a janela do terminal muda de tamanho ---
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Reequilibrar splits ao redimensionar a janela",
  callback = function() vim.cmd("wincmd =") end,
})

--- fecha buffers "utilitários" só com "q" (sem precisar de :q ou <C-w>q) ---
vim.api.nvim_create_autocmd("FileType", {
  desc = "Fechar buffers utilitários (help, qf, lspinfo etc.) com 'q'",
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth", "notify" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})
