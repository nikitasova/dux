package main

import (
	"github.com/nikitasova/dux/internal/docker"
	"github.com/spf13/cobra"
)

var useCmd = &cobra.Command{
	Use:               "use <name>",
	Short:             "Switch to a Docker context",
	Args:              cobra.ExactArgs(1),
	ValidArgsFunction: contextCompletion,
	Run:               runUse,
}

func runUse(cmd *cobra.Command, args []string) {
	exitOnErr(docker.UseContext(args[0]))
}
