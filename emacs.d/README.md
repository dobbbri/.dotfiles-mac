# Configuração do Emacs (macOS, Emacs 31)

Configuração com Evil (modo Vim), Vertico/Consult/Corfu, Eglot para TypeScript/Astro/CSS, Magit, Projectile e tree-sitter. Pensada para **Emacs 31.1** no macOS (binário Emacs for Mac OS X; as ferramentas de apoio vêm do MacPorts).

> **Versão do Emacs:** requer **Emacs 30.2 ou mais novo** (exigência do `eglot-typescript-preset`). O `emacs-mac-app` do MacPorts é o Emacs 29.4 e não atende; use o Emacs 31.1.

## Arquivos

| Arquivo | Onde fica | Função |
|---|---|---|
| `early-init.el` | `~/.emacs.d/early-init.el` | Roda antes dos pacotes: shim de `treesit-ready-p` e workaround do crash de fontes |
| `init.el` | `~/.emacs.d/init.el` | Configuração principal |

## Instalação

### 1. Ferramentas do sistema

```sh
xcode-select --install                      # compilador C (gramáticas tree-sitter)
sudo port install coreutils ripgrep git
```

Instale o Emacs 31.1 pelo binário "Emacs for Mac OS X" (emacsformacosx.com), copiando `Emacs.app` para `/Applications`. O `emacs-app` do MacPorts foi abandonado por causa dos crashes de desenho.

- `coreutils` fornece o `gls` (o `dired` usa `--group-directories-first`).
- `ripgrep` é usado por `SPC /` e `SPC p s` (`consult-ripgrep`).

### 2. Node e servidores de linguagem

Com node instalado via nvm (o `exec-path-from-shell` lê o PATH do `~/.zshrc`):

```sh
npm i -g typescript@6 typescript-language-server \
         @astrojs/language-server vscode-langservers-extracted
```

> **Importante:** use `typescript@6`. O TypeScript 7 não traz a API JS do compilador, da qual o `astro-ls` depende, e o servidor cai ao iniciar. Se o projeto Astro tiver TypeScript 7, instale nele: `npm i -D typescript@npm:@typescript/typescript6`.

### 3. Copiar os arquivos

```sh
mkdir -p ~/.emacs.d
cp early-init.el init.el ~/.emacs.d/
mkdir -p ~/Codes        # pasta varrida pelo Projectile
```

### 4. Primeira execução

1. Abra o Emacs. Os pacotes são baixados do MELPA automaticamente.
2. Instale as fontes de ícones: `M-x nerd-icons-install-fonts`.
3. Instale as gramáticas tree-sitter: `M-x treesit-auto-install-all` (ou aceite os prompts). Se o Astro falhar: `M-x treesit-install-language-grammar RET astro`.
4. Reinicie o Emacs (`Cmd+Q` e abra de novo).

### 5. Verificar

```
M-: (list (executable-find "node") (executable-find "astro-ls")) RET
M-: (mapcar #'treesit-language-available-p '(astro css tsx html)) RET   ; (t t t t)
```

## Personalização rápida

- **Fonte e tamanho:** `my/font-family` e `my/font-size` na seção 1.6 do `init.el`, ou `SPC t f` / `SPC t s` na sessão.
- **Pasta de projetos:** `projectile-project-search-path` (padrão `~/Codes`).
- **Tema:** `doom-one` (trocar em `load-theme`).

## Pacotes

Os URLs foram escritos de memória a partir dos repositórios mais conhecidos; confira em `M-x list-packages` se algum mudou.

### Embutidos no Emacs

| Pacote | URL | Descrição |
|---|---|---|
| use-package | https://github.com/jwiegley/use-package | Macro de configuração declarativa de pacotes |
| eglot | https://github.com/joaotavora/eglot | Cliente LSP (diagnósticos, completions, rename, code actions) |
| dired | https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html | Gerenciador de arquivos |
| which-key | https://github.com/justbur/emacs-which-key | Mostra as teclas disponíveis após um prefixo |
| recentf | https://www.gnu.org/software/emacs/manual/html_node/emacs/File-Conveniences.html | Lista de arquivos recentes (usada pelo `SPC f r`) |

### Do MELPA

| Pacote | URL | Descrição |
|---|---|---|
| evil | https://github.com/emacs-evil/evil | Modo Vim |
| evil-collection | https://github.com/emacs-evil/evil-collection | Keybindings Evil para dired, magit e outros modos |
| evil-commentary | https://github.com/linktohack/evil-commentary | Comentar com `gcc` / `gc{movimento}` |
| doom-themes | https://github.com/doomemacs/themes | Temas (usa `doom-one`) |
| doom-modeline | https://github.com/seagle0128/doom-modeline | Modeline moderna (ícones desligados por causa do crash de fontes no Cocoa) |
| nerd-icons | https://github.com/rainstormstudio/nerd-icons.el | Biblioteca de ícones Nerd Font |
| nerd-icons-dired | https://github.com/rainstormstudio/nerd-icons-dired | Ícones no dired |
| vertico | https://github.com/minad/vertico | Minibuffer de completion vertical |
| orderless | https://github.com/oantolin/orderless | Estilo de busca por termos em qualquer ordem |
| marginalia | https://github.com/minad/marginalia | Anotações (descrição, tamanho) nos candidatos |
| consult | https://github.com/minad/consult | Buscas e navegação (buffers, ripgrep, linhas, imenu) |
| corfu | https://github.com/minad/corfu | Popup de autocompletar |
| projectile | https://github.com/bbatsov/projectile | Gerenciamento de projetos |
| magit | https://github.com/magit/magit | Interface Git |
| treesit-auto | https://github.com/renzmann/treesit-auto | Instala gramáticas e ativa os modos `-ts-mode` |
| astro-ts-mode | https://github.com/Sorixelle/astro-ts-mode | Modo para arquivos `.astro` |
| eglot-typescript-preset | https://github.com/mwolson/eglot-typescript-preset | Presets do Eglot para TypeScript, Astro e CSS |
| exec-path-from-shell | https://github.com/purcell/exec-path-from-shell | Herda o PATH do shell (node/nvm) |

## Atalhos

Tecla líder: **`SPC`** (modo normal e motion). Ao apertar `SPC`, o which-key lista as opções.

### Acesso rápido

| Tecla | Ação |
|---|---|
| `SPC SPC` | `M-x` |
| `SPC .` | Abrir arquivo |
| `SPC ,` | Trocar de buffer |
| `SPC /` | Buscar no projeto (ripgrep) |
| `SPC d` | Dired |

### Arquivos (`SPC f`)

| Tecla | Ação |
|---|---|
| `f f` | Abrir arquivo |
| `f r` | Arquivos recentes |
| `f s` | Salvar |
| `f j` | Dired na pasta do arquivo |

### Buffers (`SPC b`)

| Tecla | Ação |
|---|---|
| `b b` | Trocar de buffer |
| `b k` | Fechar buffer atual |
| `b n` / `b p` | Próximo / anterior |
| `b r` | Recarregar do disco |

### Janelas (`SPC w`)

| Tecla | Ação |
|---|---|
| `w v` / `w s` | Dividir vertical / horizontal |
| `w d` | Fechar janela |
| `w o` | Manter só esta janela |
| `w w` | Próxima janela |
| `w h/j/k/l` | Mover para esquerda/baixo/cima/direita |

### Busca (`SPC s`)

| Tecla | Ação |
|---|---|
| `s s` | Buscar linha no buffer |
| `s i` | Símbolos do arquivo (imenu) |
| `s p` | Buscar no projeto |

### Projetos (`SPC p`)

| Tecla | Ação |
|---|---|
| `p p` | Trocar de projeto |
| `p f` | Abrir arquivo do projeto |
| `p s` | Buscar no projeto |

### Git (`SPC g`)

| Tecla | Ação |
|---|---|
| `g g` | Magit status |
| `g l` | Log |
| `g b` | Blame |
| `g c` | Commit |

### Código / LSP (`SPC c`)

| Tecla | Ação |
|---|---|
| `c r` | Renomear símbolo |
| `c a` | Code actions |
| `c f` | Formatar buffer |
| `c d` | Diagnósticos (flymake) |
| `c i` | Ir para implementação |

### UI e fonte (`SPC t`)

| Tecla | Ação |
|---|---|
| `t f` | Escolher fonte |
| `t s` | Tamanho da fonte |
| `t +` / `t -` / `t 0` | Zoom global (repete com `+`, `-`, `0`; `0` restaura) |
| `t l` | Liga/desliga números de linha |

### Ajuda e sair

| Tecla | Ação |
|---|---|
| `h k` / `h f` / `h v` / `h m` | Descrever tecla / função / variável / modo |
| `q q` | Sair do Emacs |
| `q r` | Reiniciar o Emacs |

### Fora do líder

| Tecla | Ação |
|---|---|
| `gcc` | Comentar/descomentar linha |
| `gc{movimento}` | Comentar trecho (ex.: `gcap`) |
| `gc` (visual) | Comentar seleção |
| `gd` | Ir para a definição (xref) |
| `g r` | Referências do símbolo |
| `K` | Documentação do símbolo (com Eglot ativo) |
| `]d` / `[d` | Próximo / anterior erro (flymake) |
| `ESC` | Sai de prompts, minibuffer e seleção |

## Problemas conhecidos

| Sintoma | Causa e solução |
|---|---|
| Emacs fecha com `SIGSEGV` em `fontset_font`, ou não abre mais | Bug do Cocoa no Emacs 31. O `early-init.el` limita `char-displayable-p` a ASCII e fixa `truncate-string-ellipsis`; sem isso o Emacs fechou ao iniciar. Os ícones da modeline ficam desligados (`doom-modeline-icon nil`) |
| Emacs fecha em `ns_scroll_run` / `-[EmacsView copyRect:to:]` (SIGABRT, `KERN_PROTECTION_FAILURE`) | Bug do desenho nativo (Cocoa) do Emacs 31 MacPorts, ao copiar pixels na rolagem. Não é erro de Lisp. Ocorreu com o MacPorts e com o Emacs for Mac OS X. Suspeitas: janela maximizada e popup do Corfu (child frame). Teste `M-x global-corfu-mode` desligado e reporte com `M-x report-emacs-bug` (relacionado ao bug#63107) |
| `void-function treesit-ready-p` | Removida no Emacs 31. O shim do `early-init.el` cobre pacotes antigos; `M-x package-update-all` também ajuda |
| `Tree-sitter grammar for Astro isn't available` | `M-x treesit-install-language-grammar RET astro` |
| Eglot reconecta em arquivos `.astro` | Verifique `typescript@6` (não 7), o PATH do node (`exec-path-from-shell`) e leia `M-x eglot-stderr-buffer` |
| `no file descriptor left` | O Eglot não observa arquivos no macOS (limite de descritores): os métodos `eglot-register-capability` no `init.el` aceitam o registro sem criar watchers |
| `--group-directories-first` não funciona | Instale `coreutils` (usa `gls`) |
