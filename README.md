# Remote Shell Setup

One-command setup script for configuring a productive shell environment on remote Linux machines.

```bash
curl -fsSL https://raw.githubusercontent.com/eugene-burachevskiy/remote-shell-setup/main/setup.sh | bash
```

Then reload your shell:

```bash
source ~/.bashrc
```

## Overview

This script sets up a complete development environment with DevOps tools, colorful shell prompt with git integration, and opencode AI assistant with custom commands.

## Features

### Tools Installed

- **kubectl** 1.32.0 - Kubernetes command-line tool
- **AWS CLI** - Latest version for AWS management
- **helm** 4.0.1 - Kubernetes package manager
- **kubectx** - Fast Kubernetes context switching
- **kubens** - Fast Kubernetes namespace switching
- **kubecolor** - Colorized kubectl output
- **git** - Version control (verified/installed)
- **opencode** - AI-powered coding assistant

### Shell Configuration

- **Purple cyberpunk-themed prompt** with:
  - Purple bold user@hostname
  - Cyan current directory
  - Green git branch (when clean)
  - Yellow git branch (when dirty/uncommitted changes)
  - Simplified format: `[user@hostname:~/dir] (branch) $`

- **Convenient aliases**:
  - `k` → `kubecolor` (colorized kubectl)

### Opencode Custom Commands

The following custom commands are copied to `~/.config/opencode/commands/`:

- `code-review` - Comprehensive code review with structured feedback
- `learn` - Extract reusable patterns from sessions
- `onboarding-plan` - Create personalized team onboarding plans
- `pr-description` - Generate natural pull request descriptions
- `explain-code` - Detailed code explanations
- `commit-message` - Generate conventional commit messages

## Quick Start

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/remote-shell-setup/main/setup.sh | bash
```

Or with wget:

```bash
wget -qO- https://raw.githubusercontent.com/YOUR_USERNAME/remote-shell-setup/main/setup.sh | bash
```

### Manual Installation

1. Clone or download the repository:
```bash
git clone https://github.com/YOUR_USERNAME/remote-shell-setup.git
cd remote-shell-setup
```

2. Run the setup script:
```bash
./setup.sh
```

3. Start a new shell or source your `.bashrc`:
```bash
source ~/.bashrc
```

## Supported Operating Systems

- **Ubuntu** 18.04, 20.04, 22.04, 24.04+
- **Debian** 9, 10, 11, 12+
- **Oracle Linux** 7, 8, 9
- **CentOS/RHEL** 7, 8, 9
- **Amazon Linux** 2, 2023
- **Rocky Linux** / **AlmaLinux**
- **Fedora**

## Supported Architectures

- x86_64 (AMD64)
- ARM64 (AArch64)

## Configuration

Tool versions and settings can be customized in `config/versions.conf`:

```bash
# Tool Versions
KUBECTL_VERSION="1.32.0"
HELM_VERSION="4.0.1"
AWS_CLI_VERSION="latest"

# Installation Directories
INSTALL_DIR="${HOME}/.local/bin"

# Feature Flags
SKIP_KUBECTL=false
SKIP_AWS_CLI=false
# ... etc
```

## What the Script Does

1. **Detects Environment**
   - Identifies OS family (Debian/Ubuntu vs RHEL-based)
   - Detects system architecture
   - Identifies available package manager

2. **Installs Base Dependencies**
   - Uses apt, yum, or dnf to install curl, wget, tar, unzip, git if missing

3. **Installs DevOps Tools**
   - Downloads and installs kubectl 1.32.0
   - Installs AWS CLI latest
   - Installs helm 4.0.1
   - Installs kubectx and kubens
   - Installs kubecolor
   - Installs opencode
   - **Skips** any tools already installed (idempotent)

4. **Configures Shell**
   - Backs up existing `.bashrc`
   - Adds `~/.local/bin` to PATH
   - Configures purple cyberpunk prompt with git integration
   - Adds `k` alias for kubecolor

5. **Sets Up Opencode**
   - Copies custom commands to `~/.config/opencode/commands/`

## Prompt Preview

When in a git repository with uncommitted changes:
```
[user@hostname:~/project] (main) $ 
 ↑purple   ↑cyan      ↑yellow (dirty branch)
```

When in a clean git repository:
```
[user@hostname:~/project] (main) $ 
 ↑purple   ↑cyan      ↑green (clean branch)
```

## Verification

After installation, verify everything is working:

```bash
# Check all tools
kubectl version --client
aws --version
helm version
kubectx --version
kubens --version
kubecolor --version
git --version
opencode --version

# Test the alias
k version --client  # Should show colorized output

# Check prompt colors
# Start a new shell and navigate to a git repo
bash
cd /path/to/git/repo
```

## Directory Structure

```
remote-shell-setup/
├── setup.sh              # Main installation script
├── config/
│   └── versions.conf     # Tool versions configuration
├── commands/             # Opencode custom commands
│   ├── code-review.md
│   ├── learn.md
│   ├── onboarding-plan.md
│   ├── pr-description.md
│   ├── explain-code.md
│   └── commit-message.md
├── docs/                 # AI DevKit documentation
│   └── ai/
│       ├── requirements/
│       ├── design/
│       ├── planning/
│       ├── implementation/
│       └── testing/
└── README.md
```

## Idempotency

The script is safe to run multiple times:
- Already installed tools are skipped
- No duplicate entries in `.bashrc`
- Configuration remains functional

## Troubleshooting

### Tools not found after installation

Start a new shell or source `.bashrc`:
```bash
source ~/.bashrc
```

### Permission denied errors

The script prefers user-level installations. If you see permission errors:
- Ensure `~/.local/bin` is in your PATH
- The script will add it to `.bashrc` automatically

### Git branch not showing

Ensure you're in a git repository:
```bash
cd /path/to/git/repo
```

### AWS CLI installation fails

Ensure `unzip` is installed:
```bash
# Ubuntu/Debian
sudo apt-get install unzip

# RHEL/Oracle Linux/CentOS
sudo yum install unzip
# or
sudo dnf install unzip
```

## Requirements

- Bash 4.0+
- curl or wget
- Internet connection
- Sudo access (for installing base dependencies via package manager)
- ~500MB free disk space

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Acknowledgments

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [helm](https://helm.sh/)
- [kubectx](https://github.com/ahmetb/kubectx)
- [kubecolor](https://kubecolor.github.io/)
- [opencode](https://opencode.ai)
