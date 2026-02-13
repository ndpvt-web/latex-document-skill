#!/usr/bin/env bash
# compile_latex.sh - Compile .tex to .pdf and optionally generate PNG previews
#
# Usage:
#   compile_latex.sh <input.tex> [--preview] [--preview-dir <dir>] [--scale <pixels>]
#
# Options:
#   --preview         Generate PNG previews of each page
#   --preview-dir     Directory for PNG output (default: same as input)
#   --scale           Max dimension for PNG preview in pixels (default: 1200)
#
# Examples:
#   compile_latex.sh resume.tex
#   compile_latex.sh report.tex --preview
#   compile_latex.sh report.tex --preview --preview-dir ./outputs --scale 1600

set -euo pipefail

# --- Parse arguments ---
INPUT_TEX=""
PREVIEW=false
PREVIEW_DIR=""
SCALE=1200

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preview) PREVIEW=true; shift ;;
    --preview-dir) PREVIEW_DIR="$2"; shift 2 ;;
    --scale) SCALE="$2"; shift 2 ;;
    -*) echo "Error: Unknown option $1" >&2; exit 1 ;;
    *) INPUT_TEX="$1"; shift ;;
  esac
done

if [[ -z "$INPUT_TEX" ]]; then
  echo "Error: No input .tex file specified" >&2
  echo "Usage: compile_latex.sh <input.tex> [--preview] [--preview-dir <dir>] [--scale <pixels>]" >&2
  exit 1
fi

if [[ ! -f "$INPUT_TEX" ]]; then
  echo "Error: File not found: $INPUT_TEX" >&2
  exit 1
fi

# Resolve absolute paths
INPUT_TEX="$(realpath "$INPUT_TEX")"
INPUT_DIR="$(dirname "$INPUT_TEX")"
INPUT_BASE="$(basename "$INPUT_TEX" .tex)"
PDF_FILE="${INPUT_DIR}/${INPUT_BASE}.pdf"

if [[ -z "$PREVIEW_DIR" ]]; then
  PREVIEW_DIR="$INPUT_DIR"
fi

# --- Ensure TeX Live is installed ---
ensure_texlive() {
  if command -v pdflatex &>/dev/null; then
    return 0
  fi
  echo ":: pdflatex not found. Installing texlive..." >&2
  if command -v sudo &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq texlive-latex-base texlive-latex-extra texlive-fonts-recommended >&2
  elif command -v apt-get &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq texlive-latex-base texlive-latex-extra texlive-fonts-recommended >&2
  else
    echo "Error: Cannot install texlive - apt-get not available" >&2
    exit 1
  fi
  if ! command -v pdflatex &>/dev/null; then
    echo "Error: pdflatex still not available after install" >&2
    exit 1
  fi
  echo ":: texlive installed successfully" >&2
}

# --- Ensure poppler-utils for PDF-to-PNG ---
ensure_poppler() {
  if command -v pdftoppm &>/dev/null; then
    return 0
  fi
  echo ":: pdftoppm not found. Installing poppler-utils..." >&2
  if command -v sudo &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq poppler-utils >&2
  elif command -v apt-get &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq poppler-utils >&2
  else
    echo "Error: Cannot install poppler-utils - apt-get not available" >&2
    exit 1
  fi
}

# --- Compile ---
ensure_texlive

echo ":: Compiling ${INPUT_TEX}..."
cd "$INPUT_DIR"

# Run pdflatex twice to resolve references, TOC, etc.
pdflatex -interaction=nonstopmode -halt-on-error "$INPUT_TEX" >/dev/null 2>&1 || {
  echo ":: First pass had issues, running again for diagnostics..." >&2
  pdflatex -interaction=nonstopmode "$INPUT_TEX" 2>&1 | tail -30 >&2
  # Check if PDF was still produced
  if [[ ! -f "$PDF_FILE" ]]; then
    echo "Error: Compilation failed - no PDF produced" >&2
    exit 1
  fi
  echo ":: PDF produced despite warnings" >&2
}

# Second pass for cross-references
pdflatex -interaction=nonstopmode "$INPUT_TEX" >/dev/null 2>&1 || true

if [[ ! -f "$PDF_FILE" ]]; then
  echo "Error: PDF not produced" >&2
  exit 1
fi

echo ":: PDF created: ${PDF_FILE}"

# --- Generate PNG previews ---
if [[ "$PREVIEW" == true ]]; then
  ensure_poppler
  mkdir -p "$PREVIEW_DIR"

  PREVIEW_BASE="${PREVIEW_DIR}/${INPUT_BASE}"
  pdftoppm "$PDF_FILE" "$PREVIEW_BASE" -png -scale-to "$SCALE"

  # List generated PNGs
  PNG_COUNT=$(ls "${PREVIEW_BASE}"*.png 2>/dev/null | wc -l)
  echo ":: Generated ${PNG_COUNT} PNG preview(s) in ${PREVIEW_DIR}/"
  ls "${PREVIEW_BASE}"*.png 2>/dev/null
fi

# --- Clean auxiliary files ---
cd "$INPUT_DIR"
rm -f "${INPUT_BASE}.aux" "${INPUT_BASE}.log" "${INPUT_BASE}.out" \
      "${INPUT_BASE}.toc" "${INPUT_BASE}.lof" "${INPUT_BASE}.lot" \
      "${INPUT_BASE}.nav" "${INPUT_BASE}.snm" "${INPUT_BASE}.vrb" 2>/dev/null || true

echo ":: Done."
