#!/usr/bin/env bash

# pdf_encrypt.sh
# Password-protect a PDF using qpdf
#
# Examples:
#   ./pdf_encrypt.sh document.pdf --user-password mypass123
#   ./pdf_encrypt.sh document.pdf --user-password mypass --owner-password admin --output secure.pdf
#   ./pdf_encrypt.sh document.pdf --user-password pass --restrict-print --restrict-modify

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Default values
USER_PASSWORD=""
OWNER_PASSWORD=""
OUTPUT_FILE=""
RESTRICT_PRINT=false
RESTRICT_COPY=false
RESTRICT_MODIFY=false

# Print usage
usage() {
    cat << EOF
Usage: $0 <input.pdf> [OPTIONS]

Password-protect a PDF using 256-bit AES encryption.

Arguments:
  input.pdf                 Input PDF file to encrypt

Options:
  --user-password <pw>      Password required to open the PDF (required)
  --owner-password <pw>     Password for full access (defaults to user password)
  --output <file>           Output file path (default: input_encrypted.pdf)
  --restrict-print          Prevent printing
  --restrict-copy           Prevent text/graphics copying
  --restrict-modify         Prevent document modification
  -h, --help                Show this help message

Examples:
  $0 document.pdf --user-password mypass123
  $0 document.pdf --user-password pass --owner-password admin --output secure.pdf
  $0 document.pdf --user-password pass --restrict-print --restrict-modify

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
        --user-password)
            USER_PASSWORD="$2"
            shift 2
            ;;
        --owner-password)
            OWNER_PASSWORD="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --restrict-print)
            RESTRICT_PRINT=true
            shift
            ;;
        --restrict-copy)
            RESTRICT_COPY=true
            shift
            ;;
        --restrict-modify)
            RESTRICT_MODIFY=true
            shift
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

# Validate user password
if [[ -z "$USER_PASSWORD" ]]; then
    echo "Error: --user-password is required" >&2
    echo "Run '$0 --help' for usage information" >&2
    exit 1
fi

# Set owner password to user password if not specified
if [[ -z "$OWNER_PASSWORD" ]]; then
    OWNER_PASSWORD="$USER_PASSWORD"
fi

# Set default output file
if [[ -z "$OUTPUT_FILE" ]]; then
    BASENAME="${INPUT_FILE%.pdf}"
    OUTPUT_FILE="${BASENAME}_encrypted.pdf"
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

# Build qpdf command
QPDF_CMD=(
    qpdf
    --encrypt "$USER_PASSWORD" "$OWNER_PASSWORD" 256
)

# Add restriction flags
RESTRICTIONS=""
if [[ "$RESTRICT_PRINT" == true ]]; then
    RESTRICTIONS="${RESTRICTIONS} --print=none"
else
    RESTRICTIONS="${RESTRICTIONS} --print=full"
fi

if [[ "$RESTRICT_COPY" == true ]]; then
    RESTRICTIONS="${RESTRICTIONS} --extract=n"
else
    RESTRICTIONS="${RESTRICTIONS} --extract=y"
fi

if [[ "$RESTRICT_MODIFY" == true ]]; then
    RESTRICTIONS="${RESTRICTIONS} --modify=none"
else
    RESTRICTIONS="${RESTRICTIONS} --modify=all"
fi

# Add remaining arguments
QPDF_CMD+=(
    $RESTRICTIONS
    --
    "$INPUT_FILE"
    "$OUTPUT_FILE"
)

# Execute encryption
echo "Encrypting $INPUT_FILE..." >&2

if "${QPDF_CMD[@]}" 2>&1; then
    echo "Successfully created encrypted PDF: $OUTPUT_FILE" >&2

    # Show restrictions summary
    if [[ "$RESTRICT_PRINT" == true ]] || [[ "$RESTRICT_COPY" == true ]] || [[ "$RESTRICT_MODIFY" == true ]]; then
        echo "" >&2
        echo "Applied restrictions:" >&2
        [[ "$RESTRICT_PRINT" == true ]] && echo "  - Printing disabled" >&2
        [[ "$RESTRICT_COPY" == true ]] && echo "  - Text/graphics copying disabled" >&2
        [[ "$RESTRICT_MODIFY" == true ]] && echo "  - Document modification disabled" >&2
    fi

    exit 0
else
    echo "Error: Failed to encrypt PDF" >&2
    exit 1
fi
