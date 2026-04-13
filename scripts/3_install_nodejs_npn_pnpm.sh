#!/bin/bash
# to make execurable
# chmod +x install_nodejs.sh 

echo "- Install Nodejs@22, npm and pnpm --------------------------------------------------"
sudo port install nvm && nvm install 22

sudo port install pnpm && corepack enable


echo "- Install NPM packages --------------------------------------------------"
npm i -g @ast-grep/cli npm-check-updates 
npm i -g neovim tree-sitter-cli typescript typescript-language-server