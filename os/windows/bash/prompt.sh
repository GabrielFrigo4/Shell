### ================================
### SHELL ENVIRONMENT
### ================================

command_not_found_handle() {
	local cmd="${1}"
	shift
	for ext in .bat .cmd .exe; do
		if command -v "${cmd}${ext}" &> "/dev/null"; then
			"${cmd}${ext}" "$@"
			return $?
		fi
	done
	echo "bash: ${cmd}: command not found" > &2
	return 127
}

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
path_back "$(cygpath -u "$LOCALAPPDATA")/Coursier/data/bin"
export PATH=$(printf "%s" "${PATH}" | awk -v RS=: -v ORS=: '!a[$(0)]++' | sed 's/:$//')

export C_INCLUDE_PATH="$(cygpath -m /usr/local/include)"
export CPLUS_INCLUDE_PATH="$(cygpath -m /usr/local/include)"
export LIBRARY_PATH="$(cygpath -m /usr/local/lib)"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"

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

	local sys_info="MSYS2-$MSYSTEM"
	local sh_name="${0##*/}"
	sh_name="${sh_name#-}"
	sh_name="${sh_name%.exe}"

	local usr_color
	if [ "$(id -u)" -eq 0 ]; then
		usr_color="${C_BRT_RED}"
	else
		usr_color="${C_BRT_GREEN}"
	fi

	PS1="\n${C_NORM_YELLOW}${C_BRT_BLUE} ${C_BRT_MAGENTA}${sys_info}${C_NORM_YELLOW}─${C_BRT_BLUE} ${C_BRT_MAGENTA}${sh_name}${C_NORM_YELLOW}"
	PS1+="\n${C_NORM_YELLOW}┌──❮ ${C_BRT_GREEN} \t${C_NORM_YELLOW} ❯─❮ ${C_BRT_GREEN} \D{%d/%m/%y}${C_NORM_YELLOW} ❯─❮ ${C_BRT_YELLOW} ${C_BRT_CYAN}\W${C_NORM_YELLOW} ❯─ ❮${C_BRT_BLUE} ${usr_color}\u${C_NORM_YELLOW}❯ $(git_branch)"
	PS1+="\n${C_NORM_YELLOW}└─${C_BRT_BLUE}${C_RESET} "
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
alias brw="lynx -use_mouse=on -nobrowse=on -nopause=on -show_cursor=off"
### --------------------------------
### Manual
### --------------------------------
alias wman="win-man"
alias uman="unix-man"
alias mandoc="unix-man"
### --------------------------------
### Management
### --------------------------------
alias upsys="pacman --noconfirm -Syu"
alias upall="upsys"
alias pac="pacman"
alias pacs="pacman -Ss"
alias paci="pacman -S"
alias pacr="pacman -Rcns"
alias pacu="pacman -Syu"
### --------------------------------
### Emacs
### --------------------------------
alias ek="pkill emacs"
alias es="runemacs --fg-daemon"
alias er="ek && es"
alias ec="emacsclientw --create-frame --alternate-editor \"\""
alias oe="emacsclientw --create-frame --alternate-editor \"\" ."
### --------------------------------
### Code Editors
### --------------------------------
alias on="nvim ."
alias ov="vim ."

### ================================
### SHELL CONFIGURATION
### ================================
