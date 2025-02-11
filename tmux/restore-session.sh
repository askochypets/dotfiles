#!/bin/bash

if [[ ! -f ~/dotfiles/tmux/.tmux-sessions ]]; then
  echo "No saved session found!"
  exit 1
fi

while IFS=: read -r session index name path; do
  if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -c "$path"
  fi
  tmux rename-window -t "$session:$index" "$name"
done <~/dotfiles/tmux/.tmux-sessions

echo "Tmux session restored!"
