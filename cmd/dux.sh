#!/bin/bash
# dux - Docker Use Context
#
# Usage: source this file in your shell rc file
#   source ~/.dux/dux.sh
#
# Commands:
#   dux                        - List all available Docker contexts
#   dux <name>                 - Switch to the specified Docker context
#   dux -c <name>              - Create a new Docker context (interactive)
#   dux -c -r <name>           - Create a remote SSH context (interactive)
#   dux -c -r <name> <ssh>     - Create a remote SSH context directly
#   dux -d <name>              - Delete a Docker context
#   dux -h                     - Show help

dux() {
    local create_mode=false
    local remote_mode=false
    local delete_mode=false
    local context_name=""
    local ssh_host=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                _dux_help
                return 0
                ;;
            -c|--create)
                create_mode=true
                shift
                ;;
            -r|--remote)
                remote_mode=true
                shift
                ;;
            -d|--delete)
                delete_mode=true
                shift
                ;;
            -*)
                echo "dux: unknown option: $1"
                echo "Use 'dux -h' for help."
                return 1
                ;;
            *)
                if [[ -z "$context_name" ]]; then
                    context_name="$1"
                else
                    ssh_host="$1"
                fi
                shift
                ;;
        esac
    done

    # Handle modes
    if [[ "$delete_mode" == "true" ]]; then
        _dux_delete "$context_name"
    elif [[ "$create_mode" == "true" ]]; then
        if [[ "$remote_mode" == "true" ]]; then
            _dux_create_remote "$context_name" "$ssh_host"
        else
            _dux_create "$context_name"
        fi
    elif [[ -n "$context_name" ]]; then
        # Switch to context
        docker context use "$context_name"
    else
        # List all contexts
        docker context list
    fi
}

_dux_help() {
    echo "dux - Docker Use Context"
    echo ""
    echo "Usage:"
    echo "  dux                        List all Docker contexts"
    echo "  dux <name>                 Switch to context"
    echo "  dux -c <name>              Create new context (interactive)"
    echo "  dux -c -r <name>           Create remote SSH context (interactive)"
    echo "  dux -c -r <name> <ssh>     Create remote SSH context"
    echo "  dux -d <name>              Delete context"
    echo "  dux -h                     Show this help"
    echo ""
    echo "Examples:"
    echo "  dux production             Switch to 'production' context"
    echo "  dux -c -r staging          Create 'staging' with interactive SSH prompt"
    echo "  dux -c -r prod user@host   Create 'prod' with ssh://user@host"
    echo ""
}

_dux_create() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo -n "Context name: "
        read name
        if [[ -z "$name" ]]; then
            echo "dux: context name is required"
            return 1
        fi
    fi

    echo -n "Docker endpoint (default: unix:///var/run/docker.sock): "
    read endpoint
    endpoint="${endpoint:-unix:///var/run/docker.sock}"

    echo -n "Description (optional): "
    read description

    if [[ -n "$description" ]]; then
        docker context create "$name" --docker "host=$endpoint" --description "$description"
    else
        docker context create "$name" --docker "host=$endpoint"
    fi
}

_dux_create_remote() {
    local name="$1"
    local ssh_host="$2"

    if [[ -z "$name" ]]; then
        echo -n "Context name: "
        read name
        if [[ -z "$name" ]]; then
            echo "dux: context name is required"
            return 1
        fi
    fi

    if [[ -z "$ssh_host" ]]; then
        echo -n "SSH host (user@host or just host): "
        read ssh_host
        if [[ -z "$ssh_host" ]]; then
            echo "dux: SSH host is required"
            return 1
        fi
    fi

    # Add ssh:// prefix if not present
    if [[ "$ssh_host" != ssh://* ]]; then
        ssh_host="ssh://$ssh_host"
    fi

    echo -n "Description (optional): "
    read description

    if [[ -n "$description" ]]; then
        docker context create "$name" --docker "host=$ssh_host" --description "$description"
    else
        docker context create "$name" --docker "host=$ssh_host"
    fi
}

_dux_delete() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo "dux: context name is required for deletion"
        echo "Usage: dux -d <name>"
        return 1
    fi

    echo -n "Delete context '$name'? [y/N]: "
    read confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        docker context rm "$name"
    else
        echo "Cancelled."
    fi
}

# ============================================================================
# Shell Completions
# ============================================================================

# Get list of Docker context names
_dux_get_contexts() {
    docker context list --format '{{.Name}}' 2>/dev/null
}

# Zsh completion
if [[ -n "$ZSH_VERSION" ]]; then
    _dux_zsh_completion() {
        local -a contexts
        local -a options

        options=(
            '-c:Create new context'
            '-r:Remote SSH context (use with -c)'
            '-d:Delete context'
            '-h:Show help'
            '--create:Create new context'
            '--remote:Remote SSH context (use with --create)'
            '--delete:Delete context'
            '--help:Show help'
        )

        # Check if we're completing after -d or --delete
        if [[ "${words[(r)-d]}" == "-d" ]] || [[ "${words[(r)--delete]}" == "--delete" ]]; then
            contexts=(${(f)"$(_dux_get_contexts)"})
            _describe 'context' contexts
            return
        fi

        # Check if we already have -c flag (don't complete contexts for create)
        if [[ "${words[(r)-c]}" == "-c" ]] || [[ "${words[(r)--create]}" == "--create" ]]; then
            # After -c, offer -r flag if not present
            if [[ "${words[(r)-r]}" != "-r" ]] && [[ "${words[(r)--remote]}" != "--remote" ]]; then
                _describe 'option' options
            fi
            return
        fi

        # Default: complete options and context names
        contexts=(${(f)"$(_dux_get_contexts)"})
        
        if [[ "$PREFIX" == -* ]]; then
            _describe 'option' options
        else
            _describe 'context' contexts
            _describe 'option' options
        fi
    }

    compdef _dux_zsh_completion dux
fi

# Bash completion
if [[ -n "$BASH_VERSION" ]]; then
    _dux_bash_completion() {
        local cur prev words cword
        _init_completion 2>/dev/null || {
            COMPREPLY=()
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
        }

        local options="-c --create -r --remote -d --delete -h --help"

        # After -d or --delete, complete context names
        if [[ "$prev" == "-d" ]] || [[ "$prev" == "--delete" ]]; then
            COMPREPLY=($(compgen -W "$(_dux_get_contexts)" -- "$cur"))
            return
        fi

        # Check if -c is in the command (creating, don't show contexts)
        local has_create=false
        for word in "${COMP_WORDS[@]}"; do
            if [[ "$word" == "-c" ]] || [[ "$word" == "--create" ]]; then
                has_create=true
                break
            fi
        done

        if [[ "$has_create" == true ]]; then
            # Only offer -r if not present
            local has_remote=false
            for word in "${COMP_WORDS[@]}"; do
                if [[ "$word" == "-r" ]] || [[ "$word" == "--remote" ]]; then
                    has_remote=true
                    break
                fi
            done
            if [[ "$has_remote" == false ]]; then
                COMPREPLY=($(compgen -W "-r --remote" -- "$cur"))
            fi
            return
        fi

        # Default: complete options and context names
        if [[ "$cur" == -* ]]; then
            COMPREPLY=($(compgen -W "$options" -- "$cur"))
        else
            local contexts="$(_dux_get_contexts)"
            COMPREPLY=($(compgen -W "$contexts $options" -- "$cur"))
        fi
    }

    complete -F _dux_bash_completion dux
fi
