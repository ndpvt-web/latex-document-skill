#!/usr/bin/env bash
# setup.sh - LaTeX Document Skill - One-Click Setup
#
# Installs all system and Python dependencies needed by the skill.
# Supports: Debian/Ubuntu (apt), macOS (brew), Fedora/RHEL (dnf),
#           Alpine (apk), Arch Linux (pacman).
#
# Usage:
#   bash setup.sh           # Install everything
#   bash setup.sh --check   # Only run verification (no installs)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/install_deps.sh"

CHECK_ONLY=false
if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
fi

echo "========================================"
echo "  LaTeX Document Skill - Setup"
echo "========================================"
echo ""
echo ":: Detected package manager: $(detect_pkg_manager)"
echo ""

# --- Phase 1: System packages ---
if [[ "$CHECK_ONLY" == false ]]; then
  echo "--- Phase 1: System Packages ---"
  echo ""

  echo ":: Installing TeX Live (LaTeX compiler)..."
  if command -v pdflatex &>/dev/null; then
    echo "   Already installed: $(pdflatex --version | head -n1)"
  else
    install_packages "texlive" || echo "   WARNING: TeX Live installation failed. Install manually."
    _brew_post_texlive
  fi
  echo ""

  echo ":: Installing Poppler (PDF utilities)..."
  if command -v pdftoppm &>/dev/null; then
    echo "   Already installed."
  else
    install_packages "poppler" || echo "   WARNING: Poppler installation failed. Install manually."
  fi
  echo ""

  echo ":: Installing ImageMagick (image processing)..."
  if command -v mogrify &>/dev/null; then
    echo "   Already installed."
  else
    install_packages "imagemagick" || echo "   WARNING: ImageMagick installation failed. Install manually."
  fi
  echo ""

  echo ":: Installing Pandoc (document conversion)..."
  if command -v pandoc &>/dev/null; then
    echo "   Already installed: $(pandoc --version | head -n1)"
  else
    install_packages "pandoc" || echo "   WARNING: Pandoc installation failed. Install manually."
  fi
  echo ""

  echo ":: Checking latexmk (build automation)..."
  if command -v latexmk &>/dev/null; then
    echo "   Already installed: $(latexmk --version 2>/dev/null | head -n1)"
  else
    echo "   latexmk not found. It is usually included with texlive."
    echo "   Install with: sudo apt-get install latexmk (or equivalent)"
    echo "   Note: latexmk is optional -- the compile script works without it."
  fi
  echo ""

  echo ":: Checking texfot (log filtering)..."
  if command -v texfot &>/dev/null; then
    echo "   Already installed."
  else
    echo "   texfot not found. It is usually included with texlive."
    echo "   Install with: sudo apt-get install texlive-extra-utils (or equivalent)"
    echo "   Note: texfot is optional -- compilation works without it."
  fi
  echo ""

  # --- Phase 2: Python packages ---
  echo "--- Phase 2: Python Packages ---"
  echo ""

  if command -v python3 &>/dev/null; then
    echo ":: Installing Python dependencies from requirements.txt..."
    python3 -m pip install -q -r "${SCRIPT_DIR}/requirements.txt" 2>&1 | grep -v "already satisfied" || {
      # PEP 668: externally-managed-environment (Debian 12+, Ubuntu 23.04+)
      echo "   Retrying with --break-system-packages (PEP 668 environment)..." >&2
      python3 -m pip install -q --break-system-packages -r "${SCRIPT_DIR}/requirements.txt" 2>&1 | grep -v "already satisfied" || true
    }
    echo "   Done."
  else
    echo "   WARNING: python3 not found. Skipping Python package installation."
    echo "   Install Python 3 and run: pip install -r requirements.txt"
  fi
  echo ""

  # --- Phase 3: Node.js check ---
  echo "--- Phase 3: Node.js (Optional - for Mermaid diagrams) ---"
  echo ""

  if command -v npx &>/dev/null; then
    echo "   Node.js available: $(node --version 2>/dev/null || echo 'unknown version')"
    NODE_VER=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
    if [[ -n "$NODE_VER" ]] && [[ "$NODE_VER" -lt 18 ]]; then
      echo "   WARNING: Node.js v${NODE_VER} detected. Mermaid CLI requires Node 18+."
    fi
  else
    echo "   Node.js/npx not found. Mermaid diagram conversion will not work."
    echo "   This is optional -- all other features work without Node.js."
    echo "   Install from: https://nodejs.org/"
  fi
  echo ""
fi

# --- Phase 4: Verification ---
echo "--- Verification ---"
echo ""

PASS=0
TOTAL=9

check_cmd() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  [OK]   $name"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $name"
  fi
}

check_cmd "pdflatex (TeX Live)"    "command -v pdflatex"
check_cmd "xelatex  (XeLaTeX)"     "command -v xelatex"
check_cmd "biber    (Bibliography)" "command -v biber"
check_cmd "latexmk  (Build Auto)"  "command -v latexmk"
check_cmd "texfot   (Log Filter)"  "command -v texfot"
check_cmd "pdftoppm (Poppler)"      "command -v pdftoppm"
check_cmd "mogrify  (ImageMagick)"  "command -v mogrify"
check_cmd "pandoc   (Conversion)"   "command -v pandoc"
check_cmd "Python packages"         "python3 -c 'import matplotlib, numpy, pandas, jinja2'"

echo ""
echo ":: Result: ${PASS}/${TOTAL} checks passed."
echo ""

if [[ $PASS -ge 7 ]]; then
  echo "Setup complete. The LaTeX document skill is ready to use."
  echo ""
  echo "Scripts:"
  echo "  scripts/compile_latex.sh     -- Compile .tex to PDF + PNG previews"
  echo "  scripts/generate_chart.py    -- Generate matplotlib charts"
  echo "  scripts/csv_to_latex.py      -- Convert CSV to LaTeX tables"
  echo "  scripts/convert_document.sh  -- Pandoc format conversion"
  echo "  scripts/pdf_to_images.sh     -- Split PDF to page images"
  echo "  scripts/mermaid_to_image.sh  -- Mermaid diagrams to PNG/PDF"
  echo "  scripts/validate_latex.py    -- Validate LaTeX batch files"
  exit 0
else
  echo "Some dependencies are missing. Review the [FAIL] items above."
  echo "The skill will still work for features whose dependencies are installed."
  exit 1
fi
