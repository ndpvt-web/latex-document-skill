#!/usr/bin/env bash
# compile_latex.sh - Compile .tex to .pdf and optionally generate PNG previews
#
# Usage:
#   compile_latex.sh <input.tex> [OPTIONS]
#
# Options:
#   --preview         Generate PNG previews of each page
#   --preview-dir     Directory for PNG output (default: same as input)
#   --scale           Max dimension for PNG preview in pixels (default: 1200)
#   --engine          LaTeX engine: pdflatex (default), xelatex, or lualatex
#   --auto-fix        Apply automatic fixes (naked floats, microtype) to temp copy before compiling
#   --use-latexmk     Use latexmk for compilation (automatic multi-pass, dependency tracking)
#   --verbose         Show full compilation output (default: summary only)
#   --quiet           Suppress all output except errors and final paths
#   --clean           Remove auxiliary files without recompiling
#   --pdfa            Produce PDF/A-compliant output (for thesis/archival submissions)
#
# Features:
#   - Auto-installs texlive if missing
#   - Auto-detects engine from document content (fontspec/xeCJK → xelatex)
#   - Detects .bib files and runs bibtex/biber automatically
#   - Detects \makeindex and runs makeindex automatically
#   - Detects \makeglossaries and runs makeglossaries automatically
#   - Runs multiple passes for cross-references
#   - Optional latexmk backend for automatic dependency resolution
#   - Optional texfot log filtering for cleaner output
#   - Generates PNG previews with pdftoppm
#   - Cleans auxiliary files after compilation
#   - Smart error recovery with --auto-fix:
#     * Automatically adds [htbp] to naked floats
#     * Auto-injects microtype for overfull hbox warnings
#   - Intelligent error parsing and helpful suggestions
#
# Examples:
#   compile_latex.sh resume.tex
#   compile_latex.sh report.tex --preview
#   compile_latex.sh report.tex --preview --preview-dir ./outputs --scale 1600
#   compile_latex.sh cjk-doc.tex --engine xelatex
#   compile_latex.sh document.tex --engine lualatex --preview
#   compile_latex.sh paper.tex --auto-fix
#   compile_latex.sh thesis.tex --use-latexmk --verbose
#   compile_latex.sh thesis.tex --pdfa
#   compile_latex.sh document.tex --clean

set -euo pipefail

# --- Usage function ---
usage() {
  cat <<'EOF'
compile_latex.sh - Compile .tex to .pdf and optionally generate PNG previews

Usage:
  compile_latex.sh <input.tex> [OPTIONS]

Options:
  --preview         Generate PNG previews of each page
  --preview-dir     Directory for PNG output (default: same as input)
  --scale           Max dimension for PNG preview in pixels (default: 1200)
  --engine          LaTeX engine: pdflatex (default), xelatex, or lualatex
  --auto-fix        Apply automatic fixes (naked floats, microtype) to temp copy before compiling
  --use-latexmk     Use latexmk for compilation (automatic multi-pass, dependency tracking)
  --verbose         Show full compilation output
  --quiet           Suppress all output except errors and final paths
  --clean           Remove auxiliary files without recompiling
  --pdfa            Produce PDF/A-compliant output (for thesis/archival submissions)

Features:
  - Auto-installs texlive if missing
  - Auto-detects engine from document content (fontspec/xeCJK → xelatex)
  - Detects .bib files and runs bibtex/biber automatically
  - Detects \makeindex and runs makeindex automatically
  - Detects \makeglossaries and runs makeglossaries automatically
  - Runs multiple passes for cross-references
  - Optional latexmk backend (--use-latexmk) for automatic dependency resolution
  - Optional texfot log filtering for cleaner output (used automatically when available)
  - Generates PNG previews with pdftoppm
  - Cleans auxiliary files after compilation
  - Smart error recovery with --auto-fix:
    * Automatically adds [htbp] to naked floats
    * Auto-injects microtype for overfull hbox warnings
  - Intelligent error parsing and helpful suggestions
  - PDF/A output for archival submissions (--pdfa)

Examples:
  compile_latex.sh resume.tex
  compile_latex.sh report.tex --preview
  compile_latex.sh report.tex --preview --preview-dir ./outputs --scale 1600
  compile_latex.sh cjk-doc.tex --engine xelatex
  compile_latex.sh document.tex --engine lualatex --preview
  compile_latex.sh paper.tex --auto-fix
  compile_latex.sh thesis.tex --use-latexmk --verbose
  compile_latex.sh thesis.tex --pdfa
  compile_latex.sh document.tex --clean
EOF
}

# --- Source cross-platform dependency installer ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# --- Parse arguments ---
INPUT_TEX=""
PREVIEW=false
PREVIEW_DIR=""
SCALE=1200
ENGINE=""
AUTO_FIX=false
USE_LATEXMK=false
VERBOSE=false
QUIET=false
CLEAN_ONLY=false
PDFA=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --preview) PREVIEW=true; shift ;;
    --preview-dir) PREVIEW_DIR="$2"; shift 2 ;;
    --scale) SCALE="$2"; shift 2 ;;
    --engine) ENGINE="$2"; shift 2 ;;
    --auto-fix) AUTO_FIX=true; shift ;;
    --use-latexmk) USE_LATEXMK=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --quiet) QUIET=true; shift ;;
    --clean) CLEAN_ONLY=true; shift ;;
    --pdfa) PDFA=true; shift ;;
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

# --- Logging helpers (respect --verbose / --quiet) ---
log_info() {
  [[ "$QUIET" == true ]] && return
  echo ":: $*" >&2
}

log_detail() {
  [[ "$VERBOSE" != true ]] && return
  echo "   $*" >&2
}

# --- Handle --clean mode (remove aux files and exit) ---
if [[ "$CLEAN_ONLY" == true ]]; then
  log_info "Cleaning auxiliary files for ${INPUT_BASE}..."
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
        "${INPUT_BASE}.synctex.gz" "${INPUT_BASE}.xdv" \
        "${INPUT_BASE}.pytxcode" 2>/dev/null || true
  log_info "Auxiliary files cleaned."
  exit 0
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
  # Filter out commented lines (starting with %) before checking
  local uncommented
  uncommented=$(sed 's/%.*//;/^[[:space:]]*$/d' "$INPUT_TEX" 2>/dev/null)
  if echo "$uncommented" | grep -qE '\\usepackage\{fontspec\}|\\usepackage\{xeCJK\}|\\usepackage\{polyglossia\}'; then
    echo "xelatex"
  elif echo "$uncommented" | grep -qE '\\usepackage\{luacode\}|\\usepackage\{luatextra\}|\\directlua'; then
    echo "lualatex"
  else
    echo "pdflatex"
  fi
}

# --- Detect bibliography usage ---
detect_bibliography() {
  # Filter out comments (both full-line and inline) before checking
  local uncommented
  uncommented=$(sed 's/%.*//;/^[[:space:]]*$/d' "$INPUT_TEX" 2>/dev/null)
  if echo "$uncommented" | grep -qE '\\bibliography\{'; then
    echo "bibtex"
  elif echo "$uncommented" | grep -qE '\\addbibresource\{'; then
    echo "biber"
  else
    echo "none"
  fi
}

# --- Detect makeindex usage ---
detect_makeindex() {
  local uncommented
  uncommented=$(sed 's/%.*//;/^[[:space:]]*$/d' "$INPUT_TEX" 2>/dev/null)
  echo "$uncommented" | grep -qE '\\makeindex|\\printindex'
}

# --- Detect glossary usage ---
detect_glossary() {
  local uncommented
  uncommented=$(sed 's/%.*//;/^[[:space:]]*$/d' "$INPUT_TEX" 2>/dev/null)
  echo "$uncommented" | grep -qE '\\makeglossaries|\\printglossary|\\printglossaries|\\newacronym'
}

# --- Parse and translate common LaTeX errors ---
parse_errors() {
  local log_file="$1"
  if [[ ! -f "$log_file" ]]; then
    return
  fi

  echo "" >&2
  echo "=== LaTeX Error Analysis ===" >&2

  # Check for missing packages
  if grep -q "File \`.*\.sty' not found" "$log_file"; then
    echo "" >&2
    grep "File \`.*\.sty' not found" "$log_file" | sed -E 's/.*File `(.*)\.sty.*/Missing package: \1/' | while read -r line; do
      package=$(echo "$line" | sed 's/Missing package: //')
      echo "  ! $line" >&2
      echo "    → Install with: sudo apt-get install texlive-latex-extra" >&2
      echo "    → Or try: tlmgr install $package" >&2
    done
  fi

  # Check for math mode errors
  if grep -q "Missing \$ inserted" "$log_file"; then
    echo "" >&2
    echo "  ! Math mode error: You used a math symbol outside of \$ delimiters" >&2
    grep -n "Missing \$ inserted" "$log_file" | head -5 | sed 's/^/    Line /' >&2
    echo "    → Wrap math symbols with \$...\$ or use \\(...\\) for inline math" >&2
  fi

  # Check for undefined control sequences
  if grep -q "Undefined control sequence" "$log_file"; then
    echo "" >&2
    echo "  ! Undefined control sequence(s) detected" >&2
    grep -A1 "Undefined control sequence" "$log_file" | grep "^l\.[0-9]" | head -5 | while read -r line; do
      linenum=$(echo "$line" | sed -E 's/^l\.([0-9]+).*/\1/')
      cmd=$(echo "$line" | sed -E 's/.*\\([a-zA-Z]+).*/\\\1/')
      echo "    Line $linenum: Unknown command '$cmd'" >&2
    done
    echo "    → Check spelling or add the required \\usepackage" >&2
  fi

  # Check for missing \begin{document}
  if grep -q "Missing .begin.document." "$log_file"; then
    echo "" >&2
    echo "  ! Your document is missing \\begin{document}" >&2
    echo "    → Add \\begin{document} after the preamble (after all \\usepackage lines)" >&2
  fi

  # Check for unbalanced braces
  if grep -q "Too many }'s" "$log_file"; then
    echo "" >&2
    echo "  ! Unbalanced braces detected" >&2
    grep -n "Too many }'s" "$log_file" | head -3 | sed 's/^/    /' >&2
    echo "    → Check for missing { or extra }" >&2
  fi

  # Check for undefined environments
  if grep -q "LaTeX Error: Environment .* undefined" "$log_file"; then
    echo "" >&2
    grep "LaTeX Error: Environment .* undefined" "$log_file" | sed -E 's/.*Environment (.*) undefined.*/  ! Environment "\1" not defined/' | head -3 >&2
    echo "    → Add the required \\usepackage for this environment" >&2
  fi

  # Check for overfull hbox (margin overflow)
  local overfull_count=0
  if [[ -f "$log_file" ]]; then
    overfull_count=$(grep -c "Overfull .hbox" "$log_file" 2>/dev/null || true)
    overfull_count=${overfull_count:-0}
  fi
  if [[ "$overfull_count" -gt 0 ]]; then
    echo "" >&2
    echo "  ! Found $overfull_count overfull hbox warning(s) - text overflows margins" >&2
    if [[ "$AUTO_FIX" == true ]]; then
      echo "    → Auto-fix will attempt to apply microtype package" >&2
    else
      echo "    → Consider adding \\usepackage{microtype} to preamble" >&2
      echo "    → Or use --auto-fix flag to apply automatically" >&2
    fi
  fi

  # Check for undefined citations
  if grep -q "Citation .* undefined" "$log_file"; then
    echo "" >&2
    echo "  ! Undefined citation(s) detected" >&2
    grep "Citation .* undefined" "$log_file" | sed -E "s/.*Citation \`(.*)' .*/    '\1'/" | sort -u | head -5 >&2
    echo "    → Check spelling or ensure your .bib file is correct" >&2
    echo "    → Make sure bibliography engine ran (bibtex/biber)" >&2
  fi

  echo "" >&2
}

# --- Auto-fix floats (adds [htbp] to naked floats) ---
auto_fix_floats() {
  local input_file="$1"
  local output_file="$2"

  # Copy input to output
  cp "$input_file" "$output_file"

  # Fix naked floats - add [htbp] to figure and table environments without placement specifiers
  # Two passes: (1) end-of-line case, (2) mid-line case where next char is not [
  # Pass 1: \begin{figure} at end of line (nothing or whitespace follows)
  sed -i.bak -E 's/\\begin\{(figure|table)\}[[:space:]]*$/\\begin{\1}[htbp]/g' "$output_file"
  rm -f "${output_file}.bak"
  # Pass 2: \begin{figure} followed by non-[ character (mid-line)
  sed -i.bak -E 's/\\begin\{(figure|table)\}([^[[])/\\begin{\1}[htbp]\2/g' "$output_file"
  rm -f "${output_file}.bak"

  # Count how many fixes were made
  local fixed_count=$(grep -o '\\begin{figure}\[htbp\]\|\\begin{table}\[htbp\]' "$output_file" 2>/dev/null | wc -l)
  if [[ $fixed_count -gt 0 ]]; then
    echo "  → Fixed $fixed_count naked float(s) by adding [htbp] placement" >&2
  fi
}

# --- Auto-inject microtype if needed ---
auto_inject_microtype() {
  local input_file="$1"
  local output_file="$2"

  # Check if microtype is already present
  if grep -q '\\usepackage.*{microtype}' "$input_file"; then
    echo "  → microtype already present, skipping injection" >&2
    cp "$input_file" "$output_file"
    return
  fi

  # Find the last \usepackage line and inject microtype after it
  # If no \usepackage found, inject after \documentclass
  if grep -q '\\usepackage' "$input_file"; then
    # Find line number of last \usepackage
    local last_pkg_line=$(grep -n '\\usepackage' "$input_file" | tail -1 | cut -d: -f1)
    # Insert after that line
    awk -v line="$last_pkg_line" 'NR==line {print; print "\\usepackage{microtype} % Auto-injected for better spacing"; next} {print}' "$input_file" > "$output_file"
    echo "  → Injected \\usepackage{microtype} after line $last_pkg_line" >&2
  elif grep -q '\\documentclass' "$input_file"; then
    local docclass_line=$(grep -n '\\documentclass' "$input_file" | head -1 | cut -d: -f1)
    awk -v line="$docclass_line" 'NR==line {print; print "\\usepackage{microtype} % Auto-injected for better spacing"; next} {print}' "$input_file" > "$output_file"
    echo "  → Injected \\usepackage{microtype} after \\documentclass" >&2
  else
    # Fallback: just copy
    cp "$input_file" "$output_file"
  fi
}

# --- Run engine command with optional texfot filtering ---
# Uses texfot when available and not in verbose mode, to show only relevant warnings/errors.
run_engine() {
  local engine="$1"
  shift
  local texfile="$1"
  shift

  if [[ "$VERBOSE" == true ]]; then
    # Verbose: show full output
    "$engine" -interaction=nonstopmode "$@" "$texfile" >&2
  elif [[ "$QUIET" == true ]]; then
    # Quiet: suppress everything
    "$engine" -interaction=nonstopmode "$@" "$texfile" >/dev/null 2>&1
  elif command -v texfot &>/dev/null; then
    # Default with texfot: filtered output
    texfot "$engine" -interaction=nonstopmode "$@" "$texfile" >&2 2>/dev/null
  else
    # Default without texfot: suppress output
    "$engine" -interaction=nonstopmode "$@" "$texfile" >/dev/null 2>&1
  fi
}

# --- PDF/A injection: add pdfx package to preamble ---
pdfa_inject() {
  local input_file="$1"
  local output_file="$2"

  # Check if pdfx or pdfmanagement is already present
  if grep -qE '\\usepackage(\[.*\])?\{pdfx\}|\\usepackage(\[.*\])?\{pdfmanagement-testphase\}' "$input_file"; then
    log_detail "PDF/A package already present, skipping injection"
    cp "$input_file" "$output_file"
    return
  fi

  # Find the \documentclass line and inject \usepackage{pdfx} right after it
  # pdfx must be loaded very early (before hyperref, before most other packages)
  if grep -q '\\documentclass' "$input_file"; then
    local docclass_line
    docclass_line=$(grep -n '\\documentclass' "$input_file" | head -1 | cut -d: -f1)
    awk -v line="$docclass_line" 'NR==line {print; print "\\usepackage[a-2b]{pdfx} % Auto-injected for PDF/A compliance"; next} {print}' "$input_file" > "$output_file"
    log_info "Injected \\usepackage[a-2b]{pdfx} for PDF/A output"
  else
    cp "$input_file" "$output_file"
  fi
}

# --- latexmk compilation backend ---
compile_with_latexmk() {
  local engine="$1"
  local texfile="$2"

  # Determine latexmk engine flag
  local lmk_flag
  case "$engine" in
    pdflatex)  lmk_flag="-pdf" ;;
    xelatex)   lmk_flag="-xelatex" ;;
    lualatex)  lmk_flag="-lualatex" ;;
    *)         lmk_flag="-pdf" ;;
  esac

  log_info "Using latexmk (${engine}) for automatic multi-pass compilation..."

  local latexmk_exit=0
  if [[ "$VERBOSE" == true ]]; then
    latexmk "$lmk_flag" -interaction=nonstopmode "$texfile" >&2 || latexmk_exit=$?
  elif [[ "$QUIET" == true ]]; then
    latexmk "$lmk_flag" -interaction=nonstopmode -quiet "$texfile" >/dev/null 2>&1 || latexmk_exit=$?
  elif command -v texfot &>/dev/null; then
    texfot latexmk "$lmk_flag" -interaction=nonstopmode "$texfile" >&2 2>/dev/null || latexmk_exit=$?
  else
    latexmk "$lmk_flag" -interaction=nonstopmode -quiet "$texfile" >/dev/null 2>&1 || latexmk_exit=$?
  fi

  return $latexmk_exit
}

# --- Compile ---
ensure_texlive

LATEX_ENGINE=$(detect_engine)
log_info "Compiling ${INPUT_TEX} with ${LATEX_ENGINE}..."
cd "$INPUT_DIR"

# --- Auto-fix / PDF/A workflow: create temp copy if needed ---
WORKING_TEX="$INPUT_TEX"
TEMP_TEX=""
TEMP_DIR=""
if [[ "$AUTO_FIX" == true || "$PDFA" == true ]]; then
  if [[ "$AUTO_FIX" == true ]]; then
    log_info "Auto-fix enabled - creating temporary working copy..."
  fi
  if [[ "$PDFA" == true ]]; then
    log_info "PDF/A mode enabled"
  fi
  TEMP_DIR=$(mktemp -d)
  TEMP_TEX="${TEMP_DIR}/${INPUT_BASE}.tex"

  # Copy all files from input directory to temp dir (for .bib, images, etc.)
  cp -a "${INPUT_DIR}/"* "$TEMP_DIR/" 2>/dev/null || true

  if [[ "$AUTO_FIX" == true ]]; then
    # Stage 1: Fix naked floats
    log_info "Stage 1: Checking for naked floats..."
    auto_fix_floats "$INPUT_TEX" "$TEMP_TEX"
  else
    cp "$INPUT_TEX" "$TEMP_TEX"
  fi

  # Inject PDF/A package if requested
  if [[ "$PDFA" == true ]]; then
    local_pdfa_tmp="${TEMP_DIR}/${INPUT_BASE}_pdfa.tex"
    pdfa_inject "$TEMP_TEX" "$local_pdfa_tmp"
    mv "$local_pdfa_tmp" "$TEMP_TEX"
  fi

  WORKING_TEX="$TEMP_TEX"
  # Change to temp dir for compilation
  cd "$TEMP_DIR"
fi

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
  log_info "Using engine: $LATEX_ENGINE"
fi
if [[ "$BIB_ENGINE" != "none" ]]; then
  log_info "Detected bibliography ($BIB_ENGINE) -- will run bibliography pass"
fi
if [[ "$NEEDS_INDEX" == true ]]; then
  log_info "Detected index -- will run makeindex"
fi
if [[ "$NEEDS_GLOSSARY" == true ]]; then
  log_info "Detected glossary -- will run makeglossaries"
fi
if command -v texfot &>/dev/null && [[ "$VERBOSE" != true && "$QUIET" != true ]]; then
  log_detail "texfot available -- using filtered log output"
fi

# Determine log file location (depends on auto-fix/pdfa mode)
if [[ -n "$TEMP_DIR" ]]; then
  LOG_FILE="${TEMP_DIR}/${INPUT_BASE}.log"
else
  LOG_FILE="${INPUT_DIR}/${INPUT_BASE}.log"
fi

# Check for PDF in correct location (temp dir for auto-fix/pdfa, input dir otherwise)
ACTUAL_PDF="$PDF_FILE"
if [[ -n "$TEMP_DIR" ]]; then
  ACTUAL_PDF="${TEMP_DIR}/${INPUT_BASE}.pdf"
fi

# =================================================================
# COMPILATION: latexmk branch vs manual multi-pass branch
# =================================================================
if [[ "$USE_LATEXMK" == true ]]; then
  # --- latexmk backend ---
  if ! command -v latexmk &>/dev/null; then
    echo "Error: latexmk not found. Install with: sudo apt-get install latexmk" >&2
    echo "Or remove --use-latexmk to use the built-in multi-pass engine." >&2
    [[ -n "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    exit 1
  fi

  LATEXMK_EXIT=0
  compile_with_latexmk "$LATEX_ENGINE" "$WORKING_TEX" || LATEXMK_EXIT=$?

  if [[ $LATEXMK_EXIT -ne 0 && ! -f "$ACTUAL_PDF" ]]; then
    echo "Error: latexmk compilation failed - no PDF produced" >&2
    parse_errors "$LOG_FILE"
    [[ -n "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    exit 1
  fi
  if [[ $LATEXMK_EXIT -ne 0 && -f "$ACTUAL_PDF" ]]; then
    log_info "latexmk had warnings (PDF still produced)"
  fi

else
  # --- Manual multi-pass backend (original logic) ---

  # First pass
  FIRST_PASS_EXIT=0
  run_engine "$LATEX_ENGINE" "$WORKING_TEX" || FIRST_PASS_EXIT=$?

  if [[ $FIRST_PASS_EXIT -ne 0 && ! -f "$ACTUAL_PDF" ]]; then
    log_info "First pass failed. Running diagnostic pass..."
    "$LATEX_ENGINE" -interaction=nonstopmode "$WORKING_TEX" 2>&1 | tail -50 >&2
    if [[ ! -f "$ACTUAL_PDF" ]]; then
      echo "Error: Compilation failed - no PDF produced" >&2
      parse_errors "$LOG_FILE"
      [[ -n "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
      exit 1
    fi
  fi
  if [[ $FIRST_PASS_EXIT -ne 0 && -f "$ACTUAL_PDF" ]]; then
    log_info "First pass had warnings (PDF still produced)"
  fi

  # Auto-fix Stage 2: Check for overfull hbox and inject microtype if needed
  if [[ "$AUTO_FIX" == true && -f "$LOG_FILE" ]]; then
    OVERFULL_COUNT=$(grep -c "Overfull \\\\hbox" "$LOG_FILE" 2>/dev/null || true)
    OVERFULL_COUNT=${OVERFULL_COUNT:-0}
    if [[ "$OVERFULL_COUNT" -gt 0 ]]; then
      log_info "Stage 2: Detected $OVERFULL_COUNT overfull hbox warnings"
      TEMP_TEX2="${TEMP_DIR}/${INPUT_BASE}_microtype.tex"
      auto_inject_microtype "$TEMP_TEX" "$TEMP_TEX2"
      WORKING_TEX="$TEMP_TEX2"

      log_info "Recompiling with microtype..."
      run_engine "$LATEX_ENGINE" "$WORKING_TEX" || true
    fi
  fi

  # Run bibliography engine if needed
  if [[ "$BIB_ENGINE" == "bibtex" ]]; then
    log_info "Running bibtex..."
    bibtex "$INPUT_BASE" >/dev/null 2>&1 || {
      log_info "bibtex had warnings (this is often normal for first run)"
    }
  elif [[ "$BIB_ENGINE" == "biber" ]]; then
    log_info "Running biber..."
    biber "$INPUT_BASE" >/dev/null 2>&1 || {
      log_info "biber had warnings"
    }
  fi

  # Run makeindex if needed
  if [[ "$NEEDS_INDEX" == true ]]; then
    log_info "Running makeindex..."
    makeindex "$INPUT_BASE" >/dev/null 2>&1 || {
      log_info "makeindex had warnings"
    }
  fi

  # Run makeglossaries if needed
  if [[ "$NEEDS_GLOSSARY" == true ]]; then
    log_info "Running makeglossaries..."
    makeglossaries "$INPUT_BASE" >/dev/null 2>&1 || {
      log_info "makeglossaries had warnings (ensure glossaries package is installed)"
    }
  fi

  # Second pass (resolves references after bibtex/biber/makeindex/glossaries)
  run_engine "$LATEX_ENGINE" "$WORKING_TEX" || true

  # Third pass if bibliography, index, or glossary was used (final cross-ref resolution)
  if [[ "$BIB_ENGINE" != "none" || "$NEEDS_INDEX" == true || "$NEEDS_GLOSSARY" == true ]]; then
    log_info "Running final pass for cross-references..."
    run_engine "$LATEX_ENGINE" "$WORKING_TEX" || true
  fi

fi

# Handle PDF location based on temp dir mode (auto-fix or pdfa)
if [[ -n "$TEMP_DIR" ]]; then
  TEMP_PDF="${TEMP_DIR}/${INPUT_BASE}.pdf"
  if [[ ! -f "$TEMP_PDF" ]]; then
    echo "Error: PDF not produced" >&2
    parse_errors "$LOG_FILE"
    rm -rf "$TEMP_DIR"
    exit 1
  fi
  # Copy PDF back to original location
  cp "$TEMP_PDF" "$PDF_FILE"
  log_info "PDF created: ${PDF_FILE}"
  if [[ "$AUTO_FIX" == true ]]; then
    log_detail "(compiled from auto-fixed temporary copy)"
  fi
  if [[ "$PDFA" == true ]]; then
    log_detail "(PDF/A-2b compliant)"
  fi
else
  if [[ ! -f "$PDF_FILE" ]]; then
    echo "Error: PDF not produced" >&2
    parse_errors "$LOG_FILE"
    exit 1
  fi
  log_info "PDF created: ${PDF_FILE}"
fi

# Run error analysis on successful compilation (for warnings/suggestions)
if [[ -f "$LOG_FILE" && "$QUIET" != true ]]; then
  parse_errors "$LOG_FILE"
fi

# --- Generate PNG previews ---
if [[ "$PREVIEW" == true ]]; then
  ensure_poppler
  mkdir -p "$PREVIEW_DIR"

  PREVIEW_BASE="${PREVIEW_DIR}/${INPUT_BASE}"
  pdftoppm "$PDF_FILE" "$PREVIEW_BASE" -png -scale-to "$SCALE"

  # List generated PNGs
  PNG_COUNT=$(ls "${PREVIEW_BASE}"*.png 2>/dev/null | wc -l)
  log_info "Generated ${PNG_COUNT} PNG preview(s) in ${PREVIEW_DIR}/"
  if [[ "$QUIET" != true ]]; then
    ls "${PREVIEW_BASE}"*.png 2>/dev/null
  fi
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

# Clean up temp directory if auto-fix was used
if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
  rm -rf "$TEMP_DIR"
fi

log_info "Done."
