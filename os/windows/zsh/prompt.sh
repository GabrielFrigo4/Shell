### ================================
### SHELL OPTIONS SETUP
### ================================

### --------------------------------
### Expansion
### --------------------------------
setopt PROMPT_SUBST

### --------------------------------
### Globbing
### --------------------------------
setopt EXTENDED_GLOB
setopt GLOB_DOTS

### --------------------------------
### History
### --------------------------------
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_VERIFY

### --------------------------------
### Interaction
### --------------------------------
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt RM_STAR_WAIT
setopt NO_CLOBBER
unsetopt BEEP

### --------------------------------
### Navigation
### --------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt COMPLETE_IN_WORD

### ================================
### SHELL ENVIRONMENT
### ================================

command_not_found_handler() {
	local cmd="${1}"
	shift
	for ext in .bat .cmd .exe; do
		if (( $+commands[${cmd}${ext}] )); then
			"${cmd}${ext}" "$@"
			return $?
		fi
	done
	echo "zsh: ${cmd}: command not found" > &2
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

() {
	zstyle ':prompt:colors' reset     '%f%b'

	zstyle ':prompt:colors' n_black   '%b%F{0}'
	zstyle ':prompt:colors' n_red     '%b%F{1}'
	zstyle ':prompt:colors' n_green   '%b%F{2}'
	zstyle ':prompt:colors' n_yellow  '%b%F{3}'
	zstyle ':prompt:colors' n_blue    '%b%F{4}'
	zstyle ':prompt:colors' n_magenta '%b%F{5}'
	zstyle ':prompt:colors' n_cyan    '%b%F{6}'
	zstyle ':prompt:colors' n_white   '%b%F{7}'

	zstyle ':prompt:colors' b_gray    '%B%F{8}'
	zstyle ':prompt:colors' b_red     '%B%F{9}'
	zstyle ':prompt:colors' b_green   '%B%F{10}'
	zstyle ':prompt:colors' b_yellow  '%B%F{11}'
	zstyle ':prompt:colors' b_blue    '%B%F{12}'
	zstyle ':prompt:colors' b_magenta '%B%F{13}'
	zstyle ':prompt:colors' b_cyan    '%B%F{14}'
	zstyle ':prompt:colors' b_white   '%B%F{15}'

	git_branch() {
		if git rev-parse --is-inside-work-tree &> "/dev/null"; then
			local branch="$(git branch --show-current 2> "/dev/null" || git rev-parse --short HEAD 2> "/dev/null")"
			if [[ -n "$branch" ]]; then
				local y Y R M
				zstyle -s ':prompt:colors' n_yellow y
				zstyle -s ':prompt:colors' b_yellow Y
				zstyle -s ':prompt:colors' b_red R
				zstyle -s ':prompt:colors' b_magenta M
				local indicator=""
				[[ -n "$(git status --short -uno 2> "/dev/null" | tail -n1)" ]] && indicator="${Y}*"
				echo "❮${R}󰊢 ${M}${branch}${indicator}${y}❯"
			fi
		fi
	}

	local z
	zstyle -s ':prompt:colors' reset z

	local k K r R g G y Y b B m M c C w W
	zstyle -s ':prompt:colors' n_black   k; zstyle -s ':prompt:colors' b_gray    K
	zstyle -s ':prompt:colors' n_red     r; zstyle -s ':prompt:colors' b_red     R
	zstyle -s ':prompt:colors' n_green   g; zstyle -s ':prompt:colors' b_green   G
	zstyle -s ':prompt:colors' n_yellow  y; zstyle -s ':prompt:colors' b_yellow  Y
	zstyle -s ':prompt:colors' n_blue    b; zstyle -s ':prompt:colors' b_blue    B
	zstyle -s ':prompt:colors' n_magenta m; zstyle -s ':prompt:colors' b_magenta M
	zstyle -s ':prompt:colors' n_cyan    c; zstyle -s ':prompt:colors' b_cyan    C
	zstyle -s ':prompt:colors' n_white   w; zstyle -s ':prompt:colors' b_white   W

	local u
	if [ "$(id -u)" -eq 0 ]; then
		zstyle -s ':prompt:colors' b_red u
	else
		zstyle -s ':prompt:colors' b_green u
	fi

	local sys_info="MSYS2-$MSYSTEM"
	local sh_name="$ZSH_NAME"

	export PROMPT="
${y}${B} ${M}${sys_info}${y}─${B} ${M}${sh_name}${y}
${y}┌──❮ ${G} %*${y} ❯─❮ ${G} %D{%d/%m/%y}${y} ❯─❮ ${Y} ${C}%c${y} ❯─ ❮${B} ${u}%n${y}❯ \$(git_branch)
${y}└─${B}${z} "
}

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
