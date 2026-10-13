#!/bin/bash
# to make execurable
# chmod +x install_nodejs.sh

echo "- Install Nodejs@24, npm and pnpm --------------------------------------------------"
sudo port install nvm -cf

nvm install 24

# sudo port install pnpm && corepack enable

echo "- Install NPM packages --------------------------------------------------"
npm i -g @ast-grep/cli npm-check-updates typescript typescript-language-server vscode-langservers-extracted eslint prettier biome