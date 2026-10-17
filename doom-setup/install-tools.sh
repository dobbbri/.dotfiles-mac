#!/usr/bin/env bash
# Instala tudo via MacPorts + npm, instala o Doom Emacs e copia init/config/packages.
# Uso: ./install-tools.sh   (rode com os arquivos .el na mesma pasta do script)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMACS_DIR="${EMACSDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/emacs}"
DOOM_DIR="${DOOMDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/doom}"
EMACS_APP_BIN="/Applications/MacPorts/Emacs.app/Contents/MacOS/Emacs"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# ---------------------------------------------------------------- pré-requisitos
command -v port >/dev/null || { echo "MacPorts não encontrado: https://www.macports.org/install.php"; exit 1; }
xcode-select -p >/dev/null 2>&1 || { echo "Instale as Command Line Tools: xcode-select --install"; exit 1; }

# ---------------------------------------------------------------- MacPorts
log "Instalando pacotes via MacPorts"
sudo port selfupdate

# Variantes do emacs-app: só pede as que existirem na sua versão do port
EMACS_VARIANTS=""
for v in nativecomp treesitter; do
  port variants emacs-app 2>/dev/null | grep -q "^ *$v:" && EMACS_VARIANTS="$EMACS_VARIANTS +$v"
done
# shellcheck disable=SC2086
sudo port install emacs-app $EMACS_VARIANTS

sudo port install git ripgrep fd coreutils shellcheck shfmt nvm

# ---------------------------------------------------------------- npm (LSPs e formatadores)
log "Instalando Node 22 via nvm"
# nvm nao se da bem com `set -eu`
set +eu
# shellcheck disable=SC1091
source /opt/local/share/nvm/init-nvm.sh
nvm install 22
nvm use 22
set -eu

log "Instalando servidores LSP e formatadores (npm, sem sudo)"
npm i -g \
  typescript@6 typescript-language-server \
  @astrojs/language-server \
  @tailwindcss/language-server \
  vscode-langservers-extracted \
  bash-language-server \
  @biomejs/biome \
  @fsouza/prettierd

# ---------------------------------------------------------------- Fonte Nerd Font
FONT_DIR="$HOME/Library/Fonts"
if ! ls "$FONT_DIR"/JetBrainsMonoNerdFont* >/dev/null 2>&1; then
  log "Instalando JetBrainsMono Nerd Font"
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/jbm.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  mkdir -p "$FONT_DIR"
  unzip -oq "$tmp/jbm.zip" '*.ttf' -d "$FONT_DIR"
  rm -rf "$tmp"
fi

# ---------------------------------------------------------------- Config do Doom (antes do install)
log "Copiando init.el, packages.el e config.el para $DOOM_DIR"
mkdir -p "$DOOM_DIR" "$DOOM_DIR/snippets"
for f in init.el packages.el config.el; do
  src="$SCRIPT_DIR/$f"
  [ -f "$src" ] || { echo "Faltando $src"; exit 1; }
  if [ -f "$DOOM_DIR/$f" ] && ! cmp -s "$src" "$DOOM_DIR/$f"; then
    cp "$DOOM_DIR/$f" "$DOOM_DIR/$f.bak.$(date +%Y%m%d%H%M%S)"
  fi
  cp "$src" "$DOOM_DIR/$f"
done

# ---------------------------------------------------------------- Doom Emacs
export EMACS="$EMACS_APP_BIN"   # o bin/doom usa $EMACS

# emacs-app do MacPorts nao instala `emacs' no PATH: cria um wrapper
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/emacs" <<WRAP
#!/bin/sh
exec "$EMACS_APP_BIN" "\$@"
WRAP
chmod +x "$HOME/.local/bin/emacs"
export PATH="$HOME/.local/bin:$PATH"

ZSHRC="$HOME/.zshrc"
add_line() { grep -qxF "$1" "$ZSHRC" 2>/dev/null || echo "$1" >> "$ZSHRC"; }
add_line 'source /opt/local/share/nvm/init-nvm.sh'
add_line 'export PATH="$HOME/.local/bin:$HOME/.config/emacs/bin:$PATH"'

if [ ! -d "$EMACS_DIR" ]; then
  log "Clonando Doom Emacs em $EMACS_DIR"
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACS_DIR"
  log "Rodando doom install (usa a config já copiada)"
  yes | "$EMACS_DIR/bin/doom" install --no-config
else
  log "Doom já instalado, rodando doom sync"
  "$EMACS_DIR/bin/doom" sync
fi

"$EMACS_DIR/bin/doom" env || true   # captura PATH (npm, MacPorts) para o Emacs.app

cat <<MSG

Pronto! Falta pouco:
  1. Abra um novo terminal (ou: source ~/.zshrc) para carregar nvm e PATH
  2. Abra /Applications/MacPorts/Emacs.app
  3. M-x nerd-icons-install-fonts
  4. M-x my/treesit-install-all   (gramáticas tree-sitter, inclusive Astro)
  5. Rode 'doom doctor' se algo falhar.
MSG
