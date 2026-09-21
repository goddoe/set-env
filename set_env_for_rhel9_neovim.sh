#!/usr/bin/env bash
# RHEL9 계열(Navix / Rocky / Alma / CentOS Stream 9) 용.
# set_env_for_ubuntu_neovim.sh 와 1:1 대응. 비대화형으로 동작하도록 작성.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SRC_DIR="${SRC_DIR:-$HOME/.local/src}"
mkdir -p "$SRC_DIR"

step() { echo; echo "==================== $* ===================="; }

# ---------------------------------------------------------------------------
# install develop env
#   build-essential      -> gcc gcc-c++ make
#   pkg-config           -> pkgconf-pkg-config
#   exuberant-ctags      -> (repo 에 없음) universal-ctags 소스 빌드
#   libopenmpi-dev       -> openmpi-devel
#   zlib1g-dev           -> zlib-devel
#   luarocks             -> (repo 에 없음) 소스 빌드, lua-devel 필요
#   language-pack-ko     -> glibc-langpack-ko
#   software-properties-common -> 해당 없음
#   + neovim 소스 빌드에 필요한 cmake ninja-build gettext unzip
# ---------------------------------------------------------------------------
step "dnf install"
sudo dnf install -y --setopt=strict=0 \
    gcc gcc-c++ make autoconf automake libtool \
    git pkgconf-pkg-config curl wget unzip \
    cmake ninja-build gettext \
    tmux \
    openmpi-devel zlib-devel \
    fontconfig \
    lua lua-devel \
    glibc-langpack-ko \
    jansson-devel libyaml-devel libxml2-devel pcre2-devel \
    zsh \
    java-17-openjdk-devel

# ---------------------------------------------------------------------------
# install uv
# ---------------------------------------------------------------------------
step "uv"
if ! command -v uv >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/uv" ]; then
    wget -qO- https://astral.sh/uv/install.sh | sh
fi

# ---------------------------------------------------------------------------
# install neovim (source build, stable branch)
# ---------------------------------------------------------------------------
step "neovim"
if [ ! -d "$SRC_DIR/neovim" ]; then
    git clone --depth 1 --branch stable https://github.com/neovim/neovim.git "$SRC_DIR/neovim"
fi
pushd "$SRC_DIR/neovim" >/dev/null
make CMAKE_BUILD_TYPE=Release && sudo make install
popd >/dev/null

# update-alternatives 대응.
# RHEL 의 /usr/bin/vim 은 rpm 소유 실파일이므로 건드리지 않고
# PATH 상 앞에 있는 /usr/local/bin 에 alternatives 링크를 만든다.
step "alternatives (vim/editor -> nvim)"
sudo alternatives --install /usr/local/bin/vim    vim    /usr/local/bin/nvim 110
sudo alternatives --install /usr/local/bin/editor editor /usr/local/bin/nvim 110

# ---------------------------------------------------------------------------
# install universal-ctags (exuberant-ctags 대응)
# ---------------------------------------------------------------------------
step "universal-ctags"
if ! command -v ctags >/dev/null 2>&1; then
    if [ ! -d "$SRC_DIR/ctags" ]; then
        git clone --depth 1 https://github.com/universal-ctags/ctags.git "$SRC_DIR/ctags"
    fi
    pushd "$SRC_DIR/ctags" >/dev/null
    ./autogen.sh && ./configure --prefix=/usr/local && make -j"$(nproc)" && sudo make install
    popd >/dev/null
fi

# ---------------------------------------------------------------------------
# install nvchad
# ---------------------------------------------------------------------------
step "nvchad"
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/goddoe/nvchad-starter.git "$HOME/.config/nvim" --depth 1
fi

# ---------------------------------------------------------------------------
# luarocks (repo 에 없어 소스 빌드) + dkjson (need for nvim-ai-assistant)
# ---------------------------------------------------------------------------
step "luarocks + dkjson"
LUAROCKS_VERSION="${LUAROCKS_VERSION:-3.11.1}"
if [ ! -x /usr/local/bin/luarocks ]; then
    pushd "$SRC_DIR" >/dev/null
    wget -q "https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz" \
        && tar zxf "luarocks-${LUAROCKS_VERSION}.tar.gz" \
        && pushd "luarocks-${LUAROCKS_VERSION}" >/dev/null \
        && ./configure --prefix=/usr/local --with-lua-include=/usr/include \
        && make && sudo make install
    popd >/dev/null 2>&1 || true
    popd >/dev/null
fi
sudo /usr/local/bin/luarocks install dkjson
# neovim 은 lua 5.1(luajit) 경로를 보므로 5.4 에 설치된 dkjson 을 5.1 경로에도 링크
LUA_VER="$(lua -e 'print(_VERSION:match("%d+%.%d+"))')"
if [ -f "/usr/local/share/lua/${LUA_VER}/dkjson.lua" ] && [ "$LUA_VER" != "5.1" ]; then
    sudo mkdir -p /usr/local/share/lua/5.1
    sudo ln -sf "/usr/local/share/lua/${LUA_VER}/dkjson.lua" /usr/local/share/lua/5.1/dkjson.lua
fi

# ---------------------------------------------------------------------------
# install font (fontconfig 표준 경로 사용)
# ---------------------------------------------------------------------------
step "font"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if ! ls "$FONT_DIR"/JetBrainsMono*NerdFont*.ttf >/dev/null 2>&1; then
    pushd "$FONT_DIR" >/dev/null
    # Ref: https://www.nerdfonts.com/#home
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/JetBrainsMono.zip \
        && unzip -o -q JetBrainsMono.zip && rm -f JetBrainsMono.zip
    popd >/dev/null
fi
fc-cache -f

# ---------------------------------------------------------------------------
# set dotfiles
# ---------------------------------------------------------------------------
step "dotfiles"
mkdir -p ~/.config
cp -r "$REPO_DIR"/config/* ~/.config/

# ---------------------------------------------------------------------------
# install lazygit
# ---------------------------------------------------------------------------
step "lazygit"
if ! command -v lazygit >/dev/null 2>&1; then
    LAZYGIT_VERSION=$(curl -sI https://github.com/jesseduffield/lazygit/releases/latest | grep -i "^location:" | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | tr -d "v")
    pushd "$SRC_DIR" >/dev/null
    curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
        && tar xf lazygit.tar.gz lazygit \
        && sudo install lazygit /usr/local/bin \
        && rm -f lazygit lazygit.tar.gz
    popd >/dev/null
fi

# ---------------------------------------------------------------------------
# Set Korean
#   locale-gen / dpkg-reconfigure locales -> glibc-langpack-ko 설치로 대체
#   update-locale                         -> localectl set-locale
# ---------------------------------------------------------------------------
step "locale"
sudo localectl set-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX

# ---------------------------------------------------------------------------
# install zsh and oh-my-zsh (비대화형)
# ---------------------------------------------------------------------------
step "oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# zsh 는 .bash_profile 을 읽지 않아 ~/.local/bin 이 PATH 에 없다. uv 설치기의 env 파일은
# uv 가 이미 설치돼 있으면 생성되지 않으므로 존재를 가정하지 말고 PATH 를 직접 넣는다.
step "zsh PATH (~/.local/bin)"
if ! grep -q 'export PATH="$HOME/.local/bin:$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc <<'ZRC'

# user-local binaries (uv, claude, ...). uv 설치기의 env 파일은 있을 때만 읽는다.
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
ZRC
fi

# ---------------------------------------------------------------------------
# java (default-jdk -> java-17-openjdk-devel)
#   /usr/lib/jvm/java 는 alternatives(java_sdk) 가 관리하는 심볼릭 링크
# ---------------------------------------------------------------------------
step "JAVA_HOME"
if [ -z "${JAVA_HOME:-}" ]; then
    export JAVA_HOME=/usr/lib/jvm/java
    grep -q 'export JAVA_HOME=' ~/.bashrc 2>/dev/null || echo "export JAVA_HOME=/usr/lib/jvm/java" >> ~/.bashrc
    grep -q 'export JAVA_HOME=' ~/.zshrc  2>/dev/null || echo "export JAVA_HOME=/usr/lib/jvm/java" >> ~/.zshrc
fi

# ---------------------------------------------------------------------------
# set zsh to default
# ---------------------------------------------------------------------------
step "chsh"
sudo chsh -s /usr/bin/zsh "$USER"

step "done"
