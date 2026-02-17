#!/usr/bin/env bash
# latex_citation_extract.sh - Extract and analyze citations from a .tex file
#
# Usage:
#   latex_citation_extract.sh <input.tex> [--bib <file.bib>] [--format json|text] [--check]
#
# Options:
#   --bib <file>      Specify .bib file (auto-detects from \bibliography{} or \addbibresource{})
#   --format <fmt>    Output format: text (default) or json
#   --check           Verify all citations exist in .bib file, report missing
#
# Features:
#   - Extracts all \cite{}, \citep{}, \citet{}, \citealp{}, \citealt{} commands
#   - Counts usage per citation key
#   - Auto-detects bibliography files from document
#   - Cross-references citations with .bib entries
#   - JSON output for programmatic use
#   - Identifies missing citations
#
# Examples:
#   latex_citation_extract.sh paper.tex
#   latex_citation_extract.sh paper.tex --bib references.bib --check
#   latex_citation_extract.sh paper.tex --format json
#   latex_citation_extract.sh paper.tex --bib refs.bib --check --format text

set -euo pipefail

# --- Usage function ---
usage() {
  cat <<'EOF'
latex_citation_extract.sh - Extract and analyze citations from a .tex file

Usage:
  latex_citation_extract.sh <input.tex> [--bib <file.bib>] [--format json|text] [--check]

Options:
  --bib <file>      Specify .bib file (auto-detects from \bibliography{} or \addbibresource{})
  --format <fmt>    Output format: text (default) or json
  --check           Verify all citations exist in .bib file, report missing

Features:
  - Extracts all \cite{}, \citep{}, \citet{}, \citealp{}, \citealt{} commands
  - Counts usage per citation key
  - Auto-detects bibliography files from document
  - Cross-references citations with .bib entries
  - JSON output for programmatic use
  - Identifies missing citations

Examples:
  latex_citation_extract.sh paper.tex
  latex_citation_extract.sh paper.tex --bib references.bib --check
  latex_citation_extract.sh paper.tex --format json
  latex_citation_extract.sh paper.tex --bib refs.bib --check --format text
EOF
}

# --- Source cross-platform dependency installer ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# --- Parse arguments ---
INPUT_TEX=""
BIB_FILE=""
FORMAT="text"
CHECK=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --bib) BIB_FILE="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    --check) CHECK=true; shift ;;
    -*) echo "Error: Unknown option $1" >&2; exit 1 ;;
    *) INPUT_TEX="$1"; shift ;;
  esac
done

if [[ -z "$INPUT_TEX" ]]; then
  echo "Error: No input .tex file specified" >&2
  echo "Usage: latex_citation_extract.sh <input.tex> [--bib <file.bib>] [--format json|text] [--check]" >&2
  exit 1
fi

if [[ ! -f "$INPUT_TEX" ]]; then
  echo "Error: File not found: $INPUT_TEX" >&2
  exit 1
fi

if [[ "$FORMAT" != "text" && "$FORMAT" != "json" ]]; then
  echo "Error: Invalid format '$FORMAT'. Must be 'text' or 'json'" >&2
  exit 1
fi

# Resolve absolute path
INPUT_TEX="$(realpath "$INPUT_TEX")"
INPUT_DIR="$(dirname "$INPUT_TEX")"

# --- Auto-detect bibliography file ---
detect_bib_file() {
  local tex_file="$1"
  local tex_dir="$2"

  # Look for \bibliography{filename} or \addbibresource{filename.bib}
  local bib_name=""

  # Try \bibliography{} first
  bib_name=$(grep -oP '\\bibliography\{\K[^\}]+' "$tex_file" 2>/dev/null | head -1)

  if [[ -n "$bib_name" ]]; then
    # Add .bib extension if not present
    if [[ ! "$bib_name" =~ \.bib$ ]]; then
      bib_name="${bib_name}.bib"
    fi
    # Check if file exists (relative to tex file)
    if [[ -f "${tex_dir}/${bib_name}" ]]; then
      echo "${tex_dir}/${bib_name}"
      return 0
    fi
  fi

  # Try \addbibresource{}
  bib_name=$(grep -oP '\\addbibresource\{\K[^\}]+' "$tex_file" 2>/dev/null | head -1)

  if [[ -n "$bib_name" ]]; then
    # addbibresource requires .bib extension
    if [[ -f "${tex_dir}/${bib_name}" ]]; then
      echo "${tex_dir}/${bib_name}"
      return 0
    fi
  fi

  # No bibliography found
  echo ""
}

# --- Extract citations from .tex file ---
extract_citations() {
  local tex_file="$1"

  # Extract all cite commands: \cite, \citep, \citet, \citealp, \citealt, \nocite
  # Handle optional arguments and comma-separated keys
  grep -oP '\\(?:cite[a-z]*|nocite)(?:\[[^\]]*\])?(?:\[[^\]]*\])?\{[^\}]+\}' "$tex_file" 2>/dev/null | \
    sed -E 's/\\(cite[a-z]*|nocite)(\[[^]]*\])?(\[[^]]*\])?\{([^}]+)\}/\4/' | \
    tr ',' '\n' | \
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
    grep -v '^$' || true
}

# --- Extract citation keys from .bib file ---
extract_bib_keys() {
  local bib_file="$1"

  # Extract @article{key, @book{key, etc.
  grep -oP '@[a-zA-Z]+\{\K[^,\}]+' "$bib_file" 2>/dev/null | \
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
    grep -v '^$' | \
    sort -u || true
}

# --- Count citations ---
count_citations() {
  local citations="$1"

  # Count occurrences of each citation
  echo "$citations" | sort | uniq -c | sort -rn
}

# --- Main extraction ---
if [[ "$FORMAT" == "text" ]]; then
  echo ":: Analyzing citations in: $INPUT_TEX" >&2
  echo "" >&2
fi

# Auto-detect bib file if not specified
if [[ -z "$BIB_FILE" ]]; then
  BIB_FILE=$(detect_bib_file "$INPUT_TEX" "$INPUT_DIR")
  if [[ -n "$BIB_FILE" ]]; then
    if [[ "$FORMAT" == "text" ]]; then
      echo ":: Auto-detected bibliography: $BIB_FILE" >&2
      echo "" >&2
    fi
  else
    if [[ "$CHECK" == true ]]; then
      echo "Warning: No bibliography file found. Cannot verify citations." >&2
      echo "Specify with --bib <file.bib>" >&2
      echo "" >&2
    fi
  fi
elif [[ ! -f "$BIB_FILE" ]]; then
  # If user specified a relative path, try relative to tex file
  if [[ ! "$BIB_FILE" =~ ^/ ]]; then
    BIB_FILE="${INPUT_DIR}/${BIB_FILE}"
  fi
  if [[ ! -f "$BIB_FILE" ]]; then
    echo "Error: Bibliography file not found: $BIB_FILE" >&2
    exit 1
  fi
fi

# Extract citations
CITATIONS=$(extract_citations "$INPUT_TEX")

if [[ -z "$CITATIONS" ]]; then
  if [[ "$FORMAT" == "text" ]]; then
    echo "No citations found in document."
  else
    echo '{"citations":[],"total":0,"unique":0}'
  fi
  exit 0
fi

# Count unique citations
UNIQUE_CITATIONS=$(echo "$CITATIONS" | sort -u)
TOTAL_CITATIONS=$(echo "$CITATIONS" | wc -l)
UNIQUE_COUNT=$(echo "$UNIQUE_CITATIONS" | wc -l)

# Get counts per citation
CITATION_COUNTS=$(count_citations "$CITATIONS")

# Extract bib keys if checking
if [[ "$CHECK" == true && -n "$BIB_FILE" ]]; then
  BIB_KEYS=$(extract_bib_keys "$BIB_FILE")
fi

# --- Output in requested format ---
if [[ "$FORMAT" == "json" ]]; then
  # JSON output
  echo "{"
  echo "  \"source_file\": \"$INPUT_TEX\","
  echo "  \"bib_file\": \"${BIB_FILE:-null}\","
  echo "  \"total_citations\": $TOTAL_CITATIONS,"
  echo "  \"unique_citations\": $UNIQUE_COUNT,"
  echo "  \"citations\": ["

  first=true
  while IFS= read -r line; do
    count=$(echo "$line" | awk '{print $1}')
    key=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^[[:space:]]*//')

    if [[ "$first" == true ]]; then
      first=false
    else
      echo ","
    fi

    echo -n "    {\"key\":\"$key\",\"count\":$count"

    # Check if in bib file
    if [[ "$CHECK" == true && -n "$BIB_FILE" ]]; then
      if echo "$BIB_KEYS" | grep -qx "$key"; then
        echo -n ",\"in_bib\":true}"
      else
        echo -n ",\"in_bib\":false}"
      fi
    else
      echo -n "}"
    fi
  done <<< "$CITATION_COUNTS"

  echo ""

  # Add missing citations if checking
  if [[ "$CHECK" == true && -n "$BIB_FILE" ]]; then
    echo "  ],"
    echo -n "  \"missing_citations\": ["

    MISSING=()
    while IFS= read -r cite_key; do
      if ! echo "$BIB_KEYS" | grep -qx "$cite_key"; then
        MISSING+=("$cite_key")
      fi
    done <<< "$UNIQUE_CITATIONS"

    first=true
    for key in "${MISSING[@]}"; do
      if [[ "$first" == true ]]; then
        first=false
      else
        echo -n ","
      fi
      echo -n "\"$key\""
    done
    echo "]"
  else
    echo "  ]"
  fi

  echo "}"
else
  # Text output
  echo "=== Citation Analysis ==="
  echo "Total citations: $TOTAL_CITATIONS"
  echo "Unique citations: $UNIQUE_COUNT"
  echo ""
  echo "Citations by frequency:"
  echo ""

  while IFS= read -r line; do
    count=$(echo "$line" | awk '{print $1}')
    key=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^[[:space:]]*//')

    printf "  [%3d] %s" "$count" "$key"

    # Check if in bib file
    if [[ "$CHECK" == true && -n "$BIB_FILE" ]]; then
      if echo "$BIB_KEYS" | grep -qx "$key"; then
        echo " ✓"
      else
        echo " ✗ MISSING"
      fi
    else
      echo ""
    fi
  done <<< "$CITATION_COUNTS"

  # Summary of missing citations
  if [[ "$CHECK" == true && -n "$BIB_FILE" ]]; then
    echo ""

    MISSING=()
    while IFS= read -r cite_key; do
      if ! echo "$BIB_KEYS" | grep -qx "$cite_key"; then
        MISSING+=("$cite_key")
      fi
    done <<< "$UNIQUE_CITATIONS"

    if [[ ${#MISSING[@]} -gt 0 ]]; then
      echo "=== Missing Citations ==="
      echo "The following ${#MISSING[@]} citation(s) are not in $BIB_FILE:"
      echo ""
      for key in "${MISSING[@]}"; do
        echo "  ✗ $key"
      done
      echo ""
      echo "Add these entries to your bibliography file or remove the citations."
      exit 1
    else
      echo "=== Verification ==="
      echo "✓ All citations are present in bibliography file"
    fi
  fi
fi
