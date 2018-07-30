#!/usr/bin/env bash

# install develop env
yum install -y sudo
sudo yum update -y
sudo yum install -y sudo
sudo yum install -y ctags libjemalloc1 screen curl cmake yum-utils groupinstall development gcc-c++ ncurses-devel

# python
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install python36u
sudo yum -y install python36u-pip
sudo yum -y install python36u-devel

sudo pip3.6 install -r ./requirements.txt

sudo ln -s `which python3.6` $(dirname `which python3.6`)/python3
sudo ln -s `which pip3.6` $(dirname `which pip3.6`)/pip3

# install vim and vim setup
# https://medium.com/@chusiang/install-the-vim-8-0-and-youcompleteme-with-make-on-centos-7-4-1573ad780953
git clone https://github.com/vim/vim.git
cd vim
./configure \
  --disable-nls \
  --enable-cscope \
  --enable-gui=no \
  --enable-multibyte  \
  --enable-rubyinterp=yes \
  --enable-python3interp=yes \
  --with-features=huge  \
  --with-python3-config-dir=/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu \
  --with-tlib=ncurses \
  --without-x
make && make install
cd ..

# --prefix=/home/jonny/.local/vim \


git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cat ./vimrc >> ~/.vimrc
vim +PluginInstall +qall

python3.6 ~/.vim/bundle/YouCompleteMe/install.py --clang-completer

# set screen config
cat ./screenrc >> ~/.screenrc
# install zsh and oh-my-zsh
sudo yum install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# virtualenvwrapper
# export WORKON_HOME=~/envs

echo 'export VIRTUALENVWRAPPER_PYTHON=`which python3.6`' >> ~/.zshrc
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/virtualenvwrapper_lazy.sh

# set zsh to default
chsh -s /usr/bin/zsh
