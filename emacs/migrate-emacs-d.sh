#!/usr/bin/env bash
# migrate-emacs-d.sh — organiza o ~/.emacs.d: move os arquivos de uso antigos
# (recentes, histórico, cache...) para var/ e etc/, onde a nova configuração
# (no-littering) passa a gravá-los. Na raiz ficam só os arquivos de configuração.
#
# Uso (com o Emacs FECHADO):
#   bash migrate-emacs-d.sh --dry-run   # só mostra o que seria movido
#   bash migrate-emacs-d.sh             # move de verdade
#
# Nada é apagado: arquivos sem destino definido vão para var/legacy/.
# Se o destino já existe, o arquivo antigo é mantido onde está.

set -euo pipefail

EMACS_D="${EMACS_D:-$HOME/.emacs.d}"
DRY=0
case "${1:-}" in
  --dry-run) DRY=1 ;;
  "") ;;
  -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "Opção desconhecida: $1" >&2; exit 1 ;;
esac

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m ✗\033[0m %s\n' "$*"; }

[ -d "$EMACS_D" ] || { fail "$EMACS_D não existe."; exit 1; }

if [ "$DRY" -eq 0 ] && pgrep -x -i emacs >/dev/null 2>&1; then
  fail "O Emacs está aberto. Feche-o antes de migrar (ele regrava esses arquivos ao sair)."
  exit 1
fi

moved=0
move() {
  local src="$EMACS_D/$1" dst="$EMACS_D/$2"
  [ -e "$src" ] || return 0
  if [ -e "$dst" ]; then
    warn "$2 já existe; mantive $1 onde está"
    return 0
  fi
  ok "$1  ->  $2"
  moved=$((moved + 1))
  if [ "$DRY" -eq 0 ]; then
    mkdir -p "$(dirname "$dst")"
    mv "$src" "$dst"
  fi
}

info "Organizando $EMACS_D$( [ "$DRY" -eq 1 ] && echo ' (simulação)')"

# --- Dados que a configuração nova lê: preservam recentes, histórico e projetos ---
move recentf.eld   var/recentf.eld
move recentf       var/recentf.eld          # nome antigo, caso exista
move history       var/savehist.el
move places        var/saveplace.el
move projects      var/projects.eld
move eln-cache     var/eln-cache            # cache de compilação nativa
move bookmarks     etc/bookmarks

# --- Estado que o Emacs recria sozinho: guardado em var/legacy/ por segurança ---
for f in auto-save-list eshell transient url tramp request semanticdb \
         network-security.data .org-id-locations .lsp-session-v1; do
  move "$f" "var/legacy/$f"
done

echo
if [ "$moved" -eq 0 ]; then
  ok "Nada para mover. A pasta já está organizada."
else
  ok "$moved item(ns) $( [ "$DRY" -eq 1 ] && echo 'seriam movidos' || echo 'movidos')."
fi

info "O que deve ficar na raiz (configuração e pacotes):"
for f in early-init.el init.el custom.el elpa tree-sitter etc var README.md \
         install-deps.sh migrate-emacs-d.sh; do
  [ -e "$EMACS_D/$f" ] && echo "    $f"
done

echo
info "Qualquer outro arquivo que ainda esteja na raiz:"
extra=0
for f in "$EMACS_D"/* "$EMACS_D"/.[!.]*; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  case "$name" in
    early-init.el|init.el|custom.el|elpa|tree-sitter|etc|var|README.md|install-deps.sh|migrate-emacs-d.sh|.git|.gitignore) ;;
    *) echo "    $name"; extra=1 ;;
  esac
done
[ "$extra" -eq 0 ] && echo "    (nenhum)"
exit 0
