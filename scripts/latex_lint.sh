#!/usr/bin/env bash

# latex_lint.sh
# Run chktex on a .tex file with human-readable formatted output
#
# Examples:
#   ./latex_lint.sh document.tex
#   ./latex_lint.sh document.tex --strict
#   ./latex_lint.sh document.tex --quiet

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Default values
STRICT=false
QUIET=false

# ANSI color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print usage
usage() {
    cat << EOF
Usage: $0 <file.tex> [OPTIONS]

Run chktex on a LaTeX file with formatted output.

Arguments:
  file.tex          Input LaTeX file to lint

Options:
  --strict          Treat all warnings as errors (exit 1 if any)
  --quiet           Only show count summary
  -h, --help        Show this help message

Examples:
  $0 document.tex
  $0 document.tex --strict
  $0 document.tex --quiet

Requires: chktex (auto-installed if missing)
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
        --strict)
            STRICT=true
            shift
            ;;
        --quiet)
            QUIET=true
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

# Check for chktex, install if missing
if ! command -v chktex &>/dev/null; then
    echo "chktex not found. Installing..." >&2

    # Map chktex to platform packages
    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apt)    run_pkg_install chktex ;;
        brew)   run_pkg_install chktex ;;
        dnf)    run_pkg_install chktex ;;
        apk)    run_pkg_install chktex ;;
        pacman) run_pkg_install chktex ;;
        *)
            echo "Error: Could not auto-install chktex" >&2
            echo "Please install manually:" >&2
            echo "  Debian/Ubuntu:  sudo apt-get install chktex" >&2
            echo "  macOS:          brew install chktex" >&2
            echo "  Fedora/RHEL:    sudo dnf install chktex" >&2
            echo "  Alpine:         sudo apk add chktex" >&2
            echo "  Arch:           sudo pacman -S chktex" >&2
            exit 1
            ;;
    esac

    if ! command -v chktex &>/dev/null; then
        echo "Error: chktex installation failed" >&2
        exit 1
    fi
fi

# Run chktex and capture output
TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT

# Run chktex (ignore exit code for now)
chktex -q -v0 "$TEX_FILE" > "$TEMP_OUTPUT" 2>&1 || true

# Count warnings and errors
WARNING_COUNT=$(grep -c "Warning" "$TEMP_OUTPUT" || true)
ERROR_COUNT=$(grep -c "Error" "$TEMP_OUTPUT" || true)
TOTAL_COUNT=$((WARNING_COUNT + ERROR_COUNT))

# Display output
if [[ "$QUIET" == false ]] && [[ -s "$TEMP_OUTPUT" ]]; then
    echo -e "${BLUE}Linting $TEX_FILE...${NC}" >&2
    echo "" >&2

    while IFS= read -r line; do
        if [[ "$line" =~ "Warning" ]]; then
            echo -e "${YELLOW}$line${NC}" >&2
        elif [[ "$line" =~ "Error" ]]; then
            echo -e "${RED}$line${NC}" >&2
        else
            echo "$line" >&2
        fi
    done < "$TEMP_OUTPUT"
    echo "" >&2
fi

# Display summary
if [[ $TOTAL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}✓ No issues found${NC}" >&2
    exit 0
else
    if [[ $ERROR_COUNT -gt 0 ]]; then
        echo -e "${RED}✗ Found $ERROR_COUNT error(s) and $WARNING_COUNT warning(s)${NC}" >&2
    else
        echo -e "${YELLOW}⚠ Found $WARNING_COUNT warning(s)${NC}" >&2
    fi

    # Exit with error if strict mode or if there are actual errors
    if [[ "$STRICT" == true ]] || [[ $ERROR_COUNT -gt 0 ]]; then
        exit 1
    fi
fi

exit 0
