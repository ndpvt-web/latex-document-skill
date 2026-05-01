# IEEE Journal Two-Column Typography Guide

Tutorial for producing camera-ready IEEE Transactions / Journal articles with the
official `IEEEtran` class. Covers two-column body geometry, single-column vs.
full-width floats, math/Unicode handling under XeLaTeX, bibliography format,
and the conversion path from a Markdown source.

## Table of Contents
- [When to Use This Guide](#when-to-use-this-guide)
- [IEEEtran in 30 Seconds](#ieeetran-in-30-seconds)
- [Document Class Options](#document-class-options)
- [Page and Body Geometry](#page-and-body-geometry)
- [Engine Choice: pdflatex vs. xelatex](#engine-choice-pdflatex-vs-xelatex)
- [Two-Column Float Rules](#two-column-float-rules)
- [Tables](#tables)
- [Figures](#figures)
- [Bibliography](#bibliography)
- [hyperref Without Colored Boxes](#hyperref-without-colored-boxes)
- [Markdown to IEEEtran via Pandoc](#markdown-to-ieeetran-via-pandoc)
- [Compile Sequence](#compile-sequence)
- [Common Mistakes](#common-mistakes)
- [Self-Check Before Submission](#self-check-before-submission)

---

## When to Use This Guide

Read this before the user asks for any of:
- A paper for IEEE Transactions, IEEE Journal, IEEE Access, or any IEEE conference using IEEEtran.
- "IEEE format / IEEE typography / IEEE two-column" applied to an existing draft.
- Conversion of a Markdown / DOCX manuscript into camera-ready IEEEtran PDF + DOCX dual delivery.
- A revision round that needs single-source rebuild (edit `.tex`, recompile to PDF, regenerate DOCX from the same MD).

If the target is a non-IEEE publisher (Springer LNCS, ACM, Elsevier, generic article class), use that publisher's class instead. This guide does not cover those.

---

## IEEEtran in 30 Seconds

`IEEEtran.cls` is the official class shipped by IEEE and packaged in CTAN as
`ieeetran`. It bakes in:

- A4 / Letter selectable, two-column body, narrow margins (~0.5 in)
- Title block, author block, IEEE running headers (`\markboth`)
- `\IEEEauthorrefmark`, `\IEEEmembership`, ORCID / IEEE membership grade glyphs
- `\IEEEPARstart` (drop-cap first letter for the first paragraph after the abstract)
- Auto-numbered figure captions (`Fig. N.`) and table captions (`TABLE N`)
- A simple `thebibliography` environment that produces IEEE-style numeric refs
- Strict float rules tuned for two-column journal layout

It does NOT:
- Set a typeface (uses Computer Modern by default; you opt-in to Times via `times` or `fontspec`)
- Provide bib styles (use `\bibliographystyle{IEEEtran}` if you keep BibTeX)
- Support arbitrary Unicode under pdflatex (must switch to xelatex for Greek, em-dash, math symbols in body text)

CTAN install (MiKTeX): `mpm.exe --install=ieeetran` — installs to
`<MiKTeX>/tex/latex/ieeetran/IEEEtran.cls`.

CTAN install (TeX Live): `tlmgr install ieeetran`.

---

## Document Class Options

```latex
\documentclass[journal,10pt]{IEEEtran}
```

Common option set:

| Option | Effect | When to use |
|---|---|---|
| `journal` | Two-column journal layout (Transactions, Access) | Default for TIFS, TPAMI, TKDE, TNNLS |
| `conference` | Two-column conference layout, no running head | ICIP, INFOCOM, ICASSP camera-ready |
| `technote` | Brief / correspondence layout | TIE Technote, IES Letter |
| `10pt` / `11pt` | Body font size | `10pt` is the IEEE journal default |
| `letterpaper` / `a4paper` | Page size | Letter for US journals; A4 if explicitly required |
| `draft` / `final` | Show / hide overfull rules and timestamp | `final` for camera-ready |
| `nofonttune` | Disable IEEEtran's micro font tweaks | Only when fontspec sets a custom font |

Avoid `peerreview` and `peerreviewca` unless the journal explicitly requests them; they collapse to single-column manuscript style which defeats the two-column claim.

---

## Page and Body Geometry

Trust the class. Do **not** load `geometry` to override margins. IEEEtran's
defaults are validated by IEEE's production system; any geometry change risks
desk rejection on layout grounds.

Two-column body:
- Column width ≈ 3.5 in (Letter) / 88.9 mm (A4)
- Column gutter ≈ 0.17 in (12 pt)
- Body height ≈ 9.25 in
- All floats default to top-of-column / top-of-page

Whenever you write `\textwidth` in a single-column scope, you are addressing the
narrow column width. Whenever you write `\textwidth` inside a `figure*` /
`table*` (full-page float), you are addressing the full page text width
(both columns + gutter, ≈ 7.16 in).

---

## Engine Choice: pdflatex vs. xelatex

Use **xelatex** when any of the following appear in the manuscript body:
- Greek letters in non-math context (`τ`, `λ`, `μ`)
- Em-dashes (`—`), en-dashes (`–`), curly quotes (`""`)
- Any non-ASCII glyph (`±`, `×`, `•`)
- Author names with diacritics (`ñ`, `é`, `ø`)
- IPA, CJK, RTL, Cyrillic

Otherwise pdflatex compiles slightly faster and yields smaller PDFs.

Minimal xelatex preamble snippet for Times-style typeface:

```latex
\documentclass[journal,10pt]{IEEEtran}
\usepackage{cite}
\usepackage{amsmath,amssymb,amsfonts}
\usepackage{graphicx}
\usepackage{textcomp}
\usepackage{xcolor}
\usepackage{array}
\usepackage{booktabs}
\usepackage[hidelinks]{hyperref}
\usepackage{fontspec}
\usepackage{unicode-math}
\setmainfont{Times New Roman}
\setmathfont{Latin Modern Math}
```

---

## Two-Column Float Rules

This is the single most common source of camera-ready layout problems.

### Rule 1: Default to single-column floats

Use `figure` and `table` (no star). They occupy one column. The text flows
around them in the other column. This is what the journal expects.

```latex
\begin{figure}[!t]
  \centering
  \includegraphics[width=\columnwidth,keepaspectratio]{system-overview.png}
  \caption{System overview.}
  \label{fig:overview}
\end{figure}
```

Note `\columnwidth` (≈ 3.5 in), not `\textwidth`.

### Rule 2: Use full-width floats only when content genuinely does not fit

`figure*` and `table*` span both columns. Reserve them for:
- Wide block diagrams with ≥ 4 horizontal stages
- Tables with > 5 columns or with a column whose text routinely exceeds 25 characters
- Comparison matrices with ≥ 5 method rows

Wrong default:
```latex
% Pulling a small 3-column table into table* is wasteful and ugly
\begin{table*}[!t] ... \end{table*}
```

Right default:
```latex
\begin{table}[!t] ... \end{table}     % start here
\begin{table*}[!t] ... \end{table*}   % only if it overflows the column
```

### Rule 3: `longtable` is incompatible with two-column journal layout

`longtable` cannot float inside a two-column body. If pandoc emits a
`longtable`, convert it to a fixed-size `tabular` inside `table` (or `table*`
when wide). Keep the body short enough to fit one float; if it spills across
multiple pages, refactor the data.

### Rule 4: Place at column / page top, not inline

Use `[!t]` placement. Do not use `[H]` (`float` package's "here") inside a
journal layout — it forces inline placement and breaks two-column balance.
Inline TikZ diagrams should be wrapped in `figure[!t]` like any other figure.

---

## Tables

### Single-column table template

```latex
\begin{table}[!t]
  \renewcommand{\arraystretch}{1.1}
  \setlength{\tabcolsep}{2pt}
  \caption{Comparison of Methods on Benchmark X}
  \label{tab:methods}
  \centering
  \scriptsize
  \begin{tabular}{@{}>{\raggedright\arraybackslash}p{0.22\columnwidth}
                     >{\raggedright\arraybackslash}p{0.30\columnwidth}
                     >{\raggedleft\arraybackslash}p{0.18\columnwidth}
                     >{\raggedleft\arraybackslash}p{0.18\columnwidth}@{}}
    \toprule
    Method & Configuration & Metric A & Metric B \\
    \midrule
    Ours & default + tweak X & 0.812 & 0.745 \\
    Baseline-1 & paper-reported & 0.643 & 0.589 \\
    Baseline-2 & re-implemented & 0.701 & 0.612 \\
    \bottomrule
  \end{tabular}
\end{table}
```

Key points:
- `\scriptsize` because column width is narrow; without it, content wraps to 3+ lines
- `\setlength{\tabcolsep}{2pt}` reduces inter-column padding from default 6pt
- `p{}` columns wrap text instead of overflowing; widths sum to ~0.88 of `\columnwidth` to leave breathing room
- `\raggedright` for label columns, `\raggedleft` for numeric columns
- IEEEtran auto-prepends the label — do **not** write `TABLE I` inside `\caption`

### Full-width table

Switch `table` → `table*` and replace `\columnwidth` with `\textwidth`. Bump
`\scriptsize` to `\footnotesize` because the row is wider.

### Caption typography

IEEE captions are uppercase Roman headers (`TABLE I`) followed by a
sentence-case title underneath. IEEEtran handles this automatically when you
write `\caption{Comparison ...}` — never include "TABLE N" in the caption text.

---

## Figures

### Single-column figure (default)

```latex
\begin{figure}[!t]
  \centering
  \includegraphics[width=\columnwidth,keepaspectratio]{pipeline.png}
  \caption{Five-stage pipeline. Inputs flow left-to-right through the encoder, fusion head, and predictor.}
  \label{fig:pipeline}
\end{figure}
```

### Full-width figure

```latex
\begin{figure*}[!t]
  \centering
  \includegraphics[width=\textwidth,keepaspectratio]{architecture-wide.png}
  \caption{Full system architecture across seven processing stages.}
  \label{fig:arch}
\end{figure*}
```

### Sub-figures

```latex
\usepackage{subcaption}
...
\begin{figure}[!t]
  \centering
  \begin{subfigure}{0.48\columnwidth}
    \includegraphics[width=\linewidth]{a.png}
    \caption{Phase A.}\label{fig:a}
  \end{subfigure}\hfill
  \begin{subfigure}{0.48\columnwidth}
    \includegraphics[width=\linewidth]{b.png}
    \caption{Phase B.}\label{fig:b}
  \end{subfigure}
  \caption{Two phases of the experiment.}
  \label{fig:phases}
\end{figure}
```

### Caption typography

IEEEtran auto-prepends `Fig. N.`. Caption text is sentence-case starting with a capital. Do **not** write `Fig. 5.` inside `\caption{...}` — you will get `Fig. 5. Fig. 5. ...`.

---

## Bibliography

IEEEtran ships with a built-in bibliography style. Two viable paths:

### Path A: Hand-written `thebibliography`

```latex
\begin{thebibliography}{99}
\bibitem{ref1} A.~Author and B.~Author, ``Paper title,'' \emph{IEEE Trans. X}, vol.~10, no.~2, pp.~100--110, 2024, doi: 10.1109/EXAMPLE.2024.123.
\bibitem{ref2} C.~Author, ``Conference paper,'' in \emph{Proc. ABC Conf.}, 2023, pp.~1--8.
\end{thebibliography}
```

Use this when you have a small, fixed reference list (≤ 20 entries) and want full control.

### Path B: BibTeX with IEEEtran style

```latex
\bibliographystyle{IEEEtran}
\bibliography{refs}
```

Run `bibtex paper` between two `xelatex` passes. Use this when references are
managed in a `.bib` file (e.g. exported from Zotero / Mendeley).

### IEEE reference format requirements

- Authors: `F.~M.~Last` (initial-period-tilde-initial pattern, never spelled-out first names)
- Journal name: italic, abbreviated per IEEE Reference Guide
- Volume / number / page range: `vol.~10, no.~2, pp.~100--110`
- Month and year (when available): `Jun.~2024`
- DOI as final field: `doi: 10.1109/...`
- Conference: `in \emph{Proc. ...}`, year, page range
- Use `--` for page ranges (en-dash), not single hyphen
- ASCII straight quotes in `.tex` source render as smart quotes only if `\usepackage{csquotes}` or curly Unicode quotes are explicitly written

---

## hyperref Without Colored Boxes

Default hyperref draws colored frames around `\cite`, `\ref`, and URL hyperlinks.
This violates the IEEE camera-ready requirement that links must not be visually
distinguishable in the printed PDF.

```latex
\usepackage[hidelinks]{hyperref}
```

`hidelinks` removes both color and frame on every link. Equivalent long form:

```latex
\hypersetup{colorlinks=false,pdfborder={0 0 0}}
```

Verify by rendering the PDF and inspecting any `[1]` citation: the bracketed
number must be the same color as body text, with no surrounding rectangle.

---

## Markdown to IEEEtran via Pandoc

Pandoc emits generic LaTeX. It does not produce IEEEtran-shaped output by
itself. The two-stage pattern:

```bash
# Stage 1: Markdown -> intermediate LaTeX body
pandoc paper.md -o body.tex \
  --from='markdown+tex_math_dollars+pipe_tables+yaml_metadata_block' \
  --to=latex --wrap=preserve

# Stage 2: post-process body.tex into IEEEtran-shaped paper.tex
python build_ieee_latex.py
```

The post-processor (sample template available; adapt per project):
1. Reads the first `\section` as the manuscript title; re-emits as `\title{...}`
2. Captures `\textbf{Abstract}---...` and `\textbf{Index Terms}---...` blocks; re-emits as `\begin{abstract}...\end{abstract}` and `\begin{IEEEkeywords}...\end{IEEEkeywords}`
3. Promotes pandoc heading levels by one (level-2 `\subsection` → IEEEtran `\section`, level-3 `\subsubsection` → `\subsection`); strips numeric prefixes (`I.`, `A.`) that the source kept for visual reference
4. Converts pandoc `longtable` into bounded `tabular` with explicit `p{}` widths
5. Converts pandoc `\textbf{Fig. N.} caption` paragraphs into `\caption{...}` inside the preceding `figure` environment (and removes the now-orphan caption paragraph)
6. Rewrites pandoc citation form `{[}N{]}` into `\cite{refN}` keys

This pattern preserves single-source authoring (Markdown) while producing
camera-ready IEEEtran output. Edit the Markdown for content; rerun the
pipeline for PDF; pandoc + a docx reference template for the editable DOCX.

---

## Compile Sequence

xelatex needs three passes for stable cross-references and TOC, four if you
clear `.aux` between runs:

```bash
xelatex -interaction=nonstopmode paper.tex
xelatex -interaction=nonstopmode paper.tex
xelatex -interaction=nonstopmode paper.tex
```

If switching engines or modifying the bibliography, delete `paper.aux paper.log paper.out paper.toc paper.bbl` first. The IEEEtran built-in bibliography does not need `bibtex`; the BibTeX path needs:

```bash
xelatex paper.tex
bibtex  paper
xelatex paper.tex
xelatex paper.tex
```

Inspect the log for:
- `LaTeX Warning: Citation 'refX' undefined` — bibitem missing or label mismatch
- `Overfull \hbox (... too wide)` — column overflow; tighten table widths or rewrap a long inline `\texttt{...}` token
- `LaTeX Font Warning: Font shape 'TU/ptm/...' undefined` — harmless when fontspec is the active font driver; fontspec serves the actual glyph

---

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `\begin{table*}` for a 3-column 4-row table | Table spans both columns, surrounded by white space, looks lonely | Use `\begin{table}` |
| `\includegraphics[width=\textwidth]` in a `figure` (not `figure*`) | Figure overflows column into the gutter | Use `\columnwidth` for `figure`, `\textwidth` only for `figure*` |
| `[H]` placement inside two-column body | Float forces inline placement, breaks balance | Use `[!t]` |
| `longtable` left untouched after pandoc | `! Package longtable Error: longtable not in 1-column mode` | Convert to `tabular` inside `table` / `table*` |
| `\caption{Fig. 5. Pipeline...}` | Output reads `Fig. 5. Fig. 5. Pipeline...` | Caption text only; let IEEEtran prepend the label |
| Manuscript with `τ` or `—` compiled with pdflatex | `! Package inputenc Error: Unicode character ... not set up` | Switch to xelatex + `\usepackage{fontspec}` |
| `\usepackage{geometry}` overriding margins | IEEE production rejects on layout audit | Remove; trust IEEEtran defaults |
| `hyperref` without `hidelinks` | Colored boxes around every `[N]` citation | `\usepackage[hidelinks]{hyperref}` |
| Including `TABLE I` in `\caption{}` text | Output reads `TABLE I TABLE I Comparison...` | Caption text only |
| Author block with full first name "John Michael Smith" | IEEE format requires `J.~M.~Smith` | Use initials with tilde for non-breaking space |

---

## Self-Check Before Submission

Render the PDF and walk every page once:

1. **Page 1**: Title centered, authors centered below, abstract italic single-column-equivalent block, Index Terms italic, then `I. Introduction` heading marks the start of two-column body.
2. **Every figure**: Caption reads `Fig. N. <text>` exactly once. No green / red / blue boxes around any reference or URL. Figure does not exceed its column except `figure*` floats.
3. **Every table**: Caption reads `TABLE N` then sentence-case title on next line. No column overflow into the gutter or right margin. Numeric columns right-aligned.
4. **Citations**: Every `[N]` resolves to a `\bibitem` (no `[?]` artifacts). Reference list at end is in IEEE numeric order, formatted with abbreviated journal names and DOI.
5. **Running header**: `IEEE TRANSACTIONS ON ...` appears top of every page from page 2 onward; page numbers in expected position.
6. **Page count**: Within journal limit (typically 12–14 for Transactions; 6–8 for letters/correspondence).
7. **Overfull warnings**: Open `paper.log`; any `Overfull \hbox > 5pt` in body text is visible; tighten table widths or break long inline tokens. Sub-5pt overfull is generally acceptable.
8. **Anonymity** (double-blind submission): Author block reads `Anonymous Author`, no acknowledgements, no GitHub URLs revealing identity, all `\cite{self}` self-references paraphrased as third-person.

When all eight checks pass, the manuscript is camera-ready.
