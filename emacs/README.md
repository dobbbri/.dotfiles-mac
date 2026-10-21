# Configuração do Emacs

Emacs vanilla moderno (31+) com **Evil**, **tree-sitter**, **LSP (eglot)**, formatação ao salvar e um stack de completion atual.

**Linguagens:** Astro, Bash, JSON, Lua, TypeScript/TSX, JavaScript, YAML, TOML.

## Instalação

1. Copie `early-init.el` e `init.el` para `~/.emacs.d/`.
2. Instale os binários externos (LSPs, formatadores, `rg`, `fd`):
   ```bash
   bash install-deps.sh            # instala tudo (MacPorts + nvm/npm)
   bash install-deps.sh --check    # só verifica o que está instalado
   ```
3. Abra o Emacs (na primeira vez ele baixa os pacotes).
4. Instale as gramáticas tree-sitter: `M-x my/treesit-install-all`.
   Já tinha um `~/.emacs.d` com arquivos de uso antigos? Com o Emacs fechado, rode
   `bash migrate-emacs-d.sh --dry-run` para ver o que seria movido e depois `bash migrate-emacs-d.sh`.
5. Reinicie o Emacs. Se os ícones aparecerem como quadrados, rode `M-x nerd-icons-install-fonts` e reinicie de novo.

## Organização do `~/.emacs.d`

Só a configuração fica na raiz; os dados de uso vão para pastas (pacote `no-littering`):

| Pasta/arquivo | Conteúdo |
|---|---|
| `early-init.el`, `init.el`, `custom.el` | Configuração |
| `etc/` | Arquivos de apoio (ex.: bookmarks) |
| `var/` | Dados de uso: recentes (`recentf.eld`), histórico, posição nos arquivos, lista de projetos, cache de compilação (`eln-cache/`), histórico do Magit... |
| `elpa/`, `tree-sitter/` | Pacotes e gramáticas (gerenciados pelo Emacs) |

Ao listar `~/.emacs.d` (`SPC f f`) ou os arquivos do projeto `~/.emacs.d` (`SPC p p`), as pastas `elpa`, `eln-cache`, `var` e `tree-sitter` ficam ocultas: só a configuração aparece. A pasta `.emacs.d` não é escondida pelo filtro de dotfiles, e o `~/.emacs.d` funciona como projeto mesmo sem git.

## Dashboard

Ao abrir o Emacs sem arquivo, aparece a tela inicial com os **últimos 8 arquivos** e os **últimos 6 projetos**. Use `j`/`k` para andar e `RET` para abrir (ou `r` / `p` para pular para a lista de recentes / projetos). O `~/.emacs.d` aparece normalmente como projeto. Para mudar as quantidades, edite `dashboard-items` no `init.el`.

## Convenções

| Tecla | O que faz |
|---|---|
| `SPC` | Tecla líder (nos modos normal, visual e motion). O `which-key` mostra o menu depois de 0,4 s |
| `,` | Local leader (reservado, ainda sem atalhos) |
| `C-g` | No modo insert, volta ao modo normal; em qualquer lugar, cancela |
| `C-u` | Rola meia página para cima (como no Vim) |
| `j` / `k` | Andam por linhas visuais (úteis com quebra de linha) |

O resto é o Vim de sempre (`h j k l`, `w b e`, `dd`, `yy`, `p`, `u`, `C-r`, `/`, `:w`...).

## Atalhos com leader (`SPC`)

### Rápidos

| Tecla | Ação |
|---|---|
| `SPC SPC` | Abrir arquivo do projeto |
| `SPC ,` | Trocar de buffer |
| `SPC /` | Buscar texto no projeto (ripgrep) |
| `SPC .` | Ações sobre o item atual (embark) |

### Arquivos (`SPC f`)

| Tecla | Ação |
|---|---|
| `SPC f f` | Abrir arquivo |
| `SPC f r` | Arquivos recentes |
| `SPC f s` | Salvar |

### Buffers (`SPC b`)

| Tecla | Ação |
|---|---|
| `SPC b b` | Trocar de buffer |
| `SPC b d` | Fechar o buffer atual |
| `SPC b n` / `SPC b p` | Próximo / anterior |
| `SPC b h` | Abrir o dashboard (arquivos e projetos recentes) |

### Janelas (`SPC w`)

| Tecla | Ação |
|---|---|
| `SPC w v` | Dividir na vertical |
| `SPC w s` | Dividir na horizontal |
| `SPC w d` | Fechar a janela |
| `SPC w w` | Ir para a outra janela |

### Busca (`SPC s`)

| Tecla | Ação |
|---|---|
| `SPC s s` | Buscar linha no buffer atual |
| `SPC s i` | Navegar por símbolos do arquivo (imenu) |
| `SPC s p` | Buscar texto no projeto (ripgrep) |
| `SPC s f` | Buscar arquivo por nome (fd) |

### Projeto (`SPC p`)

| Tecla | Ação |
|---|---|
| `SPC p p` | Trocar de projeto |
| `SPC p f` | Abrir arquivo do projeto |
| `SPC p b` | Buffers do projeto |

### Git (`SPC g`)

| Tecla | Ação |
|---|---|
| `SPC g g` | Status do git (Magit) |
| `SPC g b` | Blame do arquivo |
| `SPC g l` | Log da branch atual |

No Magit: `?` abre o menu com todas as teclas, `TAB` expande/recolhe, `s` / `u` fazem stage / unstage, `q` sai. As marcas de alteração na margem vêm do `diff-hl`.

### Código / LSP (`SPC c`)

| Tecla | Ação |
|---|---|
| `SPC c r` | Renomear símbolo |
| `SPC c a` | Ações de código (quick fixes) |
| `SPC c f` | Formatar o buffer agora |
| `SPC c o` | Organizar imports |
| `SPC c d` | Listar diagnósticos (erros e avisos) |
| `SPC c e` | Iniciar o eglot manualmente |

### Toggle (`SPC t`)

| Tecla | Ação |
|---|---|
| `SPC t t` | Trocar de tema (`doom-one`, gruvbox, catppuccin...) |
| `SPC t l` | Ligar/desligar números de linha |
| `SPC t .` | Mostrar/ocultar dotfiles (find-file, projetos e dired). `node_modules` fica sempre oculto |
| `M-.` (no prompt de arquivos) | Mostrar/ocultar dotfiles sem sair do prompt; a lista atualiza na hora |
| `g .` (no dired, modo normal) | Mostrar/ocultar dotfiles na pasta aberta |
| `SPC t r` | Ligar/desligar o `rass` (Tailwind junto com `ts_ls`/`astro-ls`) |

### Abrir (`SPC o`)

| Tecla | Ação |
|---|---|
| `SPC o t` | Terminal na raiz do projeto (eat) |
| `SPC o T` | Terminal comum (eat) |

### Ajuda e sair

| Tecla | Ação |
|---|---|
| `SPC h f` | Descrever uma função |
| `SPC h v` | Descrever uma variável |
| `SPC h k` | Descrever uma tecla |
| `SPC h m` | Descrever o modo atual |
| `SPC q q` | Sair do Emacs |

## Navegação de código (modo normal)

| Tecla | Ação |
|---|---|
| `gd` | Ir para a definição |
| `gr` | Ver referências |
| `K` | Mostrar a documentação do símbolo |
| `]d` / `[d` | Próximo / anterior erro (flymake) |

## Edição

| Tecla | Ação |
|---|---|
| `gcc` | Comentar/descomentar a linha |
| `gc{movimento}` | Comentar um trecho (ex.: `gcap` comenta o parágrafo) |
| `gc` (modo visual) | Comentar a seleção |
| `ys{movimento}{char}` | Envolver com um par (ex.: `ysiw"` coloca aspas na palavra) |
| `cs{antigo}{novo}` | Trocar o par (ex.: `cs"'` troca `"` por `'`) |
| `ds{char}` | Remover o par (ex.: `ds"`) |
| `S{char}` (modo visual) | Envolver a seleção com um par |

Os pares `()`, `[]`, `{}` e `""` fecham sozinhos (`electric-pair`).

## Completion

| Tecla | Ação |
|---|---|
| `C-n` / `C-p` | Próximo / anterior candidato (minibuffer e popup) |
| `RET` | Confirmar o candidato |
| `C-g` | Cancelar |
| `C-.` | Ações sobre o candidato ou item sob o cursor (embark) |
| `C-;` | Ação padrão para o item sob o cursor (embark dwim) |

O popup do código aparece sozinho enquanto você digita (com ícones e documentação ao lado). Os candidatos aceitam várias palavras em qualquer ordem (`orderless`): digitar `ts app` acha `app.ts`.

## Formatação

A formatação roda ao salvar (apheleia), sem mover o cursor.

**Projeto primeiro, global como reserva:** para `prettier`, o Emacs usa o que estiver em `node_modules` do projeto. Se o projeto não tiver (ou, em arquivos Astro, se faltar o `prettier` ou o `prettier-plugin-astro`), usa o `prettier` global instalado pelo `install-deps.sh`. Os demais formatadores (`shfmt`, `stylua`, `taplo`, `yamlfmt`) já são globais.

| Linguagem | Formatador |
|---|---|
| JS, TS, TSX, JSON | `prettier` |
| Astro | `prettier` + `prettier-plugin-astro` |
| Bash | `shfmt` |
| Lua | `stylua` |
| TOML | `taplo` |
| YAML | `yamlfmt` |

Para Astro, crie um `.prettierrc` no projeto:

```json
{
  "plugins": ["prettier-plugin-astro"],
  "overrides": [{ "files": "*.astro", "options": { "parser": "astro" } }]
}
```

## Comandos úteis (`M-x`)

| Comando | Para quê |
|---|---|
| `my/treesit-install-all` | Instalar as gramáticas tree-sitter que faltam |
| `my/toggle-rass` | Ligar/desligar o Tailwind via `rass` (também em `SPC t r`) |
| `eglot-reconnect` | Reiniciar a conexão com o LSP |
| `eglot-events-buffer` | Ver a conversa com o servidor LSP (depuração) |
| `nerd-icons-install-fonts` | Baixar a fonte dos ícones |
| `my/tsdk` (via `M-:`) | Ver qual TypeScript o `astro-ls` está usando |

## Pacotes usados

Os links são de memória (só o do `dashboard` e o manual do `eglot` foram conferidos); se algum não abrir, procure o nome em melpa.org.

### Pacotes do Emacs (instalados pelo `package.el`)

| Pacote | URL | Função |
|---|---|---|
| `no-littering` | https://github.com/emacscollective/no-littering | Move os arquivos de uso do `~/.emacs.d` para `var/` e `etc/` |
| `exec-path-from-shell` | https://github.com/purcell/exec-path-from-shell | Copia o `PATH` do shell para o Emacs |
| `dashboard` | https://github.com/emacs-dashboard/emacs-dashboard | Tela inicial com arquivos e projetos recentes |
| `doom-themes` | https://github.com/doomemacs/themes | Coleção de temas (`doom-one` e outros) |
| `catppuccin-theme` | https://github.com/catppuccin/emacs | Tema Catppuccin |
| `gruvbox-theme` | https://github.com/greduan/emacs-theme-gruvbox | Tema Gruvbox |
| `doom-modeline` | https://github.com/seagle0128/doom-modeline | Barra de status com ícones |
| `nerd-icons` | https://github.com/rainstormstudio/nerd-icons.el | Biblioteca de ícones (fonte Nerd) |
| `nerd-icons-completion` | https://github.com/rainstormstudio/nerd-icons-completion | Ícones nos candidatos do minibuffer |
| `nerd-icons-corfu` | https://github.com/LuigiPiucco/nerd-icons-corfu | Ícones no popup de completion de código |
| `nerd-icons-dired` | https://github.com/rainstormstudio/nerd-icons-dired | Ícones por tipo de arquivo no dired |
| `vertico` | https://github.com/minad/vertico | Lista vertical de candidatos no minibuffer (inclui `vertico-multiform`) |
| `orderless` | https://github.com/oantolin/orderless | Filtra candidatos por várias palavras, em qualquer ordem |
| `marginalia` | https://github.com/minad/marginalia | Anotações ao lado dos candidatos |
| `consult` | https://github.com/minad/consult | Buscas e navegação (`ripgrep`, `fd`, buffers, imenu, temas) |
| `embark` | https://github.com/oantolin/embark | Menu de ações sobre o item sob o cursor |
| `embark-consult` | https://github.com/oantolin/embark | Integração do Embark com o Consult |
| `corfu` | https://github.com/minad/corfu | Popup de completion enquanto você digita (inclui `corfu-popupinfo`) |
| `cape` | https://github.com/minad/cape | Fontes extras de completion (arquivos e palavras) |
| `evil` | https://github.com/emacs-evil/evil | Teclas do Vim |
| `evil-collection` | https://github.com/emacs-evil/evil-collection | Teclas do Vim em dired, Magit, help etc. |
| `evil-commentary` | https://github.com/linktohack/evil-commentary | Comentar com `gcc` e `gc{movimento}` |
| `evil-surround` | https://github.com/emacs-evil/evil-surround | Pares ao redor do texto (`ys`, `cs`, `ds`) |
| `astro-ts-mode` | https://github.com/Sorixelle/astro-ts-mode | Modo para arquivos `.astro` (tree-sitter) |
| `apheleia` | https://github.com/radian-software/apheleia | Formata o arquivo ao salvar, sem mover o cursor |
| `magit` | https://github.com/magit/magit | Interface completa de git |
| `diff-hl` | https://github.com/dgutov/diff-hl | Marcas de alteração na margem |
| `eat` | https://codeberg.org/akib/emacs-eat | Terminal dentro do Emacs (sem compilar nada) |

### Embutidos no Emacs (não instalam nada)

| Recurso | Função |
|---|---|
| `use-package` | Declarar e carregar os pacotes |
| `eglot` | Cliente LSP (manual: https://www.gnu.org/software/emacs/manual/html_mono/eglot.html) |
| `flymake` e `eldoc` | Diagnósticos de erros e documentação rápida |
| `which-key` | Mostra as teclas disponíveis depois do `SPC` |
| `project.el` | Detecta e troca de projetos |
| `treesit` | Realce e análise de código com tree-sitter |
| `dired` e `dired-x` | Gerenciador de arquivos (e ocultar dotfiles e `node_modules`) |
| `recentf`, `savehist`, `saveplace` | Lembram arquivos recentes, histórico do minibuffer e posição nos arquivos |
| `editorconfig`, `electric-pair`, `so-long`, `repeat-mode` | Respeitar `.editorconfig`, fechar pares, proteger contra linhas gigantes, repetir comandos |

### Ferramentas externas (instaladas pelo `install-deps.sh`)

| Ferramenta | URL | Função |
|---|---|---|
| `nvm` | https://github.com/nvm-sh/nvm | Instala e gerencia o Node.js |
| `typescript` (6.x) | https://github.com/microsoft/TypeScript | Compilador, exigido pelo `astro-ls` e pelo `ts_ls` |
| `@astrojs/language-server` | https://github.com/withastro/language-tools | LSP do Astro (`astro-ls`) |
| `typescript-language-server` | https://github.com/typescript-language-server/typescript-language-server | LSP de JS/TS/TSX |
| `bash-language-server` | https://github.com/bash-lsp/bash-language-server | LSP de Bash |
| `vscode-langservers-extracted` | https://github.com/hrsh7th/vscode-langservers-extracted | Traz o LSP de JSON (`vscode-json-language-server`) |
| `@tailwindcss/language-server` | https://github.com/tailwindlabs/tailwindcss-intellisense | LSP do Tailwind |
| `lua-language-server` | https://github.com/LuaLS/lua-language-server | LSP de Lua |
| `prettier` + `prettier-plugin-astro` | https://github.com/prettier/prettier e https://github.com/withastro/prettier-plugin-astro | Formata JS/TS/JSON e Astro |
| `shfmt` | https://github.com/mvdan/sh | Formata Bash |
| `stylua` | https://github.com/JohnnyMorganz/StyLua | Formata Lua |
| `taplo` | https://github.com/tamasfe/taplo | Formata TOML |
| `yamlfmt` | https://github.com/google/yamlfmt | Formata YAML |
| `ripgrep` (`rg`) | https://github.com/BurntSushi/ripgrep | Busca de texto rápida (`SPC /`) |
| `fd` | https://github.com/sharkdp/fd | Busca de arquivos rápida (`SPC s f`) |
| `coreutils` | https://www.gnu.org/software/coreutils/ | Fornece o `gls`, usado pelo dired |
| `git` | https://git-scm.com | Controle de versão (Magit e projetos) |
| MacPorts | https://www.macports.org | Instala as ferramentas nativas acima |
| `rass` (opcional) | https://github.com/joaotavora/rassumfrassum | Multiplexa servidores LSP (Tailwind junto com `ts_ls`/`astro-ls`), só com `--with-rass` |

As gramáticas tree-sitter (bash, astro, typescript etc.) vêm dos repositórios listados no `treesit-language-source-alist` do `init.el`.

## Problemas comuns

- **`astro-ls` não acha o TypeScript:** o projeto precisa de um `node_modules/typescript/lib` com `typescript.js`. Rode `npm install` (ou `npm i -D typescript@6`) e depois `M-x eglot-reconnect`. Se o do projeto não servir, o Emacs usa o TypeScript global e avisa no `*Messages*`.
- **Binário não encontrado (LSP ou formatador):** rode `bash install-deps.sh --check`, reabra o terminal e reinicie o Emacs (ele lê o `PATH` do seu shell de login).
- **Se você mudar a versão padrão do Node pelo nvm:** rode `bash install-deps.sh` de novo para atualizar o symlink `~/.nvm/current`.
- **Ícones como quadrados:** `M-x nerd-icons-install-fonts` e reinicie o Emacs.
