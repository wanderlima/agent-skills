# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-06-21

### Added

- `session-handoff` skill — creates a safe en-US handoff markdown file from the current session and saves it under the active workspace `handoffs/` folder

### Changed

- `README.md` — skill table, install example, repository structure tree, and reference links updated for `session-handoff`

## [0.2.00] - 2026-06-19

### Added

- `prepare-git-commit` skill — stages related changes and writes `.git/COMMIT_EDITMSG` without running `git commit` or push
- `docs/skill-anatomy.md` — authoring guide for skill structure and conventions

### Changed

- `prepare-git-commit` — restructured `SKILL.md` to follow `docs/skill-anatomy.md` (Overview, When to Use, Inputs, Outputs, Constraints, Steps, Rationalization Traps, Red Flags, Verification); added `version`, `tags`, and `tools` frontmatter
- `local-md-mermaid-pdf` — restructured `SKILL.md` to follow `docs/skill-anatomy.md`; added `version`, `tags`, and `tools` frontmatter (`puppeteer`, not Playwright); clarified that all intermediate artifacts must live in `local-md-mermaid-pdf-sandbox` (only the final PDF is written outside)
- `docs/skill-anatomy.md` — optional frontmatter example aligned with `local-md-mermaid-pdf` dependencies (`mmdc`, `md-to-pdf`, `puppeteer`)
- `README.md` — skill table, install example, and reference links updated for both skills

## [0.1.0] - 2026-06-18

### Added

- Initial open-source release of the skills collection
- `local-md-mermaid-pdf` skill — converts Markdown with Mermaid diagrams to PDF using local tools (`mmdc`, `md-to-pdf`)
- Repository layout compatible with [skills.sh](https://skills.sh/) (`skills/<name>/SKILL.md`)
- E2E validation script for `local-md-mermaid-pdf`

[Unreleased]: https://github.com/wanderlima/agent-skills/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/wanderlima/agent-skills/compare/v0.2.00...v0.3.0
[0.2.00]: https://github.com/wanderlima/agent-skills/compare/v0.1.0...v0.2.00
[0.1.0]: https://github.com/wanderlima/agent-skills/releases/tag/v0.1.0
