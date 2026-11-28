#!/usr/bin/env bash
# Instala o Emacs 31.1 (MacPorts) + a config vanilla em ~/.config/emacs, via GNU Stow.
# Pergunta antes de cada grupo, então dá para instalar só parte. O que já está instalado é
# pulado, e o script pode ser rodado de novo. As gramáticas tree-sitter e os servidores
# LSP (astro-ls, typescript, json/css/html, Biome e Tailwind) o próprio Emacs instala, na
# primeira abertura (precisa do Node, da etapa 2).
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

PORTS_EMACS=(emacs)                              # instalado com @31.1 +treesitter +nativecomp
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
      port_install emacs
    else
      port_install "${missing[@]}"
    fi
  fi
done

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

# ---------------------------------------------------------------- 3. Cache do npm
# Os servidores LSP e o Biome (npm) e o do Tailwind o próprio Emacs instala na primeira
# abertura (veja o fim do lisp/init-lsp.el). Aqui só se corrige um ~/.npm que tenha ficado
# com arquivos de root: com ele o npm falha com EACCES.
if [ -d "$HOME/.npm" ] && [ -n "$(find "$HOME/.npm" ! -user "$(id -un)" 2>/dev/null | head -n 1)" ]; then
  step "3. Cache do npm (~/.npm)"
  say "   ~/.npm tem arquivos de root (de um 'sudo npm' antigo); isso faz o npm falhar."
  if ask "Corrigir o dono com sudo chown?" s; then
    run sudo chown -R "$(id -u):$(id -g)" "$HOME/.npm"
  fi
fi

# ---------------------------------------------------------------- 4. Stow
step "4. Config em ${TARGET} (GNU Stow, pacote ${PKG_NAME})"
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
say "Abra /Applications/MacPorts/Emacs.app. Primeiro uso:"
say "  1. Na primeira abertura o Emacs baixa e compila os pacotes e, em seguida, instala todas"
say "     as gramáticas tree-sitter (git + compilador C) e os servidores LSP (npm + Tailwind,"
say "     em segundo plano). Leva vários minutos e precisa de internet; o Emacs pode ficar"
say "     ocupado nesse tempo. O andamento dos servidores aparece em *lsp-npm-install*."
say "  2. Instale a fonte Lekton Nerd Font Mono; este script não a instala."
say ""
say "LEMBRETE para cada projeto Astro: instale o TypeScript e o Biome no próprio projeto."
say "O astro-ls usa o TypeScript do projeto, e o Biome local deve ter a versão do \$schema"
say "do biome.json:"
say "  npm i -D typescript@6"
say "  npm i -D --save-exact @biomejs/biome"
say ""
