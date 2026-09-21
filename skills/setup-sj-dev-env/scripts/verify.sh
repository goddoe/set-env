#!/usr/bin/env bash
# 설치 후 검증. 모든 항목을 OK/FAIL 로 출력하고, FAIL 이 하나라도 있으면 exit 1.
set -uo pipefail
fail=0
ok()   { printf "OK    %s\n" "$*"; }
bad()  { printf "FAIL  %s\n" "$*"; fail=1; }
have() { command -v "$1" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$1" ]; }

echo "## tools"
for c in gcc make cmake git tmux zsh nvim ctags luarocks uv lazygit java fc-cache; do
    have "$c" && ok "$c -> $(command -v $c 2>/dev/null || echo ~/.local/bin/$c)" || bad "$c missing"
done

echo; echo "## versions"
have nvim && { v=$(nvim --version | head -1); echo "$v"; nvim --version | head -1 | grep -qE 'v0\.(1[1-9]|[2-9][0-9])|v[1-9]' && ok "nvim >= 0.11" || bad "nvim < 0.11 (NvChad needs 0.11+)"; }
have ctags && ctags --version | head -1
have luarocks && luarocks --version | head -1
have java && java -version 2>&1 | head -1
have uv && (uv --version 2>/dev/null || ~/.local/bin/uv --version)

echo; echo "## vim -> nvim"
if [ "$(uname -s)" = "Darwin" ]; then
    grep -q 'alias vim=nvim' ~/.zshrc 2>/dev/null && ok "alias vim=nvim in .zshrc" || bad "no alias vim=nvim"
else
    target=$(readlink -f "$(command -v vim 2>/dev/null)" 2>/dev/null)
    case "$target" in *nvim*) ok "vim -> $target" ;; *) bad "vim -> ${target:-none} (expected nvim)" ;; esac
    target=$(readlink -f "$(command -v editor 2>/dev/null)" 2>/dev/null)
    case "$target" in *nvim*) ok "editor -> $target" ;; *) bad "editor -> ${target:-none}" ;; esac
    [ -L /usr/bin/vim ] && case "$(readlink -f /usr/bin/vim)" in *nvim*) echo "note: /usr/bin/vim itself points to nvim (fine on Debian, suspicious on RHEL)";; esac
fi

echo; echo "## nvim config + dkjson"
[ -d ~/.config/nvim/.git ] && ok "~/.config/nvim cloned" || bad "~/.config/nvim missing"
if have nvim; then
    LOG="${TMPDIR:-/tmp}/nvim-verify-$$.log"
    # 첫 실행은 lazy.nvim 부트스트랩으로 출력이 매우 크다. 파일로 보낸다.
    timeout 600 nvim --headless "+Lazy! sync" +qa > "$LOG" 2>&1
    n=$(ls ~/.local/share/nvim/lazy 2>/dev/null | wc -l)
    [ "$n" -gt 5 ] && ok "lazy plugins: $n" || bad "lazy plugins: $n (bootstrap failed? see $LOG)"
    res=$(timeout 60 nvim --headless -c 'lua local ok,m=pcall(require,"dkjson"); io.stdout:write(ok and ("DKJSON_OK "..tostring(m.version)) or ("DKJSON_FAIL "..tostring(m)))' -c qa 2>>"$LOG" | tr -d '\r' | grep -ao 'DKJSON_[A-Z]* [^[:cntrl:]]*' | tail -1)
    case "$res" in DKJSON_OK*) ok "$res" ;; *) bad "dkjson not loadable in nvim (${res:-no output}); log: $LOG" ;; esac
fi

echo; echo "## dotfiles / fonts / shell"
[ -f ~/.config/tmux/tmux.conf ] && ok "tmux config" || bad "~/.config/tmux/tmux.conf missing"
[ -d ~/.oh-my-zsh ] && ok "oh-my-zsh" || bad "oh-my-zsh missing"
if [ "$(uname -s)" != "Darwin" ]; then
    [ "$(fc-list 2>/dev/null | grep -ci jetbrains)" -gt 0 ] && ok "JetBrainsMono font in fc-list" || bad "JetBrainsMono font not found by fontconfig"
    sh=$(getent passwd "$(id -un)" | cut -d: -f7); case "$sh" in *zsh) ok "login shell $sh" ;; *) bad "login shell $sh (expected zsh)" ;; esac
fi
grep -q 'local/bin/env' ~/.zshrc 2>/dev/null && ok "uv env sourced in .zshrc" || bad "uv env not sourced in .zshrc (oh-my-zsh overwrote it? see pitfalls.md)"
grep -q 'export JAVA_HOME=' ~/.zshrc 2>/dev/null && ok "JAVA_HOME in .zshrc" || bad "JAVA_HOME not in .zshrc"
jh=$(grep -o 'export JAVA_HOME=.*' ~/.zshrc 2>/dev/null | head -1 | cut -d= -f2 | tr -d '"')
[ -n "$jh" ] && { [ -e "$jh" ] && ok "JAVA_HOME path exists: $jh" || bad "JAVA_HOME path does not exist: $jh"; }
if have zsh; then
    zsh -ic 'command -v uv >/dev/null && command -v nvim >/dev/null' 2>/dev/null && ok "zsh -i sees uv and nvim" || bad "zsh -i cannot find uv or nvim (PATH)"
fi

echo; echo "## locale"
if [ "$(uname -s)" != "Darwin" ]; then
    if command -v localectl >/dev/null; then localectl status 2>/dev/null | head -1; fi
    ko=0; for f in /etc/locale.conf /etc/default/locale; do [ -r "$f" ] && grep -q 'LANG=.*ko_KR' "$f" && ko=1; done
    [ "$ko" = 1 ] && ok "system LANG=ko_KR" || echo "note: system LANG is not ko_KR (intentional if shared server)"
fi

echo
[ "$fail" = 0 ] && echo "ALL OK" || { echo "SOME CHECKS FAILED"; exit 1; }
