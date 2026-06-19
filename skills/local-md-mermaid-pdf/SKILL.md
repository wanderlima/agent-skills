---
name: local-md-mermaid-pdf
description: >-
  Converts Markdown files with Mermaid diagrams to PDF using local tools
  (mmdc, md-to-pdf, Puppeteer) with CSS styling and page numbers. Use when
  the user asks to export markdown to PDF, render Mermaid charts to PDF, or
  convert a .md file with diagrams to a printable document.
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

# Local MD & Mermaid to PDF

## Overview

Converts a Markdown file with Mermaid diagrams into a PDF using local `mmdc` and `md-to-pdf`. All intermediate artifacts live in `local-md-mermaid-pdf-sandbox`; only the final PDF is written beside the source file (`-export.pdf` suffix). The sandbox is removed after success.

## When to Use

### Use when

- The user asks to export Markdown to PDF
- The source file contains Mermaid diagram blocks
- The user wants styled PDF output with page numbers from local tools

### Do not use when

- The file has no Mermaid diagrams and a simple MD→PDF path is enough (still works, but heavier than necessary)
- The user wants cloud/API-based conversion instead of local binaries
- The user asks to modify the source Markdown (this skill only exports)

## Inputs

- Source Markdown file path (with optional Mermaid ` ```mermaid ` blocks)
- `style.css` from this skill folder (unless the user requests custom styling)
- Local binaries `mmdc` and `md-to-pdf`, or `npx --yes` fallback
- Google Chrome or Chromium for Puppeteer (`executablePath` when available)

## Outputs

- PDF at `<source-dir>/<original-basename>-export.pdf` — **only deliverable outside the sandbox**
- Final reply with the absolute PDF path
- Sandbox `local-md-mermaid-pdf-sandbox` removed after success (all intermediate artifacts deleted with it)

## Constraints

- **All artifacts go in the sandbox** — every file created during the run (`input.md`, `input.tmp.md`, `input.for-pdf.md`, `puppeteer-config.json`, Puppeteer cache, Mermaid render outputs) must live inside `local-md-mermaid-pdf-sandbox`. **Only** the final PDF is written outside the sandbox (via `dest` beside the source file)
- Use **`style.css`** from this skill folder unless the user asks for custom styling (read-only reference; do not copy into the project unless the user requests custom styling)
- Page numbers via `md-to-pdf` front matter: `Page <span class="pageNumber"></span> of <span class="totalPages"></span>`
- Use a **sandbox-local** Puppeteer cache (`PUPPETEER_CACHE_DIR` inside the sandbox); **never** depend on `~/.cache/puppeteer`
- Prefer local binaries; use `npx --yes` only when a binary is missing
- If Chrome or Chromium exists, pass `executablePath` to Puppeteer
- On Puppeteer/cache failures, retry only with the documented Chromium fallback; **do not** invent launch flags
- **Do not** leave the sandbox directory after a successful run

## Steps

### 1. Create sandbox

- Create `local-md-mermaid-pdf-sandbox` next to the source file
- **All workflow artifacts stay inside this directory** — do not write intermediate files next to the source or elsewhere
- Copy the source Markdown to `local-md-mermaid-pdf-sandbox/input.md`
- Set `PUPPETEER_CACHE_DIR` to a path inside the sandbox (e.g. `local-md-mermaid-pdf-sandbox/.puppeteer-cache`)

### 2. Render Mermaid

- Run `mmdc -i input.md -o input.tmp.md` from inside the sandbox (paths relative to `local-md-mermaid-pdf-sandbox/`)
- If `mmdc` emits images or other sidecar files, they must remain inside the sandbox
- If `mmdc` fails on Puppeteer/cache, write `local-md-mermaid-pdf-sandbox/puppeteer-config.json` with system Chrome `executablePath` and retry with `mmdc -p puppeteer-config.json`

### 3. Build PDF input

Write `local-md-mermaid-pdf-sandbox/input.for-pdf.md` with YAML front matter:

- `dest`: `<source-dir>/<original-basename>-export.pdf` — **the only output path outside the sandbox**
- `stylesheet`: absolute path to this skill’s `style.css`
- `pdf_options.displayHeaderFooter`: `true`
- `pdf_options.headerTemplate`: `'<div></div>'`
- `pdf_options.footerTemplate`: centered page numbers only
- Body: contents of `input.tmp.md`

### 4. Convert to PDF

- Build `--launch-options` JSON (`executablePath` when Chrome/Chromium is available; `args: ["--no-sandbox"]`)
- Run `md-to-pdf --basedir local-md-mermaid-pdf-sandbox --launch-options '<json>' input.for-pdf.md` from inside the sandbox (or `npx --yes md-to-pdf@5.2.5 ...`)

### 5. Clean up and report

- Delete `local-md-mermaid-pdf-sandbox`
- Reply with the final PDF path

## Rationalization Traps

| Rationalization | Reality |
| --- | --- |
| Skip Mermaid render for MD without diagrams | `mmdc` is still required when diagrams exist; inspect the file first |
| Reuse `~/.cache/puppeteer` | Breaks isolation and causes cross-project cache conflicts |
| Invent Puppeteer flags on failure | Only the documented Chromium `executablePath` retry is allowed |
| Keep sandbox for debugging | Sandbox must be removed after success; use `--keep` in `scripts/e2e.sh` for local dev only |
| Overwrite the source PDF name | Use the stable `-export.pdf` suffix to avoid clobbering prior runs |
| Write intermediates beside the source file | Only the final PDF leaves the sandbox; everything else stays in `local-md-mermaid-pdf-sandbox` |

## Red Flags

- Intermediate files (`input.md`, `input.tmp.md`, `input.for-pdf.md`, `puppeteer-config.json`, cache) exist outside `local-md-mermaid-pdf-sandbox`
- PDF missing or smaller than ~1 KB after conversion
- `input.tmp.md` was not produced by `mmdc`
- Sandbox directory still exists after a successful run
- `stylesheet` points outside this skill folder without user request
- `npx` used when global `mmdc` / `md-to-pdf` binaries are already available

## Verification

- [ ] All intermediate artifacts are inside `local-md-mermaid-pdf-sandbox` (no stray files beside the source)
- [ ] `local-md-mermaid-pdf-sandbox/input.tmp.md` exists after `mmdc`
- [ ] `local-md-mermaid-pdf-sandbox/input.for-pdf.md` has `dest`, `stylesheet`, and footer page-number template
- [ ] `<original-basename>-export.pdf` exists beside the source file
- [ ] PDF size is greater than 1 KB
- [ ] `local-md-mermaid-pdf-sandbox` was deleted
- [ ] User received the absolute PDF path
