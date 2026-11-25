#!/usr/bin/env bash
# Instala o Emacs 31.1 (MacPorts) + a config vanilla em ~/.config/emacs, via GNU Stow.
# Use depois de remover o Doom (veja o README). Pode ser rodado de novo sem problemas.
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles-mac"
PKG_NAME="emacs-vanilla"                         # pacote do Stow
PKG_CONFIG_DIR="$DOTFILES_DIR/$PKG_NAME/.config/emacs"
TARGET="$HOME/.config/emacs"                     # onde o Emacs procura a config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Node.js via nvm (porta `nvm' do MacPorts). Versão principal desejada:
NODE_VERSION="22"
NVM_INIT="/opt/local/share/nvm/init-nvm.sh"

# Pacotes npm globais (LSPs, Biome) ficam em ~/.local, sem sudo.
NPM_PREFIX="$HOME/.local"
PATH_ORIGINAL="$PATH"
export PATH="${NPM_PREFIX}/bin:/opt/local/bin:/opt/local/sbin:${PATH}"

echo "=================================================================="
echo " Instalando Emacs 31.1 (MacPorts) + config vanilla (Stow, Astro & TW)"
echo "=================================================================="

# 0. Pré-requisitos
if ! xcode-select -p >/dev/null 2>&1; then
  echo "--> Instale as Xcode Command Line Tools primeiro: xcode-select --install"
  exit 1
fi

if ! command -v port >/dev/null 2>&1; then
  echo "--> MacPorts (port) não encontrado. Instale em https://www.macports.org/install.php e rode de novo."
  exit 1
fi

if [ ! -d "$PKG_CONFIG_DIR" ]; then
  echo "--> Pasta $PKG_CONFIG_DIR não encontrada."
  echo "    Copie early-init.el, init.el e a pasta lisp/ para lá."
  exit 1
fi

if [ ! -x "$SCRIPT_DIR/build-grammars.sh" ]; then
  echo "--> build-grammars.sh não encontrado (ou sem permissão de execução) em $SCRIPT_DIR."
  echo "    Copie-o para ao lado do install.sh e rode: chmod +x build-grammars.sh"
  exit 1
fi

for f in early-init.el init.el \
         lisp/init-package.el lisp/init-core.el lisp/init-ui.el lisp/init-evil.el \
         lisp/init-keys.el lisp/init-completion.el lisp/init-dired.el lisp/init-editor.el \
         lisp/init-treesit.el lisp/init-lsp.el lisp/init-biome.el lisp/init-langs.el \
         lisp/init-org.el; do
  if [ ! -f "$PKG_CONFIG_DIR/$f" ]; then
    echo "--> Faltando $PKG_CONFIG_DIR/$f"
    exit 1
  fi
done

# O Doom (ou uma config antiga) não pode estar no caminho: o Stow não sobrescreve.
if [ -e "$HOME/.emacs.d" ]; then
  echo "--> $HOME/.emacs.d existe e tem prioridade sobre ~/.config/emacs. Remova-o antes."
  exit 1
fi
if [ -e "$TARGET/bin/doom" ] || [ -d "$TARGET/.git" ]; then
  echo "--> O Doom ainda está em $TARGET. Remova-o antes (veja o README):"
  echo "      cd $DOTFILES_DIR && stow -D -t \"\$HOME\" doom-emacs"
  echo "      rm -rf ~/.config/emacs ~/.config/doom"
  exit 1
fi
if [ -L "$TARGET" ]; then
  echo "--> $TARGET é um link simbólico (Stow 'dobrando' a pasta). Desfaça com:"
  echo "      cd $DOTFILES_DIR && stow -D -t \"\$HOME\" $PKG_NAME"
  echo "    e rode de novo (este script usa --no-folding)."
  exit 1
fi

# 1. Emacs 31.1 + dependências (as gramáticas vêm do build-grammars.sh)
echo "--> Instalando GNU Emacs 31.1 e dependências via MacPorts..."
sudo port selfupdate
sudo port install emacs-app @31.1 +treesitter +nativecomp
# coreutils: o `gls' que o Dired usa; cmake/libtool: compilar o módulo do vterm;
# shfmt/shellcheck: formatação e checagem de scripts sh
sudo port install ripgrep fd git stow nvm cmake libtool shfmt shellcheck coreutils

# Node.js e npm via nvm (o nvm é uma função de shell: precisa ser carregado)
if [ ! -s "$NVM_INIT" ]; then
  echo "ERRO: $NVM_INIT não encontrado. Confira a instalação com 'port contents nvm'."
  exit 1
fi
# O nvm não é compatível com `set -eu': desliga só durante este bloco
set +eu
# shellcheck disable=SC1090
source "$NVM_INIT"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION" >/dev/null
NODE_BIN_DIR="$(dirname "$(nvm which "$NODE_VERSION")")"
set -eu

if [ ! -x "$NODE_BIN_DIR/node" ] || [ ! -x "$NODE_BIN_DIR/npm" ]; then
  echo "ERRO: node/npm não encontrados em $NODE_BIN_DIR após 'nvm install $NODE_VERSION'."
  exit 1
fi

# Links estáveis em ~/.local/bin: o Emacs (GUI) não carrega o nvm, e os servidores
# LSP precisam de `node' no PATH. O caminho do nvm muda a cada versão; este não.
mkdir -p "$NPM_PREFIX/bin"
for b in node npm npx; do
  ln -sf "$NODE_BIN_DIR/$b" "$NPM_PREFIX/bin/$b"
done

# Um `sudo npm' antigo deixa arquivos de root em ~/.npm e o npm falha com EACCES
if [ -d "$HOME/.npm" ] && [ -n "$(find "$HOME/.npm" ! -user "$(id -un)" 2>/dev/null | head -n 1)" ]; then
  echo "--> ~/.npm tem arquivos de root (de um 'sudo npm' antigo); corrigindo o dono..."
  sudo chown -R "$(id -u):$(id -g)" "$HOME/.npm"
fi

# 2. Servidores LSP (TypeScript 6, Astro, JSON/CSS/HTML) e BiomeJS em ~/.local (sem sudo)
#    O servidor do Tailwind NÃO vem do npm: o lsp-mode o instala (ver o aviso no fim).
echo "--> Instalando Astro LS, TypeScript 6, BiomeJS e servidores web em ${NPM_PREFIX}..."
npm install -g --prefix "$NPM_PREFIX" typescript@6 typescript-language-server \
  @astrojs/language-server @biomejs/biome vscode-langservers-extracted

# 3. Pasta do Org (a config também a cria, mas assim ela já existe)
mkdir -p ~/My Files/Org Files/daily

# 4. Compilar as gramáticas tree-sitter em ~/.local/lib/tree-sitter
echo "--> Compilando gramáticas tree-sitter..."
"$SCRIPT_DIR/build-grammars.sh"

# 5. Links simbólicos com GNU Stow. --no-folding: ~/.config/emacs fica uma pasta de
#    verdade (só os arquivos viram link), assim elpa/, var/ e custom.el, gerados pelo
#    Emacs, não caem dentro do repositório de dotfiles.
echo "--> Aplicando dotfiles com GNU Stow..."
cd "$DOTFILES_DIR"
stow -v -R --no-folding -t "$HOME" "$PKG_NAME"

# 6. Primeira abertura em modo batch: baixa, instala e compila todos os pacotes,
#    com o log em ~/.local/state/emacs/ (e também na tela).
if command -v emacs >/dev/null 2>&1; then
  EMACS_BIN="$(command -v emacs)"
else
  EMACS_BIN="/Applications/MacPorts/Emacs.app/Contents/MacOS/Emacs"
fi
LOG_DIR="$HOME/.local/state/emacs"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$LOG_DIR"

echo "--> Instalando e compilando os pacotes (pode levar vários minutos)..."
set +e
{ echo "=== emacs --batch ($(date '+%F %T')) ==="
  "$EMACS_BIN" --batch --eval '(message "Pacotes prontos")'; } 2>&1 | tee -a "$LOG_FILE"
BATCH_STATUS="${PIPESTATUS[0]}"
set -e

echo
echo "Log salvo em: $LOG_FILE"
[ "$BATCH_STATUS" -eq 0 ] || echo "AVISO: o Emacs terminou com código $BATCH_STATUS. Veja o log:  grep -n -i 'error' \"$LOG_FILE\""

case ":${PATH_ORIGINAL}:" in
  *":${NPM_PREFIX}/bin:"*) ;;
  *)
    echo
    echo "AVISO: ${NPM_PREFIX}/bin não está no PATH do seu shell (o Emacs já o inclui)."
    echo "Adicione ao ~/.zshrc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo
echo "Para usar node/npm no terminal, adicione ao ~/.zshrc:"
echo "  source $NVM_INIT"
echo "=================================================================="
echo " Instalação concluída! Abra /Applications/MacPorts/Emacs.app"
echo " Teste as gramáticas com:"
echo "   M-: (treesit-language-available-p 'astro)"
echo
echo " Primeiro uso no Emacs:"
echo "   1. M-x lsp-install-server RET tailwindcss   (servidor do Tailwind, baixado pelo lsp-mode)"
echo "   2. Instale a fonte Lekton Nerd Font Mono; este script não a instala"
echo
echo " No projeto Astro, use o Biome local (versão igual à do \$schema do biome.json):"
echo "   npm i -D --save-exact @biomejs/biome"
echo "=================================================================="
