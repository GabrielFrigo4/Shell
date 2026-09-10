### ================================
### BASH CONFIGURATION
### ================================

### --------------------------------
### Shell Options & History
### --------------------------------
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000

shopt -s histappend
shopt -s checkwinsize

### --------------------------------
### Interaction & Safety
### --------------------------------
set -o noclobber

### --------------------------------
### Navigation
### --------------------------------
shopt -s autocd 2> "/dev/null" || true
shopt -s cdspell 2> "/dev/null" || true
shopt -s dirspell 2> "/dev/null" || true

### --------------------------------
### System Completions
### --------------------------------
if ! shopt -oq posix; then
	if [ -f "/usr/share/bash-completion/bash_completion" ]; then
		. "/usr/share/bash-completion/bash_completion"
	elif [ -f "/etc/bash_completion" ]; then
		. "/etc/bash_completion"
	fi
fi
