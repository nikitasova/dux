#!/bin/bash
# dux-prompt - Docker context prompt for shell integration
#
# Usage: source this file in your shell rc file
#   source ~/.dux/dux-prompt.sh
#
# Then add $(docker_ps1) or $(docker_ps1_with_spacing) to your PROMPT variable
#   Example for zsh: PROMPT='$(docker_ps1) %~ $ '
#   Example for bash: PS1='$(docker_ps1) \w $ '
#
# Use docker_ps1_with_spacing for automatic leading space (useful for right-side prompts):
#   Example: RPROMPT='$(docker_ps1_with_spacing)'
#
# Commands:
#   dockon   - Enable Docker context in prompt
#   dockoff  - Disable Docker context in prompt

# Toggle variable (default: enabled)
DOCKER_PS1_ENABLED=${DOCKER_PS1_ENABLED:-true}

# Get current Docker context (reads config file directly for speed)
_docker_context_prompt() {
    local config_file="$HOME/.docker/config.json"
    if [[ -f "$config_file" ]]; then
        local context
        context=$(grep -o '"currentContext"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" 2>/dev/null | cut -d'"' -f4)
        [[ -z "$context" ]] && context="default"
        echo "(🐳|${context})"
    fi
}

# Function to use in PROMPT
docker_ps1() {
    if [[ "$DOCKER_PS1_ENABLED" == "true" ]]; then
        _docker_context_prompt
    fi
}

# Function with leading space (useful for appending to existing prompts)
docker_ps1_with_spacing() {
    local docker_output=$(docker_ps1)
    if [[ -n "$docker_output" ]]; then
        echo " $docker_output"
    fi
}

# Enable Docker context in prompt
dockon() {
    DOCKER_PS1_ENABLED=true
}

# Disable Docker context in prompt
dockoff() {
    DOCKER_PS1_ENABLED=false
}

