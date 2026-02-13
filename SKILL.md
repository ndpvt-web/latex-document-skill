---
name: latex-document
description: >
  Create, compile, and render professional LaTeX documents as PDF with PNG previews.
  Supports resumes/CVs, business reports, cover letters, invoices, academic papers,
  and presentations. Includes tables (tabularx, booktabs, colored rows, multirow),
  images (includegraphics, TikZ drawings, circular clipped photos), and professional
  formatting. Use when the user asks to: (1) create a resume, CV, or cover letter in
  LaTeX, (2) write any document in LaTeX, (3) create a PDF document with tables or
  images, (4) render or compile a .tex file, (5) "make me a resume/report/invoice",
  (6) anything involving LaTeX, TeX, pdflatex, or typesetting.
---

# LaTeX Document Skill

Create LaTeX documents, compile to PDF, and generate PNG previews.

## Workflow

1. Determine document type (resume, report, letter, invoice, article, presentation)
2. Copy the appropriate template from `assets/templates/` or write from scratch
3. Customize content based on user requirements
4. Compile with `scripts/compile_latex.sh`
5. Show PNG preview to user, deliver PDF

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

## Templates

Copy from `assets/templates/` and customize:

- **`resume.tex`** - Professional resume with photo area, skills table, experience entries, education
- **`report.tex`** - Business report with TOC, headers/footers, data tables, recommendations

Usage:
```bash
cp <skill_path>/assets/templates/resume.tex ./outputs/my_resume.tex
# Edit content, then compile
bash <skill_path>/scripts/compile_latex.sh ./outputs/my_resume.tex --preview --preview-dir ./outputs
```

## Document Type Selection

| User Request | Template | Document Class |
|---|---|---|
| Resume, CV | `resume.tex` | `article` |
| Report, analysis | `report.tex` | `article` |
| Cover letter | Write from scratch | `letter` or `article` |
| Invoice | Write from scratch | `article` |
| Academic paper | Write from scratch | `article` |
| Slides, presentation | Write from scratch | `beamer` |

For document-type-specific patterns and preambles, see [references/document-types.md](references/document-types.md).

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

## Advanced Features

- **Tables**: Colored rows, multi-row/column, borderless booktabs, long tables spanning pages. See [references/tables-and-images.md](references/tables-and-images.md).
- **Images**: External images, TikZ drawings, circular clipped photos, side-by-side, text wrapping. See [references/tables-and-images.md](references/tables-and-images.md).
- **Package reference**: Common packages and their purposes. See [references/packages.md](references/packages.md).

## Critical Notes

- Run compile script from the directory containing the .tex file, or use absolute paths
- For documents with `\tableofcontents`, the script runs pdflatex twice automatically
- Use `\usepackage{colortbl}` when using `\rowcolor` - missing this causes `Undefined control sequence` errors
- PNG previews require `poppler-utils` (auto-installed by script)
- Place output .tex files in `./outputs/` for user visibility
- After compilation, read the PNG files to show the user how the document looks
