#!/usr/bin/env sh

### ================================
### SHELL STARTUP BENCHMARK
### ================================

### --------------------------------
### Environment Setup
### --------------------------------
_repo_dir="$(cd "$(dirname "${0}")/.." && pwd)"
_vault_dir="${VAULT_DIR:-${_repo_dir}/../Vault}"
[ ! -d "${_vault_dir}" ] && _vault_dir="${HOME}/.vault"

_iterations=5
for _arg in "$@"; do
	case "${_arg}" in
		--iterations=*|-i=*) _iterations="${_arg#*=}" ;;
		[0-9]*)              _iterations="${_arg}" ;;
	esac
done

_c_reset=$'\e[0m'
_c_bold=$'\e[1m'
_c_green=$'\e[32m'
_c_yellow=$'\e[33m'
_c_red=$'\e[31m'
_c_cyan=$'\e[36m'


printf "%b⚡ Shell Startup Latency Benchmark%b (iters: %s, standard: 2^n)\n\n" "${_c_bold}${_c_cyan}" "${_c_reset}" "${_iterations}"

### --------------------------------
### Measurement Runner
### --------------------------------
_measure_cmd() {
	_cmd="${1}"
	python3 -c "
import sys, time, subprocess
cmd = sys.argv[1]
iters = int(sys.argv[2])
times = []
for _ in range(iters):
    t0 = time.perf_counter()
    subprocess.run(cmd, shell=True, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    times.append((time.perf_counter() - t0) * 1000)
avg = sum(times) / len(times)
print(f'{avg:.1f}')
" "${_cmd}" "${_iterations}" 2> "/dev/null" || echo "0.0"
}

_format_ms() {
	_val="${1}"
	_val_int="${_val%.*}"
	if [ "${_val_int:-0}" -lt 32 ]; then
		printf "%b%sms%b" "${_c_green}" "${_val}" "${_c_reset}"
	elif [ "${_val_int:-0}" -le 64 ]; then
		printf "%b%sms%b" "${_c_yellow}" "${_val}" "${_c_reset}"
	else
		printf "%b%sms%b" "${_c_red}" "${_val}" "${_c_reset}"
	fi
}

### --------------------------------
### Benchmark Interactive Shells
### --------------------------------
printf "%b%-12s %-12s %-10s %s%b\n" "${_c_bold}" "SHELL" "LATENCY" "STATUS" "TARGET" "${_c_reset}"
printf "%s\n" "----------------------------------------------------"

for _sh in sh bash zsh; do
	if command -v "${_sh}" > "/dev/null" 2>&1; then
		case "${_sh}" in
			sh|bash) _target="< 32ms"; _target_limit=32 ;;
			zsh)     _target="< 64ms"; _target_limit=64 ;;
			*)       _target="< 64ms"; _target_limit=64 ;;
		esac
		_ms="$(_measure_cmd "${_sh} -i -c exit")"
		_ms_int="${_ms%.*}"
		if [ "${_ms_int:-0}" -lt "${_target_limit}" ]; then
			_status="${_c_green}PASS${_c_reset}"
			_latency_colored="${_c_green}${_ms}ms${_c_reset}"
		elif [ "${_ms_int:-0}" -le 128 ]; then
			_status="${_c_yellow}WARN${_c_reset}"
			_latency_colored="${_c_yellow}${_ms}ms${_c_reset}"
		else
			_status="${_c_red}SLOW${_c_reset}"
			_latency_colored="${_c_red}${_ms}ms${_c_reset}"
		fi
		printf "%-12s %-21b %-19b %s\n" "${_sh}" "${_latency_colored}" "${_status}" "${_target}"
	fi
done

### --------------------------------
### Benchmark Ecosystem Modules
### --------------------------------
printf "\n%b📦 Ecosystem Modules Latency%b\n" "${_c_bold}${_c_cyan}" "${_c_reset}"
printf "%s\n" "----------------------------------------------------"

_shell_core_ms="$(_measure_cmd "sh -c '. ${_repo_dir}/library/detect.sh; . ${_repo_dir}/library/functions.sh; . ${_repo_dir}/core/environment.sh'")"
printf "%-24s %b\n" "Shell Core (sh)" "$(_format_ms "${_shell_core_ms}")"

if command -v bash > "/dev/null" 2>&1; then
	_shell_bash_ms="$(_measure_cmd "bash -c 'export SHELL_REPO_DIR=${_repo_dir}; for f in ${_repo_dir}/library/*.sh ${_repo_dir}/core/*.sh; do . \"\$f\"; done; . ${_repo_dir}/target/linux/bash/prompt.sh'")"
	printf "%-24s %b\n" "Shell Stack (bash)" "$(_format_ms "${_shell_bash_ms}")"
fi

if command -v zsh > "/dev/null" 2>&1; then
	_shell_zsh_ms="$(_measure_cmd "zsh -c 'export SHELL_REPO_DIR=${_repo_dir}; for f in ${_repo_dir}/library/*.sh ${_repo_dir}/core/*.sh; do . \"\$f\"; done; . ${_repo_dir}/target/linux/zsh/prompt.sh'")"
	printf "%-24s %b\n" "Shell Stack (zsh)" "$(_format_ms "${_shell_zsh_ms}")"
fi

if [ -f "${_vault_dir}/vault.sh" ]; then
	_vault_ms="$(_measure_cmd "sh -c '. ${_vault_dir}/vault.sh'")"
	printf "%-24s %b\n" "Vault Sourcing (sh)" "$(_format_ms "${_vault_ms}")"
fi

printf "\n%b✨ Benchmark completed successfully.%b\n" "${_c_green}" "${_c_reset}"
