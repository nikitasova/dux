# fish completion for dux

# Disable file completion
complete -c dux -f

# Contexts
complete -c dux -n '__fish_use_subcommand' -a '(docker context list --format "{{.Name}}" 2>/dev/null)'

# Commands
complete -c dux -n '__fish_use_subcommand' -a 'create' -d 'Create a new Docker context'
complete -c dux -n '__fish_use_subcommand' -a 'delete' -d 'Delete a Docker context'
complete -c dux -n '__fish_use_subcommand' -a 'list' -d 'List all Docker contexts'
complete -c dux -n '__fish_use_subcommand' -a 'use' -d 'Switch to a Docker context'
complete -c dux -n '__fish_use_subcommand' -a 'current' -d 'Show current context'
complete -c dux -n '__fish_use_subcommand' -a 'prompt' -d 'Install dux-prompt'
complete -c dux -n '__fish_use_subcommand' -a 'version' -d 'Show version'

# delete/use subcommand - complete with contexts
complete -c dux -n '__fish_seen_subcommand_from delete use' -a '(docker context list --format "{{.Name}}" 2>/dev/null)'

# create subcommand flags
complete -c dux -n '__fish_seen_subcommand_from create' -s r -d 'SSH host for remote context'
complete -c dux -n '__fish_seen_subcommand_from create' -s e -d 'Docker endpoint URL'
complete -c dux -n '__fish_seen_subcommand_from create' -s d -d 'Context description'

# completion subcommand
complete -c dux -n '__fish_seen_subcommand_from completion' -a 'bash zsh fish powershell'
