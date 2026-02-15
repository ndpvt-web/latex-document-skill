---
name: latex-document
description: >
  Universal LaTeX document skill: create, compile, and convert any document to
  professional PDF with PNG previews. Supports resumes, reports, cover letters,
  invoices, academic papers, theses/dissertations, academic CVs, presentations
  (Beamer), scientific posters, formal letters, exams/quizzes, books,
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
  diagrams for LaTeX, (18) create a formal business letter.
---

# LaTeX Document Skill

Create any LaTeX document, compile to PDF, and generate PNG previews. Convert PDFs of any type to LaTeX.

## Workflow: Create Documents

1. Determine document type (resume, report, letter, invoice, article, thesis, academic CV, presentation, poster, exam, book)
2. **If poster:** Run the poster sub-workflow (see [Poster Sub-Workflow](#poster-sub-workflow) below), then skip to step 5.
3. **Ask the user which enrichment elements they want** (use AskUserQuestion tool with multiSelect). Offer relevant options based on document type:
   - **AI-generated images** -- custom illustrations, diagrams, photos (uses generate-image skill)
   - **Charts/graphs** -- bar, line, pie, scatter, heatmap (pgfplots or matplotlib)
   - **Flowcharts/diagrams** -- process flows, architecture, decision trees (TikZ or Mermaid)
   - **Citations/bibliography** -- academic references, footnotes, works cited (BibTeX/biblatex)
   - **Tables with data** -- comparison matrices, financial data, statistics (booktabs)
   - **Watermarks** -- DRAFT, CONFIDENTIAL, or company logo background
   - Skip this step for simple documents (cover letters, invoices) or when the user has already specified exactly what they want.
4. Copy the appropriate template from `assets/templates/` or write from scratch
5. Customize content based on user requirements
6. Generate external assets based on user's element choices:
   - AI images: `python3 <skill_path>/../generate-image/scripts/generate_image.py "prompt" --output ./outputs/figure.png`
   - matplotlib charts: `python3 <skill_path>/scripts/generate_chart.py <type> --data '<json>' --output chart.png`
   - Mermaid diagrams: `bash <skill_path>/scripts/mermaid_to_image.sh diagram.mmd output.png`
7. **For documents 5+ pages:** Review the [Long-Form Document Anti-Patterns](#long-form-document-anti-patterns-must-read-for-reports-theses-books) section and run the Content Generation Checklist before compiling. Key rules: prefer prose over bullets, include global list compaction, escape `<`/`>` in text mode, vary section formats, limit `\newpage`, size images at 0.75-0.85 textwidth.
8. Compile with `scripts/compile_latex.sh` (auto-detects XeLaTeX for CJK/RTL, glossaries, bibliography)
9. Show PNG preview to user, deliver PDF

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
6. Concatenate all batch files with the preamble
7. Compile with `scripts/compile_latex.sh`

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

### Other Templates

- **`lecture-notes.tex`** -- Beautiful lecture notes (`scrartcl` KOMA-Script class) with Palatino font, `microtype` typography, color-coded `tcolorbox` theorem environments (blue theorems, green definitions, orange examples, purple remarks), TikZ graph theory diagram styles and macros (`\CompleteGraph`, `\CycleGraph`, `\PathGraph`), styled section headings with `titlesec`, `fancyhdr` headers, `hyperref` + `cleveref` navigation. Ideal for converting handwritten math/science notes to beautiful PDFs. Includes graph theory custom commands (`\V`, `\E`, `\deg`, `\chr`). Used by the math-notes conversion profile in beautiful mode.
- **`thesis.tex`** -- Thesis/dissertation (`book` class) with title page, declaration, abstract, acknowledgments, TOC, list of figures/tables, chapters, appendices, bibliography. Front matter uses roman numerals, main matter uses arabic. Includes theorem environments.
- **`academic-cv.tex`** -- Multi-page academic CV with publications (journal/conference/preprint sections), grants and funding, teaching, advising (current/graduated students), awards, professional service, invited talks. ORCID and Google Scholar links.
- **`book.tex`** -- Full book (`book` class) with half-title, title page, copyright page, dedication, preface, acknowledgments, TOC, list of figures/tables, parts, chapters, appendix, bibliography, index. Custom chapter headings, epigraphs, fancyhdr, microtype.
- **`poster.tex`** -- Conference poster (`tikzposter` class, A0 portrait) with 2-column layout, QR code, 5 color schemes, tikzfigure charts, tables, coloredbox highlights. Includes commented **#BetterPoster** layout variant (central billboard + sidebars). Portrait is standard for most conferences. See poster design guide for conference size presets.
- **`poster-landscape.tex`** -- Landscape conference poster (`tikzposter` class, A0 landscape) with 3-column (30/40/30) layout, QR code, tech purple color scheme. For CS/ML conferences (NeurIPS, ICML, CVPR, ICLR). Includes commented `\geometry{}` presets for CVPR/NeurIPS custom sizes.
- **`letter.tex`** -- Formal business letter with colored letterhead bar, TikZ logo placeholder, company info, recipient block, date, subject line, signature. Professional corporate appearance.
- **`exam.tex`** -- Exam/quiz (`exam` class) with grading table, multiple question types (multiple choice, true/false, fill-in-blank, matching, short answer, essay), point values, solution toggle via `\printanswers`.
- **`report.tex`** -- Business report with TOC, headers/footers, data tables, bar chart (pgfplots), process flowchart (TikZ), recommendations
- **`cover-letter.tex`** -- Professional cover letter with sender/recipient blocks
- **`invoice.tex`** -- Invoice with company header, line items table, subtotal/tax/total
- **`academic-paper.tex`** -- Research paper with abstract, sections, bibliography, figures. Includes example `.bib` file (`references.bib`) for BibTeX citations.
- **`presentation.tex`** -- Beamer presentation with title slide, content frames, columns
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
| Formal business letter | `letter.tex` | `article` |
| Exam, quiz, test | `exam.tex` | `exam` |
| Slides, presentation | `presentation.tex` | `beamer` |
| **Convert PDF to LaTeX** | Select profile + see [pdf-conversion.md](references/pdf-conversion.md) | varies |
| **Convert formats** | Use `scripts/convert_document.sh` + see [format-conversion.md](references/format-conversion.md) | varies |

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
