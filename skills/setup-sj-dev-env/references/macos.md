# macOS

저장소의 `set_env_for_mac_neovim.sh` 가 기본형이지만 오래됐다. 아래대로 갱신해서 쓴다.

## 차이점

- Homebrew 설치 URL: 원본의 `raw.githubusercontent.com/Homebrew/install/master/install` (ruby) 은 폐기됨.
  `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`.
  Apple Silicon 은 `/opt/homebrew/bin` 을 PATH 에 넣어야 한다 (`eval "$(/opt/homebrew/bin/brew shellenv)"`).
- `brew tap homebrew/cask-fonts` 는 더 이상 필요 없다(폰트 cask 가 본 저장소로 이동). `brew install --cask font-jetbrains-mono-nerd-font` 만.
- 패키지: `brew install cmake tmux neovim lazygit universal-ctags luarocks uv openjdk@17 open-mpi`
  - brew neovim 은 최신 stable 이라 소스 빌드 불필요.
  - `luarocks install dkjson` 은 brew lua(5.4) 기준으로 설치됨. nvim 이 찾도록 `luarocks --lua-version=5.1` 이 되는지 확인하거나
    `/usr/local/share/lua/5.1/` (Intel) 또는 `/opt/homebrew/share/lua/5.1/` 에 링크.
- zsh 는 macOS 기본 셸이라 `chsh` 불필요. oh-my-zsh 는 동일하게 `RUNZSH=no CHSH=no KEEP_ZSHRC=yes`.
- `vim`→nvim 은 alternatives 가 없으니 `.zshrc` 에 `alias vim=nvim` (`zshrc_diff_only` 에 이미 있음).
- JAVA_HOME: `export JAVA_HOME=$(/usr/libexec/java_home -v 17)`. brew openjdk 는 `sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk` 로 등록해야 `java_home` 이 인식한다.
- 로케일: 시스템 설정 변경 없음. 필요하면 `.zshrc` 에 `export LANG=ko_KR.UTF-8`.
- `config/tmux/macos.conf` 가 macOS 용 tmux 설정이다. `cp -r config/* ~/.config/` 는 동일.
- `xcode-select --install` 은 GUI 프롬프트가 뜬다. 이미 설치됐는지 `xcode-select -p` 로 먼저 본다.
