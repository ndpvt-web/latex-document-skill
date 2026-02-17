#!/usr/bin/env bash
# latex_package_check.sh - Pre-flight check for LaTeX package availability
#
# Usage:
#   latex_package_check.sh <input.tex> [--install] [--verbose]
#
# Options:
#   --install         Attempt to install missing packages via tlmgr
#   --verbose         Show check details for each package
#
# Features:
#   - Scans .tex file for \usepackage commands
#   - Checks availability with kpsewhich
#   - Reports available and missing packages
#   - Optional auto-install with tlmgr
#   - Provides install suggestions for missing packages
#   - Detects documentclass and checks availability
#
# Examples:
#   latex_package_check.sh document.tex
#   latex_package_check.sh paper.tex --verbose
#   latex_package_check.sh report.tex --install
#   latex_package_check.sh thesis.tex --install --verbose

set -euo pipefail

# --- Usage function ---
usage() {
  cat <<'EOF'
latex_package_check.sh - Pre-flight check for LaTeX package availability

Usage:
  latex_package_check.sh <input.tex> [--install] [--verbose]

Options:
  --install         Attempt to install missing packages via tlmgr
  --verbose         Show check details for each package

Features:
  - Scans .tex file for \usepackage commands
  - Checks availability with kpsewhich
  - Reports available and missing packages
  - Optional auto-install with tlmgr
  - Provides install suggestions for missing packages
  - Detects documentclass and checks availability

Examples:
  latex_package_check.sh document.tex
  latex_package_check.sh paper.tex --verbose
  latex_package_check.sh report.tex --install
  latex_package_check.sh thesis.tex --install --verbose
EOF
}

# --- Source cross-platform dependency installer ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# --- Parse arguments ---
INPUT_TEX=""
INSTALL=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --install) INSTALL=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    -*) echo "Error: Unknown option $1" >&2; exit 1 ;;
    *) INPUT_TEX="$1"; shift ;;
  esac
done

if [[ -z "$INPUT_TEX" ]]; then
  echo "Error: No input .tex file specified" >&2
  echo "Usage: latex_package_check.sh <input.tex> [--install] [--verbose]" >&2
  exit 1
fi

if [[ ! -f "$INPUT_TEX" ]]; then
  echo "Error: File not found: $INPUT_TEX" >&2
  exit 1
fi

# Resolve absolute path
INPUT_TEX="$(realpath "$INPUT_TEX")"

# --- Ensure LaTeX is installed ---
ensure_latex() {
  if command -v kpsewhich &>/dev/null; then
    return 0
  fi
  echo ":: LaTeX (kpsewhich) not found. Installing TeX Live..." >&2
  install_packages "texlive" || {
    echo "Error: Failed to install TeX Live." >&2
    print_install_help "texlive"
    exit 1
  }
  _brew_post_texlive
  if ! command -v kpsewhich &>/dev/null; then
    echo "Error: kpsewhich still not available after install" >&2
    exit 1
  fi
  echo ":: TeX Live installed successfully" >&2
}

# --- Extract packages from .tex file ---
extract_packages() {
  local tex_file="$1"

  # Extract \usepackage{...} and \usepackage[...]{...}
  # Handle multi-line \usepackage commands and comma-separated packages
  grep -oP '\\usepackage(?:\[[^\]]*\])?\{[^\}]+\}' "$tex_file" 2>/dev/null | \
    sed -E 's/\\usepackage(\[[^\]]*\])?\{([^\}]+)\}/\2/' | \
    tr ',' '\n' | \
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
    grep -v '^$' | \
    sort -u || true
}

# --- Extract document class ---
extract_documentclass() {
  local tex_file="$1"
  grep -oP '\\documentclass(?:\[[^\]]*\])?\{\K[^\}]+' "$tex_file" 2>/dev/null | head -1
}

# --- Check if package is available ---
check_package() {
  local package="$1"
  kpsewhich "${package}.sty" &>/dev/null
}

# --- Check if document class is available ---
check_documentclass() {
  local docclass="$1"
  kpsewhich "${docclass}.cls" &>/dev/null
}

# --- Install package with tlmgr ---
install_package() {
  local package="$1"

  if ! command -v tlmgr &>/dev/null; then
    echo "  → tlmgr not available (TeX Live package manager)" >&2
    return 1
  fi

  echo "  → Installing $package via tlmgr..." >&2
  tlmgr install "$package" 2>&1 | grep -v "^tlmgr: package repository" | grep -v "^$" >&2 || {
    # Try updating tlmgr first, then retry
    echo "  → Updating tlmgr and retrying..." >&2
    tlmgr update --self 2>&1 | grep -v "^tlmgr: package repository" >&2 || true
    tlmgr install "$package" 2>&1 | grep -v "^tlmgr: package repository" | grep -v "^$" >&2
  }
}

# --- Main check ---
ensure_latex

echo ":: Checking LaTeX packages for: $INPUT_TEX" >&2
echo "" >&2

# Check document class
DOCCLASS=$(extract_documentclass "$INPUT_TEX")
if [[ -n "$DOCCLASS" ]]; then
  echo "Document class: $DOCCLASS"
  if check_documentclass "$DOCCLASS"; then
    if [[ "$VERBOSE" == true ]]; then
      echo "  ✓ Available"
    fi
  else
    echo "  ✗ MISSING"
    if [[ "$INSTALL" == true ]]; then
      install_package "$DOCCLASS" && echo "  ✓ Installed successfully" || echo "  ✗ Installation failed"
    else
      echo "    → Install with: tlmgr install $DOCCLASS"
    fi
  fi
  echo ""
fi

# Extract and check packages
PACKAGES=$(extract_packages "$INPUT_TEX")

if [[ -z "$PACKAGES" ]]; then
  echo "No packages found in document."
  exit 0
fi

PACKAGE_COUNT=$(echo "$PACKAGES" | wc -l)
echo "Found $PACKAGE_COUNT package(s) to check:"
echo ""

AVAILABLE=()
MISSING=()

while IFS= read -r package; do
  if [[ -z "$package" ]]; then
    continue
  fi

  if [[ "$VERBOSE" == true ]]; then
    echo -n "Checking: $package ... "
  fi

  if check_package "$package"; then
    AVAILABLE+=("$package")
    if [[ "$VERBOSE" == true ]]; then
      echo "✓ Available"
    fi
  else
    MISSING+=("$package")
    if [[ "$VERBOSE" == true ]]; then
      echo "✗ MISSING"
    else
      echo "✗ MISSING: $package"
    fi

    if [[ "$INSTALL" == true ]]; then
      install_package "$package" && {
        # Verify installation
        if check_package "$package"; then
          echo "  ✓ Installed successfully"
          # Move from MISSING to AVAILABLE
          AVAILABLE+=("$package")
          unset 'MISSING[-1]'
        else
          echo "  ✗ Installation failed or package not found"
        fi
      }
    else
      echo "    → Install with: tlmgr install $package"
      echo "    → Or: sudo apt-get install texlive-latex-extra (Debian/Ubuntu)"
    fi
  fi
done <<< "$PACKAGES"

echo ""
echo "=== Summary ==="
echo "Available: ${#AVAILABLE[@]} package(s)"
echo "Missing:   ${#MISSING[@]} package(s)"

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo ""
  echo "Missing packages:"
  for pkg in "${MISSING[@]}"; do
    echo "  - $pkg"
  done

  if [[ "$INSTALL" == false ]]; then
    echo ""
    echo "To auto-install missing packages, run with --install flag"
    echo ""
    echo "Manual installation options:"
    echo "  tlmgr install ${MISSING[*]}"
    echo "  sudo apt-get install texlive-latex-extra  (Debian/Ubuntu)"
    echo "  sudo dnf install texlive-collection-latexextra  (Fedora/RHEL)"
  fi

  exit 1
else
  echo ""
  echo "✓ All packages are available!"
  exit 0
fi
