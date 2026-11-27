#!/bin/sh
# RBAi CLI installer for macOS and Linux: the standalone rbai program, no Node.js needed.
#
#   curl -fsSL https://cli.thedreamlabinnovations.com/install.sh | sh
#
# It picks the build for this machine: macOS or Linux; x64 or arm64; on Linux glibc or musl
# (Alpine); on x64 CPUs without AVX2 the -baseline build; on Apple silicon the native arm64 build,
# also when this shell runs under Rosetta. It downloads that build and the release's SHA256SUMS
# from https://cli.thedreamlabinnovations.com over HTTPS, checks the SHA-256, checks that the
# program starts and is the version asked for, and only then installs it as ~/.rbai/bin/rbai.
# It never uses sudo: everything goes into your home folder. When ~/.rbai/bin is not on your PATH
# it adds one line, ending in "# rbai", to your shell's startup file, and says which file.
#
# Options (environment variables):
#   RBAI_VERSION=1.0.0          install this version (default: the newest, from latest.json)
#   RBAI_INSTALL_DIR=/abs/dir   install there instead of ~/.rbai/bin; it must be a new or empty
#                               folder, or an earlier rbai install (rbai and .rbai-install only)
#   RBAI_NO_MODIFY_PATH=1       never edit a shell startup file
# For example: curl -fsSL https://cli.thedreamlabinnovations.com/install.sh | RBAI_VERSION=1.0.0 sh
#
# Uninstall: run `rbai logout` (it ends the browser sign-in), then rm -rf ~/.rbai/bin and delete
# the line ending in "# rbai" from your shell's startup file. Your settings stay in ~/.config/rbai
# and ~/.local/state/rbai until you delete them.
#
# Everything runs inside main(), so a download of this script that is cut short runs nothing.

set -eu

HOST="https://cli.thedreamlabinnovations.com"
NPM_HINT="With Node.js 22 or later you can install it from npm instead: npm install -g rbai-cli"

say() { printf '%s\n' "$*" >&2; }
fail() {
  printf 'rbai install: %s\n' "$*" >&2
  exit 1
}

# AVX2 on this x64 CPU (Bun's default x64 builds need it; the -baseline builds do not).
has_avx2() {
  if [ "$1" = linux ]; then
    grep -qw avx2 /proc/cpuinfo 2>/dev/null
  else
    [ "$(sysctl -n hw.optional.avx2_0 2>/dev/null || echo 0)" = 1 ]
  fi
}

main() {
  # -- this machine -----------------------------------------------------------
  os="$(uname -s)"
  cpu="$(uname -m)"
  case "$os" in
    Linux) os=linux ;;
    Darwin) os=darwin ;;
    MINGW* | MSYS* | CYGWIN*) fail "this is Windows. In PowerShell run:  irm $HOST/install.ps1 | iex" ;;
    *) fail "there is no rbai build for $os. $NPM_HINT" ;;
  esac
  case "$cpu" in
    x86_64 | amd64) cpu=x64 ;;
    arm64 | aarch64) cpu=arm64 ;;
    *) fail "there is no rbai build for the $cpu CPU. $NPM_HINT" ;;
  esac
  note=""
  # A shell under Rosetta 2 on Apple silicon reports x86_64; the native arm64 build is faster.
  if [ "$os" = darwin ] && [ "$cpu" = x64 ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
    cpu=arm64
    note="This shell runs under Rosetta 2 on Apple silicon, so the native arm64 build was installed."
  fi
  target="$os-$cpu"
  # musl when this system's own programs use it (Alpine and other musl distributions).
  if [ "$os" = linux ] && { [ -f /etc/alpine-release ] || ldd /bin/sh 2>&1 | grep -q musl; }; then
    target="$target-musl"
  fi
  if [ "$cpu" = x64 ] && ! has_avx2 "$os"; then
    target="$target-baseline"
    note="This CPU has no AVX2, so the baseline build was installed."
  fi
  asset="rbai-$target"

  # -- tools ------------------------------------------------------------------
  if command -v curl >/dev/null 2>&1; then
    if [ -t 2 ]; then progress="--progress-bar"; else progress="-sS"; fi
    fetch() { curl -fsSL --proto '=https' --tlsv1.2 --retry 3 --connect-timeout 20 "$1"; }
    fetch_to() { curl -fL --proto '=https' --tlsv1.2 --retry 3 --connect-timeout 20 "$progress" -o "$2" "$1"; }
  elif command -v wget >/dev/null 2>&1; then
    fetch() { wget -q -O - "$1"; }
    fetch_to() { wget -q -O "$2" "$1"; }
  else
    fail "it needs curl or wget to download rbai."
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256() { sha256sum "$1" | cut -d ' ' -f 1; }
  elif command -v shasum >/dev/null 2>&1; then
    sha256() { shasum -a 256 "$1" | cut -d ' ' -f 1; }
  else
    fail "it needs sha256sum or shasum to check the download."
  fi

  # -- which version ----------------------------------------------------------
  version="${RBAI_VERSION:-}"
  if [ -z "$version" ]; then
    latest="$(fetch "$HOST/latest.json")" || fail "could not read $HOST/latest.json. Check the connection (behind a proxy, set HTTPS_PROXY)."
    version="$(printf '%s' "$latest" | tr -d '\r\n' | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
    [ -n "$version" ] || fail "$HOST/latest.json names no version."
  fi
  version="${version#v}"
  case "$version" in
    *[!0-9A-Za-z.+-]* | '') fail "\"$version\" is not a version number (for example 1.0.0)." ;;
    [0-9]*.[0-9]*.[0-9]*) ;;
    *) fail "\"$version\" is not a version number (for example 1.0.0)." ;;
  esac

  # -- where: a new or empty folder, or an earlier rbai install ---------------
  dir="${RBAI_INSTALL_DIR:-$HOME/.rbai/bin}"
  case "$dir" in
    /*) ;;
    *) fail "RBAI_INSTALL_DIR must be an absolute path (it is \"$dir\")." ;;
  esac
  if [ -d "$dir" ]; then
    for entry in "$dir"/* "$dir"/.[!.]* "$dir"/..?*; do
      [ -e "$entry" ] || [ -L "$entry" ] || continue
      case "${entry##*/}" in
        rbai | .rbai-install | .rbai-download.*) ;;
        *) fail "$dir is not empty and is not an rbai install (it holds ${entry##*/}), so nothing was changed. Choose a new or empty folder with RBAI_INSTALL_DIR." ;;
      esac
    done
  elif [ -e "$dir" ]; then
    fail "$dir exists and is not a folder."
  fi
  mkdir -p "$dir" 2>/dev/null || fail "could not create $dir. Choose a folder you can write to with RBAI_INSTALL_DIR (this installer never uses sudo)."
  [ -w "$dir" ] || fail "cannot write to $dir. Choose a folder you can write to with RBAI_INSTALL_DIR (this installer never uses sudo)."

  # -- download and check -----------------------------------------------------
  release="$HOST/cli/$version"
  tmp="$(mktemp -d 2>/dev/null || mktemp -d -t rbai)" || fail "could not make a temporary folder."
  # The download goes into the install folder itself, so the check below runs it where it will
  # live (a /tmp mounted noexec would refuse it there).
  partial="$dir/.rbai-download.$$"
  trap 'rm -rf "$tmp"; rm -f "$partial"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM

  fetch "$release/SHA256SUMS" >"$tmp/SHA256SUMS" || fail "rbai $version is not on $HOST (could not read $release/SHA256SUMS). The newest version is in $HOST/latest.json."
  expected="$(awk -v f="$asset" '$2 == f || $2 == "*" f { print $1; exit }' "$tmp/SHA256SUMS")"
  if [ -z "$expected" ]; then
    case "$target" in
      *-baseline) fail "rbai $version has no build for $target (for x64 CPUs without AVX2, like this one). $NPM_HINT" ;;
      *) fail "rbai $version has no build for $target. $NPM_HINT" ;;
    esac
  fi
  case "$expected" in
    *[!0-9a-f]*) fail "SHA256SUMS has no valid SHA-256 for $asset." ;;
  esac
  [ "${#expected}" -eq 64 ] || fail "SHA256SUMS has no valid SHA-256 for $asset."

  say "Downloading rbai $version for $target"
  say "  $release/$asset"
  fetch_to "$release/$asset" "$partial" || fail "the download of $release/$asset failed. Nothing was installed."
  actual="$(sha256 "$partial")"
  [ "$actual" = "$expected" ] || fail "the download's SHA-256 is $actual, but SHA256SUMS says $expected. Nothing was installed. Try again; if it repeats, tell hari@thedreamlabinnovations.com."
  say "SHA-256 checked: $actual"

  chmod 755 "$partial"
  if ! got="$(RBAI_NO_UPDATE_CHECK=1 "$partial" --version 2>"$tmp/version.err")"; then
    case "$target" in
      *-musl*) hint=" It needs libstdc++ and libgcc (Alpine: apk add libstdc++ libgcc)." ;;
      linux-*) hint=" It needs a 64-bit Linux with glibc." ;;
      *) hint="" ;;
    esac
    fail "the downloaded rbai does not start on this machine ($(head -n 3 "$tmp/version.err" | tr '\n' ' '))$hint Nothing was installed. $NPM_HINT"
  fi
  [ "$got" = "$version" ] || fail "the downloaded program says it is version \"$got\", not $version. Nothing was installed."

  # -- install ----------------------------------------------------------------
  mv -f "$partial" "$dir/rbai" || fail "could not move rbai into $dir."
  {
    printf '# rbai was installed in this folder by %s/install.sh; delete the folder to uninstall it.\n' "$HOST"
    printf 'host=%s\nversion=%s\ntarget=%s\ninstalled=%s\n' "$HOST" "$version" "$target" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } >"$dir/.rbai-install"

  rc=""
  case ":${PATH:-}:" in
    *":$dir:"*) on_path=1 ;;
    *) on_path=0 ;;
  esac
  if [ "$on_path" = 0 ]; then
    shown="$dir"
    case "$dir" in
      "$HOME"/*) shown="\$HOME${dir#"$HOME"}" ;;
    esac
    line="export PATH=\"$shown:\$PATH\" # rbai"
    if [ "${RBAI_NO_MODIFY_PATH:-}" = 1 ]; then
      say "$dir is not on your PATH. To run rbai from any folder, add this line to your shell's startup file:"
      say "  $line"
    else
      case "${SHELL:-}" in
        */zsh) rc="${ZDOTDIR:-$HOME}/.zshrc" ;;
        */bash) if [ "$os" = darwin ]; then rc="$HOME/.bash_profile"; else rc="$HOME/.bashrc"; fi ;;
        */fish) rc="$HOME/.config/fish/conf.d/rbai.fish" ;;
        *) rc="$HOME/.profile" ;;
      esac
      if [ "${rc##*/}" = rbai.fish ]; then
        if mkdir -p "${rc%/*}" && printf "fish_add_path -g '%s' # rbai\n" "$dir" >"$rc"; then
          say "Added $dir to PATH in $rc."
        else
          say "Could not write $rc. Add $dir to your PATH yourself."
          rc=""
        fi
      elif grep -qsF "$line" "$rc"; then
        say "$rc already adds $dir to PATH."
      elif printf '\n%s\n' "$line" >>"$rc"; then
        say "Added $dir to PATH in $rc."
      else
        say "Could not write $rc. To run rbai from any folder, add this line to your shell's startup file:"
        say "  $line"
        rc=""
      fi
    fi
  fi

  first="$(command -v rbai 2>/dev/null || true)"
  if [ -n "$first" ] && [ "$first" != "$dir/rbai" ]; then
    say "Note: another rbai comes first on your PATH: $first (npm's rbai-cli, or an older copy)."
    say "      Remove it (npm: npm uninstall -g rbai-cli) or put $dir before it."
  fi

  say ""
  say "rbai $version is installed: $dir/rbai"
  if [ -n "$note" ]; then say "$note"; fi
  if [ -n "$rc" ]; then
    say "Open a new terminal (or run: . \"$rc\"), then:"
  else
    say "Next:"
  fi
  say "  rbai login    sign in through your browser"
  say "  rbai          start the chat"
  say ""
  # (Not ${rc:-...} with an apostrophe in the default: shells disagree on quotes inside it.)
  if [ -n "$rc" ]; then startup="$rc"; else startup="your shell's startup file"; fi
  say "Uninstall: rbai logout, then rm -rf \"$dir\", and delete the line ending in # rbai from $startup."
}

main "$@"
