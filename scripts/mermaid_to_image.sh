#!/bin/bash

# mermaid_to_image.sh
# Converts Mermaid diagram files (.mmd) to PNG or PDF images for LaTeX inclusion
#
# Examples:
#   ./mermaid_to_image.sh diagram.mmd output.png
#   ./mermaid_to_image.sh diagram.mmd output.pdf --format pdf --theme dark
#   ./mermaid_to_image.sh flowchart.mmd chart.png --width 1200 --background transparent

set -euo pipefail

# Default values
FORMAT="png"
WIDTH="800"
THEME="default"
BACKGROUND="white"

# Print usage
usage() {
    cat << EOF
Usage: $0 <input.mmd> <output> [OPTIONS]

Convert Mermaid diagram files to PNG or PDF for LaTeX inclusion.

Arguments:
  input.mmd         Input Mermaid diagram file
  output            Output file path (e.g., diagram.png or diagram.pdf)

Options:
  --format FORMAT   Output format: png or pdf (default: png)
  --width PIXELS    Width in pixels (default: 800)
  --theme THEME     Theme: default, dark, forest, neutral (default: default)
  --background BG   Background: white or transparent (default: white)
  -h, --help        Show this help message

Examples:
  $0 diagram.mmd output.png
  $0 diagram.mmd output.pdf --format pdf --theme dark
  $0 flowchart.mmd chart.png --width 1200 --background transparent

Requires: npx and @mermaid-js/mermaid-cli
EOF
    exit 0
}

# Check if help is requested or no args
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

# Check minimum arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Missing required arguments" >&2
    echo "Run '$0 --help' for usage information" >&2
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"
shift 2

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --width)
            WIDTH="$2"
            shift 2
            ;;
        --theme)
            THEME="$2"
            shift 2
            ;;
        --background)
            BACKGROUND="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Validate input file
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file not found: $INPUT_FILE" >&2
    exit 1
fi

# Validate format
if [[ "$FORMAT" != "png" ]] && [[ "$FORMAT" != "pdf" ]]; then
    echo "Error: Format must be 'png' or 'pdf', got: $FORMAT" >&2
    exit 1
fi

# Validate theme
if [[ "$THEME" != "default" ]] && [[ "$THEME" != "dark" ]] && [[ "$THEME" != "forest" ]] && [[ "$THEME" != "neutral" ]]; then
    echo "Error: Theme must be 'default', 'dark', 'forest', or 'neutral', got: $THEME" >&2
    exit 1
fi

# Validate background
if [[ "$BACKGROUND" != "white" ]] && [[ "$BACKGROUND" != "transparent" ]]; then
    echo "Error: Background must be 'white' or 'transparent', got: $BACKGROUND" >&2
    exit 1
fi

# Validate width is a number
if ! [[ "$WIDTH" =~ ^[0-9]+$ ]]; then
    echo "Error: Width must be a number, got: $WIDTH" >&2
    exit 1
fi

# Create temporary puppeteer config
PUPPETEER_CONFIG=$(mktemp /tmp/puppeteer-config.XXXXXX.json)
trap "rm -f $PUPPETEER_CONFIG" EXIT

cat > "$PUPPETEER_CONFIG" << EOF
{
  "args": ["--no-sandbox", "--disable-setuid-sandbox"]
}
EOF

# Build mermaid-cli command
echo "Converting $INPUT_FILE to $OUTPUT_FILE..." >&2

MMD_CMD=(
    npx -y @mermaid-js/mermaid-cli@11.12.0 mmdc
    -i "$INPUT_FILE"
    -o "$OUTPUT_FILE"
    -t "$THEME"
    -w "$WIDTH"
    -p "$PUPPETEER_CONFIG"
)

# Add background option
if [[ "$BACKGROUND" == "transparent" ]]; then
    MMD_CMD+=(-b transparent)
else
    MMD_CMD+=(-b white)
fi

# Execute conversion
if "${MMD_CMD[@]}" 2>&1; then
    echo "Successfully created: $OUTPUT_FILE" >&2
    exit 0
else
    echo "Error: Failed to convert Mermaid diagram" >&2
    exit 1
fi
