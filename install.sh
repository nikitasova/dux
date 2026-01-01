#!/bin/bash
# dux installer
# Fast installation script for dux tools
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash -s -- --dux
#   curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash -s -- --prompt
#   curl -fsSL https://raw.githubusercontent.com/nikitasova/dux/main/install.sh | bash -s -- --all

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="nikitasova/dux"
REPO_URL="https://raw.githubusercontent.com/${REPO}/main"
INSTALL_DIR="$HOME/.local/bin"
PROMPT_DIR="$HOME/.dux"

print_banner() {
    echo -e "${BLUE}"
    echo "  ┌─────────────────────────────────────┐"
    echo "  │         dux installer               │"
    echo "  │   Fast Docker context switching     │"
    echo "  └─────────────────────────────────────┘"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "darwin"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            echo "amd64"
            ;;
        arm64|aarch64)
            echo "arm64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

detect_shell() {
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        echo "zsh"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

get_shell_rc() {
    local shell_type=$(detect_shell)
    case "$shell_type" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.bash_profile"
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

get_latest_release() {
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

install_dux() {
    local os=$(detect_os)
    local arch=$(detect_arch)
    
    if [[ "$os" == "unknown" ]] || [[ "$arch" == "unknown" ]]; then
        print_error "Unsupported platform: $(uname -s) $(uname -m)"
        print_info "Please build from source: https://github.com/${REPO}"
        exit 1
    fi

    print_info "Detecting platform: ${os}/${arch}"
    
    # Get latest release version
    local version=$(get_latest_release)
    if [[ -z "$version" ]]; then
        print_warn "Could not detect latest version, using 'latest'"
        version="latest"
    else
        print_info "Latest version: ${version}"
    fi
    
    # Download binary
    local binary_name="dux-${os}-${arch}"
    local download_url="https://github.com/${REPO}/releases/latest/download/${binary_name}"
    
    print_info "Downloading dux..."
    mkdir -p "$INSTALL_DIR"
    
    if curl -fsSL "$download_url" -o "$INSTALL_DIR/dux" 2>/dev/null; then
        chmod +x "$INSTALL_DIR/dux"
        print_success "dux installed to $INSTALL_DIR/dux"
    else
        # Fallback: try to build from source if Go is available
        print_warn "Binary download failed. Trying to build from source..."
        if command -v go &> /dev/null; then
            go install "github.com/${REPO}/cmd/dux@latest"
            print_success "dux installed via 'go install'"
        else
            print_error "Could not download binary and Go is not installed."
            print_info "Please install Go or download manually from:"
            print_info "  https://github.com/${REPO}/releases"
            exit 1
        fi
    fi
}

install_prompt() {
    print_info "Installing dux-prompt (shell prompt)..."
    mkdir -p "$PROMPT_DIR"
    curl -fsSL "$REPO_URL/scripts/dux-prompt.sh" -o "$PROMPT_DIR/dux-prompt.sh"
    chmod +x "$PROMPT_DIR/dux-prompt.sh"
    print_success "dux-prompt installed to $PROMPT_DIR/dux-prompt.sh"
}

setup_completions() {
    local shell_type=$(detect_shell)
    
    print_info "Setting up shell completions..."
    
    case "$shell_type" in
        zsh)
            # Add to .zshrc
            local completion_cmd='eval "$(dux completion zsh)"'
            if ! grep -q "dux completion" "$HOME/.zshrc" 2>/dev/null; then
                echo "" >> "$HOME/.zshrc"
                echo "# dux shell completion" >> "$HOME/.zshrc"
                echo "$completion_cmd" >> "$HOME/.zshrc"
                print_success "Zsh completions configured"
            else
                print_info "Completions already configured"
            fi
            ;;
        bash)
            local rc_file=$(get_shell_rc)
            local completion_cmd='eval "$(dux completion bash)"'
            if ! grep -q "dux completion" "$rc_file" 2>/dev/null; then
                echo "" >> "$rc_file"
                echo "# dux shell completion" >> "$rc_file"
                echo "$completion_cmd" >> "$rc_file"
                print_success "Bash completions configured"
            else
                print_info "Completions already configured"
            fi
            ;;
    esac
}

show_setup_instructions() {
    local shell_rc=$(get_shell_rc)
    local shell_type=$(detect_shell)
    
    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_warn "~/.local/bin is not in your PATH"
        echo ""
        echo "Add to your ${YELLOW}$shell_rc${NC}:"
        echo '  export PATH="$HOME/.local/bin:$PATH"'
        echo ""
    fi
    
    if [[ "$INSTALL_PROMPT" == "true" ]]; then
        echo "Add to your ${YELLOW}$shell_rc${NC}:"
        echo ""
        echo -e "${BLUE}# dux-prompt - Docker context in prompt${NC}"
        echo "source ~/.dux/dux-prompt.sh"
        
        if [[ "$shell_type" == "zsh" ]]; then
            echo 'PROMPT='\''$(docker_ps1) '\''$PROMPT'
        else
            echo 'PS1='\''$(docker_ps1) '\''$PS1'
        fi
        echo ""
    fi
    
    echo "Then reload your shell:"
    echo -e "  ${YELLOW}source $shell_rc${NC}"
    echo ""
    echo "Usage:"
    echo "  dux              # List all contexts"
    echo "  dux <name>       # Switch to context"
    echo "  dux create -r <name> <ssh-host>  # Create remote context"
    echo "  dux --help       # Show all commands"
    echo ""
}

show_interactive_menu() {
    echo "What would you like to install?"
    echo ""
    echo "  1) dux          - Docker context switcher (Go binary)"
    echo "  2) dux-prompt   - Docker context in shell prompt"
    echo "  3) Both         - Install everything"
    echo "  q) Quit"
    echo ""
    read -p "Enter choice [1-3, q]: " choice
    
    case "$choice" in
        1)
            INSTALL_DUX=true
            INSTALL_PROMPT=false
            ;;
        2)
            INSTALL_DUX=false
            INSTALL_PROMPT=true
            ;;
        3)
            INSTALL_DUX=true
            INSTALL_PROMPT=true
            ;;
        q|Q)
            echo "Installation cancelled."
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please try again."
            show_interactive_menu
            ;;
    esac
}

main() {
    print_banner
    
    # Parse arguments
    INSTALL_DUX=false
    INSTALL_PROMPT=false
    INTERACTIVE=true
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dux)
                INSTALL_DUX=true
                INTERACTIVE=false
                shift
                ;;
            --prompt)
                INSTALL_PROMPT=true
                INTERACTIVE=false
                shift
                ;;
            --all)
                INSTALL_DUX=true
                INSTALL_PROMPT=true
                INTERACTIVE=false
                shift
                ;;
            -h|--help)
                echo "Usage: install.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --dux      Install dux binary (context switcher)"
                echo "  --prompt   Install dux-prompt (shell prompt)"
                echo "  --all      Install both components"
                echo "  -h, --help Show this help message"
                echo ""
                echo "Without options, runs interactive installer."
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Interactive mode if no flags provided
    if [[ "$INTERACTIVE" == "true" ]]; then
        show_interactive_menu
    fi
    
    # Validate selection
    if [[ "$INSTALL_DUX" == "false" && "$INSTALL_PROMPT" == "false" ]]; then
        print_error "No components selected for installation."
        exit 1
    fi
    
    # Install selected components
    if [[ "$INSTALL_DUX" == "true" ]]; then
        install_dux
        setup_completions
    fi
    
    if [[ "$INSTALL_PROMPT" == "true" ]]; then
        install_prompt
    fi
    
    # Show setup instructions
    show_setup_instructions
}

main "$@"
