# Common LaTeX Packages Quick Reference

## Essential (include in most documents)

**What this covers:** Fundamental packages that handle character encoding, page layout, and basic document features. These form the foundation of most LaTeX documents.

| Package | Purpose |
|---------|---------|
| `inputenc` | UTF-8 input encoding (`\usepackage[utf8]{inputenc}`) |
| `fontenc` | T1 font encoding (`\usepackage[T1]{fontenc}`) |
| `geometry` | Page margins and dimensions |
| `hyperref` | Clickable links, URLs, cross-references |
| `xcolor` | Color definitions and usage |
| `graphicx` | Image inclusion (`\includegraphics`) |

**Example:** Basic document setup
```latex
\documentclass{article}
\usepackage[utf8]{inputenc}  % UTF-8 input (default in modern TeX)
\usepackage[T1]{fontenc}     % Better font encoding
\usepackage[margin=1in]{geometry}  % Set all margins to 1 inch
\usepackage{xcolor}          % For \textcolor, \colorbox
\usepackage{graphicx}        % For \includegraphics
\usepackage{hyperref}        % LOAD LAST (almost always)

\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    urlcolor=cyan
}
```

**Common pitfalls:**
- `hyperref` should be loaded last (with few exceptions like `cleveref`)
- `inputenc` is not needed with XeLaTeX/LuaLaTeX
- `geometry` package should come before `hyperref`
- Color names require `\usepackage[dvipsnames]{xcolor}` for extended names

## Typography

**What this covers:** Fine-tuning text appearance, spacing, fonts, and document layout. These packages control how your text looks on the page.

| Package | Purpose |
|---------|---------|
| `titlesec` | Customize section heading styles |
| `fancyhdr` | Custom headers and footers |
| `parskip` | Paragraph spacing instead of indentation |
| `microtype` | Improved text justification and kerning |
| `lmodern` | Latin Modern fonts (scalable) |
| `setspace` | Line spacing (`\singlespacing`, `\onehalfspacing`, `\doublespacing`) |

**Example:** Custom headers with chapter/section names
```latex
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}  % Clear all headers/footers
\fancyhead[L]{\leftmark}   % Chapter name on left
\fancyhead[R]{\thepage}    % Page number on right
\renewcommand{\headrulewidth}{0.4pt}
```

**Example:** Professional typography setup
```latex
\usepackage{microtype}     % Improves spacing (load early)
\usepackage{lmodern}       % Better fonts than Computer Modern
\usepackage[onehalfspacing]{setspace}  % 1.5 line spacing
\usepackage{parskip}       % Space between paragraphs instead of indent
```

**Common pitfalls:**
- `microtype` should be loaded early, before fonts are set
- `parskip` can conflict with `memoir` and KOMA-Script classes
- `fancyhdr` requires `\pagestyle{fancy}` to activate
- `titlesec` conflicts with KOMA-Script and `memoir` (they have built-in alternatives)

## Tables

**What this covers:** Traditional table formatting with tabular environments. For modern alternatives, see "Modern Matrix/Table Packages" below.

| Package | Purpose |
|---------|---------|
| `tabularx` | Tables with auto-width `X` columns |
| `array` | Extended column definitions (`>{...}`, `p{width}`) |
| `booktabs` | Professional rules: `\toprule`, `\midrule`, `\bottomrule` |
| `colortbl` | `\rowcolor`, `\cellcolor`, `\columncolor` |
| `multirow` | `\multirow{rows}{width}{text}` |
| `longtable` | Tables spanning multiple pages |

**Example:** Professional table with `booktabs`
```latex
\usepackage{booktabs}
\usepackage{tabularx}

\begin{table}[h]
\centering
\begin{tabularx}{0.8\textwidth}{lXr}
\toprule
\textbf{Item} & \textbf{Description} & \textbf{Value} \\
\midrule
A & Long text that wraps automatically & 123 \\
B & Another row & 456 \\
\bottomrule
\end{tabularx}
\caption{A well-formatted table}
\end{table}
```

**Common pitfalls:**
- Never use vertical lines with `booktabs` (looks unprofessional)
- `\hline` conflicts with `booktabs` spacing — use `\midrule` instead
- `tabularx` requires total width specification (e.g., `\textwidth`)
- `longtable` cannot be used inside a `table` float
- Load order matters: `array` before `tabularx`, both before `booktabs`

## Images and Drawing

**What this covers:** Including external images and creating vector graphics programmatically within LaTeX.

| Package | Purpose |
|---------|---------|
| `graphicx` | `\includegraphics[width=..]{file}` |
| `tikz` | Programmatic vector graphics, diagrams |
| `wrapfig` | Wrap text around figures |
| `subcaption` | Subfigures within a figure |
| `float` | Force figure placement with `[H]` |
| `caption` | Customize figure/table captions |

**Example:** Responsive image sizing
```latex
\usepackage{graphicx}

% Best practice: scale relative to text width
\includegraphics[width=0.8\textwidth]{diagram.pdf}

% Maintain aspect ratio with max dimensions
\includegraphics[width=0.8\textwidth,height=0.6\textheight,keepaspectratio]{photo.jpg}
```

**Example:** Side-by-side subfigures
```latex
\usepackage{subcaption}

\begin{figure}[htbp]
    \centering
    \begin{subfigure}{0.45\textwidth}
        \includegraphics[width=\textwidth]{img1.png}
        \caption{First subfigure}
        \label{fig:sub1}
    \end{subfigure}
    \hfill
    \begin{subfigure}{0.45\textwidth}
        \includegraphics[width=\textwidth]{img2.png}
        \caption{Second subfigure}
        \label{fig:sub2}
    \end{subfigure}
    \caption{Combined caption}
\end{figure}
```

**Common pitfalls:**
- File extensions: prefer PDF/PNG over JPG for diagrams (lossless)
- `float` package's `[H]` often causes bad page breaks; use `[htbp]` instead
- `subcaption` replaces older `subfig` and `subfigure` packages
- TikZ can be slow to compile; externalize complex diagrams with `\tikzexternalize`

## Charts and Graphs

**What this covers:** Data visualization with publication-quality plots, charts, and diagrams.

| Package | Purpose |
|---------|---------|
| `pgfplots` | Line charts, bar charts, scatter plots, histograms |
| `pgfplotstable` | Read and plot from CSV/TSV data files |
| `tikz` | Flowcharts, timelines, custom diagrams |

**Example:** Simple line plot with pgfplots
```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}  % Use latest compatibility mode

\begin{tikzpicture}
\begin{axis}[
    xlabel={Time (s)},
    ylabel={Position (m)},
    legend pos=north west
]
\addplot[blue,thick] coordinates {
    (0,0) (1,2) (2,4) (3,8) (4,16)
};
\legend{Exponential growth}
\end{axis}
\end{tikzpicture}
```

**Example:** Reading data from CSV
```latex
\usepackage{pgfplots,pgfplotstable}
\pgfplotsset{compat=1.18}

\begin{tikzpicture}
\begin{axis}[xlabel=X, ylabel=Y]
\addplot table[x=col1, y=col2, col sep=comma] {data.csv};
\end{axis}
\end{tikzpicture}
```

**Common pitfalls:**
- Always set `\pgfplotsset{compat=1.18}` to use modern syntax
- CSV files must be in same directory or use absolute paths
- Large datasets can slow compilation significantly
- Axis scaling issues: specify `xmin`, `xmax`, `ymin`, `ymax` explicitly if needed

## Lists

**What this covers:** Customizing bulleted, numbered, and description lists.

| Package | Purpose |
|---------|---------|
| `enumitem` | Customize itemize/enumerate spacing, labels, nesting |

**Example:** Compact lists with custom labels
```latex
\usepackage{enumitem}

% Globally compact lists
\setlist{noitemsep, topsep=0pt}

% Custom enumerate labels
\begin{enumerate}[label=(\roman*)]
    \item First item
    \item Second item
\end{enumerate}

% Inline lists
Some features: \begin{enumerate*}[label=\arabic*)]
    \item compact, \item inline, \item enumeration
\end{enumerate*} in a sentence.
```

**Common pitfalls:**
- Must use `\setlist` in preamble, not inside document
- Conflicts with beamer class (use beamer's built-in list customization)
- Inline lists require starred version: `\begin{enumerate*}`

## Math

**What this covers:** Mathematical typesetting, symbols, and theorem environments. For Unicode math, see "Modern Font Handling" below.

| Package | Purpose |
|---------|---------|
| `amsmath` | Advanced math environments (`align`, `gather`, `cases`) |
| `amssymb` | Additional math symbols (`\mathbb`, `\therefore`) |
| `amsthm` | Theorem environments (`\newtheorem`) |
| `mathtools` | Extensions to amsmath (paired delimiters, cases) |
| `mathrsfs` | Script math font (`\mathscr`) |
| `bbm` | Blackboard bold indicator (`\mathbbm{1}`) |
| `esint` | Extended surface integrals (`\oiint`) |
| `cancel` | Cancellation marks in equations (`\cancel{x}`) |

**Example:** Aligned equations with numbering
```latex
\usepackage{amsmath}

\begin{align}
    E &= mc^2 \label{eq:einstein} \\
    F &= ma \label{eq:newton}
\end{align}

See equation \eqref{eq:einstein} for relativity.
```

**Example:** Theorem environment
```latex
\usepackage{amsthm}
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}

\begin{theorem}[Pythagorean]
In a right triangle, $a^2 + b^2 = c^2$.
\end{theorem}
```

**Common pitfalls:**
- Load order: `amsmath` before `mathtools`, both before most other math packages
- Never use `$$...$$` (plain TeX); use `\[...\]` or equation environments
- `align` automatically numbers all lines; use `align*` for unnumbered
- `\mathbb` requires `amssymb` or `amsfonts`

## Presentations

**What this covers:** Creating slide presentations with LaTeX.

| Package | Purpose |
|---------|---------|
| `beamer` | Document class for slides/presentations |
| Common themes | `Madrid`, `Berlin`, `CambridgeUS`, `Boadilla`, `Warsaw` |

**Example:** Basic beamer presentation
```latex
\documentclass{beamer}
\usetheme{Madrid}
\usecolortheme{beaver}

\title{My Presentation}
\author{Author Name}
\date{\today}

\begin{document}

\frame{\titlepage}

\begin{frame}
\frametitle{First Slide}
Content here with \pause incremental reveals.
\end{frame}

\end{document}
```

**Common pitfalls:**
- Beamer is a document class, not a package (use `\documentclass{beamer}`)
- Many packages conflict with beamer (especially enumitem, parskip)
- Fragile frames need `\begin{frame}[fragile]` for verbatim content
- Use `\pause` for incremental reveals, not overlays unless needed

## Bibliography

**What this covers:** Managing citations and references. Use with BibTeX or Biber backend.

| Package | Purpose |
|---------|---------|
| `natbib` | Author-year citations (`\citet`, `\citep`) |
| `biblatex` | Modern bibliography management (more flexible than natbib) |

**Example:** BibLaTeX with Biber (recommended)
```latex
\usepackage[backend=biber, style=authoryear]{biblatex}
\addbibresource{references.bib}

\begin{document}
According to \textcite{author2020}, the results show...
Multiple sources \parencite{author2020,smith2019}.

\printbibliography
\end{document}

% Compile: pdflatex -> biber -> pdflatex -> pdflatex
```

**Example:** NatBib (traditional)
```latex
\usepackage[numbers]{natbib}

\begin{document}
\citet{author2020} found that... \citep{smith2019}.

\bibliographystyle{plainnat}
\bibliography{references}
\end{document}

% Compile: pdflatex -> bibtex -> pdflatex -> pdflatex
```

**Common pitfalls:**
- `biblatex` and `natbib` are mutually exclusive (never load both)
- Compile sequence matters: multiple passes required for references
- `biblatex` requires Biber backend for full features (not BibTeX)
- `.bib` file encoding must match document encoding

## Modern Font Handling

**What this covers:** Engine-agnostic font selection and Unicode support for modern TeX engines (XeLaTeX/LuaLaTeX).

| Package | Purpose |
|---------|---------|
| `iftex` | Engine detection (`\ifPDFTeX`, `\ifXeTeX`, `\ifLuaTeX`) for engine-agnostic preambles |
| `fontspec` | System font access (XeLaTeX/LuaLaTeX only) |
| `unicode-math` | Unicode math fonts (XeLaTeX/LuaLaTeX) |
| `fontawesome5` | Icon glyphs (phone, email, LinkedIn, GitHub, etc.) |

**Example:** Engine-agnostic preamble
```latex
\usepackage{iftex}
\ifPDFTeX
  \usepackage[utf8]{inputenc}
  \usepackage[T1]{fontenc}
  \usepackage{lmodern}
\else
  \usepackage{fontspec}
  \setmainfont{Linux Libertine O}
  \setsansfont{Linux Biolinum O}
  \setmonofont{Inconsolata}
\fi
```

**Example:** System fonts with fontspec
```latex
% XeLaTeX or LuaLaTeX only
\usepackage{fontspec}
\setmainfont{Helvetica Neue}[
    UprightFont = *,
    BoldFont = * Bold,
    ItalicFont = * Italic
]
```

**Example:** Font Awesome icons
```latex
\usepackage{fontawesome5}

\faPhone\ +1-234-567-8900 \\
\faEnvelope\ email@example.com \\
\faGithub\ github.com/user \\
\faLinkedin\ linkedin.com/in/user
```

**Common pitfalls:**
- `fontspec` only works with XeLaTeX/LuaLaTeX, not pdfLaTeX
- System fonts must be installed and accessible to the engine
- `unicode-math` must load after `fontspec`
- Font names are case-sensitive and OS-dependent
- pdfLaTeX users should stick with `inputenc` and `fontenc`

**Version notes:**
- iftex replaces older `ifxetex`, `ifluatex`, `ifpdf` packages
- fontspec requires XeTeX ≥0.9999 or LuaTeX ≥0.80

## Modern Matrix/Table Packages

**What this covers:** Next-generation table and matrix packages with enhanced features beyond traditional tabular.

| Package | Purpose |
|---------|---------|
| `nicematrix` | Enhanced matrices with color, borders, named cells |
| `tabularray` | Modern table package (replacement for tabular/tabularx) |
| `nicetabular` | From nicematrix, for enhanced tables |

**Example:** nicematrix with colored cells
```latex
\usepackage{nicematrix}

$\begin{pNiceMatrix}[first-row,first-col]
    & C_1 & C_2 & C_3 \\
R_1 & \Block[fill=red!15]{2-2}{A} & & 0 \\
R_2 & & & 0 \\
R_3 & 0 & 0 & B \\
\end{pNiceMatrix}$
```

**Example:** tabularray modern table
```latex
\usepackage{tabularray}

\begin{tblr}{
  colspec = {lXr},
  hlines, vlines,
  row{1} = {bg=azure8, font=\bfseries}
}
Item & Description & Value \\
A & Long text that wraps & 123 \\
B & Another row & 456 \\
\end{tblr}
```

**Common pitfalls:**
- `nicematrix` requires TikZ as dependency
- `tabularray` syntax differs from traditional tabular
- Both packages are relatively new (2020+)
- Compile twice for proper cell positioning

**Version notes:**
- tabularray requires LaTeX 2020-10-01 or newer
- nicematrix works with all major engines

## Code Listing Packages

**What this covers:** Syntax-highlighted code blocks in documents.

| Package | Purpose |
|---------|---------|
| `listings` | Basic code highlighting (no external deps) |
| `minted` | Superior highlighting via Pygments (requires -shell-escape) |
| `tcolorbox` with `listings` | Code in colored boxes |

**Example:** listings basic usage
```latex
\usepackage{listings}
\usepackage{xcolor}

\lstset{
  language=Python,
  basicstyle=\ttfamily\small,
  keywordstyle=\color{blue},
  commentstyle=\color{gray},
  stringstyle=\color{red},
  numbers=left,
  frame=single
}

\begin{lstlisting}
def hello():
    print("Hello, world!")
\end{lstlisting}
```

**Example:** minted with Pygments
```latex
\usepackage{minted}

\begin{minted}[linenos, bgcolor=lightgray]{python}
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
\end{minted}

% Compile with: pdflatex -shell-escape document.tex
```

**Example:** tcolorbox with listings
```latex
\usepackage{tcolorbox}
\tcbuselibrary{listings, skins}

\begin{tcblisting}{
  colback=blue!5,
  colframe=blue!75!black,
  listing only,
  title=Python Code
}
def greet(name):
    return f"Hello, {name}!"
\end{tcblisting}
```

**Common pitfalls:**
- `minted` requires Python Pygments installed: `pip install Pygments`
- Must compile with `-shell-escape` flag for minted (security risk)
- `listings` has limited language support compared to minted
- Verbatim code in `listings` requires `\lstinline` not `\verb`

**Version notes:**
- minted 2.x changed syntax from 1.x (check docs if using old code)
- Pygments must be in system PATH

## Document Structure

**What this covers:** Cross-references, bookmarks, glossaries, and navigation aids.

| Package | Purpose |
|---------|---------|
| `bookmark` | Enhanced PDF bookmarks (better than hyperref alone) |
| `cleveref` | Smart cross-references (`\cref{fig:x}` → "Figure 1") |
| `glossaries` | Acronyms and glossary management |
| `makeidx` | Index generation |

**Example:** cleveref smart references
```latex
\usepackage{hyperref}  % Load hyperref first
\usepackage{cleveref}  % Then cleveref

\begin{figure}
  \includegraphics{plot.pdf}
  \caption{Results}
  \label{fig:results}
\end{figure}

See \cref{fig:results} for details.  % Outputs: "Figure 1"
\Cref{fig:results} shows...          % Outputs: "Figure 1" (capitalized)
```

**Example:** glossaries for acronyms
```latex
\usepackage{glossaries}
\makeglossaries

\newacronym{nasa}{NASA}{National Aeronautics and Space Administration}

\begin{document}
First use: \gls{nasa}   % Outputs: National Aeronautics... (NASA)
Later use: \gls{nasa}   % Outputs: NASA

\printglossary[type=\acronymtype]
\end{document}

% Compile: pdflatex -> makeglossaries -> pdflatex
```

**Example:** Index generation
```latex
\usepackage{makeidx}
\makeindex

\begin{document}
Important term\index{term} here.
Another concept\index{concept!subconcept}.

\printindex
\end{document}

% Compile: pdflatex -> makeindex -> pdflatex
```

**Common pitfalls:**
- `cleveref` must load after `hyperref` and `amsmath`
- `glossaries` requires external tool: `makeglossaries document`
- Use `glossaries-extra` for more features
- `bookmark` should load after `hyperref`

**Version notes:**
- cleveref requires ntheorem package for theorem support

## Accessibility & Compliance

**What this covers:** Making PDFs accessible for screen readers and archival compliance.

| Package | Purpose |
|---------|---------|
| `pdfx` | PDF/A compliance for archival |
| `tagpdf` | Tagged PDF for screen readers (experimental) |
| `axessibility` | Math accessibility |

**Example:** PDF/A-2b compliance
```latex
\usepackage[a-2b]{pdfx}
% Requires .xmpdata file with metadata

\begin{document}
Content here...
\end{document}
```

**Example:** Tagged PDF (experimental)
```latex
\DocumentMetadata{testphase=phase-III}
\documentclass{article}
\usepackage{tagpdf}

\tagpdfsetup{activate-all}

\begin{document}
Tagged content for accessibility...
\end{document}
```

**Common pitfalls:**
- `pdfx` requires a `.xmpdata` file with metadata
- `tagpdf` is experimental and syntax changes frequently
- PDF/A prohibits some PDF features (transparency, encryption)
- Accessibility is an active development area in LaTeX

**Version notes:**
- tagpdf requires LaTeX 2023-06-01 or newer
- pdfx incompatible with some packages (check docs)

## Science & Engineering

**What this covers:** Specialized notation for scientific and technical fields.

| Package | Purpose |
|---------|---------|
| `siunitx` | SI units with uncertainties (`\qty{9.81}{m/s^2}`) |
| `mhchem` | Chemical formulas (`\ce{H2O}`) |
| `circuitikz` | Circuit diagrams |
| `tikz-feynman` | Feynman diagrams |

**Example:** siunitx for units and numbers
```latex
\usepackage{siunitx}

\qty{3.14159}{\meter\per\second}
\qty{6.022e23}{\per\mole}
\qty{25.3(2)}{\celsius}  % With uncertainty
\numrange{10}{20}
\ang{45}  % Angle: 45°
```

**Example:** mhchem for chemistry
```latex
\usepackage{mhchem}

\ce{H2O}                    % Water
\ce{CO2 + H2O -> H2CO3}     % Reaction
\ce{^{227}_{90}Th+}         % Isotope notation
\ce{A <=> B}                % Equilibrium
```

**Example:** circuitikz for circuits
```latex
\usepackage{circuitikz}

\begin{circuitikz}
\draw (0,0) to[battery, l=$V$] (0,2)
      to[R, l=$R$] (2,2)
      to[C, l=$C$] (2,0)
      -- (0,0);
\end{circuitikz}
```

**Common pitfalls:**
- siunitx v3 syntax differs from v2 (`\SI` → `\qty`)
- circuitikz uses TikZ syntax (requires TikZ knowledge)
- tikz-feynman requires LuaLaTeX for automatic layout
- mhchem conflicts with some math packages

**Version notes:**
- siunitx v3 (2021+): use `\qty`, `\unit`, `\num` not `\SI`
- tikz-feynman requires LuaTeX for graph layout

## Interactive / Dynamic Content

**What this covers:** Conditional compilation, data-driven documents, and interactive PDF features.

| Package | Purpose |
|---------|---------|
| `hyperref` (forms) | Fillable PDF form fields: `\TextField`, `\CheckBox`, `\ChoiceMenu`, `\PushButton` |
| `etoolbox` | Boolean toggles for conditional content (`\newtoggle`, `\iftoggle`) |
| `ifthen` | Conditional logic (`\ifthenelse`, `\equal`, `\boolean`) |
| `comment` | Block-level conditional inclusion/exclusion (`\includecomment`, `\excludecomment`) |
| `xkeyval` | Key-value option parsing for document configuration |
| `draftwatermark` | Conditional DRAFT/CONFIDENTIAL watermarks |
| `lineno` | Line numbering for drafts and review copies |
| `datatool` | Read CSV/databases directly in LaTeX (`\DTLloaddb`, `\DTLforeach`) |
| `csvsimple` | Simpler CSV processing (`\csvreader`, `\csvautotabular`) |

**Example:** Conditional content with etoolbox
```latex
\usepackage{etoolbox}

\newtoggle{showsolutions}
\toggletrue{showsolutions}  % or \togglefalse

\begin{document}
Problem: What is 2+2?

\iftoggle{showsolutions}{
    \textbf{Solution:} 4
}{}
\end{document}
```

**Example:** CSV data to table
```latex
\usepackage{csvsimple}

\csvautotabular{data.csv}  % Automatic table

% Or custom formatting:
\csvreader[head to column names]{data.csv}{}{
    \name: \score points
}
```

**Example:** Fillable PDF form
```latex
\usepackage{hyperref}

\begin{Form}
Name: \TextField[name=fullname, width=5cm]{}

\CheckBox[name=agree]{I agree to terms}

\PushButton[name=submit]{Submit}
\end{Form}
```

**Common pitfalls:**
- PDF forms only work in Adobe Reader, not all PDF viewers
- `datatool` is slow for large CSV files (use csvsimple instead)
- `comment` package can break with verbatim content inside
- Line numbers from `lineno` may conflict with equation numbering

## Version Control / Diffing

**What this covers:** Generating change-marked PDFs showing differences between document versions.

| Tool | Purpose |
|---------|---------|
| `latexdiff` | Generate change-tracked LaTeX between two `.tex` files |
| `latexdiff-vc` | Git-aware variant: diff against commits, branches, tags |
| `latexrevise` | Accept/reject changes from latexdiff output |

**Example:** Basic latexdiff usage
```bash
# Compare two files
latexdiff old.tex new.tex > diff.tex
pdflatex diff.tex

# Result: PDF with deletions in red strikethrough, additions in blue
```

**Example:** Git integration
```bash
# Compare current file against previous commit
latexdiff-vc -r HEAD~1 document.tex

# Compare against specific commit
latexdiff-vc -r abc123 document.tex

# Compare between two commits
latexdiff-vc -r abc123 -r def456 document.tex
```

**Common pitfalls:**
- latexdiff can fail on complex macros or environments
- Use `--flatten` flag for multi-file documents with `\input`
- Math mode changes may not display correctly
- Large documents may produce very slow-compiling diffs

## Legal / Long Documents

**What this covers:** Formatting for legal briefs, academic papers, and long-form professional documents.

| Package | Purpose |
|---------|---------|
| `setspace` | Double/1.5 spacing for legal/academic docs |
| `footmisc` | Footnote customization |
| `lineno` | Line numbering (for legal documents, drafts) |
| `multicol` | Multi-column layouts |

**Example:** Legal document formatting
```latex
\usepackage[doublespacing]{setspace}
\usepackage[left]{lineno}
\linenumbers

\usepackage[bottom]{footmisc}  % Footnotes at page bottom

\begin{document}
\pagenumbering{roman}  % i, ii, iii for front matter
\tableofcontents

\clearpage
\pagenumbering{arabic}  % 1, 2, 3 for main content

Content with line numbers and double spacing...
\end{document}
```

**Example:** Two-column layout
```latex
\usepackage{multicol}

\begin{multicols}{2}
Text flows across two columns automatically.
Column breaks happen naturally.
\end{multicols}
```

**Common pitfalls:**
- Line numbers from `lineno` may interfere with margin notes
- `multicol` doesn't work with floats (figures/tables) by default
- Double spacing affects equations unless you use `\begin{singlespace}`
- Footnote placement can be inconsistent with floats

## Special Characters
- `%` → `\%`
- `$` → `\$`
- `&` → `\&`
- `#` → `\#`
- `_` → `\_`
- `{` → `\{`
- `}` → `\}`
- `~` → `\textasciitilde`
- `^` → `\textasciicircum`
- `\` → `\textbackslash`
- `--` → en-dash (ranges: 2019--2025)
- `---` → em-dash (parenthetical)
- `§` → `\S` (section symbol)
- `¶` → `\P` (paragraph symbol)
- `©` → `\copyright`
- `®` → `\textregistered`
- `™` → `\texttrademark`
