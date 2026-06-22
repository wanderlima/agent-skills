---
name: local-md-mermaid-pdf
description: >-
  Converts Markdown files with Mermaid diagrams to PDF using local tools
  (mmdc, md-to-pdf, Puppeteer) with CSS styling and page numbers. Use when
  the user asks to export markdown to PDF, render Mermaid charts to PDF, or
  convert a .md file with diagrams to a printable document, or convert
  multiple Markdown files (one PDF per file, processed sequentially).
version: 1.1.1
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

Converts one or more Markdown files with Mermaid diagrams into PDF(s) using local `mmdc` and `md-to-pdf`. Each source file gets its own PDF (`<basename>-export.pdf` beside the source). All intermediate artifacts live in `local-md-mermaid-pdf-sandbox`; only the final PDF(s) are written outside the sandbox. The sandbox is removed after each successful run.

**Multiple files:** process **sequentially** (one complete run at a time). Produce **one PDF per source file**. **Do not** merge PDFs unless the user explicitly asks.

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
- **Multiple sources:** one PDF per file (same `-export.pdf` rule beside each source). List every absolute PDF path in the final reply
- **Merge:** only when the user explicitly requests a single combined PDF (e.g. "merge", "combine"). Otherwise never merge
- Sandbox `local-md-mermaid-pdf-sandbox` removed after each successful run (all intermediate artifacts deleted with it)

## Constraints

- **All artifacts go in the sandbox** — every file created during the run (`input.md`, `input.tmp.md`, `input.for-pdf.md`, `puppeteer-config.json`, Puppeteer cache, Mermaid render outputs) must live inside `local-md-mermaid-pdf-sandbox`. **Only** the final PDF is written outside the sandbox (via `dest` beside the source file)
- Use **`style.css`** from this skill folder unless the user asks for custom styling (read-only reference; do not copy into the project unless the user requests custom styling)
- Page numbers via `md-to-pdf` front matter: `Page <span class="pageNumber"></span> of <span class="totalPages"></span>`
- Use a **sandbox-local** Puppeteer cache (`PUPPETEER_CACHE_DIR` inside the sandbox); **never** depend on `~/.cache/puppeteer`
- Prefer local binaries; use `npx --yes` only when a binary is missing
- If Chrome or Chromium exists, pass `executablePath` to Puppeteer
- On Puppeteer/cache failures, retry only with the documented Chromium fallback; **do not** invent launch flags
- **Do not** leave the sandbox directory after a successful run
- **Multiple source files — sequential only:** run the full workflow (steps 1–5) for file A, wait until it finishes (PDF written, sandbox deleted), then start file B. **Never** launch parallel conversions, shared sandboxes, or concurrent `mmdc` / `md-to-pdf` / Puppeteer runs
- **Multiple source files — no merge by default:** each source becomes its own `<basename>-export.pdf`. **Do not** concatenate Markdown sources, merge PDFs, or produce one combined output unless the user explicitly asks

## Steps

### 1. Create sandbox

- Create `local-md-mermaid-pdf-sandbox` next to the source file
- **All workflow artifacts stay inside this directory** — do not write intermediate files next to the source or elsewhere
- Copy the source Markdown to `local-md-mermaid-pdf-sandbox/input.md`
- Set `PUPPETEER_CACHE_DIR` to a path inside the sandbox (e.g. `local-md-mermaid-pdf-sandbox/.puppeteer-cache`)

### 2. Render Mermaid

- **Before** running `mmdc`, if Google Chrome or Chromium is available, write `local-md-mermaid-pdf-sandbox/puppeteer-config.json` with system `executablePath` and `args: ["--no-sandbox"]`. **This is required** when `PUPPETEER_CACHE_DIR` points to the empty sandbox cache — without it, `mmdc` cannot find Chrome and diagrams will not render
- Run `mmdc -p puppeteer-config.json -i input.md -o input.tmp.md` when the config exists; otherwise `mmdc -i input.md -o input.tmp.md`
- If `mmdc` emits images or other sidecar files, they must remain inside the sandbox
- If `mmdc` still fails on Puppeteer/cache, retry only with a corrected `executablePath` in `puppeteer-config.json` — **do not** skip to PDF conversion
- **Verify** `input.tmp.md` exists and no longer contains raw ` ```mermaid ` blocks (expect `![diagram](...)` image references and sidecar SVG/PNG files)

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
- Reply with the final PDF path (or all PDF paths when multiple sources were converted)

### Multiple files

When the user provides more than one Markdown file:

1. Confirm the file list (paths and order if order matters to the user)
2. **Queue:** convert file 1 through step 5 completely before starting file 2
3. **One PDF per file:** each output is `<source-dir>/<basename>-export.pdf` beside its source
4. **No merge** unless the user explicitly requested a single combined PDF — if they did, use a separate merge step after all individual PDFs exist (outside this skill's default path)
5. Final reply lists every generated PDF path

## Rationalization Traps

| Rationalization | Reality |
| --- | --- |
| Skip Mermaid render for MD without diagrams | `mmdc` is still required when diagrams exist; inspect the file first |
| Run `mmdc` without `puppeteer-config.json` when sandbox cache is empty | `mmdc` will fail to find Chrome; write config with system `executablePath` **before** the first run |
| Skip to PDF when `mmdc` fails | Never convert without `input.tmp.md`; raw ` ```mermaid ` blocks do not render in PDF |
| Reuse `~/.cache/puppeteer` | Breaks isolation and causes cross-project cache conflicts |
| Invent Puppeteer flags on failure | Only the documented Chromium `executablePath` retry is allowed |
| Keep sandbox for debugging | Sandbox must be removed after success; use `--keep` in `scripts/e2e.sh` for local dev only |
| Overwrite the source PDF name | Use the stable `-export.pdf` suffix to avoid clobbering prior runs |
| Write intermediates beside the source file | Only the final PDF leaves the sandbox; everything else stays in `local-md-mermaid-pdf-sandbox` |
| Run multiple conversions in parallel to save time | Sequential queue only — parallel runs conflict on Puppeteer, cache, and sandbox paths |
| Merge multiple files into one PDF by default | One PDF per source; merge only when the user explicitly asks |
| Reuse one sandbox for several source files at once | Fresh sandbox per file; complete and delete before the next file |

## Red Flags

- Intermediate files (`input.md`, `input.tmp.md`, `input.for-pdf.md`, `puppeteer-config.json`, cache) exist outside `local-md-mermaid-pdf-sandbox`
- PDF missing or smaller than ~1 KB after conversion
- `input.tmp.md` was not produced by `mmdc`
- `input.tmp.md` still contains ` ```mermaid ` blocks (diagrams were not rendered)
- Sandbox directory still exists after a successful run
- `stylesheet` points outside this skill folder without user request
- `npx` used when global `mmdc` / `md-to-pdf` binaries are already available
- Multiple files converted in parallel or from a shared sandbox
- A single merged PDF produced without an explicit user request to merge/combine

## Verification

- [ ] All intermediate artifacts are inside `local-md-mermaid-pdf-sandbox` (no stray files beside the source)
- [ ] `local-md-mermaid-pdf-sandbox/input.tmp.md` exists after `mmdc` and has no raw ` ```mermaid ` blocks
- [ ] `local-md-mermaid-pdf-sandbox/input.for-pdf.md` has `dest`, `stylesheet`, and footer page-number template
- [ ] `<original-basename>-export.pdf` exists beside the source file
- [ ] PDF size is greater than 1 KB
- [ ] `local-md-mermaid-pdf-sandbox` was deleted
- [ ] User received the absolute PDF path
- [ ] **Multiple files:** each source has its own `-export.pdf`; conversions ran sequentially (not in parallel)
- [ ] **Multiple files:** no merged/combined PDF unless the user explicitly requested it
