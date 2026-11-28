#!/usr/bin/env bash
# Reverte o install.sh: desfaz o Stow, remove os servidores LSP/Biome de ~/.local, os links
# de emacs/node/npm/npx, as gramáticas, os arquivos que o Emacs gerou e, se você quiser, os
# pacotes do MacPorts e o Node do nvm. Pergunta antes de cada grupo.
#
# Uso:  ./uninstall.sh [-n|--dry-run] [-y|--yes]
#   -n, --dry-run  só mostra o que seria feito, sem alterar nada
#   -y, --yes      aceita as respostas padrão (que são as mais seguras: faz backup em vez
#                  de apagar, e não mexe nos pacotes do MacPorts nem no Node)
#
# Nunca é apagado: ~/org (suas notas), o repositório ~/.dotfiles-mac (só os links
# são removidos) e o MacPorts/Xcode CLT em si.
set -uo pipefail

DOTFILES_DIR="$HOME/.dotfiles-mac"
PKG_NAME="emacs-vanilla"                  # pacote do Stow (igual ao do install.sh)
TARGET="$HOME/.config/emacs"
NPM_PREFIX="$HOME/.local"
NODE_VERSION="22"
NVM_INIT="/opt/local/share/nvm/init-nvm.sh"
LOG_DIR="$HOME/.local/state/emacs"

NPM_PACKAGES=(typescript typescript-language-server @astrojs/language-server
              @tailwindcss/language-server @biomejs/biome vscode-langservers-extracted)
PORTS_EMACS=(emacs-app)
PORTS_TOOLS=(ripgrep fd shfmt shellcheck cmake libtool)   # úteis ao Emacs, mas genéricos
PORTS_SHARED=(git stow nvm coreutils)                      # você provavelmente usa fora do Emacs

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

say()  { printf '%s\n' "$*"; }
step() { printf '\n==> %s\n' "$*"; }

# Executa (ou apenas mostra, no --dry-run) um comando.
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '   [dry-run] %s\n' "$*"
    return 0
  fi
  "$@"
}

# ask "pergunta" padrão(s|n): devolve 0 para sim.
ask() {
  local prompt="$1" default="${2:-n}" reply hint="[s/N]"
  [ "$default" = "s" ] && hint="[S/n]"
  if [ "$ASSUME_YES" -eq 1 ]; then
    [ "$default" = "s" ]; return
  fi
  read -r -p "$prompt $hint " reply || reply=""
  reply="${reply:-$default}"
  case "$reply" in s|S|y|Y|sim|Sim) return 0 ;; *) return 1 ;; esac
}

[ "$DRY_RUN" -eq 1 ] && say "(modo --dry-run: nada será alterado)"

# ---------------------------------------------------------------- 1. Stow
step "1. Links do Stow (${PKG_NAME} -> ${TARGET})"
if command -v stow >/dev/null 2>&1 && [ -d "$DOTFILES_DIR/$PKG_NAME" ]; then
  if ask "Desfazer os links do Stow? (os arquivos em $DOTFILES_DIR/$PKG_NAME permanecem)" s; then
    ( cd "$DOTFILES_DIR" && run stow -v -D --no-folding -t "$HOME" "$PKG_NAME" )
  fi
else
  say "   stow ou $DOTFILES_DIR/$PKG_NAME não encontrado; nada a fazer."
fi

# ---------------------------------------------------------------- 2. npm e links
step "2. Servidores LSP e Biome instalados em ${NPM_PREFIX}"
export PATH="$NPM_PREFIX/bin:$PATH"
if command -v npm >/dev/null 2>&1; then
  if ask "Remover (${NPM_PACKAGES[*]}) de ${NPM_PREFIX}?" s; then
    run npm uninstall -g --prefix "$NPM_PREFIX" "${NPM_PACKAGES[@]}"
  fi
else
  say "   npm não encontrado no PATH; pulando a remoção dos pacotes."
fi

step "   Links emacs/node/npm/npx em ${NPM_PREFIX}/bin (criados pelo install.sh)"
for b in emacs node npm npx; do
  link="$NPM_PREFIX/bin/$b"
  if [ -L "$link" ]; then
    dest="$(readlink "$link")"
    case "$dest" in
      *".nvm"*|*"/nvm/"*|*"/Applications/MacPorts/Emacs.app/"*)
        if ask "Remover o link $link -> $dest?" s; then run rm -f -- "$link"; fi ;;
      *) say "   $link aponta para $dest (não foi criado pelo install.sh); mantido." ;;
    esac
  fi
done

# ---------------------------------------------------------------- 3. gramáticas
step "3. Gramáticas tree-sitter compiladas"
for d in "$TARGET/tree-sitter" "$HOME/.local/lib/tree-sitter"; do
  if [ -d "$d" ]; then
    say "   $d ($(find "$d" -maxdepth 1 -type f | wc -l | tr -d ' ') arquivos)"
    default="s"
    # Esta última pasta pode ser de um setup antigo (Doom): por segurança, padrão = não.
    [ "$d" = "$HOME/.local/lib/tree-sitter" ] && default="n"
    if ask "Remover $d?" "$default"; then run rm -rf -- "$d"; fi
  fi
done

# ---------------------------------------------------------------- 4. arquivos do Emacs
step "4. Arquivos gerados pelo Emacs em ${TARGET} (elpa, var, custom.el, ...)"
if [ -d "$TARGET" ]; then
  if [ -L "$TARGET" ]; then
    say "   $TARGET é um link simbólico; mantido (desfaça-o pelo passo do Stow)."
  else
    say "   Conteúdo atual:"
    ls -A "$TARGET" | sed 's/^/     /'
    say "   (depois do Stow, o que sobrou foi gerado pelo Emacs; custom.el pode ter ajustes seus)"
    say "   [a] apagar   [m] mover para backup   [n] não mexer"
    choice="m"
    if [ "$ASSUME_YES" -eq 0 ]; then
      read -r -p "   Escolha [a/M/n]: " choice || choice="m"
      choice="${choice:-m}"
    fi
    case "$choice" in
      a|A)
        if ask "Confirma apagar TUDO em $TARGET?" n; then run rm -rf -- "$TARGET"; fi ;;
      m|M)
        backup="$TARGET.bak-$(date +%Y%m%d-%H%M%S)"
        run mv -- "$TARGET" "$backup"
        say "   Movido para $backup" ;;
      *) say "   Mantido." ;;
    esac
  fi
else
  say "   $TARGET não existe."
fi

# Pasta de testes antiga (de quando a config ficava em ~/.config/emacs-vanilla)
OLD_DIR="$HOME/.config/emacs-vanilla"
if [ -d "$OLD_DIR" ] && [ ! -L "$OLD_DIR" ]; then
  say "   Encontrada a pasta de testes antiga: $OLD_DIR"
  if ask "Mover $OLD_DIR para backup?" n; then
    run mv -- "$OLD_DIR" "$OLD_DIR.bak-$(date +%Y%m%d-%H%M%S)"
  fi
fi

if [ -d "$LOG_DIR" ]; then
  if ask "Remover os logs de instalação em $LOG_DIR?" s; then run rm -rf -- "$LOG_DIR"; fi
fi

# ---------------------------------------------------------------- 5. Node (nvm)
step "5. Node ${NODE_VERSION} instalado pelo nvm"
if [ -s "$NVM_INIT" ]; then
  if ask "Desinstalar o Node ${NODE_VERSION} do nvm? (e remover o alias default)" n; then
    if [ "$DRY_RUN" -eq 1 ]; then
      say "   [dry-run] nvm unalias default; nvm uninstall $NODE_VERSION"
    else
      set +u
      # shellcheck disable=SC1090
      source "$NVM_INIT"
      nvm unalias default 2>/dev/null
      nvm deactivate >/dev/null 2>&1
      nvm uninstall "$NODE_VERSION"
      set -u
    fi
  fi
else
  say "   $NVM_INIT não encontrado; pulando."
fi

# ---------------------------------------------------------------- 6. MacPorts
step "6. Pacotes do MacPorts"
if command -v port >/dev/null 2>&1; then
  installed() { port installed "$1" 2>/dev/null | grep -q "(active)"; }

  for group in EMACS TOOLS SHARED; do
    case "$group" in
      EMACS)  label="Emacs";                         pkgs=("${PORTS_EMACS[@]}");  default="n" ;;
      TOOLS)  label="ferramentas auxiliares";        pkgs=("${PORTS_TOOLS[@]}");  default="n" ;;
      SHARED) label="ferramentas COMPARTILHADAS (use só se não precisar delas fora do Emacs)"
              pkgs=("${PORTS_SHARED[@]}"); default="n" ;;
    esac
    present=()
    for p in "${pkgs[@]}"; do installed "$p" && present+=("$p"); done
    if [ "${#present[@]}" -eq 0 ]; then
      say "   $label: nenhum instalado."
      continue
    fi
    if ask "Desinstalar $label (${present[*]}) com sudo port uninstall?" "$default"; then
      run sudo port uninstall "${present[@]}"
    fi
  done
else
  say "   MacPorts não encontrado; pulando."
fi

step "Concluído"
say "Não foram tocados: ~/org (notas), $DOTFILES_DIR (repositório de dotfiles),"
say "o MacPorts, as Xcode Command Line Tools e a fonte Lekton Nerd Font Mono."
say "Se adicionou 'source $NVM_INIT' ao ~/.zshrc, remova a linha à mão se não quiser mais o nvm."
