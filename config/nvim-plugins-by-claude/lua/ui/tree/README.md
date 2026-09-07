# simpletree.nvim

Uma árvore de arquivos **minimalista** para Neovim, inspirada no
[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua), mas reduzida ao
essencial: navegar, criar, renomear e excluir arquivos e pastas.

Suporta ícones via [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
(opcional) e não tem git status nem configuração avançada — é o básico, num
único arquivo Lua, fácil de ler e de estender.

## Dependências

- Neovim >= 0.9
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
  (**opcional**). Se não estiver instalado, o plugin funciona normalmente,
  só sem ícones coloridos (usa `>`/`v` para pastas e nenhum ícone para
  arquivos). Requer uma [Nerd Font](https://www.nerdfonts.com/) instalada e
  configurada no seu terminal/GUI para os ícones aparecerem corretamente.

## Instalação

### lazy.nvim

```lua
{
  "seu-usuario/simpletree.nvim", -- ou "dir = '~/caminho/simpletree.nvim'" localmente
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- opcional, para ícones
  config = function()
    require("simpletree").setup({
      keymap = "<leader>e",     -- tecla para abrir/fechar a árvore (opcional)
      close_on_open = false,    -- fecha a árvore ao abrir um arquivo? (opcional)
    })
  end,
}
```

### packer.nvim

```lua
use({
  "seu-usuario/simpletree.nvim",
  requires = { "nvim-tree/nvim-web-devicons" }, -- opcional, para ícones
  config = function()
    require("simpletree").setup({
      close_on_open = true, -- exemplo: fecha a árvore ao abrir um arquivo
    })
  end,
})
```

### Instalação manual

Copie a pasta `lua/simpletree` para dentro do seu `~/.config/nvim/lua/` e
adicione ao seu `init.lua`:

```lua
require("simpletree").setup()
```

## Uso

| Comando               | Ação                                           |
| ---------------------- | ----------------------------------------------- |
| `:SimpleTreeToggle`     | Abre/fecha a árvore no diretório atual (`cwd`) |
| `:SimpleTreeToggle DIR` | Abre/fecha a árvore em `DIR`                   |
| `:SimpleTreeOpen [DIR]` | Sempre abre (não alterna)                      |

Dentro da janela da árvore:

| Tecla     | Ação                                                        |
| --------- | ------------------------------------------------------------ |
| `<CR>`/`o`| Abre o arquivo (em outra janela) ou expande/recolhe a pasta |
| `a`       | **Criar** arquivo ou pasta (termine o nome com `/` para pasta) |
| `r`       | **Renomear**/mover o item sob o cursor                      |
| `d`       | **Excluir** o item sob o cursor (pede confirmação)           |
| `R`       | Atualizar a árvore                                           |
| `q`       | Fechar a janela da árvore                                    |

### Criando arquivos e pastas

Ao pressionar `a`, um prompt aparece já preenchido com o diretório do item
selecionado (ou a raiz, se nada estiver selecionado):

- Para criar um **arquivo**: complete o caminho normalmente, ex.
  `/home/user/projeto/novo_arquivo.lua`
- Para criar uma **pasta**: termine o caminho com `/`, ex.
  `/home/user/projeto/nova_pasta/`

Pastas intermediárias que não existem são criadas automaticamente
(equivalente a `mkdir -p`).

## Opções de `setup()`

| Opção           | Padrão        | Descrição                                                       |
| ---------------- | ------------- | ----------------------------------------------------------------- |
| `keymap`          | `"<leader>e"` | Tecla para `:SimpleTreeToggle`. Use `false` para não mapear nada. |
| `close_on_open`   | `false`       | Se `true`, fecha a janela da árvore automaticamente ao abrir um arquivo (tecla `<CR>`/`o` sobre um arquivo). |
| `icons`           | `nil`         | Tabela para sobrescrever os ícones de pasta (`folder_closed`, `folder_open`, `folder_empty`, `folder_empty_open`). Veja [Ícones](#ícones). |

## Ícones

Se o [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
estiver instalado:

- Cada **arquivo** mostra o ícone da sua extensão, colorido com o grupo de
  highlight fornecido pelo próprio devicons.
- Cada **pasta** mostra um ícone diferente conforme o estado — fechada,
  aberta, vazia fechada ou vazia aberta — destacado com o grupo
  `SimpleTreeFolderIcon` (por padrão ligado a `Directory`; sobrescreva no
  seu colorscheme se quiser outra cor):

  ```lua
  vim.api.nvim_set_hl(0, "SimpleTreeFolderIcon", { fg = "#7aa2f7" })
  ```

Sem o devicons instalado, o plugin usa `>`/`v` (fechada/aberta) como
fallback ASCII para pastas, sem ícones para arquivos.

### Personalizando os ícones de pasta

Os quatro ícones de pasta podem ser sobrescritos em `setup()`:

```lua
require("simpletree").setup({
  icons = {
    folder_closed     = "",
    folder_open       = "",
    folder_empty      = "",
    folder_empty_open = "",
  },
})
```

Se você não fornecer algum dos quatro, o padrão (Nerd Font, ou ASCII se o
devicons não estiver disponível) é mantido para ele.

## Estrutura do projeto

```
simpletree.nvim/
├── lua/
│   └── simpletree/
│       └── init.lua   -- toda a lógica do plugin
└── README.md
```

## Limitações (por ser "simples")

- Não mostra status do git, ícones ou diagnósticos do LSP.
- Não suporta copiar/colar, marcação múltipla ou drag-and-drop.
- Renderiza a árvore inteira recursivamente a cada atualização — ótimo para
  projetos pequenos/médios, mas não otimizado para diretórios gigantes.

Sinta-se livre para usar este código como base e adicionar o que precisar.
