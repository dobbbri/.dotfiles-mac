# Config modular do Neovim

Baseada no `init-com-dap.lua`, só que separada em arquivos pra facilitar
manutenção e leitura.

## Estrutura

```
init.lua                  -- bootstrap: leader, options, lazy.nvim, keymaps, autocmds
lua/
  config/
    options.lua            -- opt.* (números, indentação, fold, etc.)
    diagnostics.lua          -- vim.diagnostic.config + ícones nos sinais
    icons.lua                 -- tabela de ícones compartilhada (diagnóstico + dap)
    ignore.lua                 -- lista de pastas/arquivos ignorados (tree/busca/replace)
    keymaps.lua                 -- atalhos que não dependem de plugin nenhum
    autocmds.lua                 -- cursor position, yank highlight, resize, fechar com "q"
  plugins/
    colorscheme.lua               -- catppuccin + nvim-web-devicons
    ui.lua                          -- lualine, bufferline, indent-blankline, which-key
    explorer.lua                     -- nvim-tree
    telescope.lua                     -- telescope + fzf-native + plenary
    search-replace.lua                 -- grug-far
    treesitter.lua                       -- nvim-treesitter (branch main) + nvim-ts-autotag
    lsp.lua                                -- mason, mason-lspconfig, nvim-lspconfig, highlight-colors, lazydev
    completion.lua                          -- blink.cmp + luasnip + friendly-snippets
    format.lua                                -- conform + mason-conform + biome
    dap.lua                                    -- nvim-dap + mason-nvim-dap + dap-ui + virtual-text
    git.lua                                      -- gitsigns
    comments.lua                                  -- ts-comments
    editing.lua                                    -- nvim-autopairs + visual-multi
    notify.lua                                      -- nvim-notify
    trouble.lua                                      -- trouble.nvim
    statuscol.lua                                     -- statuscol.nvim
```

## Atalhos de teclado

`<leader>` = tecla espaço.

### Geral

| Tecla | Ação |
|---|---|
| `jk` (insert) | Sair pro modo normal |
| `<leader>w` | Salvar arquivo |
| `<leader>q` | Fechar janela |
| `<leader>nh` | Limpar destaque de busca |
| `<C-h>` / `<C-l>` / `<C-j>` / `<C-k>` | Ir pra janela à esquerda/direita/abaixo/acima |
| `<C-d>` / `<C-u>` | Meia página abaixo/acima, cursor centralizado |
| `<M-j>` / `<M-k>` (normal) | Mover linha atual pra baixo/cima |
| `J` / `K` (visual) | Mover seleção pra baixo/cima |
| `q` (em `help`/`qf`/`lspinfo`/`man`/`checkhealth`/`notify`/dap) | Fechar o buffer |

### Explorer de arquivos (nvim-tree)

| Tecla | Ação |
|---|---|
| `<leader>e` / `-` | Abrir/fechar árvore de arquivos |

Dentro da árvore: `<CR>` abre, `a` cria, `d` deleta, `r` renomeia, `x`
recorta, `p` cola, `?` mostra todos os atalhos internos do plugin.

### Busca (Telescope)

| Tecla | Ação |
|---|---|
| `<leader>ff` | Buscar arquivos |
| `<leader>fg` | Buscar texto no projeto (grep) |
| `<leader>fb` | Buscar entre buffers abertos |
| `<leader>fh` | Buscar na ajuda |
| `<leader>fr` | Arquivos recentes |
| `<leader>fd` | Buscar diagnósticos (erros/avisos) |

Dentro do picker: `<C-j>`/`<C-k>` navega, `<CR>` seleciona, `<C-x>`/`<C-v>`/`<C-t>`
abre em split/vsplit/aba, `<Esc>` fecha.

### Search & Replace (grug-far)

| Tecla | Ação |
|---|---|
| `<leader>sr` | Abrir search & replace |
| `<leader>sw` | Substituir a palavra sob o cursor |

### LSP (só ativo em buffer com servidor de linguagem anexado)

| Tecla | Ação |
|---|---|
| `gd` | Ir para definição |
| `gr` | Ver referências |
| `K` | Documentação (hover) |
| `<leader>rn` | Renomear símbolo |
| `<leader>ca` | Ações de código |

### Formatação

| Tecla | Ação |
|---|---|
| `<leader>cf` (normal e visual) | Formatar código (conform + biome) |

### Git (gitsigns — buffer-local, só em arquivo versionado)

| Tecla | Ação |
|---|---|
| `]c` / `[c` | Próximo/anterior hunk git |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame da linha |

### Debug (nvim-dap)

| Tecla | Ação |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Breakpoint condicional (pede a condição) |
| `<leader>dc` / `<F5>` | Continuar / iniciar debug |
| `<leader>di` / `<F11>` | Step into |
| `<leader>do` / `<F10>` | Step over |
| `<leader>dO` / `<F12>` | Step out |
| `<leader>dr` | Abrir REPL |
| `<leader>dl` | Repetir última sessão de debug |
| `<leader>dt` | Terminar debug |
| `<leader>du` | Abrir/fechar painel do dap-ui |

### Diagnósticos

| Tecla | Ação |
|---|---|
| `<leader>xx` | Lista de diagnósticos (trouble.nvim) |
| *(automático)* | Float de diagnóstico ao parar o cursor na linha (`CursorHold`) |

### Comentário, autopairs e multi-cursor (atalhos nativos/padrão do plugin)

| Tecla | Ação |
|---|---|
| `gcc` | Comentar/descomentar a linha atual |
| `gc` + motion/seleção | Comentar/descomentar um bloco |
| *(automático)* | Fechar parênteses/aspas/colchetes ao digitar (nvim-autopairs) |
| `<C-n>` | Selecionar palavra sob o cursor / próxima ocorrência igual (visual-multi) |
| `<C-Down>` / `<C-Up>` | Criar cursor na linha abaixo/acima (visual-multi) |
| `\\A` | Selecionar todas as ocorrências no arquivo (visual-multi) |

### Autocomplete (blink.cmp, insert mode)

| Tecla | Ação |
|---|---|
| `<C-y>` | Aceitar sugestão |
| `<C-n>` / `<C-p>` | Navegar entre sugestões |
| `<C-space>` | Abrir/fechar documentação da sugestão |

## Como instalar

1. Faça backup da sua config atual: `mv ~/.config/nvim ~/.config/nvim.bak`
2. Copie o conteúdo desta pasta pra `~/.config/nvim/`
3. Abra o Neovim — o lazy.nvim se instala e baixa todos os plugins sozinho.

## Como o import automático funciona

O `init.lua` só tem:

```lua
require("lazy").setup({
  spec = { { import = "plugins" } },
  ...
})
```

O `{ import = "plugins" }` faz o lazy.nvim ler **todo arquivo `.lua` dentro
de `lua/plugins/`** e juntar tudo que cada um `return`a numa lista só de
specs. Pra adicionar um plugin novo: cria um arquivo novo em
`lua/plugins/nome-qualquer.lua` retornando a spec (ou uma lista de specs) —
não precisa editar o `init.lua` nem nenhum outro arquivo.

## Módulos compartilhados

`config.icons` e `config.ignore` existem porque vários arquivos de plugin
diferentes precisam dos mesmos dados (ex: `explorer.lua`, `telescope.lua` e
`search-replace.lua` todos usam a mesma lista de pastas ignoradas). Se
precisar adicionar mais um valor compartilhado, é só editar esses dois
arquivos — qualquer plugin já pode fazer `require("config.xxx")`.

## Requisitos externos

git, ripgrep (`rg`), `fd`, node + npm, uma Nerd Font no terminal.
