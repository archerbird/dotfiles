# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history
HISTFILE=$HOME/.zhistory
SAVEHIST=3000
HISTSIZE=999
setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_verify
setopt hist_find_no_dups

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# use eza for ls plus some ls shorthand
alias ls="eza --color=always --long --grid --no-filesize --icons=always --no-time --no-user --no-permissions"
alias la="ls -a"
alias ll="eza --long --no-user --icons=always -a"
alias lf="la --only-files"
alias ld="la --only-dirs"
alias lt="eza --tree --level=2 --icons --git"

# use zoxide for cd
alias cd="z"
eval "$(zoxide init zsh)"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# show an ls after each cd
function chpwd() {
    emulate -L zsh
    ls -a
}

#just make the damn dirs
alias mkdir="mkdir -p"

# enable vi mode
bindkey -v
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# always route to nvim
export EDITOR=nvim
alias vi="nvim"
alias vim="nvim"
alias cat="bat"
export BAT_THEME="Catppuccin Mocha"

#git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# dotnet
alias dnr="dotnet restore --no-cache"
alias dnb="dotnet build"
alias dnc="dotnet clean"
alias dnx="dotnet run"
alias dnf="dnc; dnr; dnb"

# dotfiles shortcuts
alias ezsh="nvim ~/.zshrc"
alias etmux="nvim ~/.config/tmux/tmux.conf"

# set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd  --hidden --strip-cwd-prefix --exclude .git'
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}
_fzf_compgen_dir() {
  fd --type d --hidden --exclude .git . "$1"
}

# autocompletions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
autoload -U compinit; compinit
source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# zsh parameter completion for the dotnet CLI

_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  # If the completion list is empty, just continue with filename selection
  if [ -z "$completions" ]
  then
    _arguments '*::arguments: _normal'
    return
  fi

  # This is not a variable assignment, don't remove spaces!
  _values = "${(ps:\n:)completions}"
}

compdef _dotnet_zsh_complete dotnet

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# shell command highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# thefuck
eval $(thefuck --alias)

# fun & memes
alias redpill="cmatrix"
