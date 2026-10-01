---
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git branch:*)
---

# Git Commit Skill

Create well-formatted git commits following conventional commit standards.

## Usage
```
/commit
```

## Behavior
1. Analyze staged changes with `git diff --staged`
2. Generate a conventional commit message
   - Create the commit with proper formatting
   - Don't add co-author information to the commit message
   - The optional body should consist of bullet points
3. `CLAUDE.md` and files under `.claude` may be committed, but never mixed into the
   same commit as other changes — always give them their own separate commit


## Commit Format
```
<type>(<scope>): <description>

[optional body]
```
The <description> should start with a capital letter.

## Types
- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Code style changes
- refactor: Code refactoring
- test: Adding or modifying tests
- chore: Maintenance tasks

## Example Output
```
feat(auth): Add password reset functionality

- Add forgot password form
- Implement email verification flow
- Add password reset endpoint
```
