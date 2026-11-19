#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_NAME="$(basename "$ROOT_DIR")"
PACKAGE_PARENT="$(dirname "$ROOT_DIR")"

DOOM_EMACS_DIR="${DOOM_EMACS_DIR:-$HOME/.config/emacs}"
DOOM_CONFIG_DIR="${DOOM_CONFIG_DIR:-$HOME/.config/doom}"
DOOM_BIN="$DOOM_EMACS_DIR/bin/doom"

SKIP_NPM=0
SKIP_TREESIT=0

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[ERRO]\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Uso: ./install.sh [opções]

  --skip-npm       Não instala servidores LSP npm globais.
  --skip-treesit   Não compila gramáticas Tree-sitter.
  -h, --help       Mostra esta ajuda.

O script não instala, remove nem atualiza o GNU Emacs.
EOF
}

while (($#)); do
  case "$1" in
    --skip-npm) SKIP_NPM=1 ;;
    --skip-treesit) SKIP_TREESIT=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Opção desconhecida: $1 (use --help)." ;;
  esac
  shift
done

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Comando obrigatório não encontrado: $1"
}

require_command emacs
require_command git
require_command node
require_command npm

if ! command -v stow >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    info "GNU Stow não encontrado; instalando com Homebrew."
    brew install stow
  else
    die "GNU Stow não encontrado. Instale-o com 'brew install stow' e execute novamente."
  fi
fi

require_command stow

if [[ "$SKIP_TREESIT" -eq 0 ]]; then
  require_command cc
fi

if ! command -v rg >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
  info "ripgrep não encontrado; instalando com Homebrew."
  brew install ripgrep
fi

mkdir -p "$HOME/.config"

# Não assume o controle de uma instalação Emacs existente ou inválida.
if [[ -d "$DOOM_EMACS_DIR/.git" ]]; then
  info "Doom já está clonado em $DOOM_EMACS_DIR."
elif [[ -e "$DOOM_EMACS_DIR" ]]; then
  die "$DOOM_EMACS_DIR existe, mas não parece ser um clone Git de Doom. Nada foi alterado nesse diretório."
else
  info "Clonando Doom em $DOOM_EMACS_DIR."
  git clone --depth 1 https://github.com/doomemacs/core "$DOOM_EMACS_DIR"
fi

[[ -x "$DOOM_BIN" ]] || die "Executável do Doom não encontrado: $DOOM_BIN"

# Move uma configuração preexistente para backup antes de criar o link do Stow.
EXPECTED_CONFIG="$(cd "$ROOT_DIR/.config/doom" && pwd -P)"
if [[ -L "$DOOM_CONFIG_DIR" ]]; then
  CURRENT_CONFIG="$(cd "$DOOM_CONFIG_DIR" 2>/dev/null && pwd -P || true)"
  if [[ "$CURRENT_CONFIG" != "$EXPECTED_CONFIG" ]]; then
    BACKUP="${DOOM_CONFIG_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
    warn "Movendo o link de configuração anterior para $BACKUP"
    mv "$DOOM_CONFIG_DIR" "$BACKUP"
  fi
elif [[ -e "$DOOM_CONFIG_DIR" ]]; then
  BACKUP="${DOOM_CONFIG_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
  warn "Preservando a configuração existente em $BACKUP"
  mv "$DOOM_CONFIG_DIR" "$BACKUP"
fi

info "Aplicando links GNU Stow: $PACKAGE_NAME"
stow --dir="$PACKAGE_PARENT" --target="$HOME" --restow "$PACKAGE_NAME"

if [[ "$SKIP_NPM" -eq 0 ]]; then
  info "Instalando servidores LSP globais via npm."
  npm install --global \
    typescript \
    typescript-language-server \
    @astrojs/language-server \
    @tailwindcss/language-server \
    vscode-langservers-extracted
else
  warn "Instalação dos servidores npm ignorada por --skip-npm."
fi

export DOOM_EMACS_DIR

if [[ "$SKIP_TREESIT" -eq 0 ]]; then
  info "Instalando gramáticas Tree-sitter."
  emacs --batch -Q -l "$ROOT_DIR/scripts/install-treesit.el"
else
  warn "Instalação das gramáticas Tree-sitter ignorada por --skip-treesit."
fi

if [[ ! -d "$DOOM_EMACS_DIR/.local" ]]; then
  info "Executando primeira instalação do Doom."
  "$DOOM_BIN" install
else
  info "Sincronizando configuração Doom."
  "$DOOM_BIN" sync
fi

info "Sincronizando variáveis de ambiente do shell."
"$DOOM_BIN" sync --env

cat <<EOF

Instalação concluída.

Configuração: $DOOM_CONFIG_DIR
Doom:         $DOOM_EMACS_DIR

Próximos passos:
  1. Abra o Emacs.
  2. Execute M-x doom/reload ou reinicie o Emacs.
  3. Em um projeto JavaScript/TypeScript, instale Biome localmente:
     $ROOT_DIR/scripts/install-biome-project.sh /caminho/do/projeto
  4. Diagnostique a instalação:
     $DOOM_BIN doctor
EOF
