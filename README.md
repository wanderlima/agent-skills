# agent-skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![skills.sh](https://img.shields.io/badge/skills.sh-installable-green)](https://skills.sh/)

A collection of open-source agent skills installable via [skills.sh](https://skills.sh/).

Works with [Cursor](https://cursor.com/), [VS Code](https://code.visualstudio.com/) (via AI extensions such as Claude Code and GitHub Copilot), [OpenClaw](https://openclaw.ai/), and [Claude](https://claude.ai/) (Claude Code, Claude Desktop, and other agents that load `SKILL.md` files).

## Install

Install interactively (shows a menu to pick skills):

```bash
npx skills add wanderlima/agent-skills
```

Install a specific skill:

```bash
npx skills add wanderlima/agent-skills --skill prepare-git-commit
npx skills add wanderlima/agent-skills --skill local-md-mermaid-pdf
npx skills add wanderlima/agent-skills --skill session-handoff
npx skills add wanderlima/agent-skills --skill list-session-files
```

Install all skills globally:

```bash
npx skills add wanderlima/agent-skills --skill '*' -g -y
```

List available skills without installing:

```bash
npx skills add wanderlima/agent-skills -l
```

### Cursor

Install via [skills.sh](https://skills.sh/) — skills land in `.agents/skills/` (project) or `~/.cursor/skills/` (global):

```bash
npx skills add wanderlima/agent-skills -a cursor -g
```

The CLI auto-detects Cursor when present. Installed skills are picked up automatically in Cursor chat.

### VS Code

VS Code uses whichever AI extension you have installed. Target that agent with `-a`:

**Claude Code** (VS Code extension):

```bash
npx skills add wanderlima/agent-skills -a claude-code -g
```

**GitHub Copilot**:

```bash
npx skills add wanderlima/agent-skills -a copilot -g
```

Without `-a`, the CLI tries to detect installed agents and may install to more than one. You can also browse and install from the editor using a [Skills.sh marketplace extension](https://marketplace.visualstudio.com/items?itemName=AbelMak.skills-sh) (works in VS Code, Cursor, and other VSIX-compatible editors).

### OpenClaw

Add the repository as a skill source in OpenClaw, or install individual skills from this repo. Skills with bundled dependencies (e.g. `local-md-mermaid-pdf`) include OpenClaw install metadata for required binaries.

### Claude

**Claude Code** (CLI or VS Code extension) — install via skills.sh:

```bash
npx skills add wanderlima/agent-skills -a claude-code -g
```

Or clone the repo and point Claude Code at the `skills/` directory.

**Other Claude clients** — copy a skill folder or reference its `SKILL.md` in your agent configuration.

## Skills

Skills are organized by category for easier discovery and maintenance.

### Session Management

| Skill | Description | Install |
|-------|-------------|---------|
| [list-session-files](skills/session/list-session-files/) | Tracks session file changes and appends paths when the agent creates or modifies files; lists full inventory on request | `npx skills add wanderlima/agent-skills --skill list-session-files` |
| [session-handoff](skills/session/session-handoff/) | Creates a safe en-US handoff markdown file from the current session and saves it under the active workspace `handoffs/` folder | `npx skills add wanderlima/agent-skills --skill session-handoff` |

### Git & Version Control

| Skill | Description | Install |
|-------|-------------|---------|
| [prepare-git-commit](skills/git/prepare-git-commit/) | Stages related changes, writes `.git/COMMIT_EDITMSG`, and hands off to the user for local `git commit` (hooks run on their machine) | `npx skills add wanderlima/agent-skills --skill prepare-git-commit` |

### Documentation & Export

| Skill | Description | Install |
|-------|-------------|---------|
| [local-md-mermaid-pdf](skills/docs/local-md-mermaid-pdf/) | Converts Markdown with Mermaid charts to PDF using local tools (`mmdc`, `md-to-pdf`) | `npx skills add wanderlima/agent-skills --skill local-md-mermaid-pdf` |

## Repository structure

Skills are organized into categories, with each skill in its own folder containing a `SKILL.md` file. The [skills.sh](https://skills.sh/) CLI discovers skills up to 3 levels deep, supporting both `skills/<category>/<skill>/SKILL.md` and `skills/<category>/<subcategory>/<skill>/SKILL.md` layouts.

See [docs/skill-anatomy.md](docs/skill-anatomy.md) for the full authoring guide — [`prepare-git-commit`](skills/git/prepare-git-commit/SKILL.md) and [`session-handoff`](skills/session/session-handoff/SKILL.md) are reference workflow-only skills; [`local-md-mermaid-pdf`](skills/docs/local-md-mermaid-pdf/SKILL.md) is the reference tool-dependent skill.

```
agent-skills/
├── docs/
│   └── skill-anatomy.md
├── skills/
│   ├── session/              # Session management
│   │   ├── list-session-files/
│   │   │   └── SKILL.md
│   │   └── session-handoff/
│   │       └── SKILL.md
│   ├── git/                  # Git & version control
│   │   └── prepare-git-commit/
│   │       └── SKILL.md
│   └── docs/                 # Documentation & export
│       └── local-md-mermaid-pdf/
│           └── SKILL.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

### Adding new skills

When adding new skills:

1. Choose the appropriate category folder (or create a new one with a clear, descriptive name)
2. Create a subfolder using lowercase kebab-case for the skill name
3. Ensure the `name` field in the skill's YAML frontmatter matches the folder name
4. Place `SKILL.md` and any supporting files in the skill folder
5. Skills will be discovered automatically by the CLI (no category-level `SKILL.md` files)

**Planned categories:** `mobile-expo/` for React Native and Expo-specific skills will be added in a future release.

## Development

From a skill folder:

```bash
cd skills/docs/local-md-mermaid-pdf
./scripts/e2e.sh --diagnose   # environment check
./scripts/e2e.sh              # full pipeline
```

Verify skill discovery from the repo root:

```bash
npx skills add . -l
```

## Issues

Feel free to [open issues](https://github.com/wanderlima/agent-skills/issues) to report bugs, request features, or suggest improvements.

Pull requests are not accepted at this time.

## Security

To report a vulnerability, see [SECURITY.md](SECURITY.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

[MIT](LICENSE) © wanderlima
