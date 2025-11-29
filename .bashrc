#!/usr/bin/env bash

alias ..='cd ..'
alias cdn='cd ~/.config/nvim'
alias dev='cd ~/dev'
alias cdo='cd /usr/lib/odin'
alias pix='nohup /home/solver/dev/tools/Pixelorama-Linux-64bit/Pixelorama.x86_64 >/dev/null 2>&1&'
alias y='yazi'
alias o='odin run .'
alias l='lsd -ltrah'
alias n='nvim'
alias v='vim'
alias g='grep --color=auto'
alias gd='git diff'
alias gs='git status'
alias lg='lazygit'

eval "$(starship init bash)"
eval "$(mcfly init bash)"
eval "$(thefuck --alias)"
eval "$(zoxide init bash)"
export "EDITOR=nvim"
