#!/usr/bin/env bash


# install develop env
apt install -y sudo
sudo apt update -y
sudo apt install -y build-essential \
                        git \
                        pkg-config \
                        exuberant-ctags \
                        curl \
                        cmake \
                        software-properties-common \
                        tmux \
                        libopenmpi-dev \
                        zlib1g-dev \
                        fontconfig \
                        luarocks \
                        language-pack-ko \
                        wget


# libjemalloc1 \


# # install miniconda
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#     && mkdir ~/.conda \
#     && bash Miniconda3-latest-Linux-x86_64.sh -b \
#     && rm -f Miniconda3-latest-Linux-x86_64.sh \
#     && echo PATH="$(cd ~; pwd -P)/miniconda3/bin":$PATH >> .bashrc

# install uv
wget -qO- https://astral.sh/uv/install.sh | sh

# install neovim
# sudo apt install neovim
git clone https://github.com/neovim/neovim.git
pushd neovim
make CMAKE_BUILD_TYPE=Release
sudo make install
popd

sudo update-alternatives --install `which vim` vim `which nvim` 110
sudo update-alternatives --install `which editor` editor `which nvim` 110

sudo update-alternatives --config vim

# install nvchad
git clone https://github.com/goddoe/nvchad-starter.git ~/.config/nvim --depth 1

# need for nvim-ai-assistant
sudo luarocks install dkjson

# install font
FONT_DIR="$HOME/.font"
mkdir ${FONT_DIR}
pushd ${FONT_DIR}
# Ref: https://www.nerdfonts.com/#home
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/JetBrainsMono.zip
unzip JetBrainsMono.zip
popd

fc-cache -fv

# set dotfiles
mkdir -p ~/.config
cp -r ./config/* ~/.config/

# install layzy git
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin


## Set Korean
# set locale
sudo locale-gen ko_KR.UTF-8

# find ko_KR.UTF-8 and set the number of ko_KR.UTF-8
sudo dpkg-reconfigure locales

sudo update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX


# install zsh and oh-my-zsh
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

sudo apt-get install -y default-jdk
if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.zshrc
fi


sudo chsh -s /usr/bin/zsh

