# Shared paths and helpers for install.sh / export.sh. Source, don't execute.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
ITERM_DOMAIN="com.googlecode.iterm2"
ITERM_PLIST="$REPO_DIR/iterm/com.googlecode.iterm2.plist"
VSCODE_EXTENSIONS="$REPO_DIR/vscode/extensions.txt"
OH_MY_TMUX_DIR="$HOME/.local/share/tmux/oh-my-tmux"

# Dotfiles that are symlinked from $HOME into this repo.
# Format: "<path in repo>|<path on this mac>"
LINKS=(
  "vim/.vimrc|$HOME/.vimrc"
  "zsh/.zshrc|$HOME/.zshrc"
  "zsh/themes/dracula.zsh-theme|$ZSH_CUSTOM_DIR/themes/dracula.zsh-theme"
  "zsh/themes/lib/async.zsh|$ZSH_CUSTOM_DIR/themes/lib/async.zsh"
  "tmux/tmux.conf.local|$HOME/.config/tmux/tmux.conf.local"
  "vscode/settings.json|$VSCODE_USER_DIR/settings.json"
  "vscode/keybindings.json|$VSCODE_USER_DIR/keybindings.json"
)

if [[ -t 1 ]]; then
  _c_info=$'\033[1;34m' _c_ok=$'\033[1;32m' _c_warn=$'\033[1;33m' _c_off=$'\033[0m'
else
  _c_info="" _c_ok="" _c_warn="" _c_off=""
fi
info() { printf '%s==>%s %s\n' "$_c_info" "$_c_off" "$*"; }
ok()   { printf '%s  ✓%s %s\n' "$_c_ok" "$_c_off" "$*"; }
warn() { printf '%s  !%s %s\n' "$_c_warn" "$_c_off" "$*" >&2; }
