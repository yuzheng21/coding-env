# coding-env

Yu's macOS dev setup (zsh, vim, tmux, iTerm2, VS Code). The goal: a brand-new MacBook ends up exactly like the current one, and it must not depend on anything from the old machine.

## Fresh Mac

Run in **Terminal.app** (not iTerm2). Nothing needs to be installed first:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yuzheng21/coding-env/master/bootstrap.sh)"
```

`bootstrap.sh` asks for sudo once, installs Homebrew (which installs the Xcode CLT and git headlessly), clones over HTTPS to `~/workspace/coding-env` with an SSH push URL, and runs `./install.sh`.

## Rules

- **Push before it counts.** The one-liner fetches `bootstrap.sh` from GitHub `master`, so changes don't reach a new Mac until they're pushed.
- **The repo must stay public.** The curl download and the HTTPS clone rely on it.
- **Only tools that ship with macOS** before Homebrew is installed: `/bin/bash` 3.2, curl, sudo, `defaults`, `tic`. No bash 4+ features (associative arrays, `mapfile`, `${var,,}`). Note that `"${arr[@]}"` on an empty array fails under `set -u`. We chose not to use Lua or Python for the installer because macOS doesn't ship Lua.
- **Nothing machine-specific in tracked files.** No `/Users/<name>`, hostname or email. The iTerm plist stores `__HOME__`, and `install.sh` replaces it with the new Mac's home folder.
- Steps must stay **safe to re-run**. Files that get replaced are moved to `~/.dotfiles-backup/<timestamp>/`.

## How sync works

- **Symlinked** (on a set-up Mac, editing `~/.vimrc` etc. edits the repo): the list is in `scripts/common.sh` (`LINKS`). A dotfile change therefore shows up in `git status`.
- **Snapshots** (run `./export.sh`, then `git diff`): iTerm2 preferences and the VS Code extension list. `export.sh` also reports Homebrew packages missing from `Brewfile`.
- Run `./install.sh iterm` only while iTerm2 is **not** running; it overwrites the imported prefs when it quits.
- The iTerm2 Dracula profile uses `TERM=xterm-256color-italic`, so the `terminfo` step must run. Without it vim, less and tput fail with "unknown terminal".

## Testing changes

Run the steps against an empty test home folder with a bare PATH. This doesn't touch the real configs:

```sh
H=$(mktemp -d); env -i HOME=$H PATH=/usr/bin:/bin:/usr/sbin:/sbin SHELL=/bin/zsh TERM=xterm-256color \
  /bin/bash ./install.sh fonts terminfo zsh vim tmux vscode
```

Don't test the `iterm` step this way: `defaults import` writes to the real preferences regardless of `$HOME`. Test the plist by importing it into a dummy domain such as `com.example.test` instead.
