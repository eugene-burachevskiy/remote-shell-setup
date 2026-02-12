---
phase: requirements
title: Remote Shell Setup - Requirements & Problem Understanding
description: Clarify the problem space, gather requirements, and define success criteria for the remote shell setup script
---

# Remote Shell Setup - Requirements

## Problem Statement

**What problem are we solving?**

When working on new remote machines (VMs, cloud instances, or fresh installations), developers waste significant time manually configuring their shell environment and installing essential tools. The current workflow requires:
- Manually editing `.bashrc` to customize the prompt
- Installing each tool individually (kubectl, AWS CLI, helm, etc.)
- Configuring aliases and shell preferences
- Setting up opencode with custom commands

**Who is affected by this problem?**

- Developers who frequently work on new remote machines
- DevOps engineers managing multiple cloud instances
- Anyone needing a standardized development environment quickly

**What is the current situation/workaround?**

Currently, developers must:
1. SSH into the remote machine
2. Install tools one by one using various package managers or curl commands
3. Manually configure shell prompts and aliases
4. Copy configuration files from other machines

This process is repetitive, error-prone, and takes 30+ minutes per machine.

## Goals & Objectives

**What do we want to achieve?**

### Primary Goals

1. **One-command setup**: Allow users to run `curl ... | bash` and have their complete shell environment ready
2. **Idempotent installations**: Skip tools that are already installed (even if older versions exist)
3. **Purple cyberpunk-themed prompt**: Customize bash prompt with purple colors and git branch display
4. **Essential DevOps tools**: Install kubectl 1.32, AWS CLI latest, helm 4.0.1, kubectx, kubens, kubecolor, and git
5. **Convenient aliases**: Set up `k="kubecolor"` alias
6. **Opencode integration**: Install opencode and copy custom commands

### Secondary Goals

1. **Cross-platform support**: Work on major Linux distributions (Ubuntu, Debian, Oracle Linux, CentOS/RHEL, Amazon Linux)
2. **OS-aware installation**: Detect OS type and use appropriate installation methods when possible
3. **Minimal dependencies**: Use standard shell tools (bash, curl, grep, etc.)
4. **Clear output**: Provide progress indication and status messages
5. **Safe execution**: Don't break existing configurations

### Non-Goals (Out of Scope)

1. Windows support (Windows Subsystem for Linux can be supported)
2. macOS-specific configurations
3. GUI tool installations
4. Docker daemon setup
5. Kubernetes cluster creation
6. Cloud provider authentication configuration

## User Stories & Use Cases

**How will users interact with the solution?**

### Primary User Story

```
As a developer who just SSH'd into a new cloud instance,
I want to run a single command to set up my shell environment,
So that I can immediately start working with opencode, kubectl, AWS CLI, and other tools.
```

### Secondary User Stories

```
As a DevOps engineer managing multiple VMs,
I want to standardize my shell environment across all machines,
So that I have a consistent experience regardless of which machine I'm on.
```

```
As a developer with a monochrome bash prompt,
I want a colorful, cyberpunk-themed prompt with git branch info,
So that my terminal is visually appealing and shows useful context.
```

```
As a user with some tools already installed,
I want the script to skip those tools,
So that I don't waste time or risk breaking existing installations.
```

```
As a developer working on different Linux distributions,
I want the script to detect my OS and use appropriate installation methods,
So that the setup works correctly on Oracle Linux, Ubuntu, Debian, and other distros.
```

### Key Workflows

1. **Initial Setup**: User runs `curl <url> | bash` on a fresh machine
2. **Verification**: User runs common commands (kubectl, aws, helm) to verify installation
3. **Prompt Verification**: User checks that their prompt shows colors and git branch info

### Edge Cases

1. **Partial installations**: Some tools already exist, others don't
2. **Network failures**: Handle cases where downloads fail
3. **Permission issues**: Handle cases where user lacks sudo access
4. **Different architectures**: Support both x86_64 and ARM64
5. **Existing .bashrc customizations**: Don't overwrite user's existing settings

## Success Criteria

**How will we know when we're done?**

### Measurable Outcomes

1. **Setup Time**: Complete setup in under 5 minutes on a fresh VM
2. **Tool Verification**: All required tools respond to `--version` or `-v` commands
3. **Prompt Display**: Bash prompt shows purple colors and git branch when in a git repository
4. **Alias Functionality**: `k get pods` works as `kubecolor get pods`
5. **Opencode Commands**: Custom commands are available and functional

### Acceptance Criteria

- [ ] Script can be executed via `curl | bash` pattern
- [ ] Script exits with code 0 on successful completion
- [ ] Script displays clear progress messages during execution
- [ ] kubectl 1.32 is installed and functional
- [ ] AWS CLI latest version is installed
- [ ] helm 4.0.1 is installed
- [ ] kubectx and kubens are installed
- [ ] kubecolor is installed
- [ ] git is verified to be installed
- [ ] opencode is installed
- [ ] Custom opencode commands are copied to ~/.config/opencode/commands/
- [ ] Purple cyberpunk-themed prompt is configured in ~/.bashrc
- [ ] Git branch is displayed in prompt when inside a git repository
- [ ] `k` alias is set to `kubecolor` in ~/.bashrc
- [ ] Existing tools are skipped (not reinstalled)
- [ ] OS detection works correctly (Ubuntu/Debian vs RHEL-based)
- [ ] Distribution-specific installation methods are used when available

### Performance Benchmarks

- Script execution time: < 5 minutes on a machine with decent internet connection
- No manual intervention required during execution
- Idempotent: Running the script twice produces the same result as running once

## Constraints & Assumptions

**What limitations do we need to work within?**

### Technical Constraints

1. **Target OS**: Linux distributions (Ubuntu 18.04+, Debian 9+, Oracle Linux 7+, CentOS/RHEL 7+, Amazon Linux 2+)
2. **OS Detection**: Must detect OS type (Ubuntu/Debian vs RHEL-based) and adjust installation methods
3. **Shell**: Bash (version 4.0+)
4. **Architecture**: x86_64 and ARM64 support
5. **Internet**: Requires internet connection for downloading tools
6. **Permissions**: May require sudo for system-wide installations

### Business Constraints

1. **No local testing**: User will test on remote machines only
2. **No root requirement preference**: Should work without root if possible

### Assumptions

1. User has basic bash knowledge
2. User has internet access on the target machine
3. User has curl or wget installed
4. Target machine has sufficient disk space (~500MB for all tools)
5. User will source ~/.bashrc or start a new shell after setup

### Dependencies

- curl or wget for downloads
- tar for extracting archives
- git (usually pre-installed on most systems)
- standard POSIX utilities (grep, sed, awk, etc.)

## Questions & Open Items

**What do we still need to clarify?**

### Resolved Questions

1. **Q**: Which opencode custom commands should be included?
   **A**: code-review, learn, onboarding-plan, pr-description, explain-code, commit-message

2. **Q**: Should we upgrade existing tools if they're older versions?
   **A**: No, skip if tool exists regardless of version

3. **Q**: Should the script require root/sudo?
   **A**: Prefer user-level installations; use sudo only when necessary

4. **Q**: What's the preferred installation method for tools?
   **A**: Official binary releases via curl when available

### Implementation Notes

1. Tool installation order matters (kubectl before kubecolor)
2. Backup existing .bashrc before modifications
3. Add clear markers around script-added sections for easy identification
4. Support both AMD64 and ARM64 architectures automatically
5. Use official installation methods from each tool's documentation
6. Detect OS family (Debian/Ubuntu vs RHEL-based) for distribution-specific handling
7. Use package managers (apt, yum, dnf) for base dependencies when appropriate
8. Oracle Linux detection should map to RHEL-based handling
