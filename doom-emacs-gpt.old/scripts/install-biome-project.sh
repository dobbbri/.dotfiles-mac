#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMPLATE="$ROOT_DIR/templates/biome.json"
PROJECT_DIR="${1:-.}"

[[ -d "$PROJECT_DIR" ]] || {
  printf '[ERRO] Diretório de projeto não encontrado: %s\n' "$PROJECT_DIR" >&2
  exit 1
}

command -v npm >/dev/null 2>&1 || {
  printf '[ERRO] npm não encontrado no PATH.\n' >&2
  exit 1
}

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd -P)"
cd "$PROJECT_DIR"

if [[ ! -f package.json ]]; then
  printf '[INFO] package.json não encontrado; criando um projeto npm básico.\n'
  npm init -y
fi

printf '[INFO] Instalando Biome 2.5 localmente em %s\n' "$PROJECT_DIR"
npm install --save-dev '@biomejs/biome@~2.5.0'

if [[ -e biome.json || -e biome.jsonc ]]; then
  printf '[INFO] biome.json/biome.jsonc já existe; não será sobrescrito.\n'
else
  cp "$TEMPLATE" biome.json
  printf '[INFO] Criado biome.json a partir do template.\n'
fi

printf '\nConcluído. Verifique a versão e execute:\n'
printf '  npx biome --version\n'
printf '  npx biome check .\n'
printf '  npx biome check --write .\n'
