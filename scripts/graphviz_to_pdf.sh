#!/usr/bin/env bash

# graphviz_to_pdf.sh
# Converts Graphviz .dot files to PDF or PNG for LaTeX inclusion
#
# Examples:
#   ./graphviz_to_pdf.sh diagram.dot
#   ./graphviz_to_pdf.sh diagram.dot --output result.pdf --format pdf
#   ./graphviz_to_pdf.sh diagram.dot --engine neato --format png
#   ./graphviz_to_pdf.sh diagrams/source/  # Batch mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Default values
FORMAT="pdf"
ENGINE="dot"
OUTPUT_FILE=""
DPI="300"

# Print usage
usage() {
    cat << EOF
Usage: $0 <input.dot|directory> [OPTIONS]

Convert Graphviz .dot files to PDF or PNG for LaTeX inclusion.

Arguments:
  input.dot         Input Graphviz .dot file
  directory         Directory containing .dot files (batch mode)

Options:
  --output FILE     Output file path (default: input name with format extension)
  --format FORMAT   Output format: pdf or png (default: pdf)
  --engine ENGINE   Layout engine: dot, neato, circo, fdp, twopi, sfdp (default: dot)
  --dpi DPI         Resolution for PNG output (default: 300)
  -h, --help        Show this help message

Layout Engines:
  dot     - Hierarchical/directed graphs (default)
  neato   - Undirected graphs (spring model)
  circo   - Circular layout
  fdp     - Force-directed placement
  twopi   - Radial layout
  sfdp    - Scalable force-directed (large graphs)

Examples:
  $0 diagram.dot
  $0 diagram.dot --output result.pdf
  $0 diagram.dot --format png --engine neato
  $0 diagrams/source/ --format pdf

Requires: graphviz (auto-installs if missing)
EOF
    exit 0
}

# Check if help is requested or no args
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

INPUT_PATH="$1"
shift

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --engine)
            ENGINE="$2"
            shift 2
            ;;
        --dpi)
            DPI="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Run '$0 --help' for usage information" >&2
            exit 1
            ;;
    esac
done

# Validate format
if [[ "$FORMAT" != "pdf" ]] && [[ "$FORMAT" != "png" ]]; then
    echo "Error: Format must be 'pdf' or 'png', got: $FORMAT" >&2
    exit 1
fi

# Validate engine
case "$ENGINE" in
    dot|neato|circo|fdp|twopi|sfdp)
        ;;
    *)
        echo "Error: Invalid engine '$ENGINE'" >&2
        echo "Valid engines: dot, neato, circo, fdp, twopi, sfdp" >&2
        exit 1
        ;;
esac

# Validate DPI is a number
if ! [[ "$DPI" =~ ^[0-9]+$ ]]; then
    echo "Error: DPI must be a number, got: $DPI" >&2
    exit 1
fi

# Check if Graphviz is installed
if ! command -v dot &>/dev/null; then
    echo "Graphviz not found. Installing..." >&2

    # Add graphviz to the package mapping in install_deps.sh
    # For now, install directly
    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apt)
            run_pkg_install graphviz
            ;;
        brew)
            run_pkg_install graphviz
            ;;
        dnf)
            run_pkg_install graphviz
            ;;
        apk)
            run_pkg_install graphviz
            ;;
        pacman)
            run_pkg_install graphviz
            ;;
        *)
            echo "Error: Could not auto-install Graphviz" >&2
            echo "" >&2
            echo "Please install manually:" >&2
            echo "  Debian/Ubuntu:  sudo apt-get install graphviz" >&2
            echo "  macOS:          brew install graphviz" >&2
            echo "  Fedora/RHEL:    sudo dnf install graphviz" >&2
            echo "  Alpine:         sudo apk add graphviz" >&2
            echo "  Arch:           sudo pacman -S graphviz" >&2
            exit 1
            ;;
    esac
fi

# Verify engine is available
if ! command -v "$ENGINE" &>/dev/null; then
    echo "Error: Engine '$ENGINE' not found in PATH" >&2
    exit 1
fi

# Function to convert a single file
convert_file() {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file not found: $input_file" >&2
        return 1
    fi

    # Validate .dot extension
    if [[ ! "$input_file" =~ \.dot$ ]]; then
        echo "Warning: Input file does not have .dot extension: $input_file" >&2
    fi

    echo "Converting $input_file -> $output_file (engine: $ENGINE, format: $FORMAT)" >&2

    # Build command based on format
    if [[ "$FORMAT" == "pdf" ]]; then
        "$ENGINE" -Tpdf "$input_file" -o "$output_file"
    elif [[ "$FORMAT" == "png" ]]; then
        "$ENGINE" -Tpng -Gdpi="$DPI" "$input_file" -o "$output_file"
    fi

    if [[ $? -eq 0 ]]; then
        echo "Successfully created: $output_file" >&2
        return 0
    else
        echo "Error: Failed to convert $input_file" >&2
        return 1
    fi
}

# Check if input is a directory (batch mode) or a file
if [[ -d "$INPUT_PATH" ]]; then
    # Batch mode: convert all .dot files in directory
    echo "Batch mode: converting all .dot files in $INPUT_PATH" >&2

    # Remove trailing slash
    INPUT_PATH="${INPUT_PATH%/}"

    # Find all .dot files
    shopt -s nullglob
    dot_files=("$INPUT_PATH"/*.dot)

    if [[ ${#dot_files[@]} -eq 0 ]]; then
        echo "Error: No .dot files found in $INPUT_PATH" >&2
        exit 1
    fi

    echo "Found ${#dot_files[@]} .dot file(s)" >&2

    success_count=0
    fail_count=0

    for dot_file in "${dot_files[@]}"; do
        filename=$(basename "$dot_file" .dot)
        output_file="$INPUT_PATH/${filename}.$FORMAT"

        if convert_file "$dot_file" "$output_file"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done

    echo "" >&2
    echo "Batch conversion complete:" >&2
    echo "  Success: $success_count" >&2
    echo "  Failed: $fail_count" >&2

    if [[ $fail_count -gt 0 ]]; then
        exit 1
    fi

elif [[ -f "$INPUT_PATH" ]]; then
    # Single file mode

    # Determine output file
    if [[ -z "$OUTPUT_FILE" ]]; then
        # Default: replace .dot extension with format
        OUTPUT_FILE="${INPUT_PATH%.dot}.$FORMAT"
    fi

    convert_file "$INPUT_PATH" "$OUTPUT_FILE"

else
    echo "Error: Input path not found: $INPUT_PATH" >&2
    exit 1
fi
