#!/usr/bin/env bash

# install develop env
sudo apt-get update
sudo apt-get install -y build-essential 
sudo apt-get install -y git
sudo apt-get install -y pkg-config
sudo apt-get install -y libblas-dev liblapack-dev libxml2-dev libxslt1-dev python3-lxml
sudo apt-get install -y libatlas-base-dev gfortran

sudo apt-get install -y python3-dev python3-pip

sudo apt-get install -y default-jdk

if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.zshrc
fi


# install vim and vim setup
sudo apt-get install -y vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cat ./vimrc >> ~/.vimrc
vim +PluginInstall +qall

# install zsh and oh-my-zsh
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /usr/bin/zsh

sudo pip3 install virtualenv
