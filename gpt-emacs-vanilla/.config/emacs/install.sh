#!/usr/bin/env bash
# Instala o Emacs 31.1 (MacPorts) + a config vanilla em ~/.config/emacs, via GNU Stow.
# Pergunta antes de cada grupo, então dá para instalar só parte. O que já está instalado é
# pulado, e o script pode ser rodado de novo. As gramáticas tree-sitter o próprio Emacs 31
# instala, na primeira vez que precisar.
#
# Uso:  ./install.sh [-n|--dry-run] [-y|--yes]
#   -n, --dry-run  só mostra o que seria feito, sem alterar nada
#   -y, --yes      aceita tudo, sem perguntar
#
# Não instala: o MacPorts, as Xcode Command Line Tools e a fonte Lekton Nerd Font Mono.
# Para reverter, use ./uninstall.sh.
set -uo pipefail

DOTFILES_DIR="$HOME/.dotfiles-mac"
PKG_NAME="emacs-vanilla"                  # pacote do Stow (igual ao do uninstall.sh)
PKG_CONFIG_DIR="$DOTFILES_DIR/$PKG_NAME/.config/emacs"
TARGET="$HOME/.config/emacs"              # onde o Emacs procura a config
NPM_PREFIX="$HOME/.local"                 # LSPs e Biome ficam aqui, sem sudo
NODE_VERSION="22"
NVM_INIT="/opt/local/share/nvm/init-nvm.sh"
LOG_DIR="$HOME/.local/state/emacs"
MACPORTS_EMACS_BIN="/Applications/MacPorts/Emacs.app/Contents/MacOS/Emacs"

NPM_PACKAGES=(typescript@6 typescript-language-server @astrojs/language-server
              @tailwindcss/language-server @biomejs/biome vscode-langservers-extracted)
PORTS_EMACS=(emacs-app)                   # instalado com @31.1 +treesitter +nativecomp
PORTS_BASE=(git stow ripgrep fd coreutils)       # stow liga a config; gls = Dired; rg = busca
PORTS_VTERM=(cmake libtool)                      # o vterm compila um módulo nativo
PORTS_SH=(shfmt shellcheck)                      # formatar e checar scripts sh
PORTS_NODE=(nvm)

CONFIG_FILES=(early-init.el init.el
              lisp/init-package.el lisp/init-core.el lisp/init-ui.el lisp/init-evil.el
              lisp/init-keys.el lisp/init-completion.el lisp/init-dired.el
              lisp/init-editor.el lisp/init-treesit.el lisp/init-lsp.el
              lisp/init-biome.el lisp/init-langs.el lisp/init-org.el)

DRY_RUN=0
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -y|--yes)     ASSUME_YES=1 ;;
    -h|--help)    sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Opção desconhecida: $arg"; exit 1 ;;
  esac
done

# Segurança: variáveis de caminho nunca podem estar vazias nem apontar para a raiz.
[ -n "${HOME:-}" ] && [ "$HOME" != "/" ] || { echo "HOME inválido."; exit 1; }

PATH_ORIGINAL="$PATH"
export PATH="$NPM_PREFIX/bin:/opt/local/bin:/opt/local/sbin:$PATH"

say()  { printf '%s\n' "$*"; }
step() { printf '\n==> %s\n' "$*"; }
die()  { printf '%s\n' "$*"; exit 1; }

# Executa (ou apenas mostra, no --dry-run) um comando.
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '   [dry-run] %s\n' "$*"
    return 0
  fi
  "$@" || { local rc=$?; printf '   AVISO: falhou (código %s): %s\n' "$rc" "$*"; return "$rc"; }
}

# ask "pergunta" [padrão s|n]: devolve 0 para sim.
ask() {
  local prompt="$1" default="${2:-s}" reply hint="[S/n]"
  [ "$default" = "n" ] && hint="[s/N]"
  [ "$ASSUME_YES" -eq 1 ] && return 0
  read -r -p "$prompt $hint " reply || reply=""
  reply="${reply:-$default}"
  case "$reply" in s|S|y|Y|sim|Sim) return 0 ;; *) return 1 ;; esac
}

[ "$DRY_RUN" -eq 1 ] && say "(modo --dry-run: nada será alterado)"

# ---------------------------------------------------------------- 0. Pré-requisitos
step "0. Pré-requisitos"
xcode-select -p >/dev/null 2>&1 \
  || die "   Instale as Xcode Command Line Tools primeiro: xcode-select --install"
command -v port >/dev/null 2>&1 \
  || die "   MacPorts (port) não encontrado. Instale em https://www.macports.org/install.php e rode de novo."
say "   Xcode Command Line Tools e MacPorts encontrados."

installed() { port installed "$1" 2>/dev/null | grep -q "(active)"; }

PORT_UPDATED=0
port_install() {                           # port_install pacote...  (selfupdate só uma vez)
  if [ "$PORT_UPDATED" -eq 0 ]; then
    run sudo port selfupdate
    PORT_UPDATED=1
  fi
  run sudo port install "$@"
}

# ---------------------------------------------------------------- 1. MacPorts
step "1. Pacotes do MacPorts"
for group in EMACS BASE VTERM SH; do
  case "$group" in
    EMACS) label="Emacs 31.1 (+treesitter +nativecomp)"; pkgs=("${PORTS_EMACS[@]}") ;;
    BASE)  label="base da config";                       pkgs=("${PORTS_BASE[@]}") ;;
    VTERM) label="terminal no Emacs (vterm)";            pkgs=("${PORTS_VTERM[@]}") ;;
    SH)    label="scripts sh (shfmt, shellcheck)";       pkgs=("${PORTS_SH[@]}") ;;
  esac
  missing=()
  for p in "${pkgs[@]}"; do installed "$p" || missing+=("$p"); done
  if [ "${#missing[@]}" -eq 0 ]; then
    say "   $label: já instalado."
    continue
  fi
  if ask "Instalar $label (${missing[*]}) com sudo port install?" s; then
    if [ "$group" = "EMACS" ]; then
      port_install emacs-app @31.1 +treesitter +nativecomp
    else
      port_install "${missing[@]}"
    fi
  fi
done

if [ -x "$MACPORTS_EMACS_BIN" ] || [ "$DRY_RUN" -eq 1 ]; then
  mkdir -p "$NPM_PREFIX/bin"
  run ln -sf "$MACPORTS_EMACS_BIN" "$NPM_PREFIX/bin/emacs"
fi

# ---------------------------------------------------------------- 2. Node (nvm)
step "2. Node ${NODE_VERSION} via nvm (necessário para os servidores LSP e para o Tailwind)"
DID_NODE=0
if ask "Instalar o nvm e o Node ${NODE_VERSION}?" s; then
  for p in "${PORTS_NODE[@]}"; do installed "$p" || port_install "$p"; done
  if [ "$DRY_RUN" -eq 1 ]; then
    say "   [dry-run] source $NVM_INIT; nvm install $NODE_VERSION; nvm alias default $NODE_VERSION"
    say "   [dry-run] ln -sf <nvm>/bin/{node,npm,npx} $NPM_PREFIX/bin/"
  else
    [ -s "$NVM_INIT" ] || die "ERRO: $NVM_INIT não encontrado. Confira a instalação com 'port contents nvm'."
    # O nvm não é compatível com `set -u': desliga só durante este bloco
    set +u
    # shellcheck disable=SC1090
    source "$NVM_INIT"
    nvm install "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
    nvm use "$NODE_VERSION" >/dev/null
    NODE_BIN_DIR="$(dirname "$(nvm which "$NODE_VERSION")")"
    set -u
    { [ -x "$NODE_BIN_DIR/node" ] && [ -x "$NODE_BIN_DIR/npm" ]; } \
      || die "ERRO: node/npm não encontrados em $NODE_BIN_DIR após 'nvm install $NODE_VERSION'."

    # Links estáveis em ~/.local/bin: o Emacs (GUI) não carrega o nvm, e os servidores
    # LSP precisam de `node' no PATH. O caminho do nvm muda a cada versão; este não.
    mkdir -p "$NPM_PREFIX/bin"
    for b in node npm npx; do ln -sf "$NODE_BIN_DIR/$b" "$NPM_PREFIX/bin/$b"; done
    DID_NODE=1
  fi
fi

# ---------------------------------------------------------------- 3. npm: LSP e Biome
# O servidor do Tailwind vem do npm e a config o usa se estiver no PATH. Se ele iniciar mas
# não completar nada, veja o aviso no fim do lisp/init-lsp.el (o lsp-mode tem um gerenciado).
step "3. Servidores LSP e Biome em ${NPM_PREFIX} (${NPM_PACKAGES[*]})"
if ask "Instalar?" s; then
  if [ "$DRY_RUN" -eq 0 ] && ! command -v npm >/dev/null 2>&1; then
    say "   npm não encontrado (instale o Node na etapa 2); pulando."
  else
    # Um `sudo npm' antigo deixa arquivos de root em ~/.npm e o npm falha com EACCES
    if [ -d "$HOME/.npm" ] && [ -n "$(find "$HOME/.npm" ! -user "$(id -un)" 2>/dev/null | head -n 1)" ]; then
      say "   ~/.npm tem arquivos de root (de um 'sudo npm' antigo); corrigindo o dono..."
      run sudo chown -R "$(id -u):$(id -g)" "$HOME/.npm"
    fi
    run npm install -g --prefix "$NPM_PREFIX" "${NPM_PACKAGES[@]}"
  fi
fi

# ---------------------------------------------------------------- 4. Stow
step "4. Config em ${TARGET} (GNU Stow, pacote ${PKG_NAME})"
STOWED=0
if ask "Aplicar?" s; then
  if [ "$DRY_RUN" -eq 0 ] && ! command -v stow >/dev/null 2>&1; then
    say "   stow não encontrado (instale-o na etapa 1); pulando."
  else
    [ -d "$PKG_CONFIG_DIR" ] \
      || die "   Pasta $PKG_CONFIG_DIR não encontrada. Copie early-init.el, init.el e lisp/ para lá."
    for f in "${CONFIG_FILES[@]}"; do
      [ -f "$PKG_CONFIG_DIR/$f" ] || die "   Faltando $PKG_CONFIG_DIR/$f"
    done

    # O Doom (ou uma config antiga) não pode estar no caminho: o Stow não sobrescreve.
    [ ! -e "$HOME/.emacs.d" ] \
      || die "   $HOME/.emacs.d existe e tem prioridade sobre ~/.config/emacs. Remova-o antes."
    if [ -e "$TARGET/bin/doom" ] || [ -d "$TARGET/.git" ]; then
      die "   O Doom ainda está em $TARGET. Remova-o antes (veja o README):
      cd $DOTFILES_DIR && stow -D -t \"\$HOME\" doom-emacs
      rm -rf ~/.config/emacs ~/.config/doom"
    fi
    if [ -L "$TARGET" ]; then
      die "   $TARGET é um link simbólico (Stow 'dobrando' a pasta). Desfaça com:
      cd $DOTFILES_DIR && stow -D -t \"\$HOME\" $PKG_NAME
    e rode de novo (este script usa --no-folding)."
    fi

    # --no-folding: ~/.config/emacs fica uma pasta de verdade (só os arquivos viram link),
    # assim elpa/, var/ e custom.el, gerados pelo Emacs, não caem no repositório de dotfiles.
    ( cd "$DOTFILES_DIR" && run stow -v -R --no-folding -t "$HOME" "$PKG_NAME" )
    STOWED=1
  fi
fi

# ---------------------------------------------------------------- 5. Pacotes do Emacs
step "5. Pacotes do Emacs (primeira abertura em modo batch: baixa e compila tudo)"
if [ "$STOWED" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ ! -f "$TARGET/init.el" ]; then
  say "   A config ainda não está em $TARGET; pulando."
elif ask "Executar agora? (pode levar vários minutos; precisa de internet)" s; then
  if [ -x "$MACPORTS_EMACS_BIN" ]; then
    EMACS_BIN="$MACPORTS_EMACS_BIN"
  elif command -v emacs >/dev/null 2>&1; then
    EMACS_BIN="$(command -v emacs)"
  else
    EMACS_BIN=""
  fi

  LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
  read -r -d '' BATCH_EVAL << 'EOF' || true
(progn
  (while (and (fboundp 'comp-async-runnings) (> (comp-async-runnings) 0))
    (sleep-for 0.5))
  (message "Pacotes e compilação nativa prontos"))
EOF

  if [ "$DRY_RUN" -eq 1 ]; then
    say "   [dry-run] $EMACS_BIN --batch --eval ... | tee $LOG_FILE"
  elif [ -z "$EMACS_BIN" ] || [ ! -x "$EMACS_BIN" ]; then
    say "   Emacs não encontrado; instale-o na etapa 1 e rode de novo."
  else
    mkdir -p "$LOG_DIR"
    { echo "=== emacs --batch ($(date '+%F %T')) ==="
      "$EMACS_BIN" --batch --eval "$BATCH_EVAL"; } 2>&1 | tee -a "$LOG_FILE"
    BATCH_STATUS="${PIPESTATUS[0]}"
    say ""
    say "   Log salvo em: $LOG_FILE"
    [ "$BATCH_STATUS" -eq 0 ] \
      || say "   AVISO: o Emacs terminou com código $BATCH_STATUS. Veja o log:  grep -n -i 'error' \"$LOG_FILE\""
  fi
fi

# ---------------------------------------------------------------- Fim
step "Concluído"
say "Não foram instalados: o MacPorts, as Xcode Command Line Tools e a fonte Lekton Nerd Font Mono."

case ":${PATH_ORIGINAL}:" in
  *":${NPM_PREFIX}/bin:"*) ;;
  *)
    say ""
    say "AVISO: ${NPM_PREFIX}/bin não está no PATH do seu shell (o Emacs já o inclui)."
    say "Adicione ao ~/.zshrc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

if [ "$DID_NODE" -eq 1 ]; then
  say ""
  say "Para usar node/npm no terminal, adicione ao ~/.zshrc:"
  say "  source $NVM_INIT"
fi

say ""
say "Abra /Applications/MacPorts/Emacs.app (ou 'emacs -nw' no terminal). Primeiro uso:"
say "  1. As gramáticas tree-sitter são instaladas sozinhas (git + compilador C) na primeira"
say "     vez que você abrir cada tipo de arquivo."
say "  2. Instale a fonte Lekton Nerd Font Mono; este script não a instala."
say ""
say "LEMBRETE para cada projeto Astro: instale o TypeScript e o Biome no próprio projeto."
say "O astro-ls usa o TypeScript do projeto, e o Biome local deve ter a versão do \$schema"
say "do biome.json:"
say "  npm i -D typescript@6"
say "  npm i -D --save-exact @biomejs/biome"
say ""
say "Se o Tailwind não completar (log com \"Initialized 0 projects\"), veja o aviso no fim"
say "do ~/.config/emacs/lisp/init-lsp.el: dá para trocar para o servidor gerenciado pelo lsp-mode."
