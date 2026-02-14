---
name: latex-document
description: >
  Universal LaTeX document skill: create, compile, and convert any document to
  professional PDF with PNG previews. Supports resumes, reports, cover letters,
  invoices, academic papers, presentations (Beamer), charts (pgfplots), tables
  (booktabs), images (TikZ), and PDF-to-LaTeX conversion of handwritten or printed
  documents (math, business, legal, general). Empirically optimized scaling: single
  agent 1-10 pages, split 11-20, batch-7 pipeline 21+. Document-type profiles for
  accurate conversion. Use when user asks to: (1) create a resume/CV/cover letter,
  (2) write a LaTeX document, (3) create PDF with tables/charts/images, (4) compile
  a .tex file, (5) make a report/invoice/presentation, (6) anything involving LaTeX
  or pdflatex, (7) convert/OCR a PDF to LaTeX, (8) convert handwritten notes,
  (9) create charts/graphs, (10) create slides.
---

# LaTeX Document Skill

Create any LaTeX document, compile to PDF, and generate PNG previews. Convert PDFs of any type to LaTeX.

## Workflow: Create Documents

1. Determine document type (resume, report, letter, invoice, article, presentation)
2. Copy the appropriate template from `assets/templates/` or write from scratch
3. Customize content based on user requirements
4. Compile with `scripts/compile_latex.sh`
5. Show PNG preview to user, deliver PDF

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
# Basic compile
bash <skill_path>/scripts/compile_latex.sh document.tex

# Compile + generate PNG previews
bash <skill_path>/scripts/compile_latex.sh document.tex --preview

# Compile + PNG in specific directory
bash <skill_path>/scripts/compile_latex.sh document.tex --preview --preview-dir ./outputs
```

The script auto-installs `texlive` and `poppler-utils` if missing, runs pdflatex twice for cross-references, generates PNG previews with `pdftoppm`, and cleans auxiliary files.

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

- **`report.tex`** -- Business report with TOC, headers/footers, data tables, bar chart (pgfplots), process flowchart (TikZ), recommendations
- **`cover-letter.tex`** -- Professional cover letter with sender/recipient blocks
- **`invoice.tex`** -- Invoice with company header, line items table, subtotal/tax/total
- **`academic-paper.tex`** -- Research paper with abstract, sections, bibliography, figures
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
| Report, analysis | `report.tex` | `article` |
| Cover letter | `cover-letter.tex` | `article` |
| Invoice | `invoice.tex` | `article` |
| Academic paper | `academic-paper.tex` | `article` |
| Slides, presentation | `presentation.tex` | `beamer` |
| **Convert PDF to LaTeX** | Select profile + see [pdf-conversion.md](references/pdf-conversion.md) | varies |

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

## Advanced Features

- **Tables**: Colored rows, multi-row/column, borderless booktabs, long tables spanning pages. See [references/tables-and-images.md](references/tables-and-images.md).
- **Images**: External images, TikZ drawings, circular clipped photos, side-by-side, text wrapping. See [references/tables-and-images.md](references/tables-and-images.md).
- **Charts and Graphs**: Line plots, bar charts, scatter plots, pie charts, pgfplots. See [references/charts-and-graphs.md](references/charts-and-graphs.md).
- **Package reference**: Common packages and their purposes. See [references/packages.md](references/packages.md).
- **Resume ATS guide**: ATS compatibility rules, LaTeX-specific pitfalls, keyword optimization, action verbs. See [references/resume-ats-guide.md](references/resume-ats-guide.md).
- **PDF-to-LaTeX conversion**: Full pipeline with scaling strategy and profiles. See [references/pdf-conversion.md](references/pdf-conversion.md).

## Critical Notes

- Run compile script from the directory containing the .tex file, or use absolute paths
- For documents with `\tableofcontents`, the script runs pdflatex twice automatically
- Use `\usepackage{colortbl}` when using `\rowcolor` -- missing this causes `Undefined control sequence` errors
- PNG previews require `poppler-utils` (auto-installed by script)
- Place output .tex files in `./outputs/` for user visibility
- After compilation, read the PNG files to show the user how the document looks
- **PDF conversion**: Do NOT use `sed` to clean control characters from LaTeX -- it breaks `\begin`, `\end`, `\newpage`, etc.
- **PDF conversion**: Do NOT use `hyperref` package in converted documents -- causes `\set@color` errors
- **PDF conversion**: Use `run_in_background` agents, NOT agent teams -- simpler, more reliable
- **PDF conversion**: Select the correct conversion profile for the document type -- a math profile on a business doc produces unnecessary theorem environments
