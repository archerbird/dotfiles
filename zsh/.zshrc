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
alias ls="EZA_GRID_ROWS=10 eza --color=always --grid --long --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first"
alias la="ls -a"
alias ll="EZA_GRID_ROWS=10 eza --grid --long --no-user --icons=always -a --group-directories-first"
alias lf="la --only-files"
alias ld="la --only-dirs"
alias lt="eza --tree --level=2 --icons --git --group-directories-first"

#alias cd="z"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
eval "$(zoxide init --cmd cd zsh)"

# use zoxide for cd (disable option is for claude code)
if [[ "$CLAUDECODE" != "1" ]]; then
fi

# show an ls after each cd (but not in claude code)
if [[ "$CLAUDECODE" != "1" ]]; then
  function chpwd() {
      emulate -L zsh
      ls -a
  }
fi

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
alias lgit="lazygit"
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
export DOTNET_SYSTEM_NET_SECURITY_USENETWORKFRAMEWORK=1
alias dnr="dotnet restore --no-cache"
alias dnb="dotnet build"
alias dnc="dotnet clean"
alias dnx="dotnet run"
alias dnf="dnc; dnr; dnb"

# dotfiles shortcuts
alias ezsh="nvim ~/.zshrc"
alias etmux="nvim ~/.config/tmux/tmux.conf"


# foxen local dev shortcuts
alias up-resapi='dotnet run --launch-profile "local_be" --project ~/code/fx-res-external/src/server/api/Foxen.Api.Server/Foxen.Api.Server.csproj'
alias up-v2api='dotnet run --launch-profile "CLI_DEV" --project ~/code/fx-v2/Foxen.Internal/Foxen.Internal.csproj'

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

# colima
colima-reset() {
  colima stop -f 2>/dev/null
  colima delete -f 2>/dev/null
  pkill -f 'limactl|colima' 2>/dev/null
  rm -rf ~/.colima/_lima/_networks/
  # Azure VPN breaks lima's usernet DHCP; disconnect during startup
  local vpn_was_connected=false
  if scutil --nc status "$FOXVPN_SVC" 2>/dev/null | grep -q Connected; then
    vpn_was_connected=true
    echo "Disconnecting $FOXVPN_SVC (breaks usernet DHCP)..."
    _vpn_auto_suspend "$FOXVPN_SVC"
    scutil --nc stop "$FOXVPN_SVC"
    local waited=0
    while [ $waited -lt 30 ]; do
      scutil --nc list | grep -F "\"$FOXVPN_SVC\"" | grep -q "(Disconnected)" && break
      sleep 1
      waited=$((waited + 1))
    done
  fi
  colima start --vm-type vz --memory 4 --cpu 2
  if $vpn_was_connected; then
    echo "Reconnecting $FOXVPN_SVC..."
    scutil --nc start "$FOXVPN_SVC"
    _vpn_auto_restore "$FOXVPN_SVC"
  fi
  return 0
}

# VPN
# put the name of your vpn here
export FOXVPN_SVC="Foxen Azure VPN"
FOXVPN_LOG="$HOME/Library/Group Containers/UBF8T346G9.group.com.microsoft.AzureVpnMac.shared/LogFiles/AzureVpnClient.log"
FOXVPN_COOKIES="$HOME/Library/Containers/com.microsoft.AzureVpnMac/Data/Library/Cookies/Cookies.binarycookies"
# The "Connect automatically" checkbox is a private app preference, not a macOS
# on-demand rule (profiles report OnDemandEnabled : FALSE), so scutil has no
# setter for it. The main app process reads this key at disconnect time and
# redials; the tunnel extension does not.
FOXVPN_PREFS="$HOME/Library/Group Containers/UBF8T346G9.group.com.microsoft.AzureVpnMac.shared/Library/Preferences/UBF8T346G9.group.com.microsoft.AzureVpnMac.shared"
FOXVPN_STATE="$HOME/.cache/foxvpn"

_vpn_marker() { printf '%s/alwayson-%s' "$FOXVPN_STATE" "${1// /_}" }

# Echo a profile's "Connect automatically" setting as true|false|unknown.
_vpn_auto_get() {
  local val
  val=$(defaults read "$FOXVPN_PREFS" "AlwaysOnEnabled_$1" 2>/dev/null) || { echo unknown; return }
  case "$val" in
    1) echo true ;;
    0) echo false ;;
    *) echo unknown ;;
  esac
}

# Set a profile's "Connect automatically" setting. Usage: _vpn_auto_set <svc> true|false
_vpn_auto_set() {
  defaults write "$FOXVPN_PREFS" "AlwaysOnEnabled_$1" -bool "$2" 2>/dev/null
  [[ $(_vpn_auto_get "$1") == "$2" ]]
}

# Turn "Connect automatically" off ahead of a scripted disconnect, leaving a
# marker so _vpn_auto_restore knows to switch it back on.
_vpn_auto_suspend() {
  local svc=$1 marker
  marker=$(_vpn_marker "$svc")
  case "$(_vpn_auto_get "$svc")" in
    true)
      mkdir -p "$FOXVPN_STATE"
      : > "$marker"
      if _vpn_auto_set "$svc" false; then
        echo "Paused 'Connect automatically'."
      else
        rm -f "$marker"
        echo "Warning: could not pause 'Connect automatically'; '$svc' may reconnect itself."
      fi
      ;;
    unknown)
      echo "Warning: 'Connect automatically' state unreadable for '$svc'."
      echo "  The Azure VPN Client may have renamed the AlwaysOnEnabled_* preference."
      ;;
  esac
}

# Switch "Connect automatically" back on if _vpn_auto_suspend turned it off.
_vpn_auto_restore() {
  local svc=$1 marker
  marker=$(_vpn_marker "$svc")
  [ -f "$marker" ] || return 0
  if _vpn_auto_set "$svc" true; then
    rm -f "$marker"
    echo "Restored 'Connect automatically'."
  else
    echo "Warning: could not restore 'Connect automatically' for '$svc'."
  fi
}

# Map NEVPNConnectionError LastCause codes to human-readable messages.
_vpn_last_cause() {
  local svc=$1
  local cause
  cause=$(scutil --nc status "$svc" 2>/dev/null | grep "LastCause" | awk '{print $NF}')
  case "$cause" in
    1)  echo "system slept too long" ;;
    2)  echo "no network available" ;;
    3)  echo "unrecoverable network change" ;;
    4)  echo "configuration failed" ;;
    5)  echo "server address resolution failed" ;;
    6)  echo "server not responding" ;;
    7)  echo "server died" ;;
    8)  echo "authentication failed" ;;
    9)  echo "client certificate invalid" ;;
    12) echo "plugin failed" ;;
    *)  echo "unknown (code $cause)" ;;
  esac
}

# Poll scutil until VPN connects, a log error appears, or timeout.
# Usage: _vpn_wait <timeout> <svc> <log_offset> <fail_hint>
_vpn_wait() {
  local timeout=$1 svc=$2 log_offset=$3 fail_hint=$4
  local elapsed=0 new_lines status_line seen_connecting=0
  while [ "$elapsed" -lt "$timeout" ]; do
    sleep 1
    elapsed=$((elapsed + 1))
    status_line=$(scutil --nc list | grep "\"$svc\"")
    if [[ $status_line == *"(Connected)"* ]]; then
      echo "VPN connected successfully (${elapsed}s)."
      return 0
    fi
    if [[ $status_line == *"(Connecting)"* || $status_line == *"(Reasserting)"* ]]; then
      seen_connecting=1
    fi
    if [[ $seen_connecting -eq 1 && $status_line == *"(Disconnected)"* ]]; then
      local reason
      reason=$(_vpn_last_cause "$svc")
      echo "VPN connection failed (${elapsed}s): $reason."
      if [[ $reason == *"authentication"* || $reason == *"certificate"* ]]; then
        echo "Run: vpn reauth"
      else
        echo "$fail_hint"
      fi
      return 1
    fi
    if [ -f "$FOXVPN_LOG" ]; then
      new_lines=$(tail -n +$((log_offset + 1)) "$FOXVPN_LOG")
      if echo "$new_lines" | grep -qi "failed\|unexpected error"; then
        echo "VPN connection failed (${elapsed}s)."
        echo ""
        echo "Log:"
        echo "$new_lines" | grep -i "failed\|unexpected error"
        echo ""
        echo "$fail_hint"
        return 1
      fi
    fi
  done
  return 2
}

vpn() {
  local svc="${FOXVPN_SVC:-}"
  if [ -z "$svc" ]; then
    echo "FOXVPN_SVC is not set. Add to your .zshrc:"
    echo "  export FOXVPN_SVC=\"<your VPN name>\""
    echo ""
    echo "Available VPN services:"
    scutil --nc list | sed -n 's/^[^"]*"\([^"]*\)".*/  \1/p'
    return 1
  fi
  local status_line
  status_line=$(scutil --nc list | grep "\"$svc\"")
  case "$1" in
    up)
      if [[ $status_line == *"(Connected)"* ]]; then
        echo "VPN '$svc' is already connected."
        _vpn_auto_restore "$svc"
        return 0
      fi
      local log_offset=0
      if [ -f "$FOXVPN_LOG" ]; then
        log_offset=$(( $(wc -l < "$FOXVPN_LOG") ))
      fi
      if [[ $status_line == *"(Connecting)"* || $status_line == *"(Reasserting)"* ]]; then
        echo "VPN '$svc' is already connecting, waiting..."
      else
        echo "Connecting to '$svc'..."
        scutil --nc start "$svc" 2>/dev/null
      fi
      _vpn_wait 30 "$svc" "$log_offset" "Likely needs re-authentication. Run: vpn reauth"
      local rc=$?
      [ $rc -eq 0 ] && _vpn_auto_restore "$svc"
      if [ $rc -eq 2 ]; then
        echo ""
        echo "Timed out after 30s."
        if [ -f "$FOXVPN_LOG" ]; then
          echo ""
          echo "Last log entries:"
          tail -5 "$FOXVPN_LOG"
        fi
        echo ""
        echo "If auth expired, run: vpn reauth"
        return 1
      fi
      return $rc
      ;;
    down)
      _vpn_auto_suspend "$svc"
      if [[ $status_line == *"(Disconnected)"* ]]; then
        echo "VPN '$svc' is not connected."
        return 0
      fi
      if [[ $status_line == *"(Disconnecting)"* ]]; then
        echo "VPN '$svc' is already disconnecting, waiting..."
      else
        echo "Disconnecting '$svc'..."
        scutil --nc stop "$svc" 2>/dev/null
      fi
      local timeout=30 elapsed=0
      while [ "$elapsed" -lt "$timeout" ]; do
        sleep 1
        elapsed=$((elapsed + 1))
        if scutil --nc list | grep "\"$svc\"" | grep -q "(Disconnected)"; then
          echo "VPN disconnected (${elapsed}s)."
          return 0
        fi
      done
      echo "Disconnect timed out after ${timeout}s (may still be disconnecting)."
      return 1
      ;;
    ls)
      if [ -z "$status_line" ]; then
        echo "VPN service '$svc' not found."
        return 1
      fi
      local state
      state=$(echo "$status_line" | sed -n 's/^[^(]*(\([^)]*\)).*/\1/p')
      echo "VPN '$svc': $state"
      echo "Connect automatically: $(_vpn_auto_get "$svc")"
      [ -f "$(_vpn_marker "$svc")" ] && echo "  (paused by 'vpn down'; 'vpn up' will restore it)"
      ;;
    auto)
      case "$2" in
        on|off)
          local want=false
          [[ $2 == on ]] && want=true
          if _vpn_auto_set "$svc" "$want"; then
            rm -f "$(_vpn_marker "$svc")"
            echo "Connect automatically: $want"
          else
            echo "Failed to set 'Connect automatically' for '$svc'."
            return 1
          fi
          ;;
        "")
          echo "Connect automatically: $(_vpn_auto_get "$svc")"
          ;;
        *)
          echo "Usage: vpn auto [on|off]"
          return 1
          ;;
      esac
      ;;
    reauth)
      _vpn_auto_suspend "$svc"
     # Stop any active/pending connection
      if [[ $status_line != *"(Disconnected)"* && $status_line != *"(Invalid)"* ]]; then
        echo "Disconnecting VPN..."
        scutil --nc stop "$svc" 2>/dev/null

        # Wait until fully disconnected (or timeout)
        local timeout=30 elapsed=0
        while [ "$elapsed" -lt "$timeout" ]; do
          sleep 1
          elapsed=$((elapsed + 1))

          status_line=$(scutil --nc list | grep -F "\"$svc\"")

          if [[ $status_line == *"(Disconnected)"* || $status_line == *"(Invalid)"* ]]; then
            echo "VPN fully disconnected (${elapsed}s)."
            break
          fi
        done

        if [[ $status_line != *"(Disconnected)"* && $status_line != *"(Invalid)"* ]]; then
          echo "Warning: disconnect timed out after ${timeout}s."
        fi
      fi
      # Clear app caches and cookies (MSAL tokens live in a sandboxed
      # keychain inaccessible from Terminal; clearing these files plus
      # the app restart below is what actually forces fresh OAuth)
      echo "Clearing auth state..."
      local container="$HOME/Library/Containers/com.microsoft.AzureVpnMac/Data/Library"
      rm -f "$FOXVPN_COOKIES"
      rm -rf "$container/Caches" "$container/HTTPStorages" "$container/WebKit/WebsiteData" 2>/dev/null
      echo "  Done."

      # Restart the app
      echo "Restarting Azure VPN Client..."
      killall "Azure VPN Client" 2>/dev/null
      sleep 1
      open -a "Azure VPN Client"
      for i in {1..15}; do
        pgrep -f "Azure VPN Client" >/dev/null && break
        sleep 1
      done
      sleep 2

      # Start connection (triggers OAuth browser flow)
      local log_offset=0
      if [ -f "$FOXVPN_LOG" ]; then
        log_offset=$(( $(wc -l < "$FOXVPN_LOG") ))
      fi
      echo "Starting VPN (authenticate in the browser window)..."
      scutil --nc start "$svc" 2>/dev/null


      _vpn_wait 60 "$svc" "$log_offset" "Re-authentication failed."
      local rc=$?
      if [ $rc -eq 0 ]; then
        _vpn_auto_restore "$svc"
        osascript -e 'tell application "Azure VPN Client" to quit'
        return 0
      fi
      if [ $rc -eq 2 ]; then
        echo "Timed out after 60s. Browser auth may still be pending."
        echo "Complete authentication, then run 'vpn up' to verify."
        return 1
      fi
      return $rc
      ;;
    *)
      echo "Usage: vpn {up|down|ls|auto [on|off]|reauth}"
      return 1
      ;;
  esac
}

compdef _dotnet_zsh_complete dotnet

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# shell command highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# thefuck
eval $(thefuck --alias)

# fun & memes
alias redpill="cmatrix"

# so claude code doesn't run into issues
export PATH="$HOME/.local/bin:$PATH"
