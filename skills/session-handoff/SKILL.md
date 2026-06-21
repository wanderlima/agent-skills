---
name: session-handoff
description: >-
  Creates a safe en-US handoff markdown file from the current session, including
  the session timestamp, status, objective, expected result, work done, wins,
  failures, blockers, related sessions or agents, and next steps. Use when the
  user asks to create a session handoff or to end the session.
version: 1.0.0
tags:
  - handoff
  - session
  - summary
  - continuity
tools:
  - read
  - write
  - sessions_history
  - sessions_list
  - sessions_send
---

# Session Handoff

## Overview

Create a concise continuation note for the current session so another agent or
future run can pick up the work quickly without reading the full transcript.

## When to Use

### Use when

- The user asks to create a session handoff
- The user says session handoff or handoff da sessão
- The user asks to encerrar sessão and preserve context for continuation

### Do not use when

- The user only wants a short summary with no continuation file
- The user asks for a public-facing recap instead of an internal handoff
- The task would reveal secrets, env vars, tokens, credentials, or other sensitive data that cannot be safely redacted

## Inputs

- The current session transcript
- Any related sessions or agent interactions that affected the outcome
- The active workspace path for the current agent
- A short objective-derived title in lowercase kebab-case
- The session timestamp, if available

## Outputs

- A markdown file at `<active-workspace>/handoffs/<objective-summary>.md`
- A handoff that is safe to share internally and free of sensitive data

## Constraints

- Write in en-US only
- Never include secrets, environment variables, tokens, cookies, passwords, private URLs, private IDs, or other sensitive data
- Never include raw `.env` values or anything that looks like a secret or credential
- Remove or redact any secret-like string before writing
- Create the `handoffs/` folder if it does not exist
- Derive the filename from the session objective, not from sensitive content
- Use lowercase kebab-case for the filename
- If the objective is too ambiguous to name confidently, ask the user for a title before writing

## Steps

### 1. Gather context

- Read the current session and any relevant related sessions or sub-agent results.
- Identify the objective, expected result, completed work, wins, failures, blockers, decisions, and next steps.
- Include other sessions or agents only when they add useful continuation context.

### 2. Sanitize

- Remove or redact anything that looks like a secret or sensitive operational detail.
- Replace sensitive references with neutral placeholders like `[redacted]`.
- Keep the handoff factual and compact.
- Prefer safe references to files, public links, and completed actions.

### 3. Choose the filename

- Build a short title from the session objective.
- Convert it to lowercase kebab-case.
- Examples:
  - `optimize-linkedin-profile.md`
  - `session-handoff.md`

### 4. Write the handoff

Use this structure:

```markdown
# Session Handoff: <short title>

## Session metadata
- Date/time: <timestamp>
- Status: <completed | partial | blocked>

## Objective

## Expected result

## What was done

## What worked

## What did not work yet

## Blockers and risks

## Decisions made

## Related sessions or agents

## Relevant files or references

## Next steps

## Notes
```

### 5. Save the file

- Save the markdown file in the current agent workspace under `handoffs/`.
- Create the folder first if needed.
- Confirm the final file path to the user when the handoff is complete.
- Include a final output line like `Handoff saved to: /absolute/path/to/file.md`.
- Confirm the main decision points to the user.

## Rationalization Traps

| Rationalization | Reality |
| --- | --- |
| The transcript is enough without a file | The skill exists to create a durable handoff artifact |
| A filename doesn't matter much | The filename is the retrieval handle for future continuation |
| Minor sensitive details are fine | Handoffs must be safe to share internally |
| Related sessions are optional in every case | They matter whenever they change the continuation plan |

## Red Flags

- The file is written outside `handoffs/`
- The filename is not lowercase kebab-case
- Secrets, env vars, tokens, cookies, passwords, or private IDs appear in the output
- The final reply does not include the file path
- The handoff omits session metadata, status, or next steps

## Verification

- The file exists in `<active-workspace>/handoffs/`
- The filename is lowercase kebab-case
- The content is in en-US
- No secrets or sensitive data appear in the handoff
- The summary includes the timestamp, status, objective, result, work done, wins, failures, blockers, related sessions or agents, next steps, and relevant references
