# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="dracula"
zstyle ':omz:update' mode reminder
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Plugins
# zsh-syntax-highlighting: colors commands as you type
# zsh-autosuggestions: suggests from history, accept with →
plugins=(git history zsh-syntax-highlighting zsh-autosuggestions)

# Docker CLI completions (must be before oh-my-zsh source)
[[ -d $HOME/.docker/completions ]] && fpath=($HOME/.docker/completions $fpath)

source $ZSH/oh-my-zsh.sh

# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH=$PATH:$HOME/.local/bin

# Homebrew
export PATH=$PATH:/opt/homebrew/bin

# Java
# JDK 25 if present, else the newest installed JDK
export JAVA_HOME=$(/usr/libexec/java_home -v 25 2>/dev/null || /usr/libexec/java_home 2>/dev/null)

# Go
export GOPATH=$HOME/go
# Official Go installer uses /usr/local/go; Homebrew's go needs no GOROOT
if [[ -d /usr/local/go ]]; then
  export GOROOT=/usr/local/go
  export PATH=$PATH:$GOROOT/bin
fi
export PATH=$PATH:$GOPATH/bin

# Aliases
alias zshconfig="vim ~/.zshrc"
alias ll="ls -lha"
alias lsd='ls -d */'
alias ssh='TERM=xterm-256color ssh'
alias t='tmux'
alias e='exit'
alias vs='code'
alias v='vim'
alias cc='claude'
alias python=python3

# LaTeX
eval "$(/usr/libexec/path_helper)"
