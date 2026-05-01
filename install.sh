#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
usage:
  ./install.sh                 Install .tmux.conf locally
  ./install.sh user@host        Install .tmux.conf on a remote machine over SSH

options:
  -h, --help                    Show this help

The installer backs up an existing ~/.tmux.conf before replacing it.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_conf="$script_dir/.tmux.conf"
target="${1:-}"

if [ ! -f "$source_conf" ]; then
  echo "error: missing $source_conf" >&2
  exit 1
fi

timestamp=$(date +%Y%m%d-%H%M%S)

if [ -z "$target" ]; then
  if [ -f "$HOME/.tmux.conf" ]; then
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$timestamp"
    echo "backed up ~/.tmux.conf to ~/.tmux.conf.bak.$timestamp"
  fi

  cp "$source_conf" "$HOME/.tmux.conf"
  echo "installed .tmux.conf locally"
  exit 0
fi

remote_tmp=".tmux.conf.mosh-tmux-install.$$"

scp "$source_conf" "$target:$remote_tmp"
ssh "$target" "set -eu
  if [ -f \"\$HOME/.tmux.conf\" ]; then
    cp \"\$HOME/.tmux.conf\" \"\$HOME/.tmux.conf.bak.$timestamp\"
    echo \"backed up ~/.tmux.conf to ~/.tmux.conf.bak.$timestamp\"
  fi
  mv \"\$HOME/$remote_tmp\" \"\$HOME/.tmux.conf\"
  if command -v tmux >/dev/null 2>&1 && [ -n \"\${TMUX:-}\" ]; then
    tmux source-file \"\$HOME/.tmux.conf\"
  fi
  echo \"installed .tmux.conf on $target\"
"
