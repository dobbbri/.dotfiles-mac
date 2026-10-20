#!/usr/bin/env bash
# install.sh — instala as dependências externas do Emacs-Kick (revisado) e copia
# a configuração (init.el / early-init.el) para ~/.emacs.d.
#
# Suporta: macOS (MacPorts ou Homebrew) e Linux (apt, dnf, pacman).
# É idempotente: pode ser executado de novo sem problemas.
#
# Uso:  ./install.sh [opções]      (veja --help)

set -Eeuo pipefail

# ----------------------------------------------------------------------
# Configuração (pode ser sobrescrita por variáveis de ambiente)
# ----------------------------------------------------------------------
NVM_VERSION="${NVM_VERSION:-v0.40.3}"          # confira a atual em github.com/nvm-sh/nvm
EMACS_DIR="${EMACS_DIR:-$HOME/.emacs.d}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

DRY_RUN=0
DO_PACKAGES=1
DO_NODE=1
DO_FONTS=1
DO_CONFIG=1
DO_EMACS=0
PM_OVERRIDE=""

# ----------------------------------------------------------------------
# Utilitários
# ----------------------------------------------------------------------
if [[ -t 1 ]]; then
  C_BLUE=$'\033[1;34m'; C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'
  C_RED=$'\033[1;31m'; C_OFF=$'\033[0m'
else
  C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_OFF=""
fi

log()  { printf '%s==>%s %s\n' "$C_BLUE" "$C_OFF" "$*"; }
ok()   { printf '%s ok%s %s\n' "$C_GREEN" "$C_OFF" "$*"; }
warn() { printf '%s !!%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
die()  { printf '%sERRO:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Executa (ou apenas mostra, com --dry-run) um comando.
run() {
  if (( DRY_RUN )); then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

usage() {
  cat <<EOF
Uso: $(basename "$0") [opções]

Instala as dependências externas do Emacs-Kick e copia a configuração.

Opções:
  --pm <port|brew|apt|dnf|pacman>  força o gerenciador de pacotes
  --with-emacs                     instala também o Emacs (se ausente)
  --no-packages                    não instala pacotes do sistema
  --no-node                        não instala nvm/Node.js/pacotes npm
  --no-fonts                       não instala a JetBrainsMono Nerd Font
  --no-config                      não copia init.el / early-init.el
  --dry-run                        só mostra o que seria feito
  -h, --help                       esta ajuda

Variáveis: NVM_VERSION (padrão $NVM_VERSION), EMACS_DIR (padrão $EMACS_DIR)
EOF
}

while (( $# )); do
  case "$1" in
    --pm)           PM_OVERRIDE="${2:-}"; shift ;;
    --with-emacs)   DO_EMACS=1 ;;
    --no-packages)  DO_PACKAGES=0 ;;
    --no-node)      DO_NODE=0 ;;
    --no-fonts)     DO_FONTS=0 ;;
    --no-config)    DO_CONFIG=0 ;;
    --dry-run)      DRY_RUN=1 ;;
    -h|--help)      usage; exit 0 ;;
    *)              usage >&2; die "opção desconhecida: $1" ;;
  esac
  shift
done

trap 'warn "falha na linha $LINENO (comando: $BASH_COMMAND)"' ERR

SUDO=""
if [[ $EUID -ne 0 ]] && have sudo; then SUDO="sudo"; fi

OS="$(uname -s)"
PM=""

# ----------------------------------------------------------------------
# Detecção do gerenciador de pacotes
# ----------------------------------------------------------------------
detect_pm() {
  if [[ -n "$PM_OVERRIDE" ]]; then PM="$PM_OVERRIDE"; return; fi
  case "$OS" in
    Darwin)
      if   have port; then PM="port"
      elif have brew; then PM="brew"
      else die "instale o MacPorts (macports.org) ou o Homebrew (brew.sh) primeiro."
      fi ;;
    Linux)
      if   have apt-get; then PM="apt"
      elif have dnf;     then PM="dnf"
      elif have pacman;  then PM="pacman"
      else die "gerenciador de pacotes não suportado; use --pm ou instale manualmente (veja o INSTALL.md)."
      fi ;;
    *) die "sistema não suportado: $OS" ;;
  esac
}

# Instala cada pacote separadamente: se um nome não existir nessa distro,
# avisa e continua com os outros.
install_each() {
  local p
  for p in "$@"; do
    case "$PM" in
      port)   run $SUDO port -N install "$p"                              || warn "port: não consegui instalar '$p'" ;;
      brew)   run brew install "$p"                                       || warn "brew: não consegui instalar '$p'" ;;
      apt)    run $SUDO apt-get install -y "$p"                           || warn "apt: não consegui instalar '$p'" ;;
      dnf)    run $SUDO dnf install -y "$p"                               || warn "dnf: não consegui instalar '$p'" ;;
      pacman) run $SUDO pacman -S --needed --noconfirm "$p"               || warn "pacman: não consegui instalar '$p'" ;;
    esac
  done
}

# ----------------------------------------------------------------------
# Pré-requisitos do macOS
# ----------------------------------------------------------------------
check_macos_clt() {
  [[ "$OS" == "Darwin" ]] || return 0
  if xcode-select -p >/dev/null 2>&1; then
    ok "Xcode Command Line Tools presentes"
  else
    warn "Xcode Command Line Tools ausentes (necessários para compilar as grammars do tree-sitter)."
    if (( DRY_RUN )); then
      echo "[dry-run] xcode-select --install"
    else
      xcode-select --install || true
      die "conclua a instalação das Command Line Tools na janela que abriu e rode o script de novo."
    fi
  fi
}

# ----------------------------------------------------------------------
# Pacotes do sistema
# ----------------------------------------------------------------------
install_packages() {
  log "Instalando pacotes do sistema com: $PM"
  case "$PM" in
    port)
      install_each git curl unzip ripgrep fd shellcheck shfmt taplo multimarkdown ttf-nerd-fonts-symbols ;;
    brew)
      install_each git curl unzip ripgrep fd shellcheck shfmt taplo multimarkdown ;;
    apt)
      run $SUDO apt-get update || warn "apt-get update falhou"
      install_each git curl unzip build-essential fontconfig ripgrep fd-find shellcheck shfmt multimarkdown ;;
    dnf)
      install_each git curl unzip gcc make fontconfig ripgrep fd-find ShellCheck shfmt ;;
    pacman)
      install_each git curl unzip base-devel fontconfig ripgrep fd shellcheck shfmt taplo-cli ;;
  esac

  # Debian/Ubuntu instalam o `fd' como `fdfind'.
  if ! have fd && have fdfind && (( ! DRY_RUN )); then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ok "criado link ~/.local/bin/fd -> fdfind"
  fi
}

install_emacs() {
  if have emacs; then return 0; fi
  log "Instalando o Emacs"
  case "$PM" in
    port)   run $SUDO port -N install emacs-app ;;
    brew)   run brew tap d12frosted/emacs-plus && run brew install emacs-plus@30 ;;
    apt)    if have snap; then run $SUDO snap install emacs --classic; else install_each emacs; fi ;;
    dnf|pacman) install_each emacs ;;
  esac
}

check_emacs_version() {
  local ver major
  if have emacs; then
    ver="$(emacs --version 2>/dev/null | head -n1 | grep -Eo '[0-9]+(\.[0-9]+)+' | head -n1 || true)"
    major="${ver%%.*}"
    if [[ -n "$major" && "$major" -ge 30 ]]; then
      ok "Emacs $ver"
    else
      warn "Emacs ${ver:-desconhecido}: a config exige 30.1 ou superior."
    fi
  else
    warn "comando 'emacs' não encontrado no PATH (no MacPorts, o app fica em /Applications/MacPorts/). Rode com --with-emacs ou instale manualmente."
  fi
}

# ----------------------------------------------------------------------
# Node.js via nvm + pacotes npm globais
# ----------------------------------------------------------------------
install_node() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "Instalando nvm $NVM_VERSION"
    if (( DRY_RUN )); then
      echo "[dry-run] curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash"
    else
      curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
    fi
  else
    ok "nvm já instalado em $NVM_DIR"
  fi

  if (( DRY_RUN )); then
    echo "[dry-run] nvm install --lts && nvm alias default 'lts/*'"
    echo "[dry-run] npm install -g typescript typescript-language-server prettier prettier-plugin-astro @astrojs/language-server vscode-langservers-extracted yaml-language-server"
    return 0
  fi

  # nvm.sh não é compatível com `set -eu'.
  set +eu
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  log "Instalando Node.js LTS"
  nvm install --lts
  nvm alias default 'lts/*'
  nvm use default >/dev/null
  set -eu

  have node || die "node não ficou disponível após instalar o nvm."
  ok "Node $(node -v) / npm $(npm -v)"

  log "Instalando pacotes npm globais (LSP e formatadores)"
  npm install -g \
    typescript \
    typescript-language-server \
    prettier \
    prettier-plugin-astro \
    @astrojs/language-server \
    vscode-langservers-extracted \
    yaml-language-server \
    || warn "alguns pacotes npm falharam"

  # Taplo via npm se não veio pelo gerenciador de pacotes.
  if ! have taplo; then
    log "taplo não encontrado; instalando @taplo/cli via npm"
    npm install -g @taplo/cli || warn "não consegui instalar o taplo"
  fi
}

# ----------------------------------------------------------------------
# Fonte JetBrainsMono Nerd Font (família completa)
# ----------------------------------------------------------------------
install_fonts() {
  local dest tmp
  case "$OS" in
    Darwin) dest="$HOME/Library/Fonts" ;;
    *)      dest="$HOME/.local/share/fonts/JetBrainsMonoNerd" ;;
  esac

  if compgen -G "$dest/JetBrainsMonoNerdFont*" >/dev/null 2>&1; then
    ok "JetBrainsMono Nerd Font já instalada"
    return 0
  fi

  log "Baixando JetBrainsMono Nerd Font"
  if (( DRY_RUN )); then
    echo "[dry-run] curl -fL $FONT_URL -> unzip em $dest"
    return 0
  fi

  have unzip || { warn "unzip ausente; pulando a instalação da fonte."; return 0; }
  mkdir -p "$dest"
  tmp="$(mktemp -d)"
  if curl -fL --retry 3 -o "$tmp/font.zip" "$FONT_URL"; then
    unzip -oq "$tmp/font.zip" '*.ttf' -d "$dest" || warn "falha ao extrair a fonte"
    if [[ "$OS" != "Darwin" ]] && have fc-cache; then fc-cache -f >/dev/null 2>&1 || true; fi
    ok "fonte instalada em $dest"
  else
    warn "não consegui baixar a fonte; instale manualmente em nerdfonts.com."
  fi
  rm -rf "$tmp"
}

# ----------------------------------------------------------------------
# Copiar a configuração
# ----------------------------------------------------------------------
install_config() {
  local f ts
  ts="$(date +%Y%m%d-%H%M%S)"
  log "Copiando configuração para $EMACS_DIR"
  run mkdir -p "$EMACS_DIR"
  for f in init.el early-init.el; do
    if [[ ! -f "$SCRIPT_DIR/$f" ]]; then
      warn "$f não encontrado em $SCRIPT_DIR; pulando."
      continue
    fi
    if [[ -f "$EMACS_DIR/$f" ]] && ! cmp -s "$SCRIPT_DIR/$f" "$EMACS_DIR/$f"; then
      run cp "$EMACS_DIR/$f" "$EMACS_DIR/$f.bak-$ts"
      ok "backup: $EMACS_DIR/$f.bak-$ts"
    fi
    run cp "$SCRIPT_DIR/$f" "$EMACS_DIR/$f"
    ok "$f copiado"
  done
}

# ----------------------------------------------------------------------
# Principal
# ----------------------------------------------------------------------
main() {
  (( DRY_RUN )) && warn "modo --dry-run: nada será alterado."
  detect_pm
  log "Sistema: $OS | gerenciador: $PM"

  check_macos_clt

  if (( DO_PACKAGES )); then install_packages; fi
  if (( DO_EMACS ));    then install_emacs; fi
  check_emacs_version

  if (( DO_NODE ));     then install_node;  fi
  if (( DO_FONTS ));    then install_fonts; fi
  if (( DO_CONFIG ));   then install_config; fi

  cat <<EOF

${C_GREEN}Pronto.${C_OFF} Próximos passos:
  1. Abra um NOVO terminal (para carregar o nvm) e rode:  emacs
  2. Espere o primeiro boot terminar (o straight.el baixa os pacotes) e feche o Emacs.
  3. Abra o Emacs de novo e rode:  M-x ek/first-install RET
  4. Em cada projeto, instale o Biome se quiser:  npm i -D --save-exact @biomejs/biome

Detalhes e solução de problemas: INSTALL.md
EOF
}

main
