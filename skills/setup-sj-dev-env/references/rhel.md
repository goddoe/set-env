# RHEL9 계열 (Navix, Rocky, Alma, CentOS Stream 9, Fedora 도 대부분 동일)

완성된 스크립트가 저장소에 있다: `set_env_for_rhel9_neovim.sh`. 2026-09-21 Navix 9.8 에서 끝까지 실행·검증됐다.
새 RHEL9 머신이면 이 스크립트를 그대로 백그라운드로 돌리고 `verify.sh` 로 확인하는 것이 가장 빠르다.
다른 배포판으로 옮길 때도 이 파일을 템플릿으로 삼는다.

## 실행

```bash
cd ~/projects/private/set-env
./set_env_for_rhel9_neovim.sh > /tmp/setup.log 2>&1; echo "EXIT=$?" >> /tmp/setup.log   # 백그라운드로
grep -E "^====|EXIT=" /tmp/setup.log                                                     # 진행 확인
bash skills/setup-sj-dev-env/scripts/verify.sh
```

## 스크립트가 하는 일 (순서대로)

1. `dnf install -y --setopt=strict=0` 로 빌드 도구, cmake, ninja-build, gettext, tmux, openmpi-devel, zlib-devel,
   lua/lua-devel, glibc-langpack-ko, ctags 선택 의존(jansson/libyaml/libxml2/pcre2-devel), zsh, java-17-openjdk-devel.
   `strict=0` 이라 없는 패키지는 조용히 건너뛰므로 뒤에서 `rpm -q` 로 확인해야 한다.
2. uv (`astral.sh/uv/install.sh`)
3. neovim stable 소스 빌드 → `/usr/local/bin/nvim`
4. `alternatives --install /usr/local/bin/{vim,editor}` → nvim. `/usr/bin/vim` 은 건드리지 않음.
5. universal-ctags 소스 빌드 (repo 에 없음)
6. NvChad starter clone → `~/.config/nvim`
7. luarocks 소스 빌드 → dkjson 설치 → lua 5.1 경로에 링크
8. Nerd Font → `~/.local/share/fonts`, `fc-cache -f`
9. `config/*` → `~/.config/`
10. lazygit GitHub release
11. `localectl set-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX` (시스템 전체)
12. oh-my-zsh (`RUNZSH=no CHSH=no KEEP_ZSHRC=yes`)
13. `JAVA_HOME=/usr/lib/jvm/java` 를 `.bashrc`, `.zshrc` 에 (중복 방지)
14. `sudo chsh -s /usr/bin/zsh $USER`

## RHEL 특이사항

- `codeready`(CRB) 저장소에 `ninja-build`, `lua-devel` 이 있다. Rocky/Alma 에서는 이름이 `crb` 이고 기본 비활성일 수 있다:
  `sudo dnf config-manager --set-enabled crb`.
- 공식 EPEL 이 붙어 있으면 `neovim`, `luarocks`, `universal-ctags`(패키지명 `ctags` 는 아님) 가 있을 수 있다.
  `dnf list neovim luarocks universal-ctags` 로 확인하고 있으면 소스 빌드 대신 dnf 로 설치한다. 단 EPEL neovim 버전이 0.11 미만이면 소스로.
- `dnf update -y` 는 하지 않는다. 원본 centos 스크립트는 하지만 공용 서버에서 커널까지 올리는 건 범위 밖이다.
- Fedora 는 기본 저장소에 neovim/luarocks/ctags 가 다 있어 소스 빌드 절이 대부분 불필요하다.
