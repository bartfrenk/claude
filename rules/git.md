# Git

- Always create commits via the `commit` skill, never with a raw `git commit`.
- A global `commit-msg` hook (`~/.config/git/hooks/commit-msg`) enforces the skill's format; if it rejects a commit, fix the message or split the commit rather than bypassing it with `--no-verify`.
