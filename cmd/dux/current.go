package main

import (
	"fmt"

	"github.com/nikitasova/dux/internal/docker"
	"github.com/spf13/cobra"
)

var currentCmd = &cobra.Command{
	Use:   "current",
	Short: "Show current Docker context",
	Run: func(cmd *cobra.Command, args []string) {
		ctx, err := docker.GetCurrentContext()
		exitOnErr(err)
		fmt.Println(ctx)
	},
}
