### ================================
### SHELL DETECTION
### ================================

### --------------------------------
### Detect OS
### --------------------------------
_detect_os() {
	[ -n "${_DETECTED_OS:-}" ] && echo "${_DETECTED_OS}" && return 0
	case "$(uname -s)" in
		Linux*)               _DETECTED_OS="linux" ;;
		FreeBSD*)             _DETECTED_OS="freebsd" ;;
		Darwin*)              _DETECTED_OS="macos" ;;
		MINGW*|CYGWIN*|MSYS*) _DETECTED_OS="windows" ;;
		*)                    _DETECTED_OS="unknown" ;;
	esac
	echo "${_DETECTED_OS}"
}

### --------------------------------
### Detect Shell
### --------------------------------
_detect_shell() {
	[ -n "${_DETECTED_SHELL:-}" ] && echo "${_DETECTED_SHELL}" && return 0
	if [ -n "${BASH_VERSION:-}" ]; then
		_DETECTED_SHELL="bash"
		echo "${_DETECTED_SHELL}"
		return 0
	elif [ -n "${ZSH_VERSION:-}" ]; then
		_DETECTED_SHELL="zsh"
		echo "${_DETECTED_SHELL}"
		return 0
	fi

	local _pid="$$"
	local _os="$(_detect_os)"
	local _name

	_name="$(command ps -p "${_pid}" -o comm= 2> "/dev/null" | command sed 's/^-//')"

	if [ -z "${_name}" ]; then
		if [ "${_os}" = "windows" ]; then
			_name="$(command ps 2> "/dev/null" | command awk -v pid="${_pid}" '$1 == pid {print $8}' | command awk -F'/' '{print $NF}' | command sed 's/^-//; s/\.exe$//')"
		else
			_name="$(command ps -o pid,comm 2> "/dev/null" | command awk -v pid="${_pid}" '$1 == pid {print $2}' | command awk -F'/' '{print $NF}' | command sed 's/^-//; s/\.exe$//')"
		fi
	fi

	if [ "${_name}" = "sudo" ] || [ "${_name}" = "doas" ] || [ "${_name}" = "su" ]; then
		local _gpid="$(command ps -p "${_pid}" -o ppid= 2> "/dev/null" | command tr -d ' ')"
		if [ -z "${_gpid}" ]; then
			if [ "${_os}" = "windows" ]; then
				_gpid="$(command ps 2> "/dev/null" | command awk -v pid="${_pid}" '$1 == pid {print $2}')"
			else
				_gpid="$(command ps -o pid,ppid 2> "/dev/null" | command awk -v pid="${_pid}" '$1 == pid {print $2}')"
			fi
		fi
		_name="$(command ps -p "${_gpid}" -o comm= 2> "/dev/null" | command sed 's/^-//')"
		if [ -z "${_name}" ]; then
			if [ "${_os}" = "windows" ]; then
				_name="$(command ps 2> "/dev/null" | command awk -v pid="${_gpid}" '$1 == pid {print $8}' | command awk -F'/' '{print $NF}' | command sed 's/^-//; s/\.exe$//')"
			else
				_name="$(command ps -o pid,comm 2> "/dev/null" | command awk -v pid="${_gpid}" '$1 == pid {print $2}' | command awk -F'/' '{print $NF}' | command sed 's/^-//; s/\.exe$//')"
			fi
		fi
	fi

	[ -z "${_name}" ] && _name="$(command basename "${SHELL}")"

	_DETECTED_SHELL="${_name##*/}"
	echo "${_DETECTED_SHELL}"
}

### --------------------------------
### Detect Distro
### --------------------------------
_detect_distro() {
	[ -n "${_DETECTED_DISTRO:-}" ] && echo "${_DETECTED_DISTRO}" && return 0
	if [ -f "/etc/os-release" ]; then
		local _id="$(. /etc/os-release && echo "${ID}")"
		_DETECTED_DISTRO="${_id:-unknown}"
	elif [ -f "/etc/arch-release" ]; then
		_DETECTED_DISTRO="arch"
	elif [ -f "/etc/debian_version" ]; then
		_DETECTED_DISTRO="debian"
	else
		_DETECTED_DISTRO="unknown"
	fi
	echo "${_DETECTED_DISTRO}"
}

### --------------------------------
### Detect Distro Family
### --------------------------------
_detect_distro_family() {
	[ -n "${_DETECTED_DISTRO_FAMILY:-}" ] && echo "${_DETECTED_DISTRO_FAMILY}" && return 0
	local _id="$(_detect_distro)"
	local _like=""
	[ -f "/etc/os-release" ] && _like="$(. /etc/os-release && echo "${ID_LIKE}")"

	case "${_id}" in
		arch|manjaro|endeavouros)             _DETECTED_DISTRO_FAMILY="arch" ;;
		debian|ubuntu|linuxmint|pop|raspbian) _DETECTED_DISTRO_FAMILY="debian" ;;
		fedora|rhel|centos|rocky|alma)        _DETECTED_DISTRO_FAMILY="fedora" ;;
		opensuse*|sles)                       _DETECTED_DISTRO_FAMILY="suse" ;;
		void)                                 _DETECTED_DISTRO_FAMILY="void" ;;
		alpine)                               _DETECTED_DISTRO_FAMILY="alpine" ;;
		gentoo|funtoo|calculate)              _DETECTED_DISTRO_FAMILY="gentoo" ;;
		nixos)                                _DETECTED_DISTRO_FAMILY="nixos" ;;
		*)
			case "${_like}" in
				*arch*)            _DETECTED_DISTRO_FAMILY="arch" ;;
				*debian*|*ubuntu*) _DETECTED_DISTRO_FAMILY="debian" ;;
				*fedora*|*rhel*)   _DETECTED_DISTRO_FAMILY="fedora" ;;
				*suse*)            _DETECTED_DISTRO_FAMILY="suse" ;;
				*gentoo*)          _DETECTED_DISTRO_FAMILY="gentoo" ;;
				*)                 _DETECTED_DISTRO_FAMILY="unknown" ;;
			esac
			;;
	esac
	echo "${_DETECTED_DISTRO_FAMILY}"
}

### --------------------------------
### Detect Desktop Environment
### --------------------------------
_detect_desktop_environment() {
	[ -n "${_DETECTED_DESKTOP_ENV:-}" ] && echo "${_DETECTED_DESKTOP_ENV}" && return 0
	local _desktop="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION}}"
	case "${_desktop}" in
		*[Kk][Dd][Ee]*|*[Pp]lasma*)                                            _DETECTED_DESKTOP_ENV="kde" ;;
		*[Gg][Nn][Oo][Mm][Ee]*)                                                _DETECTED_DESKTOP_ENV="gnome" ;;
		*[Xx][Ff][Cc][Ee]*)                                                    _DETECTED_DESKTOP_ENV="xfce" ;;
		*[Cc][Ii][Nn][Nn][Aa][Mm][Oo][Nn]*)                                    _DETECTED_DESKTOP_ENV="cinnamon" ;;
		*[Mm][Aa][Tt][Ee]*)                                                    _DETECTED_DESKTOP_ENV="mate" ;;
		*[Cc][Oo][Ss][Mm][Ii][Cc]*)                                            _DETECTED_DESKTOP_ENV="cosmic" ;;
		*[Ll][Xx][Qq][Tt]*)                                                    _DETECTED_DESKTOP_ENV="lxqt" ;;
		*[Ss][Ww][Aa][Yy]*)                                                    _DETECTED_DESKTOP_ENV="sway" ;;
		*[Hh][Yy][Pp][Rr][Ll][Aa][Nn][Dd]*)                                    _DETECTED_DESKTOP_ENV="hyprland" ;;
		*[Ii]3*|*[Bb][Ss][Pp][Ww][Mm]*|*[Rr][Ii][Vv][Ee][Rr]*|*[Dd][Ww][Mm]*) _DETECTED_DESKTOP_ENV="wm" ;;
		*)                                                                     _DETECTED_DESKTOP_ENV="unknown" ;;
	esac
	echo "${_DETECTED_DESKTOP_ENV}"
}

### --------------------------------
### Detect Color Scheme
### --------------------------------
_detect_color_scheme() {
	[ -n "${_DETECTED_COLOR_SCHEME:-}" ] && echo "${_DETECTED_COLOR_SCHEME}" && return 0

	local _cache="${XDG_RUNTIME_DIR:-/tmp}/.shell_color_scheme"
	if [ -f "${_cache}" ]; then
		read -r _DETECTED_COLOR_SCHEME < "${_cache}" 2> "/dev/null"
		if [ -n "${_DETECTED_COLOR_SCHEME:-}" ]; then
			echo "${_DETECTED_COLOR_SCHEME}"
			return 0
		fi
	fi

	_DETECTED_COLOR_SCHEME="dark"
	if command -v gdbus > "/dev/null" 2>&1; then
		local _portal
		_portal="$(gdbus call --session --dest org.freedesktop.portal.Desktop \
			--object-path /org/freedesktop/portal/desktop \
			--method org.freedesktop.portal.Settings.Read \
			"org.freedesktop.appearance" "color-scheme" 2> "/dev/null")"
		case "${_portal}" in
			*uint32\ 1*) _DETECTED_COLOR_SCHEME="dark" ;;
			*uint32\ 2*) _DETECTED_COLOR_SCHEME="light" ;;
		esac
	elif command -v gsettings > "/dev/null" 2>&1; then
		local _gnome_scheme
		_gnome_scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2> "/dev/null")"
		case "${_gnome_scheme}" in
			*prefer-dark*)  _DETECTED_COLOR_SCHEME="dark" ;;
			*prefer-light*) _DETECTED_COLOR_SCHEME="light" ;;
		esac
	elif command -v kreadconfig6 > "/dev/null" 2>&1; then
		local _kde_scheme
		_kde_scheme="$(kreadconfig6 --group General --key ColorScheme 2> "/dev/null")"
		case "${_kde_scheme}" in
			*[Dd]ark*)  _DETECTED_COLOR_SCHEME="dark" ;;
			*[Ll]ight*) _DETECTED_COLOR_SCHEME="light" ;;
		esac
	elif command -v kreadconfig5 > "/dev/null" 2>&1; then
		local _kde_scheme5
		_kde_scheme5="$(kreadconfig5 --group General --key ColorScheme 2> "/dev/null")"
		case "${_kde_scheme5}" in
			*[Dd]ark*)  _DETECTED_COLOR_SCHEME="dark" ;;
			*[Ll]ight*) _DETECTED_COLOR_SCHEME="light" ;;
		esac
	elif [ -f "${HOME}/.config/kdeglobals" ]; then
		if grep -qi "ColorScheme=.*Dark" "${HOME}/.config/kdeglobals" 2> "/dev/null"; then
			_DETECTED_COLOR_SCHEME="dark"
		elif grep -qi "ColorScheme=.*Light" "${HOME}/.config/kdeglobals" 2> "/dev/null"; then
			_DETECTED_COLOR_SCHEME="light"
		fi
	fi

	[ -d "${XDG_RUNTIME_DIR:-/tmp}" ] && echo "${_DETECTED_COLOR_SCHEME}" > "${_cache}" 2> "/dev/null" || true
	echo "${_DETECTED_COLOR_SCHEME}"
}

### --------------------------------
### Detect GTK Theme
### --------------------------------
_detect_gtk_theme() {
	local _desktop_env="$(_detect_desktop_environment)"
	local _color_scheme="$(_detect_color_scheme)"

	case "${_desktop_env}" in
		kde)
			if [ "${_color_scheme}" = "dark" ]; then
				echo "Breeze-Dark"
			else
				echo "Breeze"
			fi
			;;
		gnome)
			echo ""
			;;
		*)
			if [ "${_color_scheme}" = "dark" ]; then
				if [ -d "/usr/share/themes/adw-gtk3-dark" ] || [ -d "${HOME}/.themes/adw-gtk3-dark" ]; then
					echo "adw-gtk3-dark"
				else
					echo "Adwaita:dark"
				fi
			else
				if [ -d "/usr/share/themes/adw-gtk3" ] || [ -d "${HOME}/.themes/adw-gtk3" ]; then
					echo "adw-gtk3"
				else
					echo "Adwaita"
				fi
			fi
			;;
	esac
}

### --------------------------------
### Detect Qt Theme
### --------------------------------
_detect_qt_theme() {
	local _desktop_env="$(_detect_desktop_environment)"
	local _color_scheme="$(_detect_color_scheme)"

	if [ "${_desktop_env}" = "kde" ]; then
		if [ "${_color_scheme}" = "dark" ]; then
			echo "Breeze-Dark"
		else
			echo "Breeze"
		fi
	else
		echo ""
	fi
}

### --------------------------------
### Detect Qt Platform Theme
### --------------------------------
_detect_qt_platform_theme() {
	local _desktop_env="$(_detect_desktop_environment)"

	case "${_desktop_env}" in
		kde)
			echo "xdgdesktopportal"
			;;
		gnome|sway|hyprland)
			if command -v qt6ct > "/dev/null" 2>&1; then
				echo "qt6ct"
			elif command -v qt5ct > "/dev/null" 2>&1; then
				echo "qt5ct"
			else
				echo "xdgdesktopportal"
			fi
			;;
		xfce|mate|cinnamon)
			echo "gtk3"
			;;
		*)
			if command -v qt6ct > "/dev/null" 2>&1; then
				echo "qt6ct"
			elif command -v qt5ct > "/dev/null" 2>&1; then
				echo "qt5ct"
			else
				echo ""
			fi
			;;
	esac
}

### --------------------------------
### Detect Eza/Exa Binary
### --------------------------------
_detect_eza() {
	[ -n "${_DETECTED_EZA:-}" ] && echo "${_DETECTED_EZA}" && return 0
	if command -v eza > "/dev/null" 2>&1; then
		_DETECTED_EZA="eza"
	elif command -v exa > "/dev/null" 2>&1; then
		_DETECTED_EZA="exa"
	elif [ -x "${HOME}/.cargo/bin/eza" ]; then
		_DETECTED_EZA="${HOME}/.cargo/bin/eza"
	elif [ -x "${HOME}/.cargo/bin/exa" ]; then
		_DETECTED_EZA="${HOME}/.cargo/bin/exa"
	else
		_DETECTED_EZA=""
	fi
	echo "${_DETECTED_EZA}"
}

### --------------------------------
### Detect Bat/Batcat Binary
### --------------------------------
_detect_bat() {
	[ -n "${_DETECTED_BAT:-}" ] && echo "${_DETECTED_BAT}" && return 0
	if command -v bat > "/dev/null" 2>&1; then
		_DETECTED_BAT="bat"
	elif command -v batcat > "/dev/null" 2>&1; then
		_DETECTED_BAT="batcat"
	elif [ -x "${HOME}/.cargo/bin/bat" ]; then
		_DETECTED_BAT="${HOME}/.cargo/bin/bat"
	else
		_DETECTED_BAT=""
	fi
	echo "${_DETECTED_BAT}"
}

### --------------------------------
### Detect Ripgrep Binary
### --------------------------------
_detect_rg() {
	[ -n "${_DETECTED_RG:-}" ] && echo "${_DETECTED_RG}" && return 0
	if command -v rg > "/dev/null" 2>&1; then
		_DETECTED_RG="rg"
	elif command -v ripgrep > "/dev/null" 2>&1; then
		_DETECTED_RG="ripgrep"
	elif [ -x "${HOME}/.cargo/bin/rg" ]; then
		_DETECTED_RG="${HOME}/.cargo/bin/rg"
	else
		_DETECTED_RG=""
	fi
	echo "${_DETECTED_RG}"
}

### --------------------------------
### Detect Rust Fd-Find Binary
### --------------------------------
_detect_fd() {
	[ -n "${_DETECTED_FD:-}" ] && echo "${_DETECTED_FD}" && return 0
	if command -v fd > "/dev/null" 2>&1; then
		_DETECTED_FD="fd"
	elif command -v fdfind > "/dev/null" 2>&1; then
		_DETECTED_FD="fdfind"
	elif command -v fd-find > "/dev/null" 2>&1; then
		_DETECTED_FD="fd-find"
	elif [ -x "${HOME}/.cargo/bin/fd" ]; then
		_DETECTED_FD="${HOME}/.cargo/bin/fd"
	else
		_DETECTED_FD=""
	fi
	echo "${_DETECTED_FD}"
}

### --------------------------------
### Detect Privilege Escalator
### --------------------------------
_detect_privilege_escalator() {
	if [ "$(id -u)" -eq 0 ]; then
		echo "root"
	elif command -v doas > "/dev/null" 2>&1; then
		echo "doas"
	elif command -v sudo > "/dev/null" 2>&1; then
		echo "sudo"
	fi
}

### --------------------------------
### Detect Raw TTY
### --------------------------------
_is_raw_tty() {
	case "${TERM}" in
		linux|dumb|vt100|cons25*) return 0 ;;
	esac

	case "$(command tty 2> "/dev/null")" in
		/dev/tty[0-9]*|/dev/ttyv*|/dev/ttyS*|/dev/console) return 0 ;;
		*) return 1 ;;
	esac
}

### --------------------------------
### Detect Kernel Release
### --------------------------------
_detect_kernel_release() {
	[ -n "${_DETECTED_KERNEL_RELEASE:-}" ] && echo "${_DETECTED_KERNEL_RELEASE}" && return 0
	_DETECTED_KERNEL_RELEASE="$(uname -r)"
	echo "${_DETECTED_KERNEL_RELEASE}"
}
