# 구성요소별 패키지 이름 매핑

원본(`set_env_for_ubuntu_neovim.sh`, apt 기준) → 다른 패키지 매니저. "소스" 는 저장소에 없어 소스 빌드가 필요했거나 그럴 가능성이 큰 것.
`-` 는 해당 없음/불필요. 실제 존재 여부는 항상 `detect_env.sh` 결과로 확인한다(미러마다 다르다).

| 구성요소 | apt (Ubuntu/Debian) | dnf (RHEL9 계열/Fedora) | brew (macOS) | pacman (Arch) | apk (Alpine) |
|---|---|---|---|---|---|
| 컴파일러/make | build-essential | gcc gcc-c++ make (또는 `@"Development Tools"`) | Xcode CLT (`xcode-select --install`) | base-devel | build-base |
| autotools (ctags 빌드용) | autoconf automake libtool | autoconf automake libtool | autoconf automake libtool | base-devel | autoconf automake libtool |
| git | git | git | git | git | git |
| pkg-config | pkg-config | pkgconf-pkg-config | pkg-config | pkgconf | pkgconf |
| ctags | exuberant-ctags 또는 universal-ctags | (없음) → 소스 `universal-ctags/ctags` | universal-ctags | ctags | ctags |
| curl / wget / unzip | curl wget unzip | curl wget unzip | (기본) wget | curl wget unzip | curl wget unzip |
| cmake | cmake | cmake | cmake | cmake | cmake |
| ninja (nvim 빌드) | ninja-build | ninja-build (CRB/codeready) | ninja | ninja | ninja |
| gettext (nvim 빌드) | gettext | gettext | gettext | gettext | gettext-dev |
| software-properties-common | software-properties-common | - | - | - | - |
| tmux | tmux | tmux | tmux | tmux | tmux |
| OpenMPI dev | libopenmpi-dev | openmpi-devel | open-mpi | openmpi | openmpi-dev |
| zlib dev | zlib1g-dev | zlib-devel | (기본) | zlib | zlib-dev |
| fontconfig | fontconfig | fontconfig | (기본) | fontconfig | fontconfig |
| lua + 헤더 | lua5.1 liblua5.1-dev (또는 5.4) | lua lua-devel (CRB) | lua | lua | lua5.4 lua5.4-dev |
| luarocks | luarocks | (없음) → 소스 luarocks.org | luarocks | luarocks | luarocks |
| 한국어 로케일 | language-pack-ko + `locale-gen ko_KR.UTF-8` | glibc-langpack-ko | - (기본 포함) | `/etc/locale.gen` 편집 + locale-gen | musl-locales |
| neovim ≥0.11 | (apt 는 구버전) → 소스 stable 또는 GitHub release tarball | (없음) → 소스 stable | neovim | neovim | neovim |
| lazygit | GitHub release tarball | GitHub release tarball | lazygit | lazygit | lazygit (edge) |
| uv | `curl -LsSf https://astral.sh/uv/install.sh \| sh` | 동일 | brew install uv 또는 동일 | 동일 | 동일 |
| Nerd Font | GitHub release zip → `~/.local/share/fonts` | 동일 | `brew install --cask font-jetbrains-mono-nerd-font` | 동일 | 동일 |
| zsh | zsh | zsh | (기본) | zsh | zsh |
| JDK | default-jdk | java-17-openjdk-devel (또는 21) | openjdk@17 | jdk17-openjdk | openjdk17 |
| JAVA_HOME | /usr/lib/jvm/default-java | /usr/lib/jvm/java | `$(/usr/libexec/java_home)` | /usr/lib/jvm/default | /usr/lib/jvm/java-17-openjdk |
| 로케일 시스템 설정 | `update-locale LANG=... LC_MESSAGES=POSIX` | `localectl set-locale LANG=... LC_MESSAGES=POSIX` | - | localectl | /etc/profile.d |
| alternatives | `update-alternatives --install $(which vim) vim $(which nvim) 110` | `alternatives --install /usr/local/bin/vim vim /usr/local/bin/nvim 110` (주의: /usr/bin/vim 금지) | `alias vim=nvim` | 동일 (/usr/local/bin) | `alias` |
| 셸 변경 | `sudo chsh -s /usr/bin/zsh $USER` | 동일 | `chsh -s /bin/zsh` | 동일 | 동일 |

## 소스 빌드 레시피 (저장소에 없을 때)

모두 `~/.local/src` 아래에서 한다.

```bash
# neovim (stable)
git clone --depth 1 --branch stable https://github.com/neovim/neovim.git
make -C neovim CMAKE_BUILD_TYPE=Release && sudo make -C neovim install

# universal-ctags
git clone --depth 1 https://github.com/universal-ctags/ctags.git
(cd ctags && ./autogen.sh && ./configure --prefix=/usr/local && make -j"$(nproc)" && sudo make install)
# 선택 의존: jansson-devel libyaml-devel libxml2-devel pcre2-devel (있으면 기능 추가, 없어도 빌드됨)

# luarocks (lua 헤더 위치는 배포판 확인: /usr/include, /usr/include/lua5.4 등)
V=3.11.1
wget -q https://luarocks.org/releases/luarocks-$V.tar.gz && tar zxf luarocks-$V.tar.gz
(cd luarocks-$V && ./configure --prefix=/usr/local --with-lua-include=/usr/include && make && sudo make install)
sudo /usr/local/bin/luarocks install dkjson
# nvim 은 lua 5.1 경로를 보므로:
sudo mkdir -p /usr/local/share/lua/5.1
sudo ln -sf /usr/local/share/lua/$(lua -e 'print(_VERSION:match("%d+%.%d+"))')/dkjson.lua /usr/local/share/lua/5.1/dkjson.lua

# lazygit
LAZYGIT_VERSION=$(curl -sI https://github.com/jesseduffield/lazygit/releases/latest | grep -i "^location:" | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | tr -d "v")
curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit && sudo install lazygit /usr/local/bin
```
