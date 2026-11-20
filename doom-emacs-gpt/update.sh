#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles-mac"
PKG_NAME="doom-emacs-gpt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NODE_VERSION="22"
NVM_INIT="/opt/local/share/nvm/init-nvm.sh"
PREFIX="$HOME/.local"

export PATH="${PREFIX}/bin:/opt/local/bin:/opt/local/sbin:${PATH}"

echo "=================================================================="
echo " Atualizando MacPorts, Node, LSPs, Biome e Doom Emacs"
echo "=================================================================="

# 1. Atualizar MacPorts
echo "--> Atualizando MacPorts e pacotes instalados..."
sudo port selfupdate
sudo port upgrade outdated

# 2. Atualizar Node via nvm e refazer symlinks estáveis
if [ -s "$NVM_INIT" ]; then
  echo "--> Atualizando Node.js ($NODE_VERSION) via nvm..."
  set +eu
  # shellcheck disable=SC1090
  source "$NVM_INIT"
  nvm install "$NODE_VERSION" --reinstall-packages-from="$NODE_VERSION" || nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  nvm use "$NODE_VERSION" >/dev/null
  NODE_BIN_DIR="$(dirname "$(nvm which "$NODE_VERSION")")"
  set -eu

  mkdir -p "$PREFIX/bin"
  for b in node npm npx; do
    ln -sf "$NODE_BIN_DIR/$b" "$PREFIX/bin/$b"
  done
fi

# 3. Atualizar pacotes npm globais em ~/.local (mantendo TypeScript 6)
echo "--> Atualizando servidores LSP e BiomeJS em ${PREFIX}..."
npm install -g --prefix "$PREFIX" typescript@6 typescript-language-server @astrojs/language-server @tailwindcss/language-server @biomejs/biome stylelint js-beautify

# 4. Reaplicar symlinks do GNU Stow
if [ -d "$DOTFILES_DIR/$PKG_NAME" ]; then
  echo "--> Reaplicando links simbólicos com GNU Stow..."
  cd "$DOTFILES_DIR"
  stow -v -R -t "$HOME" "$PKG_NAME"
fi

# 5. Atualizar links das gramáticas tree-sitter no cache do Doom
if [ -x "$SCRIPT_DIR/build-grammars.sh" ]; then
  "$SCRIPT_DIR/build-grammars.sh" --link-only || true
fi

# 6. Atualizar e sincronizar o Doom Emacs
DOOM_BIN="$HOME/.config/emacs/bin/doom"
if [ -x "$DOOM_BIN" ]; then
  echo "--> Atualizando Doom Emacs e pacotes..."
  "$DOOM_BIN" upgrade --force
  "$DOOM_BIN" sync --env
  "$DOOM_BIN" doctor || true
fi

echo "=================================================================="
echo " Atualização concluída!"
echo "=================================================================="
