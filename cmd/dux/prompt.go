package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

const (
	promptURL     = "https://raw.githubusercontent.com/nikitasova/dux/main/scripts/dux-prompt.sh"
	promptInstall = ".dux/dux-prompt.sh"
)

var promptCmd = &cobra.Command{
	Use:   "prompt",
	Short: "Install dux-prompt for shell integration",
	Long: `Install dux-prompt to show Docker context in your shell prompt.

After installation, add to your shell rc file:

  # Zsh (~/.zshrc)
  source ~/.dux/dux-prompt.sh
  PROMPT='$(docker_ps1) '$PROMPT

  # Bash (~/.bashrc)
  source ~/.dux/dux-prompt.sh
  PS1='$(docker_ps1) '$PS1`,
	Run: runPromptInstall,
}

func init() {
	rootCmd.AddCommand(promptCmd)
}

func runPromptInstall(cmd *cobra.Command, args []string) {
	home, err := os.UserHomeDir()
	if err != nil {
		exitOnErr(fmt.Errorf("cannot find home directory: %w", err))
	}

	installPath := filepath.Join(home, promptInstall)
	installDir := filepath.Dir(installPath)

	// Create directory
	if err := os.MkdirAll(installDir, 0755); err != nil {
		exitOnErr(fmt.Errorf("cannot create directory: %w", err))
	}

	// Download script
	fmt.Println("Downloading dux-prompt...")
	resp, err := http.Get(promptURL)
	if err != nil {
		exitOnErr(fmt.Errorf("download failed: %w", err))
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		exitOnErr(fmt.Errorf("download failed: HTTP %d", resp.StatusCode))
	}

	// Write to file
	file, err := os.Create(installPath)
	if err != nil {
		exitOnErr(fmt.Errorf("cannot create file: %w", err))
	}
	defer file.Close()

	if _, err := io.Copy(file, resp.Body); err != nil {
		exitOnErr(fmt.Errorf("cannot write file: %w", err))
	}

	// Make executable
	if err := os.Chmod(installPath, 0755); err != nil {
		exitOnErr(fmt.Errorf("cannot set permissions: %w", err))
	}

	fmt.Printf("✓ Installed to %s\n\n", installPath)
	printSetupInstructions()
}

func printSetupInstructions() {
	fmt.Println("Add to your shell rc file:")
	fmt.Println()
	fmt.Println("  # Zsh (~/.zshrc)")
	fmt.Println("  source ~/.dux/dux-prompt.sh")
	fmt.Println("  PROMPT='$(docker_ps1) '$PROMPT")
	fmt.Println()
	fmt.Println("  # Bash (~/.bashrc)")
	fmt.Println("  source ~/.dux/dux-prompt.sh")
	fmt.Println("  PS1='$(docker_ps1) '$PS1")
	fmt.Println()
	fmt.Println("Then reload: source ~/.zshrc")
}

