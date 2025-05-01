#!/bin/sh

cmd="$1"
path="$2"

# Replace $HOME with ~
short_path="${path/#$HOME/~}"

# Shorten long paths to last 3 segments
shorten_path() {
  IFS='/' read -r -a parts <<< "${1/#\//}"
  count=${#parts[@]}
  if [ "$count" -le 4 ]; then
    echo "$1"
  else
    echo "…/${parts[$((count-3))]}/${parts[$((count-2))]}/${parts[$((count-1))]}"
  fi
}

case "$cmd" in
  zsh|bash|fish)
    shorten_path "$short_path"
    ;;
  nvim)
    # Show "nvim: project" (top-level folder name)
    IFS='/' read -r -a parts <<< "${short_path/#\//}"
    echo "nvim: ${parts[0]}"
    ;;
  *)
    echo "$cmd"
    ;;
esac
