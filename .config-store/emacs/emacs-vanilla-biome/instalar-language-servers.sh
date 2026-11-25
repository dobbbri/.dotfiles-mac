#!/usr/bin/env bash
# Instala os language servers usados na config do Doom Emacs (Fedora).
# Uso: ./instalar-language-servers.sh
set -euo pipefail

PREFIX="${HOME}/.local"

# Node.js e npm (via dnf, só se faltarem)
if ! command -v npm >/dev/null 2>&1; then
  echo ">> npm não encontrado. Instalando nodejs e npm (pede sudo)..."
  sudo dnf install -y nodejs npm
fi

# Pacotes npm instalados em ~/.local, sem sudo
PACOTES=(
  @astrojs/language-server     # astro-ls (.astro)
  typescript-language-server   # TypeScript / JavaScript
  vscode-langservers-extracted # HTML, CSS, JSON
  yaml-language-server         # YAML
  bash-language-server         # shell scripts
  @biomejs/biome               # formatador e linter (substitui Prettier e ESLint)
)

for pkg in "${PACOTES[@]}"; do
  echo ">> Instalando ${pkg}..."
  npm install -g --prefix "$PREFIX" "$pkg"
done

echo
echo ">> Instalados em ${PREFIX}/bin:"
for bin in astro-ls typescript-language-server vscode-html-language-server \
           yaml-language-server bash-language-server biome; do
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
     echo "Adicione ao ~/.bashrc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

cat <<'EOF'

Próximos passos:
  1. No projeto Astro, instale o Biome local (a versão deve bater com o
     "$schema" do biome.json) e o TypeScript:
       npm i -D --save-exact @biomejs/biome typescript@6
  2. Se o projeto ainda usa Prettier/ESLint, migre as regras e remova-os:
       npx biome migrate prettier --write
       npx biome migrate eslint --write
       npm rm prettier prettier-plugin-astro eslint
     e apague .prettierrc*, .prettierignore e eslint.config.* / .eslintrc*.
  3. Reinicie o Emacs (a config nova usa `npx biome` no projeto e o
     biome de ~/.local/bin como reserva).
EOF
