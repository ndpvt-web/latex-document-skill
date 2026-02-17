---
name: latex-document
description: >
  Universal LaTeX document skill: create, compile, and convert any document to
  professional PDF with PNG previews. Supports resumes, reports, cover letters,
  invoices, academic papers, theses/dissertations, academic CVs, presentations
  (Beamer), scientific posters, formal letters, exams/quizzes, books,
  cheat sheets, reference cards, exam formula sheets,
  fillable PDF forms (hyperref form fields), conditional content (etoolbox toggles),
  mail merge from CSV/JSON (Jinja2 templates), version diffing (latexdiff),
  charts (pgfplots + matplotlib), tables (booktabs + CSV import), images (TikZ),
  Mermaid diagrams, AI-generated images, watermarks, landscape pages,
  bibliography/citations (BibTeX/biblatex), multi-language/CJK (auto XeLaTeX),
  algorithms/pseudocode, colored boxes (tcolorbox), SI units (siunitx),
  Pandoc format conversion (Markdown/DOCX/HTML ↔ LaTeX),
  and PDF-to-LaTeX conversion of handwritten or printed documents (math, business,
  legal, general). Compile script supports pdflatex, xelatex, lualatex with
  auto-detection. Empirically optimized scaling: single agent 1-10 pages, split
  11-20, batch-7 pipeline 21+. Use when user asks to: (1) create a resume/CV/cover
  letter, (2) write a LaTeX document, (3) create PDF with tables/charts/images,
  (4) compile a .tex file, (5) make a report/invoice/presentation, (6) anything
  involving LaTeX or pdflatex, (7) convert/OCR a PDF to LaTeX, (8) convert
  handwritten notes, (9) create charts/graphs/diagrams, (10) create slides,
  (11) write a thesis or dissertation, (12) create an academic CV, (13) create
  a poster, (14) create an exam/quiz, (15) create a book, (16) convert between
  document formats (Markdown, DOCX, HTML to/from LaTeX), (17) generate Mermaid
  diagrams for LaTeX, (18) create a formal business letter, (19) create a cheat
  sheet or reference card, (20) create an exam formula sheet or crib sheet,
  (21) condense lecture notes/PDFs into a cheat sheet,
  (22) create a fillable PDF form with text fields/checkboxes/dropdowns,
  (23) create a document with conditional content/toggles (show/hide sections),
  (24) generate batch/mail-merge documents from CSV/JSON data,
  (25) create a version diff PDF (latexdiff) highlighting changes between documents,
  (26) create a homework or assignment submission with problems and solutions,
  (27) create a lab report with data tables, graphs, and error analysis,
  (28) encrypt or password-protect a PDF,
  (29) merge multiple PDFs into one,
  (30) optimize/compress a PDF for web or email,
  (31) lint or check a LaTeX document for common issues,
  (32) count words in a LaTeX document,
  (33) analyze document statistics (figures, tables, citations),
  (34) fetch BibTeX from a DOI,
  (35) convert a Graphviz .dot file to PDF/PNG,
  (36) convert a PlantUML .puml file to PDF/PNG.
---

# LaTeX Document Skill

Create any LaTeX document, compile to PDF, and generate PNG previews. Convert PDFs of any type to LaTeX.

## Workflow: Create Documents

1. Determine document type (resume, report, letter, invoice, article, thesis, academic CV, presentation, poster, exam, book, cheat sheet)
2. **If poster:** Run the poster sub-workflow (see [Poster Sub-Workflow](#poster-sub-workflow) below), then skip to step 5.
3. **If cheat sheet / reference card:** Run the cheat sheet sub-workflow (see [Cheat Sheet / Reference Card Sub-Workflow](#cheat-sheet--reference-card-sub-workflow) below), then skip to step 5.
4. **Ask the user which enrichment elements they want** (use AskUserQuestion tool with multiSelect). Offer relevant options based on document type:
   - **AI-generated images** -- custom illustrations, diagrams, photos (uses generate-image skill)
   - **Charts/graphs** -- bar, line, pie, scatter, heatmap (pgfplots or matplotlib)
   - **Flowcharts/diagrams** -- process flows, architecture, decision trees (TikZ or Mermaid)
   - **Citations/bibliography** -- academic references, footnotes, works cited (BibTeX/biblatex)
   - **Tables with data** -- comparison matrices, financial data, statistics (booktabs)
   - **Watermarks** -- DRAFT, CONFIDENTIAL, or company logo background
   - Skip this step for simple documents (cover letters, invoices) or when the user has already specified exactly what they want.
5. Copy the appropriate template from `assets/templates/` or write from scratch
6. Customize content based on user requirements
7. Generate external assets based on user's element choices:
   - AI images: `python3 <skill_path>/../generate-image/scripts/generate_image.py "prompt" --output ./outputs/figure.png`
   - matplotlib charts: `python3 <skill_path>/scripts/generate_chart.py <type> --data '<json>' --output chart.png`
   - Mermaid diagrams: `bash <skill_path>/scripts/mermaid_to_image.sh diagram.mmd output.png`
8. **For documents 5+ pages:** Review the [Long-Form Document Anti-Patterns](#long-form-document-anti-patterns-must-read-for-reports-theses-books) section and run the Content Generation Checklist before compiling. Key rules: prefer prose over bullets, include global list compaction, escape `<`/`>` in text mode, vary section formats, limit `\newpage`, size images at 0.75-0.85 textwidth.
9. Compile with `scripts/compile_latex.sh` (auto-detects XeLaTeX for CJK/RTL, glossaries, bibliography)
10. Show PNG preview to user, deliver PDF

### Poster Sub-Workflow

When the user requests a poster (step 1), follow these steps before proceeding to template customization:

**Step A: Ask for conference/orientation** (use AskUserQuestion with these options):
- "Which conference or orientation is this poster for?"
  - **Portrait A0 (Recommended)** -- Default for most conferences (Interspeech, SIGMOD, APS, AACR, AGU, biomedical, physics, most European)
  - **Landscape A0** -- For CS/ML conferences (AAAI, some engineering)
  - **NeurIPS / ICML / CVPR / ICLR** -- Landscape with custom dimensions (auto-configured)
  - **Other** -- Let user specify dimensions

Based on the answer, select the template and configure paper size:

| Answer | Template | Paper Size | Notes |
|---|---|---|---|
| Portrait A0 (default) | `poster.tex` | A0 841mm x 1189mm | No changes needed |
| Landscape A0 | `poster-landscape.tex` | A0 1189mm x 841mm | No changes needed |
| NeurIPS main | `poster-landscape.tex` | Uncomment `\geometry{paperwidth=2438mm, paperheight=1219mm}` | 96" x 48" |
| NeurIPS workshop | `poster.tex` | Add `\geometry{paperwidth=610mm, paperheight=914mm}` | 24" x 36" |
| ICML main | `poster-landscape.tex` | Uncomment `\geometry{paperwidth=1219mm, paperheight=914mm}` | 48" x 36" |
| ICML workshop | `poster.tex` | Add `\geometry{paperwidth=610mm, paperheight=914mm}` | 24" x 36" |
| CVPR | `poster-landscape.tex` | Uncomment `\geometry{paperwidth=2133mm, paperheight=1067mm}` | 84" x 42" |
| ICLR main | `poster-landscape.tex` | Add `\geometry{paperwidth=1940mm, paperheight=950mm}` | 194cm x 95cm |
| ICLR workshop | `poster.tex` | Add `\geometry{paperwidth=610mm, paperheight=914mm}` | 24" x 36" |

**Step B: Ask for layout archetype** (use AskUserQuestion):
- "Which layout style do you prefer?"
  - **Traditional Column (Recommended)** -- Standard academic poster: 2 columns (portrait) or 3 columns (landscape). Used by ~70% of posters. Best for most conferences.
  - **#BetterPoster** -- Central billboard with ONE key finding in large text, sidebars for details. Maximizes "drive-by" readability. Growing trend (~10% of posters).
  - **Visual-Heavy** -- Large central figure dominating 40-50% of area. Best for data visualization, imaging, astronomy.

If #BetterPoster is selected: use the commented #BetterPoster layout in `poster.tex` (uncomment it, comment out the default 2-column layout).

**Step C: Ask for color scheme** (use AskUserQuestion):
- "Which color scheme?"
  - **Navy + Amber (Recommended)** -- Professional, high contrast, works for any field
  - **Tech Purple** -- Modern CS/ML/AI conferences (purple + pink accent)
  - **Forest Green** -- Biology, environmental sciences
  - **Medical Teal** -- Healthcare, clinical research
  - **Minimal Dark** -- High contrast, modern minimalist

Then proceed to step 5 (customize content) with the selected template, layout, and color scheme. See [poster-design-guide.md](references/poster-design-guide.md) for typography standards, content guidelines, and common mistakes.

### Cheat Sheet / Reference Card Sub-Workflow

When the user requests a cheat sheet or reference card (step 1), follow these steps before proceeding to template customization:

**Step A: Ask for cheat sheet type** (use AskUserQuestion):
- "What type of cheat sheet do you need?"
  - **General Reference Card (Recommended)** -- Multi-topic, landscape 3-column, colored sections. For command references, concept summaries, quick-reference guides.
  - **Exam Formula Sheet** -- Maximum density, portrait 2-column, B&W-safe. For university exam "allowed cheat sheets" with formulas, theorems, definitions.
  - **Programming Reference Card** -- Landscape 4-column, syntax highlighting. For language syntax, API reference, CLI commands, keyboard shortcuts.

Based on the answer, select the template and configure layout:

| Answer | Template | Layout |
|---|---|---|
| General Reference Card | `cheatsheet.tex` | Landscape, 3 columns, 7pt, colored boxes |
| Exam Formula Sheet | `cheatsheet-exam.tex` | Portrait, 2 columns, 6pt, B&W grayscale |
| Programming Reference Card | `cheatsheet-code.tex` | Landscape, 4 columns, 7pt, syntax highlighting |

**Step B: Ask about source material** (use AskUserQuestion):
- "Do you have source PDFs to condense into the cheat sheet?"
  - **Yes, I'll upload PDFs** -- I'll extract and condense key content from your lecture notes, textbooks, or past papers
  - **No, I'll describe what I need** -- I'll create content based on your topic description
  - **Both** -- I'll use your PDFs as primary source and fill gaps based on your description

**Step C: If PDFs provided, ask about content priority** (only if user selected Yes/Both):
- "How should I prioritize content?"
  - **Exam-focused (Recommended)** -- Prioritize formulas, theorems, and definitions likely to appear on exams
  - **Comprehensive coverage** -- Cover all major topics equally
  - **Past paper analysis** -- Cross-reference with past exam papers to identify high-yield topics (requires past papers)

**Step D: Ask for customization** (use AskUserQuestion with multiSelect):
- "Customize your cheat sheet (select all that apply):"
  - **Custom color scheme** -- Choose your own colors instead of the default
  - **Different column count** -- 2, 3, 4, or 5 columns
  - **Different paper size** -- A3 (wall poster), A5 (pocket), or custom
  - **Front-only (1 page)** -- Single page instead of front+back
  - **Keep defaults** -- Use the template defaults

Then proceed to customize the template and fill in content.

**PDF-to-Cheatsheet Pipeline** (when source PDFs provided):

**Phase 1: PDF Ingestion & Structure Analysis**
1. Convert PDF to processable format:
   - For text-based PDFs: Use `python3 -c "import fitz; doc=fitz.open('input.pdf'); [open(f'tmp/page_{i}.txt','w').write(page.get_text()) for i,page in enumerate(doc)]"` for fast text extraction
   - For scanned/handwritten PDFs: `bash <skill_path>/scripts/pdf_to_images.sh input.pdf ./tmp/pages` then use LLM vision
   - Auto-detect: if extracted text is <50 chars/page, treat as scanned and fall back to vision
2. Build document structure map (Pass 1 - send first 10-20 pages to LLM):
   ```
   Analyze this document and create a structured outline:
   - Chapter/section titles with page numbers
   - Content type per section (theoretical, applied, examples, exercises)
   - Importance rating (high/medium/low) based on: theorem density, boxed content, "Important" markers
   Output as structured list.
   ```
3. For 100+ page documents, use hierarchical chunking:
   - Chunk at section/subsection boundaries (not arbitrary page counts)
   - Keep chunks to 3000-6000 tokens each (leaves room for prompt + output)
   - Maintain chapter/section metadata with each chunk
   - Process high-importance sections first (from structure map)

**Phase 2: Targeted Content Extraction (Pass 2)**
4. Extract key content from each high-importance section using subject-specific prompts:
   - **Mathematics**: "Extract ALL formulas, theorems (with conditions), definitions, and proof techniques. Preserve LaTeX notation exactly."
   - **Computer Science**: "Extract algorithms with complexity, data structure operations, key theorems. Format algorithms as step-lists."
   - **Physics**: "Extract equations with units, laws with applicability conditions, constants. Note coordinate system dependencies."
   - **Chemistry**: "Extract reactions, mechanisms, equilibrium expressions, nomenclature rules, periodic trends."
   - **Biology**: "Extract processes/cycles as stage-lists, pathways, classification hierarchies, comparative tables."
   - **General**: "Extract formulas > theorems > definitions > procedures > reference tables. Skip motivational text and history."
5. For each extracted item, capture:
   - Type: FORMULA | THEOREM | DEFINITION | PROCEDURE | TABLE
   - Content (preserving all math notation)
   - Context (when to use it)
   - Prerequisites (what must be known first)

**Phase 3: Content Prioritization & Compression (Pass 3)**
6. Score and rank all extracted items:
   - Priority 1 (60-70% of lookups): Formulas with variable meanings
   - Priority 2 (15-20%): Procedure steps and algorithms
   - Priority 3 (10-15%): Constants, units, conversion factors
   - Priority 4 (5-10%): Technical definitions
   - Boost score for: items appearing in multiple sections, boxed/highlighted content, named theorems
7. Compress content using density techniques:
   - Convert verbose definitions to terse one-liners
   - Use symbols: → instead of "implies", ∀ instead of "for all", ⇔ instead of "if and only if"
   - Telegram-style writing: "The gradient is defined as..." → "Gradient:"
   - Merge overlapping content from different chapters
   - Use \tfrac instead of \frac, \textstyle in align environments
   - Stack short equations horizontally: `$E=mc^2$ \hfill $F=ma$`
8. If past papers provided: cross-reference to weight high-frequency topics (boost items that appear in 2+ exams)

**Phase 4: Layout & Assembly**
9. Space budget management:
   - Estimate: ~45-50 lines per page at 6pt, ~40-45 at 7pt (landscape with 3 columns = 3× that)
   - 2-page cheat sheet ≈ 60-80 distinct items (formulas, theorems, definitions)
   - If extracted items > budget: cut lowest-priority items, merge related items, reduce font for less-critical sections
10. Organize into logical sections matching template structure
11. Apply LaTeX density optimizations:
    - No blank lines between consecutive tcolorbox environments (causes `//` artifacts)
    - Use `@{}` in tabular to suppress inter-column padding
    - Use \smallmatrix instead of pmatrix for 2×2 matrices (saves 40% height)
    - Use \hfill to stack two formulas per line
    - Negative \vspace between sections if nearly fitting
12. Compile, verify fits within page constraints, iterate if needed
    - If overflow: use \scalebox{0.95}, \enlargethispage{1cm}, or cut lowest-priority items
    - If underflow: add worked examples or expand compressed definitions

### Content Budget Guidelines (from QA Testing)

**CRITICAL: LLMs consistently generate 150-250% too much content for cheatsheets.**
Always use these character budgets (LaTeX source, not rendered text):

| Template | Layout | Budget per page | Total (2 pages) |
|---|---|---|---|
| Exam | Portrait 2-col 6pt | ~4,500 chars | ~9,000 chars |
| General | Landscape 3-col 7pt | ~8,000 chars | ~16,000 chars |
| Code | Landscape 4-col 7pt | ~9,000 chars | ~18,000 chars |

**Mandatory compile-and-verify workflow:**
1. Write page 1 content only (within budget)
2. Compile with `pdflatex -interaction=nonstopmode`
3. Verify page count with `pdfinfo <file>.pdf | grep Pages`
4. If page 1 fits, write page 2 content
5. Recompile and verify exactly 2 pages
6. If >2 pages: cut lowest-priority content, recompile

**Content distribution rules:**
- End `\begin{multicols}` before `\newpage`, start new `\begin{multicols}` after
- Use `\columnbreak` to force balanced column distribution
- For 4-column layouts, add `\sloppy` after `\begin{multicols}{4}` to reduce underfull warnings
- Target ~equal content per column (visually inspect previews)

**Compression ratio guidelines:**
- 5-20 page source → 2 pages: include most key content (2.5-10:1)
- 20-50 page source → 2 pages: definitions + key theorems + formulas only (10-25:1)
- 50-100+ page source → 2 pages: ruthless prioritization needed (25-50:1)
  - Only core definitions, critical formulas, essential algorithms
  - Use telegram-style text, symbol abbreviations, horizontal stacking
  - Test with `pdfinfo` after every 3-4 sections added

## Workflow: Mail Merge (Batch Personalized Documents)

Generate N personalized documents from a LaTeX template + CSV/JSON data source:

```bash
# Basic mail merge from CSV
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv --output-dir ./outputs

# With compilation via compile script
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --compile-script <skill_path>/scripts/compile_latex.sh

# Parallel compilation (4 workers), merge into single PDF
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --workers 4 --merge --merge-name all_letters.pdf \
    --compile-script <skill_path>/scripts/compile_latex.sh

# Custom output naming by data field
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --name-field "last_name" --prefix "letter"

# Generate .tex files only (no compilation)
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv --output-dir ./outputs --no-compile

# Dry run (preview)
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv --dry-run
```

**Template syntax**: Use `{{variable}}` for simple substitution (auto-detected). For conditionals/loops, use Jinja2 syntax: `<< variable >>` for variables, `<% if ... %>` for blocks. See `assets/templates/mail-merge-letter.tex` for a complete example. Full guide: [references/interactive-features.md](references/interactive-features.md).

## Workflow: Version Diffing (latexdiff)

Generate highlighted change-tracked PDFs between two document versions:

```bash
# Basic diff between two files
bash <skill_path>/scripts/latex_diff.sh old.tex new.tex --compile --preview

# Diff against a git revision
bash <skill_path>/scripts/latex_diff.sh paper.tex --git-rev HEAD~1 --compile

# Multi-file document (expands \input/\include)
bash <skill_path>/scripts/latex_diff.sh old/main.tex new/main.tex --flatten --compile

# Custom markup style (underline + change bars)
bash <skill_path>/scripts/latex_diff.sh old.tex new.tex --type CULINECHBAR --compile

# Custom colors
bash <skill_path>/scripts/latex_diff.sh old.tex new.tex \
    --color-add "green!70!black" --color-del "red!80!black" --compile
```

The script auto-installs `latexdiff` if not present. Markup types: UNDERLINE (default), CTRADITIONAL, CFONT, CHANGEBAR, CULINECHBAR. Full guide: [references/interactive-features.md](references/interactive-features.md).

## Workflow: Convert Document Formats

For converting between Markdown, DOCX, HTML, and LaTeX using Pandoc:

```bash
bash <skill_path>/scripts/convert_document.sh input.md output.tex
bash <skill_path>/scripts/convert_document.sh input.docx output.tex --standalone --extract-media=./media
bash <skill_path>/scripts/convert_document.sh input.tex output.docx
```

See [references/format-conversion.md](references/format-conversion.md) for full Pandoc conversion guide.

## Workflow: Convert PDF to LaTeX

For converting existing PDFs (handwritten notes, printed reports, legal docs, any content) to LaTeX:

1. Split PDF into page images: `bash <skill_path>/scripts/pdf_to_images.sh input.pdf ./tmp/pages`
2. Determine document type and select the matching **conversion profile** from `references/profiles/`
3. Create a shared preamble (scan a few pages, use profile as starting point)
4. Apply the correct **scaling strategy** based on page count (see below)
5. Each agent reads its page images and outputs body-only LaTeX
6. Validate batch files: `python3 <skill_path>/scripts/validate_latex.py tmp/batch_*.tex --preamble tmp/preamble.tex`
7. Concatenate all batch files with the preamble
8. Compile with `scripts/compile_latex.sh`

**Full pipeline details**: See [references/pdf-conversion.md](references/pdf-conversion.md).

### Scaling Strategy (Empirically Validated)

| PDF Size | Strategy | Agents | How |
|---|---|---|---|
| **1-10 pages** | Single agent | 1 | One agent converts all pages. May produce 0-2 minor errors (trivially fixable). Batching overhead not justified. |
| **11-20 pages** | Split in half | 2 | Two agents, ~equal page splits. Avoids the error cliff at 10+ pages while keeping merge simple. |
| **21+ pages** | Batch-7 pipeline | ceil(N/7) | Each agent gets 7 pages (optimal per-agent size). Full parallel processing with `run_in_background: true`. |

**Why these thresholds**: Empirical testing showed 0 errors at 7 pages, 2 structural errors at 10, and 11 catastrophic errors at 15. A single agent handles up to 10 with minor fixable issues. Past 10, errors cascade (unclosed environments, mismatched nesting). Past 20, the merge overhead of batch-7 is clearly justified by the error reduction.

### Conversion Profiles

Select based on document content:

| Content Type | Profile | When to Use |
|---|---|---|
| Math / science notes | `references/profiles/math-notes.md` | Equations, theorems, proofs, definitions, Greek symbols. **Has beautiful mode** (default) using `lecture-notes.tex` template with tcolorbox + TikZ diagrams. |
| Business documents | `references/profiles/business-document.md` | Reports, meeting notes, memos, proposals, financial data |
| Legal documents | `references/profiles/legal-document.md` | Contracts, regulations, statutes, numbered paragraphs, citations |
| General / mixed | `references/profiles/general-notes.md` | Handwritten notes, letters, journals, anything not clearly one of the above |

Each profile provides: suggested preamble, structural patterns to recognize, worker agent hints, and common pitfalls for that document type.

### Worker Agent Instructions

Each agent receives:
- The shared preamble (reference only)
- Their assigned page images
- Context: what section they're in, what comes before/after
- The conversion profile hints for the document type

Each agent outputs ONLY body LaTeX -- no `\documentclass`, no `\usepackage`, no `\begin{document}`.

Use `run_in_background: true` for parallel agents. Do NOT use agent teams -- simple background agents are more reliable.

## Compile Script

```bash
# Basic compile (auto-detects engine)
bash <skill_path>/scripts/compile_latex.sh document.tex

# Compile + generate PNG previews
bash <skill_path>/scripts/compile_latex.sh document.tex --preview

# Compile + PNG in specific directory
bash <skill_path>/scripts/compile_latex.sh document.tex --preview --preview-dir ./outputs

# Force a specific engine
bash <skill_path>/scripts/compile_latex.sh document.tex --engine xelatex
bash <skill_path>/scripts/compile_latex.sh document.tex --engine lualatex
```

**Engine auto-detection**: If the .tex file uses `fontspec`, `xeCJK`, or `polyglossia`, the script automatically uses `xelatex`. If it uses `luacode` or `luatextra`, it uses `lualatex`. Otherwise defaults to `pdflatex`. Override with `--engine`.

The script auto-installs `texlive` (including `texlive-science`, `texlive-xetex`, `texlive-luatex`, `biber`) and `poppler-utils` if missing. It auto-detects `\bibliography{}` (runs bibtex), `\addbibresource{}` (runs biber), `\makeindex` (runs makeindex), `\makeglossaries` (runs makeglossaries), runs the correct number of passes, generates PNG previews with `pdftoppm`, and cleans auxiliary files.

## PDF-to-Images Script

```bash
# Split PDF and resize for API compatibility
bash <skill_path>/scripts/pdf_to_images.sh input.pdf ./tmp/pages

# Custom DPI and max dimension
bash <skill_path>/scripts/pdf_to_images.sh input.pdf ./tmp/pages --dpi 200 --max-dim 2000
```

Auto-installs `poppler-utils` and `imagemagick`, renders pages as PNG, resizes to fit within API image dimension limits (2000px max).

## Compile Script: Auto-Fix Mode

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

## PDF Utility Scripts

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

## LaTeX Quality Scripts

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

## Bibliography Script

```bash
# Auto-download BibTeX from a DOI
bash <skill_path>/scripts/fetch_bibtex.sh 10.1145/359576.359579

# Append to an existing .bib file
bash <skill_path>/scripts/fetch_bibtex.sh 10.1145/359576.359579 >> references.bib
```

## Diagram Scripts

```bash
# Convert Graphviz .dot to PDF
bash <skill_path>/scripts/graphviz_to_pdf.sh diagram.dot output.pdf

# Convert PlantUML .puml to PDF
bash <skill_path>/scripts/plantuml_to_pdf.sh diagram.puml output.pdf
```

## Templates

Copy from `assets/templates/` and customize.

### Resume Templates (5 ATS-Compatible Options)

Select based on experience level, industry, and ATS requirements. See [references/resume-ats-guide.md](references/resume-ats-guide.md) for full ATS guidance.

| Template | Best For | Key Feature | ATS Score |
|---|---|---|---|
| **`resume-classic-ats.tex`** | Finance, law, government, any ATS portal | Zero graphics, plain text only, maximum parse safety | 10/10 |
| **`resume-modern-professional.tex`** | Tech, corporate, general professional | Subtle color accents, clean design, good ATS + human appeal | 9/10 |
| **`resume-executive.tex`** | VP, Director, C-suite (5-15+ years) | Two-page, executive summary, board roles, P&L focus | 9/10 |
| **`resume-technical.tex`** | Software, data, engineering roles | Skills-first hybrid, projects section, tech stack emphasis | 9/10 |
| **`resume-entry-level.tex`** | New graduates, career starters | Education-first, one page, coursework, activities | 9/10 |

All 5 templates follow ATS rules: single-column, no graphics/images, no tables for layout, standard section headings, contact info in body (not header/footer).

### STEM Student Templates

- **`homework.tex`** -- Homework/assignment submission template (`article` class, 11pt) with toggle-able solutions (`\showsolutionstrue`/`\showsolutionsfalse`), custom problem/solution environments, honor code section, `fancyhdr` headers, `amsmath`+`amssymb`+`amsthm` math, `listings` code highlighting (Python, Java, C++, Matlab styles), `enumitem` for (a), (b), (c) sub-parts, `hyperref`. Customization via `\coursename`, `\assignmentnumber`, `\studentname`, `\studentid`, `\duedate`. Example problems: calculus, proof by induction, Python coding, matrix algebra, kinematics, Java OOP.
- **`lab-report.tex`** -- STEM lab report template (`article` class, 11pt) with `siunitx` for uncertainties and SI units, `pgfplots` for data visualization, `booktabs` for professional tables, `amsmath` for equations, `fancyhdr` headers, `caption`+`subcaption` for figures. Structured sections: abstract, theory, procedure, data/results (with uncertainty tables), analysis (pgfplots graphs), discussion (error analysis), conclusion, references, appendix. Example: pendulum period measurement with error propagation.

### Other Templates

- **`lecture-notes.tex`** -- Beautiful lecture notes (`scrartcl` KOMA-Script class) with Palatino font, `microtype` typography, color-coded `tcolorbox` theorem environments (blue theorems, green definitions, orange examples, purple remarks), TikZ graph theory diagram styles and macros (`\CompleteGraph`, `\CycleGraph`, `\PathGraph`), styled section headings with `titlesec`, `fancyhdr` headers, `hyperref` + `cleveref` navigation. Ideal for converting handwritten math/science notes to beautiful PDFs. Includes graph theory custom commands (`\V`, `\E`, `\deg`, `\chr`). Used by the math-notes conversion profile in beautiful mode.
- **`thesis.tex`** -- Thesis/dissertation (`book` class) with title page, declaration, abstract, acknowledgments, TOC, list of figures/tables, chapters, appendices, bibliography. Front matter uses roman numerals, main matter uses arabic. Includes theorem environments.
- **`academic-cv.tex`** -- Multi-page academic CV with publications (journal/conference/preprint sections), grants and funding, teaching, advising (current/graduated students), awards, professional service, invited talks. ORCID and Google Scholar links.
- **`book.tex`** -- Full book (`book` class) with half-title, title page, copyright page, dedication, preface, acknowledgments, TOC, list of figures/tables, parts, chapters, appendix, bibliography, index. Custom chapter headings, epigraphs, fancyhdr, microtype.
- **`poster.tex`** -- Conference poster (`tikzposter` class, A0 portrait) with 2-column layout, QR code, 5 color schemes, tikzfigure charts, tables, coloredbox highlights. Includes commented **#BetterPoster** layout variant (central billboard + sidebars). Portrait is standard for most conferences. See poster design guide for conference size presets.
- **`poster-landscape.tex`** -- Landscape conference poster (`tikzposter` class, A0 landscape) with 3-column (30/40/30) layout, QR code, tech purple color scheme. For CS/ML conferences (NeurIPS, ICML, CVPR, ICLR). Includes commented `\geometry{}` presets for CVPR/NeurIPS custom sizes.
- **`cheatsheet.tex`** -- General reference card (`extarticle` class, landscape A4, 7pt base font) with 3-column `multicols` layout, `tcolorbox` colored section boxes, tight spacing. For command references, concept summaries, quick-reference guides. Supports front+back printing.
- **`cheatsheet-exam.tex`** -- Exam formula sheet (`extarticle` class, portrait A4, 6pt base font) with 2-column layout, maximum content density, black-and-white printer-safe. For university exam "allowed cheat sheets" with formulas, theorems, definitions. Optimized for single-sided printing.
- **`cheatsheet-code.tex`** -- Programming reference card (`extarticle` class, landscape A4, 7pt base font) with 4-column layout, `minted` syntax highlighting, monospace font emphasis. For language syntax, API reference, CLI commands, keyboard shortcuts.
- **`letter.tex`** -- Formal business letter with colored letterhead bar, TikZ logo placeholder, company info, recipient block, date, subject line, signature. Professional corporate appearance.
- **`exam.tex`** -- Exam/quiz (`exam` class) with grading table, multiple question types (multiple choice, true/false, fill-in-blank, matching, short answer, essay), point values, solution toggle via `\printanswers`.
- **`report.tex`** -- Business report with TOC, headers/footers, data tables, bar chart (pgfplots), process flowchart (TikZ), recommendations
- **`cover-letter.tex`** -- Professional cover letter with sender/recipient blocks
- **`invoice.tex`** -- Invoice with company header, line items table, subtotal/tax/total
- **`academic-paper.tex`** -- Research paper with abstract, sections, bibliography, figures. Includes example `.bib` file (`references.bib`) for BibTeX citations.
- **`presentation.tex`** -- Beamer presentation with title slide, content frames, columns
- **`fillable-form.tex`** -- Fillable PDF form (`article` class) with hyperref form fields: text inputs, checkboxes, radio buttons, dropdowns, push buttons. Two-column layout with `tabularx`. Custom `\FormField`, `\FormCheck`, `\FormDropdown` helper commands. Requires Adobe Reader for full form support (browser PDF viewers have limited form capabilities).
- **`conditional-document.tex`** -- Configurable document (`article` class) with etoolbox toggle system: show/hide TOC, appendix, watermark, draft mode, confidential marking, abstract. Template variables via `\providecommand` (title, author, org, version). Three visual profiles (corporate, academic, minimal). Supports command-line variable passing for CI/CD.
- **`mail-merge-letter.tex`** -- Mail merge letter template with `{{variable}}` placeholders for use with `scripts/mail_merge.py`. Company-branded letterhead, recipient address block, body text with data-driven personalization. Pair with CSV/JSON data source.
- **`resume.tex`** -- Legacy resume template (has photo area and tables -- not ATS-optimized)

Usage:
```bash
cp <skill_path>/assets/templates/resume-classic-ats.tex ./outputs/my_resume.tex
# Edit content, then compile
bash <skill_path>/scripts/compile_latex.sh ./outputs/my_resume.tex --preview --preview-dir ./outputs
```

## Document Type Selection

| User Request | Template | Document Class |
|---|---|---|
| Resume, CV (ATS-safe) | `resume-classic-ats.tex` | `article` |
| Resume (modern look) | `resume-modern-professional.tex` | `article` |
| Resume (senior/executive) | `resume-executive.tex` | `article` |
| Resume (technical/engineering) | `resume-technical.tex` | `article` |
| Resume (new graduate) | `resume-entry-level.tex` | `article` |
| Homework, assignment, problem set | `homework.tex` | `article` |
| Lab report, experiment writeup | `lab-report.tex` | `article` |
| Lecture notes, math notes (beautiful) | `lecture-notes.tex` | `scrartcl` |
| Thesis, dissertation | `thesis.tex` | `book` |
| Academic CV (publications, grants) | `academic-cv.tex` | `article` |
| Report, analysis | `report.tex` | `article` |
| Cover letter | `cover-letter.tex` | `article` |
| Invoice | `invoice.tex` | `article` |
| Academic paper | `academic-paper.tex` + `references.bib` | `article` |
| Book | `book.tex` | `book` |
| Scientific poster (portrait) | `poster.tex` | `tikzposter` |
| Scientific poster (landscape) | `poster-landscape.tex` | `tikzposter` |
| Cheat sheet, reference card | `cheatsheet.tex` | `extarticle` |
| Exam formula sheet, crib sheet | `cheatsheet-exam.tex` | `extarticle` |
| Programming reference card | `cheatsheet-code.tex` | `extarticle` |
| Formal business letter | `letter.tex` | `article` |
| Exam, quiz, test | `exam.tex` | `exam` |
| Slides, presentation | `presentation.tex` | `beamer` |
| Fillable PDF form | `fillable-form.tex` | `article` |
| Conditional/configurable document | `conditional-document.tex` | `article` |
| Mail merge, batch letters | `mail-merge-letter.tex` + `scripts/mail_merge.py` | `article` |
| **Version diff (latexdiff)** | Use `scripts/latex_diff.sh` + see [interactive-features.md](references/interactive-features.md) | varies |
| **Convert PDF to LaTeX** | Select profile + see [pdf-conversion.md](references/pdf-conversion.md) | varies |
| **Convert formats** | Use `scripts/convert_document.sh` + see [format-conversion.md](references/format-conversion.md) | varies |
| **Mail merge from CSV/JSON** | Use `scripts/mail_merge.py` + see [interactive-features.md](references/interactive-features.md) | varies |

## Key LaTeX Patterns

### Escaping Special Characters

Always escape: `%` → `\%`, `$` → `\$`, `&` → `\&`, `#` → `\#`, `_` → `\_`

**Angle brackets in text mode:** `<` and `>` are NOT valid in LaTeX text mode with T1 encoding. They render as inverted question marks (¡ or ¿). Always use math mode or text commands:
- `<5%` → `$<$5\%` or `\textless 5\%`
- `>50` → `$>$50` or `\textgreater 50`
- `<$300` → `$<$\$300`
- `>=` → `$\geq$`, `<=` → `$\leq$`

This is one of the most common silent errors in generated LaTeX — the document compiles without errors but the PDF shows garbage characters.

Date ranges use en-dash: `2019--2025` (double hyphen).

### Standard Preamble

```latex
\documentclass[11pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{geometry}
\usepackage{hyperref}
\usepackage{xcolor}
\usepackage{graphicx}
\usepackage{tabularx}
\usepackage{colortbl}
\usepackage{enumitem}
\usepackage{titlesec}
```

### Quick Table

```latex
\begin{tabularx}{\textwidth}{|l|X|c|}
\hline
\rowcolor{lightgray}
\textbf{Header 1} & \textbf{Header 2} & \textbf{Header 3} \\
\hline
Data & Description text & Value \\
\hline
\end{tabularx}
```

### Quick Chart (pgfplots)

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
% ...
\begin{tikzpicture}
\begin{axis}[ybar, xlabel={Quarter}, ylabel={Revenue (\$K)}]
  \addplot coordinates {(1,120) (2,150) (3,180) (4,210)};
\end{axis}
\end{tikzpicture}
```

### Quick Flowchart (TikZ)

```latex
\usepackage{tikz}
\usetikzlibrary{shapes.geometric, arrows.meta, positioning}
% ...
\begin{tikzpicture}[
    node distance=1.5cm,
    box/.style={draw, rounded corners, fill=blue!10, minimum width=3cm, minimum height=1cm, align=center},
    decision/.style={draw, diamond, fill=yellow!20, aspect=2, align=center},
    arrow/.style={-{Stealth[length=3mm]}, thick}
]
\node[box] (start) {Start};
\node[box, below of=start] (process) {Process};
\node[decision, below of=process] (check) {Valid?};
\node[box, below of=check] (output) {Output};
\node[box, right of=check, node distance=3.5cm] (fix) {Fix};
\draw[arrow] (start) -- (process);
\draw[arrow] (process) -- (check);
\draw[arrow] (check) -- node[left] {Yes} (output);
\draw[arrow] (check) -- node[above] {No} (fix);
\draw[arrow] (fix) |- (process);
\end{tikzpicture}
```

### Quick Bibliography (BibTeX)

```latex
% In preamble:
\usepackage{natbib}

% In text:
\citet{vaswani2017attention}   % Vaswani et al. (2017)
\citep{vaswani2017attention}   % (Vaswani et al., 2017)

% Before \end{document}:
\bibliographystyle{plainnat}   % or: apalike, ieeetr, unsrt, alpha
\bibliography{references}      % references.bib file
```

The compile script auto-detects `\bibliography{}` and runs bibtex. For biblatex, use `\addbibresource{}` instead (auto-detected, runs biber). See `assets/templates/references.bib` for example entries. Full guide: [references/bibliography-guide.md](references/bibliography-guide.md).

### Quick Watermark

```latex
% Text watermark (DRAFT, CONFIDENTIAL)
\usepackage{draftwatermark}
\SetWatermarkText{DRAFT}
\SetWatermarkScale{1.5}
\SetWatermarkColor[gray]{0.85}
```

For logo watermarks (`eso-pic`), header logos (`fancyhdr`), first-page-only watermarks, and combined text+logo, see [references/advanced-features.md](references/advanced-features.md).

### Quick Landscape Page

```latex
\usepackage{pdflscape}  % or: lscape (for print-rotated)

% Normal portrait content...
\begin{landscape}
% Wide table or chart here -- page rotated in PDF viewer
\end{landscape}
% Back to portrait...
```

Use `pdflscape` for on-screen reading (page rotates in PDF viewer). Use `lscape` for print (content rotates on static page).

### Quick Multi-Language

```latex
% European languages (pdflatex):
\usepackage[english,french]{babel}
\selectlanguage{french}
Bonjour le monde.
\selectlanguage{english}

% CJK (requires XeLaTeX, not pdflatex):
\usepackage{fontspec}
\usepackage{xeCJK}
\setCJKmainfont{Noto Serif CJK SC}  % Chinese Simplified

% RTL / Arabic (requires XeLaTeX):
\usepackage{polyglossia}
\setotherlanguage{arabic}
```

For CJK/RTL documents, compile with `xelatex` instead of `pdflatex`. Full guide: [references/advanced-features.md](references/advanced-features.md).

### Quick Image

```latex
% External file
\includegraphics[width=0.5\textwidth]{image.png}

% Placeholder circle (when no image available)
\begin{tikzpicture}
  \draw[fill=gray!20] (0,0) circle (1.2cm);
  \node at (0,0) {\small Photo};
\end{tikzpicture}
```

### Quick Mermaid Diagram

```bash
# Convert Mermaid .mmd file to PNG/PDF for LaTeX inclusion
bash <skill_path>/scripts/mermaid_to_image.sh diagram.mmd output.png
bash <skill_path>/scripts/mermaid_to_image.sh diagram.mmd output.pdf --format pdf --theme forest
```

```latex
% Include in LaTeX
\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{diagram.pdf}
    \caption{System architecture diagram}
\end{figure}
```

See [references/mermaid-diagrams.md](references/mermaid-diagrams.md) for flowcharts, sequence diagrams, class diagrams, ER diagrams, Gantt charts, and more.

### Quick matplotlib Chart

```bash
# Generate publication-quality chart from JSON data
python3 <skill_path>/scripts/generate_chart.py bar \
    --data '{"x":["Q1","Q2","Q3","Q4"],"y":[120,150,180,210]}' \
    --output chart.png --title "Quarterly Revenue" --ylabel "Revenue ($K)"

# Generate from CSV file
python3 <skill_path>/scripts/generate_chart.py line --csv data.csv --output trend.pdf
```

Supports: bar, line, scatter, pie, heatmap, box, histogram, area, radar. See [references/python-charts.md](references/python-charts.md).

### Quick CSV-to-LaTeX Table

```bash
# Convert CSV to LaTeX table code
python3 <skill_path>/scripts/csv_to_latex.py data.csv --caption "Results" --label "tab:results"
python3 <skill_path>/scripts/csv_to_latex.py data.csv --style booktabs --alternating-rows --output table.tex
```

Supports: booktabs, grid, simple, plain styles. Auto-detects column alignment. See script help for options.

### Quick AI-Generated Image

```bash
python3 <skill_path>/../generate-image/scripts/generate_image.py \
    "Professional diagram of neural network, clean white background, technical illustration" \
    --output ./outputs/figure.png
```

Then include with `\includegraphics[width=0.6\textwidth]{figure.png}` in a `figure` environment. Request "white background, clean, no text" for best results. See [references/advanced-features.md](references/advanced-features.md).

### Quick Fillable PDF Form

```latex
\usepackage[colorlinks=true]{hyperref}
% ...
\begin{Form}
    \TextField[name=fullName, width=10cm, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}, charsize=10pt]{Full Name:}\\[8pt]
    \TextField[name=email, width=10cm, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}, charsize=10pt]{Email:}\\[8pt]
    \CheckBox[name=agree, width=12pt, height=12pt]{I agree to terms}\\[8pt]
    \ChoiceMenu[name=dept, combo, width=6cm]{Department:}{Sales, Engineering, Marketing, HR}\\[8pt]
    \TextField[name=comments, width=\textwidth, height=3cm, multiline=true,
               bordercolor=blue, backgroundcolor={0.94 0.96 1.0}]{Comments:}
\end{Form}
```

All form fields MUST be inside `\begin{Form}...\end{Form}`. See `assets/templates/fillable-form.tex` for full example. Full guide: [references/interactive-features.md](references/interactive-features.md).

### Quick Conditional Content (Toggles)

```latex
\usepackage{etoolbox}
\newtoggle{showAppendix}
\newtoggle{isDraft}
\toggletrue{showAppendix}
\togglefalse{isDraft}
% Template variables (overridable from command line)
\providecommand{\doctitle}{My Document}
\providecommand{\docauthor}{Author Name}
% ...
\iftoggle{isDraft}{\usepackage{lineno}\linenumbers}{}
% In body:
\iftoggle{showAppendix}{\appendix \section{Appendix} ...}{}
```

See `assets/templates/conditional-document.tex` for a full document with toggles, profiles, and variables. Full guide: [references/interactive-features.md](references/interactive-features.md).

### Quick Mail Merge

```bash
# Generate personalized letters from CSV data
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv --output-dir ./outputs \
    --compile-script <skill_path>/scripts/compile_latex.sh
```

Template uses `{{variable}}` placeholders. See `assets/templates/mail-merge-letter.tex`. Full guide: [references/interactive-features.md](references/interactive-features.md).

### Quick Version Diff

```bash
# Diff two files and compile to PDF
bash <skill_path>/scripts/latex_diff.sh old.tex new.tex --compile --preview

# Diff against git revision
bash <skill_path>/scripts/latex_diff.sh paper.tex --git-rev HEAD~1 --compile
```

Auto-installs `latexdiff`. Full guide: [references/interactive-features.md](references/interactive-features.md).

## Visual Elements in Reports

When creating reports, use the enrichment elements the user selected in step 2. If the user selected "AI-generated images", generate relevant illustrations for key sections. Available visual elements:

| Element | Tool | Best For |
|---|---|---|
| Bar/line/pie charts | pgfplots (inline) or matplotlib (script) | Metrics, trends, breakdowns |
| Flowcharts | TikZ (inline) or Mermaid (script) | Processes, architecture, decisions |
| AI-generated images | generate-image skill | Custom illustrations, diagrams, photos |
| Data tables | booktabs/tabularx | Comparisons, financials, statistics |
| Timelines | TikZ | Project phases, milestones, roadmaps |

The `report.tex` template includes pgfplots, TikZ, and all required packages out of the box. Use `\begin{figure}[H]` (from `float` package) to prevent figures from floating away from their context.

**Sizing TikZ diagrams**: Always use `width=0.8\textwidth` or smaller in axis options. For TikZ flowcharts, keep `node distance` and `minimum width` small enough that the diagram fits within margins. Test-compile and check PNG preview to catch clipping.

## Reference Guides (load as needed)

| Topic | File | When to Read |
|---|---|---|
| Bibliography/Citations | [bibliography-guide.md](references/bibliography-guide.md) | BibTeX/biblatex, citation styles, .bib format |
| Watermarks, Landscape, Multi-Lang, Code, Algorithms, tcolorbox, siunitx, Advanced Charts, AI Images | [advanced-features.md](references/advanced-features.md) | Any feature not covered by quick patterns above |
| Mermaid Diagrams | [mermaid-diagrams.md](references/mermaid-diagrams.md) | Flowcharts, sequence, class, ER, Gantt, pie, mindmap |
| Python Charts (matplotlib) | [python-charts.md](references/python-charts.md) | Bar, line, scatter, pie, heatmap, box, histogram, area, radar |
| Format Conversion (Pandoc) | [format-conversion.md](references/format-conversion.md) | Markdown/DOCX/HTML to/from LaTeX |
| Tables and Images | [tables-and-images.md](references/tables-and-images.md) | Colored rows, multi-row/column, booktabs, long tables, images, TikZ |
| Charts and Graphs (pgfplots) | [charts-and-graphs.md](references/charts-and-graphs.md) | Line plots, bar charts, scatter plots, pie charts in pgfplots |
| LaTeX Packages | [packages.md](references/packages.md) | Common packages reference |
| Poster Design Guide | [poster-design-guide.md](references/poster-design-guide.md) | Conference size presets, typography, color schemes, layout archetypes, content guidelines |
| Resume ATS Guide | [resume-ats-guide.md](references/resume-ats-guide.md) | ATS rules, LaTeX pitfalls, keywords |
| PDF-to-LaTeX Pipeline | [pdf-conversion.md](references/pdf-conversion.md) | Full conversion pipeline with profiles |
| Interactive Features (Forms, Conditionals, Mail Merge, Diffing) | [interactive-features.md](references/interactive-features.md) | Fillable PDF forms, conditional content toggles, mail merge from CSV/JSON, latexdiff version tracking |
| Cheat Sheet / Reference Card Design | [cheatsheet-guide.md](references/cheatsheet-guide.md) | Template selection, typography, color schemes, layout techniques, density optimization, PDF-to-cheatsheet pipeline, print considerations |
| PDF-to-Cheatsheet Prompt Templates | [pdf-extraction-prompts.md](references/pdf-extraction-prompts.md) | Ready-to-use LLM prompts for each extraction stage: structure analysis, subject-specific extraction (math/CS/physics/chem/bio/stats/engineering), compression, LaTeX formatting, quality verification |
| Visual Packages (TikZ/Diagrams) | [visual-packages.md](references/visual-packages.md) | 24 installed TikZ/visualization packages (tikz-cd, forest, circuitikz, chemfig, mhchem, pgf-pie, tikz-feynman, etc.) with minimal working examples |
| Graphviz & PlantUML Workflows | [graphviz-plantuml.md](references/graphviz-plantuml.md) | External diagram tool workflows: .dot to PDF/PNG, .puml to PDF/PNG, integration with LaTeX documents, examples, best practices |

## Critical Notes and Common Mistakes

### Compile & Output
- Run compile script from the directory containing the .tex file, or use absolute paths
- Place output .tex files in `./outputs/` for user visibility
- After compilation, read the PNG preview files to show the user how the document looks
- PNG previews require `poppler-utils` (auto-installed by script)

### Package Dependency Errors (MUST READ)
These cause `Undefined control sequence` -- always include the required package:

| If you use... | You MUST include | Error without it |
|---|---|---|
| `\rowcolor{}` | `\usepackage{colortbl}` | Undefined control sequence `\rowcolor` |
| `\url{}` in .bib with natbib | `\usepackage{url}` | Undefined control sequence `\url` |
| `\checkmark` | `\usepackage{amssymb}` | Undefined control sequence `\checkmark` |
| `\begin{figure}[H]` | `\usepackage{float}` | Unknown float option `H` |
| `\rowcolors{}{}{}` | `\usepackage[table]{xcolor}` or `\usepackage{colortbl}` | Undefined control sequence |

### Exam Class Pitfalls
- Do NOT use `\usepackage{fancyhdr}` with exam class -- it conflicts with exam's own `headandfoot` pagestyle, causing `\f@nch@orf` errors. The exam class provides `\firstpageheader`, `\runningheader`, `\footer` instead.
- Do NOT use bare `\section*{}` inside `\begin{questions}` -- it causes "Something's wrong--perhaps a missing \item" errors. Use `\fullwidth{\section*{Part A: ...}}` instead.
- Use `\fullwidth{...}` for ANY non-question content inside the `questions` environment (headings, instructions, notes).

### Book/Thesis Pitfalls
- When using `fancyhdr` with custom headers, set `headheight=14pt` (or larger) in geometry options: `\usepackage[margin=1in, headheight=14pt]{geometry}`. Without this, you get "headheight is too small" warnings that can cause layout issues.
- First-pass compilation of books/theses will always show "undefined references" and "Label(s) may have changed" warnings -- this is normal. The compile script runs multiple passes to resolve these.

### Poster (tikzposter) Pitfalls
- **Orientation depends on conference.** Portrait (2-column, A0 841mm x 1189mm) is most common (~60% of conferences). Landscape is used by CS/ML conferences (NeurIPS, ICML, CVPR, ICLR). Always check conference guidelines. Default to **portrait** if unknown. See [poster-design-guide.md](references/poster-design-guide.md) for conference size presets.
- **Template selection:** Use `poster.tex` for portrait, `poster-landscape.tex` for landscape. For #BetterPoster layout, uncomment the alternative layout section at the end of `poster.tex`. For non-A0 sizes (e.g., CVPR 84"x42"), uncomment the `\geometry{}` line in the landscape template.
- Portrait uses **2 equal columns** (50/50); landscape uses **3 columns** (30/40/30, center wider for main results).
- Do NOT use `\begin{figure}` inside tikzposter -- use `\begin{tikzfigure}[Caption]` instead.
- Always use **relative widths** for charts: `width=0.9\linewidth` (not `width=20cm`). Fixed dimensions overflow blocks on A0.
- Set `bodyinnersep=15mm` (not 8mm) and `margin=15mm` -- 8mm padding causes content-edge collisions on A0.
- Keep total text under 800 words (target 400-500). Use `\coloredbox` for key insights.
- **QR codes:** Add with `\usepackage{qrcode}` and `\qrcode[height=3.5cm]{URL}`. Link to paper, code, or demo.
- **Color schemes:** Both templates include 5 schemes (Navy+Amber, Forest Green, Medical Teal, Tech Purple, Minimal Dark). Uncomment the desired scheme.

### Cheat Sheet / Reference Card Pitfalls

**Critical Layout Issues:**
- **No blank lines between consecutive tcolorbox environments inside `multicols`** — blank lines create `\par` tokens that render as visible `//` artifacts at small font sizes. Always place `\end{thmbox}` immediately followed by `\begin{formulabox}` with NO blank line between them.
- **Never name a `\newtcolorbox` using existing LaTeX commands** — e.g., `\newtcolorbox{fbox}` conflicts with LaTeX's built-in `\fbox`. Use distinctive names like `formulabox`, `thmbox`, `defbox`.
- **No trailing commas in tcolorbox option lists** — `after skip=0.5mm,` before `}` causes errors. The last option before `}` must NOT have a trailing comma.
- **Don't use `parbox=false` in tcolorbox definitions** — causes compilation errors in some tcolorbox versions.

**Space & Typography Issues:**
- **Don't use `\linespread{<0.85}`** — descenders (g, y, p, q) will visually touch ascenders (h, t, l, d) on the next line, making text illegible.
- **Don't use `margin=<3mm` for printed documents** — most laser printers have 3-5mm non-printable margins and will clip content.
- **Always call `\selectfont` after `\fontsize{X}{Y}`** — without it, the font size change doesn't take effect.
- **Don't use `\displaystyle` in cheat sheets** — use `\textstyle` or `\tfrac` instead; displaystyle wastes 20-40% vertical space per equation.

**Content & Density Issues:**
- **Don't try to fit everything** — a 200-page textbook cannot fit on 2 pages. Target a 100:1 compression ratio. Prioritize formulas > theorems > definitions > procedures.
- **Use the 5-second lookup test** — every formula should be findable within 5 seconds of scanning. If sections are too dense to scan, add visual hierarchy (headers, boxes, bold labels).
- **Don't skip variable definitions** — "What does σ represent?" is the #1 exam lookup (60-70% of all lookups). Always include variable legends with formulas.
- **Don't use proofs on cheat sheets** — unless the exam specifically tests proof reproduction. Proofs consume massive space for low exam utility.
- **Always verify page count after compilation** — use `pdfinfo file.pdf | grep Pages` to confirm exactly 2 pages; LLMs consistently over-generate content by 50-150%

**PDF Extraction Issues:**
- **Auto-detect scanned vs text PDFs** — if extracted text averages <50 characters per page, the PDF is likely scanned. Fall back to LLM vision processing.
- **Chunk at section boundaries, not arbitrary page counts** — splitting mid-theorem or mid-proof loses critical context.
- **Deduplicate across chapters** — the same formula often appears in multiple chapters (e.g., chain rule in both differentiation and integration chapters).
- **Verify extracted math** — OCR and text extraction frequently corrupt mathematical notation. Always verify LaTeX renders correctly before finalizing.

### Fillable PDF Forms Pitfalls
- All form fields (`\TextField`, `\CheckBox`, `\ChoiceMenu`, `\PushButton`) MUST be inside `\begin{Form}...\end{Form}`. Fields outside this environment will not work.
- Form field `backgroundcolor` uses space-separated RGB 0-1 values: `backgroundcolor={0.94 0.96 1.0}`, NOT xcolor syntax like `backgroundcolor=blue!10`.
- Each field `name=` must be unique in the document. Duplicate names cause fields to sync values.
- Form fields do NOT work inside `tikzposter` class -- use `article` or `report` class.
- **PDF viewer support varies**: Text fields and checkboxes work in most viewers. Radio buttons, dropdowns, and JavaScript require Adobe Reader. Always test in the target viewer.
- Tab order follows the order fields appear in the LaTeX source.

### hyperref Package
- `hyperref` is fine for normal documents (most templates use it).
- Only avoid it in **PDF-to-LaTeX converted documents** with theorem environments, where it causes `\set@color` errors.

### PDF-to-LaTeX Conversion
- Do NOT use `sed` to clean control characters from LaTeX -- it breaks `\begin`, `\end`, `\newpage`, etc.
- Do NOT use `hyperref` package in converted documents -- causes `\set@color` errors with theorem environments
- Use `run_in_background` agents, NOT agent teams -- simpler, more reliable
- Select the correct conversion profile for the document type -- a math profile on a business doc produces unnecessary theorem environments

### Compilation Environment
- If texlive is not installed, the compile script auto-installs it. Do NOT run multiple compile commands in parallel before texlive is installed -- they will all try to install simultaneously, causing dpkg lock contention. Install once first or run compiles sequentially.
- The compile script uses `-interaction=nonstopmode` (not `-halt-on-error`) to ensure PDFs are produced even with warnings. This is intentional -- many documents produce warnings on first pass that resolve on subsequent passes.

## Long-Form Document Anti-Patterns (MUST READ for Reports, Theses, Books)

These rules apply to any document longer than 5 pages (reports, analyses, theses, books, strategic documents). They address systematic problems that silently degrade document quality. Violations produce documents that compile fine but look unprofessional.

### Anti-Pattern 1: "Wall of Bullets" — Over-reliance on itemize/enumerate

**The Problem:** When generating content about any complex topic, the default behavior is to put every group of related points into `\begin{itemize}`. A 40-page report can easily end up with 50-80 itemize blocks, making it look like a PowerPoint outline rather than a professional document.

**The Rule:** In reports and articles, **prose paragraphs are the default**. Bullet lists are the exception. Use this decision framework:

| Content Type | Format | Example |
|---|---|---|
| Analysis, explanation, argument | **Prose paragraph** | Market trends, strategic rationale, findings |
| Genuinely parallel items (specs, features) | **Table** (`tabularx` + `booktabs`) | Feature comparison, pricing tiers, specs |
| 3-5 labeled concepts | **Bold-label paragraphs** | `\textbf{Concept:} Explanation...` |
| Personas, callouts, key findings | **tcolorbox cards** | Customer profiles, executive summaries |
| Sequential steps (process, timeline) | **Numbered prose or table** | GTM phases, implementation roadmap |
| Raw data points, reference lists | **Bullet list (only here)** | Bibliography, tool lists, prerequisites |

**How to convert bullets to prose:** Take each bullet point and weave it into a flowing sentence. Connect points with transitions (furthermore, additionally, in contrast, this means that). Group related bullets into a single paragraph with a topic sentence.

**Bad (wall of bullets):**
```latex
\textbf{Market Trends:}
\begin{itemize}
  \item Multi-model adoption is increasing
  \item Open-source models growing at 46\%
  \item Startups adopt 3-5x faster than enterprises
  \item Web development is the largest use case
\end{itemize}
```

**Good (prose with structure):**
```latex
\textbf{Market Trends:} Multi-model adoption is accelerating, with nearly all
enterprises now testing multiple AI providers rather than standardizing on one.
Open-source models are gaining traction---46\% of organizations prefer them for
cost and control. Startups adopt agentic tools 3--5x faster than enterprises,
and web development represents the largest use case for AI coding tools.
```

**Good (bold-label paragraphs for distinct concepts):**
```latex
\textbf{Multi-Model Adoption:} Nearly all enterprises now test multiple AI
models rather than standardizing on one, favoring flexibility per task.

\textbf{Open-Source Surge:} 46\% of organizations prefer open-source models
for cost and control, creating demand for platforms supporting both commercial
and open-source models.
```

**Good (tcolorbox card for personas/profiles):**
```latex
\usepackage[most]{tcolorbox}
% ...
\begin{tcolorbox}[colback=blue!5, colframe=blue!70, title={\textbf{Target Persona: Solo Developer}}, fonttitle=\bfseries]
\textbf{Profile:} CS degree or bootcamp grad, 28--35, entrepreneurial mindset.
Active on Hacker News and indie communities.

\textbf{Pain Points:} Spends 80\% of time on boilerplate. Tool fatigue from
10+ subscriptions. Deployment complexity slows iteration.

\textbf{Value Prop:} \textit{``Ship your side project in a weekend, not a month.''}
\end{tcolorbox}
```

**Target:** A well-formatted 40-page report should have fewer than 15 itemize/enumerate blocks total. If you count more than 20, refactor.

### Anti-Pattern 2: Excessive \newpage Commands

**The Problem:** Inserting `\newpage` before every `\section` creates pages that are 30-50% empty. This mimics slide-deck formatting and wastes space.

**The Rule:** Let LaTeX handle page breaks naturally. Only use `\newpage` in these cases:
- Before `\tableofcontents` and after it (standard)
- Before the first `\section` (after front matter)
- Between truly independent major parts (e.g., between a 20-page analysis and a 10-page appendix)
- When a figure/table would look awkward split across pages

**Never** use `\newpage` before every `\section` or `\subsection`. LaTeX's page-breaking algorithm is sophisticated — let it work.

### Anti-Pattern 3: Oversized Images and Rigid Float Placement

**The Problem:** Images at `width=0.95\textwidth` consume almost the full page width, pushing surrounding text to the next page and creating whitespace. Combined with `[H]` float placement, this forces half-empty pages.

**The Rules:**
- Default image width: `0.75\textwidth` to `0.85\textwidth` (not 0.95)
- Use `[htbp]` for most figures (allows LaTeX to optimize placement)
- Only use `[H]` when the figure MUST appear at that exact spot (e.g., immediately after "as shown below:")
- For AI-generated images (often 1-2MB), `0.75\textwidth` is usually sufficient
- For charts and graphs, `0.80-0.85\textwidth` works well
- For full-page figures, use `0.90\textwidth` maximum

```latex
% Good: flexible placement, reasonable size
\begin{figure}[htbp]
\centering
\includegraphics[width=0.80\textwidth]{chart.png}
\caption{Revenue growth by quarter}
\end{figure}

% Only when exact placement is critical
\begin{figure}[H]
\centering
\includegraphics[width=0.75\textwidth]{diagram.png}
\caption{Architecture diagram referenced in text above}
\end{figure}
```

### Anti-Pattern 4: No Global List Compaction

**The Problem:** LaTeX's default list spacing (itemsep, topsep, parsep, partopsep) is generous. A 4-item bullet list can consume as much vertical space as a full paragraph. In a document with many lists, this creates enormous wasted space.

**The Rule:** Always add global list compaction to the preamble for reports and articles:

```latex
\usepackage{enumitem}
\setlist[itemize]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
\setlist[enumerate]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
```

This reduces list spacing to match body text density without eliminating indentation or readability.

### Anti-Pattern 5: Monotonous Section Structure

**The Problem:** Every subsection follows the identical pattern: intro sentence → bullet list → bold conclusion. Over 40+ pages, this repetition makes the document feel generated rather than authored.

**The Rule:** Vary presentation across sections. Use at least 3-4 different content formats throughout a long document:

1. **Prose paragraphs** (analysis, narrative, argument)
2. **Tables** (`booktabs` + `tabularx`) for comparisons and structured data
3. **tcolorbox cards** for profiles, callouts, executive summaries
4. **Bold-label paragraphs** for 3-5 distinct concepts
5. **Figures with captions** for charts, diagrams, images
6. **Longtable** for multi-page structured comparisons

Adjacent sections should NOT use the same format. If Section 3.1 uses a table, Section 3.2 should use prose or tcolorbox, not another table.

### Anti-Pattern 6: Silent Encoding Errors

**The Problem:** Documents compile without errors but the PDF contains garbage characters (inverted question marks, missing symbols). The agent doesn't notice because compilation succeeds.

**Common silent errors:**
| You Write | PDF Shows | Fix |
|---|---|---|
| `<5%` in text | ¿5% | `$<$5\%` |
| `>50` in text | ¡50 | `$>$50` |
| `~` in text | (nothing/tilde accent on next char) | `\textasciitilde` |
| `|` in text | (may render wrong) | `\textbar` or `$\vert$` |
| `\` in text | (starts a command) | `\textbackslash` |
| `{` or `}` in text | (grouping chars) | `\{` or `\}` |

**The Rule:** After generating LaTeX content, scan for these characters in text mode (outside math `$...$` and commands). The most commonly missed are `<` and `>`.

### Quick Reference: Report Preamble Best Practices

Every report-class document (10+ pages) should include this baseline preamble setup:

```latex
\documentclass[11pt,a4paper]{article}

% Core packages
\usepackage[margin=1in]{geometry}
\usepackage{graphicx}
\usepackage[colorlinks=true, linkcolor=blue, urlcolor=blue]{hyperref}
\usepackage[table]{xcolor}
\usepackage{colortbl}
\usepackage{booktabs}
\usepackage{tabularx}
\usepackage{float}
\usepackage{enumitem}
\usepackage{longtable}
\usepackage{amsmath, amssymb}

% Recommended for professional reports
\usepackage[most]{tcolorbox}  % colored boxes for callouts, personas, highlights
\usepackage{titlesec}          % section heading customization
\usepackage{fancyhdr}          % headers and footers

% Global list compaction (ALWAYS include for reports)
\setlist[itemize]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
\setlist[enumerate]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
```

### Content Generation Checklist (Run Before Compiling)

Before compiling a long-form document, verify:

- [ ] **Bullet count:** Fewer than 15 itemize/enumerate blocks per 40 pages? If not, convert excess to prose.
- [ ] **Angle brackets:** Search for `<` and `>` outside math mode. Replace with `$<$`/`$>$` or `\textless`/`\textgreater`.
- [ ] **\newpage abuse:** Are `\newpage` commands only at major transitions, not before every section?
- [ ] **Image sizing:** Are most images `0.75-0.85\textwidth`? No images at `0.95\textwidth` unless full-bleed is intended?
- [ ] **List compaction:** Is `\setlist[itemize]{nosep, leftmargin=*}` in the preamble?
- [ ] **Format variety:** Do adjacent sections use different content formats (prose, table, tcolorbox, figure)?
- [ ] **Float placement:** Are most figures `[htbp]`, with `[H]` only where exact placement matters?
- [ ] **Special characters:** Are `%`, `$`, `&`, `#`, `_`, `<`, `>` properly escaped in text mode?
