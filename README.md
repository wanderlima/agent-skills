# agent-skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![skills.sh](https://img.shields.io/badge/skills.sh-installable-green)](https://skills.sh/)

A collection of open-source agent skills installable via [skills.sh](https://skills.sh/).

Works with [OpenClaw](https://openclaw.ai/) and [Claude](https://claude.ai/) (Claude Code, Claude Desktop, and other agents that load `SKILL.md` files).

## Install

Install interactively (shows a menu to pick skills):

```bash
npx skills add wanderlima/agent-skills
```

Install a specific skill:

```bash
npx skills add wanderlima/agent-skills@local-md-mermaid-pdf
```

Install all skills globally:

```bash
npx skills add wanderlima/agent-skills --skill '*' -g -y
```

List available skills without installing:

```bash
npx skills add wanderlima/agent-skills -l
```

### OpenClaw

Add the repository as a skill source in OpenClaw, or install individual skills from this repo. Skills with bundled dependencies (e.g. `local-md-mermaid-pdf`) include OpenClaw install metadata for required binaries.

### Claude

**Claude Code** — install via skills.sh:

```bash
npx skills add wanderlima/agent-skills -a claude-code -g
```

Or clone the repo and point Claude Code at the `skills/` directory.

**Other Claude clients** — copy a skill folder or reference its `SKILL.md` in your agent configuration.

## Skills

| Skill | Description |
|-------|-------------|
| [local-md-mermaid-pdf](skills/local-md-mermaid-pdf/) | Converts Markdown with Mermaid charts to PDF using local tools |

## Repository structure

Each skill lives in its own folder under `skills/` with a `SKILL.md` file:

```
agent-skills/
├── skills/
│   └── local-md-mermaid-pdf/
│       ├── SKILL.md
│       ├── style.css
│       └── scripts/
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Development

From a skill folder:

```bash
cd skills/local-md-mermaid-pdf
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
