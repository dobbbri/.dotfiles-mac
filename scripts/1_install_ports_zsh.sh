#!/bin/bash

echo "install mac ports ---------------------------------------------------"

sudo port install stow eza wget nvm alacritty kitty fzf viu chafa neovim go ripgrep colima docker-compose 

echo "install oh-my-zsh ---------------------------------------------------"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "install Nerd Fonts -------------------------------------------------------------"

curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
getnf && fc-cache -f

cp ~/.zshrc ~/.zshrc.original
rm ~/.zshrc

echo "\.DS_Store" >>~/.stow-global-ignore

echo "run stow -------------------------------------------------------------"

cd ~/.dotfiles-mac/
mkdir -p ~/.config/_BKP

mv ~/.config/alacritty ~/.config/_BKP/
mv ~/.config/nvim ~/.config/_BKP/
mv ~/.config/kitty ~/.config/_BKP/

stow config/
stow home/

echo "fix ssh permission -----------------------------------------------------"
cd ~ && ./.ssh/fix_ssh_permission.sh

