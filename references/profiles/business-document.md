# Conversion Profile: Business Documents

Use this profile when the PDF contains: reports, meeting notes, memos, proposals, financial data, org charts, executive summaries, action items, bullet points, data tables.

## Suggested Preamble

```latex
\documentclass[12pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[margin=1in]{geometry}
\usepackage{graphicx}
\usepackage{xcolor}
\usepackage{titlesec}
\usepackage{fancyhdr}
\usepackage{tabularx}
\usepackage{array}
\usepackage{colortbl}
\usepackage{booktabs}
\usepackage{multirow}
\usepackage{longtable}
\usepackage{enumitem}
\usepackage{parskip}

% Professional colors
\definecolor{headerblue}{RGB}{0, 102, 204}
\definecolor{lightgray}{RGB}{240, 240, 240}
\definecolor{darkgray}{RGB}{80, 80, 80}

% Section styling
\titleformat{\section}{\Large\bfseries\color{headerblue}}{\thesection}{0.5em}{}
\titleformat{\subsection}{\large\bfseries}{}{0em}{}

% Headers/footers
\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small\textcolor{darkgray}{Document Title}}
\fancyhead[R]{\small\textcolor{darkgray}{\today}}
\fancyfoot[C]{\small\thepage}
\renewcommand{\headrulewidth}{0.4pt}
```

## Structural Patterns to Recognize

- **Section headings**: Bold or underlined text, often numbered -> `\section{}` or `\subsection{}`
- **Executive summary**: Opening paragraph with key findings -> dedicated `\section{Executive Summary}`
- **Bullet points**: Dashes or dots -> `\begin{itemize}...\end{itemize}`
- **Numbered lists**: Sequential numbers -> `\begin{enumerate}...\end{enumerate}`
- **Action items**: Checkboxes or "TODO" markers -> itemize with bold labels
- **Data tables**: Rows and columns of data -> `tabularx` with `booktabs` rules
- **Financial figures**: Currency amounts, percentages -> right-aligned columns with `r`
- **Headers/footers**: Recurring text at page top/bottom -> capture in `fancyhdr` setup
- **Signatures**: Signature lines -> `\rule{5cm}{0.4pt}` with name below
- **Date/time stamps**: Meeting dates, deadlines -> format consistently
- **Company logos**: Letterhead images -> `\includegraphics` or note as placeholder

## Worker Agent Hints

- Use `\section{}` with numbers (not `\section*{}`) -- business docs typically have numbered sections
- Preserve table structure carefully: count columns, align data types (text left, numbers right)
- For financial tables: use `booktabs` (`\toprule`, `\midrule`, `\bottomrule`), right-align currency
- Meeting notes: use `\textbf{Date:}`, `\textbf{Attendees:}`, etc. for metadata blocks
- Bullet points: use `\begin{itemize}[itemsep=0.3em]` for compact lists
- For emphasis: use `\textbf{}` for bold, `\textit{}` for italic -- match the original
- When text references a chart or image that isn't transcribable: `% [Figure: description of chart/image]`
- Close ALL environments before the end of your batch

## Common Pitfalls

1. **Table column count mismatch**: Count `&` separators carefully. Each row must have exactly N-1 `&` for N columns.
2. **Stray `&` in text**: Business text often contains `&` (e.g., "R&D", "P&L"). Escape as `\&` outside tables.
3. **Dollar signs in financial data**: `$100` in text needs escaping: `\$100`.
4. **Percentage signs**: `50%` comments out the rest of the line in LaTeX. Use `50\%`.
5. **Long tables**: If a table spans many rows, use `longtable` instead of `tabularx` to allow page breaks.
6. **Missing `colortbl`**: If using `\rowcolor{}`, the `colortbl` package must be loaded.
