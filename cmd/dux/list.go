package main

import (
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

var listCmd = &cobra.Command{
	Use:     "list",
	Aliases: []string{"ls", "l"},
	Short:   "List all Docker contexts",
	Run:     runList,
}

func runList(cmd *cobra.Command, args []string) {
	c := exec.Command("docker", "context", "list")
	c.Stdout, c.Stderr = os.Stdout, os.Stderr
	c.Run()
}
