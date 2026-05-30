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

  if [[ "$session" == *:* ]]; then
    print -u2 "error: session name must not contain ':'"
    return 2
  fi

  if [[ -z "${1:-}" ]]; then
    print -u2 "usage: mosh-tmux [-s session] user@host [tmux args...]"
    return 2
  fi

  local target="$1"
  shift

  command mosh --no-init "$target" -- tmux new-session -A -s "$session" "$@"
}

if [ -n "$TMUX" ]; then
  tmux set-option -wq @last_command "shell"

  preexec() {
    local cmd="${1%% *}"
    cmd="${cmd[1,24]}"
    tmux set-option -wq @last_command "$cmd"
  }
fi

