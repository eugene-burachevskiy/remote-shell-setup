---
description: 'Write a pull request or merge request description'
---

Write a description for the current pull request (PR) or merge request (MR).
Do not create or update the change request.

## Inspect the change

1. Identify the remote default branch. Do not assume that it is `main`.
2. Review the commits and `git diff <default-branch>...HEAD`.
3. Review relevant tests, issue context, and user-provided context.
4. Use the repository template when one exists.

## Describe the change

- State the problem or goal first.
- Explain what changed and why. Do not narrate details that the diff shows.
- State how you verified the change. Do not claim tests that did not run.
- Include important risks, limitations, migrations, or follow-up work.
- Use full issue URLs when the hosting context is unclear. Use closing keywords
  only when the change fully resolves the issue.
- Keep a simple change to one short paragraph. Use headings and bullet lists
  only when they help readers review a complex change.

## Language standard

Use these ASD-STE100 and Google developer documentation principles:

- Use active voice, present tense, and direct language.
- Use common, precise words. Use one term for each concept.
- Give each sentence one idea. Keep sentences to 25 words or fewer.
- Put a condition before the action or result that depends on it.
- Address the reviewer as "you" only when necessary.
- Avoid idioms, unnecessary jargon, vague pronouns, and filler.
- Use standard American English and sentence-case headings.

## Output

Return only the ready-to-use Markdown description.
