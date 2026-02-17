#!/usr/bin/env bash
# pdf_extract_pages.sh - Extract page ranges from a PDF
#
# Usage:
#   pdf_extract_pages.sh <input.pdf> --pages <range> [--output <output.pdf>]
#
# Options:
#   --pages <range>   Page range to extract (required)
#   --output <file>   Output PDF file (default: auto-generated)
#
# Page range formats:
#   Single page:      --pages 5
#   Range:            --pages 1-10
#   Multiple:         --pages 1,3,5-8
#   Odd pages:        --pages odd
#   Even pages:       --pages even
#   Last N pages:     --pages last:3
#
# Features:
#   - Auto-installs qpdf if missing
#   - Preserves PDF metadata and bookmarks
#   - Smart output naming (input_pages_X-Y.pdf)
#   - Validates page ranges against document
#
# Examples:
#   pdf_extract_pages.sh document.pdf --pages 1-5
#   pdf_extract_pages.sh report.pdf --pages 1,3,5-8 --output selected.pdf
#   pdf_extract_pages.sh book.pdf --pages odd
#   pdf_extract_pages.sh paper.pdf --pages last:3 --output appendix.pdf

set -euo pipefail

# --- Usage function ---
usage() {
  cat <<'EOF'
pdf_extract_pages.sh - Extract page ranges from a PDF

Usage:
  pdf_extract_pages.sh <input.pdf> --pages <range> [--output <output.pdf>]

Options:
  --pages <range>   Page range to extract (required)
  --output <file>   Output PDF file (default: auto-generated)

Page range formats:
  Single page:      --pages 5
  Range:            --pages 1-10
  Multiple:         --pages 1,3,5-8
  Odd pages:        --pages odd
  Even pages:       --pages even
  Last N pages:     --pages last:3

Features:
  - Auto-installs qpdf if missing
  - Preserves PDF metadata and bookmarks
  - Smart output naming (input_pages_X-Y.pdf)
  - Validates page ranges against document

Examples:
  pdf_extract_pages.sh document.pdf --pages 1-5
  pdf_extract_pages.sh report.pdf --pages 1,3,5-8 --output selected.pdf
  pdf_extract_pages.sh book.pdf --pages odd
  pdf_extract_pages.sh paper.pdf --pages last:3 --output appendix.pdf
EOF
}

# --- Source cross-platform dependency installer ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# --- Parse arguments ---
INPUT_PDF=""
PAGES=""
OUTPUT_PDF=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --pages) PAGES="$2"; shift 2 ;;
    --output) OUTPUT_PDF="$2"; shift 2 ;;
    -*) echo "Error: Unknown option $1" >&2; exit 1 ;;
    *) INPUT_PDF="$1"; shift ;;
  esac
done

if [[ -z "$INPUT_PDF" ]]; then
  echo "Error: No input PDF file specified" >&2
  echo "Usage: pdf_extract_pages.sh <input.pdf> --pages <range> [--output <output.pdf>]" >&2
  exit 1
fi

if [[ ! -f "$INPUT_PDF" ]]; then
  echo "Error: File not found: $INPUT_PDF" >&2
  exit 1
fi

if [[ -z "$PAGES" ]]; then
  echo "Error: No page range specified. Use --pages <range>" >&2
  echo "Examples: --pages 1-5, --pages 1,3,5, --pages odd" >&2
  exit 1
fi

# Resolve absolute paths
INPUT_PDF="$(realpath "$INPUT_PDF")"
INPUT_DIR="$(dirname "$INPUT_PDF")"
INPUT_BASE="$(basename "$INPUT_PDF" .pdf)"

# --- Ensure qpdf is installed ---
ensure_qpdf() {
  if command -v qpdf &>/dev/null; then
    return 0
  fi
  echo ":: qpdf not found. Installing qpdf..." >&2

  # Map qpdf package name per platform
  local mgr
  mgr="$(detect_pkg_manager)"
  local pkg_name="qpdf"

  case "$mgr" in
    apt) pkg_name="qpdf" ;;
    brew) pkg_name="qpdf" ;;
    dnf) pkg_name="qpdf" ;;
    apk) pkg_name="qpdf" ;;
    pacman) pkg_name="qpdf" ;;
  esac

  run_pkg_install "$pkg_name" || {
    echo "Error: Failed to install qpdf." >&2
    echo "" >&2
    echo "Install qpdf manually:" >&2
    echo "  Debian/Ubuntu:  sudo apt-get install qpdf" >&2
    echo "  macOS:          brew install qpdf" >&2
    echo "  Fedora/RHEL:    sudo dnf install qpdf" >&2
    echo "  Alpine:         sudo apk add qpdf" >&2
    echo "  Arch:           sudo pacman -S qpdf" >&2
    echo "" >&2
    exit 1
  }

  if ! command -v qpdf &>/dev/null; then
    echo "Error: qpdf still not available after install" >&2
    exit 1
  fi
  echo ":: qpdf installed successfully" >&2
}

# --- Get total page count ---
get_page_count() {
  local pdf="$1"
  qpdf --show-npages "$pdf" 2>/dev/null || {
    echo "Error: Unable to read PDF page count" >&2
    exit 1
  }
}

# --- Parse page range into qpdf format ---
parse_page_range() {
  local range="$1"
  local total_pages="$2"

  # Handle special keywords
  case "$range" in
    odd)
      echo "1-$total_pages:odd"
      return 0
      ;;
    even)
      echo "1-$total_pages:even"
      return 0
      ;;
    last:*)
      local n="${range#last:}"
      if ! [[ "$n" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid last:N format - N must be a number" >&2
        exit 1
      fi
      local start=$((total_pages - n + 1))
      if [[ $start -lt 1 ]]; then
        start=1
      fi
      echo "$start-$total_pages"
      return 0
      ;;
  esac

  # Validate range format (numbers, commas, dashes only)
  if ! [[ "$range" =~ ^[0-9,\-]+$ ]]; then
    echo "Error: Invalid page range format: $range" >&2
    echo "Valid formats: 5, 1-10, 1,3,5-8, odd, even, last:3" >&2
    exit 1
  fi

  # Return range as-is for qpdf
  echo "$range"
}

# --- Generate output filename ---
generate_output_name() {
  local range="$1"
  local base="$2"
  local dir="$3"

  # Clean range for filename (replace commas and colons with underscores)
  local clean_range="${range//,/_}"
  clean_range="${clean_range//:/_}"

  echo "${dir}/${base}_pages_${clean_range}.pdf"
}

# --- Main extraction ---
ensure_qpdf

TOTAL_PAGES=$(get_page_count "$INPUT_PDF")
echo ":: Input PDF: $INPUT_PDF ($TOTAL_PAGES pages)" >&2

QPDF_RANGE=$(parse_page_range "$PAGES" "$TOTAL_PAGES")

# Determine output file
if [[ -z "$OUTPUT_PDF" ]]; then
  OUTPUT_PDF=$(generate_output_name "$PAGES" "$INPUT_BASE" "$INPUT_DIR")
else
  OUTPUT_PDF="$(realpath "$OUTPUT_PDF")"
fi

echo ":: Extracting pages: $PAGES" >&2
echo ":: Output PDF: $OUTPUT_PDF" >&2

# Extract pages with qpdf
qpdf "$INPUT_PDF" --pages . "$QPDF_RANGE" -- "$OUTPUT_PDF" 2>&1 | while read -r line; do
  # Filter out warnings we don't care about
  if [[ ! "$line" =~ "ignoring attempt to remove page we don't have" ]]; then
    echo "$line" >&2
  fi
done || {
  echo "Error: qpdf extraction failed" >&2
  exit 1
}

if [[ ! -f "$OUTPUT_PDF" ]]; then
  echo "Error: Output PDF not created" >&2
  exit 1
fi

OUTPUT_PAGES=$(get_page_count "$OUTPUT_PDF")
echo ":: Extraction complete: $OUTPUT_PAGES pages extracted"
echo ":: Output: $OUTPUT_PDF"
