# bash completion for dux

_dux() {
  local cur prev commands contexts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  
  commands="create delete list use current prompt version"
  
  case "${prev}" in
    dux)
      # First argument: contexts or commands
      contexts=$(docker context list --format '{{.Name}}' 2>/dev/null)
      COMPREPLY=($(compgen -W "${contexts} ${commands}" -- "${cur}"))
      ;;
    delete|rm|d|use)
      # Complete with context names
      contexts=$(docker context list --format '{{.Name}}' 2>/dev/null)
      COMPREPLY=($(compgen -W "${contexts}" -- "${cur}"))
      ;;
    create|c)
      COMPREPLY=($(compgen -W "-r -e -d" -- "${cur}"))
      ;;
    completion)
      COMPREPLY=($(compgen -W "bash zsh fish powershell" -- "${cur}"))
      ;;
  esac
}

complete -F _dux dux
