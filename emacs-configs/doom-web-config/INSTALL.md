# Guia de instalação — Doom Emacs para desenvolvimento web

Stack: Node, JSON, Biome, Shell, Astro, JS/TS, Tailwind, Prettier e ESLint.

Conteúdo do pacote: `doom/init.el`, `doom/config.el`, `doom/packages.el` e este guia.
Descompacte com `unzip doom-web-config.zip && cd doom-web-config`.

---

## 1. Pré-requisitos

Precisa de **Emacs 29 ou superior** (com tree-sitter), além de `git`, `ripgrep`, `fd` e um compilador C (para as gramáticas tree-sitter).

Confira a versão e o suporte a tree-sitter:

```sh
emacs --version
emacs --batch --eval '(message "%s" (treesit-available-p))'   # deve imprimir t
```

### Ubuntu / Debian
```sh
sudo apt update
sudo apt install -y emacs git ripgrep fd-find build-essential cmake libtool libtool-bin
# no Debian/Ubuntu o fd se chama fdfind:
mkdir -p ~/.local/bin && ln -sf "$(which fdfind)" ~/.local/bin/fd
```
Se o `emacs` do repositório for anterior à versão 29, use o PPA `ppa:ubuntuhandbook1/emacs` ou o Snap (`sudo snap install emacs --classic`).

### Arch
```sh
sudo pacman -S emacs git ripgrep fd base-devel cmake
```

### Fedora
```sh
sudo dnf install emacs git ripgrep fd-find @development-tools cmake
```

### macOS (Homebrew)
```sh
brew install git ripgrep fd cmake coreutils
brew tap d12frosted/emacs-plus
brew install emacs-plus@30 --with-native-comp
```

### Windows
Use o **WSL2** com Ubuntu e siga os passos de Ubuntu acima.

---

## 2. Node.js e ferramentas web

Instale o Node com um gerenciador de versões (exemplo com `fnm`):

```sh
curl -fsSL https://fnm.vercel.app/install | bash
fnm install --lts
```

Servidores de linguagem e ferramentas (globais):

```sh
npm i -g \
  typescript typescript-language-server \
  vscode-langservers-extracted \
  @astrojs/language-server \
  @tailwindcss/language-server \
  bash-language-server \
  prettier @biomejs/biome eslint
```

O pacote `vscode-langservers-extracted` traz HTML, CSS, JSON e ESLint.

### Shell
```sh
# shellcheck (lint) e shfmt (formatação) para scripts
sudo apt install -y shellcheck shfmt     # Ubuntu/Debian
brew install shellcheck shfmt            # macOS
```

### rass (Tailwind junto com TypeScript)
O Eglot usa um servidor por buffer. O `rass` combina vários:

```sh
pipx install rassumfrassum
```
É opcional. Sem ele, o Tailwind LSP não roda junto com o de TS, mas o resto funciona.

### direnv (opcional, recomendado)
```sh
sudo apt install -y direnv   # ou: brew install direnv
```

---

## 3. Instalar o Doom Emacs

Se você já tem uma config do Emacs, faça backup:

```sh
mv ~/.emacs.d ~/.emacs.d.bak 2>/dev/null
mv ~/.config/emacs ~/.config/emacs.bak 2>/dev/null
```

Clone e instale:

```sh
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

Adicione o `doom` ao PATH (bash/zsh):

```sh
echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ~/.bashrc   # ou ~/.zshrc
source ~/.bashrc
```

---

## 4. Copiar a configuração

```sh
mkdir -p ~/.config/doom
cp doom/init.el doom/config.el doom/packages.el ~/.config/doom/
```

Edite `~/.config/doom/config.el` e troque `user-full-name`, `user-mail-address` e a fonte se necessário.

Depois sincronize:

```sh
doom sync
doom doctor      # mostra o que está faltando
```

---

## 5. Fontes e ícones

Dentro do Emacs:

```
M-x nerd-icons-install-fonts
```

Instale também a fonte **JetBrains Mono**:

```sh
sudo apt install -y fonts-jetbrains-mono   # Ubuntu/Debian
brew install --cask font-jetbrains-mono    # macOS
```

---

## 6. Gramáticas tree-sitter

Abra o Emacs (`emacs`) e execute:

```
M-x astro-ts-mode-ensure
M-x treesit-install-language-grammar
```

Rode o segundo comando para cada linguagem: `typescript`, `tsx`, `javascript`, `json`, `css`, `html`, `bash`, `yaml`.

---

## 7. Teste rápido

Crie um projeto de exemplo e abra no Emacs:

```sh
npm create astro@latest meu-site
cd meu-site && npm i -D eslint prettier prettier-plugin-astro prettier-plugin-tailwindcss
emacs src/pages/index.astro
```

Verifique:

| O que testar | Como |
|---|---|
| Menu which-key | Aperte `SPC` e espere |
| LSP ativo | `M-x eglot` (deve conectar ao `astro-ls`) |
| Erros e avisos | `SPC c x` |
| Formatação | `SPC c f` ou salvar o arquivo |
| ESLint --fix | `SPC c F` |
| Scripts npm | `SPC o n` |
| Terminal | `SPC o t` |
| Git | `SPC g g` |

---

## 8. Dia a dia

```sh
doom sync       # depois de mudar init.el ou packages.el
doom upgrade    # atualiza o Doom e os pacotes
doom doctor     # diagnóstico
doom build      # recompila se algo quebrar após atualizar o Emacs
```

Dentro do Emacs, `SPC h r r` recarrega a config e `SPC h d m` abre a documentação de um módulo.

---

## 9. Problemas comuns

**`doom: command not found`**
O shell não encontra o executável do Doom. Há duas causas possíveis.

1. O Doom ainda não foi clonado. Confira com `ls ~/.config/emacs/bin/doom`. Se der "No such file", rode:
   ```sh
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
   ~/.config/emacs/bin/doom install
   ```
2. O Doom existe, mas não está no PATH. Teste com o caminho completo (`~/.config/emacs/bin/doom sync`). Se funcionar, adicione ao PATH de forma permanente, no arquivo do seu shell:
   ```sh
   # zsh (padrão no macOS)
   echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

   # bash
   echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

   # fish
   fish_add_path ~/.config/emacs/bin
   ```
   Confirme com `which doom` e `doom --version`.

Se você instalou o Doom em `~/.emacs.d` (versões antigas), use `~/.emacs.d/bin` no lugar de `~/.config/emacs/bin`.

**`doom sync` reclama de `(syntax +flymake)`**
Sua versão do Doom é mais antiga. Troque por `syntax` no `init.el` e use o checker `javascript-eslint` do flycheck no lugar do `flymake-eslint`.

**Erros do tipo "grammar not available"**
Falta a gramática tree-sitter. Rode `M-x treesit-install-language-grammar` para a linguagem indicada. Precisa de `gcc` e `git` instalados.

**Eglot não acha o servidor (`typescript-language-server` etc.)**
O Emacs não está vendo o PATH do Node. Use o módulo `direnv`, ou rode `doom env` para regenerar as variáveis de ambiente e reinicie.

**Ícones quadrados**
Execute `M-x nerd-icons-install-fonts` e reinicie o Emacs.

**Astro sem completions TypeScript**
O `astro-ls` precisa do `typescript` instalado localmente: `npm i -D typescript` no projeto.

**Formatador errado (Biome vs Prettier)**
Biome é escolhido só se existir `biome.json` ou `biome.jsonc` no projeto. Sem isso, usa Prettier.

**Atalho não funciona (`SPC c F`, `SPC o n`)**
Pode haver conflito na sua versão. Veja o menu do which-key em `SPC c` ou `SPC o` e mude no `map!` do `config.el`.
