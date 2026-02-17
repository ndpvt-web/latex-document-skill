#!/usr/bin/env bash

# latex_wordcount.sh
# Count words in a LaTeX document (stripping LaTeX commands)
#
# Examples:
#   ./latex_wordcount.sh document.tex
#   ./latex_wordcount.sh thesis.tex --detailed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Default values
DETAILED=false

# Print usage
usage() {
    cat << EOF
Usage: $0 <file.tex> [OPTIONS]

Count words in a LaTeX document by stripping LaTeX commands.

Arguments:
  file.tex          Input LaTeX file

Options:
  --detailed        Show detailed statistics (figures, tables, equations, citations)
  -h, --help        Show this help message

Examples:
  $0 document.tex
  $0 thesis.tex --detailed

Requires: detex (included in texlive)
EOF
    exit 0
}

# Check if help is requested or no args
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

# Parse arguments
TEX_FILE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --detailed)
            DETAILED=true
            shift
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$TEX_FILE" ]]; then
                TEX_FILE="$1"
            else
                echo "Error: Multiple input files specified" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate input file
if [[ -z "$TEX_FILE" ]]; then
    echo "Error: No input file specified" >&2
    echo "Run '$0 --help' for usage information" >&2
    exit 1
fi

if [[ ! -f "$TEX_FILE" ]]; then
    echo "Error: Input file not found: $TEX_FILE" >&2
    exit 1
fi

# Check for detex
if ! command -v detex &>/dev/null; then
    echo "Error: detex not found" >&2
    echo "detex is typically included with texlive" >&2
    echo "Please install texlive:" >&2
    echo "  Debian/Ubuntu:  sudo apt-get install texlive-extra-utils" >&2
    echo "  macOS:          brew install texlive" >&2
    echo "  Fedora/RHEL:    sudo dnf install texlive-scheme-medium" >&2
    echo "  Alpine:         sudo apk add texlive-full" >&2
    echo "  Arch:           sudo pacman -S texlive-most" >&2
    exit 1
fi

# Count words using detex
WORD_COUNT=$(detex "$TEX_FILE" 2>/dev/null | wc -w | tr -d ' ')

# Basic output
echo "Word count: $WORD_COUNT words"

# Estimate page count (250 words per page is standard)
PAGES=$((WORD_COUNT / 250))
if [[ $PAGES -gt 0 ]]; then
    echo "Estimated pages: ~$PAGES pages (250 words/page)"
fi

# Detailed statistics if requested
if [[ "$DETAILED" == true ]]; then
    echo ""
    echo "Detailed Statistics:"
    echo "==================="

    # Count figures
    FIGURE_COUNT=$(grep -c '\\begin{figure}' "$TEX_FILE" 2>/dev/null || echo "0")
    echo "Figures: $FIGURE_COUNT"

    # Count tables
    TABLE_COUNT=$(grep -c '\\begin{table}' "$TEX_FILE" 2>/dev/null || echo "0")
    echo "Tables: $TABLE_COUNT"

    # Count equations (equation environment + align environment)
    EQUATION_COUNT=$(grep -c '\\begin{equation}' "$TEX_FILE" 2>/dev/null || echo "0")
    ALIGN_COUNT=$(grep -c '\\begin{align' "$TEX_FILE" 2>/dev/null || echo "0")
    TOTAL_EQUATIONS=$((EQUATION_COUNT + ALIGN_COUNT))
    echo "Equations: $TOTAL_EQUATIONS"

    # Count citations
    CITATION_COUNT=$(grep -o '\\cite{[^}]*}' "$TEX_FILE" 2>/dev/null | wc -l | tr -d ' ')
    echo "Citations: $CITATION_COUNT"

    # Count sections
    SECTION_COUNT=$(grep -c '^\\section{' "$TEX_FILE" 2>/dev/null || echo "0")
    SUBSECTION_COUNT=$(grep -c '^\\subsection{' "$TEX_FILE" 2>/dev/null || echo "0")
    echo ""
    echo "Structure:"
    echo "  Sections: $SECTION_COUNT"
    echo "  Subsections: $SUBSECTION_COUNT"

    # Character count (including spaces)
    CHAR_COUNT=$(detex "$TEX_FILE" 2>/dev/null | wc -c | tr -d ' ')
    echo ""
    echo "Characters (with spaces): $CHAR_COUNT"

    # Line count of raw .tex file
    LINE_COUNT=$(wc -l < "$TEX_FILE" | tr -d ' ')
    echo "LaTeX source lines: $LINE_COUNT"
fi

exit 0
