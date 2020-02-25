#!/usr/bin/env bash

# install develop env
apt-get install -y sudo
sudo apt-get update -y
sudo apt-get install -y build-essential \
                        git \
                        pkg-config \
                        ctags \
                        libjemalloc1 \
                        curl \
                        cmake \
                        software-properties-common \
                        tmux \
                        libopenmpi-dev \
                        zlib1g-dev \
                        wget

# 1) python
# sudo add-apt-repository ppa:jonathonf/python-3.6
# sudo apt-get update
# sudo apt-get install python3.6 python3.6-dev
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# python3.6 get-pip.py
# sudo pip3 install -r ./requirements.txt

# 2) miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir ~/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && echo PATH="$(cd ~; pwd -P)/miniconda3/bin":$PATH >> .bashrc \


# install vim and vim setup
# sudo apt-get install -y vim-gnome
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install -y vim

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cat ./vimrc >> ~/.vimrc
vim +PluginInstall +qall

python3 ~/.vim/bundle/YouCompleteMe/install.py --clang-completer

# set screen config
cat ./tmux.conf >> ~/.tmux.conf
# install zsh and oh-my-zsh
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# virtualenvwrapper
# export WORKON_HOME=~/envs
# echo 'export VIRTUALENVWRAPPER_PYTHON=`which python3`' >> ~/.zshrc
# echo 'source /usr/local/bin/virtualenvwrapper.sh' >> ~/.zshrc

# java
sudo apt-get install -y default-jdk
if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.zshrc
fi

# set zsh to default
chsh -s /usr/bin/zsh

# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
# echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
