# LaTeX Document Types

## Table of Contents
- [Resume / CV](#resume--cv)
- [Business Report](#business-report)
- [Cover Letter](#cover-letter)
- [Invoice](#invoice)
- [Academic Article](#academic-article)
- [Presentation (Beamer)](#presentation-beamer)

---

## Resume / CV

**Base preamble:**
```latex
\documentclass[11pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{geometry}
\usepackage{enumitem}
\usepackage{hyperref}
\usepackage{xcolor}
\usepackage{titlesec}
\usepackage{graphicx}
\usepackage{tabularx}
\usepackage{colortbl}
\usepackage{tikz}

\geometry{a4paper, left=0.75in, right=0.75in, top=0.75in, bottom=0.75in}
\pagestyle{empty}
```

**Key patterns:**
- Use `\minipage` for header layout (name + photo side by side)
- Custom `\newcommand{\experience}[4]` for job entries: title, dates, company, location
- `\section*{}` with `titlesec` customization for colored section headers with rules
- `itemize` with `[leftmargin=1.5em, itemsep=0.3em]` for compact bullet points
- Tables for skills matrix (category | technologies | proficiency)
- Escape `%` as `\%`, `$` as `\$`, `&` as `\&`

**Template available:** See `assets/templates/resume.tex`

---

## Business Report

**Base preamble:**
```latex
\documentclass[12pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{geometry}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{xcolor}
\usepackage{titlesec}
\usepackage{fancyhdr}
\usepackage{tabularx}
\usepackage{colortbl}
\usepackage{booktabs}

\geometry{a4paper, margin=1in}
\pagestyle{fancy}
```

**Key patterns:**
- Title page with `\maketitle` or custom `titlepage` environment
- Table of contents with `\tableofcontents` (requires two compilation passes)
- `fancyhdr` for headers/footers with company branding
- `booktabs` for clean data tables (`\toprule`, `\midrule`, `\bottomrule`)
- Numbered sections with `\section{}`, `\subsection{}`
- Figures with captions and cross-references (`\label`, `\ref`)

**Template available:** See `assets/templates/report.tex`

---

## Cover Letter

**Base preamble:**
```latex
\documentclass[11pt,a4paper]{letter}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{geometry}
\usepackage{hyperref}
\usepackage{xcolor}

\geometry{a4paper, margin=1in}
\pagestyle{empty}
```

**Key patterns:**
- Use `letter` document class or `article` with custom formatting
- `\opening{Dear ...}` and `\closing{Sincerely,}`
- Keep to one page
- Match styling with resume for consistency (same fonts, colors)

**Minimal example:**
```latex
\begin{document}
\begin{letter}{Company Name \\ Street \\ City}
\date{February 13, 2026}
\opening{Dear Hiring Manager,}

First paragraph: why you are writing...

Second paragraph: your qualifications...

Third paragraph: closing and call to action...

\closing{Sincerely,}
Your Name
\end{letter}
\end{document}
```

---

## Invoice

**Key patterns:**
- Use `article` class with minimal margins
- Company header with logo using `\includegraphics` or TikZ
- Invoice table: `tabularx` with item, description, quantity, unit price, total
- Summary box at bottom with subtotal, tax, total
- Use `\hfill` for right-aligned totals

**Table structure:**
```latex
\begin{tabularx}{\textwidth}{|c|X|c|r|r|}
\hline
\rowcolor{lightgray}
\textbf{\#} & \textbf{Description} & \textbf{Qty} & \textbf{Unit Price} & \textbf{Total} \\
\hline
1 & Web development services & 40 hrs & \$150.00 & \$6,000.00 \\
\hline
2 & UI/UX design & 10 hrs & \$120.00 & \$1,200.00 \\
\hline
\multicolumn{4}{|r|}{\textbf{Subtotal}} & \$7,200.00 \\
\hline
\multicolumn{4}{|r|}{\textbf{Tax (10\%)}} & \$720.00 \\
\hline
\multicolumn{4}{|r|}{\textbf{Total}} & \textbf{\$7,920.00} \\
\hline
\end{tabularx}
```

---

## Academic Article

**Base preamble:**
```latex
\documentclass[12pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{geometry}
\usepackage{natbib}   % or biblatex for references
\usepackage{abstract}

\geometry{a4paper, margin=1in}
```

**Key patterns:**
- `\title{}`, `\author{}`, `\date{}`, `\maketitle`
- `\begin{abstract}...\end{abstract}`
- Math with `$...$` inline, `\[...\]` or `equation` environment for display
- Citations with `\cite{key}` and bibliography at end
- Figures and tables with `\label` and `\ref` cross-references

---

## Presentation (Beamer)

**Base preamble:**
```latex
\documentclass{beamer}
\usetheme{Madrid}  % or Berlin, CambridgeUS, etc.
\usepackage[utf8]{inputenc}
\usepackage{graphicx}
\usepackage{tikz}

\title{Presentation Title}
\author{Author Name}
\date{\today}
```

**Key patterns:**
```latex
\begin{document}
\frame{\titlepage}

\begin{frame}{Slide Title}
  \begin{itemize}
    \item Point one
    \item Point two
  \end{itemize}
\end{frame}

\begin{frame}{With Columns}
  \begin{columns}
    \column{0.5\textwidth}
    Left content
    \column{0.5\textwidth}
    Right content
  \end{columns}
\end{frame}
\end{document}
```

**Note:** Beamer requires `texlive-latex-extra` package for themes. Use `--preview` flag on compile script to generate slide PNGs.
