#!/usr/bin/env bash
# 개발환경 설치 전 환경 감지. 읽기 전용. 어떤 references/*.md 를 볼지, 무엇을 소스 빌드할지 결정하는 근거를 출력한다.
set -uo pipefail

section() { echo; echo "## $*"; }

section "OS"
if [ -r /etc/os-release ]; then
    . /etc/os-release
    echo "ID=${ID:-} ID_LIKE=${ID_LIKE:-} VERSION_ID=${VERSION_ID:-} PRETTY_NAME=${PRETTY_NAME:-}"
elif [ "$(uname -s)" = "Darwin" ]; then
    echo "ID=macos VERSION=$(sw_vers -productVersion 2>/dev/null) ARCH=$(uname -m)"
else
    uname -a
fi
echo "kernel=$(uname -r) arch=$(uname -m) nproc=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null)"

section "package manager"
PM=""
for p in apt-get dnf yum brew pacman apk zypper; do
    if command -v "$p" >/dev/null 2>&1; then echo "$p: $(command -v $p)"; [ -z "$PM" ] && PM=$p; fi
done
echo "primary=$PM"

section "privileges"
echo "user=$(id -un) uid=$(id -u)"
if [ "$(id -u)" = "0" ]; then echo "root=yes"
elif sudo -n true 2>/dev/null; then echo "sudo=passwordless"
elif command -v sudo >/dev/null; then echo "sudo=available (password may be required -> ask user to run interactive step)"
else echo "sudo=MISSING"; fi
if [ "$(uname -s)" != "Darwin" ]; then
    if grep -q "^$(id -un):" /etc/passwd 2>/dev/null; then echo "account=local (/etc/passwd) -> chsh OK"
    else echo "account=NOT in /etc/passwd (LDAP/SSSD?) -> chsh may fail, see pitfalls.md"; fi
fi

section "network"
for u in https://github.com https://astral.sh https://luarocks.org https://github.com/jesseduffield/lazygit/releases/latest; do
    code=$(curl -sL -A "setup-sj-dev-env" -o /dev/null -w '%{http_code}' --max-time 8 "$u" 2>/dev/null || echo ERR)
    echo "$u -> $code"
done

section "already installed"
for c in gcc g++ make cmake ninja pkg-config git curl wget unzip gettext ctags tmux zsh nvim vim uv lazygit luarocks lua java fc-cache autoconf automake libtool; do
    loc=$(command -v "$c" 2>/dev/null || ls "$HOME/.local/bin/$c" 2>/dev/null || echo MISSING)
    printf "%-11s %s\n" "$c" "$loc"
done
command -v nvim >/dev/null 2>&1 && nvim --version | head -1
command -v lua  >/dev/null 2>&1 && echo "lua $(lua -e 'print(_VERSION)')"

section "dotfiles / dirs"
for d in ~/.config/nvim ~/.config/tmux ~/.oh-my-zsh ~/.local/share/fonts ~/.local/src; do
    [ -e "$d" ] && echo "exists  $d" || echo "absent  $d"
done
echo "SHELL=$SHELL login_shell=$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7)"
grep -q 'local/bin/env' ~/.zshrc 2>/dev/null && echo "zshrc: uv env sourced" || echo "zshrc: uv env NOT sourced"

section "locale"
locale -a 2>/dev/null | grep -i '^ko' | tr '\n' ' '; echo
[ -r /etc/locale.conf ] && { echo "/etc/locale.conf:"; cat /etc/locale.conf; }
[ -r /etc/default/locale ] && { echo "/etc/default/locale:"; cat /etc/default/locale; }

section "repo availability (installed or available)"
case "$PM" in
    dnf|yum)
        PKGS="gcc gcc-c++ make cmake ninja-build gettext pkgconf-pkg-config ctags universal-ctags tmux openmpi-devel zlib-devel fontconfig lua lua-devel luarocks glibc-langpack-ko zsh java-17-openjdk-devel java-21-openjdk-devel neovim jansson-devel libyaml-devel libxml2-devel pcre2-devel unzip"
        # dnf list --available 는 설치된 것을 숨긴다. 둘 다 보이는 dnf list 를 쓴다.
        out=$($PM -q list $PKGS 2>/dev/null)
        for p in $PKGS; do
            pe=$(printf '%s' "$p" | sed 's/[+.]/\\&/g')
            if echo "$out" | grep -E "^$pe\.(x86_64|noarch|aarch64)" >/dev/null; then
                if rpm -q "$p" >/dev/null 2>&1; then echo "installed  $p"; else echo "available  $p ($(echo "$out" | grep -E "^$pe\." | awk '{print $3}' | head -1))"; fi
            else echo "MISSING    $p  -> source build or alternative (see package-map.md)"; fi
        done
        echo; echo "repos:"; $PM -q repolist 2>/dev/null
        for r in $($PM -q repolist 2>/dev/null | awk 'NR>1{print $1}' | grep -i epel); do
            echo "epel repo '$r' package count: $($PM -q repoquery --repo "$r" 2>/dev/null | wc -l)  (small number = partial mirror)"
        done
        ;;
    apt-get)
        PKGS="build-essential cmake ninja-build gettext pkg-config exuberant-ctags universal-ctags tmux libopenmpi-dev zlib1g-dev fontconfig luarocks language-pack-ko zsh default-jdk neovim unzip"
        for p in $PKGS; do
            if dpkg -s "$p" >/dev/null 2>&1; then echo "installed  $p"
            elif apt-cache policy "$p" 2>/dev/null | grep -q Candidate; then echo "available  $p ($(apt-cache policy "$p" | awk '/Candidate/{print $2}'))"
            else echo "MISSING    $p"; fi
        done
        ;;
    brew)
        for p in cmake tmux neovim lazygit universal-ctags luarocks uv openjdk@17 open-mpi; do
            brew list --versions "$p" >/dev/null 2>&1 && echo "installed  $p" || echo "not yet    $p"
        done
        ;;
    *) echo "no mapping for $PM; use references/package-map.md" ;;
esac
