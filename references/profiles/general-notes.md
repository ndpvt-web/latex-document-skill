# Conversion Profile: General / Mixed Notes

Use this profile when the PDF contains: handwritten notes, personal journals, lecture notes (non-math), letters, mixed content that doesn't clearly fit math/business/legal categories.

## Suggested Preamble

```latex
\documentclass[11pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[margin=1in]{geometry}
\usepackage{graphicx}
\usepackage{xcolor}
\usepackage{enumitem}
\usepackage{parskip}
\usepackage{titlesec}
\usepackage{tabularx}
\usepackage{booktabs}

% Colors for annotations
\definecolor{notecolor}{rgb}{1,0,0}
\definecolor{highlight}{RGB}{255,255,200}

% Section styling
\titleformat{\section}{\Large\bfseries}{}
    {0em}{}[\titlerule]
\titleformat{\subsection}{\large\bfseries}{}
    {0em}{}
```

## Structural Patterns to Recognize

- **Headings**: Larger or underlined text -> `\section{}` or `\subsection{}`
- **Bullet points / dashes**: Listed items -> `\begin{itemize}...\end{itemize}`
- **Numbered items**: Sequential points -> `\begin{enumerate}...\end{enumerate}`
- **Paragraphs**: Regular text blocks -> standard paragraphs with blank line separation
- **Emphasized text**: Underlined, circled, or highlighted -> `\textbf{}`, `\emph{}`, or `\underline{}`
- **Colored annotations**: Red/blue marks -> `{\color{notecolor}text}`
- **Diagrams / drawings**: Sketches -> `% [Figure: description of drawing]`
- **Tables / grids**: Organized data -> `tabularx` or `tabular`
- **Dates**: Date headers on notes -> `\subsection*{Date}` or bold text
- **Arrows / connections**: Flow indicators -> describe in text or use TikZ

## Worker Agent Hints

- Be faithful to the content -- transcribe what's written, don't reinterpret
- For illegible text: use `[illegible]` or `[?]` markers
- Handwriting with crossed-out text: omit the crossed-out content unless it's clearly important
- Marginal notes: include as `\marginpar{note}` or inline with `{\color{notecolor}note}`
- Preserve the general flow and organization of the original
- If the notes switch topics abruptly, use `\bigskip` or `\section*{}` to mark the transition
- For simple diagrams described in text: use a centered italic description
  ```latex
  \begin{center}
  \textit{[Diagram: flowchart showing process A → B → C]}
  \end{center}
  ```
- Close ALL environments before the end of your batch

## Common Pitfalls

1. **Over-structuring**: Handwritten notes are often informal. Don't force them into rigid theorem/definition environments unless the content clearly matches.
2. **Illegible content**: Don't guess at illegible handwriting. Mark it clearly.
3. **Mixed languages**: If notes contain non-English text, ensure UTF-8 encoding handles the characters. Add `\usepackage[language]{babel}` if needed.
4. **Doodles and sketches**: Don't try to reproduce complex drawings in TikZ. Describe them or note them as figures.
5. **Inconsistent formatting**: Notes may change style mid-page. Follow the original's structure even if inconsistent.
6. **Special characters**: Handwritten ampersands, dollar signs, percent signs all need escaping in LaTeX.
