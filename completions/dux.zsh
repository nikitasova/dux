#compdef dux

_dux() {
  local -a commands contexts
  
  commands=(
    'create:Create a new Docker context'
    'delete:Delete a Docker context'
    'list:List all Docker contexts'
    'use:Switch to a Docker context'
    'current:Show current Docker context'
    'prompt:Install dux-prompt for shell integration'
    'version:Show version'
  )
  
  if (( CURRENT == 2 )); then
    # First argument: contexts or commands
    contexts=($(docker context list --format '{{.Name}}' 2>/dev/null))
    _describe 'context' contexts
    _describe 'command' commands
  elif (( CURRENT == 3 )); then
    case "${words[2]}" in
      delete|rm|d|use)
        contexts=($(docker context list --format '{{.Name}}' 2>/dev/null))
        _describe 'context' contexts
        ;;
      create|c)
        _arguments \
          '-r[SSH host for remote context]:ssh host:' \
          '-e[Docker endpoint URL]:endpoint:' \
          '-d[Context description]:description:'
        ;;
      completion)
        _values 'shell' bash zsh fish powershell
        ;;
    esac
  fi
}

_dux "$@"
