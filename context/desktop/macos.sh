### ================================
### DESKTOP CONTEXT MACOS
### ================================

### --------------------------------
### System Integration
### --------------------------------
clip() {
	command -v pbcopy > "/dev/null" 2>&1 || { echo "❌ pbcopy not found." >&2; return 127; }
	command pbcopy "$@"
}

paste() {
	command -v pbpaste > "/dev/null" 2>&1 || { echo "❌ pbpaste not found." >&2; return 127; }
	command pbpaste "$@"
}

o() {
	command -v open > "/dev/null" 2>&1 || { echo "❌ open not found." >&2; return 127; }
	command open "$@"
}
