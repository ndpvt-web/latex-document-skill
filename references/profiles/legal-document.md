# Conversion Profile: Legal Documents

Use this profile when the PDF contains: contracts, agreements, regulations, statutes, terms and conditions, legal briefs, numbered paragraphs, footnotes, citations, definitions sections.

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
\usepackage{enumitem}
\usepackage{parskip}
\usepackage{setspace}
\usepackage{footmisc}

% Legal document spacing (often double-spaced)
\onehalfspacing

% Section numbering: Article I, Section 1.1, etc.
\renewcommand{\thesection}{\Roman{section}}
\renewcommand{\thesubsection}{\thesection.\arabic{subsection}}
\renewcommand{\thesubsubsection}{\thesubsection.\alph{subsubsection}}

\titleformat{\section}{\large\bfseries\centering}{\thesection.}{0.5em}{}
\titleformat{\subsection}{\normalsize\bfseries}{\thesubsection}{0.5em}{}

% Headers/footers
\pagestyle{fancy}
\fancyhf{}
\fancyfoot[C]{\small\thepage}
\renewcommand{\headrulewidth}{0pt}

% Indented paragraphs for legal clauses
\setlength{\parindent}{2em}
\setlength{\parskip}{0.5em}
```

## Structural Patterns to Recognize

- **Articles / Sections**: "ARTICLE I", "Section 1.1" -> `\section{}`, `\subsection{}`
- **Numbered clauses**: "(a)", "(b)", "(i)", "(ii)" -> nested `enumerate` with custom labels
- **Definitions**: "Term" means... -> `\textbf{"Term"}` with definition text
- **Recitals / Whereas clauses**: "WHEREAS..." paragraphs -> regular paragraphs with `\textsc{Whereas}`
- **Signature blocks**: Party names, dates, signature lines -> formatted block with `\rule`
- **Footnotes**: Superscript numbers with notes -> `\footnote{}`
- **Block quotes**: Indented cited text -> `\begin{quote}...\end{quote}`
- **ALL CAPS headings**: Section titles in uppercase -> `\section{\texorpdfstring{\MakeUppercase{Title}}{Title}}`
- **Cross-references**: "See Section 3.2" -> keep as plain text (don't try to `\ref`)
- **Page numbers**: "Page X of Y" -> handled by `fancyhdr`

## Worker Agent Hints

- Legal docs have deeply nested numbering: Article > Section > Subsection > (a) > (i). Use nested `enumerate`:
  ```latex
  \begin{enumerate}[label=(\alph*)]
    \item First clause
    \begin{enumerate}[label=(\roman*)]
      \item Sub-clause
    \end{enumerate}
  \end{enumerate}
  ```
- Preserve exact wording -- legal text is precise, don't paraphrase or summarize
- ALL CAPS headers: use `\textbf{\MakeUppercase{heading text}}`
- Signature blocks:
  ```latex
  \vspace{2cm}
  \noindent\rule{6cm}{0.4pt} \\
  Name \\
  Title \\
  Date: \rule{3cm}{0.4pt}
  ```
- For "WHEREAS" recitals: start each with `\noindent\textsc{Whereas},`
- Footnotes: place `\footnote{text}` immediately after the reference mark
- Close ALL environments before the end of your batch

## Common Pitfalls

1. **Section numbering mismatch**: Legal documents use Roman numerals (I, II, III) or custom numbering. Match the original scheme.
2. **Nested list depth**: LaTeX supports 4 levels of nesting. For deeper nesting, customize `enumitem` labels.
3. **Quotation marks**: Use `` ` `` and `'` for quotes in LaTeX (`` `single' `` and ``` ``double'' ```), not straight quotes.
4. **Long paragraphs**: Legal text can be very dense. Preserve paragraph breaks as they appear in the original.
5. **Escaping special chars**: Legal text often has `§` (use `\S`), `¶` (use `\P`), and `©` (use `\copyright`).
6. **Cross-references**: Don't try to create `\label`/`\ref` pairs -- just write "Section 3.2" as plain text.
