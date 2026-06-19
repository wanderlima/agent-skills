# Skill Anatomy

This document defines the structure, contract, and conventions for skills in [agent-skills](../README.md).

Skills are executable workflows.

They are not reference documents, knowledge bases, or general advice.

A skill must change agent behavior.

If removing a section would not change how an agent behaves, remove it.

---

## Skills location

Every skill lives in its own directory under `skills/`:

```text
agent-skills/
├── skills/
│   └── skill-name/
│       ├── SKILL.md               # Required: runtime contract
│       ├── README.md              # Optional: maintainer-only documentation
│       ├── style.css              # Optional: workflow assets
│       ├── scripts/               # Optional: runnable helpers
│       └── tests/                 # Optional: local validation fixtures
```

`SKILL.md` is the only required file.

Supporting files should exist only when they materially improve execution or maintainability.

Skills are installable via [skills.sh](https://skills.sh/):

```bash
npx skills add wanderlima/agent-skills
npx skills add wanderlima/agent-skills@skill-name
npx skills add . -l
```

---

## Skill loading model

Agents load `SKILL.md` first.

Supporting files should only be referenced when needed.

Optimize every skill for:

- Fast comprehension
- Minimal token usage
- Deterministic execution
- Clear exit criteria

`README.md` is never loaded into agent context.

Use it only for maintainer notes, development workflows, or local debugging instructions.

---

## SKILL.md format

### Frontmatter (required)

```yaml
---
name: skill-name-with-hyphens
description: >-
  What the skill does in third person. Use when [specific trigger conditions].
---
```

### Rules

- `name` must be lowercase kebab-case
- `name` must match the directory name
- `description` must be written in third person
- `description` must explain both:
  - what the skill does
  - when it should be used
- Maximum length: 1024 characters

---

### Optional frontmatter

Use only when needed:

```yaml
---
name: local-md-mermaid-pdf
description: Exports markdown files with Mermaid diagrams to PDF.
version: 1.0.0
tags:
  - markdown
  - pdf
  - mermaid
tools:
  - node
  - puppeteer
requires:
  bins:
    - mmdc
    - md-to-pdf
metadata:
  openclaw:
    install:
      - kind: node
        package: "@mermaid-js/mermaid-cli@11.15.0"
        bins: [mmdc]
      - kind: node
        package: "md-to-pdf@5.2.5"
        bins: [md-to-pdf]
---
```

### Optional fields

| Field | Purpose |
| --- | --- |
| `version` | Skill evolution tracking |
| `tags` | Discovery and categorization |
| `tools` | Tool affinity and runtime expectations |
| `requires.bins` | Required local binaries |
| `metadata.openclaw.install` | Auto-install instructions for OpenClaw |

Only declare dependencies the skill actually requires.

---

## Standard sections

Section naming may vary, but consistency is preferred.

Use this structure whenever possible:

```markdown
# Skill name

## Overview

## When to Use

### Use when

### Do not use when

## Inputs

## Outputs

## Constraints

## Steps

## Rationalization Traps

## Red Flags

## Verification
```

Equivalent headings are acceptable when they preserve the same meaning.

---

## Section purposes

### Overview

A brief description of the skill.

- What does this skill do?
- Why does it exist?

Keep it short.

---

### When to Use

Defines activation boundaries.

Split clearly:

#### Use when

Positive triggers. Example:

- Use when the user asks to prepare a Git commit.

#### Do not use when

Negative exclusions. Example:

- Do not use for pushing commits.

---

### Inputs

What the skill expects before execution.

Examples:

- Selected files
- Input markdown
- Existing branch state

Inputs should be observable.

---

### Outputs

What the skill must produce.

Examples:

- `.git/COMMIT_EDITMSG`
- Exported PDF file
- Validation logs

Outputs should be concrete.

---

### Constraints

Non-negotiable rules.

Examples:

- Never run `git commit`
- Never push to remote
- Never modify source files directly

Constraints should be explicit.

---

### Steps

The execution path.

This is the core of the skill.

Steps must be actionable.

| Quality | Example |
| --- | --- |
| Good | `Run git add only for selected paths` |
| Bad | `Stage the right files` |

Specificity matters.

---

### Rationalization Traps

Common shortcuts or excuses an agent may use to skip steps.

Use this format:

| Rationalization | Reality |
| --- | --- |
| This step seems unnecessary | It prevents incomplete execution |

Use this section for safety-critical or error-prone workflows.

---

### Red Flags

Common signs the skill is being used incorrectly.

Examples:

- Running prohibited commands
- Missing output artifacts
- Skipping verification

These are operational warnings.

---

### Verification

Exit criteria for the skill.
Every item must map to observable evidence.

No subjective verification.

| Quality | Example |
| --- | --- |
| Good | `git diff --cached` reviewed; commit message file created |
| Bad | Looks good |

---

## Skill types

### Workflow-only skills

Pure markdown workflows.

No bundled binaries.

| Aspect | Pattern |
| --- | --- |
| Layout | `SKILL.md` only |
| Process | Explicit steps |
| Safety | Constraints section |
| Output | Concrete deliverables |

Example: [`prepare-git-commit`](../skills/prepare-git-commit/SKILL.md)

Key characteristics:

- Strong constraints
- Explicit commands
- Clear handoff to user

---

### Tool-dependent skills

Require binaries, scripts, or assets.

| Aspect | Pattern |
| --- | --- |
| Layout | `SKILL.md`, scripts, assets |
| Frontmatter | Dependencies declared |
| Process | File-specific flow |
| Validation | Local e2e or smoke checks |

Example: [`local-md-mermaid-pdf`](../skills/local-md-mermaid-pdf/SKILL.md)

Key characteristics:

- Runtime dependencies
- Sandboxed execution
- Stable outputs

---

## Supporting files

Only create supporting files when necessary.

Use them when:

- `SKILL.md` would exceed ~100 lines
- Runnable helpers are part of the workflow
- Long reference material is needed

| File | Audience | Loaded by agent |
| --- | --- | --- |
| `SKILL.md` | Agents | Yes |
| `README.md` | Maintainers | No |
| `scripts/` | Runtime helpers | Only when referenced |
| `tests/` | Local validation | No |
| `style.css` | Workflow assets | Only when referenced |

Prefer inline content when possible.

Keep supporting files purposeful.

---

## Writing principles

### 1. Process over knowledge

Skills define execution.

Not theory.

### 2. Specific over general

Prefer exact paths, filenames, and commands.

### 3. Evidence over assumption

Verification requires proof.

Not claims.

### 4. Anti-rationalization

If a step is important, defend it.

### 5. Progressive disclosure

Keep the entry point minimal.

Load deeper files only when necessary.

### 6. Token-conscious

Every line should justify its cost.

---

## Naming conventions

| Item | Convention | Example |
| --- | --- | --- |
| Skill directory | `lowercase-hyphen-separated` | `prepare-git-commit` |
| Skill file | `SKILL.md` | `skills/prepare-git-commit/SKILL.md` |
| Supporting docs | `lowercase-hyphen-separated.md` | `reference.md` |
| Sandbox dirs | Skill-prefixed | `local-md-mermaid-pdf-sandbox` |

Prefer verb-first names for action-oriented skills.

| Quality | Example |
| --- | --- |
| Good | `prepare-git-commit` |
| Avoid | `git-commit-preparation` |

---

## Cross-skill references

Reference other skills by name.

Do not duplicate their logic.

Example:

```markdown
After preparing the commit, the user runs `git commit` locally.

For PDF exports, use `local-md-mermaid-pdf`.
```

Skills should compose.

---

## New skill checklist

### Required

- [ ] `skills/<skill-name>/SKILL.md` exists
- [ ] Frontmatter `name` matches directory name
- [ ] Description explains what + when
- [ ] Workflow steps are actionable
- [ ] Outputs are explicit
- [ ] Verification is evidence-based
- [ ] `npx skills add . -l` lists the skill

### Recommended

- [ ] Use exclusions in `When to Use`
- [ ] Add `Inputs`
- [ ] Add `Outputs`
- [ ] Add `Constraints`
- [ ] Add `Rationalization Traps`
- [ ] Add root README entry
- [ ] Add changelog entry

### If the skill uses binaries

- [ ] `requires.bins` documented
- [ ] `metadata.openclaw.install` declared if applicable
- [ ] Local validation exists
- [ ] Maintainer docs exist when necessary
