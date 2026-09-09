### ================================
### CONTAINER CONTEXT FREEBSD
### ================================

### --------------------------------
### Jail Detection
### --------------------------------
if command sysctl -n security.jail.jailed 2> "/dev/null" | command grep -qF '1'; then
	export CONTAINER_RUNTIME="jail"
fi

### --------------------------------
### Jail Identity
### --------------------------------
jid() {
	command sysctl -n security.jail.param.id 2> "/dev/null" ||
	command jls -n jid 2> "/dev/null" | command head -1 ||
	echo "unknown"
}

### --------------------------------
### Process Inspector
### --------------------------------
cprocs() {
	command ps aux 2> "/dev/null" || command ps -ef 2> "/dev/null"
}
