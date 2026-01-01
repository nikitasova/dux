package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func prompt(msg string) string {
	fmt.Print(msg)
	s, _ := bufio.NewReader(os.Stdin).ReadString('\n')
	return strings.TrimSpace(s)
}

func getArg(args []string, i int, promptMsg string) string {
	if i < len(args) {
		return args[i]
	}
	return prompt(promptMsg)
}

func exitOnErr(err error) {
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func exitWithMsg(msg string) {
	fmt.Fprintf(os.Stderr, "Error: %s\n", msg)
	os.Exit(1)
}
