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
