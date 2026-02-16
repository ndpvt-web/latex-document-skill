#!/usr/bin/env bash
# latex_diff.sh - Generate highlighted change-tracked PDFs between two LaTeX document versions
#
# Usage:
#   latex_diff.sh OLD.tex NEW.tex [OPTIONS]
#   latex_diff.sh OLD.tex NEW.tex --git                    # Use git for OLD version
#   latex_diff.sh document.tex --git-rev HEAD~1            # Diff against git revision
#   latex_diff.sh document.tex --git-rev v1.0..v2.0       # Diff between two git tags
#
# Options:
#   --output FILE       Output diff .tex file (default: diff_OLD_NEW.tex)
#   --output-dir DIR    Output directory (default: same as NEW file)
#   --type TYPE         Markup type: UNDERLINE (default), CTRADITIONAL, CFONT,
#                       CHANGEBAR, CCHANGEBAR, CULINECHBAR, FONTSTRIKE, INVISIBLE
#   --subtype SUBTYPE   Markup subtype: SAFE (default), IDENTICAL, BOLD, COLOR,
#                       LABEL, DVIPSCOL, ZLABEL, ONLYCHANGEDPAGE
#   --flatten           Expand \input and \include before diffing (for multi-file docs)
#   --math-markup MODE  Math markup: fine (default), coarse, off, whole
#   --color-add COLOR   Color for additions (default: blue)
#   --color-del COLOR   Color for deletions (default: red)
#   --compile           Auto-compile the diff to PDF
#   --preview           Compile and generate PNG preview
#   --compile-script    Path to compile_latex.sh for compilation
#   --git-rev REV       Diff current file against a git revision
#   --exclude-safecmd   Comma-separated commands to exclude from safe cmd list
#   --exclude-textcmd   Comma-separated commands to exclude from text cmd list
#   --packages PKGS     Comma-separated packages to add to preamble
#   --verbose           Show detailed latexdiff output
#   --help              Show this help
#
# Markup Types:
#   UNDERLINE      - Additions underlined in blue, deletions struck through in red (default)
#   CTRADITIONAL   - Additions in blue, deletions in red with strikethrough (traditional)
#   CFONT          - Additions in sans-serif blue, deletions in tiny red
#   CHANGEBAR      - Change bars in margin, no inline markup
#   CCHANGEBAR     - Change bars + color changes
#   CULINECHBAR    - Underline + change bars (most comprehensive)
#   FONTSTRIKE     - Font change + strikethrough
#   INVISIBLE      - No visible markup (for testing)
#
# Examples:
#   # Basic diff between two files
#   latex_diff.sh paper_v1.tex paper_v2.tex --compile --preview
#
#   # Diff with git (current vs last commit)
#   latex_diff.sh paper.tex --git-rev HEAD~1 --compile
#
#   # Diff between two git tags
#   latex_diff.sh paper.tex --git-rev v1.0 --compile --type CULINECHBAR
#
#   # Multi-file document diff
#   latex_diff.sh thesis_v1/main.tex thesis_v2/main.tex --flatten --compile
#
#   # Custom colors
#   latex_diff.sh old.tex new.tex --color-add "green!70!black" --color-del "red!80!black"

set -euo pipefail

# --- Parse arguments ---
OLD_FILE=""
NEW_FILE=""
OUTPUT_FILE=""
OUTPUT_DIR=""
MARKUP_TYPE="UNDERLINE"
MARKUP_SUBTYPE=""
MATH_MARKUP=""
FLATTEN=false
COMPILE=false
PREVIEW=false
COMPILE_SCRIPT=""
GIT_REV=""
COLOR_ADD="blue"
COLOR_DEL="red"
EXCLUDE_SAFECMD=""
EXCLUDE_TEXTCMD=""
EXTRA_PACKAGES=""
VERBOSE=false

show_help() {
    sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) show_help ;;
        --output) OUTPUT_FILE="$2"; shift 2 ;;
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        --type) MARKUP_TYPE="$2"; shift 2 ;;
        --subtype) MARKUP_SUBTYPE="$2"; shift 2 ;;
        --math-markup) MATH_MARKUP="$2"; shift 2 ;;
        --flatten) FLATTEN=true; shift ;;
        --compile) COMPILE=true; shift ;;
        --preview) PREVIEW=true; COMPILE=true; shift ;;
        --compile-script) COMPILE_SCRIPT="$2"; shift 2 ;;
        --git-rev) GIT_REV="$2"; shift 2 ;;
        --color-add) COLOR_ADD="$2"; shift 2 ;;
        --color-del) COLOR_DEL="$2"; shift 2 ;;
        --exclude-safecmd) EXCLUDE_SAFECMD="$2"; shift 2 ;;
        --exclude-textcmd) EXCLUDE_TEXTCMD="$2"; shift 2 ;;
        --packages) EXTRA_PACKAGES="$2"; shift 2 ;;
        --verbose|-v) VERBOSE=true; shift ;;
        -*) echo "Error: Unknown option $1" >&2; exit 1 ;;
        *)
            if [[ -z "$OLD_FILE" ]]; then
                OLD_FILE="$1"
            elif [[ -z "$NEW_FILE" ]]; then
                NEW_FILE="$1"
            else
                echo "Error: Too many positional arguments" >&2; exit 1
            fi
            shift ;;
    esac
done

# --- Validate inputs ---

# Git revision mode: only one file needed
if [[ -n "$GIT_REV" ]]; then
    if [[ -z "$OLD_FILE" ]]; then
        echo "Error: No .tex file specified" >&2
        exit 1
    fi
    NEW_FILE="$OLD_FILE"
    # OLD_FILE will be extracted from git
fi

if [[ -z "$OLD_FILE" ]]; then
    echo "Error: No input files specified" >&2
    echo "Usage: latex_diff.sh OLD.tex NEW.tex [OPTIONS]" >&2
    echo "       latex_diff.sh FILE.tex --git-rev REV [OPTIONS]" >&2
    exit 1
fi

if [[ -z "$GIT_REV" && -z "$NEW_FILE" ]]; then
    echo "Error: Need two files or --git-rev option" >&2
    exit 1
fi

if [[ ! -f "$NEW_FILE" ]]; then
    echo "Error: File not found: $NEW_FILE" >&2
    exit 1
fi

if [[ -z "$GIT_REV" && ! -f "$OLD_FILE" ]]; then
    echo "Error: File not found: $OLD_FILE" >&2
    exit 1
fi

# --- Ensure latexdiff is installed ---
ensure_latexdiff() {
    if command -v latexdiff &>/dev/null; then
        if [[ "$VERBOSE" == true ]]; then
            echo ":: latexdiff found: $(latexdiff --version 2>&1 | head -1)" >&2
        fi
        return 0
    fi

    echo ":: latexdiff not found. Installing..." >&2
    if command -v sudo &>/dev/null; then
        sudo apt-get update -q >&2 2>/dev/null
        sudo apt-get install -y -q latexdiff >&2 || {
            echo "Error: Failed to install latexdiff" >&2
            exit 1
        }
    elif command -v apt-get &>/dev/null; then
        apt-get update -q >&2 2>/dev/null
        apt-get install -y -q latexdiff >&2 || {
            echo "Error: Failed to install latexdiff" >&2
            exit 1
        }
    else
        echo "Error: Cannot install latexdiff - apt-get not available" >&2
        echo "Install manually: sudo apt-get install latexdiff" >&2
        exit 1
    fi

    if ! command -v latexdiff &>/dev/null; then
        echo "Error: latexdiff still not available after install" >&2
        exit 1
    fi
    echo ":: latexdiff installed successfully" >&2
}

# --- Git revision extraction ---
extract_git_version() {
    local file="$1"
    local rev="$2"
    local tmpfile="$3"

    # Check we're in a git repo
    if ! git rev-parse --git-dir &>/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi

    # Get the file path relative to repo root
    local repo_root
    repo_root=$(git rev-parse --show-toplevel)
    local rel_path
    rel_path=$(realpath --relative-to="$repo_root" "$file" 2>/dev/null || echo "$file")

    echo ":: Extracting $rel_path at revision $rev..." >&2

    if git show "${rev}:${rel_path}" > "$tmpfile" 2>/dev/null; then
        return 0
    else
        # Try with just the filename
        if git show "${rev}:$(basename "$file")" > "$tmpfile" 2>/dev/null; then
            return 0
        fi
        echo "Error: Cannot find $rel_path at revision $rev" >&2
        echo "  Tried: git show ${rev}:${rel_path}" >&2
        exit 1
    fi
}

# --- Build latexdiff command ---
build_diff_cmd() {
    local old="$1"
    local new="$2"
    local output="$3"

    local cmd=(latexdiff)

    # Markup type
    cmd+=(--type="$MARKUP_TYPE")

    # Subtype
    if [[ -n "$MARKUP_SUBTYPE" ]]; then
        cmd+=(--subtype="$MARKUP_SUBTYPE")
    fi

    # Math markup
    if [[ -n "$MATH_MARKUP" ]]; then
        cmd+=(--math-markup="$MATH_MARKUP")
    fi

    # Flatten for multi-file documents
    if [[ "$FLATTEN" == true ]]; then
        cmd+=(--flatten)
    fi

    # Exclude commands
    if [[ -n "$EXCLUDE_SAFECMD" ]]; then
        cmd+=(--exclude-safecmd="$EXCLUDE_SAFECMD")
    fi

    if [[ -n "$EXCLUDE_TEXTCMD" ]]; then
        cmd+=(--exclude-textcmd="$EXCLUDE_TEXTCMD")
    fi

    # Extra packages
    if [[ -n "$EXTRA_PACKAGES" ]]; then
        cmd+=(--packages="$EXTRA_PACKAGES")
    fi

    # Allow spaces in labels/refs
    cmd+=(--allow-spaces)

    # Input files
    cmd+=("$old" "$new")

    echo "${cmd[@]}"
}

# --- Custom color preamble injection ---
inject_custom_colors() {
    local diff_file="$1"
    local color_add="$2"
    local color_del="$3"

    # Only inject if non-default colors
    if [[ "$color_add" == "blue" && "$color_del" == "red" ]]; then
        return
    fi

    # Create color override commands
    local color_cmds=""
    if [[ "$color_add" != "blue" ]]; then
        color_cmds+="\\\providecommand{\\\\DIFaddcolor}{\\\\color{${color_add}}}\n"
    fi
    if [[ "$color_del" != "red" ]]; then
        color_cmds+="\\\providecommand{\\\\DIFdelcolor}{\\\\color{${color_del}}}\n"
    fi

    if [[ -n "$color_cmds" ]]; then
        # Insert after \begin{document}
        sed -i "/\\\\begin{document}/a\\
${color_cmds}" "$diff_file"
    fi
}

# --- Main execution ---

ensure_latexdiff

# Resolve paths
NEW_FILE="$(realpath "$NEW_FILE")"
NEW_DIR="$(dirname "$NEW_FILE")"
NEW_BASE="$(basename "$NEW_FILE" .tex)"

if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$NEW_DIR"
fi
mkdir -p "$OUTPUT_DIR"

# Handle git revision mode
CLEANUP_TMP=false
if [[ -n "$GIT_REV" ]]; then
    TMP_OLD=$(mktemp /tmp/latexdiff_old_XXXXXX.tex)
    CLEANUP_TMP=true
    extract_git_version "$NEW_FILE" "$GIT_REV" "$TMP_OLD"
    OLD_FILE="$TMP_OLD"

    # Default output name for git mode
    if [[ -z "$OUTPUT_FILE" ]]; then
        SAFE_REV=$(echo "$GIT_REV" | tr '/:~^' '____')
        OUTPUT_FILE="${OUTPUT_DIR}/diff_${SAFE_REV}_vs_current_${NEW_BASE}.tex"
    fi
else
    OLD_FILE="$(realpath "$OLD_FILE")"
    OLD_BASE="$(basename "$OLD_FILE" .tex)"

    if [[ -z "$OUTPUT_FILE" ]]; then
        OUTPUT_FILE="${OUTPUT_DIR}/diff_${OLD_BASE}_vs_${NEW_BASE}.tex"
    fi
fi

echo ":: Generating diff..."
echo "   Old: $(basename "$OLD_FILE")"
echo "   New: $(basename "$NEW_FILE")"
echo "   Type: $MARKUP_TYPE"
echo "   Output: $OUTPUT_FILE"

# Build and run latexdiff
DIFF_CMD=$(build_diff_cmd "$OLD_FILE" "$NEW_FILE" "$OUTPUT_FILE")

if [[ "$VERBOSE" == true ]]; then
    echo ":: Running: $DIFF_CMD" >&2
fi

if eval "$DIFF_CMD" > "$OUTPUT_FILE" 2>/tmp/latexdiff_stderr.txt; then
    echo ":: Diff generated: $OUTPUT_FILE"
else
    STDERR=$(cat /tmp/latexdiff_stderr.txt)
    # latexdiff often writes warnings to stderr but still produces output
    if [[ -s "$OUTPUT_FILE" ]]; then
        echo ":: Diff generated with warnings: $OUTPUT_FILE" >&2
        if [[ "$VERBOSE" == true ]]; then
            echo ":: Warnings: $STDERR" >&2
        fi
    else
        echo "Error: latexdiff failed" >&2
        echo "$STDERR" >&2
        [[ "$CLEANUP_TMP" == true ]] && rm -f "$TMP_OLD"
        exit 1
    fi
fi

# Inject custom colors
inject_custom_colors "$OUTPUT_FILE" "$COLOR_ADD" "$COLOR_DEL"

# Cleanup temp files
[[ "$CLEANUP_TMP" == true ]] && rm -f "$TMP_OLD"

# --- Compile diff ---
if [[ "$COMPILE" == true ]]; then
    echo ":: Compiling diff PDF..."

    if [[ -n "$COMPILE_SCRIPT" ]]; then
        COMPILE_CMD="bash $COMPILE_SCRIPT $OUTPUT_FILE"
        if [[ "$PREVIEW" == true ]]; then
            COMPILE_CMD="$COMPILE_CMD --preview --preview-dir $OUTPUT_DIR"
        fi
    else
        # Find compile_latex.sh relative to this script
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [[ -f "${SCRIPT_DIR}/compile_latex.sh" ]]; then
            COMPILE_CMD="bash ${SCRIPT_DIR}/compile_latex.sh $OUTPUT_FILE"
            if [[ "$PREVIEW" == true ]]; then
                COMPILE_CMD="$COMPILE_CMD --preview --preview-dir $OUTPUT_DIR"
            fi
        else
            # Direct compilation fallback
            ENGINE="pdflatex"
            # Auto-detect engine from the diff file
            if grep -qE '\\usepackage\{fontspec\}|\\usepackage\{xeCJK\}' "$OUTPUT_FILE" 2>/dev/null; then
                ENGINE="xelatex"
            fi
            COMPILE_CMD="cd $(dirname "$OUTPUT_FILE") && $ENGINE -interaction=nonstopmode $(basename "$OUTPUT_FILE")"
        fi
    fi

    if [[ "$VERBOSE" == true ]]; then
        echo ":: Running: $COMPILE_CMD" >&2
    fi

    if eval "$COMPILE_CMD"; then
        PDF_FILE="${OUTPUT_FILE%.tex}.pdf"
        if [[ -f "$PDF_FILE" ]]; then
            echo ":: Diff PDF: $PDF_FILE"
        fi
    else
        echo ":: Compilation had errors (diff PDF may still be usable)" >&2
    fi
fi

echo ":: Done."
