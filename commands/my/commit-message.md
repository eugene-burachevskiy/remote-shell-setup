---
description: 'Write a Git commit message from staged changes'
---

Write a commit message for the staged changes. Do not create the commit.

## Inspect the change

1. Run `git diff --staged --stat` and `git diff --staged`.
2. If the index is empty, say that there are no staged changes and stop.
3. Read relevant tests, documentation, and issue context when the diff does not
   explain the reason for the change.
4. Check recent commit subjects for a clear repository convention. Follow that
   convention when it conflicts with the default format below.

## Write the message

- Summarize one coherent change. If the subject cannot stay concise, suggest
  that the user split the commit.
- Write the subject as an imperative command. It must complete this sentence:
  "If applied, this commit will ..."
- Start a plain subject with a capital letter. Do not end it with a period.
- Target 50 characters for the subject. Never exceed 72 characters.
- Add a body only when it gives useful context that the diff cannot show.
- Put one blank line between the subject and body.
- Wrap body text at 72 characters.
- Explain the problem, the change, and the reason for the change. Include
  important behavior changes, constraints, or side effects.
- Put issue references and other required trailers after the body.
- Use a Conventional Commit prefix only when the repository uses that format.

## Language standard

Use these ASD-STE100 and Google developer documentation principles:

- Use active voice and present tense when they are accurate.
- Use common, precise words. Use one term for each concept.
- Give each sentence one idea. Keep procedural sentences to 20 words or fewer.
- Keep descriptive sentences to 25 words or fewer.
- Avoid idioms, unnecessary jargon, vague pronouns, and filler.
- Use standard American English. Keep technical names and code identifiers
  unchanged.

## Output

Return only the commit message in a plain-text code block. Do not add analysis,
labels, or a `git commit` command.
