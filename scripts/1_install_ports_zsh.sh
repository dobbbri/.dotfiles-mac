#!/bin/bash

echo "install mac ports ---------------------------------------------------"

sudo port install stow eza wget tree wezterm fd bat fzf viu chafa neovim go ripgrep

echo "install oh-my-zsh ---------------------------------------------------"


echo "install Nerd Fonts -------------------------------------------------------------"

curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
$HOME/.local/bin/getnf && fc-cache -f

echo "run stow -------------------------------------------------------------"

cd ~/.dotfiles-mac/
mkdir -p ~/.config/_BKP

mv ~/.config/alacritty ~/.config/_BKP/
mv ~/.config/nvim ~/.config/_BKP/
mv ~/.config/kitty ~/.config/_BKP/

cp ~/.zshrc ~/.zshrc.original
rm ~/.zshrc

echo "\.DS_Store" >>~/.stow-global-ignore

stow config/
stow home/

echo "fix ssh permission -----------------------------------------------------"
cd ~ && ./.ssh/fix_ssh_permission.sh
