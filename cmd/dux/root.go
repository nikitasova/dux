package main

import (
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:               "dux [context]",
	Short:             "Docker Use Context - Fast Docker context switching",
	Args:              cobra.MaximumNArgs(1),
	ValidArgsFunction: contextCompletion,
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			runList(cmd, args)
		} else {
			runUse(cmd, args)
		}
	},
}

func init() {
	rootCmd.AddCommand(listCmd, useCmd, createCmd, deleteCmd, currentCmd, versionCmd)
}
