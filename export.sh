#!/usr/bin/env bash
# Capture this Mac's current vim / zsh / tmux / iTerm2 / VS Code setup into the repo.
# Run it whenever you change settings, then review with `git diff` and commit.
#
#   ./export.sh
set -euo pipefail
source "$(dirname "$0")/scripts/common.sh"
cd "$REPO_DIR"

# --- dotfiles ---------------------------------------------------------------
info "Dotfiles"
# The Dracula theme may live in $ZSH/themes (manual install) or $ZSH_CUSTOM/themes.
theme_src() {
  local rel="$1"
  for d in "$ZSH_CUSTOM_DIR/themes" "$ZSH_DIR/themes"; do
    if [[ -e "$d/$rel" ]]; then echo "$d/$rel"; return; fi
  done
  return 0
}
for entry in "${LINKS[@]}"; do
  repo_rel="${entry%%|*}" live="${entry#*|}"
  case "$repo_rel" in
    zsh/themes/*) live="$(theme_src "${repo_rel#zsh/themes/}")" ;;
  esac
  if [[ -z "$live" || ! -e "$live" ]]; then
    warn "missing on this mac, skipped: $repo_rel"
  elif [[ -L "$live" && "$(readlink "$live")" == "$REPO_DIR/$repo_rel" ]]; then
    ok "$repo_rel (already symlinked to repo)"
  else
    mkdir -p "$(dirname "$repo_rel")"
    cp "$live" "$repo_rel"
    ok "$repo_rel  <-  $live"
  fi
done

# --- VS Code extensions -----------------------------------------------------
info "VS Code extensions"
if command -v code >/dev/null; then
  code --list-extensions | sort -f > "$VSCODE_EXTENSIONS"
  ok "$(wc -l < "$VSCODE_EXTENSIONS" | tr -d ' ') extensions -> vscode/extensions.txt"
else
  warn "'code' CLI not on PATH; extensions not exported"
fi

# --- iTerm2 -----------------------------------------------------------------
# Exports the preferences (profiles, colors, keys, appearance) minus
# machine-specific state, window positions, update bookkeeping and AI/API keys.
# Your home directory is replaced with __HOME__ so it imports on any user.
info "iTerm2 preferences"
python3 - "$HOME" "$ITERM_PLIST" <<'PY'
import os, plistlib, sys
home, out = sys.argv[1], sys.argv[2]
src = os.path.join(home, "Library/Preferences/com.googlecode.iterm2.plist")
with open(src, "rb") as f:
    prefs = plistlib.load(f)

DROP_PREFIXES = ("NoSync", "NSWindow Frame", "SU", "AI", "Ai", "NSNav", "NSOSP",
                 "NSSplitView", "NSToolbar")
DROP_KEYS = {"iTerm Version"}

def scrub(v):
    if isinstance(v, str):
        return v.replace(home, "__HOME__")
    if isinstance(v, list):
        return [scrub(x) for x in v]
    if isinstance(v, dict):
        return {k: scrub(x) for k, x in v.items()}
    return v

clean = {k: scrub(v) for k, v in prefs.items()
         if not k.startswith(DROP_PREFIXES) and k not in DROP_KEYS}
with open(out, "wb") as f:
    plistlib.dump(clean, f, fmt=plistlib.FMT_XML, sort_keys=True)
names = ", ".join(b.get("Name", "?") for b in clean.get("New Bookmarks", []))
print(f"  kept {len(clean)}/{len(prefs)} keys; profiles: {names}")
PY
ok "iterm/com.googlecode.iterm2.plist"

# --- Homebrew drift ---------------------------------------------------------
info "Homebrew"
if command -v brew >/dev/null; then
  export HOMEBREW_NO_AUTO_UPDATE=1
  # Names only (strip tap prefixes), sorted, for comm(1).
  names() { sed 's|.*/||' | sort -u; }
  want_f="$(brew bundle list --file="$REPO_DIR/Brewfile" --formula 2>/dev/null | names)"
  want_c="$(brew bundle list --file="$REPO_DIR/Brewfile" --cask 2>/dev/null | names)"
  extra="$( { comm -23 <(brew leaves --installed-on-request | names) <(echo "$want_f") | sed 's/^/brew "/; s/$/"/'
              comm -23 <(brew list --cask | names) <(echo "$want_c") | sed 's/^/cask "/; s/$/"/'; } )"
  if [[ -n "$extra" ]]; then
    warn "installed but not in Brewfile (add them if you want them on new macs):"
    sed 's/^/      /' <<<"$extra" >&2
  else
    ok "Brewfile covers everything installed"
  fi
fi

echo
info "Done. Review with: git -C \"$REPO_DIR\" diff"
