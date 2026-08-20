---

description: 'AI-powered code review using ocr CLI with structured feedback'

---

## Task

Review the code changes by:

1. Run `git diff` to review uncommitted changes.
2. For branch changes, identify the remote default branch and compare it with
   `HEAD`.
3. Follow the review target that the user provides, such as a commit, branch,
   merge request (MR), or pull request (PR).
4. Use `glab` for a GitLab MR. Use `gh` for a GitHub PR.
5. Provide structured, actionable feedback.

## Review Process

Use the **open-code-review** skill to perform the review:

1. Load the `open-code-review` skill
2. Follow its workflow: prerequisites check, gather business context, run `ocr review --audience agent`, and collect results
3. Take the raw ocr output and reformat it according to the output format below

## Output Format

Present the review results in this structure:

### ✅ Strengths

List what's done well in the changes. Be specific — highlight good patterns, clean abstractions, proper error handling, or any other positive aspects worth acknowledging.

### ⚠️ Issues Found

Take all ocr review comments and format each one as:

- **Severity**: 🔴 Critical | 🟡 Medium | 🔵 Low
- **Location**: File path and line numbers
- **Problem**: Clear description of the issue
- **Suggestion**: Specific fix with code example (use ocr's `suggestion_code` when available)
- **Rationale**: Why this matters

Group issues by severity, starting with 🔴 Critical.

### 🔧 Refactoring Opportunities

Beyond the issues above, identify optional improvements that would enhance code quality — better abstractions, reduced duplication, improved naming, or structural improvements.

### 📚 Learning Resources

Relevant documentation, best practices, or patterns that would help address the issues found (if applicable).

### Summary

Overall assessment: how many files reviewed, total issues by severity, and recommended next steps.

## Guidelines

- Be constructive and educational
- Prioritize issues by severity
- Always explain *why* something is an issue
- Include code examples for suggestions whenever possible
- If ocr produces no issues, acknowledge the clean review and note any strengths
