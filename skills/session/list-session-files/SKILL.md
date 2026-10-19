---
name: list-session-files
description: >-
  Tracks files created and modified in the current agent session and surfaces
  their absolute full system paths in agent replies. Appends a session-files
  list whenever the current response creates or modifies files; lists the full
  session inventory when the user asks for session files, touched files, or
  what changed this session. Works for any path — versioned, unversioned, or
  outside a git repo. Use on every turn that writes files and whenever the user
  requests a session file list.
version: 1.0.0
tags:
  - session
  - files
  - inventory
tools:
  - read
  - write
---

# List Session Files

## Overview

Keep a running inventory of files created and modified during the current
session. Surface paths in agent replies when file work happens, and on demand
when the user asks. This skill is not tied to git — files may live anywhere on
the filesystem and may or may not be versioned.

## When to Use

### Use when

- The current response creates or modifies one or more files (append the list)
- The user asks for session files or touched files
- The user asks what was created or changed in this session
- The user says "what changed in this session" or similar

### Do not use when

- The response only reads, searches, or discusses files without writing
- The user wants branch diff, PR scope, or git history (not this skill)
- The user wants file contents or a code review (paths only)

## Inputs

- Current session tool history (Write, StrReplace, Delete, EditNotebook, shell commands that create or modify files)
- Files created or modified in the **current turn**
- Cumulative session file state from earlier turns

## Outputs

### After a turn that creates or modifies files

A **Session files** block appended to the reply (see format below).

### When the user asks for session files

The full cumulative inventory, grouped by **Created** and **Modified**.

## Constraints

- Scope is the **current session only**
- Do not use git status, git diff, or any git command for this skill
- List paths only; do not dump file contents unless the user explicitly asks
- Do not include secrets or sensitive file contents
- Always list **absolute full system paths** (e.g. `/Users/name/project/file.md`)
- When a tool returns a relative path, resolve it against the active workspace root before listing
- Append the session-files block only when **this turn** created or modified files — not on read-only replies
- Omit the block on turns with no file creation or modification

## Steps

### 1. Track session file state

Maintain a mental running inventory across the session:

- **Created** — first write of a new path in this session
- **Modified** — edit of a path that already existed before this session
- **Deleted** — path removed in this session (include only when applicable)

Evidence sources:

- `Write` — created (new file) unless the path was already created earlier in the session
- `StrReplace` — modified (or created if first touch was a replace on a new path)
- `Delete` — deleted
- `EditNotebook` — created or modified depending on `is_new_cell`
- Shell commands — include only when they clearly created or modified specific paths

If a file is created then modified later in the same session, keep it under **Created**.

Deduplicate paths. Sort alphabetically within each group.

Normalize every path to an absolute full system path before listing. If the
file tool used a relative path, prepend the active workspace root (from user
info or `pwd`). Never output workspace-relative paths in the inventory.

### 2. Append list after file-changing turns

When **this turn** creates or modifies at least one file, append to the reply:

```markdown
---

**Session files**

Created:
- /Users/name/project/path/to/new-file.md

Modified:
- /Users/name/project/path/to/existing-file.ts
```

Rules for the footer:

- List paths touched **in this turn** under Created or Modified
- Omit empty groups
- Keep the block compact — paths only, no file contents
- Place it at the end of the reply, after the main answer
- Do not add this block when the turn did not create or modify any file

### 3. Respond to explicit requests

When the user asks for session files (or equivalent), return the **full
cumulative** inventory for the session:

```markdown
## Session files

**Created** (N)
- /Users/name/project/path/to/new-file.md

**Modified** (N)
- /Users/name/project/path/to/existing-file.ts

**Deleted** (N)
- /Users/name/project/path/to/removed-file.js

**Total:** N
```

Omit empty groups. When nothing was touched in the session, say so explicitly.

### 4. Hand off

- Do not suggest git workflows unless the user asks
- For continuation notes, cross-reference `session-handoff` only when relevant

## Rationalization Traps

| Rationalization | Reality |
| --- | --- |
| Git status is a reliable source | This skill tracks session tool actions; git may be absent or irrelevant |
| Show the list on every reply | Only append when this turn created or modified files |
| Conversation memory is enough | Tool history is the source of truth for paths |
| Created then modified should appear in both groups | Each path belongs in one group; created-then-modified stays under Created |
| Relative paths are shorter and fine | Always resolve to absolute full system paths before listing |

## Red Flags

- Session-files block appended on a read-only turn
- Paths listed with no session tool evidence
- Git commands used to build the inventory
- Duplicate paths across groups
- File contents or secrets included without request
- Footer missing after a turn that used Write or StrReplace
- Any path listed as relative instead of absolute

## Verification

- Footer appears only on turns that created or modified files
- Every listed path maps to a session file action
- Every listed path is an absolute full system path (starts with `/` on Unix)
- Git was not used to produce the list
- Groups use only Created, Modified, and Deleted (omit empty groups)
- Paths are deduplicated; explicit request shows full cumulative session inventory
- Counts match the listed paths
