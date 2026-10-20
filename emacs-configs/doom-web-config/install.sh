#!/bin/bash
echo 'clone doomemacs' &&
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs &&
  echo 'install doom' &&
  ~/.config/emacs/bin/doom install &&
  echo 'create doom folder in ~/.config/doom' &&
  mkdir -p ~/.config/doom &&
  echo 'copy doom config files to ~/.config/doom' &&
  cd ~/.dotfiles-mac/doom-web-config/doom/init.el ~/.dotfiles-mac/doom-web-config/doom/config.el ~/.dotfiles-mac/doom-web-config/doom/packages.el ~/.config/doom/ &&
  echo 'run doom sync e doom doctor' &&
  doom sync && doom doctor
