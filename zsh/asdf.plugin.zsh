# asdf plugin
# Return early if asdf is not installed
(( ${+commands[asdf]} )) || return 1

# Set ASDF_DATA_DIR if not already set
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-${HOME}/.asdf}"

# Add asdf shims to PATH (remove if already present, then prepend)
path=("${ASDF_DATA_DIR}/shims" ${path:#${ASDF_DATA_DIR}/shims})

# Set up completions
() {
  builtin emulate -L zsh -o EXTENDED_GLOB
  
  local -r asdf_data="${ASDF_DATA_DIR}"
  local -r completion_file="${asdf_data}/completions/_asdf"
  
  # Check if _asdf is already in fpath
  if [[ -z ${^fpath}/_asdf(#qN) ]]; then
    # Generate or update completion file if needed
    if [[ ! -f "${completion_file}" ]] || [[ ! "${completion_file}" -nt "${commands[asdf]}" ]]; then
      mkdir -p "${asdf_data}/completions"
      asdf completion zsh >! "${completion_file}" 2>/dev/null
    fi
    
    # Add to fpath if completion file exists
    if [[ -f "${completion_file}" ]]; then
      fpath=("${asdf_data}/completions" ${fpath})
    fi
  fi
}
