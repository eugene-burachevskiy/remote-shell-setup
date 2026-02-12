---
phase: testing
title: Remote Shell Setup - Testing Strategy & Test Cases
description: Define testing approach, test cases, and validation procedures for the remote shell setup script
---

# Remote Shell Setup - Testing

## Testing Strategy

**Overall Approach**: Manual testing on remote machines

Since the user will test on their remote machines, we focus on:
1. **Manual Testing Checklist**: Comprehensive step-by-step verification
2. **Test Scenarios**: Different OS and environment combinations
3. **Verification Commands**: Specific commands to validate each component
4. **Troubleshooting Guide**: Common issues and solutions

## Test Environments

**Supported Target Environments**:

| OS | Version | Architecture | Priority |
|----|---------|--------------|----------|
| Ubuntu | 20.04, 22.04, 24.04 | x86_64 | High |
| Ubuntu | 20.04, 22.04 | ARM64 | Medium |
| Debian | 11, 12 | x86_64 | High |
| Oracle Linux | 7, 8, 9 | x86_64 | High |
| CentOS/RHEL | 7, 8, 9 | x86_64 | Medium |
| Amazon Linux | 2, 2023 | x86_64 | Medium |

## Manual Testing Checklist

### Pre-Installation Checks

- [ ] Target machine is accessible via SSH
- [ ] Internet connection is available
- [ ] `curl` or `wget` is installed
- [ ] Sudo access is available (for package manager operations)
- [ ] At least 500MB free disk space

### Installation Execution

- [ ] Run: `curl -fsSL <script-url> | bash`
- [ ] Script starts without errors
- [ ] OS detection displays correct distribution
- [ ] Progress messages are clear and informative
- [ ] Each tool installation shows status (installing/skipped)
- [ ] No errors during tool installations
- [ ] Script completes with success message
- [ ] Script exit code is 0: `echo $?` returns `0`

### OS-Specific Validation

- [ ] **Ubuntu/Debian**: apt-get update runs successfully
- [ ] **Ubuntu/Debian**: Base dependencies installed via apt
- [ ] **RHEL/Oracle Linux**: yum/dnf available and working
- [ ] **RHEL/Oracle Linux**: Base dependencies installed via yum/dnf
- [ ] **Oracle Linux**: Correctly detected as RHEL-based

### Tool Verification

#### kubectl

- [ ] Run: `kubectl version --client`
- [ ] Output shows version 1.32.x
- [ ] No errors in output
- [ ] Command is in PATH

**Expected Output**:
```
Client Version: v1.32.0
Kustomize Version: v5.x.x
```

#### AWS CLI

- [ ] Run: `aws --version`
- [ ] Output shows version 2.x
- [ ] No errors in output
- [ ] Command is in PATH

**Expected Output**:
```
aws-cli/2.x.x Python/3.x.x Linux/x86_64
```

#### helm

- [ ] Run: `helm version`
- [ ] Output shows version 4.0.1
- [ ] No errors in output
- [ ] Command is in PATH

**Expected Output**:
```
version.BuildInfo{Version:"v4.0.1", ...}
```

#### kubectx

- [ ] Run: `kubectx --version`
- [ ] Output shows version
- [ ] Run: `kubectx` (lists contexts or shows "no contexts")
- [ ] No errors in output

**Expected Output**:
```
0.9.x
```

#### kubens

- [ ] Run: `kubens --version`
- [ ] Output shows version
- [ ] Run: `kubens` (lists namespaces or shows "no contexts")
- [ ] No errors in output

#### kubecolor

- [ ] Run: `kubecolor --version`
- [ ] Output shows version
- [ ] Command is in PATH

#### git

- [ ] Run: `git --version`
- [ ] Output shows version 2.x
- [ ] No errors in output

#### opencode

- [ ] Run: `opencode --version`
- [ ] Output shows version
- [ ] Command is in PATH

### Shell Configuration Verification

#### Prompt Styling

- [ ] Start a new bash shell: `bash`
- [ ] Prompt shows purple/cyberpunk colors
- [ ] User@hostname is displayed in purple
- [ ] Current directory is displayed in cyan
- [ ] Prompt symbol is displayed

**Expected Appearance**:
- Purple colored text for user and hostname
- Cyan colored text for current directory
- Bold formatting for emphasis

#### Git Integration

- [ ] Navigate to a git repository: `cd /path/to/repo`
- [ ] Prompt displays git branch name
- [ ] Git branch name is colored (green for clean, yellow/red for dirty)
- [ ] Navigate out of repository: `cd ~`
- [ ] Git branch info disappears from prompt

**Expected Output Example**:
```
[user@hostname:~/project] (main) $
```

#### Alias Verification

- [ ] Run: `alias k`
- [ ] Output shows: `alias k='kubecolor'`
- [ ] Run: `k version --client`
- [ ] Should show kubectl version output with colors
- [ ] Output should be colorized

### Opencode Commands Verification

- [ ] Check commands directory: `ls -la ~/.config/opencode/commands/`
- [ ] Following files exist:
  - [ ] `code-review.md`
  - [ ] `learn.md`
  - [ ] `onboarding-plan.md`
  - [ ] `pr-description.md`
  - [ ] `explain-code.md`
  - [ ] `commit-message.md`

### BashRC Backup

- [ ] Check for backup file: `ls -la ~/.bashrc.backup.*`
- [ ] Backup file exists with timestamp
- [ ] Backup contains original configuration

### Idempotency Test

- [ ] Run the setup script a second time
- [ ] Script should report skipping already installed tools
- [ ] No duplicate entries in ~/.bashrc
- [ ] Script completes successfully
- [ ] Configuration remains functional

### Edge Case Testing

#### Partial Installations

- [ ] Test on machine with some tools already installed
- [ ] Script should skip existing tools
- [ ] Install missing tools only
- [ ] No errors during execution

#### No Sudo Access

- [ ] Test on machine without sudo
- [ ] Script should attempt user-level installations
- [ ] Should work for binary-based tools
- [ ] Package manager operations should fail gracefully

#### Slow Connection

- [ ] Test with slow/intermittent connection
- [ ] Retry logic should work
- [ ] Script should handle timeouts gracefully

## Test Scenarios

### Scenario 1: Fresh Ubuntu 22.04 VM

**Setup**: Fresh Ubuntu 22.04 installation with only curl installed

**Steps**:
1. SSH into VM
2. Run: `curl -fsSL <url> | bash`
3. Follow testing checklist

**Expected Result**: All tools installed, prompt configured

### Scenario 2: Oracle Linux 8 with Some Tools

**Setup**: Oracle Linux 8 with kubectl and git pre-installed

**Steps**:
1. Verify OS detected as RHEL-based
2. Run setup script
3. Verify kubectl and git skipped
4. Verify other tools installed

**Expected Result**: Skips existing, installs missing

### Scenario 3: Debian 12 Minimal

**Setup**: Minimal Debian 12 installation

**Steps**:
1. Run setup script
2. Verify apt is used for base dependencies
3. Verify all tools installed

**Expected Result**: Full installation successful

### Scenario 4: Re-run on Already Configured Machine

**Setup**: Machine already configured by script

**Steps**:
1. Run setup script again
2. Verify all tools skipped
3. Verify no duplicate .bashrc entries
4. Verify configuration still works

**Expected Result**: Idempotent behavior

## Verification Commands

### Quick Verification

Run these commands to quickly verify everything:

```bash
# Check all tools
echo "=== kubectl ===" && kubectl version --client
echo "=== AWS CLI ===" && aws --version
echo "=== helm ===" && helm version
echo "=== kubectx ===" && kubectx --version
echo "=== kubens ===" && kubens --version
echo "=== kubecolor ===" && kubecolor --version
echo "=== git ===" && git --version
echo "=== opencode ===" && opencode --version

# Check alias
echo "=== Alias ===" && alias k

# Check prompt (start new shell)
bash
echo "Prompt should be colorful now"
```

### Detailed Verification

```bash
# Check all binaries are in PATH
which kubectl aws helm kubectx kubens kubecolor git opencode

# Check .bashrc modifications
grep -n "REMOTE-SHELL-SETUP" ~/.bashrc

# Check backup exists
ls -la ~/.bashrc.backup.*

# Check opencode commands
ls -la ~/.config/opencode/commands/
```

## Troubleshooting Guide

### Issue: "Command not found" after installation

**Cause**: Binary directory not in PATH

**Solution**:
```bash
# Add to .bashrc manually or source it
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc
```

### Issue: Permission denied during installation

**Cause**: No sudo access for package manager

**Solution**:
- Script should fall back to user-level binary installs
- For base dependencies, install manually: `sudo apt-get install curl wget tar unzip`

### Issue: Download timeouts

**Cause**: Slow or unstable connection

**Solution**:
- Script has built-in retry logic
- Check internet connection: `ping google.com`
- Try running script again

### Issue: Git branch not showing in prompt

**Cause**: parse_git_branch function not loaded

**Solution**:
```bash
# Start a new shell
bash

# Or source .bashrc
source ~/.bashrc
```

### Issue: Colors not showing correctly

**Cause**: Terminal doesn't support colors or TERM variable not set

**Solution**:
```bash
# Check terminal support
echo $TERM

# Set if needed
export TERM=xterm-256color
```

### Issue: AWS CLI installation fails

**Cause**: unzip not installed or permission issues

**Solution**:
```bash
# Install unzip
sudo apt-get install unzip  # Debian/Ubuntu
sudo yum install unzip      # RHEL/Oracle Linux
```

### Issue: Oracle Linux not detected correctly

**Cause**: OS detection logic needs adjustment

**Solution**:
- Check /etc/os-release: `cat /etc/os-release`
- Report ID and ID_LIKE values
- Script should handle ol, oraclelinux IDs

## Success Criteria Verification

Verify all acceptance criteria are met:

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

## Test Results Template

Use this template to record test results:

```markdown
## Test Run: [Date]

### Environment
- OS: 
- Version: 
- Architecture: 
- Cloud Provider: 

### Results
- [ ] Installation completed successfully
- [ ] All tools installed
- [ ] Prompt configured correctly
- [ ] Git integration working
- [ ] Alias functional
- [ ] Opencode commands present

### Issues Found
1. 
2. 

### Notes

```

## Sign-Off

**Testing Completed By**: 
**Date**: 
**Result**: [ ] Pass / [ ] Fail / [ ] Partial

**Known Issues**: 

**Approved for Release**: [ ] Yes / [ ] No
