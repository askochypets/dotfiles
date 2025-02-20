# System
alias c='clear'
alias e='exit'

# Neovim
alias vi='nvim'
alias v='nvim'

# Ranger
alias r=". ranger"

# Better ls
alias ls="eza --all --icons=always"
alias la="eza --all --icons=always --all --long"

# Lazygit
alias lg="lazygit"

# Git
git config --global alias.f "fetch --prune" 
git config --global alias.r "!git f && git checkout \"$1\" && git reset --hard origin/\"$1\" #"
git config --global alias.m "!git f && git r main"
git config --global alias.bc "!git m && git branch | grep -v \"main\" | xargs git branch -D"
git config --global alias.b "!git branch --show-current | tr -d \"\n\" | pbcopy"
git config --global alias.cp "!git cherry-pick $(git merge-base \"$0\" \"$2\")..\"$2\" #"
git config --global alias.acmn "!git add . && git commit --no-verify -m"
git config --global alias.p "!git push origin $(git branch --show-current | tr -d \"\n\"):\"$1\" #"
