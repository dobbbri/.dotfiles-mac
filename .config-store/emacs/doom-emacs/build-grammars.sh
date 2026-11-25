#!/usr/bin/env bash
# Compila as gramáticas tree-sitter usadas no config.el e instala em
# ~/.local/lib/tree-sitter (mesmo caminho do treesit-extra-load-path).
# Uso: ./build-grammars.sh               (compila todas)
#      ./build-grammars.sh tsx css       (compila só as indicadas)
#      ./build-grammars.sh --link-only   (não compila: só refaz os links no cache do Doom)
set -euo pipefail

LINK_ONLY=0
if [ "${1:-}" = "--link-only" ]; then
  LINK_ONLY=1
  shift
fi

DEST="$HOME/.local/lib/tree-sitter"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$DEST"

# nome | repositório | subdiretório com parser.c
GRAMMARS=(
  "astro|https://github.com/virchau13/tree-sitter-astro|."
  "bash|https://github.com/tree-sitter/tree-sitter-bash|."
  "css|https://github.com/tree-sitter/tree-sitter-css|."
  "html|https://github.com/tree-sitter/tree-sitter-html|."
  "javascript|https://github.com/tree-sitter/tree-sitter-javascript|."
  "json|https://github.com/tree-sitter/tree-sitter-json|."
  "yaml|https://github.com/tree-sitter-grammars/tree-sitter-yaml|."
  "typescript|https://github.com/tree-sitter/tree-sitter-typescript|typescript"
  "tsx|https://github.com/tree-sitter/tree-sitter-typescript|tsx"
)

# Nomes pedidos na linha de comando (vazio = todas)
WANT=("$@")
wanted() {
  [ "${#WANT[@]}" -eq 0 ] && return 0
  local w
  for w in "${WANT[@]}"; do [ "$w" = "$1" ] && return 0; done
  return 1
}

for entry in "${GRAMMARS[@]}"; do
  [ "$LINK_ONLY" -eq 1 ] && break
  IFS='|' read -r name repo sub <<< "$entry"
  wanted "$name" || continue
  echo "--> $name"

  repodir="$WORK/$(basename "$repo")"
  [ -d "$repodir" ] || git clone --quiet --depth 1 "$repo" "$repodir"

  src="$repodir/$sub/src"
  out="$DEST/libtree-sitter-$name.dylib"
  objs=()
  cxx=0

  cc -fPIC -O2 -I "$src" -c "$src/parser.c" -o "$WORK/$name-parser.o"
  objs+=("$WORK/$name-parser.o")

  if [ -f "$src/scanner.c" ]; then
    cc -fPIC -O2 -I "$src" -c "$src/scanner.c" -o "$WORK/$name-scanner.o"
    objs+=("$WORK/$name-scanner.o")
  elif [ -f "$src/scanner.cc" ]; then
    c++ -fPIC -O2 -I "$src" -c "$src/scanner.cc" -o "$WORK/$name-scanner.o"
    objs+=("$WORK/$name-scanner.o"); cxx=1
  fi

  if [ "$cxx" = 1 ]; then
    c++ -dynamiclib -o "$out" "${objs[@]}"
  else
    cc -dynamiclib -o "$out" "${objs[@]}"
  fi
done

# Links no cache do Doom. O Emacs sempre procura em <user-emacs-directory>/tree-sitter,
# que no Doom é ~/.config/emacs/.local/cache/tree-sitter. Os comandos `doom sync' e
# `doom doctor' rodam SEM o seu config.el (logo, sem o treesit-extra-load-path) e
# só enxergam as gramáticas ali; sem os links, o astro-ts-mode avisa "grammar for
# astro failed to load" ao ser instalado.
DOOM_CACHE="$HOME/.config/emacs/.local/cache/tree-sitter"
if [ -d "$HOME/.config/emacs" ]; then
  mkdir -p "$DOOM_CACHE"
  for f in "$DEST"/libtree-sitter-*.dylib; do
    [ -e "$f" ] && ln -sf "$f" "$DOOM_CACHE/$(basename "$f")"
  done
  echo "Links criados em $DOOM_CACHE"
fi

# Confere se todas as gramáticas esperadas existem
missing=0
for entry in "${GRAMMARS[@]}"; do
  IFS='|' read -r name _ _ <<< "$entry"
  if [ -f "$DEST/libtree-sitter-$name.dylib" ]; then
    echo "   ok     $name"
  else
    echo "   FALTA  $name"
    missing=1
  fi
done

echo "Gramáticas em $DEST"
[ "$missing" -eq 0 ] || { echo "Atenção: há gramáticas faltando (veja acima)."; exit 1; }
