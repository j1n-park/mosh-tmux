# mosh-tmux

Shareable tmux configuration and a `mosh-tmux` zsh helper.

## Requirements

- `tmux` 3.2 or newer for the bundled status-line formatting.
- `mosh` and `zsh` for the optional `mosh-tmux` helper.
- `ssh`/`scp` when installing on a remote machine.

## Files

- `.tmux.conf`: tmux settings and status bar style.
- `mosh-tmux.zsh`: zsh function that connects with `mosh` and attaches or creates a tmux session.

## Install locally

```sh
./install.sh --helper
printf '\n[ -f "$HOME/.mosh-tmux.zsh" ] && source "$HOME/.mosh-tmux.zsh"\n' >> ~/.zshrc
```

Reload zsh:

```sh
source ~/.zshrc
```

## Install tmux config on a remote machine

```sh
./install.sh user@host
```

The installer copies `.tmux.conf` over SSH and backs up any existing remote
`~/.tmux.conf` to `~/.tmux.conf.bak.YYYYMMDD-HHMMSS`.

If you also want the `mosh-tmux` helper on the remote machine:

```sh
./install.sh --helper user@host
ssh user@host 'printf "\n[ -f \"\$HOME/.mosh-tmux.zsh\" ] && source \"\$HOME/.mosh-tmux.zsh\"\n" >> ~/.zshrc'
```

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
