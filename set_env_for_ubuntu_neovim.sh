#!/usr/bin/env bash


# install develop env
apt install -y sudo
sudo apt update -y
sudo apt install -y build-essential \
                        git \
                        pkg-config \
                        exuberant-ctags \
                        libjemalloc1 \
                        curl \
                        cmake \
                        software-properties-common \
                        tmux \
                        libopenmpi-dev \
                        zlib1g-dev \
                        fontconfig \
                        luarocks \
                        wget



# install miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir ~/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && echo PATH="$(cd ~; pwd -P)/miniconda3/bin":$PATH >> .bashrc


# install neovim
sudo apt install neovim

# install nvchad
# git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
git clone https://github.com/goddoe/NvChad.git ~/.config/nvim --depth 1

# need for nvim-ai-assistant
sudo luarocks install dkjson

# install fish shell
# Ref: https://fishshell.com
# sudo apt-get install software-properties-common
# sudo apt-add-repository ppa:fish-shell/release-3
# sudo apt update
# sudo apt install fish


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
