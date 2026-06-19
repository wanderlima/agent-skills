# local-md-mermaid-pdf

Converts Markdown files containing Mermaid diagrams into PDF using local machine tools.

## Skill summary

- Input: a Markdown file with Mermaid blocks
- Output: a PDF saved in the same directory as the source file
- Output naming: uses a stable suffix to avoid overwriting prior runs
- Rendering: uses local `mmdc` and `md-to-pdf`
- Styling: uses `style.css` from this folder unless a custom style is explicitly requested
- Pagination: injects footer page numbers through `md-to-pdf` front matter
- Cleanup: removes the temporary sandbox after a successful run

## Notes for maintainers

The skill file is the user-facing contract. This README is for internal/dev reference.

### Dev-only files

- `scripts/` contains local validation helpers for the skill.
- `tests/` contains e2e fixtures and output artifacts used during development.

### Useful dev commands

From the skill root:

```bash
./scripts/e2e.sh --diagnose   # environment check only
./scripts/e2e.sh              # full pipeline (global binaries)
./scripts/e2e.sh --via-npx    # simulate OpenClaw without global installs
./scripts/e2e.sh --keep       # keep artifacts in tests/output/e2e-run on failure
```

## Important behavior

- The sandbox directory is temporary and removed after completion.
- Puppeteer cache is isolated to the sandbox.
- The PDF is written to the original directory with the configured suffix.
- The skill prefers local binaries, but can fall back to `npx` when needed.

## Files in this folder

- `SKILL.md` — user-facing skill instructions
- `style.css` — PDF visual styling
- `README.md` — internal/dev notes and validation entry points
- `scripts/` — development validation helpers
- `tests/` — fixtures and e2e outputs
