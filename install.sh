#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
usage:
  ./install.sh [--helper]         Install .tmux.conf locally
  ./install.sh [--helper] user@host
                                  Install files on a remote machine over SSH

options:
  --helper                        Also install mosh-tmux.zsh
  -h, --help                      Show this help

The installer backs up existing target files before replacing them.
EOF
}

install_helper=false
target=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --helper)
      install_helper=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -n "$target" ]; then
        echo "error: expected at most one target" >&2
        usage >&2
        exit 2
      fi
      target="$1"
      shift
      ;;
  esac
done

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_conf="$script_dir/.tmux.conf"
helper_file="$script_dir/mosh-tmux.zsh"

if [ ! -f "$source_conf" ]; then
  echo "error: missing $source_conf" >&2
  exit 1
fi

if [ "$install_helper" = "true" ] && [ ! -f "$helper_file" ]; then
  echo "error: missing $helper_file" >&2
  exit 1
fi

timestamp=$(date +%Y%m%d-%H%M%S)

install_local_file() {
  src=$1
  dest=$2
  mode=$3
  label=$4

  if [ -f "$dest" ]; then
    backup_file="$dest.bak.$timestamp"
    cp "$dest" "$backup_file"
    echo "backed up $dest to $backup_file"
  fi

  cp "$src" "$dest"
  chmod "$mode" "$dest"
  echo "installed $label locally"
}

if [ -z "$target" ]; then
  install_local_file "$source_conf" "$HOME/.tmux.conf" 0644 ".tmux.conf"

  if [ "$install_helper" = "true" ]; then
    install_local_file "$helper_file" "$HOME/.mosh-tmux.zsh" 0644 "mosh-tmux helper"
  fi

  exit 0
fi

for cmd in scp ssh; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: $cmd is required for remote installs" >&2
    exit 1
  fi
done

remote_conf_tmp=".tmux.conf.mosh-tmux-install.$$.$timestamp"
remote_helper_tmp=".mosh-tmux.zsh.mosh-tmux-install.$$.$timestamp"

scp "$source_conf" "$target:$remote_conf_tmp"
if [ "$install_helper" = "true" ]; then
  scp "$helper_file" "$target:$remote_helper_tmp"
fi

ssh "$target" "set -eu
  install_helper=\"$install_helper\"
  remote_conf=\"\$HOME/.tmux.conf\"
  remote_conf_tmp=\"\$HOME/$remote_conf_tmp\"
  remote_helper=\"\$HOME/.mosh-tmux.zsh\"
  remote_helper_tmp=\"\$HOME/$remote_helper_tmp\"

  cleanup() {
    rm -f \"\$remote_conf_tmp\" \"\$remote_helper_tmp\"
  }
  trap cleanup EXIT HUP INT TERM

  install_remote_file() {
    src=\$1
    dest=\$2
    mode=\$3
    label=\$4

    if [ -f \"\$dest\" ]; then
      backup_file=\"\$dest.bak.$timestamp\"
      cp \"\$dest\" \"\$backup_file\"
      echo \"backed up \$dest to \$backup_file\"
    fi

    mv \"\$src\" \"\$dest\"
    chmod \"\$mode\" \"\$dest\"
    echo \"installed \$label on $target\"
  }

  install_remote_file \"\$remote_conf_tmp\" \"\$remote_conf\" 0644 .tmux.conf

  if [ \"\$install_helper\" = \"true\" ]; then
    install_remote_file \"\$remote_helper_tmp\" \"\$remote_helper\" 0644 \"mosh-tmux helper\"
  fi

  if command -v tmux >/dev/null 2>&1 && [ -n \"\${TMUX:-}\" ]; then
    tmux source-file \"\$remote_conf\"
  fi
"
