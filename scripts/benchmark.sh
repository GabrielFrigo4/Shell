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

_c_reset="\033[0m"
_c_bold="\033[1m"
_c_green="\033[32m"
_c_yellow="\033[33m"
_c_red="\033[31m"
_c_cyan="\033[36m"

printf "%b⚡ Shell Startup Latency Benchmark%b (iters: %s, target: <50ms)\n\n" "${_c_bold}${_c_cyan}" "${_c_reset}" "${_iterations}"

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
    t1 = time.perf_counter()
    times.append((t1 - t0) * 1000)
avg = sum(times) / len(times)
print(f'{avg:.1f}')
" "${_cmd}" "${_iterations}" 2> "/dev/null" || echo "0.0"
}

### --------------------------------
### Benchmark Interactive Shells
### --------------------------------
printf "%b%-12s %-12s %-10s %s%b\n" "${_c_bold}" "SHELL" "LATENCY" "STATUS" "TARGET" "${_c_reset}"
printf "%s\n" "----------------------------------------------------"

for _sh in sh bash zsh; do
	if command -v "${_sh}" > "/dev/null" 2>&1; then
		_ms="$(_measure_cmd "${_sh} -i -c exit")"
		_ms_int="${_ms%.*}"
		if [ "${_ms_int:-0}" -lt 50 ]; then
			_status="${_c_green}PASS${_c_reset}"
		elif [ "${_ms_int:-0}" -lt 100 ]; then
			_status="${_c_yellow}WARN${_c_reset}"
		else
			_status="${_c_red}SLOW${_c_reset}"
		fi
		printf "%-12s %-12s %-19b %s\n" "${_sh}" "${_ms}ms" "${_status}" "< 50ms"
	fi
done

### --------------------------------
### Benchmark Ecosystem Modules
### --------------------------------
printf "\n%b📦 Ecosystem Modules Latency%b\n" "${_c_bold}${_c_cyan}" "${_c_reset}"
printf "%s\n" "----------------------------------------------------"

_shell_core_ms="$(_measure_cmd "sh -c '. ${_repo_dir}/library/detect.sh; . ${_repo_dir}/library/functions.sh; . ${_repo_dir}/core/environment.sh'")"
printf "%-24s %s\n" "Shell Core (sh)" "${_shell_core_ms}ms"

if command -v bash > "/dev/null" 2>&1; then
	_shell_bash_ms="$(_measure_cmd "bash -c 'export SHELL_REPO_DIR=${_repo_dir}; for f in ${_repo_dir}/library/*.sh ${_repo_dir}/core/*.sh; do . \"\$f\"; done; . ${_repo_dir}/target/linux/bash/prompt.sh'")"
	printf "%-24s %s\n" "Shell Stack (bash)" "${_shell_bash_ms}ms"
fi

if command -v zsh > "/dev/null" 2>&1; then
	_shell_zsh_ms="$(_measure_cmd "zsh -c 'export SHELL_REPO_DIR=${_repo_dir}; for f in ${_repo_dir}/library/*.sh ${_repo_dir}/core/*.sh; do . \"\$f\"; done; . ${_repo_dir}/target/linux/zsh/prompt.sh'")"
	printf "%-24s %s\n" "Shell Stack (zsh)" "${_shell_zsh_ms}ms"
fi

if [ -f "${_vault_dir}/vault.sh" ]; then
	_vault_ms="$(_measure_cmd "sh -c '. ${_vault_dir}/vault.sh'")"
	printf "%-24s %s\n" "Vault Sourcing (sh)" "${_vault_ms}ms"
fi

printf "\n%b✨ Benchmark completed successfully.%b\n" "${_c_green}" "${_c_reset}"
