#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles-mac"
DOOM_PKG="$DOTFILES_DIR/doom-emacs-lsp"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================================="
echo " Instalando Doom Emacs + Emacs 31.1 (MacPorts, Stow, Astro & TW)"
echo "=================================================================="

# 0. Pré-requisitos
if ! xcode-select -p >/dev/null 2>&1; then
  echo "--> Instale as Xcode Command Line Tools primeiro: xcode-select --install"
  exit 1
fi

if [ ! -d "$DOOM_PKG" ]; then
  echo "--> Pasta $DOOM_PKG não encontrada. Verifique seus dotfiles."
  exit 1
fi

for f in init.el config.el packages.el; do
  if [ ! -f "$DOOM_PKG/.config/doom/$f" ]; then
    echo "--> Faltando $DOOM_PKG/.config/doom/$f (copie seus arquivos do Doom para lá)."
    exit 1
  fi
done

# 1. Atualizar MacPorts e instalar Emacs 31.1 + dependências (as gramáticas vêm do build-grammars.sh)
echo "--> Instalando GNU Emacs 31.1 e dependências via MacPorts..."
sudo port selfupdate
sudo port install emacs-app @31.1 +treesitter +nativecomp
sudo port install ripgrep fd git stow nodejs20 npm10

# 2. Instalar servidores LSP (TypeScript 6, Astro, Tailwind) e BiomeJS globalmente
echo "--> Instalando Astro LS, Tailwind LS, TypeScript 6 e BiomeJS..."
sudo npm install -g typescript@6 typescript-language-server @astrojs/language-server @tailwindcss/language-server @biomejs/biome

# 3. Criar diretórios necessários (inclui a pasta de snippets do yasnippet)
mkdir -p ~/.config/doom
mkdir -p ~/org/daily
mkdir -p "$DOOM_PKG/.config/doom/snippets"
touch "$DOOM_PKG/.config/doom/snippets/.gitkeep"

# 4. Compilar TODAS as gramáticas tree-sitter em ~/.local/lib/tree-sitter
if [ -x "$SCRIPT_DIR/build-grammars.sh" ]; then
  echo "--> Compilando gramáticas tree-sitter..."
  "$SCRIPT_DIR/build-grammars.sh"
else
  echo "--> build-grammars.sh não encontrado ao lado do install.sh; pulando gramáticas."
  echo "    (depois rode M-x treesit-install-language-grammar RET astro no Emacs)"
fi

# 5. Aplicar links simbólicos com GNU Stow (ANTES do doom install, para o Doom já achar a config)
echo "--> Aplicando dotfiles com GNU Stow..."
cd "$DOTFILES_DIR"
stow -v -R -t "$HOME" doom-emacs

# 6. Clonar o Doom Emacs oficial se ainda não existir
if [ ! -d "$HOME/.config/emacs" ]; then
  echo "--> Clonando repositório oficial do Doom Emacs..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install --no-config
else
  echo "--> Doom Emacs já encontrado em ~/.config/emacs"
fi

# 7. Sincronizar Doom Emacs e capturar variáveis de ambiente do macOS
echo "--> Sincronizando pacotes e ambiente do Doom Emacs (doom sync --env)..."
~/.config/emacs/bin/doom sync --env

echo "=================================================================="
echo " Instalação concluída! Abra /Applications/MacPorts/Emacs.app"
echo " Teste as gramáticas com:"
echo "   M-: (treesit-language-available-p 'astro)"
echo
echo " No projeto Astro, use o Biome local (versão igual à do \$schema do biome.json)"
echo " e remova Prettier/ESLint:"
echo "   npm i -D --save-exact @biomejs/biome"
echo "   npx biome migrate prettier --write && npx biome migrate eslint --write"
echo "   npm rm prettier prettier-plugin-astro eslint"
echo "=================================================================="
