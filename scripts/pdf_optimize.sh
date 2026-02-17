#!/usr/bin/env bash

# pdf_optimize.sh
# Compress and linearize PDFs for web/email
#
# Examples:
#   ./pdf_optimize.sh document.pdf
#   ./pdf_optimize.sh large_file.pdf --output compressed.pdf

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Default values
OUTPUT_FILE=""

# Print usage
usage() {
    cat << EOF
Usage: $0 <input.pdf> [OPTIONS]

Compress and linearize PDFs for fast web viewing and reduced file size.

Arguments:
  input.pdf         Input PDF file to optimize

Options:
  --output <file>   Output file path (default: input_optimized.pdf)
  -h, --help        Show this help message

Examples:
  $0 document.pdf
  $0 large_file.pdf --output compressed.pdf

Requires: qpdf (auto-installed if missing)
EOF
    exit 0
}

# Check if help is requested or no args
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

# Parse arguments
INPUT_FILE=""
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
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            else
                echo "Error: Multiple input files specified" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate input file
if [[ -z "$INPUT_FILE" ]]; then
    echo "Error: No input file specified" >&2
    echo "Run '$0 --help' for usage information" >&2
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file not found: $INPUT_FILE" >&2
    exit 1
fi

# Set default output file
if [[ -z "$OUTPUT_FILE" ]]; then
    BASENAME="${INPUT_FILE%.pdf}"
    OUTPUT_FILE="${BASENAME}_optimized.pdf"
fi

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

# Get original file size
ORIGINAL_SIZE=$(stat -f%z "$INPUT_FILE" 2>/dev/null || stat -c%s "$INPUT_FILE" 2>/dev/null)
ORIGINAL_SIZE_HUMAN=$(du -h "$INPUT_FILE" | cut -f1)

echo "Optimizing $INPUT_FILE..." >&2
echo "Original size: $ORIGINAL_SIZE_HUMAN" >&2

# Optimize with qpdf
# --linearize: optimize for fast web viewing (byte-serving)
# --compress-streams=y: compress internal streams
# --recompress-flate: recompress with better compression
# --object-streams=generate: pack objects into streams for smaller size
if qpdf \
    --linearize \
    --compress-streams=y \
    --recompress-flate \
    --object-streams=generate \
    "$INPUT_FILE" \
    "$OUTPUT_FILE" 2>&1; then

    # Get optimized file size
    OPTIMIZED_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
    OPTIMIZED_SIZE_HUMAN=$(du -h "$OUTPUT_FILE" | cut -f1)

    # Calculate size reduction
    if [[ $ORIGINAL_SIZE -gt 0 ]]; then
        REDUCTION=$((100 - (OPTIMIZED_SIZE * 100 / ORIGINAL_SIZE)))
        echo "Optimized size: $OPTIMIZED_SIZE_HUMAN (${REDUCTION}% reduction)" >&2
    else
        echo "Optimized size: $OPTIMIZED_SIZE_HUMAN" >&2
    fi

    echo "" >&2
    echo "Successfully created: $OUTPUT_FILE" >&2
    echo "The PDF is now linearized for fast web viewing" >&2
    exit 0
else
    echo "Error: Failed to optimize PDF" >&2
    exit 1
fi
