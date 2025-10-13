#
# ~/.bashrc
#

alias ..='cd ..'
alias cdn='cd ~/.config/nvim'
alias dev='cd ~/dev'
alias cdo='cd /usr/lib/odin'
alias pix='nohup /home/solver/dev/tools/Pixelorama-Linux-64bit/Pixelorama.x86_64 >/dev/null 2>&1&'
alias y='yazi'
alias o='odin run .'
alias l='lsd -ltrah'
alias n='nvim'
alias g='grep --color=auto'
alias gd='git diff'
alias gs='git status'

# Start tmux automatically if not already inside tmux
if command -v tmux &> /dev/null; then
  # only attach if not already in tmux
  if [ -z "$TMUX" ]; then
    # attach to existing session named "main", or create it
    tmux attach-session -t main || tmux new-session -s main
  fi
fi

eval "$(starship init bash)"
eval "$(mcfly init bash)"
eval "$(thefuck --alias)"
eval "$(zoxide init bash)"
export "EDITOR=nvim"

