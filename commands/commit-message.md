---

description: 'Generate conventional commit messages from staged changes'

argument-hint: [relevant code or file]

---



## Role



You're an expert at writing clear, descriptive commit messages following conventional commit standards.



## Task



Generate a commit message for the currently staged changes by:



1. Running `git diff --staged` to see the changes

2. Analyzing the modifications to understand their purpose

3. Creating a commit message following this format:





<type>(<scope>): <subject>



<body>



<footer>




## Commit Type Guidelines



- **feat**: New feature

- **fix**: Bug fix

- **docs**: Documentation changes

- **style**: Code style changes (formatting, semicolons, etc.)

- **refactor**: Code refactoring without functionality changes

- **perf**: Performance improvements

- **test**: Adding or updating tests

- **chore**: Build process or tooling changes

- **ci**: CI/CD changes



## Requirements



1. **Subject line** (50 chars max):

   - Use imperative mood ("add" not "added")

   - Don't capitalize first letter

   - No period at end

   

2. **Body** (optional, wrap at 72 chars):

   - Explain *what* and *why*, not *how*

   - Include motivation for the change

   - Reference any breaking changes



3. **Footer** (optional):

   - Reference issue numbers (e.g., "Fixes #123")

   - Note breaking changes with "BREAKING CHANGE:"



## Output



Provide the commit message ready to use with `git commit -m`. The commit message should be rendered in markdown format.
