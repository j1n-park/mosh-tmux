# mosh + tmux helper
mosh-tmux() {
  local session="main"

  if [ "$1" = "-s" ]; then
    session="$2"
    shift 2
  fi

  if [ -z "$1" ]; then
    echo "usage: mosh-tmux [-s session] user@host [tmux args...]" >&2
    return 2
  fi

  local target="$1"
  shift

  command mosh --no-init "$target" -- tmux new -A -s "$session" "$@"
}
