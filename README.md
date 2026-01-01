<p align="center">
  <img src="docs/assets/logo/Dux-logo.png" alt="dux logo" width="120">
</p>

<h1 align="center">dux</h1>

<p align="center">
  <strong>Docker! Use Context - Tool for fast Docker context usage</strong>
</p>

<p align="center">
  <a href="https://github.com/nikitasova/dux/blob/main/LICENSE"><img src="https://img.shields.io/github/license/nikitasova/dux?style=flat-square" alt="License"></a>
  <a href="https://github.com/nikitasova/dux/stargazers"><img src="https://img.shields.io/github/stars/nikitasova/dux?style=flat-square" alt="Stars"></a>
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-green?style=flat-square&logo=gnu-bash" alt="Shell">
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-usage">Usage</a> •
  <a href="#-configuration">Configuration</a>
</p>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🐳 **Context Switcher** | Quickly list and switch Docker contexts with `dux` |
| 🔗 **Remote Contexts** | Create SSH remote contexts with `dux -c -r` |
| 🎨 **Shell Prompt** | Show current Docker context in your prompt like kube-ps1 |
| ⌨️ **Tab Completion** | Auto-complete context names and flags (Bash & Zsh) |
| 📦 **Modular Install** | Install only what you need - switcher, prompt, or both |
| ⚡ **Fast** | Reads config directly from file, no Docker CLI overhead |
| 🔧 **Shell Agnostic** | Works with Bash, Zsh, and compatible shells |

---

## 📊 Components

| Component | Description | File |
|-----------|-------------|------|
| 🔀 **dux** | Context switcher command | `cmd/dux.sh` |
| 🎯 **dux-prompt** | Shell prompt integration | `cmd/dux-prompt.sh` |

Both components are **standalone** and can be installed independently.

---

## 📦 Installation

### Quick Install (curl)

```bash
# Interactive installer (choose what to install)
curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash
```

#### Install specific components

```bash
# Install only dux (context switcher)
curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash -s -- --dux

# Install only dux-prompt (shell prompt)
curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash -s -- --prompt

# Install both
curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash -s -- --all
```

### Manual Installation

```bash
# Create directory
mkdir -p ~/.dux

# Download dux (context switcher)
curl -o ~/.dux/dux.sh https://raw.githubusercontent.com/nikitasova/dux/main/cmd/dux.sh

# Download dux-prompt (shell prompt)
curl -o ~/.dux/dux-prompt.sh https://raw.githubusercontent.com/nikitasova/dux/main/cmd/dux-prompt.sh

# Make executable
chmod +x ~/.dux/*.sh
```

### Shell Configuration

Add to your shell rc file (`~/.zshrc` or `~/.bashrc`):

**Zsh:**
```bash
# dux - Docker context switcher
source ~/.dux/dux.sh

# dux-prompt - Docker context in prompt
source ~/.dux/dux-prompt.sh
PROMPT='$(docker_ps1) '$PROMPT
```

**Bash:**
```bash
# dux - Docker context switcher
source ~/.dux/dux.sh

# dux-prompt - Docker context in prompt
source ~/.dux/dux-prompt.sh
PS1='$(docker_ps1) '$PS1
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

---

## 🚀 Usage

### dux - Context Switcher

#### Commands

| Command | Description |
|---------|-------------|
| `dux` | List all Docker contexts |
| `dux <name>` | Switch to context |
| `dux -c <name>` | Create new context (interactive) |
| `dux -c -r <name>` | Create remote SSH context (interactive) |
| `dux -c -r <name> <ssh>` | Create remote SSH context directly |
| `dux -d <name>` | Delete context |
| `dux -h` | Show help |

#### Examples

List all available Docker contexts:

```bash
$ dux
NAME         DESCRIPTION                               DOCKER ENDPOINT               ERROR
default *    Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
production   Production server                         ssh://user@prod.example.com
staging      Staging environment                       ssh://user@stage.example.com
```

Switch to a specific context:

```bash
$ dux production
Current context is now "production"
```

Create a remote SSH context (interactive):

```bash
$ dux -c -r staging
SSH host (user@host or just host): deploy@staging.example.com
Description (optional): Staging server
staging
Successfully created context "staging"
```

Create a remote SSH context (one-liner):

```bash
# With hostname
$ dux -c -r prod user@prod.example.com

# With IP address
$ dux -c -r prod root@192.168.1.100
```

Delete a context:

```bash
$ dux -d old-context
Delete context 'old-context'? [y/N]: y
old-context
```

#### Tab Completion

Completion is automatically enabled for both Bash and Zsh:

```bash
$ dux <TAB>
default     production  staging     -c          -d          -h

$ dux -d <TAB>
default     production  staging

$ dux prod<TAB>
$ dux production
```

### dux-prompt - Shell Prompt

When enabled, your prompt shows the current Docker context:

```
(🐳|production) ~/projects $
```

#### Available Functions

| Function | Output | Use Case |
|----------|--------|----------|
| `docker_ps1` | `(🐳\|context)` | Standard prompt |
| `docker_ps1_with_spacing` | ` (🐳\|context)` | Appending to existing prompts |

#### Toggle Commands

| Command | Action |
|---------|--------|
| `dockon` | Enable Docker context in prompt |
| `dockoff` | Disable Docker context in prompt |

---

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOCKER_PS1_ENABLED` | `true` | Enable/disable Docker context in prompt |

Set default state in your shell rc:

```bash
DOCKER_PS1_ENABLED=false  # Disabled by default
source ~/.dux/dux-prompt.sh
```

---

## 📋 Requirements

- Docker CLI installed and configured
- Bash, Zsh, or compatible shell
- `curl` (for installation)

---

## 📁 Project Structure

```
dux/
├── cmd/
│   ├── dux.sh          # Docker context switcher
│   └── dux-prompt.sh   # Shell prompt integration
├── install.sh          # One-line installer script
├── LICENSE             # MIT License with attribution
└── README.md
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. 🍴 Fork the project
2. 🔨 Create your feature branch (`git checkout -b feat/amazing-feature`)
3. 📝 Commit your changes using [Conventional Commits](https://www.conventionalcommits.org/)
4. 🚀 Push to the branch (`git push origin feat/amazing-feature`)
5. 📬 Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License with Attribution Requirement - see [LICENSE](LICENSE) for details.

---

## ❤️ Support

- ⭐ [Star the project](https://github.com/nikitasova/dux)
- 🐛 [Report a bug](https://github.com/nikitasova/dux/issues/new?labels=bug)
- 💡 [Request a feature](https://github.com/nikitasova/dux/issues/new?labels=enhancement)

---

<p align="center">
  <strong>Original Author:</strong> <a href="https://github.com/nikitasova">Nikita</a>
</p>

<p align="center">
  <em>Inspired by <a href="https://github.com/ahmetb/kubectx">kubectx</a> and <a href="https://github.com/jonmosco/kube-ps1">kube-ps1</a></em>
</p>
