---
name: emacs
description: Open a file in Emacs with `em`. Use when the user asks to open, show or view a file in Emacs (or their editor).
argument-hint: <file> [line]
model: haiku
allowed-tools:
  - Bash(em:*)
---

# Open a file in Emacs

Arguments: `$ARGUMENTS`: a file path, optionally followed by a line number.

Open it with `em` (a wrapper around `emacsclient -n` that returns immediately and reuses an existing frame):

```sh
em <absolute-path>              # open the file
em +<line> <absolute-path>      # jump to a line
```

- Resolve a relative path against the current working directory and pass it as an absolute path.
- If no file was given, use the file most recently discussed in the conversation; ask if that's unclear.
- If the file doesn't exist, say so instead of creating it, unless the user asked for a new file.
- Don't use `emacs` or `emacsclient` directly.

Reply with one short line naming the opened file (as a markdown link).
