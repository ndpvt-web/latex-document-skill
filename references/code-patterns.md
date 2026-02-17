# LaTeX Code Patterns Quick Reference

Ready-to-use LaTeX code snippets for common elements. Load this file when you need specific LaTeX patterns.

## Quick Table

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

## Quick Chart (pgfplots)

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

## Quick Flowchart (TikZ)

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

## Quick Bibliography (BibTeX)

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

The compile script auto-detects `\bibliography{}` and runs bibtex. For biblatex, use `\addbibresource{}` instead (auto-detected, runs biber). See `assets/templates/references.bib` for example entries. Full guide: [bibliography-guide.md](bibliography-guide.md).

## Quick Watermark

```latex
% Text watermark (DRAFT, CONFIDENTIAL)
\usepackage{draftwatermark}
\SetWatermarkText{DRAFT}
\SetWatermarkScale{1.5}
\SetWatermarkColor[gray]{0.85}
```

For logo watermarks (`eso-pic`), header logos (`fancyhdr`), first-page-only watermarks, and combined text+logo, see [advanced-features.md](advanced-features.md).

## Quick Landscape Page

```latex
\usepackage{pdflscape}  % or: lscape (for print-rotated)

% Normal portrait content...
\begin{landscape}
% Wide table or chart here -- page rotated in PDF viewer
\end{landscape}
% Back to portrait...
```

Use `pdflscape` for on-screen reading (page rotates in PDF viewer). Use `lscape` for print (content rotates on static page).

## Quick Multi-Language

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

For CJK/RTL documents, compile with `xelatex` instead of `pdflatex`. Full guide: [advanced-features.md](advanced-features.md).

## Quick Image

```latex
% External file
\includegraphics[width=0.5\textwidth]{image.png}

% Placeholder circle (when no image available)
\begin{tikzpicture}
  \draw[fill=gray!20] (0,0) circle (1.2cm);
  \node at (0,0) {\small Photo};
\end{tikzpicture}
```

## Quick Mermaid Diagram

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

See [mermaid-diagrams.md](mermaid-diagrams.md) for flowcharts, sequence diagrams, class diagrams, ER diagrams, Gantt charts, and more.

## Quick matplotlib Chart

```bash
# Generate publication-quality chart from JSON data
python3 <skill_path>/scripts/generate_chart.py bar \
    --data '{"x":["Q1","Q2","Q3","Q4"],"y":[120,150,180,210]}' \
    --output chart.png --title "Quarterly Revenue" --ylabel "Revenue ($K)"

# Generate from CSV file
python3 <skill_path>/scripts/generate_chart.py line --csv data.csv --output trend.pdf
```

Supports: bar, line, scatter, pie, heatmap, box, histogram, area, radar. See [python-charts.md](python-charts.md).

## Quick CSV-to-LaTeX Table

```bash
# Convert CSV to LaTeX table code
python3 <skill_path>/scripts/csv_to_latex.py data.csv --caption "Results" --label "tab:results"
python3 <skill_path>/scripts/csv_to_latex.py data.csv --style booktabs --alternating-rows --output table.tex
```

Supports: booktabs, grid, simple, plain styles. Auto-detects column alignment. See script help for options.

## Quick AI-Generated Image

```bash
python3 <skill_path>/../generate-image/scripts/generate_image.py \
    "Professional diagram of neural network, clean white background, technical illustration" \
    --output ./outputs/figure.png
```

Then include with `\includegraphics[width=0.6\textwidth]{figure.png}` in a `figure` environment. Request "white background, clean, no text" for best results. See [advanced-features.md](advanced-features.md).

## Quick Fillable PDF Form

```latex
\usepackage[colorlinks=true]{hyperref}
% ...
\begin{Form}
    \TextField[name=fullName, width=10cm, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}, charsize=10pt]{Full Name:}\\[8pt]
    \TextField[name=email, width=10cm, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}, charsize=10pt]{Email:}\\[8pt]
    \CheckBox[name=agree, width=12pt, height=12pt]{I agree to terms}\\[8pt]
    \ChoiceMenu[name=dept, combo, width=6cm]{Department:}{Sales, Engineering, Marketing, HR}\\[8pt]
    \TextField[name=comments, width=\textwidth, height=3cm, multiline=true,
               bordercolor=blue, backgroundcolor={0.94 0.96 1.0}]{Comments:}
\end{Form}
```

All form fields MUST be inside `\begin{Form}...\end{Form}`. See `assets/templates/fillable-form.tex` for full example. Full guide: [interactive-features.md](interactive-features.md).

## Quick Conditional Content (Toggles)

```latex
\usepackage{etoolbox}
\newtoggle{showAppendix}
\newtoggle{isDraft}
\toggletrue{showAppendix}
\togglefalse{isDraft}
% Template variables (overridable from command line)
\providecommand{\doctitle}{My Document}
\providecommand{\docauthor}{Author Name}
% ...
\iftoggle{isDraft}{\usepackage{lineno}\linenumbers}{}
% In body:
\iftoggle{showAppendix}{\appendix \section{Appendix} ...}{}
```

See `assets/templates/conditional-document.tex` for a full document with toggles, profiles, and variables. Full guide: [interactive-features.md](interactive-features.md).

## Quick Mail Merge

```bash
# Generate personalized letters from CSV data
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv --output-dir ./outputs \
    --compile-script <skill_path>/scripts/compile_latex.sh
```

Template uses `{{variable}}` placeholders. See `assets/templates/mail-merge-letter.tex`. Full guide: [interactive-features.md](interactive-features.md).

## Quick Version Diff

```bash
# Diff two files and compile to PDF
bash <skill_path>/scripts/latex_diff.sh old.tex new.tex --compile --preview

# Diff against git revision
bash <skill_path>/scripts/latex_diff.sh paper.tex --git-rev HEAD~1 --compile
```

Auto-installs `latexdiff`. Full guide: [interactive-features.md](interactive-features.md).
