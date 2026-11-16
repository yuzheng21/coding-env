#!/bin/bash
# Fresh-Mac entry point. Uses only what ships with macOS (bash 3.2, curl, sudo).
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yuzheng21/coding-env/master/bootstrap.sh)"
#
# 1. installs Homebrew, whose installer also installs the Xcode Command Line
#    Tools (git) without the GUI dialog
# 2. clones this repo over HTTPS (no SSH key needed) to ~/workspace/coding-env
#    and sets the push URL to SSH for later, once you've added a key to GitHub
# 3. runs ./install.sh (all steps)
set -euo pipefail

REPO_HTTPS="https://github.com/yuzheng21/coding-env.git"
REPO_SSH="git@github.com:yuzheng21/coding-env.git"
DEST="${CODING_ENV_DIR:-$HOME/workspace/coding-env}"

echo "==> sudo (Homebrew and some casks need it; asked once)"
sudo -v
while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done 2>/dev/null &

for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
done
if ! command -v brew >/dev/null; then
  echo "==> Homebrew + Xcode Command Line Tools"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

echo "==> coding-env -> $DEST"
if [[ -d "$DEST/.git" ]]; then
  git -C "$DEST" pull --ff-only
else
  mkdir -p "$(dirname "$DEST")"
  git clone "$REPO_HTTPS" "$DEST"
  git -C "$DEST" remote set-url --push origin "$REPO_SSH"
fi

# exec keeps the PID, so the sudo keep-alive loop above keeps running.
exec "$DEST/install.sh" "$@"
