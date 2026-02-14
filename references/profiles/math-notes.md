# Conversion Profile: Math / Science Notes

Use this profile when the PDF contains: equations, theorems, proofs, definitions, lemmas, Greek symbols, matrices, integrals, mathematical notation.

## Suggested Preamble

```latex
\documentclass[11pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[margin=1in]{geometry}
\usepackage{amsmath,amssymb,amsthm}
\usepackage{mathtools}
\usepackage{mathrsfs}
\usepackage{graphicx}
\usepackage{xcolor}
\usepackage{tikz}
\usepackage{enumitem}
\usepackage{parskip}
\usepackage{bbm}
\usepackage{esint}
\usepackage{cancel}

% Number sets
\newcommand{\R}{\mathbb{R}}
\newcommand{\N}{\mathbb{N}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\Q}{\mathbb{Q}}
\newcommand{\C}{\mathbb{C}}

% Derivatives
\newcommand{\pd}[2]{\frac{\partial #1}{\partial #2}}
\newcommand{\dd}[2]{\frac{d #1}{d #2}}

% Norms and delimiters
\newcommand{\norm}[1]{\left\|#1\right\|}
\newcommand{\abs}[1]{\left|#1\right|}
\newcommand{\inner}[2]{\langle #1,\, #2 \rangle}

% Theorem environments
\theoremstyle{plain}
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}

\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{example}[theorem]{Example}

\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}
\newtheorem{note}[theorem]{Note}

\renewcommand{\qedsymbol}{$\blacksquare$}
```

## Structural Patterns to Recognize

- **Theorem/Lemma/Proposition**: Boxed or labeled statements -> `\begin{theorem}...\end{theorem}`
- **Definitions**: Usually underlined key term -> `\begin{definition}...\end{definition}`
- **Proofs**: Starts with "Proof:" or "Pf:", ends with QED symbol -> `\begin{proof}...\end{proof}`
- **Examples**: Starts with "Example:" or "Ex:" -> `\begin{example}...\end{example}`
- **Remarks**: Side notes, observations -> `\begin{remark}...\end{remark}`
- **Multi-line derivations**: Aligned at `=` signs -> `align*` environment
- **Single important equations**: Standalone display -> `equation*` environment
- **Matrices**: Arrays of numbers in brackets -> `pmatrix` or `bmatrix`
- **Diagrams**: Coordinate systems, function graphs -> describe in TikZ or note as figure

## Worker Agent Hints

- Use `\section*{}` for unnumbered section headings (matching handwritten headers)
- Red or colored annotations in original: `{\color{red}text}`
- When equations span multiple lines, prefer `align*` with `&` alignment at `=`
- Close ALL environments before the end of your batch -- if a proof spans your boundary, close it and note `% continues in next batch`
- Subscript notation: be careful with `D_{x_i}f` vs `\frac{\partial f}{\partial x_i}`
- Use `\left( \right)` for auto-sized delimiters around fractions
- Inline math for short expressions: `$f(x) = x^2$`
- Display math for important results: `\[ f'(x) = 2x \]`

## Common Pitfalls

1. **Mismatched environments**: The #1 error source. Always pair `\begin{X}` with `\end{X}`. Count your opens and closes before finishing.
2. **Stray `&` characters**: `&` is a column separator in tables/align. Outside these environments it causes errors. Escape as `\&` in text.
3. **Missing `$` delimiters**: Forgetting to close inline math mode. Every `$` needs a matching `$`.
4. **Nested environments**: `align*` inside `theorem` is fine. `align*` inside `definition` is fine. But don't cross-nest (`\begin{theorem}...\begin{align*}...\end{theorem}...\end{align*}` = error).
5. **`hyperref` conflicts**: Do NOT include `hyperref` -- causes `\set@color` errors with theorem environments.
