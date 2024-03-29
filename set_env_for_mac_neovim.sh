#!/usr/bin/env bash

# install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install stuffs
brew install cmake
brew install tmux
brew install neovim
brew install lazygit

# install font
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

mkdir -p ~/.config
cp -r ./config/* ~/.config/

# install zsh and oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /usr/bin/zsh


