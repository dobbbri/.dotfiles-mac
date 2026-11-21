#!/usr/bin/env bash
set -e

echo "--> Atualizando MacPorts e pacotes do sistema..."
sudo port selfupdate
sudo port upgrade outdated

echo "--> Atualizando servidores LSP (mantendo TypeScript 6) e BiomeJS..."
sudo npm install -g typescript@6
sudo npm update -g typescript-language-server @astrojs/language-server @biomejs/biome

echo "--> Reaplicando links do GNU Stow..."
cd "$HOME/.dotfiles-mac"
stow -R -t "$HOME" doom-emacs

echo "--> Atualizando Doom Emacs e pacotes..."
~/.config/emacs/bin/doom upgrade

echo "--> Limpando arquivos temporários do MacPorts..."
sudo port clean --all installed

echo "Atualização concluída com sucesso!"
