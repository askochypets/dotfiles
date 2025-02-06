#!/bin/bash
tmux list-windows -a -F '#S:#I:#W:#{pane_current_path}' >~/dotfiles/tmux/.tmux-sessions
echo "Tmux session saved!"
