#!/usr/bin/env bash

# convert_document.sh - Document format conversion wrapper for Pandoc
#
# DESCRIPTION:
#   Converts between various document formats using Pandoc.
#   Auto-detects conversion direction from file extensions.
#
# SUPPORTED CONVERSIONS:
#   .md   → .tex, .docx, .html, .pdf
#   .tex  → .md, .docx, .html, .pdf
#   .docx → .tex, .md, .html, .pdf
#   .html → .tex, .md, .docx, .pdf
#
# USAGE:
#   convert_document.sh INPUT OUTPUT [OPTIONS]
#
# EXAMPLES:
#   # Markdown to LaTeX
#   convert_document.sh report.md report.tex --standalone --toc
#
#   # LaTeX to PDF with bibliography
#   convert_document.sh paper.tex paper.pdf --bibliography refs.bib --csl ieee.csl
#
#   # DOCX to LaTeX with custom template
#   convert_document.sh manuscript.docx manuscript.tex --template custom.latex
#
#   # LaTeX to Markdown (for editing)
#   convert_document.sh document.tex document.md
#
#   # HTML to LaTeX
#   convert_document.sh webpage.html output.tex --standalone
#
# OPTIONS:
#   --template PATH       Custom Pandoc template file
#   --bibliography PATH   BibTeX (.bib) file for citations
#   --csl PATH           Citation Style Language file
#   --toc                Include table of contents
#   --standalone         Produce standalone document (default for most)
#   --no-standalone      Disable standalone mode
#   --help               Show this help message

set -euo pipefail

# --- Source cross-platform dependency installer ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to show help
show_help() {
    sed -n '/^# convert_document.sh/,/^$/p' "$0" | sed 's/^# \?//'
    exit 0
}

# Function to check if pandoc is installed
check_pandoc() {
    if command -v pandoc >/dev/null 2>&1; then
        local version=$(pandoc --version | head -n1)
        info "Pandoc found: $version"
        return 0
    else
        warn "Pandoc not found. Attempting to install..."
        install_packages "pandoc" || {
            error "Unable to auto-install pandoc. Please install manually:"
            error "  Ubuntu/Debian:  sudo apt-get install pandoc"
            error "  macOS:          brew install pandoc"
            error "  Fedora/RHEL:    sudo dnf install pandoc"
            error "  Alpine:         sudo apk add pandoc"
            error "  Arch:           sudo pacman -S pandoc"
            error "  Or download from: https://pandoc.org/installing.html"
            exit 1
        }

        if command -v pandoc >/dev/null 2>&1; then
            success "Pandoc installed successfully"
        else
            error "Pandoc installation failed"
            print_install_help "pandoc"
            exit 1
        fi
    fi
}

# Function to get file extension
get_extension() {
    echo "${1##*.}" | tr '[:upper:]' '[:lower:]'
}

# Function to get base filename without extension
get_basename() {
    local filename=$(basename "$1")
    echo "${filename%.*}"
}

# Parse arguments
if [[ $# -lt 2 ]]; then
    error "Insufficient arguments"
    echo ""
    show_help
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"
shift 2

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    error "Input file not found: $INPUT_FILE"
    exit 1
fi

# Parse options
TEMPLATE=""
BIBLIOGRAPHY=""
CSL=""
TOC=false
STANDALONE="auto"
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --template)
            TEMPLATE="$2"
            if [[ ! -f "$TEMPLATE" ]]; then
                error "Template file not found: $TEMPLATE"
                exit 1
            fi
            shift 2
            ;;
        --bibliography)
            BIBLIOGRAPHY="$2"
            if [[ ! -f "$BIBLIOGRAPHY" ]]; then
                error "Bibliography file not found: $BIBLIOGRAPHY"
                exit 1
            fi
            shift 2
            ;;
        --csl)
            CSL="$2"
            if [[ ! -f "$CSL" ]]; then
                error "CSL file not found: $CSL"
                exit 1
            fi
            shift 2
            ;;
        --toc)
            TOC=true
            shift
            ;;
        --standalone)
            STANDALONE="yes"
            shift
            ;;
        --no-standalone)
            STANDALONE="no"
            shift
            ;;
        --help)
            show_help
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# Check pandoc installation
check_pandoc

# Get file extensions
INPUT_EXT=$(get_extension "$INPUT_FILE")
OUTPUT_EXT=$(get_extension "$OUTPUT_FILE")

info "Converting: $INPUT_FILE ($INPUT_EXT) → $OUTPUT_FILE ($OUTPUT_EXT)"

# Build pandoc command
PANDOC_CMD=(pandoc "$INPUT_FILE" -o "$OUTPUT_FILE")

# Determine if standalone should be used
if [[ "$STANDALONE" == "auto" ]]; then
    # Default to standalone for most conversions, except when creating fragments
    if [[ "$OUTPUT_EXT" == "tex" || "$OUTPUT_EXT" == "html" || "$OUTPUT_EXT" == "docx" || "$OUTPUT_EXT" == "pdf" ]]; then
        PANDOC_CMD+=(--standalone)
    fi
elif [[ "$STANDALONE" == "yes" ]]; then
    PANDOC_CMD+=(--standalone)
fi

# Add table of contents
if [[ "$TOC" == true ]]; then
    PANDOC_CMD+=(--toc)
    info "Including table of contents"
fi

# Add template
if [[ -n "$TEMPLATE" ]]; then
    PANDOC_CMD+=(--template="$TEMPLATE")
    info "Using template: $TEMPLATE"
fi

# Add bibliography
if [[ -n "$BIBLIOGRAPHY" ]]; then
    PANDOC_CMD+=(--bibliography="$BIBLIOGRAPHY")
    info "Using bibliography: $BIBLIOGRAPHY"
fi

# Add CSL
if [[ -n "$CSL" ]]; then
    PANDOC_CMD+=(--csl="$CSL")
    info "Using citation style: $CSL"
fi

# Add format-specific options
case "$INPUT_EXT" in
    tex)
        PANDOC_CMD+=(--from=latex)
        ;;
    md|markdown)
        PANDOC_CMD+=(--from=markdown)
        ;;
    docx)
        PANDOC_CMD+=(--from=docx)
        ;;
    html|htm)
        PANDOC_CMD+=(--from=html)
        ;;
esac

case "$OUTPUT_EXT" in
    tex)
        PANDOC_CMD+=(--to=latex)
        ;;
    md|markdown)
        PANDOC_CMD+=(--to=markdown)
        ;;
    docx)
        PANDOC_CMD+=(--to=docx)
        ;;
    html|htm)
        PANDOC_CMD+=(--to=html)
        # Add MathJax for math rendering in HTML
        PANDOC_CMD+=(--mathjax)
        ;;
    pdf)
        PANDOC_CMD+=(--to=pdf)
        # Use lualatex if available for better Unicode support
        if command -v lualatex >/dev/null 2>&1; then
            PANDOC_CMD+=(--pdf-engine=lualatex)
        elif command -v pdflatex >/dev/null 2>&1; then
            PANDOC_CMD+=(--pdf-engine=pdflatex)
        fi
        ;;
    *)
        warn "Unknown output format: $OUTPUT_EXT"
        warn "Pandoc will attempt auto-detection"
        ;;
esac

# Add any extra arguments
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
    PANDOC_CMD+=("${EXTRA_ARGS[@]}")
fi

# Print command for debugging
info "Running: ${PANDOC_CMD[*]}"

# Execute conversion
if "${PANDOC_CMD[@]}"; then
    success "Conversion completed successfully"

    # Get absolute path of output file
    OUTPUT_ABS=$(realpath "$OUTPUT_FILE")

    # Print file info
    if [[ -f "$OUTPUT_FILE" ]]; then
        FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
        success "Output file: $OUTPUT_ABS"
        info "File size: $FILE_SIZE"
    fi

    exit 0
else
    error "Conversion failed"
    echo ""
    error "Troubleshooting tips:"
    error "  1. Check that input file is valid ${INPUT_EXT} format"
    error "  2. For PDF output, ensure LaTeX is installed (texlive-full)"
    error "  3. For bibliography, ensure .bib file syntax is correct"
    error "  4. Try adding --verbose flag for more details"
    exit 1
fi
