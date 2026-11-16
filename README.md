# coding-env

My macOS dev setup: zsh, vim, tmux, iTerm2, VS Code.

## New Mac

```sh
xcode-select --install                      # gives you git; wait for it to finish
git clone <this repo> ~/workspace/coding-env
cd ~/workspace/coding-env
./install.sh
```

Run `./install.sh` from **Terminal.app**, not iTerm2. The iTerm2 step is skipped while iTerm2 is running, because iTerm2 would overwrite the imported preferences when it quits.

Run only some steps with `./install.sh vim zsh`. The steps are:

| step     | what it does |
|----------|--------------|
| `brew`   | Command Line Tools, Homebrew, everything in `Brewfile` (incl. iTerm2, VS Code, JDK 25, Go, Docker) |
| `fonts`  | copies `font/*` to `~/Library/Fonts` |
| `zsh`    | Oh My Zsh, zsh-syntax-highlighting, zsh-autosuggestions, Dracula theme, `.zshrc`; sets zsh as the login shell |
| `vim`    | `.vimrc`, vim-plug, `:PlugInstall` |
| `tmux`   | Oh my tmux! + `tmux.conf.local` |
| `iterm`  | imports `iterm/com.googlecode.iterm2.plist` (Dracula profile as default, plus global prefs) |
| `vscode` | `settings.json`, `keybindings.json`, extensions from `vscode/extensions.txt` |
| `claude` | Claude Code (native installer) |

Re-running is safe. Before replacing a file, the script moves it to `~/.dotfiles-backup/<timestamp>/`.

## How the configs stay up to date

- **Symlinked** (edits on the Mac go straight into the repo): `~/.vimrc`, `~/.zshrc`, the Dracula zsh theme, `~/.config/tmux/tmux.conf.local`, and VS Code's `settings.json` / `keybindings.json`.
- **Exported** (snapshot, re-run `./export.sh`): iTerm2 preferences, VS Code extension list. `export.sh` also lists Homebrew packages you've installed that aren't in the `Brewfile` yet.

After changing iTerm2 settings or installing a VS Code extension:

```sh
./export.sh && git diff
```

The iTerm2 export leaves out window positions, update and analytics bookkeeping, and the AI plugin settings (including any API key). It also writes `__HOME__` in place of your home directory, and the importer fills in the new Mac's path.

## Layout

```
install.sh / export.sh   set up a Mac / capture this Mac into the repo
scripts/common.sh        shared paths + list of symlinked files
Brewfile                 Homebrew formulae & casks
zsh/                     .zshrc, themes/dracula.zsh-theme (+ lib/async.zsh)
vim/                     .vimrc (vim-plug, Dracula); colors/ = older unused schemes
tmux/                    tmux.conf.local for Oh my tmux!
iterm/                   com.googlecode.iterm2.plist; colors/*.itermcolors
vscode/                  settings.json, keybindings.json, extensions.txt
font/                    Consolas, Inconsolata, DejaVu Sans Mono, Droid Sans Mono
intellij/ terminfo/      older extras (not installed by the script)
```

## References

- Oh My Zsh <https://ohmyz.sh> · Dracula for zsh <https://draculatheme.com/zsh> / iTerm <https://draculatheme.com/iterm>
- vim-plug <https://github.com/junegunn/vim-plug>
- Oh my tmux! <https://github.com/gpakosz/.tmux>
- Italics & true colour in iTerm/tmux/vim: <https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be>
