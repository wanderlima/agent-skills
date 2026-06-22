#!/usr/bin/env bash
# End-to-end validation for local-md-mermaid-pdf.
# Usage:
#   ./scripts/e2e.sh              # full pipeline
#   ./scripts/e2e.sh --diagnose     # environment checks only
#   ./scripts/e2e.sh --via-npx      # force npx instead of global bins
#   ./scripts/e2e.sh --keep         # keep workdir on failure
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURE="${SKILL_ROOT}/tests/fixtures/sample.md"
STYLE="${SKILL_ROOT}/style.css"
WORKDIR="${SKILL_ROOT}/tests/output/e2e-run"
OUTPUT_PDF="${WORKDIR}/output.pdf"

MMDC_PKG="@mermaid-js/mermaid-cli@11.15.0"
MDTOPDF_PKG="md-to-pdf@5.2.5"

DIAGNOSE_ONLY=false
FORCE_NPX=false
KEEP_ON_FAIL=false
VERBOSE=false

log()  { printf '[e2e] %s\n' "$*"; }
fail() { printf '[e2e] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: ./scripts/e2e.sh [options]

Options:
  --diagnose    Print environment diagnostics and exit
  --via-npx     Force npx instead of globally installed mmdc / md-to-pdf
  --keep        Keep tests/output/e2e-run when the run fails
  --verbose     Print resolved commands and intermediate paths
  -h, --help    Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --diagnose) DIAGNOSE_ONLY=true ;;
    --via-npx)  FORCE_NPX=true ;;
    --keep)     KEEP_ON_FAIL=true ;;
    --verbose)  VERBOSE=true ;;
    -h|--help)  usage; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
  shift
done

[[ -f "$FIXTURE" ]] || fail "Missing fixture: $FIXTURE"
[[ -f "$STYLE" ]] || fail "Missing stylesheet: $STYLE"

resolve_chrome() {
  if [[ -n "${PUPPETEER_EXECUTABLE_PATH:-}" && -x "${PUPPETEER_EXECUTABLE_PATH}" ]]; then
    echo "${PUPPETEER_EXECUTABLE_PATH}"
    return 0
  fi

  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/usr/bin/google-chrome"
    "/usr/bin/chromium"
    "/usr/bin/chromium-browser"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

print_diagnostics() {
  log "Skill root: ${SKILL_ROOT}"
  log "Node: $(node -v 2>/dev/null || echo 'not found')"
  log "npm:  $(npm -v 2>/dev/null || echo 'not found')"
  log "npx:  $(command -v npx 2>/dev/null || echo 'not found')"

  if command -v mmdc >/dev/null 2>&1; then
    log "mmdc: $(command -v mmdc) ($(mmdc -V 2>/dev/null || mmdc --version 2>/dev/null || echo 'version unknown'))"
  else
    log "mmdc: not found"
  fi

  if command -v md-to-pdf >/dev/null 2>&1; then
    log "md-to-pdf: $(command -v md-to-pdf) ($(md-to-pdf --version 2>/dev/null || echo 'version unknown'))"
  else
    log "md-to-pdf: not found"
  fi

  if chrome="$(resolve_chrome 2>/dev/null)"; then
    log "Chrome: ${chrome}"
  else
    log "Chrome: not found (set PUPPETEER_EXECUTABLE_PATH or install Google Chrome)"
  fi

  log "PUPPETEER_CACHE_DIR: ${PUPPETEER_CACHE_DIR:-<default>}"
  log "Fixture: ${FIXTURE}"
}

run_mmdc() {
  local input="$1"
  local output="$2"
  local puppeteer_config="${3:-}"

  local -a cmd
  if [[ "$FORCE_NPX" == true ]] || ! command -v mmdc >/dev/null 2>&1; then
    cmd=(npx --yes -p "$MMDC_PKG" mmdc)
  else
    cmd=(mmdc)
  fi

  if [[ -n "$puppeteer_config" ]]; then
    cmd+=(-p "$puppeteer_config")
  fi

  cmd+=(-i "$input" -o "$output")

  $VERBOSE && log "Running: ${cmd[*]}"
  "${cmd[@]}"
}

build_launch_options() {
  local chrome
  if chrome="$(resolve_chrome 2>/dev/null)"; then
    node -e "console.log(JSON.stringify({executablePath: process.argv[1], args: ['--no-sandbox']}))" "$chrome"
  else
    echo '{"args":["--no-sandbox"]}'
  fi
}

run_with_timeout() {
  local seconds="$1"
  shift
  "$@" &
  local pid=$!
  (
    sleep "$seconds"
    kill "$pid" 2>/dev/null
  ) &
  local watcher=$!
  if wait "$pid" 2>/dev/null; then
    wait "$watcher" 2>/dev/null || true
    return 0
  fi
  local status=$?
  wait "$watcher" 2>/dev/null || true
  return "$status"
}

run_md_to_pdf() {
  local input="$1"
  local basedir="$2"
  local launch_options="$3"

  local -a cmd
  if [[ "$FORCE_NPX" == true ]] || ! command -v md-to-pdf >/dev/null 2>&1; then
    cmd=(npx --yes "$MDTOPDF_PKG")
  else
    cmd=(md-to-pdf)
  fi

  cmd+=(--basedir "$basedir" --launch-options "$launch_options" "$input")

  $VERBOSE && log "Running: ${cmd[*]}"
  if ! run_with_timeout 120 "${cmd[@]}"; then
    fail "md-to-pdf timed out or failed after 120s"
  fi
}

write_frontmatter() {
  local dest="$1"
  local stylesheet="$2"
  local body_file="$3"
  local output="$4"

  cat > "$output" <<EOF
---
dest: ${dest}
stylesheet: ${stylesheet}
pdf_options:
  displayHeaderFooter: true
  footerTemplate: |-
    <div style="font-size: 10px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif; width: 100%; text-align: center;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>
  format: A4
  margin: 20mm 20mm 25mm 20mm
  printBackground: true
---
EOF
  cat "$body_file" >> "$output"
}

cleanup() {
  if [[ "${KEEP_ON_FAIL}" == true ]]; then
    log "Keeping workdir: ${WORKDIR}"
    return
  fi
  rm -rf "$WORKDIR"
}

on_error() {
  local code=$?
  log "Pipeline failed (exit ${code})."
  print_diagnostics
  if [[ -d "$WORKDIR" ]]; then
    log "Artifacts in: ${WORKDIR}"
    ls -la "$WORKDIR" 2>/dev/null || true
  fi
  cleanup
  exit "$code"
}

trap on_error ERR

print_diagnostics
if [[ "$DIAGNOSE_ONLY" == true ]]; then
  exit 0
fi

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cp "$FIXTURE" "${WORKDIR}/input.md"

SANDBOX="${WORKDIR}/sandbox"
mkdir -p "$SANDBOX"
cp "${WORKDIR}/input.md" "${SANDBOX}/input.md"

log "Step 1/3: render Mermaid"
puppeteer_config=""
chrome="$(resolve_chrome 2>/dev/null || true)"
if [[ -n "$chrome" ]]; then
  log "Using system Chrome for mmdc: ${chrome}"
  printf '{"executablePath":"%s","args":["--no-sandbox"]}\n' "$chrome" > "${SANDBOX}/puppeteer-config.json"
  puppeteer_config="${SANDBOX}/puppeteer-config.json"
fi

if [[ -n "$puppeteer_config" ]]; then
  run_mmdc "${SANDBOX}/input.md" "${SANDBOX}/input.tmp.md" "$puppeteer_config"
else
  run_mmdc "${SANDBOX}/input.md" "${SANDBOX}/input.tmp.md" || fail "mmdc failed and no Chrome/Chromium executable was found"
fi

[[ -f "${SANDBOX}/input.tmp.md" ]] || fail "mmdc did not produce input.tmp.md"
if grep -q '```mermaid' "${SANDBOX}/input.tmp.md"; then
  fail "input.tmp.md still contains raw mermaid blocks — mmdc did not render diagrams"
fi
log "Mermaid rendered: ${SANDBOX}/input.tmp.md"

log "Step 2/3: prepare PDF input"
write_frontmatter "$OUTPUT_PDF" "$STYLE" "${SANDBOX}/input.tmp.md" "${SANDBOX}/input.for-pdf.md"

log "Step 3/3: convert to PDF"
launch_options="$(build_launch_options)"
$VERBOSE && log "launch-options: ${launch_options}"
run_md_to_pdf "${SANDBOX}/input.for-pdf.md" "$SANDBOX" "$launch_options"

[[ -f "$OUTPUT_PDF" ]] || fail "Expected PDF not found: ${OUTPUT_PDF}"

size="$(wc -c < "$OUTPUT_PDF" | tr -d ' ')"
[[ "$size" -gt 1000 ]] || fail "PDF looks too small (${size} bytes): ${OUTPUT_PDF}"

log "OK: ${OUTPUT_PDF} (${size} bytes)"
rm -rf "$WORKDIR"
trap - ERR
exit 0
