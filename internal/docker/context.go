package docker

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Context represents a Docker context
type Context struct {
	Name        string `json:"Name"`
	Description string `json:"Description"`
	DockerHost  string `json:"DockerEndpoint"`
	Current     bool   `json:"Current"`
}

// DockerConfig represents the Docker config.json structure
type DockerConfig struct {
	CurrentContext string `json:"currentContext"`
}

// ListContexts returns all available Docker contexts
func ListContexts() ([]Context, error) {
	cmd := exec.Command("docker", "context", "list", "--format", "json")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to list contexts: %w", err)
	}

	var contexts []Context
	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	for _, line := range lines {
		if line == "" {
			continue
		}
		var ctx Context
		if err := json.Unmarshal([]byte(line), &ctx); err != nil {
			continue
		}
		contexts = append(contexts, ctx)
	}

	return contexts, nil
}

// GetContextNames returns just the names of all contexts
func GetContextNames() ([]string, error) {
	contexts, err := ListContexts()
	if err != nil {
		return nil, err
	}

	names := make([]string, len(contexts))
	for i, ctx := range contexts {
		names[i] = ctx.Name
	}
	return names, nil
}

// GetCurrentContext returns the name of the current context
func GetCurrentContext() (string, error) {
	configPath := filepath.Join(os.Getenv("HOME"), ".docker", "config.json")
	data, err := os.ReadFile(configPath)
	if err != nil {
		return "default", nil
	}

	var config DockerConfig
	if err := json.Unmarshal(data, &config); err != nil {
		return "default", nil
	}

	if config.CurrentContext == "" {
		return "default", nil
	}
	return config.CurrentContext, nil
}

// UseContext switches to the specified context
func UseContext(name string) error {
	cmd := exec.Command("docker", "context", "use", name)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// CreateContext creates a new Docker context
func CreateContext(name, host, description string) error {
	args := []string{"context", "create", name, "--docker", fmt.Sprintf("host=%s", host)}
	if description != "" {
		args = append(args, "--description", description)
	}

	cmd := exec.Command("docker", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// CreateRemoteContext creates a new SSH remote context
func CreateRemoteContext(name, sshHost, description string) error {
	// Add ssh:// prefix if not present
	if !strings.HasPrefix(sshHost, "ssh://") {
		sshHost = "ssh://" + sshHost
	}
	return CreateContext(name, sshHost, description)
}

// DeleteContext removes a Docker context
func DeleteContext(name string) error {
	cmd := exec.Command("docker", "context", "rm", name)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// ContextExists checks if a context with the given name exists
func ContextExists(name string) bool {
	contexts, err := GetContextNames()
	if err != nil {
		return false
	}
	for _, ctx := range contexts {
		if ctx == name {
			return true
		}
	}
	return false
}

