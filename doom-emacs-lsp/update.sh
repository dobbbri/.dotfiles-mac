#!/usr/bin/env bash
set -e

# O MacPorts instala em /opt/local; garante que o script o enxergue
export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"

echo "--> Atualizando MacPorts e pacotes do sistema..."
sudo port selfupdate
sudo port upgrade outdated

echo "--> Atualizando o Node.js (nvm) e os links em ~/.local/bin..."
NODE_VERSION="22"
NVM_INIT="/opt/local/share/nvm/init-nvm.sh"
PREFIX="$HOME/.local"
# O nvm não é compatível com `set -e': desliga só durante este bloco
set +e
# shellcheck disable=SC1090
source "$NVM_INIT"
nvm install "$NODE_VERSION"          # traz a última 22.x, se houver
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION" >/dev/null
NODE_BIN_DIR="$(dirname "$(nvm which "$NODE_VERSION")")"
set -e
mkdir -p "$PREFIX/bin"
for b in node npm npx; do
  ln -sf "$NODE_BIN_DIR/$b" "$PREFIX/bin/$b"
done

echo "--> Atualizando servidores LSP (mantendo TypeScript 6) e BiomeJS..."
npm install -g --prefix "$PREFIX" typescript@6
npm update -g --prefix "$PREFIX" typescript-language-server @astrojs/language-server @tailwindcss/language-server @biomejs/biome stylelint js-beautify

echo "--> Reaplicando links do GNU Stow..."
cd "$HOME/.dotfiles-mac"
stow -R -t "$HOME" doom-emacs-lsp

echo "--> Atualizando Doom Emacs e pacotes..."
~/.config/emacs/bin/doom upgrade

echo "--> Limpando arquivos temporários do MacPorts..."
sudo port clean --all installed

echo "Atualização concluída com sucesso!"
