# mosh-tmux

Shareable tmux configuration and a `mosh-tmux` zsh helper.

## Requirements

- `tmux` 3.2 or newer for the bundled status-line formatting.
- `mosh` and `zsh` for the `mosh-tmux` helper.
- `ssh`/`scp` when installing on a remote machine.

## Files

- `.tmux.conf`: tmux settings and status bar style.
- `mosh-tmux.zsh`: zsh function that connects with `mosh` and attaches or creates a tmux session.

## Install locally

```sh
./install.sh
```

The installer copies `.tmux.conf` and `mosh-tmux.zsh`, then adds this line to
`~/.zshrc` if needed:

```sh
[ -f "$HOME/.mosh-tmux.zsh" ] && source "$HOME/.mosh-tmux.zsh"
```

Reload zsh:

```sh
source ~/.zshrc
```

## Install on a remote machine

```sh
./install.sh user@host
```

The installer copies `.tmux.conf` and `mosh-tmux.zsh` over SSH, backs up any
existing remote files to `*.bak.YYYYMMDD-HHMMSS`, and configures remote
`~/.zshrc` to source the helper.

Use the default `main` session:

```sh
mosh-tmux user@host
```

Use a named session:

```sh
mosh-tmux -s work user@host
```

Session names must not contain `:` because tmux uses that character as a target
separator.

Pass extra tmux arguments after the host, for example to start in a directory:

```sh
mosh-tmux -s work user@host -c ~/src
```

Show the helper usage:

```sh
mosh-tmux --help
```
