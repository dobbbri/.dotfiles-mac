#!/bin/bash

echo "install mac ports ---------------------------------------------------"

sudo port install stow eza wget nvm alacritty kitty neovim go ripgrep ttf-nerd-fonts-symbols

echo "install oh-my-zsh ---------------------------------------------------"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# wget -P ~/.oh-my-zsh/custom/themes https://raw.githubusercontent.com/moarram/headline/main/headline.zsh-theme

cp ~/.zshrc ~/.zshrc.original
rm ~/.zshrc

echo "\.DS_Store" >> ~/.stow-global-ignore


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

echo "copy docker ------------------------------------------------------------"

mkdir -p ~/Work

cp -r ~/.dotfiles-mac/docker/wordpress-local-dev/ ~/Work/
