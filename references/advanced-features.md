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
