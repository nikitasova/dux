package main

import (
	"strings"

	"github.com/nikitasova/dux/internal/docker"
	"github.com/spf13/cobra"
)

var (
	flagRemote   string
	flagEndpoint string
	flagDesc     string
)

var createCmd = &cobra.Command{
	Use:     "create <name>",
	Aliases: []string{"c"},
	Short:   "Create a new Docker context",
	Example: `  dux create local
  dux create -r prod user@192.168.1.100
  dux create -e tcp://localhost:2375 dev`,
	Args: cobra.MaximumNArgs(1),
	Run:  runCreate,
}

func init() {
	createCmd.Flags().StringVarP(&flagRemote, "remote", "r", "", "SSH host (user@host or IP)")
	createCmd.Flags().StringVarP(&flagEndpoint, "endpoint", "e", "", "Docker endpoint URL")
	createCmd.Flags().StringVarP(&flagDesc, "description", "d", "", "Context description")
}

func runCreate(cmd *cobra.Command, args []string) {
	name := getArg(args, 0, "Context name: ")
	if name == "" {
		exitWithMsg("context name is required")
	}

	host := resolveHost()
	desc := flagDesc
	if desc == "" {
		desc = prompt("Description (optional): ")
	}

	exitOnErr(docker.CreateContext(name, host, desc))
}

func resolveHost() string {
	switch {
	case flagRemote != "":
		if strings.HasPrefix(flagRemote, "ssh://") {
			return flagRemote
		}
		return "ssh://" + flagRemote
	case flagEndpoint != "":
		return flagEndpoint
	default:
		h := prompt("Docker endpoint (default: unix:///var/run/docker.sock): ")
		if h == "" {
			return "unix:///var/run/docker.sock"
		}
		return h
	}
}
