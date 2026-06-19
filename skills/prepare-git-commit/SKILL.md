---
name: prepare-git-commit
description: >-
  Stages related git changes and writes a commit message to .git/COMMIT_EDITMSG
  without running git commit or push (hooks run when the user commits). Use when
  the user asks to prepare a commit, stage files, write a commit message, or
  commit changes without pushing.
version: 1.0.0
tags:
  - git
  - commit
  - staging
tools:
  - git
---

# Prepare Git Commit

## Overview

Stages files for one logical change and writes a commit message to `.git/COMMIT_EDITMSG`. The user runs `git commit` locally so hooks (e.g. `commit-msg`) execute.

## When to Use

### Use when

- The user asks to prepare a commit
- The user asks to stage files or write a commit message
- The user asks to commit changes without pushing

### Do not use when

- The user explicitly asks to run `git commit` or `git push`
- The user wants amend, squash, or rebase unless explicitly requested
- Only documentation or review is needed (no staging or message)

## Inputs

- Current branch state (`git status`, `git diff`)
- Files already staged or changed on the branch
- Recent commit message style (`git log`)
- User scope when they name specific paths or changes

## Outputs

- `.git/COMMIT_EDITMSG` with the formatted commit message
- List of staged files
- Reminder to run commit locally:

```bash
git commit
# or
git commit -F .git/COMMIT_EDITMSG
```

## Constraints

- **Never** run `git commit` or `git push`
- **Never** amend, squash, or rebase unless explicitly requested
- **Never** stage secrets (`.env`, credentials, tokens)
- **Never** add `Co-authored-by:`, `Made-with: Cursor`, or any AI/editor attribution
- Commit message language: **en-US**

## Steps

### 1. Inspect

Run in parallel when possible:

- `git status`
- `git diff` (staged + unstaged)
- `git log -n 5` (message style)

### 2. Stage

- If files are already staged appropriately, leave as-is
- Otherwise, pick branch changes related to the same logical work (prefer recent edits)
- Stage only files for the same logical change
- Do not stage unrelated or generated files unless explicitly required
- Run `git add` for selected paths only

### 3. Write commit message

- Write to **`.git/COMMIT_EDITMSG`**
- Format: short title line + bullet list (intent/why, not noisy implementation detail)
- **Prefix** — prefer prefix from branch name (e.g. `feat/`, `fix/`, `chore/`); otherwise use `feat:`, `fix:`, `bugfix:`, `chore:`, `refactor:`

### 4. Hand off

Report staged files, the full commit message (copy-ready), and instruct the user to run `git commit` locally.

## Rationalization Traps

| Rationalization | Reality |
| --- | --- |
| Running `git commit` is faster | Hooks must run on the user's machine |
| Files are already staged, skip inspect | Staging may include unrelated or secret files |
| Attribution lines are harmless | `Co-authored-by:` and editor attribution are prohibited |
| One big stage is fine | Unrelated changes block clean review and revert |

## Red Flags

- `git commit` or `git push` was executed
- `.env`, credentials, or generated artifacts were staged
- `.git/COMMIT_EDITMSG` was not written
- `git diff --cached` was not reviewed before staging

## Verification

- [ ] `git diff --cached` reviewed for scope and secrets
- [ ] Only related files are staged (`git diff --cached --name-only`)
- [ ] `.git/COMMIT_EDITMSG` exists with title, prefix, and bullet list
- [ ] No prohibited attribution in the message
- [ ] User received staged file list, full message, and local commit command
