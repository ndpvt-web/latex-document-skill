# Advanced LaTeX Features

## Landscape Pages

Mix portrait and landscape pages in a single document. Useful for wide tables, charts, or diagrams.

### Using lscape (static landscape)

```latex
\usepackage{lscape}

% ... normal portrait content ...

\begin{landscape}
\begin{table}[H]
\centering
\caption{Wide comparison table}
\begin{tabular}{lcccccccc}
\toprule
\textbf{Method} & \textbf{M1} & \textbf{M2} & \textbf{M3} & \textbf{M4} & \textbf{M5} & \textbf{M6} & \textbf{M7} & \textbf{M8} \\
\midrule
Approach A & 85.2 & 83.1 & 79.4 & 91.2 & 88.3 & 77.6 & 82.1 & 90.5 \\
\bottomrule
\end{tabular}
\end{table}
\end{landscape}

% ... back to portrait ...
```

### Using pdflscape (rotated in PDF viewer)

```latex
\usepackage{pdflscape}

\begin{landscape}
% Content appears rotated in the PDF viewer for easier on-screen reading
% Print output is identical to lscape
\end{landscape}
```

**When to use which:**
- `lscape`: Content is rotated on the page (good for printing)
- `pdflscape`: Page is rotated in PDF viewer (good for on-screen reading) -- usually preferred

---

## Watermarks

### Text Watermark (DRAFT, CONFIDENTIAL, etc.)

```latex
\usepackage{draftwatermark}

% Simple text watermark
\SetWatermarkText{DRAFT}
\SetWatermarkScale{1.5}
\SetWatermarkColor[gray]{0.85}

% Or: CONFIDENTIAL
\SetWatermarkText{CONFIDENTIAL}
\SetWatermarkScale{1.2}
\SetWatermarkColor[rgb]{0.8, 0, 0}  % red tint
```

### Company Name Watermark

```latex
\usepackage{draftwatermark}

\SetWatermarkText{Acme Corp}
\SetWatermarkScale{1.0}
\SetWatermarkAngle{45}
\SetWatermarkColor[gray]{0.9}
```

### Image/Logo Watermark (Background)

```latex
\usepackage{eso-pic}
\usepackage{graphicx}

% Centered background logo (semi-transparent)
\AddToShipoutPictureBG{%
    \AtPageCenter{%
        \makebox(0,0){%
            \includegraphics[width=0.4\paperwidth,keepaspectratio,opacity=0.08]{company-logo.png}%
        }%
    }%
}
```

### Header Logo (top of every page)

```latex
\usepackage{fancyhdr}
\usepackage{graphicx}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\includegraphics[height=1cm]{company-logo.png}}
\fancyhead[R]{\small Company Name}
\fancyfoot[C]{\thepage}
```

### Watermark on First Page Only

```latex
\usepackage{eso-pic}
\usepackage{graphicx}

\AddToShipoutPictureBG*{% note the * -- first page only
    \AtPageCenter{%
        \makebox(0,0){%
            \includegraphics[width=0.5\paperwidth,opacity=0.1]{logo.png}%
        }%
    }%
}
```

### Combining Text + Logo

```latex
\usepackage{draftwatermark}
\usepackage{fancyhdr}
\usepackage{graphicx}

% Text watermark on all pages
\SetWatermarkText{CONFIDENTIAL}
\SetWatermarkScale{1.2}
\SetWatermarkColor[gray]{0.9}

% Logo in header
\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\includegraphics[height=0.8cm]{logo.png}}
\fancyhead[R]{\small\textcolor{gray}{Internal Document}}
\fancyfoot[C]{\small\thepage}
```

---

## Multi-Language Support

### European Languages (babel)

```latex
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[french]{babel}  % French
% or: \usepackage[german]{babel}
% or: \usepackage[spanish]{babel}
% or: \usepackage[portuguese]{babel}

% Multiple languages (last one is primary):
\usepackage[english,french]{babel}

% Switch languages in document:
\selectlanguage{french}
Ceci est en fran\c{c}ais.
\selectlanguage{english}
This is in English.

% Or use short blocks:
\foreignlanguage{french}{Bonjour le monde}
```

### CJK Languages (Chinese, Japanese, Korean)

**Requires XeLaTeX or LuaLaTeX** instead of pdflatex.

```latex
% For XeLaTeX:
\documentclass[12pt,a4paper]{article}
\usepackage{fontspec}           % System font support
\usepackage{xeCJK}              % CJK support

% Set CJK fonts (use fonts available on your system)
\setCJKmainfont{Noto Serif CJK SC}    % Chinese Simplified
% \setCJKmainfont{Noto Serif CJK TC}  % Chinese Traditional
% \setCJKmainfont{Noto Serif CJK JP}  % Japanese
% \setCJKmainfont{Noto Serif CJK KR}  % Korean

\begin{document}
English text mixed with 中文文本 seamlessly.
\end{document}
```

### Arabic / Hebrew (RTL Languages)

```latex
% Requires XeLaTeX
\documentclass[12pt,a4paper]{article}
\usepackage{fontspec}
\usepackage{polyglossia}

\setmainlanguage{english}
\setotherlanguage{arabic}

\newfontfamily\arabicfont[Script=Arabic]{Amiri}

\begin{document}
English paragraph here.

\begin{arabic}
هذا نص عربي يظهر من اليمين إلى اليسار.
\end{arabic}

Back to English.
\end{document}
```

### Cyrillic (Russian, Ukrainian, etc.)

```latex
% With pdflatex:
\usepackage[utf8]{inputenc}
\usepackage[T2A]{fontenc}       % Cyrillic font encoding
\usepackage[russian,english]{babel}

\begin{document}
English text here.
\selectlanguage{russian}
Русский текст здесь.
\selectlanguage{english}
\end{document}
```

### Multilingual Document Tips

1. **Font coverage**: Ensure your font supports all needed characters. Noto fonts have excellent coverage.
2. **Encoding**: Always use `[utf8]{inputenc}` with pdflatex, or `fontspec` with XeLaTeX.
3. **Hyphenation**: babel/polyglossia load language-specific hyphenation rules.
4. **Date formatting**: babel auto-formats `\today` in the active language.
5. **XeLaTeX compilation**: Replace `pdflatex` with `xelatex` in the compile command. The compile script uses pdflatex by default -- for CJK/RTL, compile manually with `xelatex -interaction=nonstopmode document.tex`.

---

## Code Listings

### Basic Syntax Highlighting

```latex
\usepackage{listings}
\usepackage{xcolor}

\lstdefinestyle{codestyle}{
    backgroundcolor=\color{gray!5},
    commentstyle=\color{green!50!black},
    keywordstyle=\color{blue!70!black}\bfseries,
    stringstyle=\color{red!60!black},
    basicstyle=\ttfamily\small,
    breaklines=true,
    numbers=left,
    numberstyle=\tiny\color{gray},
    frame=single,
    rulecolor=\color{gray!30},
    tabsize=4
}
\lstset{style=codestyle}

\begin{lstlisting}[language=Python, caption={Example function}]
def fibonacci(n):
    """Return the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)
\end{lstlisting}
```

### Inline Code

```latex
Use \lstinline|print("hello")| to output text.
% Or simpler:
Use \texttt{print("hello")} for inline code.
```

### Supported Languages

Common: `Python`, `Java`, `C`, `C++`, `JavaScript`, `HTML`, `SQL`, `R`, `Matlab`, `Ruby`, `Bash`, `Go`, `Rust`, `PHP`, `Haskell`, `Scala`

---

## Algorithms and Pseudocode

### Using algorithm2e

```latex
\usepackage[ruled,lined,linesnumbered]{algorithm2e}

\begin{algorithm}[H]
\SetAlgoLined
\KwIn{Array $A[1..n]$, target value $t$}
\KwOut{Index $i$ such that $A[i] = t$, or $-1$ if not found}
$left \gets 1$\;
$right \gets n$\;
\While{$left \leq right$}{
    $mid \gets \lfloor (left + right) / 2 \rfloor$\;
    \eIf{$A[mid] = t$}{
        \Return{$mid$}\;
    }{
        \eIf{$A[mid] < t$}{
            $left \gets mid + 1$\;
        }{
            $right \gets mid - 1$\;
        }
    }
}
\Return{$-1$}\;
\caption{Binary Search}
\end{algorithm}
```

### Using algorithmicx (algpseudocode)

```latex
\usepackage{algorithm}
\usepackage{algpseudocode}

\begin{algorithm}[H]
\caption{Quicksort}
\begin{algorithmic}[1]
\Procedure{QuickSort}{$A, lo, hi$}
    \If{$lo < hi$}
        \State $p \gets$ \Call{Partition}{$A, lo, hi$}
        \State \Call{QuickSort}{$A, lo, p - 1$}
        \State \Call{QuickSort}{$A, p + 1, hi$}
    \EndIf
\EndProcedure
\Statex
\Function{Partition}{$A, lo, hi$}
    \State $pivot \gets A[hi]$
    \State $i \gets lo - 1$
    \For{$j \gets lo$ \textbf{to} $hi - 1$}
        \If{$A[j] \leq pivot$}
            \State $i \gets i + 1$
            \State swap $A[i]$ and $A[j]$
        \EndIf
    \EndFor
    \State swap $A[i+1]$ and $A[hi]$
    \State \Return $i + 1$
\EndFunction
\end{algorithmic}
\end{algorithm}
```

**When to use which:**
- `algorithm2e`: More customizable, line numbering, IF/ELSE style closer to code
- `algorithmicx`: More traditional CS textbook style, widely used in academic papers

---

## Colored Boxes (tcolorbox)

### Basic Colored Box

```latex
\usepackage[most]{tcolorbox}

\begin{tcolorbox}[colback=blue!5, colframe=blue!50!black, title=Important Note]
This is a colored box with a title. Useful for callouts, warnings, theorems, or highlighting key information.
\end{tcolorbox}
```

### Theorem with tcolorbox

```latex
\newtcolorbox{mytheo}[2][]{
    colback=blue!5,
    colframe=blue!50!black,
    fonttitle=\bfseries,
    title={Theorem #2},
    #1
}

\begin{mytheo}{3.1}
For all $n \geq 1$, $\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$.
\end{mytheo}
```

### Code Example Box (upper/lower split)

```latex
\begin{tcolorbox}[colback=gray!5, colframe=gray!50, title=Python Example,
    listing and text, listing options={language=Python, basicstyle=\ttfamily\small}]
def greet(name):
    return f"Hello, {name}!"
\tcblower
\textbf{Output:} Hello, World!
\end{tcolorbox}
```

### Warning / Info / Tip Boxes

```latex
% Warning box
\newtcolorbox{warningbox}{colback=red!5, colframe=red!50!black,
    fonttitle=\bfseries, title=Warning}

% Info box
\newtcolorbox{infobox}{colback=cyan!5, colframe=cyan!50!black,
    fonttitle=\bfseries, title=Information}

% Tip box
\newtcolorbox{tipbox}{colback=green!5, colframe=green!50!black,
    fonttitle=\bfseries, title=Tip}

\begin{warningbox}
Do not use hyperref in PDF-to-LaTeX converted documents with theorem environments.
\end{warningbox}
```

---

## SI Units (siunitx)

### Basic Usage

```latex
\usepackage{siunitx}

% Numbers
\num{12345.67}       % → 12 345.67 (with proper grouping)
\num{1e-10}          % → 1 × 10⁻¹⁰

% Units
\si{kg.m/s^2}        % → kg m/s²
\si{\kilo\gram\metre\per\second\squared}  % → kg m s⁻²

% Quantities (number + unit)
\qty{9.81}{m/s^2}    % → 9.81 m/s²
\qty{300}{\mega\hertz}   % → 300 MHz
\qty{25}{\celsius}       % → 25 °C
\qty{1.38e-23}{J/K}     % → 1.38 × 10⁻²³ J/K
```

### In Tables (aligned decimal columns)

```latex
\begin{tabular}{l S[table-format=3.2] S[table-format=2.1]}
\toprule
{Material} & {Density (\si{g/cm^3})} & {Melting Point (\si{\celsius})} \\
\midrule
Iron       & 7.87  & 1538.0 \\
Aluminum   & 2.70  & 660.3 \\
Copper     & 8.96  & 1085.0 \\
\bottomrule
\end{tabular}
```

### Common Units Quick Reference

| Macro | Output | Macro | Output |
|-------|--------|-------|--------|
| `\metre` | m | `\kilogram` | kg |
| `\second` | s | `\ampere` | A |
| `\kelvin` | K | `\mole` | mol |
| `\hertz` | Hz | `\newton` | N |
| `\pascal` | Pa | `\joule` | J |
| `\watt` | W | `\volt` | V |
| `\celsius` | °C | `\percent` | % |

---

## Advanced Chart Types (pgfplots)

### 3D Surface Plot

```latex
\begin{tikzpicture}
\begin{axis}[
    view={45}{30},
    xlabel=$x$, ylabel=$y$, zlabel=$f(x,y)$,
    colormap/viridis,
    title={3D Surface Plot},
]
\addplot3[surf, samples=25, domain=-2:2] {exp(-x^2 - y^2)};
\end{axis}
\end{tikzpicture}
```

### Heatmap (matrix plot)

```latex
\begin{tikzpicture}
\begin{axis}[
    colormap/hot,
    colorbar,
    xlabel={Column}, ylabel={Row},
    point meta min=0, point meta max=100,
    title={Heatmap},
]
\addplot[matrix plot*, mesh/cols=4, mesh/rows=3,
    point meta=explicit] coordinates {
    (0,0) [20]  (1,0) [40]  (2,0) [60]  (3,0) [80]
    (0,1) [30]  (1,1) [55]  (2,1) [75]  (3,1) [90]
    (0,2) [10]  (1,2) [35]  (2,2) [50]  (3,2) [70]
};
\end{axis}
\end{tikzpicture}
```

### Box Plot

```latex
\usepgfplotslibrary{statistics}

\begin{tikzpicture}
\begin{axis}[
    boxplot/draw direction=y,
    xtick={1,2,3},
    xticklabels={Group A, Group B, Group C},
    ylabel={Score},
    title={Box Plot Comparison},
]
\addplot+[boxplot prepared={
    median=42, upper quartile=50, lower quartile=35,
    upper whisker=65, lower whisker=20
}] coordinates {};
\addplot+[boxplot prepared={
    median=55, upper quartile=62, lower quartile=48,
    upper whisker=78, lower whisker=30
}] coordinates {};
\addplot+[boxplot prepared={
    median=38, upper quartile=45, lower quartile=28,
    upper whisker=58, lower whisker=15
}] coordinates {};
\end{axis}
\end{tikzpicture}
```

### Gantt Chart (pgfgantt)

```latex
\usepackage{pgfgantt}

\begin{ganttchart}[
    hgrid, vgrid,
    x unit=0.8cm,
    title height=1,
    bar/.style={fill=blue!40},
    milestone/.style={fill=red!60},
]{1}{12}
\gantttitle{2026}{12} \\
\gantttitlelist{Jan,...,Dec}{1} \\
\ganttbar{Research}{1}{3} \\
\ganttbar{Design}{3}{5} \\
\ganttbar{Development}{5}{9} \\
\ganttbar{Testing}{8}{10} \\
\ganttbar{Launch}{11}{12} \\
\ganttmilestone{Beta Release}{9}
\ganttlink{elem0}{elem1}
\ganttlink{elem1}{elem2}
\ganttlink{elem2}{elem3}
\end{ganttchart}
```

### Radar / Spider Chart (TikZ)

```latex
\begin{tikzpicture}
\def\categories{{"Speed", "Accuracy", "Cost", "Scalability", "Ease of Use"}}
\def\n{5}  % number of categories
\def\dataA{0.8, 0.9, 0.6, 0.7, 0.85}
\def\dataB{0.6, 0.7, 0.9, 0.8, 0.5}

% Draw grid
\foreach \level in {0.2, 0.4, 0.6, 0.8, 1.0} {
    \draw[gray!30] \foreach \i in {1,...,\n} {
        ({360/\n*(\i-1)}:{\level*3}) --
    } cycle;
}
% Draw axes
\foreach \i in {1,...,\n} {
    \draw[gray!50] (0,0) -- ({360/\n*(\i-1)}:3);
    \pgfmathparse{\categories[\i-1]}
    \node[font=\small] at ({360/\n*(\i-1)}:3.5) {\pgfmathresult};
}
% Plot data A
\draw[blue, thick, fill=blue!20, opacity=0.5]
    (90:0.8*3) -- (162:0.9*3) -- (234:0.6*3) -- (306:0.7*3) -- (378:0.85*3) -- cycle;
% Plot data B
\draw[red, thick, fill=red!20, opacity=0.5]
    (90:0.6*3) -- (162:0.7*3) -- (234:0.9*3) -- (306:0.8*3) -- (378:0.5*3) -- cycle;
\end{tikzpicture}
```

---

## AI-Generated Images in LaTeX

When the `generate-image` skill is available, you can create custom illustrations for LaTeX documents:

### Workflow

1. Generate the image:
```bash
python3 /home/node/.claude/skills/generate-image/scripts/generate_image.py \
    "Professional diagram of a neural network architecture, clean white background, technical illustration style" \
    --output ./outputs/neural_net.png
```

2. Include in LaTeX:
```latex
\begin{figure}[H]
\centering
\includegraphics[width=0.6\textwidth]{neural_net.png}
\caption{Neural network architecture (AI-generated).}
\label{fig:neural_net}
\end{figure}
```

### Best Practices for AI Images in LaTeX

- **Request "white background, clean, technical illustration"** for best results in documents
- **Request "no text in the image"** -- add labels/captions in LaTeX instead (more consistent typography)
- **Use high resolution** -- AI images at 1024x1024+ work well at print quality
- **Save as PNG** for raster images, or use `--format pdf` if the tool supports it
- **Available models**: Gemini 3 Pro (photorealistic), Seedream 4.5 (artistic), GPT-Image (advanced)
