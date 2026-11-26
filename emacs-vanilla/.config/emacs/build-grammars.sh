#!/usr/bin/env bash
# Compila as gramáticas tree-sitter usadas pela config, sem depender do Emacs.
# Uso:  ./build-grammars.sh [pasta-de-destino]
# Padrão: ~/.config/emacs/tree-sitter (a pasta onde o Emacs procura as gramáticas sozinho)
# Precisa de git e de um compilador C (macOS: xcode-select --install).
set -euo pipefail

DEST="${1:-$HOME/.config/emacs/tree-sitter}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$DEST"

case "$(uname -s)" in
  Darwin) EXT="dylib" ;;
  *)      EXT="so" ;;
esac

# nome | repositório | subpasta com src/ ("." se for a raiz)
GRAMMARS=(
  "astro|https://github.com/virchau13/tree-sitter-astro|."
  "bash|https://github.com/tree-sitter/tree-sitter-bash|."
  "css|https://github.com/tree-sitter/tree-sitter-css|."
  "html|https://github.com/tree-sitter/tree-sitter-html|."
  "javascript|https://github.com/tree-sitter/tree-sitter-javascript|."
  "json|https://github.com/tree-sitter/tree-sitter-json|."
  "tsx|https://github.com/tree-sitter/tree-sitter-typescript|tsx"
  "typescript|https://github.com/tree-sitter/tree-sitter-typescript|typescript"
  "yaml|https://github.com/tree-sitter-grammars/tree-sitter-yaml|."
)

falhas=()
for item in "${GRAMMARS[@]}"; do
  IFS='|' read -r nome repo sub <<<"$item"
  saida="$DEST/libtree-sitter-$nome.$EXT"
  if [[ -f "$saida" ]]; then echo "✓ $nome (já existe)"; continue; fi

  echo "→ $nome"
  dir="$WORK/$nome"
  if ! git clone --depth 1 --quiet "$repo" "$dir"; then
    echo "  ✗ falha ao clonar $repo"; falhas+=("$nome"); continue
  fi

  src="$dir/$sub/src"
  incs=(-I"$src")
  [[ -d "$dir/common" ]] && incs+=(-I"$dir/common")   # typescript/tsx

  cfiles=("$src"/*.c)
  ccfiles=()
  shopt -s nullglob; ccfiles=("$src"/*.cc); shopt -u nullglob

  if ((${#ccfiles[@]})); then
    cxx="${CXX:-c++}"
    objs=()
    for f in "${cfiles[@]}"; do o="$WORK/$nome-$(basename "$f").o"; "${CC:-cc}" -O2 -fPIC "${incs[@]}" -c "$f" -o "$o"; objs+=("$o"); done
    for f in "${ccfiles[@]}"; do o="$WORK/$nome-$(basename "$f").o"; "$cxx" -O2 -fPIC "${incs[@]}" -c "$f" -o "$o"; objs+=("$o"); done
    "$cxx" -shared "${objs[@]}" -o "$saida" || { echo "  ✗ falha ao compilar"; falhas+=("$nome"); continue; }
  else
    "${CC:-cc}" -shared -fPIC -O2 "${incs[@]}" "${cfiles[@]}" -o "$saida" \
      || { echo "  ✗ falha ao compilar"; falhas+=("$nome"); continue; }
  fi
  echo "  ✓ $saida"
done

echo
if ((${#falhas[@]})); then
  echo "Falharam: ${falhas[*]}"; exit 1
fi
echo "Pronto. Gramáticas em $DEST"
