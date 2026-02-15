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
2. Copy the appropriate template from `assets/templates/` or write from scratch
3. Customize content based on user requirements
4. Generate any external assets (Mermaid diagrams, matplotlib charts, AI images) if needed
5. Compile with `scripts/compile_latex.sh` (auto-detects XeLaTeX for CJK/RTL, glossaries, bibliography)
6. Show PNG preview to user, deliver PDF

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
| Math / science notes | `references/profiles/math-notes.md` | Equations, theorems, proofs, definitions, Greek symbols |
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

- **`thesis.tex`** -- Thesis/dissertation (`book` class) with title page, declaration, abstract, acknowledgments, TOC, list of figures/tables, chapters, appendices, bibliography. Front matter uses roman numerals, main matter uses arabic. Includes theorem environments.
- **`academic-cv.tex`** -- Multi-page academic CV with publications (journal/conference/preprint sections), grants and funding, teaching, advising (current/graduated students), awards, professional service, invited talks. ORCID and Google Scholar links.
- **`book.tex`** -- Full book (`book` class) with half-title, title page, copyright page, dedication, preface, acknowledgments, TOC, list of figures/tables, parts, chapters, appendix, bibliography, index. Custom chapter headings, epigraphs, fancyhdr, microtype.
- **`poster.tex`** -- Scientific conference poster (`tikzposter` class, A0) with 3-column layout, color blocks, TikZ workflow diagram, pgfplots bar chart, booktabs table. Customizable color scheme.
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
| Thesis, dissertation | `thesis.tex` | `book` |
| Academic CV (publications, grants) | `academic-cv.tex` | `article` |
| Report, analysis | `report.tex` | `article` |
| Cover letter | `cover-letter.tex` | `article` |
| Invoice | `invoice.tex` | `article` |
| Academic paper | `academic-paper.tex` + `references.bib` | `article` |
| Book | `book.tex` | `book` |
| Scientific poster | `poster.tex` | `tikzposter` |
| Formal business letter | `letter.tex` | `article` |
| Exam, quiz, test | `exam.tex` | `exam` |
| Slides, presentation | `presentation.tex` | `beamer` |
| **Convert PDF to LaTeX** | Select profile + see [pdf-conversion.md](references/pdf-conversion.md) | varies |
| **Convert formats** | Use `scripts/convert_document.sh` + see [format-conversion.md](references/format-conversion.md) | varies |

## Key LaTeX Patterns

### Escaping Special Characters

Always escape: `%` → `\%`, `$` → `\$`, `&` → `\&`, `#` → `\#`, `_` → `\_`

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

% Company logo as background watermark
\usepackage{eso-pic}
\usepackage{graphicx}
\AddToShipoutPictureBG{%
    \AtPageCenter{%
        \makebox(0,0){%
            \includegraphics[width=0.4\paperwidth,keepaspectratio,opacity=0.08]{logo.png}%
        }%
    }%
}

% Logo in header (every page)
\usepackage{fancyhdr}
\fancyhead[L]{\includegraphics[height=1cm]{logo.png}}
```

See [references/advanced-features.md](references/advanced-features.md) for combining text + logo watermarks, first-page-only watermarks, and more.

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
# Generate image with AI and include in LaTeX
python3 /home/node/.claude/skills/generate-image/scripts/generate_image.py \
    "Professional diagram of neural network, clean white background, technical illustration" \
    --output ./outputs/figure.png
```

```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=0.6\textwidth]{figure.png}
    \caption{Neural network architecture (AI-generated).}
\end{figure}
```

Request "white background, clean, no text" for best results in documents. See [references/advanced-features.md](references/advanced-features.md).

## Visual Elements in Reports

When creating reports, always include visual elements where they strengthen the content:

- **Bar charts** (pgfplots `ybar`/`xbar`): Compare categories, show rankings, display metrics
- **Line charts** (pgfplots): Show trends over time, growth curves, multi-series comparisons
- **Pie charts** (TikZ): Show budget allocation, market share, composition breakdowns
- **Flowcharts** (TikZ): Show processes, workflows, decision trees, system architecture
- **Timelines** (TikZ): Show project phases, milestones, rollout schedules
- **Tables** (booktabs/tabularx): Show detailed data, capability matrices, risk assessments, comparisons

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
