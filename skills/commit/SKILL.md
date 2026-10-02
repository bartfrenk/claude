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
2. Read `FORMAT.md` (in this skill's directory) and generate a commit message
   that follows it exactly, then create the commit
3. `CLAUDE.md` and files under `.claude` may be committed, but never mixed into the
   same commit as other changes — always give them their own separate commit

## Message Format
[FORMAT.md](FORMAT.md) is the single source of truth for the commit message
shape (format, types, and style rules). It's also read directly by magit's
"c g" (generate commit) in Emacs — edit it there to keep both aligned.
