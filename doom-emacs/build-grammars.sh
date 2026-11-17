#!/usr/bin/env bash
# Compila as gramáticas tree-sitter usadas no config.el e instala em
# ~/.local/lib/tree-sitter (mesmo caminho do treesit-extra-load-path).
set -euo pipefail

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

for entry in "${GRAMMARS[@]}"; do
  IFS='|' read -r name repo sub <<< "$entry"
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

echo "Pronto. Gramáticas em $DEST:"
ls "$DEST"
