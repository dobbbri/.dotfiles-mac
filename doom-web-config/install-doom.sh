#!/usr/bin/env bash
# install-doom.sh
# Instala o Doom Emacs, aplica init.el/config.el/packages.el e instala as
# dependências do setup web (Astro, TS/JS, Tailwind, Prettier, Biome, ESLint).
#
# Uso:   ./install-doom.sh [opções]
#   -y, --yes           não pergunta nada (assume "sim")
#   --skip-deps         não instala pacotes do sistema nem npm/pipx
#   --skip-grammars     não compila as gramáticas tree-sitter
#   -h, --help          mostra esta ajuda
#
# Coloque este script na mesma pasta de init.el, config.el e packages.el
# (ou em uma pasta pai que tenha uma subpasta "doom/" com eles).

set -euo pipefail

# ---------------------------------------------------------------------------
# Opções
# ---------------------------------------------------------------------------
ASSUME_YES=0
SKIP_DEPS=0
SKIP_GRAMMARS=0

for arg in "$@"; do
  case "$arg" in
    -y|--yes)         ASSUME_YES=1 ;;
    --skip-deps)      SKIP_DEPS=1 ;;
    --skip-grammars)  SKIP_GRAMMARS=1 ;;
    -h|--help)        sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Opção desconhecida: $arg" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  C_B=$'\033[1m'; C_G=$'\033[32m'; C_Y=$'\033[33m'; C_R=$'\033[31m'; C_0=$'\033[0m'
else
  C_B=""; C_G=""; C_Y=""; C_R=""; C_0=""
fi

step() { printf '\n%s==>%s %s%s%s\n' "$C_G" "$C_0" "$C_B" "$*" "$C_0"; }
info() { printf '  %s\n' "$*"; }
warn() { printf '%s  [aviso]%s %s\n' "$C_Y" "$C_0" "$*" >&2; }
die()  { printf '%s[erro]%s %s\n' "$C_R" "$C_0" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

confirm() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  local reply
  read -r -p "  $1 [s/N] " reply
  [[ "$reply" =~ ^[sSyY]$ ]]
}

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if have sudo; then SUDO="sudo"; fi
fi

TS="$(date +%Y%m%d-%H%M%S)"

# ---------------------------------------------------------------------------
# Localiza os arquivos de configuração
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR=""
for d in "$SCRIPT_DIR" "$SCRIPT_DIR/doom"; do
  if [ -f "$d/init.el" ] && [ -f "$d/config.el" ] && [ -f "$d/packages.el" ]; then
    SRC_DIR="$d"; break
  fi
done
[ -n "$SRC_DIR" ] || die "init.el, config.el e packages.el não encontrados em $SCRIPT_DIR (nem em $SCRIPT_DIR/doom)."

# Diretórios de destino
EMACS_DIR="${EMACSDIR:-$HOME/.config/emacs}"          # onde o Doom é clonado
if [ -d "$HOME/.doom.d" ] && [ ! -d "$HOME/.config/doom" ]; then
  DOOMDIR="$HOME/.doom.d"
else
  DOOMDIR="${DOOMDIR:-$HOME/.config/doom}"
fi
DOOM_BIN="$EMACS_DIR/bin/doom"

info "Fonte da config : $SRC_DIR"
info "Doom (clone)    : $EMACS_DIR"
info "DOOMDIR (config): $DOOMDIR"

# ---------------------------------------------------------------------------
# Sistema operacional / gerenciador de pacotes
# ---------------------------------------------------------------------------
PM=""
case "$(uname -s)" in
  Darwin) PM="brew" ;;
  Linux)
    if   have apt-get; then PM="apt"
    elif have dnf;     then PM="dnf"
    elif have pacman;  then PM="pacman"
    elif have zypper;  then PM="zypper"
    fi ;;
  *) die "Sistema não suportado: $(uname -s)" ;;
esac
[ -n "$PM" ] || warn "Gerenciador de pacotes não reconhecido; pulando pacotes do sistema."

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$EMACS_DIR/bin:$PATH"

# ---------------------------------------------------------------------------
# 1. Pacotes do sistema
# ---------------------------------------------------------------------------
install_system_deps() {
  step "Instalando pacotes do sistema ($PM)"
  case "$PM" in
    apt)
      $SUDO apt-get update
      $SUDO apt-get install -y \
        git curl unzip ripgrep fd-find emacs \
        build-essential cmake libtool libtool-bin libvterm-dev \
        python3 python3-pip pipx nodejs npm shellcheck fonts-jetbrains-mono
      # No Debian/Ubuntu o binário se chama `fdfind'
      if have fdfind && ! have fd; then
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        info "Link criado: ~/.local/bin/fd -> fdfind"
      fi
      ;;
    dnf)
      $SUDO dnf install -y \
        git curl unzip ripgrep fd-find emacs \
        gcc gcc-c++ make cmake libtool libvterm-devel \
        python3 python3-pip pipx nodejs npm ShellCheck jetbrains-mono-fonts
      ;;
    pacman)
      $SUDO pacman -Sy --needed --noconfirm \
        git curl unzip ripgrep fd emacs \
        base-devel cmake libtool libvterm \
        python python-pipx nodejs npm shellcheck ttf-jetbrains-mono
      ;;
    zypper)
      $SUDO zypper --non-interactive install \
        git curl unzip ripgrep fd emacs \
        gcc gcc-c++ make cmake libtool libvterm-devel \
        python3 python3-pip python3-pipx nodejs npm ShellCheck jetbrains-mono-fonts
      ;;
    brew)
      have brew || die "Homebrew não encontrado. Instale em https://brew.sh"
      brew install git ripgrep fd cmake libtool libvterm node pipx shellcheck coreutils gnu-tar
      brew install --cask emacs font-jetbrains-mono || warn "Falha ao instalar o Emacs/fonte via cask."
      ;;
  esac
}

# ---------------------------------------------------------------------------
# 2. Ferramentas globais (npm / pipx)
# ---------------------------------------------------------------------------
install_node_tools() {
  step "Instalando ferramentas via npm (LSPs, Prettier, Biome)"
  have npm || die "npm não encontrado. Instale o Node.js e rode de novo."

  local node_major
  node_major="$(node -v 2>/dev/null | sed 's/^v//; s/\..*//')"
  if [ -n "$node_major" ] && [ "$node_major" -lt 18 ]; then
    warn "Node $node_major é antigo (recomendado >= 18). Considere nvm/fnm/direnv por projeto."
  fi

  # Sem sudo: se o prefixo global não for gravável, usa ~/.local
  local prefix
  prefix="$(npm config get prefix)"
  if [ ! -w "$prefix" ]; then
    info "Prefixo npm ($prefix) não é gravável; usando ~/.local"
    npm config set prefix "$HOME/.local"
  fi

  npm install -g \
    typescript \
    typescript-language-server \
    @astrojs/language-server \
    @tailwindcss/language-server \
    bash-language-server \
    vscode-langservers-extracted \
    prettier \
    prettier-plugin-astro \
    prettier-plugin-tailwindcss \
    @biomejs/biome
  info "ESLint fica por projeto (npm i -D eslint) e é chamado via npx."
}

install_python_tools() {
  step "Instalando ferramentas via pipx (grip, rass)"
  if ! have pipx; then
    warn "pipx não encontrado; instalando via pip --user"
    python3 -m pip install --user pipx || { warn "Não foi possível instalar o pipx; pulando."; return 0; }
  fi
  pipx ensurepath >/dev/null 2>&1 || true
  # grip: preview de Markdown; rassumfrassum: multiplexa TS + Tailwind no eglot
  pipx install grip           || warn "Falha ao instalar grip."
  pipx install rassumfrassum  || warn "Falha ao instalar rassumfrassum (rass)."
}

# ---------------------------------------------------------------------------
# 3. Verificação do Emacs
# ---------------------------------------------------------------------------
check_emacs() {
  step "Verificando o Emacs"
  have emacs || die "Emacs não encontrado no PATH."
  local ver major
  ver="$(emacs --version | head -n1 | grep -Eo '[0-9]+\.[0-9]+' | head -n1)"
  major="${ver%%.*}"
  info "Emacs $ver"
  if [ "$major" -lt 29 ]; then
    warn "Esta config usa tree-sitter nativo (treesit) e eglot: precisa de Emacs 29+ (ideal 30+)."
    warn "Debian 12 e Ubuntu antigos trazem versão antiga; use Flatpak, snap (--classic) ou compile do fonte."
    confirm "Continuar mesmo assim?" || die "Abortado."
  elif [ "$major" -lt 30 ]; then
    info "Emacs 29 funciona; o ajuste de eglot-events-buffer já cai no fallback."
  fi
}

# ---------------------------------------------------------------------------
# 4. Doom Emacs (clone)
# ---------------------------------------------------------------------------
install_doom_core() {
  step "Instalando o Doom Emacs"

  # ~/.emacs.d tem prioridade sobre ~/.config/emacs e quebraria o Doom
  if [ -e "$HOME/.emacs.d" ] && [ ! -f "$HOME/.emacs.d/bin/doom" ]; then
    warn "~/.emacs.d existe e faria o Emacs ignorar $EMACS_DIR."
    if confirm "Mover ~/.emacs.d para ~/.emacs.d.bak-$TS?"; then
      mv "$HOME/.emacs.d" "$HOME/.emacs.d.bak-$TS"
      info "Backup: ~/.emacs.d.bak-$TS"
    else
      die "Remova/mova ~/.emacs.d manualmente e rode de novo."
    fi
  fi

  if [ -x "$DOOM_BIN" ]; then
    info "Doom já clonado em $EMACS_DIR (pulando clone)."
    DOOM_FRESH=0
  else
    if [ -e "$EMACS_DIR" ]; then
      warn "$EMACS_DIR existe e não é um clone do Doom."
      confirm "Mover para ${EMACS_DIR}.bak-$TS?" || die "Abortado."
      mv "$EMACS_DIR" "${EMACS_DIR}.bak-$TS"
    fi
    mkdir -p "$(dirname "$EMACS_DIR")"
    git clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACS_DIR"
    DOOM_FRESH=1
  fi
}

# ---------------------------------------------------------------------------
# 5. Aplica os 3 arquivos (com backup)
# ---------------------------------------------------------------------------
apply_config() {
  step "Aplicando init.el, config.el e packages.el em $DOOMDIR"
  mkdir -p "$DOOMDIR"
  local f
  for f in init.el config.el packages.el; do
    if [ -f "$DOOMDIR/$f" ] && ! cmp -s "$SRC_DIR/$f" "$DOOMDIR/$f"; then
      cp "$DOOMDIR/$f" "$DOOMDIR/$f.bak-$TS"
      info "Backup: $f.bak-$TS"
    fi
    cp "$SRC_DIR/$f" "$DOOMDIR/$f"
    info "Copiado: $f"
  done
}

# ---------------------------------------------------------------------------
# 6. doom install / sync
# ---------------------------------------------------------------------------
run_doom() {
  export DOOMDIR
  if [ "${DOOM_FRESH:-0}" -eq 1 ]; then
    step "Rodando 'doom install' (demora; baixa e compila pacotes)"
    "$DOOM_BIN" install --no-config --env --fonts
  else
    step "Rodando 'doom sync'"
    "$DOOM_BIN" sync
  fi
}

# ---------------------------------------------------------------------------
# 7. Gramáticas tree-sitter (best effort)
# ---------------------------------------------------------------------------
install_grammars() {
  step "Compilando gramáticas tree-sitter"
  if ! have cc && ! have gcc && ! have clang; then
    warn "Sem compilador C; pulando gramáticas."; return 0
  fi
  local out="$EMACS_DIR/.local/etc/tree-sitter"
  mkdir -p "$out"
  emacs --batch --eval "
(progn
  (unless (and (fboundp 'treesit-available-p) (treesit-available-p))
    (message \"treesit indisponível neste Emacs; pulando.\")
    (kill-emacs 0))
  (setq user-emacs-directory \"$EMACS_DIR/.local/etc/\")
  (add-to-list 'treesit-extra-load-path \"$out\")
  (let ((treesit-language-source-alist
         '((astro      \"https://github.com/virchau13/tree-sitter-astro\")
           (typescript \"https://github.com/tree-sitter/tree-sitter-typescript\" \"master\" \"typescript/src\")
           (tsx        \"https://github.com/tree-sitter/tree-sitter-typescript\" \"master\" \"tsx/src\")
           (javascript \"https://github.com/tree-sitter/tree-sitter-javascript\" \"master\" \"src\")
           (css        \"https://github.com/tree-sitter/tree-sitter-css\")
           (html       \"https://github.com/tree-sitter/tree-sitter-html\")
           (json       \"https://github.com/tree-sitter/tree-sitter-json\")
           (bash       \"https://github.com/tree-sitter/tree-sitter-bash\")
           (yaml       \"https://github.com/ikatyang/tree-sitter-yaml\"))))
    (dolist (lang '(astro typescript tsx javascript css html json bash yaml))
      (if (treesit-language-available-p lang)
          (message \"ok (já instalada): %s\" lang)
        (condition-case err
            (progn (treesit-install-language-grammar lang \"$out\")
                   (message \"ok: %s\" lang))
          (error (message \"FALHOU %s: %s\" lang err)))))))
" 2>&1 | sed 's/^/  /' || warn "Algumas gramáticas falharam; use M-x treesit-install-language-grammar."
}

# ---------------------------------------------------------------------------
# 8. PATH no shell
# ---------------------------------------------------------------------------
setup_path() {
  step "Configurando o PATH"
  local rc=""
  case "${SHELL##*/}" in
    zsh)  rc="$HOME/.zshrc" ;;
    bash) rc="$HOME/.bashrc" ;;
    fish)
      info "Fish detectado. Rode: fish_add_path $EMACS_DIR/bin ~/.local/bin"
      return 0 ;;
    *)    rc="$HOME/.profile" ;;
  esac
  if grep -q '# >>> doom-emacs >>>' "$rc" 2>/dev/null; then
    info "PATH já configurado em $rc"
  else
    {
      echo ''
      echo '# >>> doom-emacs >>>'
      echo "export PATH=\"$EMACS_DIR/bin:\$HOME/.local/bin:\$PATH\""
      echo '# <<< doom-emacs <<<'
    } >> "$rc"
    info "Adicionado a $rc (abra um novo terminal ou: source $rc)"
  fi
}

# ---------------------------------------------------------------------------
# Execução
# ---------------------------------------------------------------------------
DOOM_FRESH=0

if [ "$SKIP_DEPS" -eq 0 ]; then
  [ -n "$PM" ] && install_system_deps
  install_node_tools
  install_python_tools
else
  info "Pulando instalação de dependências (--skip-deps)."
fi

check_emacs
install_doom_core
apply_config
run_doom
[ "$SKIP_GRAMMARS" -eq 0 ] && install_grammars
setup_path

step "Diagnóstico (doom doctor)"
"$DOOM_BIN" doctor || warn "O doctor apontou avisos; leia a saída acima."

cat <<EOF

${C_G}Pronto.${C_0}
  - Abra um novo terminal (ou 'source' no seu rc) e rode: emacs
  - Depois de editar a config:  doom sync   e reinicie (SPC h r r)
  - Se algum .astro/.ts abrir sem highlight:  M-x treesit-install-language-grammar
EOF
