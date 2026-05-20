package main

import (
	"fmt"
	"strings"

	"github.com/nikitasova/dux/internal/docker"
	"github.com/spf13/cobra"
)

var flagForce bool

var deleteCmd = &cobra.Command{
	Use:               "delete <name>",
	Aliases:           []string{"rm", "d"},
	Short:             "Delete a Docker context",
	Args:              cobra.ExactArgs(1),
	ValidArgsFunction: contextCompletion,
	Run:               runDelete,
}

func init() {
	deleteCmd.Flags().BoolVarP(&flagForce, "force", "f", false, "Skip confirmation")
}

func runDelete(cmd *cobra.Command, args []string) {
	name := args[0]

	if !flagForce {
		answer := prompt(fmt.Sprintf("Delete '%s'? [y/N]: ", name))
		if strings.ToLower(answer) != "y" {
			fmt.Println("Cancelled.")
			return
		}
	}

	exitOnErr(docker.DeleteContext(name))
}
