#!/usr/bin/env bash
# install-deps.sh — instala os binários externos usados pelo init.el
# (servidores LSP, formatadores e ferramentas de busca).
#   - MacPorts: git, coreutils, ripgrep, fd e formatadores
#   - nvm:      Node.js e os pacotes npm globais
#
# Uso:
#   bash install-deps.sh              # instala tudo
#   bash install-deps.sh --check      # só verifica o que está instalado
#   bash install-deps.sh --with-rass  # também instala o rass (Tailwind + ts_ls/astro-ls)
#
# Variáveis opcionais:
#   NODE_VERSION=20 bash install-deps.sh     # versão do Node (padrão: 22)
#   NVM_VERSION=v0.40.3 bash install-deps.sh # versão do nvm
#
# Compatível com o bash 3.2 do macOS. Pede sudo só para o `port`.

set -euo pipefail

# ----------------------------------------------------------------
# Configuração
# ----------------------------------------------------------------
NVM_VERSION="${NVM_VERSION:-v0.40.3}"
NODE_VERSION="${NODE_VERSION:-22}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
GOBIN_DIR="$HOME/.local/bin"

BASE_PORTS="git coreutils ripgrep fd"

# Ferramentas com fallback (npm/go) se a porta não existir ou falhar
TOOL_PORTS="lua-language-server shfmt stylua taplo yamlfmt"

# typescript fixado na 6.x: astro-ls e typescript-language-server precisam do
# typescript.js/tsserver (API JavaScript do compilador); o astro-ls não é
# compatível com TypeScript 7.
NPM_PKGS="
  @astrojs/language-server
  bash-language-server
  vscode-langservers-extracted
  @tailwindcss/language-server
  typescript@6
  typescript-language-server
  prettier
  prettier-plugin-astro
"

CHECK_CMDS="
  node
  npm
  astro-ls
  bash-language-server
  vscode-json-language-server
  lua-language-server
  tailwindcss-language-server
  typescript-language-server
  tsc
  prettier
  shfmt
  stylua
  taplo
  yamlfmt
  rg
  fd
  gls
  git
"

WITH_RASS=0
CHECK_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --with-rass) WITH_RASS=1 ;;
    --check)     CHECK_ONLY=1 ;;
    -h|--help)   sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Opção desconhecida: $arg" >&2; exit 1 ;;
  esac
done

# ----------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m ✗\033[0m %s\n' "$*"; }

# Arquivo de perfil lido por shells de login (o exec-path-from-shell usa isso)
PROFILE="$HOME/.zprofile"
case "${SHELL:-}" in */bash) PROFILE="$HOME/.bash_profile" ;; esac

# Põe o diretório no PATH desta execução e, de forma idempotente, no perfil
add_path() {
  local dir="$1"
  case ":$PATH:" in *":$dir:"*) ;; *) export PATH="$dir:$PATH" ;; esac
  if ! grep -qsF "$dir" "$PROFILE" 2>/dev/null; then
    printf '\n# adicionado por install-deps.sh\nexport PATH="%s:$PATH"\n' "$dir" >> "$PROFILE"
    ok "PATH: $dir adicionado a $PROFILE"
  fi
}

# MacPorts normalmente já está no PATH, mas garantimos para esta execução
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

verify() {
  info "Verificando binários no PATH"
  local missing=0 cmd
  for cmd in $CHECK_CMDS; do
    if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd"; else fail "$cmd (não encontrado)"; missing=1; fi
  done
  if [ "$WITH_RASS" -eq 1 ]; then
    if command -v rass >/dev/null 2>&1; then ok "rass"; else fail "rass (não encontrado)"; missing=1; fi
  fi
  return $missing
}

if [ "$CHECK_ONLY" -eq 1 ]; then
  # Mesmo PATH que o Emacs enxerga via login shell
  if [ -d "$NVM_DIR/current/bin" ]; then export PATH="$NVM_DIR/current/bin:$PATH"; fi
  if [ -d "$GOBIN_DIR" ]; then export PATH="$GOBIN_DIR:$PATH"; fi
  verify && exit 0 || exit 1
fi

# nvm.sh não é compatível com `set -eu`, então liberamos só durante o carregamento
load_nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] || return 1
  set +eu
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  set -eu
}

# ----------------------------------------------------------------
# Funções do MacPorts
# ----------------------------------------------------------------
port_exists()    { port -q info --name "$1" >/dev/null 2>&1; }
port_installed() { [ -n "$(port -q installed "$1" 2>/dev/null)" ]; }

port_install() {
  local p
  for p in "$@"; do
    if port_installed "$p"; then
      ok "$p (já instalado)"
    else
      info "port install $p"
      sudo port -N install "$p"
    fi
  done
}

go_install() {
  port_install go
  mkdir -p "$GOBIN_DIR"
  GOBIN="$GOBIN_DIR" go install "$1"
  add_path "$GOBIN_DIR"
}

# Alternativas quando a porta não existe ou não compila no seu macOS
fallback_install() {
  case "$1" in
    taplo)   npm install -g @taplo/cli ;;
    stylua)  npm install -g @johnnymorganz/stylua-bin ;;
    shfmt)   go_install mvdan.cc/sh/v3/cmd/shfmt@latest ;;
    yamlfmt) go_install github.com/google/yamlfmt/cmd/yamlfmt@latest ;;
    lua-language-server)
      warn "lua-language-server: sem alternativa automática."
      warn "Baixe o binário em https://github.com/LuaLS/lua-language-server/releases,"
      warn "extraia em ~/.local/lua-language-server e faça um symlink de bin/lua-language-server para ~/.local/bin."
      return 1 ;;
  esac
}

# ----------------------------------------------------------------
# Pré-requisitos
# ----------------------------------------------------------------
info "macOS $(sw_vers -productVersion 2>/dev/null || echo '?')"

if ! command -v port >/dev/null 2>&1; then
  fail "MacPorts não encontrado. Instale o pacote da sua versão do macOS em:"
  fail "  https://www.macports.org/install.php"
  fail "Depois reabra o terminal e rode este script de novo."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  warn "Xcode Command Line Tools ausentes (necessárias para o MacPorts e para compilar gramáticas tree-sitter)."
  xcode-select --install || true
  fail "Termine a instalação das Command Line Tools e rode o script de novo."
  exit 1
fi

info "Pedindo sudo (usado só para o comando 'port')"
sudo -v

info "Atualizando a árvore de ports (selfupdate)"
sudo port selfupdate

# ----------------------------------------------------------------
# Ports base
# ----------------------------------------------------------------
info "Instalando ports base: $BASE_PORTS"
# shellcheck disable=SC2086
port_install $BASE_PORTS

# ----------------------------------------------------------------
# nvm + Node
# ----------------------------------------------------------------
if load_nvm; then
  ok "nvm (já instalado em $NVM_DIR)"
else
  info "Instalando nvm $NVM_VERSION"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
  load_nvm || { fail "nvm instalado, mas não consegui carregar $NVM_DIR/nvm.sh"; exit 1; }
fi

info "Instalando Node $NODE_VERSION via nvm"
set +e +u
nvm install "$NODE_VERSION"
rc=$?
if [ "$rc" -eq 0 ]; then
  nvm alias default "$NODE_VERSION" >/dev/null
  nvm use default >/dev/null
fi
set -eu
if [ "$rc" -ne 0 ]; then
  fail "Falha ao instalar o Node $NODE_VERSION."
  fail "Versões novas do Node podem exigir um macOS mais recente que o seu."
  fail "Tente uma mais antiga: NODE_VERSION=20 bash install-deps.sh"
  exit 1
fi
ok "node $(node --version) | npm $(npm --version)"

# O nvm só entra no PATH via .zshrc (shell interativo), que o Emacs não lê.
# Criamos um symlink estável e o colocamos no perfil de login.
node_prefix="$(dirname "$(dirname "$(command -v node)")")"
ln -sfn "$node_prefix" "$NVM_DIR/current"
add_path "$NVM_DIR/current/bin"

info "Instalando pacotes npm globais"
# shellcheck disable=SC2086
npm install -g $NPM_PKGS

# ----------------------------------------------------------------
# Formatadores e lua-language-server (porta, com fallback)
# ----------------------------------------------------------------
info "Instalando: $TOOL_PORTS"
for tool in $TOOL_PORTS; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool (já no PATH)"
    continue
  fi
  if port_exists "$tool"; then
    port_install "$tool" || { warn "port $tool falhou; tentando alternativa"; fallback_install "$tool" || true; }
  else
    warn "porta '$tool' não existe no MacPorts; tentando alternativa"
    fallback_install "$tool" || true
  fi
done

# ----------------------------------------------------------------
# Opcional: rass
# ----------------------------------------------------------------
if [ "$WITH_RASS" -eq 1 ]; then
  info "Instalando rassumfrassum (rass)"
  if command -v pipx >/dev/null 2>&1; then
    pipx install rassumfrassum || pipx upgrade rassumfrassum
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user rassumfrassum
    add_path "$(python3 -m site --user-base)/bin"
  else
    warn "python3 não encontrado; pulei o rass."
  fi
  warn "Depois ponha (setq my/use-rass t) no init.el para ativar."
fi

# ----------------------------------------------------------------
# Verificação final
# ----------------------------------------------------------------
echo
status=0
verify || status=1

echo
if command -v emacs >/dev/null 2>&1; then
  ts="$(emacs --batch --eval '(princ (if (and (fboundp (quote treesit-available-p)) (treesit-available-p)) "yes" "no"))' 2>/dev/null || true)"
  if [ "$ts" = "yes" ]; then
    ok "Emacs com suporte a tree-sitter"
  else
    warn "Seu Emacs parece estar SEM suporte a tree-sitter."
    warn "Confira com M-: (treesit-available-p) e reinstale o Emacs com a variante de tree-sitter, se necessário."
  fi
else
  info "emacs não está no PATH; confira no Emacs com: M-: (treesit-available-p)"
fi

echo
if [ "$status" -eq 0 ]; then
  ok "Tudo certo. Reinicie o Emacs (o exec-path-from-shell relê o PATH) e rode: M-x my/treesit-install-all"
  info "Se trocar a versão padrão do Node (nvm alias default ...), rode este script de novo para atualizar $NVM_DIR/current."
else
  warn "Alguns binários não estão no PATH."
  warn "Reabra o terminal (o PATH novo foi gravado em $PROFILE) e rode: bash install-deps.sh --check"
  exit 1
fi
