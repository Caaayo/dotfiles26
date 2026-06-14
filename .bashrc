#
# ~/.bashrc
#

# If not running interactively, don't do anything
clear && fastfetch
[[ $- != *i* ]] && return

export EDITOR="nvim"

alias ls='ls -la --color=auto'
alias ll='ls -la --color=auto'
alias sbash='source ~/.bashrc'
alias rbash='nvim ~/.bashrc'
#alias searchin='pacman -Qe'
alias searchin='yay -Qe'
#alias install='yay -S $0'
alias install='sudo pacman -S'
alias search='sudo pacman -Ss'
alias grep='grep --color=auto'

alias venv='source .venv/bin/activate'
alias leavevenv='deactivate'
alias venvpack='pip install -r requirements.txt'
alias venvupgrade='pip install --upgrade -r requirements.txt'
alias createvenv='python3 -m venv .venv && ./.venv/bin/pip install --upgrade pip'

PS1='[\u@\h \W]\$ '
