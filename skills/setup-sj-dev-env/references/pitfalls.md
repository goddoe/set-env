# Pitfalls — 실제로 겪은 문제와 예방법

2026-09-21 Navix 9.8(RHEL9 계열) 서버에 `set_env_for_ubuntu_neovim.sh` 를 옮기며 겪은 것들.
각 항목은 "무슨 일이 있었나 → 왜 → 어떻게 피하나" 순서다.

## 셸 설정 파일

### oh-my-zsh 설치가 `.zshrc` 를 갈아치워 uv PATH 가 사라진다
- uv 설치기는 `~/.zshrc` 에 `. "$HOME/.local/bin/env"` 를 추가한다. 그 뒤 oh-my-zsh 설치기가
  기존 `.zshrc` 를 `.zshrc.pre-oh-my-zsh` 로 옮기고 새 템플릿을 깐다. 결과: zsh 에서 `uv` 를 못 찾는다.
- 예방: oh-my-zsh 설치 시 `RUNZSH=no CHSH=no KEEP_ZSHRC=yes` 를 준다. 또는 oh-my-zsh 를 uv 보다 먼저 설치한다.
- 검증: `zsh -ic 'command -v uv'`. 없으면 `.zshrc` 에 `. "$HOME/.local/bin/env"` 를 추가한다.

### zsh 에서는 `~/.local/bin` 이 PATH 에 없을 수 있다
- RHEL/Ubuntu 의 skel `.bash_profile` 이 `~/.local/bin` 을 PATH 에 넣지만 zsh 는 그 파일을 안 읽는다.
- uv 의 `env` 파일을 source 하면 해결된다. `alias vim=nvim` 같은 것도 `.zshrc` 기준으로 검증한다.

### `.zshrc` 에 append 할 때 중복 방지
- `grep -q 'export JAVA_HOME=' ~/.zshrc || echo ... >> ~/.zshrc` 패턴. 재실행 시 줄이 계속 늘어나지 않게.

## 패키지 매니저

### `dnf list --available` 은 이미 설치된 패키지를 안 보여준다
- gettext, fontconfig, unzip 이 "없는 것처럼" 보였지만 사실 설치돼 있었다.
- 예방: `dnf list <pkg>` (설치됨/사용가능 둘 다) 또는 `rpm -q <pkg>` 로 확인한다. `detect_env.sh` 가 이 방식을 쓴다.

### 없는 패키지 하나 때문에 `dnf install` 전체가 실패한다
- `dnf install a b c` 에서 c 가 저장소에 없으면 a, b 도 설치되지 않고 종료한다.
- 예방: `dnf install -y --setopt=strict=0 ...` 로 없는 것은 건너뛰게 하고, 그 뒤 `rpm -q` 로 뭐가 빠졌는지 확인해 소스 빌드로 보충한다.
- apt 는 반대로 없는 패키지가 있으면 그냥 에러이므로 패키지 존재를 `apt-cache policy <pkg>` 로 먼저 본다.

### 사내 EPEL 미러는 일부만 있을 수 있다
- Navix 의 `ncc-epel-noarch` 는 noarch 27개뿐이었다. `ctags`, `universal-ctags`, `luarocks`, `neovim` 전부 없음.
- 예방: "EPEL 이 있으니 되겟지" 라고 가정하지 말고 `dnf repoquery --repo <epel> | wc -l` 로 크기를 본다.
  없으면 소스 빌드(ctags: autogen/configure/make, luarocks: configure --with-lua-include, neovim: make CMAKE_BUILD_TYPE=Release).
- `codeready`(CRB) 저장소에 `ninja-build`, `lua-devel` 이 있다. RHEL 계열에서 CRB 가 꺼져 있으면 `dnf config-manager --set-enabled crb`.

### `sudo` 의 `secure_path` 에 `/usr/local/bin` 이 없을 수 있다
- `sudo luarocks ...` 가 "command not found" 가 될 수 있다.
- 예방: `sudo /usr/local/bin/luarocks ...` 처럼 절대 경로로 부른다. `make install` 로 `/usr/local` 에 넣은 도구는 전부 해당.

## vim / neovim

### RHEL 의 `/usr/bin/vim` 은 rpm 소유 실파일이다 — alternatives 를 걸지 말 것
- Ubuntu 의 `/usr/bin/vim` 은 원래 `/etc/alternatives/vim` 심볼릭 링크라 `update-alternatives --install $(which vim) ...` 이 된다.
  RHEL 에서 같은 명령을 치면 rpm 소유 파일을 덮어쓰게 되고 `dnf update vim-enhanced` 때 충돌한다.
- 예방: PATH 에서 `/usr/bin` 보다 앞에 있는 `/usr/local/bin` 에 링크를 만든다.
  `sudo alternatives --install /usr/local/bin/vim vim /usr/local/bin/nvim 110` (editor 도 동일).
  `update-alternatives --config vim` 은 대화형이므로 생략한다. 우선순위 110 하나면 auto 로 선택된다.

### neovim 은 `stable` 브랜치로 clone
- 원본은 기본 브랜치(nightly) 를 빌드한다. NvChad 가 가끔 nightly 변경으로 깨진다.
  `git clone --depth 1 --branch stable https://github.com/neovim/neovim.git`. NvChad 최소 요구는 0.11.
- 빌드 의존: cmake, ninja-build(또는 make), gettext, unzip, curl, gcc/g++. 32코어에서 약 3분.

### nvim 첫 실행은 출력이 1MB 넘게 나온다
- NvChad 의 lazy.nvim 이 첫 실행 때 플러그인 30여 개를 clone 하고 그 로그를 stdout 에 쏟는다.
  `nvim --headless -c 'lua ...' -c q` 를 검증에 쓰면 그 출력이 통째로 섞여 결과가 잘린다.
- 예방: 첫 실행은 `nvim --headless "+Lazy! sync" +qa > /tmp/nvim-bootstrap.log 2>&1` 로 워밍업하고,
  그 다음 검증 명령을 따로 돌린다. `verify.sh` 가 이렇게 한다.

### dkjson 은 lua 5.1 경로에 있어야 nvim 이 찾는다
- 시스템 lua 가 5.4 면 luarocks 가 `/usr/local/share/lua/5.4/dkjson.lua` 에 설치한다. nvim(luajit) 은 `.../lua/5.1/` 을 본다.
- 예방: `sudo ln -sf /usr/local/share/lua/5.4/dkjson.lua /usr/local/share/lua/5.1/dkjson.lua`. dkjson 은 순수 lua 라 버전 무관.
- 검증: `nvim --headless -c 'lua print(pcall(require,"dkjson"))' -c q`. (`> file 2>&1` 필수, 위 항목 참고)

### luarocks 는 `--with-lua-include` 를 안 주면 configure 가 헤더를 못 찾는다
- `lua-devel` 설치 후 `./configure --prefix=/usr/local --with-lua-include=/usr/include`.

## 대화형 명령 → 비대화형 대체

원본 스크립트에는 사람이 키를 눌러야 하는 단계가 있다. 백그라운드로 돌리면 거기서 영원히 멈춘다.

| 원본 | 대체 |
|---|---|
| `update-alternatives --config vim` | 생략. `--install` 우선순위 하나면 자동 선택됨 |
| `dpkg-reconfigure locales` | 생략. `locale-gen ko_KR.UTF-8` (deb) / `glibc-langpack-ko` (rpm) 이면 충분 |
| oh-my-zsh `install.sh` (zsh 로 진입) | `RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl ...)"` |
| `chsh -s /usr/bin/zsh` (비번 물음) | `sudo chsh -s /usr/bin/zsh "$USER"` |
| `apt install` 의 tzdata 등 프롬프트 | `DEBIAN_FRONTEND=noninteractive` |
| `unzip` 덮어쓰기 질문 | `unzip -o -q` |

## 로케일 / 계정

### `localectl set-locale` 은 시스템 전체 설정이다
- `/etc/locale.conf` 가 바뀌어 다른 계정의 기본 LANG 도 바뀐다. 공용 서버면 사용자에게 말하고, 보고에 되돌리기 명령을 적는다:
  `sudo localectl set-locale LANG=en_US.UTF-8`.
- 사용자 세션에서만 원하면 `.zshrc` 에 `export LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX` 로 대신한다.
- 로케일이 이미 생성돼 있는지 `locale -a | grep -i ko` 로 먼저 본다. RHEL9 는 `glibc-langpack-ko` 설치로 끝, `locale-gen` 이 없다.

### LDAP/SSSD 계정은 `chsh` 가 안 된다
- `getent passwd $USER` 는 나오는데 `grep $USER /etc/passwd` 가 비면 로컬 계정이 아니다. `chsh` 가 실패하거나 무시된다.
- 대안: `.bash_profile` 끝에 `[ -x /usr/bin/zsh ] && exec zsh -l` 을 넣거나 관리자에게 요청한다.

## Java

### JAVA_HOME 경로가 배포판마다 다르다
- Debian/Ubuntu `default-jdk`: `/usr/lib/jvm/default-java`
- RHEL/Fedora `java-17-openjdk-devel`: `/usr/lib/jvm/java` (→ `/etc/alternatives/java_sdk`)
- macOS: `$(/usr/libexec/java_home)`
- 원본 스크립트의 `default-java` 경로를 그대로 쓰면 RHEL 에서 존재하지 않는 경로가 export 된다.

## 폰트

### `~/.font` 는 fontconfig 검색 경로가 아니다
- 원본은 `~/.font` 에 넣는데 fontconfig 는 `~/.fonts`(구식) 와 `~/.local/share/fonts` 를 본다.
  `~/.local/share/fonts` 를 쓰고 `fc-cache -f` 후 `fc-list | grep -i jetbrains` 로 확인한다.
- 헤드리스 서버에서는 터미널 폰트가 클라이언트 쪽 문제라 실질적 효과는 없다. 그래도 원본과 맞추려면 설치는 해둔다.

## 실행 방식

### 긴 스크립트는 백그라운드 + 로그 + 마커 grep
- 전체 실행에 10분 가까이 걸린다(dnf, neovim 빌드, 플러그인 clone). 포그라운드 timeout 에 걸린다.
- `./script.sh > setup.log 2>&1; echo EXIT=$? >> setup.log` 를 백그라운드로 돌리고
  `grep -E "^====|EXIT=|error:|FAILED"` 로만 진행을 본다. cmake 의 "Performing Test ... - Failed" 는 정상 출력이니 오탐에 주의.

### `set -e` 는 쓰지 말고 단계 안에서 `&&` 로 묶는다
- 한 단계(예: 폰트 다운로드) 실패로 전체가 중단되면 나머지 단계를 못 한다. 단계별 성공/실패를 verify.sh 로 마지막에 한 번에 본다.

## 검증 스크립트 작성 시

### `set -o pipefail` + `grep -q` 는 성공을 실패로 만든다
- `fc-list | grep -qi jetbrains` 에서 grep 이 첫 매치 후 종료하면 fc-list 가 SIGPIPE 로 죽고, pipefail 때문에 파이프 전체가 실패로 잡힌다.
  실제로 폰트 96개가 잡혔는데 FAIL 로 나왔다.
- 예방: 파이프 안에서는 `grep -q` 대신 `grep ... >/dev/null` 또는 `[ "$(... | grep -c x)" -gt 0 ]` 를 쓴다. 입력을 끝까지 읽어야 SIGPIPE 가 안 난다.

### 패키지 이름을 정규식에 그대로 넣지 말 것
- `gcc-c++` 의 `+` 가 정규식 수량자로 해석돼 "MISSING" 으로 나왔다. `grep -F` 를 쓰거나 `sed 's/[+.]/\\&/g'` 로 이스케이프한다.

### GitHub API 는 회사 공용 IP 에서 rate limit(403) 에 걸린다
- 원본 스크립트는 `api.github.com/repos/.../releases/latest` 로 lazygit 버전을 얻는다. 비인증 요청은 IP 당 시간당 60회라
  NAT 뒤 사내 서버에서는 남이 다 써버려 403 `API rate limit exceeded` 가 나고, 버전이 빈 문자열이 되어 다운로드 URL 이 깨진다.
- 예방: API 대신 리다이렉트 헤더를 쓴다. 제한이 없다.
  `curl -sI https://github.com/jesseduffield/lazygit/releases/latest | grep -i '^location:' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+'`
- 네트워크 체크도 `api.github.com` 이 아니라 `github.com/.../releases/latest` 로 한다.

### `grep -s` 는 파일이 없으면 조용히 종료 코드 2 를 낸다
- `grep -hs PAT /etc/locale.conf /etc/default/locale` 는 한쪽 파일이 없으면 매치가 있어도 exit 2 → pipefail 에서 실패.
  `cat a b 2>/dev/null | grep` 도 cat 이 exit 1 을 내서 똑같이 실패한다. 파이프를 버리고 파일별로 `[ -r f ] && grep -q PAT f` 를 돌린다.
  요약: pipefail 을 켠 스크립트에서 "있는지 확인" 용 파이프는 전부 의심하라. 한 단계라도 0 이 아니면 전체가 실패다.
