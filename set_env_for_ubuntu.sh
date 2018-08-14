#!/usr/bin/env bash

# install develop env
apt-get install -y sudo
sudo apt-get update -y
sudo apt-get install -y build-essential git pkg-config ctags libjemalloc1 curl cmake software-properties-common tmux

# python
sudo apt-get install -y python3-dev python3-pip
sudo pip3 install -r ./requirements.txt

# sudo ln -s `which python3` $(dirname `which python3`)/python
# sudo ln -s `which pip3` $(dirname `which pip3`)/pip

# install vim and vim setup
# sudo apt-get install -y vim-gnome
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install vim

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cat ./vimrc >> ~/.vimrc
vim +PluginInstall +qall

python3 ~/.vim/bundle/YouCompleteMe/install.py --clang-completer

# set screen config
cat ./screenrc >> ~/.screenrc
# install zsh and oh-my-zsh
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# virtualenvwrapper
# export WORKON_HOME=~/envs
echo 'export VIRTUALENVWRAPPER_PYTHON=`which python3`' >> ~/.zshrc
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> ~/.zshrc

# java
sudo apt-get install -y default-jdk
if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.zshrc
fi

# set zsh to default
chsh -s /usr/bin/zsh
