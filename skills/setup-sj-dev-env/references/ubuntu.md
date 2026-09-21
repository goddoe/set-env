# Ubuntu / Debian

원본 `set_env_for_ubuntu_neovim.sh` 가 이 OS 용이지만 그대로 돌리면 대화형 단계에서 멈춘다.
아래 차이만 반영한 비대화형 버전을 만들어 실행한다.

## 원본을 그대로 쓰면 안 되는 지점

| 원본 줄 | 문제 | 대체 |
|---|---|---|
| `apt install -y sudo` (첫 줄) | 이미 sudo 가 있으면 root 가 아니어서 실패, 컨테이너 전용 | `command -v sudo || apt install -y sudo` (root 일 때만) |
| `sudo update-alternatives --config vim` | 대화형 | 생략 |
| `sudo dpkg-reconfigure locales` | 대화형 | 생략. `locale-gen ko_KR.UTF-8` 로 충분 |
| oh-my-zsh install.sh | zsh 로 진입해 스크립트가 멈춤, `.zshrc` 덮어씀 | `RUNZSH=no CHSH=no KEEP_ZSHRC=yes` |
| `sudo chsh -s /usr/bin/zsh` | 대상 사용자 없음 → root 의 셸이 바뀜 | `sudo chsh -s /usr/bin/zsh "$USER"` |
| `git clone neovim` (기본 브랜치) | nightly 라 NvChad 가 깨질 수 있음 | `--branch stable --depth 1` |
| `mkdir ${FONT_DIR}` with `~/.font` | fontconfig 가 안 읽는 경로 | `~/.local/share/fonts` |
| neovim/lazygit 을 저장소 디렉터리에 clone/다운로드 | git 저장소가 더러워짐 | `~/.local/src` |
| `sudo luarocks install dkjson` | Ubuntu luarocks 는 lua 5.1 기준이라 nvim 이 바로 찾음. 문제 없음 | 그대로. 단 `luarocks --lua-version` 확인 |

## 추가로 필요한 것

- `apt install -y ninja-build gettext unzip` (neovim 빌드). `build-essential` 만으로는 부족.
- `DEBIAN_FRONTEND=noninteractive` 를 apt 앞에 붙여 tzdata 등 프롬프트를 막는다.
- Ubuntu 22.04 이하 apt 의 `neovim` 은 0.6~0.7 이라 NvChad 요건 미달. 소스 빌드 또는 GitHub release tarball(`nvim-linux-x86_64.tar.gz`) 을 `/usr/local` 에 푼다.
- `exuberant-ctags` 대신 `universal-ctags` 패키지가 22.04+ 에 있다. 둘 다 `ctags` 명령을 제공한다.
- `update-alternatives --install $(which vim) vim $(which nvim) 110` 은 Ubuntu 에서는 안전하다. `/usr/bin/vim` 이 원래 alternatives 링크이기 때문.
  단 `which editor` 가 비어 있으면 (vim 미설치 상태) 두 번째 줄이 깨진다. `/usr/bin/editor` 로 고정한다.
- JAVA_HOME 은 `/usr/lib/jvm/default-java` 가 맞다.
