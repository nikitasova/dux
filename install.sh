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
REPO_URL="https://raw.githubusercontent.com/nikitasova/dux/main"
INSTALL_DIR="$HOME/.dux"

print_banner() {
    echo -e "${BLUE}"
    echo "  ┌─────────────────────────────────────┐"
    echo "  │         dux installer               │"
    echo "  │   Docker Use Context - like kubectx │"
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

install_dux() {
    print_info "Installing dux (context switcher)..."
    curl -fsSL "$REPO_URL/cmd/dux.sh" -o "$INSTALL_DIR/dux.sh"
    chmod +x "$INSTALL_DIR/dux.sh"
    print_success "dux installed to $INSTALL_DIR/dux.sh"
}

install_prompt() {
    print_info "Installing dux-prompt (shell prompt)..."
    curl -fsSL "$REPO_URL/cmd/dux-prompt.sh" -o "$INSTALL_DIR/dux-prompt.sh"
    chmod +x "$INSTALL_DIR/dux-prompt.sh"
    print_success "dux-prompt installed to $INSTALL_DIR/dux-prompt.sh"
}

show_setup_instructions() {
    local shell_rc=$(get_shell_rc)
    local shell_type=$(detect_shell)
    
    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo "Add the following to your ${YELLOW}$shell_rc${NC}:"
    echo ""
    
    if [[ "$INSTALL_DUX" == "true" ]]; then
        echo -e "${BLUE}# dux - Docker context switcher${NC}"
        echo "source ~/.dux/dux.sh"
        echo ""
    fi
    
    if [[ "$INSTALL_PROMPT" == "true" ]]; then
        echo -e "${BLUE}# dux-prompt - Docker context in prompt${NC}"
        echo "source ~/.dux/dux-prompt.sh"
        
        if [[ "$shell_type" == "zsh" ]]; then
            echo 'PROMPT='\''$(docker_ps1) '\''$PROMPT'
            echo "# Or use with spacing: "'RPROMPT='\''$(docker_ps1_with_spacing)'\'''
        else
            echo 'PS1='\''$(docker_ps1) '\''$PS1'
        fi
        echo ""
    fi
    
    echo "Then reload your shell:"
    echo -e "  ${YELLOW}source $shell_rc${NC}"
    echo ""
}

show_interactive_menu() {
    echo "What would you like to install?"
    echo ""
    echo "  1) dux          - Docker context switcher command"
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
                echo "  --dux      Install dux (context switcher)"
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
    
    # Create install directory
    print_info "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    
    # Install selected components
    if [[ "$INSTALL_DUX" == "true" ]]; then
        install_dux
    fi
    
    if [[ "$INSTALL_PROMPT" == "true" ]]; then
        install_prompt
    fi
    
    # Show setup instructions
    show_setup_instructions
}

main "$@"

