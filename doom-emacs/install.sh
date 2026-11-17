#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles-mac"

echo "=================================================================="
echo " Instalando Doom Emacs + Emacs 31.1 (MacPorts, Stow, Astro & TW)"
echo "=================================================================="

# 1. Atualizar MacPorts e instalar Emacs 31.1 + dependências + gramáticas oficiais
echo "--> Instalando GNU Emacs 31.1 e dependências via MacPorts..."
sudo port selfupdate
sudo port install emacs-app @31.1 +treesitter +nativecomp \
  ripgrep fd git stow nodejs20 npm10 tree-sitter \
  tree-sitter-css tree-sitter-html tree-sitter-javascript \
  tree-sitter-json tree-sitter-typescript

# 2. Instalar servidores LSP (TypeScript 6, Astro, Tailwind) e BiomeJS globalmente
echo "--> Instalando Astro LS, Tailwind LS, TypeScript 6 e BiomeJS..."
sudo npm install -g typescript@6 typescript-language-server @astrojs/language-server @tailwindcss/language-server @biomejs/biome

# 3. Clonar o Doom Emacs oficial (doomemacs/core) se ainda não existir
if [ ! -d "$HOME/.config/emacs" ]; then
  echo "--> Clonando repositório oficial do Doom Emacs..."
  git clone --depth 1 https://github.com ~/.config/emacs
  ~/.config/emacs/bin/doom install --no-config
else
  echo "--> Doom Emacs já encontrado em ~/.config/emacs"
fi

# 4. Criar diretórios necessários
mkdir -p ~/.config/doom
mkdir -p ~/org/daily

# 5. Aplicar links simbólicos com GNU Stow
echo "--> Aplicando dotfiles com GNU Stow..."
cd "$DOTFILES_DIR"
stow -v -R -t "$HOME" doom-emacs

# 6. Sincronizar Doom Emacs e capturar variáveis de ambiente do macOS
echo "--> Sincronizando pacotes e ambiente do Doom Emacs (doom sync --env)..."
~/.config/emacs/bin/doom sync --env

echo "=================================================================="
echo " Instalação concluída! Abra /Applications/MacPorts/Emacs.app"
echo " Na primeira abertura, rode: M-x treesit-install-language-grammar -> astro"
echo "=================================================================="
