#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles-mac"
PKG_NAME="doom-emacs-lsp"
DOOM_PKG="$DOTFILES_DIR/$PKG_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Node.js via nvm (porta `nvm' do MacPorts). Versão principal desejada:
NODE_VERSION="22"
NVM_INIT="/opt/local/share/nvm/init-nvm.sh"

# Pacotes npm globais (LSPs, Biome) ficam em ~/.local, sem sudo: não dependem do
# MacPorts e sobrevivem às atualizações do Node.
PREFIX="$HOME/.local"
PATH_ORIGINAL="$PATH"

# O MacPorts instala em /opt/local; garante que o script o enxergue
export PATH="${PREFIX}/bin:/opt/local/bin:/opt/local/sbin:${PATH}"

echo "=================================================================="
echo " Instalando Doom Emacs + Emacs 31.1 (MacPorts, Stow, Astro & TW)"
echo "=================================================================="

# 0. Pré-requisitos
if ! xcode-select -p >/dev/null 2>&1; then
  echo "--> Instale as Xcode Command Line Tools primeiro: xcode-select --install"
  exit 1
fi

if ! command -v port >/dev/null 2>&1; then
  echo "--> MacPorts (port) não encontrado. Instale em https://www.macports.org/install.php e rode de novo."
  exit 1
fi

if [ ! -d "$DOOM_PKG" ]; then
  echo "--> Pasta $DOOM_PKG não encontrada. Verifique seus dotfiles."
  exit 1
fi

for f in init.el config.el packages.el; do
  if [ ! -f "$DOOM_PKG/.config/doom/$f" ]; then
    echo "--> Faltando $DOOM_PKG/.config/doom/$f (copie seus arquivos do Doom para lá)."
    exit 1
  fi
done

# 1. Atualizar MacPorts e instalar Emacs 31.1 + dependências (as gramáticas vêm do build-grammars.sh)
echo "--> Instalando GNU Emacs 31.1 e dependências via MacPorts..."
sudo port selfupdate
sudo port install emacs-app @31.1 +treesitter +nativecomp
sudo port install ripgrep fd git stow nvm cmake libtool shfmt shellcheck

# Node.js e npm via nvm (o nvm é uma função de shell: precisa ser carregado)
if [ ! -s "$NVM_INIT" ]; then
  echo "ERRO: $NVM_INIT não encontrado. Confira a instalação com 'port contents nvm'."
  exit 1
fi
# O nvm não é compatível com `set -eu': desliga só durante este bloco
set +eu
# shellcheck disable=SC1090
source "$NVM_INIT"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION" >/dev/null
NODE_BIN_DIR="$(dirname "$(nvm which "$NODE_VERSION")")"
set -eu

if [ ! -x "$NODE_BIN_DIR/node" ] || [ ! -x "$NODE_BIN_DIR/npm" ]; then
  echo "ERRO: node/npm não encontrados em $NODE_BIN_DIR após 'nvm install $NODE_VERSION'."
  exit 1
fi

# Links estáveis em ~/.local/bin: o Emacs (GUI) não carrega o nvm, e os servidores
# LSP precisam de `node' no PATH. O caminho do nvm muda a cada versão; este não.
mkdir -p "$PREFIX/bin"
for b in node npm npx; do
  ln -sf "$NODE_BIN_DIR/$b" "$PREFIX/bin/$b"
done

# 2. Instalar servidores LSP (TypeScript 6, Astro, Tailwind) e BiomeJS em ~/.local (sem sudo)
echo "--> Instalando Astro LS, Tailwind LS, TypeScript 6, BiomeJS, stylelint e js-beautify em ${PREFIX}..."
npm install -g --prefix "$PREFIX" typescript@6 typescript-language-server @astrojs/language-server @tailwindcss/language-server @biomejs/biome stylelint js-beautify

# 3. Criar diretórios necessários (inclui a pasta de snippets do yasnippet)
mkdir -p ~/.config/doom
mkdir -p ~/org/daily
mkdir -p "$DOOM_PKG/.config/doom/snippets"
touch "$DOOM_PKG/.config/doom/snippets/.gitkeep"

# 4. Compilar TODAS as gramáticas tree-sitter em ~/.local/lib/tree-sitter
if [ -x "$SCRIPT_DIR/build-grammars.sh" ]; then
  echo "--> Compilando gramáticas tree-sitter..."
  "$SCRIPT_DIR/build-grammars.sh"
else
  echo "--> build-grammars.sh não encontrado ao lado do install.sh; pulando gramáticas."
  echo "    (depois rode M-x treesit-install-language-grammar RET astro no Emacs)"
fi

# 5. Aplicar links simbólicos com GNU Stow (ANTES do doom install, para o Doom já achar a config)
echo "--> Aplicando dotfiles com GNU Stow..."
cd "$DOTFILES_DIR"
stow -v -R -t "$HOME" "$PKG_NAME"

# 6. Clonar o Doom Emacs oficial se ainda não existir
if [ ! -d "$HOME/.config/emacs" ]; then
  echo "--> Clonando repositório oficial do Doom Emacs..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  # O `doom install' roda sem o config.el: os links no cache do Doom evitam o aviso
  # "grammar for astro failed to load" ao instalar o astro-ts-mode.
  "$SCRIPT_DIR/build-grammars.sh" --link-only || true
  ~/.config/emacs/bin/doom install --no-config
else
  echo "--> Doom Emacs já encontrado em ~/.config/emacs"
  "$SCRIPT_DIR/build-grammars.sh" --link-only || true
fi

# 7. Sincronizar o Doom, capturar o ambiente do macOS e rodar o doctor.
#    Tudo vai para um log em ~/.local/state/doom-emacs/ (e também para a tela).
DOOM_BIN="$HOME/.config/emacs/bin/doom"
LOG_DIR="$HOME/.local/state/doom-emacs"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$LOG_DIR"

# Roda um comando mostrando a saída na tela e gravando no log;
# devolve o código de saída do comando (não o do tee).
run_logged() {
  local titulo="$1"; shift
  echo "--> $titulo"
  { echo "=== $titulo ($(date '+%F %T')) ==="; "$@"; } 2>&1 | tee -a "$LOG_FILE"
  return "${PIPESTATUS[0]}"
}

SYNC_STATUS=0
DOCTOR_STATUS=0
run_logged "doom sync --env (pacotes e ambiente)" "$DOOM_BIN" sync --env || SYNC_STATUS=$?
run_logged "doom doctor (diagnóstico)" "$DOOM_BIN" doctor || DOCTOR_STATUS=$?

echo
echo "Log salvo em: $LOG_FILE"
[ "$SYNC_STATUS" -eq 0 ]   || echo "AVISO: 'doom sync' terminou com código $SYNC_STATUS. Veja o log."
[ "$DOCTOR_STATUS" -eq 0 ] || echo "AVISO: 'doom doctor' encontrou problemas (código $DOCTOR_STATUS). Veja o log:  grep -n -i 'error\|warn' \"$LOG_FILE\""

case ":${PATH_ORIGINAL}:" in
  *":${PREFIX}/bin:"*) ;;
  *)
    echo
    echo "AVISO: ${PREFIX}/bin não está no PATH do seu shell (o Emacs já o inclui)."
    echo "Adicione ao ~/.zshrc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo
echo "Para usar node/npm no terminal, adicione ao ~/.zshrc:"
echo "  source $NVM_INIT"
echo "=================================================================="
echo " Instalação concluída! Abra /Applications/MacPorts/Emacs.app"
echo " Teste as gramáticas com:"
echo "   M-: (treesit-language-available-p 'astro)"
echo
echo " No projeto Astro, use o Biome local (versão igual à do \$schema do biome.json):"
echo "   npm i -D --save-exact @biomejs/biome"
echo "=================================================================="
