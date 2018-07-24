#!/usr/bin/env bash

# install vim and vim setup
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cat ./vimrc >> ~/.vimrc
vim +PluginInstall +qall

~/.vim/bundle/YouCompleteMe/install.py --js-completer --clang-completer

cat ./screenrc >> ~/.screenrc

# install zsh and oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /usr/bin/zsh

