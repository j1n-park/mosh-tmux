# mosh + tmux helper
mosh-tmux() {
  emulate -L zsh

  local session="main"

  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    print -u2 "usage: mosh-tmux [-s session] user@host [tmux args...]"
    return 0
  fi

  if [[ "${1:-}" == "-s" ]]; then
    if [[ -z "${2:-}" ]]; then
      print -u2 "error: -s requires a session name"
      print -u2 "usage: mosh-tmux [-s session] user@host [tmux args...]"
      return 2
    fi

    session="$2"
    shift 2
  fi

  if [[ -z "${1:-}" ]]; then
    print -u2 "usage: mosh-tmux [-s session] user@host [tmux args...]"
    return 2
  fi

  local target="$1"
  shift

  command mosh --no-init "$target" -- tmux new-session -A -s "$session" "$@"
}
