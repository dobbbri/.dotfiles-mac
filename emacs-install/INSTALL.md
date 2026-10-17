# Guia de instalação — Emacs-Kick (revisado)

Este guia instala a configuração composta por `init.el` e `early-init.el`, com suporte a TypeScript, JavaScript, Astro, JSON, YAML, TOML e shell (shellcheck e shfmt). Ela foi escrita para o **Emacs 30.1 ou superior** e também roda no Emacs 31 (há um shim de compatibilidade para a função `treesit-ready-p`, removida nessa versão). Tempo estimado: 15 a 30 minutos, a maior parte no primeiro boot, quando o straight.el baixa e compila os pacotes.

## Instalação automática (opcional)

O arquivo `install.sh` faz os passos das seções 1, 3 e 2.2 de uma vez: instala os pacotes do sistema (MacPorts, Homebrew, apt, dnf ou pacman), o nvm com Node.js LTS, os pacotes npm globais, a fonte JetBrainsMono Nerd Font e copia o `init.el` e o `early-init.el` para `~/.emacs.d` (com backup se já existirem). Coloque o script na mesma pasta dos dois arquivos de config e rode:

```sh
bash install.sh --dry-run     # só mostra o que seria feito
bash install.sh               # executa
bash install.sh --help        # opções (--pm, --with-emacs, --no-node, --no-fonts, --no-config...)
```

Depois, siga a seção 2.3 em diante (primeiro boot e `M-x ek/first-install`). O script não instala o Biome, que é por projeto (seção 3.3).

## 1. Pré-requisitos

### 1.1 Emacs 30.1+ com tree-sitter

Confira a versão e os recursos:

```sh
emacs --version
emacs --batch --eval '(message "treesit: %s | native-comp: %s" (treesit-available-p) (native-comp-available-p))'
```

O resultado esperado é `treesit: t`. Se `native-comp` for `nil`, a config funciona, mas mais devagar.

Formas comuns de instalar (a disponibilidade de versão varia por distribuição, então sempre confira com `emacs --version`; no MacPorts, veja a versão disponível com `port info emacs-app`):

| Sistema | Comando |
|---|---|
| macOS (Homebrew) | `brew install emacs-plus@30` (tap `d12frosted/emacs-plus`) ou `brew install --cask emacs` |
| macOS (MacPorts) | `sudo port install emacs-app` (GUI) ou `sudo port install emacs` (só terminal) |
| Arch Linux | `sudo pacman -S emacs` |
| Fedora | `sudo dnf install emacs` |
| Ubuntu/Debian | `sudo snap install emacs --classic` (ou compile da fonte, se o repositório tiver versão antiga) |
| Nix | `nix-shell -p emacs30` |

### 1.2 Ferramentas básicas

O straight.el precisa de `git` e `curl`. As grammars do tree-sitter são compiladas na instalação, então você também precisa de um compilador C (`gcc` ou `clang`) e do `make`.

```sh
# Debian/Ubuntu
sudo apt install git curl build-essential ripgrep fd-find
# macOS (Homebrew)
xcode-select --install && brew install git curl ripgrep fd
# macOS (MacPorts)
xcode-select --install && sudo port install git curl ripgrep fd
# Arch
sudo pacman -S git curl base-devel ripgrep fd
```

O `ripgrep` é usado pelo `consult-ripgrep` (`<leader> s r`).

### 1.3 Fonte (apenas para uso gráfico)

A config usa a fonte **JetBrainsMono Nerd Font** na interface gráfica. No terminal, use essa fonte no próprio emulador de terminal.

```sh
# macOS (Homebrew)
brew install --cask font-jetbrains-mono-nerd-font
# macOS (MacPorts): só existe a fonte de SÍMBOLOS (ícones), não a família completa
sudo port install ttf-nerd-fonts-symbols
```

**MacPorts:** o port `ttf-nerd-fonts-symbols` instala apenas os glifos de ícones (a fonte "Symbols Nerd Font Mono"). Isso já basta para os ícones do Emacs, desde que o texto use outra fonte. Para ter também a fonte de código, baixe **JetBrainsMono Nerd Font** em nerdfonts.com e instale pelo Font Book, ou instale a "JetBrains Mono" normal. O `init.el` usa `JetBrainsMono Nerd Font` se existir; senão, `JetBrains Mono`; senão, a fonte padrão do sistema. Em qualquer caso o `M-x ek/first-install` também instala os símbolos via `nerd-icons`.

No Linux, baixe em nerdfonts.com e copie para `~/.local/share/fonts`, depois rode `fc-cache -fv`. Se não quiser ícones, ponha `(defcustom ek-use-nerd-fonts nil ...)` no `init.el`.

### 1.4 Clipboard no terminal

Para copiar e colar entre o Emacs em terminal e o sistema: `xclip` (X11) ou `wl-clipboard` (Wayland).

### 1.5a Emacs x86_64 em Mac Apple Silicon

Se o caminho do seu Emacs contém `lib-x86_64` (por exemplo `/Applications/Emacs.app/Contents/MacOS/lib-x86_64-11`), ele é um build Intel. Em um Mac Apple Silicon ele roda via Rosetta, e as grammars compiladas pelo compilador nativo (arm64) podem não carregar (erro de arquitetura incompatível). Confira com `uname -m` e `file /Applications/Emacs.app/Contents/MacOS/Emacs`; se forem diferentes, prefira instalar um Emacs arm64 (MacPorts `emacs-app` ou Homebrew `emacs-plus@30`).

### 1.5 PATH no macOS (Homebrew e MacPorts)

O Emacs gráfico no macOS não herda o PATH do seu shell. Por isso binários instalados em `/opt/local/bin` (MacPorts) ou `/opt/homebrew/bin` (Homebrew) podem não ser encontrados pelo LSP e pelos formatadores. O `init.el` já inclui o pacote `exec-path-from-shell`, que importa o PATH do shell ao iniciar. Ele roda o shell em modo login **e interativo** (`-l -i`), o que é necessário para o `nvm`: o nvm é carregado pelo `~/.zshrc`, que um shell não interativo não lê. Se o Emacs demorar um pouco para abrir ou mostrar mensagens do shell, é por causa disso. Confira se o seu `~/.zprofile` ou `~/.zshrc` inclui o diretório do gerenciador, por exemplo `export PATH=/opt/local/bin:/opt/local/sbin:$PATH` para o MacPorts.

## 2. Instalar a configuração

### 2.1 Faça backup do que já existe

O Emacs lê `~/.emacs.d` ou `~/.config/emacs`. Salve o que houver:

```sh
[ -d ~/.emacs.d ] && mv ~/.emacs.d ~/.emacs.d.bak
[ -d ~/.config/emacs ] && mv ~/.config/emacs ~/.config/emacs.bak
[ -f ~/.emacs ] && mv ~/.emacs ~/.emacs.bak
```

### 2.2 Copie os arquivos

```sh
mkdir -p ~/.emacs.d
cp init.el early-init.el ~/.emacs.d/
```

Os dois arquivos precisam estar no mesmo diretório. Para o Emacs gráfico **não** abrir maximizado, mude `ek-start-maximized` para `nil` no `early-init.el` (a opção não tem efeito no terminal). O `early-init.el` roda antes da interface e desativa o package.el, ajusta o GC e define `LSP_USE_PLISTS`.

### 2.3 Primeiro boot

```sh
emacs
```

O straight.el vai clonar e compilar dezenas de pacotes. Isso pode levar vários minutos e a tela pode parecer parada. Se algo falhar, abra o buffer `*Messages*` (`<leader> SPC` e digite `Messages`, ou `C-h e`). Quando terminar, feche o Emacs com `:q`.

### 2.4 Instalador (grammars e fontes)

Abra o Emacs novamente e execute:

```
M-x ek/first-install RET
```

Isso instala as grammars do tree-sitter, as grammars do Astro (astro, css e tsx) e as fontes de ícones. Ao terminar, aperte uma tecla: o Emacs fecha sozinho. Na próxima abertura tudo estará pronto.

## 3. Ferramentas externas

Os servidores de linguagem e formatadores ficam **fora** do Emacs. Instale o que for usar.

### 3.1 Node.js

Instale o Node.js via **nvm** (Node Version Manager), que funciona igual no macOS e no Linux e permite versões diferentes por projeto:

```sh
# 1. instale o nvm (confira a versão atual do script em github.com/nvm-sh/nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# 2. abra um novo terminal (ou: source ~/.zshrc) e instale o Node LTS
nvm install --lts
nvm alias default 'lts/*'

# 3. confira
node -v && npm -v
```

O instalador do nvm adiciona as linhas de inicialização ao `~/.zshrc` (ou `~/.bashrc`). O `alias default` é importante: é a versão que o Emacs enxerga. Projetos com `.nvmrc` podem usar `nvm use` no terminal, mas o Emacs usa sempre a versão padrão (para outra versão por projeto, abra o Emacs a partir do terminal depois de `nvm use`).

### 3.2 Pacotes globais

```sh
npm i -g typescript prettier prettier-plugin-astro @astrojs/language-server
```

Os servidores de TypeScript/JavaScript, JSON e YAML são oferecidos para download pelo próprio lsp-mode na primeira vez que você abrir um arquivo de cada tipo (aceite o prompt). Se preferir instalar manualmente:

```sh
npm i -g typescript-language-server vscode-langservers-extracted yaml-language-server
```

### 3.3 Biome (por projeto)

```sh
npm i -D --save-exact @biomejs/biome
npx biome init
```

O Biome formata com **tabs** por padrão. Se o projeto usa espaços, edite o `biome.json`:

```json
{ "formatter": { "indentStyle": "space" } }
```

O suporte a LSP do Biome vem do pacote **lsp-biome** ([cxa/lsp-biome](https://github.com/cxa/lsp-biome)), instalado automaticamente pelo straight. Ele só ativa em projetos que tenham `biome.json` ou `biome.jsonc` **e** onde o `biome` seja encontrado (instalação local em `node_modules/@biomejs/biome` ou, na falta dela, o do PATH). Roda junto do servidor de TypeScript (modo add-on), sem substituí-lo, e ativa em arquivos `js`, `jsx`, `ts`, `tsx`, `mts`, `mjs`, `cts`, `cjs`, `json`, `jsonc` e `css`. Comandos extras: `<leader> c o` (organize imports) e `<leader> c x` (aplicar todos os fixes). Para formatar use `<leader> m f`, que passa pelo Biome; o `<leader> l f` (formatação via LSP) pode usar o formatador do TypeScript.

A config só usa o Biome para **formatar** em projetos que tenham `biome.json` ou `biome.jsonc`. Sem ele, usa Prettier se encontrar um `.prettierrc*` ou `prettier.config.*`; se não houver nenhum dos dois, não formata nada ao salvar.

### 3.4 Astro

Para formatar `.astro`, o projeto precisa de `prettier-plugin-astro` e de um `.prettierrc` com:

```json
{ "plugins": ["prettier-plugin-astro"] }
```

### 3.5 TOML (Taplo)

```sh
# macOS (MacPorts)
sudo port install taplo
# qualquer sistema, via Rust ou npm
cargo install taplo-cli --locked
# ou: npm i -g @taplo/cli
```

### 3.6 Shell (shellcheck e shfmt)

```sh
# Debian/Ubuntu
sudo apt install shellcheck shfmt
# macOS (Homebrew)
brew install shellcheck shfmt
# macOS (MacPorts)
sudo port install shellcheck shfmt
# Arch
sudo pacman -S shellcheck shfmt
```

O shellcheck aparece como diagnóstico do flymake. Para seguir `source` entre arquivos, crie um `.shellcheckrc` com `external-sources=true`.

### 3.7 Opcionais

`multimarkdown` (preview de Markdown), `feh` e `mpv` (abrir imagens e mídia pelo Dired).

## 4. Verificação

Abra um arquivo de cada tipo e confira:

| Arquivo | O que esperar |
|---|---|
| `.ts` / `.tsx` / `.js` | Modeline mostra LSP; `K` mostra documentação; `gr` acha referências |
| `.ts` em projeto com `biome.json` | Diagnósticos do Biome junto com os do TypeScript; `<leader> c a` oferece organize imports |
| `.json` / `.jsonc` | Realce via tree-sitter; LSP de JSON ativo |
| `.yaml` | LSP de YAML ativo; formata com Prettier ao salvar (se houver `.prettierrc*`) |
| `.toml` | Taplo ativo; formata ao salvar |
| `.astro` | `astro-ts-mode` e LSP do Astro ativos |
| `.sh` | Avisos do shellcheck na margem; shfmt ao salvar |

Se uma linguagem não funcionar, use `M-x lsp-doctor` e olhe o buffer `*lsp-log*` ou `*Messages*`.

## 5. Atalhos principais (leader = `SPC`)

| Atalho | Ação |
|---|---|
| `<leader> SPC` | Trocar de buffer |
| `<leader> p f` / `p p` | Achar arquivo no projeto / trocar de projeto |
| `<leader> s r` / `/` | Ripgrep / buscar na linha |
| `<leader> g g` | Magit |
| `<leader> e e` | Árvore de arquivos |
| `<leader> m f` | Formatar buffer |
| `<leader> m c` | `biome check --write` no arquivo |
| `<leader> c o` / `c x` | Biome: organize imports / aplicar fixes (via lsp-biome) |
| `<leader> t m` | Alternar janela maximizada (GUI) |
| `<leader> t f` | Alternar tela cheia (GUI) |
| `<leader> l f` | Formatar via LSP |
| `<leader> r n` | Renomear símbolo |
| `<leader> x x` | Lista de diagnósticos |
| `<leader> .` | Embark (ações contextuais) |

## 6. Solução de problemas

- **`Could not find package window` (ou `dired`, `org`, `eldoc`…):** pacote built-in sendo buscado pelo straight. Em `use-package`, built-ins devem usar `:straight nil` (a versão 0.7.1 do `init.el` já corrige isso).
- **Descobrir qual erro aborta o `init.el`:** feche o Emacs e rode `emacs --debug-init` no terminal. O backtrace mostra o pacote ou a linha que falha. Sem corrigir isso, partes da config (inclusive pacotes) deixam de ser instaladas.
- **`ek/first-install` com "No such file or directory" ao carregar `treesit-auto`:** o pacote ainda não foi instalado porque o boot anterior abortou. A função agora instala o que falta; rode-a de novo e leia as linhas `>>> ERRO` / `>>> AVISO` no `*Messages*` (`git` e `cc` precisam estar no PATH).
- **`void-function treesit-ready-p`:** você está no Emacs 31 e algum pacote usa a função removida. A versão 0.7.2 ou superior do `init.el` inclui o shim; atualize o arquivo.
- **Erro no primeiro boot:** apague `~/.emacs.d/straight/` e abra o Emacs de novo para refazer a instalação.
- **Avisos `Cannot load language definition` / `libtree-sitter-typescript.so (no such file)` ao abrir arquivos ou no boot:** as grammars do tree-sitter ainda não foram instaladas em `~/.emacs.d/tree-sitter/`. Rode `M-x ek/first-install RET` e, no fim, leia a linha `>>> Todas as grammars necessárias estão instaladas` ou `>>> AVISO: grammars ainda ausentes: ...`. O `astro-ts-mode` precisa das grammars tsx e css para carregar, então elas são instaladas antes das do Astro (a versão 0.9.4 do `init.el` também não carrega mais o `astro-ts-mode` no boot, o que evitava o erro `astro-ts-mode/:catch`).
- **Aviso `language grammar for astro failed to load (not-found)`:** a grammar do Astro não está instalada. Rode `M-x astro-ts-mode-install-grammars RET` (instala astro, css e tsx). Na versão 0.9.1 do `init.el`, abrir um `.astro` sem a grammar oferece instalá-la na hora. A instalação precisa de `git` e de compilador C: no macOS, `xcode-select --install`.
- **Grammars não compilam:** confira se há compilador C (`gcc --version`) e rode `M-x ek/first-install` novamente.
- **LSP lento ou com comportamento estranho após mudar o `early-init.el`:** apague `~/.emacs.d/straight/build/lsp-mode` e reinicie (o `LSP_USE_PLISTS` precisa estar definido na hora da compilação).
- **Formatação não acontece:** `M-x apheleia-format-buffer` mostra qual formatador está sendo usado e o erro, se houver. Verifique se o binário (`biome`, `prettier`, `shfmt`, `taplo`) está no PATH, ou em `node_modules/.bin` do projeto.
- **Binário instalado pelo MacPorts/Homebrew não é encontrado (biome, prettier, shfmt…):** no Emacs gráfico, rode `M-x getenv RET PATH RET` e confira se `/opt/local/bin` (MacPorts) ou `/opt/homebrew/bin` (Homebrew) aparece. Se não aparecer, ajuste o PATH no `~/.zprofile` e reinicie o Emacs.
- **`node`, `npm` ou servidores de linguagem não encontrados (nvm):** confirme que `nvm alias default 'lts/*'` foi feito e que o carregamento do nvm está no `~/.zshrc`. No Emacs, `M-x getenv RET PATH RET` deve conter `~/.nvm/versions/node/...`. Depois reinicie o Emacs por completo.
- **Nada de ícones:** instale a fonte Nerd Font e reinicie, ou defina `ek-use-nerd-fonts` como `nil`.
- **Taplo não formata:** os argumentos do comando seguem a documentação do Taplo, mas versões diferentes podem divergir; confira `taplo format --help`.
- **Astro sem diagnósticos de tipos:** confirme que `typescript` está em `node_modules` do projeto ou instalado globalmente (o `astro-ls` precisa do caminho `typescript/lib`).

## 7. Manutenção

```
M-x straight-pull-all          ; atualizar todos os pacotes
M-x straight-freeze-versions   ; gravar versões em straight/versions/default.el
M-x straight-thaw-versions     ; restaurar as versões gravadas
```

Versione `init.el`, `early-init.el` e `straight/versions/default.el` no Git para reproduzir a mesma configuração em outra máquina. Customizações feitas pela interface (`M-x customize`) ficam em `custom-vars.el`, que é carregado por último no `init.el` para não ser sobrescrito pelos valores dos pacotes. O histórico do minibuffer, o kill-ring e as buscas são salvos entre sessões pelo `savehist`.
