#!/usr/bin/env bash

alias ..='cd ..'
alias cdn='cd ~/.config/nvim'
alias dev='cd ~/dev'
alias cdo='cd /usr/lib/odin'
alias pix='nohup /home/solver/dev/tools/Pixelorama-Linux-64bit/Pixelorama.x86_64 >/dev/null 2>&1&'
alias y='yazi'
alias o='odin run .'
alias l='ls -ltrahF'
alias n='nvim'
alias v='vim'
alias g='grep --color=auto'
alias gd='git diff'
alias gs='git status'
alias lg='lazygit'

alias that='xrandr --output eDP --off --output HDMI-A-0 --auto'
alias this='xrandr --output HDMI-A-0 --off --output eDP --auto'

__prompt_git() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    local branch flags status
    status=$(git status --porcelain=v1 -b 2>/dev/null)
    branch=$(sed -n 's/^## \([^.]*\).*/\1/p' <<< "$status")
    [[ $status =~ "ahead" ]]  && flags+=" [⇡]"
    [[ $status =~ "behind" ]] && flags+=" [⇣]"
    grep -qm1 "^[MARC]"  <<< "$status" && flags+=" [+]"
    grep -qm1 "^.[MD]"   <<< "$status" && flags+=" [!]"
    grep -qm1 "^[D ]D"   <<< "$status" && flags+=" [x]"
    grep -qm1 "^??"      <<< "$status" && flags+=" [?]"
    grep -qm1 "^[UA][UA]\|^AA\|^DD" <<< "$status" && flags+=" [=]"
    echo -n "  $branch$flags"
}
PROMPT_COMMAND='PS1="${PWD/#$HOME/\~}$(__prompt_git)\n\$ "'

eval "$(mcfly init bash)"
eval "$(thefuck --alias)"
eval "$(zoxide init bash)"
export "EDITOR=nvim"
