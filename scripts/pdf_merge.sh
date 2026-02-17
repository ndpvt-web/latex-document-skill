#!/usr/bin/env bash

# pdf_merge.sh
# Merge multiple PDFs into one
#
# Examples:
#   ./pdf_merge.sh file1.pdf file2.pdf file3.pdf --output combined.pdf
#   ./pdf_merge.sh chapter*.pdf --output book.pdf
#   ./pdf_merge.sh intro.pdf body.pdf appendix.pdf

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Default values
OUTPUT_FILE="merged.pdf"
INPUT_FILES=()

# Print usage
usage() {
    cat << EOF
Usage: $0 <file1.pdf> <file2.pdf> ... [OPTIONS]

Merge multiple PDFs into one document.

Arguments:
  file1.pdf file2.pdf ...   Input PDF files to merge (minimum 2 files)

Options:
  --output <file>           Output file path (default: merged.pdf)
  -h, --help                Show this help message

Examples:
  $0 file1.pdf file2.pdf file3.pdf --output combined.pdf
  $0 chapter*.pdf --output book.pdf
  $0 intro.pdf body.pdf appendix.pdf

Requires: qpdf (auto-installed if missing)
EOF
    exit 0
}

# Check if help is requested or no args
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)
            INPUT_FILES+=("$1")
            shift
            ;;
    esac
done

# Validate input files
if [[ ${#INPUT_FILES[@]} -lt 2 ]]; then
    echo "Error: At least 2 PDF files are required for merging" >&2
    echo "Run '$0 --help' for usage information" >&2
    exit 1
fi

# Check all input files exist
for file in "${INPUT_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: Input file not found: $file" >&2
        exit 1
    fi
    # Verify it's a PDF
    if ! file "$file" | grep -q "PDF"; then
        echo "Error: Not a valid PDF file: $file" >&2
        exit 1
    fi
done

# Check for qpdf, install if missing
if ! command -v qpdf &>/dev/null; then
    echo "qpdf not found. Installing..." >&2

    # Map qpdf to platform packages
    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apt)    run_pkg_install qpdf ;;
        brew)   run_pkg_install qpdf ;;
        dnf)    run_pkg_install qpdf ;;
        apk)    run_pkg_install qpdf ;;
        pacman) run_pkg_install qpdf ;;
        *)
            echo "Error: Could not auto-install qpdf" >&2
            echo "Please install manually:" >&2
            echo "  Debian/Ubuntu:  sudo apt-get install qpdf" >&2
            echo "  macOS:          brew install qpdf" >&2
            echo "  Fedora/RHEL:    sudo dnf install qpdf" >&2
            echo "  Alpine:         sudo apk add qpdf" >&2
            echo "  Arch:           sudo pacman -S qpdf" >&2
            exit 1
            ;;
    esac

    if ! command -v qpdf &>/dev/null; then
        echo "Error: qpdf installation failed" >&2
        exit 1
    fi
fi

# Build qpdf command
echo "Merging ${#INPUT_FILES[@]} PDF files..." >&2

# Display files being merged
for i in "${!INPUT_FILES[@]}"; do
    echo "  $((i+1)). ${INPUT_FILES[$i]}" >&2
done
echo "" >&2

# Execute merge using qpdf
# The first file is the base, then we append the rest
if qpdf --empty --pages "${INPUT_FILES[@]}" -- "$OUTPUT_FILE" 2>&1; then
    # Get file size
    SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "Successfully created: $OUTPUT_FILE ($SIZE)" >&2
    exit 0
else
    echo "Error: Failed to merge PDF files" >&2
    exit 1
fi
