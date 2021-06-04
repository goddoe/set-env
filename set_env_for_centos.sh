#!/usr/bin/env bash

# install develop env
#  yum install -y sudo
yum update -y
yum install -y ctags libjemalloc1 curl make yum-utils groupinstall development gcc-c++ ncurses-devel less openssh-clients perl which perl-Error tmux openssh-server xorg xauth 

# install devtools 8 
yum install -y centos-release-scl
yum install -y devtoolset-8
scl enable devtoolset-8 -- bash

# install cmake
wget https://github.com/Kitware/CMake/archive/refs/tags/v3.14.5.tar.gz

tar -zxf v3.14.5.tar.gz
pushd CMake-3.14.5
./bootstrap --prefix=/usr/local
make && make install 
popd


# python
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir ~/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh


# install git 2.x +
# https://www.lesstif.com/pages/viewpage.action?pageId=14745759
# CentOS6
# rpm -Uvh http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
# CentOS7
rpm -Uvh http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm
yum --enablerepo=WANdisco-git --disablerepo=base,updates install -y git

# install vim and vim setup
# https://medium.com/@chusiang/install-the-vim-8-0-and-youcompleteme-with-make-on-centos-7-4-1573ad780953
yum-builddep -y vim-X11
git clone https://github.com/vim/vim.git

# python3_config_dir=`realpath ~/miniconda3/lib/python3.8/config-3.8-x86_64-linux-gnu`

cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local
cd ..

# --prefix=/home/jonny/.local/vim \


git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cat ./vimrc >> ~/.vimrc
vim +PluginInstall +qall

~/miniconda3/bin/python3 ~/.vim/bundle/YouCompleteMe/install.py --clang-completer

# set screen config
cat ./tmux.conf >> ~/.tmux.conf
# install zsh and oh-my-zsh
yum install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# virtualenvwrapper
# export WORKON_HOME=~/envs

# echo 'export VIRTUALENVWRAPPER_PYTHON=`which python3.6`' >> ~/.zshrc
# export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
# source /usr/local/bin/virtualenvwrapper_lazy.sh

# set zsh to default
chsh -s /usr/bin/zsh

# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
# echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
