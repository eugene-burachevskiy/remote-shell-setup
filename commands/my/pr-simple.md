---
description: 'Commit current changes and create a pull or merge request'
---

Commit the intended current changes, push the branch, and create a pull request
(PR) or merge request (MR).

## Prepare the change

1. Read the repository instructions and determine the remote hosting service.
2. Inspect `git status`, staged and unstaged diffs, untracked files, the current
   branch, the remote default branch, and recent commit subjects.
3. If the current branch is the default branch, create a focused topic branch.
4. Separate unrelated work. Stage only the intended files or hunks.
5. Run the narrowest checks that verify the change.

## Commit and push

1. Follow the repository commit convention when it exists.
2. Otherwise, use a capitalized imperative subject without a final period.
   Target 50 characters and never exceed 72 characters.
3. Separate an optional body with one blank line. Wrap it at 72 characters.
   Explain what changed and why, not implementation details visible in the diff.
4. Confirm the staged diff, then create the commit.
5. Integrate remote changes safely and push the topic branch. Never force-push.

## Create the change request

1. Use the repository PR or MR template when one exists.
2. Use `gh pr create` for GitHub. Use `glab mr create --push` for GitLab.
3. Write a concise, sentence-case title. Summarize the complete change request,
   not only its last commit.
4. Explain the problem, the change, the reason, verification, and important
   risks. Do not claim tests that did not run.

## Language standard

Use active voice, common words, and one term for each concept. Give each
sentence one idea. Keep instructions to 20 words and descriptions to 25 words
when practical. Use present tense, standard American English, and sentence-case
headings. Put conditions before instructions. Avoid idioms, vague pronouns,
unnecessary jargon, and filler.

Return the PR or MR URL and a short verification summary.
