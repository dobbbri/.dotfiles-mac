# Doom Emacs — configuração para macOS / Emacs 31.1

Configuração gerenciada por **GNU Stow**, com foco em Astro, JavaScript, TypeScript, TSX, Tailwind CSS e Biome 2.5.

O pacote instala o Doom Emacs em `~/.config/emacs` e liga os arquivos desta pasta a `~/.config/doom`. **O Emacs já instalado não é reinstalado nem substituído.**

## Estrutura

```text
doom-emacs-gpt/
├── README.md
├── install.sh
├── .config/
│   └── doom/
│       ├── init.el
│       ├── packages.el
│       └── config.el
├── scripts/
│   ├── install-biome-project.sh
│   └── install-treesit.el
└── templates/
    └── biome.json
```

## Requisitos

- macOS e GNU Emacs 31.1.
- Git.
- Node.js e npm.
- GNU Stow.
- `cc` / Xcode Command Line Tools para compilar as gramáticas Tree-sitter.
- `ripgrep` é recomendado para a busca do Doom.

No macOS, caso ainda faltem ferramentas auxiliares:

```bash
xcode-select --install
sudo macport install stow ripgrep fd
```

Não execute `brew install emacs`: o instalador deste pacote não instala nem atualiza o Emacs.

## Instalação

Coloque a pasta `doom-emacs-gpt` diretamente dentro do diretório que você usa como repositório de dotfiles. Exemplo:

```text
~/.dotfiles-mac/
└── doom-emacs-gpt/
```

Então:

```bash
cd ~/.dotfiles-mac/doom-emacs-gpt
chmod +x install.sh scripts/install-biome-project.sh
./install.sh
```

O instalador:

1. verifica Emacs, Git, Node.js, npm, Stow e compilador C;
2. clona Doom em `~/.config/emacs`, caso ainda não exista;
3. preserva uma configuração real já existente em `~/.config/doom`, movendo-a para um diretório de backup com data e hora;
4. aplica os links do GNU Stow;
5. instala os servidores LSP globais de Astro, TypeScript, Tailwind e HTML/CSS/JSON;
6. instala as gramáticas Tree-sitter necessárias;
7. executa `doom install` na primeira instalação ou `doom sync` nas seguintes e salva o ambiente do shell.

Opções:

```bash
./install.sh --skip-npm       # não instala/atualiza servidores npm globais
./install.sh --skip-treesit   # não compila gramáticas Tree-sitter
./install.sh --help
```

Se Doom já estiver instalado, o script não o clona novamente. Se `~/.config/emacs` existir e não for um clone Git do Doom, o instalador para sem apagar esse diretório.

## Biome 2.5 em cada projeto

O executável do Biome deve ser instalado **localmente em cada projeto**. Isso permite que o cliente LSP use a versão travada pelo projeto em vez de uma versão global.

A partir da pasta desta configuração:

```bash
./scripts/install-biome-project.sh /caminho/do/seu/projeto
```

Ou, estando dentro do projeto:

```bash
/path/para/doom-emacs-gpt/scripts/install-biome-project.sh .
```

O script executa `npm install --save-dev @biomejs/biome@~2.5.0` e copia `templates/biome.json` se o projeto ainda não tiver `biome.json` ou `biome.jsonc`. Ele **não sobrescreve** uma configuração Biome já existente.

Configuração incluída:

- indentação com 2 espaços;
- limite de 120 colunas;
- formatter habilitado;
- linter habilitado;
- ação `organizeImports` habilitada.

Comandos úteis no projeto:

```bash
npx biome --version
npx biome check .
npx biome check --write .
npx biome format --write .
npx biome lint .
```

`npx biome check --write .` executa as verificações e aplica as correções disponíveis, inclusive organização de imports configurada no `biome.json`.

## Astro e a fronteira do Biome

O LSP do Astro fornece recursos de linguagem para arquivos `.astro`, e o LSP do Tailwind é configurado como servidor adicional para coexistir com outros servidores no mesmo buffer.

**O Biome não é configurado como formatador de arquivos `.astro`.** A integração Biome desta configuração fica para JavaScript, TypeScript, TSX/JSX, JSON/JSONC e CSS. O servidor Astro pode oferecer formatação por meio de Prettier, mas isso exige instalar Prettier e `prettier-plugin-astro` no projeto; eles não são instalados por este pacote.

## Tree-sitter

O instalador compila as gramáticas `astro`, `css`, `html`, `javascript`, `json`, `tsx` e `typescript`.

Astro depende especialmente das gramáticas `astro`, `tsx` e `css`. As gramáticas são compiladas na máquina local e ficam no diretório de dados do Doom, fora desta pasta de dotfiles.

Para instalar ou reparar manualmente as gramáticas depois:

```bash
DOOM_EMACS_DIR="$HOME/.config/emacs" \
  emacs --batch -Q -l scripts/install-treesit.el
```

## Atalhos e comandos

O prefixo do LSP é `C-c l`:

- `C-c l o`: organizar imports com Biome.
- `C-c l f`: aplicar correções disponíveis do Biome.
- `C-c l w d`: descrever a sessão LSP.
- `C-c l w r`: reiniciar os servidores da sessão.
- `M-x lsp-format-buffer`: solicitar formatação ao servidor LSP ativo.

O formatador automático no salvamento usa Apheleia com `npx --no-install biome format` para os modos JavaScript/TypeScript/TSX, JSON e CSS. Por isso, instale Biome localmente em cada projeto antes de ativar a formatação nesse projeto.

## Diagnóstico

Depois da instalação:

```bash
~/.config/emacs/bin/doom doctor
~/.config/emacs/bin/doom sync
```

Dentro do Emacs, abra um projeto que tenha `package.json` e `biome.json` e execute:

```text
M-x lsp-describe-session
```

Para verificar se o executável do Biome local é encontrado, no terminal do projeto:

```bash
./node_modules/.bin/biome --version
```

Se o Emacs aberto pelo Dock não encontrar executáveis globais do npm, feche-o e abra-o novamente depois de executar `doom sync --env` no terminal.

## Arquivos gerenciados

| Caminho no pacote | Destino via Stow |
|---|---|
| `.config/doom/init.el` | `~/.config/doom/init.el` |
| `.config/doom/packages.el` | `~/.config/doom/packages.el` |
| `.config/doom/config.el` | `~/.config/doom/config.el` |

Para retirar os links do Stow, execute no diretório pai do pacote:

```bash
stow -D doom-emacs-gpt
```

Isso remove os links gerenciados pelo Stow; não desinstala Doom, Emacs, npm ou os pacotes já instalados.
