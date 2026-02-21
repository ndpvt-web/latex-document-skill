# Script & Tool Reference

Complete reference for all automation scripts in the latex-document skill. Load when you need to use PDF utilities, quality checks, or conversion tools.

## PDF Tools

### PDF-to-Images Script

```bash
# Split PDF and resize for API compatibility
bash <skill_path>/scripts/pdf_to_images.sh input.pdf ./tmp/pages

# Custom DPI and max dimension
bash <skill_path>/scripts/pdf_to_images.sh input.pdf ./tmp/pages --dpi 200 --max-dim 2000
```

Auto-installs `poppler-utils` and `imagemagick`, renders pages as PNG, resizes to fit within API image dimension limits (2000px max).

### PDF Encryption

**IMPORTANT: ALWAYS use the AskUserQuestion tool to ask the user what password they want BEFORE encrypting any PDF. NEVER use a default or auto-generated password. The user must explicitly choose their password.**

```bash
# Encrypt a PDF with AES-256
bash <skill_path>/scripts/pdf_encrypt.sh document.pdf --user-password "<USER_PASSWORD>"

# With separate owner password and restrictions
bash <skill_path>/scripts/pdf_encrypt.sh document.pdf --user-password "<USER_PASSWORD>" --owner-password "<OWNER_PASSWORD>" --restrict-print --restrict-modify

# Custom output path
bash <skill_path>/scripts/pdf_encrypt.sh document.pdf --user-password "<USER_PASSWORD>" --output secure.pdf
```

When the user asks to encrypt, protect, or password-protect a PDF, use this workflow:
1. Use **AskUserQuestion** to ask: "What password would you like to use to protect this PDF?"
2. Wait for the user's response
3. Run `pdf_encrypt.sh` with the password they provided
4. Report success and remind the user to remember their password

### PDF Merge

```bash
# Merge multiple PDFs into one
bash <skill_path>/scripts/pdf_merge.sh file1.pdf file2.pdf file3.pdf -o merged.pdf
```

### PDF Optimize

```bash
# Compress and linearize a PDF for web delivery or email
bash <skill_path>/scripts/pdf_optimize.sh document.pdf optimized.pdf
```

### PDF Page Extraction

```bash
# Extract pages 1-10 from a PDF
bash <skill_path>/scripts/pdf_extract_pages.sh input.pdf --pages 1-10

# Extract specific pages with custom output
bash <skill_path>/scripts/pdf_extract_pages.sh input.pdf --pages 1,3,5-8 --output selected.pdf

# Extract odd or even pages only
bash <skill_path>/scripts/pdf_extract_pages.sh input.pdf --pages odd --output odd_pages.pdf

# Extract the last 3 pages
bash <skill_path>/scripts/pdf_extract_pages.sh input.pdf --pages last:3
```

### PDF Form Operations

```bash
# Check if PDF has fillable form fields
python3 <skill_path>/scripts/pdf_check_form.py input.pdf

# Extract form field info to JSON (field IDs, types, pages, rects)
python3 <skill_path>/scripts/pdf_extract_fields.py input.pdf field_info.json

# Fill fillable form fields (validates field IDs/pages/values before writing)
python3 <skill_path>/scripts/pdf_fill_form.py input.pdf field_values.json output.pdf

# Fill non-fillable forms with text annotations at bounding box positions
python3 <skill_path>/scripts/pdf_fill_annotations.py input.pdf fields.json output.pdf

# Validate bounding boxes (check intersections and entry height vs font size)
python3 <skill_path>/scripts/pdf_validate_boxes.py fields.json

# Create validation image showing bounding boxes overlaid on page image
python3 <skill_path>/scripts/pdf_validate_boxes.py fields.json \
    --image page-001.png --output validation.png --page 1
```

**Workflow for fillable PDFs:** `pdf_check_form.py` -> `pdf_extract_fields.py` -> create `field_values.json` -> `pdf_fill_form.py`

**Workflow for non-fillable PDFs:** `pdf_check_form.py` -> `pdf_to_images.sh` -> create `fields.json` with bounding boxes -> `pdf_validate_boxes.py` (validate + create validation images) -> `pdf_fill_annotations.py`

See `references/pdf-operations.md` for detailed field format documentation and advanced PDF operations.

## LaTeX Quality Tools

### Lint (Pre-Compilation Check)

```bash
# Run chktex linter with formatted output
bash <skill_path>/scripts/latex_lint.sh document.tex
```

### Word Count

```bash
# Count words (strips LaTeX commands)
bash <skill_path>/scripts/latex_wordcount.sh document.tex
```

### Document Analysis

```bash
# Get statistics: word count, figures, tables, equations, citations, sections
bash <skill_path>/scripts/latex_analyze.sh document.tex
```

### Package Availability Check

```bash
# Pre-flight check: verify all \usepackage packages are installed
bash <skill_path>/scripts/latex_package_check.sh document.tex

# With auto-install of missing packages
bash <skill_path>/scripts/latex_package_check.sh document.tex --install

# Verbose output showing each package check
bash <skill_path>/scripts/latex_package_check.sh document.tex --verbose
```

### Citation Analysis

```bash
# Extract all \cite{} keys from a .tex file
bash <skill_path>/scripts/latex_citation_extract.sh document.tex

# Cross-reference citations against a .bib file (auto-detects from \bibliography{})
bash <skill_path>/scripts/latex_citation_extract.sh document.tex --check

# Specify .bib file explicitly, output as JSON
bash <skill_path>/scripts/latex_citation_extract.sh document.tex --bib refs.bib --format json
```

## Compilation Tools

### Auto-Fix Mode

```bash
# Compile with automatic fixes for common issues
bash <skill_path>/scripts/compile_latex.sh document.tex --auto-fix

# Auto-fix + preview
bash <skill_path>/scripts/compile_latex.sh document.tex --auto-fix --preview --preview-dir ./outputs
```

`--auto-fix` creates a temporary copy and applies:
- **Stage 1:** Adds `[htbp]` placement to naked `\begin{figure}` and `\begin{table}` (the #1 LaTeX complaint)
- **Stage 2:** If overfull hbox warnings are detected, injects `\usepackage{microtype}` and recompiles

The script also parses the `.log` file and translates cryptic LaTeX errors into actionable suggestions (missing `$`, undefined commands, missing packages, unbalanced braces, undefined citations).

## Bibliography Tools

### Fetch BibTeX

```bash
# Auto-download BibTeX from a DOI
bash <skill_path>/scripts/fetch_bibtex.sh 10.1145/359576.359579

# Append to an existing .bib file
bash <skill_path>/scripts/fetch_bibtex.sh 10.1145/359576.359579 >> references.bib
```

## Diagram Tools

### Diagram Conversion Scripts

```bash
# Convert Graphviz .dot to PDF
bash <skill_path>/scripts/graphviz_to_pdf.sh diagram.dot output.pdf

# Convert PlantUML .puml to PDF
bash <skill_path>/scripts/plantuml_to_pdf.sh diagram.puml output.pdf
```
