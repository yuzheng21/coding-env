#!/usr/bin/env bash
# Set up a fresh Mac from this repo. Safe to re-run.
#
#   ./install.sh                 # everything
#   ./install.sh vim zsh         # only some steps
#
# Steps: brew fonts terminfo zsh vim tmux iterm vscode claude
#
# Existing files that would be replaced are moved to ~/.dotfiles-backup/<timestamp>/.
set -euo pipefail
source "$(dirname "$0")/scripts/common.sh"

ALL_STEPS=(brew fonts terminfo zsh vim tmux iterm vscode claude)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Symlink $REPO_DIR/<repo_rel> to <dest>, backing up whatever is there.
link() {
  local src="$REPO_DIR/$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    ok "$dest (already linked)"; return
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    warn "backed up existing $dest -> $BACKUP_DIR/"
  fi
  ln -s "$src" "$dest"
  ok "$dest -> $1"
}

link_matching() {  # link every LINKS entry whose repo path starts with $1
  for entry in "${LINKS[@]}"; do
    if [[ "${entry%%|*}" == "$1"* ]]; then link "${entry%%|*}" "${entry#*|}"; fi
  done
  return 0
}

clone_or_pull() {
  if [[ -d "$2/.git" ]]; then
    git -C "$2" pull --ff-only --quiet && ok "updated $2"
  else
    git clone --depth=1 --quiet "$1" "$2" && ok "cloned $2"
  fi
}

# Ask for the password once and keep sudo's timestamp fresh while we run
# (Homebrew's non-interactive installer and pkg-based casks need it).
keep_sudo_alive() {
  [[ -n "${_SUDO_KEEPALIVE:-}" ]] && return 0
  sudo -v
  while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done 2>/dev/null &
  _SUDO_KEEPALIVE=$!
}

brew_shellenv() {
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$b" ]] && { eval "$("$b" shellenv)"; return 0; }
  done
  return 1
}

# --- steps ------------------------------------------------------------------

step_brew() {
  info "Homebrew (its installer also installs the Xcode Command Line Tools, incl. git)"
  keep_sudo_alive
  if ! brew_shellenv; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_shellenv
  fi
  ok "$(brew --version | head -1)"
  if ! xcode-select -p >/dev/null 2>&1; then
    warn "Xcode Command Line Tools missing: run 'xcode-select --install', then ./install.sh"
    exit 1
  fi

  info "brew bundle (this can take a while; some casks ask for your password)"
  # Don't let one failed download stop the dotfile steps that follow.
  brew bundle --file="$REPO_DIR/Brewfile" ||
    warn "some Brewfile entries failed; fix them and re-run ./install.sh brew"
}

step_fonts() {
  info "Fonts"
  mkdir -p "$HOME/Library/Fonts"
  cp -n "$REPO_DIR"/font/*.{ttf,otf} "$HOME/Library/Fonts/" 2>/dev/null || true
  ok "copied font/* to ~/Library/Fonts"
}

step_terminfo() {
  info "terminfo"
  # The iTerm2 Dracula profile sets TERM=xterm-256color-italic, which macOS
  # doesn't ship; without it vim/less/tput fail with "unknown terminal".
  mkdir -p "$HOME/.terminfo"
  for f in "$REPO_DIR"/terminfo/*.terminfo; do
    tic -x -o "$HOME/.terminfo" "$f"
    ok "$(basename "$f" .terminfo)"
  done
}

step_zsh() {
  info "Oh My Zsh"
  # Link .zshrc first so the Oh My Zsh installer (KEEP_ZSHRC) leaves it alone.
  link zsh/.zshrc "$HOME/.zshrc"
  if [[ ! -f "$ZSH_DIR/oh-my-zsh.sh" ]]; then
    # A half-finished install (e.g. a plugin clone that ran after a failed
    # download) leaves $ZSH_DIR behind, and the Oh My Zsh installer refuses
    # to install into an existing folder. Move it aside.
    if [[ -e "$ZSH_DIR" ]]; then
      mkdir -p "$BACKUP_DIR"
      mv "$ZSH_DIR" "$BACKUP_DIR/"
      warn "moved incomplete $ZSH_DIR -> $BACKUP_DIR/"
    fi
    # Download first: inside "$(...)" as an argument, a curl failure is ignored by set -e.
    local omz_installer
    omz_installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$omz_installer" "" --unattended
    [[ -f "$ZSH_DIR/oh-my-zsh.sh" ]] || { warn "Oh My Zsh install failed; re-run ./install.sh zsh"; exit 1; }
  fi
  ok "$ZSH_DIR"
  clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  clone_or_pull https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  link_matching zsh/themes/
  if [[ "$SHELL" != */zsh ]]; then
    chsh -s /bin/zsh && ok "login shell set to zsh"
  fi
}

step_vim() {
  info "Vim"
  link_matching vim/
  if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    curl -fsSLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  vim -E -s -u "$HOME/.vimrc" +PlugInstall +qall </dev/null || true
  ok "vim-plug plugins installed"
}

step_tmux() {
  info "tmux (Oh my tmux!)"
  clone_or_pull https://github.com/gpakosz/.tmux "$OH_MY_TMUX_DIR"
  mkdir -p "$HOME/.config/tmux"
  ln -sfn "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
  link_matching tmux/
}

step_iterm() {
  info "iTerm2 preferences"
  if pgrep -xq iTerm2; then
    warn "iTerm2 is running and would overwrite the import when it quits."
    warn "Quit iTerm2, then run from Terminal.app:  ./install.sh iterm"
    return
  fi
  local tmp; tmp="$(mktemp -d)/iterm2.plist"
  # __HOME__ placeholders were written by export.sh; '|' delimiter because $HOME has '/'.
  sed "s|__HOME__|$HOME|g" "$ITERM_PLIST" > "$tmp"
  defaults import "$ITERM_DOMAIN" "$tmp"
  rm -f "$tmp"
  mkdir -p "$HOME/workspace"   # the Dracula profile opens new windows in ~/workspace
  ok "imported iterm/com.googlecode.iterm2.plist (Dracula profile is the default)"
}

step_vscode() {
  info "VS Code"
  link_matching vscode/
  local code_bin
  code_bin="$(command -v code || echo "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code")"
  if [[ ! -x "$code_bin" ]]; then
    warn "VS Code not found; install it (brew step) and re-run ./install.sh vscode"
    return
  fi
  local installed; installed="$("$code_bin" --list-extensions | tr 'A-Z' 'a-z')"
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    if grep -qx "$(tr 'A-Z' 'a-z' <<<"$ext")" <<<"$installed"; then
      ok "$ext (already installed)"
    else
      "$code_bin" --install-extension "$ext" --force >/dev/null && ok "$ext"
    fi
  done < "$VSCODE_EXTENSIONS"
}

step_claude() {
  info "Claude Code"
  if command -v claude >/dev/null || [[ -x "$HOME/.local/bin/claude" ]]; then
    ok "already installed"
  else
    curl -fsSL https://claude.ai/install.sh | bash
  fi
}

# --- main -------------------------------------------------------------------

steps=("$@")
[[ ${#steps[@]} -eq 0 ]] && steps=("${ALL_STEPS[@]}")
for s in "${steps[@]}"; do
  if ! declare -F "step_$s" >/dev/null; then
    echo "Unknown step: $s (choose from: ${ALL_STEPS[*]})" >&2; exit 2
  fi
done

brew_shellenv || true
for s in "${steps[@]}"; do "step_$s"; done

echo
info "All done. Open a new terminal (iTerm2) to load the new shell config."
if [[ -d "$BACKUP_DIR" ]]; then info "Replaced files were backed up to $BACKUP_DIR"; fi
exit 0
