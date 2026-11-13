#!/usr/bin/env bash
# Instala os language servers usados na config do Emacs (macOS, via MacPorts).
# Uso: ./instalar-language-servers-macos.sh
set -euo pipefail

PREFIX="${HOME}/.local"

# Portas do Node.js e do npm no MacPorts. Confira as versões atuais com:
#   port search nodejs   e   port search npm
NODE_PORT="nodejs22"
NPM_PORT="npm10"

# O MacPorts instala em /opt/local; garante que o script o enxergue
export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"

# Node.js e npm (via MacPorts, só se faltarem)
if ! command -v npm >/dev/null 2>&1; then
  if ! command -v port >/dev/null 2>&1; then
    echo "ERRO: npm não encontrado e o MacPorts (port) não está instalado."
    echo "Instale o MacPorts em https://www.macports.org/install.php e rode de novo."
    exit 1
  fi
  echo ">> npm não encontrado. Instalando ${NODE_PORT} e ${NPM_PORT} (pede sudo)..."
  sudo port install "$NODE_PORT" "$NPM_PORT"
  sudo port select --set nodejs "$NODE_PORT" || echo "AVISO: não consegui selecionar ${NODE_PORT}."
  sudo port select --set npm "$NPM_PORT" || echo "AVISO: não consegui selecionar ${NPM_PORT}."
  hash -r
  if ! command -v npm >/dev/null 2>&1; then
    echo "ERRO: o npm continua indisponível. Confira os nomes com 'port search npm'."
    exit 1
  fi
fi

# Pacotes npm instalados em ~/.local, sem sudo
PACOTES=(
  @astrojs/language-server     # astro-ls (.astro)
  typescript-language-server   # TypeScript / JavaScript
  vscode-langservers-extracted # HTML, CSS, JSON
  yaml-language-server         # YAML
  bash-language-server         # shell scripts
  prettier                     # formatador
)

for pkg in "${PACOTES[@]}"; do
  echo ">> Instalando ${pkg}..."
  npm install -g --prefix "$PREFIX" "$pkg"
done

echo
echo ">> Instalados em ${PREFIX}/bin:"
for bin in astro-ls typescript-language-server vscode-html-language-server \
           yaml-language-server bash-language-server prettier; do
  if [ -x "${PREFIX}/bin/${bin}" ]; then
    echo "   ok  ${bin}"
  else
    echo "   FALTA ${bin}"
  fi
done

case ":${PATH}:" in
  *":${PREFIX}/bin:"*) ;;
  *) echo
     echo "AVISO: ${PREFIX}/bin não está no PATH."
     echo "Adicione ao ~/.zshrc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

cat <<'EOF'

Próximos passos:
  1. No projeto Astro:  npm i -D typescript@6 prettier-plugin-astro
  2. O Emacs aberto pelo Dock ou pelo Finder não herda o PATH do terminal.
     - Doom Emacs: rode `doom env` e reinicie o Emacs.
     - Config do zero: instale o pacote `exec-path-from-shell`.
EOF
