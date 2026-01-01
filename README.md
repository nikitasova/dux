<p align="center">
  <img src="docs/assets/logo/Dux-logo.png" alt="dux logo" width="120">
</p>



<p>
  <h1 align="center">dux</h1>
  <h2 align=center>Docker! Use Context! </strong>
</p>


<p align="center">
  <a href="https://github.com/nikitasova/dux/releases"><img src="https://img.shields.io/github/v/release/nikitasova/dux?style=flat-square&color=blue" alt="Release"></a>
  <a href="https://github.com/nikitasova/dux/blob/main/LICENSE"><img src="https://img.shields.io/github/license/nikitasova/dux?style=flat-square" alt="License"></a>
  <a href="https://github.com/nikitasova/dux/stargazers"><img src="https://img.shields.io/github/stars/nikitasova/dux?style=flat-square" alt="Stars"></a>
  <img src="https://img.shields.io/badge/Go-1.22+-00ADD8?style=flat-square&logo=go" alt="Go Version">
</p>

<p align="center">
  <code>dux</code> + <code>dux-prompt</code>: Useful tools for docker
</p>



## Install

**Homebrew**
```bash
brew install nikitasova/dux/dux
```

**APT**
```bash
curl -fsSL https://nikitasova.github.io/dux/dux.gpg | sudo gpg --dearmor -o /usr/share/keyrings/dux.gpg

echo "deb [signed-by=/usr/share/keyrings/dux.gpg] https://nikitasova.github.io/dux/repo/apt stable main" | sudo tee /etc/apt/sources.list.d/dux.list

sudo apt update && sudo apt install dux
```

**Go**
```bash
go install github.com/nikitasova/dux/cmd/dux@latest
```

**Script**
```bash
curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash
```

---

## Usage

```bash
dux                           # List contexts
dux <name>                    # Switch to context
dux create <name>             # Create context
dux create -r <name> <ssh>    # Create SSH remote context
dux delete <name>             # Delete context
dux current                   # Show current context
dux prompt                    # Install shell prompt
```

**Examples**
```bash
$ dux
NAME         DESCRIPTION    DOCKER ENDPOINT
default *                   unix:///var/run/docker.sock
production                  ssh://user@prod.example.com

$ dux production
Current context is now "production"

$ dux create -r staging root@192.168.1.100
```

---

## $ Shell Prompt

Install and configure `dux-prompt` to show context in your prompt:

```bash
dux prompt
```

Add to `~/.zshrc`:
```bash
source ~/.dux/dux-prompt.sh
PROMPT='$(docker_ps1) '$PROMPT
```

Result: `(🐳|production) ~/projects $`

```shell 
# Toggle ON/OFF pre-command / prompt 

# ON
dockon

# OFF
dockoff
```
