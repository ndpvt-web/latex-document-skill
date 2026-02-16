#!/usr/bin/env bash
# pdf_to_images.sh - Split a PDF into page images for OCR/vision processing
#
# Usage:
#   pdf_to_images.sh <input.pdf> <output_dir> [--dpi <dpi>] [--max-dim <pixels>]
#
# Options:
#   --dpi       Resolution for rendering (default: 200)
#   --max-dim   Max dimension in pixels; images are resized if larger (default: 2000)
#
# Output:
#   Creates page-001.png, page-002.png, etc. in output_dir
#   Prints total page count on success

set -euo pipefail

# --- Source cross-platform dependency installer ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

INPUT_PDF=""
OUTPUT_DIR=""
DPI=200
MAX_DIM=2000

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dpi) DPI="$2"; shift 2 ;;
    --max-dim) MAX_DIM="$2"; shift 2 ;;
    -*) echo "Error: Unknown option $1" >&2; exit 1 ;;
    *)
      if [[ -z "$INPUT_PDF" ]]; then
        INPUT_PDF="$1"
      elif [[ -z "$OUTPUT_DIR" ]]; then
        OUTPUT_DIR="$1"
      fi
      shift ;;
  esac
done

if [[ -z "$INPUT_PDF" || -z "$OUTPUT_DIR" ]]; then
  echo "Usage: pdf_to_images.sh <input.pdf> <output_dir> [--dpi <dpi>] [--max-dim <pixels>]" >&2
  exit 1
fi

# Ensure dependencies
MISSING_DEPS=()
command -v pdftoppm &>/dev/null || MISSING_DEPS+=("poppler")
command -v pdfinfo  &>/dev/null || { [[ ! " ${MISSING_DEPS[*]} " =~ " poppler " ]] && MISSING_DEPS+=("poppler"); }
command -v mogrify  &>/dev/null || MISSING_DEPS+=("imagemagick")

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  echo ":: Installing dependencies: ${MISSING_DEPS[*]}..." >&2
  install_packages "${MISSING_DEPS[@]}" || {
    echo "Error: Failed to install dependencies." >&2
    for dep in "${MISSING_DEPS[@]}"; do
      print_install_help "$dep"
    done
    exit 1
  }
fi

mkdir -p "$OUTPUT_DIR"

# Get page count
PAGES=$(pdfinfo "$INPUT_PDF" 2>/dev/null | grep "Pages:" | awk '{print $2}')
if [[ -z "$PAGES" || "$PAGES" -eq 0 ]]; then
  echo "Error: Could not determine page count from PDF" >&2
  exit 1
fi
echo ":: PDF has $PAGES pages" >&2

# Render to PNG
echo ":: Rendering at ${DPI} DPI..." >&2
pdftoppm -png -r "$DPI" "$INPUT_PDF" "${OUTPUT_DIR}/page"

# Rename to zero-padded 3-digit format
cd "$OUTPUT_DIR"
shopt -s nullglob
FILES=(page-*.png)
shopt -u nullglob

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Error: pdftoppm produced no PNG files" >&2
  exit 1
fi

for f in "${FILES[@]}"; do
  # pdftoppm may produce page-1.png or page-01.png depending on page count
  NUM=$(echo "$f" | sed 's/page-0*\([0-9]*\)\.png/\1/')
  PADDED=$(printf "page-%03d.png" "$NUM")
  if [[ "$f" != "$PADDED" ]]; then
    mv "$f" "$PADDED" 2>/dev/null || true
  fi
done

# Resize if needed (API limit: 2000px max for multi-image requests)
shopt -s nullglob
PNG_FILES=(page-*.png)
shopt -u nullglob

if [[ ${#PNG_FILES[@]} -gt 0 ]]; then
  SAMPLE="${PNG_FILES[0]}"
  WIDTH=$(identify -format '%w' "$SAMPLE" 2>/dev/null || echo 0)
  HEIGHT=$(identify -format '%h' "$SAMPLE" 2>/dev/null || echo 0)

  if [[ "$WIDTH" -gt "$MAX_DIM" || "$HEIGHT" -gt "$MAX_DIM" ]]; then
    echo ":: Resizing ${#PNG_FILES[@]} images from ${WIDTH}x${HEIGHT} to fit within ${MAX_DIM}px..." >&2
    local_count=0
    for img in "${PNG_FILES[@]}"; do
      mogrify -resize "${MAX_DIM}x${MAX_DIM}>" "$img"
      local_count=$((local_count + 1))
      if (( local_count % 10 == 0 )); then
        echo "::   Resized ${local_count}/${#PNG_FILES[@]}..." >&2
      fi
    done
    NEW_W=$(identify -format '%w' "$SAMPLE" 2>/dev/null)
    NEW_H=$(identify -format '%h' "$SAMPLE" 2>/dev/null)
    echo ":: Resized all ${#PNG_FILES[@]} images to ~${NEW_W}x${NEW_H}" >&2
  fi
fi

FINAL_COUNT=${#PNG_FILES[@]}
echo ":: Created $FINAL_COUNT page images in $OUTPUT_DIR" >&2
echo "$FINAL_COUNT"
