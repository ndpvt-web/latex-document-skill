#!/usr/bin/env bash

# fetch_bibtex.sh
# Auto-download BibTeX entries from DOIs or arXiv IDs
#
# Examples:
#   ./fetch_bibtex.sh 10.1038/nature12373
#   ./fetch_bibtex.sh 2301.07041 --output references.bib
#   ./fetch_bibtex.sh 10.1145/3290605.3300608 1906.08237 --append --output refs.bib

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
OUTPUT_FILE=""
APPEND_MODE=false
IDENTIFIERS=()

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print usage
usage() {
    cat << EOF
Usage: $0 <DOI_or_arXiv_ID> [<DOI_or_arXiv_ID> ...] [OPTIONS]

Auto-download BibTeX entries from DOIs or arXiv IDs.

Arguments:
  DOI_or_arXiv_ID   One or more DOIs (e.g., 10.1038/nature12373) or
                    arXiv IDs (e.g., 2301.07041 or arXiv:2301.07041)

Options:
  --output <file>   Output .bib file (default: stdout)
  --append          Append to existing .bib file instead of overwriting
  -h, --help        Show this help message

Examples:
  $0 10.1038/nature12373
  $0 2301.07041 --output references.bib
  $0 10.1145/3290605.3300608 1906.08237 --append --output refs.bib

Requires: curl (usually pre-installed)
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
        --append)
            APPEND_MODE=true
            shift
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)
            IDENTIFIERS+=("$1")
            shift
            ;;
    esac
done

# Validate we have at least one identifier
if [[ ${#IDENTIFIERS[@]} -eq 0 ]]; then
    echo "Error: No DOI or arXiv ID specified" >&2
    echo "Run '$0 --help' for usage information" >&2
    exit 1
fi

# Check for curl
if ! command -v curl &>/dev/null; then
    echo "Error: curl not found. Please install curl:" >&2
    echo "  Debian/Ubuntu:  sudo apt-get install curl" >&2
    echo "  macOS:          brew install curl" >&2
    echo "  Fedora/RHEL:    sudo dnf install curl" >&2
    echo "  Alpine:         sudo apk add curl" >&2
    echo "  Arch:           sudo pacman -S curl" >&2
    exit 1
fi

# Function to detect if identifier is DOI or arXiv
detect_type() {
    local id="$1"

    # Strip 'arXiv:' prefix if present
    id="${id#arXiv:}"
    id="${id#arxiv:}"

    # arXiv pattern: 4 digits, optional dot, 4-5 digits, optional version
    # Examples: 2301.07041, 2301.07041v1, 1906.08237
    if [[ "$id" =~ ^[0-9]{4}\.[0-9]{4,5}(v[0-9]+)?$ ]]; then
        echo "arxiv"
    # DOI pattern: starts with 10.
    elif [[ "$id" =~ ^10\. ]]; then
        echo "doi"
    else
        echo "unknown"
    fi
}

# Function to fetch BibTeX from DOI
fetch_doi() {
    local doi="$1"

    echo "Fetching DOI: $doi..." >&2

    local bibtex
    bibtex=$(curl -sL -H "Accept: application/x-bibtex" "https://doi.org/$doi" 2>&1)

    if [[ $? -ne 0 ]] || [[ -z "$bibtex" ]]; then
        echo -e "${RED}Error: Failed to fetch BibTeX for DOI: $doi${NC}" >&2
        return 1
    fi

    # Basic validation: check if it looks like BibTeX
    if ! echo "$bibtex" | grep -q '@'; then
        echo -e "${RED}Error: Invalid BibTeX response for DOI: $doi${NC}" >&2
        echo "Response: $bibtex" >&2
        return 1
    fi

    echo "$bibtex"
    return 0
}

# Function to fetch BibTeX from arXiv
fetch_arxiv() {
    local arxiv_id="$1"

    # Strip 'arXiv:' prefix if present
    arxiv_id="${arxiv_id#arXiv:}"
    arxiv_id="${arxiv_id#arxiv:}"

    echo "Fetching arXiv: $arxiv_id..." >&2

    # Fetch from arXiv API (returns Atom XML)
    local xml
    xml=$(curl -sL "http://export.arxiv.org/api/query?id_list=$arxiv_id" 2>&1)

    if [[ $? -ne 0 ]] || [[ -z "$xml" ]]; then
        echo -e "${RED}Error: Failed to fetch metadata for arXiv: $arxiv_id${NC}" >&2
        return 1
    fi

    # Check if entry exists
    if echo "$xml" | grep -q "Error: incorrect id format"; then
        echo -e "${RED}Error: Invalid arXiv ID: $arxiv_id${NC}" >&2
        return 1
    fi

    # Parse XML and generate BibTeX
    # Extract: title, authors, published date, summary
    local title=$(echo "$xml" | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' | tail -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    local authors=$(echo "$xml" | sed -n 's/.*<name>\(.*\)<\/name>.*/\1/p' | paste -sd " and " -)
    local year=$(echo "$xml" | sed -n 's/.*<published>\([0-9]\{4\}\).*/\1/p' | head -n 1)
    local summary=$(echo "$xml" | sed -n 's/.*<summary>\(.*\)<\/summary>.*/\1/p' | sed 's/^[ \t]*//;s/[ \t]*$//')

    # Generate citation key
    local first_author=$(echo "$authors" | cut -d' ' -f1)
    local cite_key="${first_author}${year}arxiv"

    # Build BibTeX entry
    cat << EOF
@misc{$cite_key,
  title={$title},
  author={$authors},
  year={$year},
  eprint={$arxiv_id},
  archivePrefix={arXiv},
  primaryClass={cs.AI}
}
EOF

    return 0
}

# Main processing
ALL_BIBTEX=""
SUCCESS_COUNT=0
FAILED_COUNT=0

for identifier in "${IDENTIFIERS[@]}"; do
    TYPE=$(detect_type "$identifier")

    case "$TYPE" in
        doi)
            if bibtex_entry=$(fetch_doi "$identifier"); then
                ALL_BIBTEX="${ALL_BIBTEX}${bibtex_entry}\n\n"
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
            ;;
        arxiv)
            if bibtex_entry=$(fetch_arxiv "$identifier"); then
                ALL_BIBTEX="${ALL_BIBTEX}${bibtex_entry}\n\n"
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
            ;;
        *)
            echo -e "${RED}Error: Could not detect type for identifier: $identifier${NC}" >&2
            echo "Supported formats: DOI (10.xxxx/...) or arXiv (YYMM.NNNNN)" >&2
            FAILED_COUNT=$((FAILED_COUNT + 1))
            ;;
    esac
done

# Output results
if [[ $SUCCESS_COUNT -eq 0 ]]; then
    echo -e "${RED}Error: Failed to fetch any BibTeX entries${NC}" >&2
    exit 1
fi

if [[ -z "$OUTPUT_FILE" ]]; then
    # Output to stdout
    echo -e "$ALL_BIBTEX"
else
    # Output to file
    if [[ "$APPEND_MODE" == true ]] && [[ -f "$OUTPUT_FILE" ]]; then
        echo -e "\n$ALL_BIBTEX" >> "$OUTPUT_FILE"
        echo -e "${GREEN}✓ Appended $SUCCESS_COUNT BibTeX entry(ies) to: $OUTPUT_FILE${NC}" >&2
    else
        echo -e "$ALL_BIBTEX" > "$OUTPUT_FILE"
        echo -e "${GREEN}✓ Wrote $SUCCESS_COUNT BibTeX entry(ies) to: $OUTPUT_FILE${NC}" >&2
    fi
fi

if [[ $FAILED_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}⚠ Failed to fetch $FAILED_COUNT entry(ies)${NC}" >&2
    exit 1
fi

exit 0
