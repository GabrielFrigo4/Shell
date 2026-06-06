### ================================
### SHELL ENVIRONMENT
### ================================

path_front() {
	if [ -d "${1}" ] && [[ ":${PATH}:" != *":${1}:"* ]]; then
		export PATH="${1}:${PATH}"
	fi
}

path_back() {
	if [ -d "${1}" ] && [[ ":${PATH}:" != *":${1}:"* ]]; then
		export PATH="${PATH}:${1}"
	fi
}

path_front "${HOME}/.local/bin"
path_back  "${HOME}/.cargo/bin"
path_back  "${HOME}/.platformio/penv/bin"
export PATH=$(printf "%s" "${PATH}" | awk -v RS=: -v ORS=: '!a[$(0)]++' | sed 's/:$//')

export EMACS_SOCKET_NAME="${HOME}/.emacs.d/var/server/auth/server"
export MICRO_TRUECOLOR=1

### ================================
### SHELL APPEARANCE
### ================================

git_branch() {
	if git rev-parse --is-inside-work-tree &> "/dev/null"; then
		local branch="$(git branch --show-current 2> "/dev/null" || git rev-parse --short HEAD 2> "/dev/null")"
		if [ -n "$branch" ]; then
			local is_dirty="$(git status --short -uno 2> "/dev/null" | tail -n1)"
			local indicator=""
			[ -n "$is_dirty" ] && indicator="${C_BRT_YELLOW}*"
			echo "❮${C_BRT_RED}󰊢 ${C_BRT_MAGENTA}${branch}${indicator}${C_NORM_YELLOW}❯"
		fi
	fi
}

update_prompt() {
	local C_RESET="\[\e[0m\]"

	local C_NORM_BLACK="\[\e[0;30m\]"
	local C_NORM_RED="\[\e[0;31m\]"
	local C_NORM_GREEN="\[\e[0;32m\]"
	local C_NORM_YELLOW="\[\e[0;33m\]"
	local C_NORM_BLUE="\[\e[0;34m\]"
	local C_NORM_MAGENTA="\[\e[0;35m\]"
	local C_NORM_CYAN="\[\e[0;36m\]"
	local C_NORM_WHITE="\[\e[0;37m\]"

	local C_BRT_GRAY="\[\e[1;90m\]"
	local C_BRT_RED="\[\e[1;91m\]"
	local C_BRT_GREEN="\[\e[1;92m\]"
	local C_BRT_YELLOW="\[\e[1;93m\]"
	local C_BRT_BLUE="\[\e[1;94m\]"
	local C_BRT_MAGENTA="\[\e[1;95m\]"
	local C_BRT_CYAN="\[\e[1;96m\]"
	local C_BRT_WHITE="\[\e[1;97m\]"

	local os_version="$(uname -r)"
	local sh_name="${0##*/}"
	sh_name="${sh_name#-}"

	local usr_color
	if [ "$(id -u)" -eq 0 ]; then
		usr_color="${C_BRT_RED}"
	else
		usr_color="${C_BRT_GREEN}"
	fi

	PS1="\n${C_NORM_YELLOW}${C_BRT_BLUE} ${C_BRT_MAGENTA}${os_version}${C_NORM_YELLOW}─${C_BRT_BLUE} ${C_BRT_MAGENTA}${sh_name}${C_NORM_YELLOW}"
	PS1+="\n${C_NORM_YELLOW}┌──❮ ${C_BRT_GREEN} \t${C_NORM_YELLOW} ❯─❮ ${C_BRT_GREEN} \D{%d/%m/%y}${C_NORM_YELLOW} ❯─❮ ${C_BRT_YELLOW} ${C_BRT_CYAN}\W${C_NORM_YELLOW} ❯─ ❮${C_BRT_BLUE} ${usr_color}\u${C_NORM_YELLOW}❯ $(git_branch)"
	PS1+="\n${C_NORM_YELLOW}└─${C_BRT_BLUE}${C_RESET} "
}

PROMPT_COMMAND=update_prompt

### ================================
### WINDOWS FUNCTIONS
### ================================

### --------------------------------
### Manual
### --------------------------------
win-man() {
	start "https://learn.microsoft.com/en-us/search/?terms=${1}"
}

### ================================
### UNIX FUNCTIONS
### ================================

### --------------------------------
### Manual
### --------------------------------
unix-man() {
	section="${1}"
	command="${2}"
	number="$section"

	if [[ ! "$section" =~ [0-9]$ ]]; then
		number="${section%?}"
	fi

	w3m "https://www.man7.org/linux/man-pages/man$number/$command.$section.html"
}

### ================================
### SHELL ALIAS
### ================================

### --------------------------------
### Software
### --------------------------------
alias wh="which"
alias show="dolphin ."
alias ds="disown"
alias brw="lynx -use_mouse=on -nobrowse=on -nopause=on -show_cursor=off"
alias mmdc="mmdc -p ~/.mermaid-puppeteer-config.json -c ~/.mermaid-theme-config.json -b \"#191919\" -s 4"
### --------------------------------
### Manual
### --------------------------------
alias wman="win-man"
alias uman="unix-man"
alias mandoc="unix-man"
### --------------------------------
### Management
### --------------------------------
alias upyay="yay --noconfirm -Syu"
alias upflat="flatpak update -y"
alias upsh="omz update"
alias upall="upsh && upyay && upflat"
alias backusb="./\"#BackupAll\""
alias yays="yay -Ss"
alias yayi="yay -S"
alias yayr="yay -Rcns"
alias yayu="yay -Syu"
alias pac="pacman"
alias pacs="pacman -Ss"
alias paci="pacman -S"
alias pacr="pacman -Rcns"
alias pacu="pacman -Syu"
### --------------------------------
### Goto
### --------------------------------
alias desk="cd ~/'Área de trabalho'"
alias down="cd ~/Downloads"
### --------------------------------
### Emacs
### --------------------------------
alias ek="pkill emacs"
alias es="emacs --daemon"
alias er="ek && es"
alias ec="emacsclient --create-frame --alternate-editor \"\""
alias oe="nohup emacsclient --create-frame --alternate-editor \"\" . &> \"/dev/null\" &"
### --------------------------------
### Code Editors
### --------------------------------
alias ok="nohup kate . &> \"/dev/null\" &"
alias og="nohup geany . &> \"/dev/null\" &"
alias oc="code ."
alias ocm="codium ."
alias oa="antigravity ."
alias oz="zed ."
alias on="nvim ."
alias ov="vim ."
alias ant="antigravity"
### --------------------------------
### Select GPU
### --------------------------------
alias nvc="DRI_PRIME=1"
alias hdc="DRI_PRIME=0"
### --------------------------------
### Select Theme
### --------------------------------
alias dark="GTK_THEME=Adwaita:dark"
alias light="GTK_THEME=Adwaita:light"

### ================================
### SHELL CONFIGURATION
### ================================
