#!/usr/bin/env bash

# latex_analyze.sh
# Comprehensive document analysis for LaTeX files
#
# Examples:
#   ./latex_analyze.sh document.tex
#   ./latex_analyze.sh thesis.tex

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# ANSI color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print usage
usage() {
    cat << EOF
Usage: $0 <file.tex>

Comprehensive analysis of a LaTeX document including word count, structure,
and common issues.

Arguments:
  file.tex          Input LaTeX file to analyze

Options:
  -h, --help        Show this help message

Examples:
  $0 document.tex
  $0 thesis.tex

Requires: detex (included in texlive)
EOF
    exit 0
}

# Check if help is requested or no args
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

TEX_FILE="$1"

# Validate input file
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

echo -e "${BOLD}LaTeX Document Analysis${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "File: $TEX_FILE"
echo ""

# === WORD COUNT ===
echo -e "${BLUE}${BOLD}Word Count${NC}"
WORD_COUNT=$(detex "$TEX_FILE" 2>/dev/null | wc -w | tr -d ' ')
echo "Words: $WORD_COUNT"
PAGES=$((WORD_COUNT / 250))
if [[ $PAGES -gt 0 ]]; then
    echo "Estimated pages: ~$PAGES (at 250 words/page)"
fi
echo ""

# === CONTENT STATISTICS ===
echo -e "${BLUE}${BOLD}Content Statistics${NC}"
FIGURE_COUNT=$(grep -c '\\begin{figure}' "$TEX_FILE" 2>/dev/null || true)
FIGURE_COUNT=${FIGURE_COUNT:-0}
echo "Figures: $FIGURE_COUNT"

TABLE_COUNT=$(grep -c '\\begin{table}' "$TEX_FILE" 2>/dev/null || true)
TABLE_COUNT=${TABLE_COUNT:-0}
echo "Tables: $TABLE_COUNT"

EQUATION_COUNT=$(grep -c '\\begin{equation}' "$TEX_FILE" 2>/dev/null || true)
EQUATION_COUNT=${EQUATION_COUNT:-0}
ALIGN_COUNT=$(grep -c '\\begin{align' "$TEX_FILE" 2>/dev/null || true)
ALIGN_COUNT=${ALIGN_COUNT:-0}
TOTAL_EQUATIONS=$((EQUATION_COUNT + ALIGN_COUNT))
echo "Equations: $TOTAL_EQUATIONS"

CITATION_COUNT=$(grep -o '\\cite{[^}]*}' "$TEX_FILE" 2>/dev/null | wc -l | tr -d ' \n' || true)
CITATION_COUNT=${CITATION_COUNT:-0}
echo "Citations: $CITATION_COUNT"
echo ""

# === DOCUMENT STRUCTURE ===
echo -e "${BLUE}${BOLD}Document Structure${NC}"

# Sections
SECTION_COUNT=$(grep -c '^\\section{' "$TEX_FILE" 2>/dev/null || true)
SECTION_COUNT=${SECTION_COUNT:-0}
echo "Sections: $SECTION_COUNT"

if [[ $SECTION_COUNT -gt 0 ]]; then
    echo ""
    echo "Section titles:"
    grep '^\\section{' "$TEX_FILE" 2>/dev/null | sed 's/\\section{\(.*\)}/  • \1/' || true
fi

# Subsections
SUBSECTION_COUNT=$(grep -c '^\\subsection{' "$TEX_FILE" 2>/dev/null || true)
SUBSECTION_COUNT=${SUBSECTION_COUNT:-0}
if [[ $SUBSECTION_COUNT -gt 0 ]]; then
    echo ""
    echo "Subsections: $SUBSECTION_COUNT"
fi

# Subsubsections
SUBSUBSECTION_COUNT=$(grep -c '^\\subsubsection{' "$TEX_FILE" 2>/dev/null || true)
SUBSUBSECTION_COUNT=${SUBSUBSECTION_COUNT:-0}
if [[ $SUBSUBSECTION_COUNT -gt 0 ]]; then
    echo "Subsubsections: $SUBSUBSECTION_COUNT"
fi
echo ""

# === COMMON ISSUES ===
echo -e "${BLUE}${BOLD}Issue Detection${NC}"
ISSUES_FOUND=0

# Check for figures without labels
FIGURES_WITHOUT_LABELS=0
if [[ $FIGURE_COUNT -gt 0 ]]; then
    # Extract figure environments and check for labels
    TEMP_FIGURES=$(mktemp)
    trap "rm -f $TEMP_FIGURES" EXIT

    # Simple heuristic: count figures with \label vs total figures
    FIGURES_WITH_LABELS=$(grep -A 5 '\\begin{figure}' "$TEX_FILE" 2>/dev/null | grep -c '\\label{' || true)
    FIGURES_WITH_LABELS=${FIGURES_WITH_LABELS:-0}
    FIGURES_WITHOUT_LABELS=$((FIGURE_COUNT - FIGURES_WITH_LABELS))

    if [[ $FIGURES_WITHOUT_LABELS -gt 0 ]]; then
        echo -e "${YELLOW}⚠ $FIGURES_WITHOUT_LABELS figure(s) may be missing \\label commands${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
fi

# Check for tables without labels
TABLES_WITHOUT_LABELS=0
if [[ $TABLE_COUNT -gt 0 ]]; then
    TABLES_WITH_LABELS=$(grep -A 5 '\\begin{table}' "$TEX_FILE" 2>/dev/null | grep -c '\\label{' || true)
    TABLES_WITH_LABELS=${TABLES_WITH_LABELS:-0}
    TABLES_WITHOUT_LABELS=$((TABLE_COUNT - TABLES_WITH_LABELS))

    if [[ $TABLES_WITHOUT_LABELS -gt 0 ]]; then
        echo -e "${YELLOW}⚠ $TABLES_WITHOUT_LABELS table(s) may be missing \\label commands${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
fi

# Check for unreferenced labels
ALL_LABELS=$(grep -o '\\label{[^}]*}' "$TEX_FILE" 2>/dev/null | sed 's/\\label{\([^}]*\)}/\1/' || true)
UNREFERENCED_LABELS=""

if [[ -n "$ALL_LABELS" ]]; then
    while IFS= read -r label; do
        if ! grep -q "\\\\ref{$label}" "$TEX_FILE" 2>/dev/null; then
            UNREFERENCED_LABELS="${UNREFERENCED_LABELS}${label}\n"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    done <<< "$ALL_LABELS"

    if [[ -n "$UNREFERENCED_LABELS" ]]; then
        echo -e "${YELLOW}⚠ Unreferenced labels found:${NC}"
        echo -e "$UNREFERENCED_LABELS" | sed 's/^/    /'
    fi
fi

# Check for TODO/FIXME comments
TODO_COUNT=$(grep -c 'TODO\|FIXME\|XXX' "$TEX_FILE" 2>/dev/null || true)
TODO_COUNT=${TODO_COUNT:-0}
if [[ $TODO_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}⚠ $TODO_COUNT TODO/FIXME comment(s) found${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for common typos
DOUBLE_SPACE_COUNT=$(grep -c '  ' "$TEX_FILE" 2>/dev/null || true)
DOUBLE_SPACE_COUNT=${DOUBLE_SPACE_COUNT:-0}
if [[ $DOUBLE_SPACE_COUNT -gt 10 ]]; then
    echo -e "${YELLOW}⚠ Multiple double spaces detected (may be intentional)${NC}"
fi

# Summary
if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✓ No common issues detected${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Analysis complete${NC}"

exit 0
