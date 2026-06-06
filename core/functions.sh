### ================================
### CORE FUNCTIONS
### ================================

### --------------------------------
### Path Front (highest priority)
### --------------------------------
path_front() {
	if [ -d "${1}" ] && [[ ":${PATH}:" != *":${1}:"* ]]; then
		export PATH="${1}:${PATH}"
	fi
}

### --------------------------------
### Path Back (lowest priority)
### --------------------------------
path_back() {
	if [ -d "${1}" ] && [[ ":${PATH}:" != *":${1}:"* ]]; then
		export PATH="${PATH}:${1}"
	fi
}

### --------------------------------
### Path Dedup
### --------------------------------
path_dedup() {
	export PATH=$(printf "%s" "${PATH}" | awk -v RS=: -v ORS=: '!a[$(0)]++' | sed 's/:$//')
}

### ================================
### MANUAL FUNCTIONS
### ================================

### --------------------------------
### Windows Manual
### --------------------------------
win-man() {
	start "https://learn.microsoft.com/en-us/search/?terms=${1}"
}

### --------------------------------
### Unix Manual
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
