#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
usage:
  ./install.sh                  Install .tmux.conf locally
  ./install.sh user@host         Install .tmux.conf on a remote machine over SSH

options:
  -h, --help                     Show this help

The installer backs up an existing ~/.tmux.conf before replacing it.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

if [ "$#" -gt 1 ]; then
  echo "error: expected at most one target" >&2
  usage >&2
  exit 2
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_conf="$script_dir/.tmux.conf"
target="${1:-}"

if [ ! -f "$source_conf" ]; then
  echo "error: missing $source_conf" >&2
  exit 1
fi

timestamp=$(date +%Y%m%d-%H%M%S)

if [ -z "$target" ]; then
  backup_conf="$HOME/.tmux.conf.bak.$timestamp"

  if [ -f "$HOME/.tmux.conf" ]; then
    cp "$HOME/.tmux.conf" "$backup_conf"
    echo "backed up ~/.tmux.conf to $backup_conf"
  fi

  cp "$source_conf" "$HOME/.tmux.conf"
  chmod 0644 "$HOME/.tmux.conf"
  echo "installed .tmux.conf locally"
  exit 0
fi

for cmd in scp ssh; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: $cmd is required for remote installs" >&2
    exit 1
  fi
done

remote_tmp=".tmux.conf.mosh-tmux-install.$$.$timestamp"

scp "$source_conf" "$target:$remote_tmp"
ssh "$target" "set -eu
  remote_conf=\"\$HOME/.tmux.conf\"
  remote_backup=\"\$HOME/.tmux.conf.bak.$timestamp\"
  remote_tmp=\"\$HOME/$remote_tmp\"

  if [ -f \"\$remote_conf\" ]; then
    cp \"\$remote_conf\" \"\$remote_backup\"
    echo \"backed up ~/.tmux.conf to \$remote_backup\"
  fi

  mv \"\$remote_tmp\" \"\$remote_conf\"
  chmod 0644 \"\$remote_conf\"

  if command -v tmux >/dev/null 2>&1 && [ -n \"\${TMUX:-}\" ]; then
    tmux source-file \"\$remote_conf\"
  fi

  echo \"installed .tmux.conf on $target\"
"
