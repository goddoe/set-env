#!/usr/bin/env bash

# install develop env
apt-get install -y sudo
sudo apt-get update -y
sudo apt-get install -y build-essential git pkg-config ctags libjemalloc1 screen curl cmake

# install vim and vim setup
sudo apt-get install -y vim-gnome
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cat ./vimrc >> ~/.vimrc
vim +PluginInstall +qall

export python=python3
~/.vim/bundle/YouCompleteMe/install.py --clang-completer

# set screen config
cat ./screenrc >> ~/.screenrc

# python
sudo apt-get install -y python3-dev python3-pip
sudo pip3 install -r ./requirements.txt

# install zsh and oh-my-zsh
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /usr/bin/zsh

# java
sudo apt-get install -y default-jdk
if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.zshrc
fi
