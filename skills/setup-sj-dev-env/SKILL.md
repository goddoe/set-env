---
name: setup-sj-dev-env
description: >
  goddoe 개인 개발환경(neovim + NvChad, zsh + oh-my-zsh, tmux 설정, uv, lazygit, universal-ctags,
  luarocks/dkjson, JetBrainsMono Nerd Font, Java, 한국어 로케일)을 새 머신에 설치한다.
  OS 를 먼저 감지하고(Ubuntu/Debian, RHEL9 계열(Navix/Rocky/Alma/CentOS Stream), Fedora, macOS,
  Arch, Alpine) 그 OS 의 패키지 매핑으로 설치하며, 저장소에 없는 패키지는 소스 빌드로 대체한다.
  사용자가 "개발환경 세팅", "새 서버 셋업", "set_env 스크립트 실행", "neovim/nvchad/zsh/tmux 설치",
  "다른 OS 에서 set_env_for_*.sh 대응되는 것 설치", "이 서버도 똑같이 맞춰줘" 처럼 말하면
  set_env 저장소의 스크립트를 직접 실행하지 말고 반드시 이 스킬을 먼저 사용한다.
  환경 세팅 중 일부(예: neovim 만, zsh 만)만 요청해도 이 스킬의 해당 절과 pitfalls 를 참고한다.
---

# setup-sj-dev-env

> 설치: 이 디렉터리는 저장소의 `skills/` 아래에 있어 Claude Code 가 자동으로 찾지 않는다.
> `ln -s ~/projects/private/set-env/skills/setup-sj-dev-env ~/.claude/skills/setup-sj-dev-env` 로 링크하면 모든 세션에서 쓸 수 있다.

`set_env_for_ubuntu_neovim.sh` 가 원본(source of truth)이다. 이 스킬은 그 스크립트의 각 단계를
다른 OS 에서 같은 결과가 나오도록 옮기는 방법과, 실제로 겪었던 함정을 기록한 것이다.
스크립트는 대화형 단계가 있고 OS 마다 패키지 이름이 달라 그대로 실행하면 중간에 멈추거나 깨진다.
그래서 "스크립트를 돌린다" 가 아니라 "스크립트가 만들려는 상태를 이 OS 에서 만든다" 로 접근한다.

저장소: `git@github.com:goddoe/set-env.git` (https://github.com/goddoe/set-env).
없으면 `~/projects/private/set-env` 로 clone 한다. `config/` (tmux 설정) 가 필요하다.

## 목표 상태 (무엇이 설치되어 있어야 하는가)

| 구성요소 | 목표 |
|---|---|
| 빌드 도구 | gcc/g++, make, cmake, pkg-config, git, curl, wget, unzip |
| neovim | 0.11 이상 (NvChad 요구). `vim`, `editor` 명령이 nvim 을 가리킴 |
| NvChad | `~/.config/nvim` = `https://github.com/goddoe/nvchad-starter.git` |
| dkjson | nvim 안에서 `require("dkjson")` 성공 (nvim-ai-assistant 용) |
| ctags | universal-ctags (원본의 exuberant-ctags 대응) |
| tmux | 설치 + `config/tmux` → `~/.config/tmux` |
| uv | `~/.local/bin/uv`, zsh 에서 PATH 잡힘 |
| lazygit | `/usr/local/bin/lazygit` (GitHub latest release) |
| 폰트 | JetBrainsMono Nerd Font v3.0.0, `fc-list` 에 보임 |
| zsh | oh-my-zsh 설치, 기본 셸 zsh |
| Java | JDK 설치 + `JAVA_HOME` 을 `.bashrc`, `.zshrc` 에 export |
| 로케일 | `LANG=ko_KR.UTF-8`, `LC_MESSAGES=POSIX` (시스템 전체) |
| 기타 라이브러리 | openmpi-devel, zlib-devel, fontconfig, lua + lua-devel |

## 진행 순서

### 1. 환경 감지 (항상 먼저)

```bash
bash skills/setup-sj-dev-env/scripts/detect_env.sh
```

OS/패키지 매니저/sudo 가능 여부/네트워크/이미 설치된 도구/저장소에서 받을 수 있는 패키지를
한 번에 출력한다. 이 결과로 `references/` 중 어느 파일을 볼지 정한다.

- `ID_LIKE` 에 `rhel`, `centos`, `fedora` → `references/rhel.md`
- `ID` 가 `ubuntu`, `debian` 또는 `ID_LIKE` 에 `debian` → `references/ubuntu.md`
- macOS → `references/macos.md`
- 그 외(arch, alpine 등) → `references/package-map.md` 의 매핑표로 직접 옮기고, 소스 빌드 절은 `rhel.md` 를 참고

감지 결과에서 특히 볼 것: (a) 기본 저장소에 없는 패키지 목록, (b) 사용자 계정이 `/etc/passwd` 에 있는지
(LDAP 계정이면 `chsh` 가 안 됨), (c) 현재 시스템 로케일과 셸.

### 2. 사용자에게 한 줄로 계획 알리기

시스템 전체에 영향을 주는 두 가지는 실행 전에 명시한다. 되돌리기 쉽지만 다른 사용자에게도 영향이 간다.

- 시스템 로케일 변경 (`localectl` / `update-locale`)
- 기본 셸 변경 (`chsh`)

사용자가 "대응되는 것 다 설치" 처럼 명확히 요청했으면 진행하고, 결과 보고에 되돌리는 명령을 적는다.

### 3. OS 별 스크립트 작성 후 실행

원본 스크립트를 한 줄씩 옮기지 말고, **비대화형 + 멱등(idempotent)** 하게 새 스크립트를 만든다.
저장소에 `set_env_for_<os>_neovim.sh` 이름으로 저장하면 다음 사람이 재사용할 수 있다.
(RHEL9 용은 이미 `set_env_for_rhel9_neovim.sh` 로 있다. 그 파일을 템플릿으로 삼으면 된다.)

작성 규칙:
- 각 단계 앞에 `==== step ====` 마커를 출력한다. 백그라운드 실행 후 로그의 마커만 grep 해서 진행 상황을 본다.
- 이미 있으면 건너뛴다 (`command -v`, `[ -d ]`). 재실행해도 안전해야 한다.
- 소스 빌드는 `~/.local/src` 아래에서 한다. 저장소 디렉터리 안에 clone 하면 git 이 더러워진다.
- 대화형 명령은 전부 비대화형 옵션으로 바꾼다. 목록은 `references/pitfalls.md` 의 "대화형" 절.
- 실행은 `run_in_background` + 로그 파일로 하고, 마커/에러만 필터링해서 모니터한다. neovim 빌드는 코어 수에 따라 수 분 걸린다.

### 4. 검증

```bash
bash skills/setup-sj-dev-env/scripts/verify.sh
```

설치 목록/버전/alternatives/dkjson 로드/로케일/셸/JAVA_HOME 을 한 번에 확인한다.
nvim 첫 실행은 플러그인 부트스트랩으로 출력이 1MB 넘게 나오므로 verify.sh 가 파일로 리다이렉트한다.
직접 `nvim --headless` 를 돌릴 때도 반드시 `> file 2>&1` 로 받는다.

### 5. 보고

무엇을 어떤 패키지로 대응시켰는지 표, 원본과 다르게 처리한 점, 시스템 전체 변경과 되돌리는 명령,
`~/.local/src` 에 남은 빌드 소스를 적는다.

## 반드시 읽을 것

- `references/pitfalls.md` — 실제로 겪은 문제와 예방법. **스크립트를 쓰기 전에 읽는다.**
  특히 oh-my-zsh 가 `.zshrc` 를 덮어써 uv PATH 가 사라지는 문제, RHEL 에서 `/usr/bin/vim` 에
  alternatives 를 걸면 안 되는 문제, `dnf list --available` 이 설치된 패키지를 숨기는 문제.
- `references/package-map.md` — 구성요소별 apt/dnf/brew/pacman/apk 패키지 이름.
- `references/rhel.md`, `references/ubuntu.md`, `references/macos.md` — OS 별 상세 절차.
