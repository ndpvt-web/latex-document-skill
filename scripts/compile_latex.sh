#!/usr/bin/env bash
# compile_latex.sh - Compile .tex to .pdf and optionally generate PNG previews
#
# Usage:
#   compile_latex.sh <input.tex> [--preview] [--preview-dir <dir>] [--scale <pixels>] [--engine <engine>]
#
# Options:
#   --preview         Generate PNG previews of each page
#   --preview-dir     Directory for PNG output (default: same as input)
#   --scale           Max dimension for PNG preview in pixels (default: 1200)
#   --engine          LaTeX engine: pdflatex (default), xelatex, or lualatex
#
# Features:
#   - Auto-installs texlive if missing
#   - Auto-detects engine from document content (fontspec/xeCJK → xelatex)
#   - Detects .bib files and runs bibtex/biber automatically
#   - Detects \makeindex and runs makeindex automatically
#   - Detects \makeglossaries and runs makeglossaries automatically
#   - Runs multiple passes for cross-references
#   - Generates PNG previews with pdftoppm
#   - Cleans auxiliary files after compilation
#
# Examples:
#   compile_latex.sh resume.tex
#   compile_latex.sh report.tex --preview
#   compile_latex.sh report.tex --preview --preview-dir ./outputs --scale 1600
#   compile_latex.sh cjk-doc.tex --engine xelatex
#   compile_latex.sh document.tex --engine lualatex --preview

set -euo pipefail

# --- Source cross-platform dependency installer ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# --- Parse arguments ---
INPUT_TEX=""
PREVIEW=false
PREVIEW_DIR=""
SCALE=1200
ENGINE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preview) PREVIEW=true; shift ;;
    --preview-dir) PREVIEW_DIR="$2"; shift 2 ;;
    --scale) SCALE="$2"; shift 2 ;;
    --engine) ENGINE="$2"; shift 2 ;;
    -*) echo "Error: Unknown option $1" >&2; exit 1 ;;
    *) INPUT_TEX="$1"; shift ;;
  esac
done

if [[ -z "$INPUT_TEX" ]]; then
  echo "Error: No input .tex file specified" >&2
  echo "Usage: compile_latex.sh <input.tex> [--preview] [--preview-dir <dir>] [--scale <pixels>] [--engine <engine>]" >&2
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
  echo ":: pdflatex not found. Installing TeX Live (this may take several minutes)..." >&2
  install_packages "texlive" || {
    echo "Error: Failed to install TeX Live." >&2
    print_install_help "texlive"
    exit 1
  }
  _brew_post_texlive
  if ! command -v pdflatex &>/dev/null; then
    echo "Error: pdflatex still not available after install" >&2
    print_install_help "texlive"
    exit 1
  fi
  echo ":: TeX Live installed successfully" >&2
}

# --- Ensure poppler-utils for PDF-to-PNG ---
ensure_poppler() {
  if command -v pdftoppm &>/dev/null; then
    return 0
  fi
  echo ":: pdftoppm not found. Installing poppler..." >&2
  install_packages "poppler" || {
    echo "Error: Failed to install poppler." >&2
    print_install_help "poppler"
    exit 1
  }
}

# --- Auto-detect engine from document content ---
detect_engine() {
  # If user specified engine, use that
  if [[ -n "$ENGINE" ]]; then
    echo "$ENGINE"
    return
  fi
  # Check for packages that require XeLaTeX/LuaLaTeX
  if grep -qE '\\usepackage\{fontspec\}|\\usepackage\{xeCJK\}|\\usepackage\{polyglossia\}' "$INPUT_TEX" 2>/dev/null; then
    echo "xelatex"
  elif grep -qE '\\usepackage\{luacode\}|\\usepackage\{luatextra\}|\\directlua' "$INPUT_TEX" 2>/dev/null; then
    echo "lualatex"
  else
    echo "pdflatex"
  fi
}

# --- Detect bibliography usage ---
detect_bibliography() {
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

# --- Detect glossary usage ---
detect_glossary() {
  grep -qE '\\makeglossaries|\\printglossary|\\printglossaries|\\newacronym' "$INPUT_TEX" 2>/dev/null
}

# --- Compile ---
ensure_texlive

LATEX_ENGINE=$(detect_engine)
echo ":: Compiling ${INPUT_TEX} with ${LATEX_ENGINE}..." >&2
cd "$INPUT_DIR"

BIB_ENGINE=$(detect_bibliography)
NEEDS_INDEX=false
NEEDS_GLOSSARY=false
if detect_makeindex; then
  NEEDS_INDEX=true
fi
if detect_glossary; then
  NEEDS_GLOSSARY=true
fi

if [[ "$LATEX_ENGINE" != "pdflatex" ]]; then
  echo ":: Using engine: $LATEX_ENGINE" >&2
fi
if [[ "$BIB_ENGINE" != "none" ]]; then
  echo ":: Detected bibliography ($BIB_ENGINE) -- will run bibliography pass" >&2
fi
if [[ "$NEEDS_INDEX" == true ]]; then
  echo ":: Detected index -- will run makeindex" >&2
fi
if [[ "$NEEDS_GLOSSARY" == true ]]; then
  echo ":: Detected glossary -- will run makeglossaries" >&2
fi

# First pass (nonstopmode to continue past warnings like undefined refs)
FIRST_PASS_EXIT=0
$LATEX_ENGINE -interaction=nonstopmode "$INPUT_TEX" >/dev/null 2>&1 || FIRST_PASS_EXIT=$?
if [[ $FIRST_PASS_EXIT -ne 0 && ! -f "$PDF_FILE" ]]; then
  echo ":: First pass failed. Running diagnostic pass..." >&2
  $LATEX_ENGINE -interaction=nonstopmode "$INPUT_TEX" 2>&1 | tail -50 >&2
  if [[ ! -f "$PDF_FILE" ]]; then
    echo "Error: Compilation failed - no PDF produced" >&2
    exit 1
  fi
fi
if [[ $FIRST_PASS_EXIT -ne 0 && -f "$PDF_FILE" ]]; then
  echo ":: First pass had warnings (PDF still produced)" >&2
fi

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

# Run makeglossaries if needed
if [[ "$NEEDS_GLOSSARY" == true ]]; then
  echo ":: Running makeglossaries..." >&2
  makeglossaries "$INPUT_BASE" >/dev/null 2>&1 || {
    echo ":: makeglossaries had warnings (ensure glossaries package is installed)" >&2
  }
fi

# Second pass (resolves references after bibtex/biber/makeindex/glossaries)
$LATEX_ENGINE -interaction=nonstopmode "$INPUT_TEX" >/dev/null 2>&1 || true

# Third pass if bibliography, index, or glossary was used (final cross-ref resolution)
if [[ "$BIB_ENGINE" != "none" || "$NEEDS_INDEX" == true || "$NEEDS_GLOSSARY" == true ]]; then
  echo ":: Running final pass for cross-references..." >&2
  $LATEX_ENGINE -interaction=nonstopmode "$INPUT_TEX" >/dev/null 2>&1 || true
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
      "${INPUT_BASE}.bcf" "${INPUT_BASE}.run.xml" \
      "${INPUT_BASE}.glo" "${INPUT_BASE}.gls" "${INPUT_BASE}.glg" \
      "${INPUT_BASE}.ist" "${INPUT_BASE}.acn" "${INPUT_BASE}.acr" \
      "${INPUT_BASE}.alg" "${INPUT_BASE}.fls" "${INPUT_BASE}.fdb_latexmk" \
      "${INPUT_BASE}.synctex.gz" 2>/dev/null || true

echo ":: Done."
