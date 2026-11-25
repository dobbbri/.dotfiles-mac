#!/usr/bin/env bash
# Limpeza antes de uma instalação limpa do Doom Emacs (macOS + MacPorts + Stow).
# Remove: links do Stow (inclusive os órfãos), o Doom em ~/.config/emacs, as
# gramáticas tree-sitter e os pacotes npm de ~/.local.
# NÃO toca em: ~/org, MacPorts, nvm/Node nem nos arquivos do pacote em ~/.dotfiles-mac.
# Uso: ./clean.sh [-n|--dry-run] [-y|--yes] [--sudo-npm]
#   -n  só mostra o que faria, sem alterar nada
#   -y  não pergunta antes de apagar
#   --sudo-npm  remove também os pacotes npm antigos de /opt/local (pede sudo)
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles-mac"
NPM_PREFIX="$HOME/.local"
export PATH="${NPM_PREFIX}/bin:/opt/local/bin:/opt/local/sbin:${PATH}"

DRY=0
YES=0
SUDO_NPM=0
for a in "$@"; do
  case "$a" in
    -n|--dry-run) DRY=1 ;;
    -y|--yes) YES=1 ;;
    --sudo-npm) SUDO_NPM=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Opção desconhecida: $a (use -h)"; exit 2 ;;
  esac
done

if [ -z "${HOME:-}" ] || [ "$HOME" = "/" ]; then
  echo "ERRO: \$HOME inválido."; exit 1
fi

NPM_PKGS="typescript typescript-language-server @astrojs/language-server @tailwindcss/language-server @biomejs/biome stylelint js-beautify"

# Mostra o comando e, fora do --dry-run, executa
run() {
  echo "   + $*"
  if [ "$DRY" -eq 0 ]; then "$@"; fi
}

# Verdadeiro se $1 é um link cujo destino passa por um pacote doom-emacs* do Stow
is_pkg_link() {
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in
    *".dotfiles-mac/doom-emacs"*) return 0 ;;
    *) return 1 ;;
  esac
}

echo "Este script remove (e só isso):"
echo "  - links do Stow dos pacotes doom-emacs*, mesmo órfãos (pasta do pacote já apagada)"
echo "  - o Doom Emacs em ~/.config/emacs e seus dados"
echo "  - as gramáticas em ~/.local/lib/tree-sitter"
echo "  - os pacotes npm globais de ~/.local e os links node/npm/npx"
if [ "$SUDO_NPM" -eq 1 ]; then
  echo "  - os pacotes npm antigos de /opt/local (sudo)"
fi
echo "Não toca em ~/org, MacPorts, nvm/Node nem em ~/.dotfiles-mac."
echo

if [ "$DRY" -eq 1 ]; then
  echo "(modo --dry-run: nada será alterado)"
elif [ "$YES" -eq 0 ]; then
  read -r -p "Continuar? [s/N] " ans
  case "$ans" in
    s|S|y|Y) ;;
    *) echo "Cancelado."; exit 1 ;;
  esac
fi

# 1. Desfaz os links com o Stow, para os pacotes cuja pasta ainda existe
echo "--> 1. Links do Stow"
if command -v stow >/dev/null 2>&1; then
  for pkg in doom-emacs doom-emacs-gpt doom-emacs-lsp; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
      run stow -D -d "$DOTFILES_DIR" -t "$HOME" "$pkg" || true
    fi
  done
else
  echo "   stow não encontrado: só a limpeza manual dos links, abaixo."
fi

# 2. Links que sobraram (ex.: a pasta do pacote foi apagada e o `stow -D' não os acha mais)
echo "--> 2. Links órfãos"
for f in "$HOME/.config/doom" "$HOME/install.sh" "$HOME/update.sh" \
         "$HOME/build-grammars.sh" "$HOME/clean.sh" "$HOME/README.md" \
         "$HOME/.stow-local-ignore"; do
  if is_pkg_link "$f"; then run rm "$f"; fi
done
if [ -d "$HOME/.config/doom" ] && [ ! -L "$HOME/.config/doom" ]; then
  while IFS= read -r l; do
    if is_pkg_link "$l"; then run rm "$l"; fi
  done < <(find "$HOME/.config/doom" -type l)
  run find "$HOME/.config/doom" -depth -type d -empty -delete
  if [ "$DRY" -eq 0 ] && [ -d "$HOME/.config/doom" ]; then
    echo "   AVISO: ~/.config/doom ainda tem arquivos que não são links do Stow; mantido."
  fi
fi

# 3. Doom Emacs
echo "--> 3. Doom Emacs"
if [ -x "$HOME/.config/emacs/bin/doom" ]; then
  run rm -rf "$HOME/.config/emacs"
elif [ -e "$HOME/.config/emacs" ]; then
  echo "   ~/.config/emacs existe, mas não parece ser o Doom (sem bin/doom): mantido."
else
  echo "   (nenhum Doom em ~/.config/emacs)"
fi
for d in "$HOME/.local/share/doom" "$HOME/.local/state/doom" "$HOME/.cache/doom"; do
  if [ -d "$d" ]; then run rm -rf "$d"; fi
done

# 4. Gramáticas tree-sitter compiladas pelo build-grammars.sh
echo "--> 4. Gramáticas tree-sitter"
GRAMMARS_DIR="$HOME/.local/lib/tree-sitter"
if [ -d "$GRAMMARS_DIR" ]; then
  run find "$GRAMMARS_DIR" -maxdepth 1 -name 'libtree-sitter-*.dylib' -delete
  run rmdir "$GRAMMARS_DIR" 2>/dev/null || true
else
  echo "   (nenhuma)"
fi

# 5. Pacotes npm globais em ~/.local e os links estáveis do Node
echo "--> 5. Pacotes npm de ~/.local"
if command -v npm >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  run npm uninstall -g --prefix "$NPM_PREFIX" $NPM_PKGS || true
else
  echo "   npm não encontrado: pulei (restam ~/.local/lib/node_modules e ~/.local/bin)."
fi
for b in node npm npx; do
  if [ -L "$NPM_PREFIX/bin/$b" ]; then run rm "$NPM_PREFIX/bin/$b"; fi
done

if [ "$SUDO_NPM" -eq 1 ]; then
  echo "--> 5b. Pacotes npm antigos de /opt/local"
  if [ -x /opt/local/bin/npm ]; then
    # shellcheck disable=SC2086
    run sudo /opt/local/bin/npm uninstall -g $NPM_PKGS || true
  else
    echo "   /opt/local/bin/npm não encontrado: pulei."
  fi
fi

# 6. Pasta do pacote: o instalador espera ~/.dotfiles-mac/doom-emacs
echo "--> 6. Pasta do pacote"
if [ -d "$DOTFILES_DIR/doom-emacs-gpt" ] && [ ! -e "$DOTFILES_DIR/doom-emacs" ]; then
  run mv "$DOTFILES_DIR/doom-emacs-gpt" "$DOTFILES_DIR/doom-emacs"
fi
if [ -d "$DOTFILES_DIR/doom-emacs" ] || [ "$DRY" -eq 1 ]; then
  echo "   pacote: $DOTFILES_DIR/doom-emacs"
else
  echo "   AVISO: $DOTFILES_DIR/doom-emacs não existe; copie o pacote para lá antes do install.sh."
fi

echo
if [ "$DRY" -eq 1 ]; then
  echo "Dry-run concluído: nada foi alterado."
else
  echo "Limpeza concluída. Para instalar do zero:"
  echo "  cd $DOTFILES_DIR/doom-emacs && ./install.sh"
fi
