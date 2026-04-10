#!/usr/bin/env bash

export PATH="$HOME/.local/vim-min/bin:$PATH"
export NEWT_COLORS='root=black,black;window=black,black;border=white,black;listbox=white,black;label=blue,black;checkbox=green,black;title=green,black;button=white,green;entry=lightgray,black;textbox=blue,black'

alias ..='cd ..'
alias dev='cd ~/dev'
alias cdo='cd /usr/lib/odin'
alias pix='nohup /home/solver/dev/tools/Pixelorama-Linux-64bit/Pixelorama.x86_64 >/dev/null 2>&1&'
alias y='yazi'
alias o='odin run .'
alias l='ls -ltrahF'
alias n='nvim'
alias v='vim'
alias s='~/status.sh'
alias g='grep --color=auto'
alias m='mpv'
alias lx='lynx --display_charset=utf-8 --assume_charset=utf-8'
alias gd='git diff'
alias gs='git status'
alias lg='lazygit'
alias bt='bluetui'
alias bat='cat /sys/class/power_supply/BAT1/capacity'

alias that='xrandr --output eDP --off --output HDMI-A-0 --auto'
alias this='xrandr --output HDMI-A-0 --off --output eDP --auto'

export EDITOR=vim
export VISUAL=vim

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
    echo -n " ⮐ $branch$flags"
}

PROMPT_COMMAND='PS1="${PWD/#$HOME/\~}$(__prompt_git)\n\$ "'


b1() { sudo systemctl start bluetooth.service; }
b0() { sudo systemctl stop bluetooth.service; }
w1() { nmcli radio wifi on; }
w0() { nmcli radio wifi off; }

# van is like man but in vim
van() { man "$@" 2>/dev/null | col -b | vim -; }

# history (cheap)
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

[ -f /usr/share/bash-completion/bash_completion ] && \
    source /usr/share/bash-completion/bash_completion

eval "$(mcfly init bash)"
eval "$(thefuck --alias)"
# eval "$(zoxide init bash)"
z() {
    unset -f z
    eval "$(zoxide init bash)"
    z "$@"
}
export "EDITOR=nvim"
