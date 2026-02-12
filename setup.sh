#!/bin/bash
#
# Remote Shell Setup Script
# One-command setup for remote development environment
# Usage: curl -fsSL <url> | bash
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration - can be overridden via environment variables
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
KUBECTL_VERSION="${KUBECTL_VERSION:-1.32.0}"
HELM_VERSION="${HELM_VERSION:-4.0.1}"
TEMP_DIR="$(mktemp -d)"

# Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Detect OS family
detect_os_family() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                echo "debian"
                ;;
            rhel|centos|fedora|rocky|almalinux|ol|oraclelinux|amzn)
                echo "rhel"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Detect architecture
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "amd64"  # Default to amd64
            ;;
    esac
}

# Get package manager
get_package_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    else
        echo "none"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check for curl or wget
    if ! command_exists curl && ! command_exists wget; then
        log_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    # Check for tar
    if ! command_exists tar; then
        log_warning "tar not found. Will attempt to install..."
        install_base_dependencies
    fi
    
    # Check for unzip (needed for AWS CLI)
    if ! command_exists unzip; then
        log_warning "unzip not found. Will attempt to install..."
        install_base_dependencies
    fi
    
    log_success "Prerequisites check passed"
}

# Install base dependencies using package manager
install_base_dependencies() {
    log_step "Installing base dependencies..."
    
    local pkg_mgr=$(get_package_manager)
    
    case "$pkg_mgr" in
        apt)
            log_info "Using apt to install dependencies..."
            if command_exists sudo; then
                sudo apt-get update -qq
                sudo apt-get install -y -qq curl wget tar unzip git
            else
                log_warning "sudo not available. Please install manually: apt-get install curl wget tar unzip git"
            fi
            ;;
        dnf)
            log_info "Using dnf to install dependencies..."
            if command_exists sudo; then
                sudo dnf install -y curl wget tar unzip git
            else
                log_warning "sudo not available. Please install manually: dnf install curl wget tar unzip git"
            fi
            ;;
        yum)
            log_info "Using yum to install dependencies..."
            if command_exists sudo; then
                sudo yum install -y curl wget tar unzip git
            else
                log_warning "sudo not available. Please install manually: yum install curl wget tar unzip git"
            fi
            ;;
        *)
            log_warning "No supported package manager found. Ensure curl, wget, tar, unzip, and git are installed."
            ;;
    esac
}

# Download helper
download() {
    local url="$1"
    local output="$2"
    
    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        log_error "No download tool available"
        return 1
    fi
}

# Install kubectl
install_kubectl() {
    if command_exists kubectl; then
        log_info "kubectl already installed, skipping..."
        return 0
    fi
    
    log_step "Installing kubectl ${KUBECTL_VERSION}..."
    
    local arch=$(detect_arch)
    local url="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${arch}/kubectl"
    
    download "$url" "${TEMP_DIR}/kubectl"
    chmod +x "${TEMP_DIR}/kubectl"
    mkdir -p "$INSTALL_DIR"
    mv "${TEMP_DIR}/kubectl" "$INSTALL_DIR/"
    
    log_success "kubectl installed"
}

# Install AWS CLI
install_aws_cli() {
    if command_exists aws; then
        log_info "AWS CLI already installed, skipping..."
        return 0
    fi
    
    log_step "Installing AWS CLI..."
    
    local arch=$(uname -m)
    local url="https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip"
    
    cd "$TEMP_DIR"
    download "$url" "awscliv2.zip"
    unzip -q awscliv2.zip
    
    if command_exists sudo; then
        sudo ./aws/install --bin-dir "$INSTALL_DIR" --install-dir "$HOME/.local/aws-cli" --update 2>/dev/null || \
        ./aws/install --bin-dir "$INSTALL_DIR" --install-dir "$HOME/.local/aws-cli" --update
    else
        ./aws/install --bin-dir "$INSTALL_DIR" --install-dir "$HOME/.local/aws-cli" --update
    fi
    
    cd - >/dev/null
    log_success "AWS CLI installed"
}

# Install helm
install_helm() {
    if command_exists helm; then
        log_info "helm already installed, skipping..."
        return 0
    fi
    
    log_step "Installing helm ${HELM_VERSION}..."
    
    local arch=$(detect_arch)
    local url="https://get.helm.sh/helm-v${HELM_VERSION}-linux-${arch}.tar.gz"
    
    cd "$TEMP_DIR"
    download "$url" "helm.tar.gz"
    tar -xzf helm.tar.gz
    
    mkdir -p "$INSTALL_DIR"
    mv "linux-${arch}/helm" "$INSTALL_DIR/"
    
    cd - >/dev/null
    log_success "helm installed"
}

# Install kubectx and kubens
install_kubectx_kubens() {
    local kubectx_exists=$(command_exists kubectx && echo "yes" || echo "no")
    local kubens_exists=$(command_exists kubens && echo "yes" || echo "no")
    
    if [ "$kubectx_exists" = "yes" ] && [ "$kubens_exists" = "yes" ]; then
        log_info "kubectx and kubens already installed, skipping..."
        return 0
    fi
    
    log_step "Installing kubectx and kubens..."
    
    mkdir -p "$INSTALL_DIR"
    
    # Get latest release URL
    local base_url="https://github.com/ahmetb/kubectx/releases/latest/download"
    
    if [ "$kubectx_exists" = "no" ]; then
        download "${base_url}/kubectx" "${TEMP_DIR}/kubectx"
        chmod +x "${TEMP_DIR}/kubectx"
        mv "${TEMP_DIR}/kubectx" "$INSTALL_DIR/"
        log_success "kubectx installed"
    fi
    
    if [ "$kubens_exists" = "no" ]; then
        download "${base_url}/kubens" "${TEMP_DIR}/kubens"
        chmod +x "${TEMP_DIR}/kubens"
        mv "${TEMP_DIR}/kubens" "$INSTALL_DIR/"
        log_success "kubens installed"
    fi
}

# Install kubecolor
install_kubecolor() {
    if command_exists kubecolor; then
        log_info "kubecolor already installed, skipping..."
        return 0
    fi
    
    log_step "Installing kubecolor..."
    
    local arch=$(detect_arch)
    
    # Get latest release info
    local latest_url="https://api.github.com/repos/hidetatz/kubecolor/releases/latest"
    local download_url
    
    if command_exists curl; then
        download_url=$(curl -s "$latest_url" | grep -o "browser_download_url.*linux-${arch}.*tar.gz" | cut -d'"' -f4)
    elif command_exists wget; then
        download_url=$(wget -qO- "$latest_url" | grep -o "browser_download_url.*linux-${arch}.*tar.gz" | cut -d'"' -f4)
    fi
    
    if [ -z "$download_url" ]; then
        # Fallback to direct binary download
        download_url="https://github.com/hidetatz/kubecolor/releases/latest/download/kubecolor"
        download "$download_url" "${TEMP_DIR}/kubecolor"
    else
        download "$download_url" "${TEMP_DIR}/kubecolor.tar.gz"
        tar -xzf "${TEMP_DIR}/kubecolor.tar.gz" -C "$TEMP_DIR"
    fi
    
    chmod +x "${TEMP_DIR}/kubecolor"
    mkdir -p "$INSTALL_DIR"
    mv "${TEMP_DIR}/kubecolor" "$INSTALL_DIR/"
    
    log_success "kubecolor installed"
}

# Verify git
verify_git() {
    if command_exists git; then
        log_info "git is installed: $(git --version)"
    else
        log_warning "git not found. Attempting to install..."
        install_base_dependencies
        if command_exists git; then
            log_success "git installed"
        else
            log_error "Failed to install git. Please install manually."
            exit 1
        fi
    fi
}

# Install opencode
install_opencode() {
    if command_exists opencode; then
        log_info "opencode already installed, skipping..."
        return 0
    fi
    
    log_step "Installing opencode..."
    
    # Run official installer
    if command_exists curl; then
        curl -fsSL https://opencode.ai/install.sh | bash
    elif command_exists wget; then
        wget -qO- https://opencode.ai/install.sh | bash
    fi
    
    log_success "opencode installed"
}

# Configure shell
configure_shell() {
    log_step "Configuring shell..."
    
    # Backup .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.bashrc" "$backup_file"
        log_info "Backed up .bashrc to $backup_file"
    fi
    
    # Add PATH if not present
    if ! grep -q "$INSTALL_DIR" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Add local bin to PATH" >> "$HOME/.bashrc"
        echo 'export PATH="'$INSTALL_DIR':$PATH"' >> "$HOME/.bashrc"
        log_info "Added $INSTALL_DIR to PATH"
    fi
    
    # Add custom prompt configuration
    if ! grep -q "REMOTE-SHELL-SETUP" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" << 'EOF'

# === REMOTE-SHELL-SETUP START ===
# Custom prompt with git branch support

# Colors
PURPLE='\[\e[35m\]'
CYAN='\[\e[36m\]'
GREEN='\[\e[32m\]'
YELLOW='\[\e[33m\]'
RESET='\[\e[0m\]'
BOLD='\[\e[1m\]'

# Function to get git branch with color based on status
parse_git_branch() {
    local branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ -n "$branch" ]; then
        # Check if working tree is dirty
        if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
            # Clean - green
            echo "(${GREEN}${branch}${RESET})"
        else
            # Dirty - yellow
            echo "(${YELLOW}${branch}${RESET})"
        fi
    fi
}

# Simplified PS1 with purple cyberpunk theme
PS1="${PURPLE}\u@\h${RESET}:${CYAN}\w${RESET} \$(parse_git_branch)$ "

# Alias k to kubecolor
alias k='kubecolor'

# === REMOTE-SHELL-SETUP END ===
EOF
        log_success "Shell configured with purple cyberpunk theme"
    else
        log_info "Shell already configured, skipping..."
    fi
}

# Setup opencode custom commands
setup_opencode_commands() {
    log_step "Setting up opencode custom commands..."
    
    local commands_dir="$HOME/.config/opencode/commands"
    mkdir -p "$commands_dir"
    
    # Get the directory where this script is located
    local script_dir
    if command_exists dirname; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        log_warning "Cannot determine script directory. Skipping opencode commands setup."
        return 0
    fi
    
    # Copy custom commands if they exist in the repo
    if [ -d "$script_dir/commands" ]; then
        cp "$script_dir/commands/"*.md "$commands_dir/" 2>/dev/null || true
        log_success "Opencode custom commands copied"
    else
        log_info "No custom commands directory found in repo"
    fi
}

# Main function
main() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Remote Shell Setup - Developer Edition             ║"
    echo "║                                                            ║"
    echo "║   Setting up your shell with:                              ║"
    echo "║   • kubectl 1.32, AWS CLI, helm 4.0.1                      ║"
    echo "║   • kubectx, kubens, kubecolor                             ║"
    echo "║   • Purple cyberpunk prompt with git integration           ║"
    echo "║   • opencode with custom commands                          ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Detect environment
    local os_family=$(detect_os_family)
    local arch=$(detect_arch)
    local pkg_mgr=$(get_package_manager)
    
    log_info "Detected OS family: $os_family"
    log_info "Detected architecture: $arch"
    log_info "Package manager: $pkg_mgr"
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Check and install prerequisites
    check_prerequisites
    
    # Install tools
    install_kubectl
    install_aws_cli
    install_helm
    install_kubectx_kubens
    install_kubecolor
    verify_git
    install_opencode
    
    # Configure shell
    configure_shell
    
    # Setup opencode commands
    setup_opencode_commands
    
    # Summary
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete!                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log_info "Installed tools:"
    command_exists kubectl && echo "  ✓ kubectl $(kubectl version --client -o yaml 2>/dev/null | grep gitVersion | head -1 | awk '{print $2}')" || echo "  ✗ kubectl"
    command_exists aws && echo "  ✓ $(aws --version 2>&1 | cut -d' ' -f1)" || echo "  ✗ aws-cli"
    command_exists helm && echo "  ✓ helm $(helm version --short 2>/dev/null)" || echo "  ✗ helm"
    command_exists kubectx && echo "  ✓ kubectx" || echo "  ✗ kubectx"
    command_exists kubens && echo "  ✓ kubens" || echo "  ✗ kubens"
    command_exists kubecolor && echo "  ✓ kubecolor" || echo "  ✗ kubecolor"
    command_exists git && echo "  ✓ $(git --version)" || echo "  ✗ git"
    command_exists opencode && echo "  ✓ opencode" || echo "  ✗ opencode"
    
    echo ""
    log_info "Next steps:"
    echo "  1. Start a new shell or run: source ~/.bashrc"
    echo "  2. Try: k get pods (alias for kubecolor)"
    echo "  3. Navigate to a git repo to see the colorful prompt"
    echo ""
    log_info "Your prompt will show:"
    echo "  - Purple: user@hostname"
    echo "  - Cyan: current directory"
    echo "  - Green: clean git branch"
    echo "  - Yellow: dirty git branch (uncommitted changes)"
}

# Run main function
main "$@"
