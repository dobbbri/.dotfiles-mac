#!/bin/bash

echo "install mac ports ---------------------------------------------------"

sudo port install stow -cf
sudo port install wget -cf
sudo port install tree -cf
sudo port install fd -cf
sudo port install bat -cf
sudo port install fzf -cf
sudo port install neovim -cf
sudo port install go -cf
sudo port install ripgrep -cf
sudo port install rust -cf
sudo port install cargo -cf
sudo port install eza -cf
sudo port install wezterm -cf
sudo port install bottom -cf
sudo port install lazygit -cf

echo "install oh-my-zsh ---------------------------------------------------"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "install Nerd Fonts --------------------------------------------------"
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
$HOME/.local/bin/getnf && fc-cache -f

echo "save screenshots to a folder------------------------------------------"
mkdir "${HOME}/screenshots"
defaults write com.apple.screencapture location -string "${HOME}/screenshots"

echo "run stow ------------------------------------------------------------"

cd ~/.dotfiles-mac/
mkdir -p ~/.config/_BKP

mv ~/.config/alacritty ~/.config/_BKP/
mv ~/.config/nvim ~/.config/_BKP/
mv ~/.config/kitty ~/.config/_BKP/

mv ~/.zshrc ~/.zshrc-original

echo "\.DS_Store" >>~/.stow-global-ignore

stow config/
stow home/

echo "fix ssh permission -----------------------------------------------------"
cd ~ && ./.ssh/fix_ssh_permission.sh
