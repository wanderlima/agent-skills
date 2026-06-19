---
name: local-md-mermaid-pdf
description: Converts Markdown files with Mermaid charts to PDF using local machine tools in a cost-efficient way, with CSS styling and automatic pagination support.
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

# Local MD & Mermaid to PDF Converter

Convert a Markdown file with Mermaid diagrams into a PDF using local tools. Save the PDF beside the source file, using the same basename plus `-export.pdf`. Remove the temporary sandbox after success.

## Rules
- Use `style.css` from this folder unless the user asks for custom styling.
- Page numbers come from `md-to-pdf` front matter; use `Page <span class="pageNumber"></span> - <span class="totalPages"></span>`.
- Use an isolated sandbox-local Puppeteer cache; never depend on `~/.cache/puppeteer`.
- Prefer local binaries. Use `npx --yes` only when a binary is missing.
- If Google Chrome or Chromium exists, pass `executablePath` to Puppeteer.
- On Puppeteer/cache issues, retry only with the documented Chromium fallback; do not invent flags.

## Flow
1. Create `local-md-mermaid-pdf-sandbox` next to the source file.
2. Copy the source Markdown to `input.md` and set `PUPPETEER_CACHE_DIR` inside the sandbox.
3. Render Mermaid blocks with `mmdc` to `input.tmp.md`.
4. Build `input.for-pdf.md` with YAML front matter:
   - `dest`: `<original-basename>-export.pdf`
   - `stylesheet`: this skill’s `style.css`
   - `pdf_options.displayHeaderFooter: true`
   - `pdf_options.headerTemplate: '<div></div>'`
   - `pdf_options.footerTemplate`: centered page numbers only
5. Convert to PDF with `md-to-pdf --basedir ... --launch-options ...`.
6. Delete the sandbox directory.
7. Reply with the final PDF path.
