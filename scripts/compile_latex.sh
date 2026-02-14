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
# Features:
#   - Auto-installs texlive if missing
#   - Detects .bib files and runs bibtex automatically
#   - Detects \makeindex and runs makeindex automatically
#   - Runs pdflatex multiple passes for cross-references
#   - Generates PNG previews with pdftoppm
#   - Cleans auxiliary files after compilation
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
  echo ":: pdflatex not found. Installing texlive (this may take several minutes)..." >&2
  local INSTALL_CMD="texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-latex-recommended"
  if command -v sudo &>/dev/null; then
    sudo apt-get update -q >&2 || { echo "Error: apt-get update failed" >&2; exit 1; }
    echo ":: Downloading and installing TeX Live packages..." >&2
    sudo apt-get install -y -q $INSTALL_CMD >&2 || { echo "Error: apt-get install failed" >&2; exit 1; }
  elif command -v apt-get &>/dev/null; then
    apt-get update -q >&2 || { echo "Error: apt-get update failed" >&2; exit 1; }
    echo ":: Downloading and installing TeX Live packages..." >&2
    apt-get install -y -q $INSTALL_CMD >&2 || { echo "Error: apt-get install failed" >&2; exit 1; }
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
    sudo apt-get update -q >&2 || { echo "Error: apt-get update failed" >&2; exit 1; }
    sudo apt-get install -y -q poppler-utils >&2 || { echo "Error: apt-get install poppler-utils failed" >&2; exit 1; }
  elif command -v apt-get &>/dev/null; then
    apt-get update -q >&2 || { echo "Error: apt-get update failed" >&2; exit 1; }
    apt-get install -y -q poppler-utils >&2 || { echo "Error: apt-get install poppler-utils failed" >&2; exit 1; }
  else
    echo "Error: Cannot install poppler-utils - apt-get not available" >&2
    exit 1
  fi
}

# --- Detect bibliography usage ---
detect_bibliography() {
  # Check if the .tex file uses \bibliography{} (BibTeX) or \addbibresource{} (biblatex)
  if grep -qE '\\bibliography\{' "$INPUT_TEX" 2>/dev/null; then
    echo "bibtex"
  elif grep -qE '\\addbibresource\{' "$INPUT_TEX" 2>/dev/null; then
    echo "biber"
  else
    echo "none"
  fi
}

# --- Detect makeindex usage ---
detect_makeindex() {
  grep -qE '\\makeindex|\\printindex' "$INPUT_TEX" 2>/dev/null
}

# --- Compile ---
ensure_texlive

echo ":: Compiling ${INPUT_TEX}..." >&2
cd "$INPUT_DIR"

BIB_ENGINE=$(detect_bibliography)
NEEDS_INDEX=false
if detect_makeindex; then
  NEEDS_INDEX=true
fi

if [[ "$BIB_ENGINE" != "none" ]]; then
  echo ":: Detected bibliography ($BIB_ENGINE) -- will run bibliography pass" >&2
fi
if [[ "$NEEDS_INDEX" == true ]]; then
  echo ":: Detected index -- will run makeindex" >&2
fi

# First pass - halt on error for quick failure detection
pdflatex -interaction=nonstopmode -halt-on-error "$INPUT_TEX" >/dev/null 2>&1 || {
  echo ":: First pass had errors. Running diagnostic pass..." >&2
  pdflatex -interaction=nonstopmode -halt-on-error "$INPUT_TEX" 2>&1 | tail -40 >&2
  # Check if PDF was still produced despite errors
  if [[ ! -f "$PDF_FILE" ]]; then
    echo "Error: Compilation failed - no PDF produced" >&2
    exit 1
  fi
  echo ":: PDF produced despite warnings" >&2
}

# Run bibliography engine if needed
if [[ "$BIB_ENGINE" == "bibtex" ]]; then
  echo ":: Running bibtex..." >&2
  bibtex "$INPUT_BASE" >/dev/null 2>&1 || {
    echo ":: bibtex had warnings (this is often normal for first run)" >&2
  }
elif [[ "$BIB_ENGINE" == "biber" ]]; then
  echo ":: Running biber..." >&2
  biber "$INPUT_BASE" >/dev/null 2>&1 || {
    echo ":: biber had warnings" >&2
  }
fi

# Run makeindex if needed
if [[ "$NEEDS_INDEX" == true ]]; then
  echo ":: Running makeindex..." >&2
  makeindex "$INPUT_BASE" >/dev/null 2>&1 || {
    echo ":: makeindex had warnings" >&2
  }
fi

# Second pass (resolves references after bibtex/biber/makeindex)
pdflatex -interaction=nonstopmode -halt-on-error "$INPUT_TEX" >/dev/null 2>&1 || true

# Third pass if bibliography or index was used (ensures all cross-refs resolved)
if [[ "$BIB_ENGINE" != "none" || "$NEEDS_INDEX" == true ]]; then
  echo ":: Running final pass for cross-references..." >&2
  pdflatex -interaction=nonstopmode -halt-on-error "$INPUT_TEX" >/dev/null 2>&1 || true
fi

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
      "${INPUT_BASE}.nav" "${INPUT_BASE}.snm" "${INPUT_BASE}.vrb" \
      "${INPUT_BASE}.bbl" "${INPUT_BASE}.blg" \
      "${INPUT_BASE}.idx" "${INPUT_BASE}.ilg" "${INPUT_BASE}.ind" \
      "${INPUT_BASE}.bcf" "${INPUT_BASE}.run.xml" 2>/dev/null || true

echo ":: Done."
