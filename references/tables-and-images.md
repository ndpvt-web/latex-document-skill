# Tables and Images in LaTeX

## Table of Contents
- [Tables](#tables)
  - [Basic Table](#basic-table)
  - [Full-Width Table with tabularx](#full-width-table-with-tabularx)
  - [Colored Rows](#colored-rows)
  - [Multi-row and Multi-column](#multi-row-and-multi-column)
  - [Borderless Modern Table](#borderless-modern-table)
  - [Long Tables](#long-tables)
- [Images](#images)
  - [Including External Images](#including-external-images)
  - [TikZ Drawings](#tikz-drawings)
  - [Circular Clipped Photo](#circular-clipped-photo)
  - [Side-by-Side Images](#side-by-side-images)
  - [Text Wrapping Around Images](#text-wrapping-around-images)

---

## Tables

Required packages:
```latex
\usepackage{tabularx}   % Auto-width columns
\usepackage{array}       % Column customization
\usepackage{colortbl}    % Row/cell colors
\usepackage{multirow}    % Span multiple rows
\usepackage{booktabs}    % Professional rules (\toprule, \midrule, \bottomrule)
\usepackage{longtable}   % Tables spanning pages
```

### Basic Table

```latex
\begin{tabular}{|l|c|r|}
\hline
\textbf{Left} & \textbf{Center} & \textbf{Right} \\
\hline
A & B & C \\
\hline
\end{tabular}
```

Column types: `l` left, `c` center, `r` right, `p{3cm}` fixed-width paragraph.

### Full-Width Table with tabularx

```latex
\begin{tabularx}{\textwidth}{|>{\bfseries}l|X|c|}
\hline
\textbf{Category} & \textbf{Description} & \textbf{Level} \\
\hline
Languages & Python, Java, Go, SQL & Expert \\
\hline
Frontend & React, Next.js, Vue.js & Advanced \\
\hline
\end{tabularx}
```

`X` columns auto-expand to fill remaining width. Use `>{\bfseries}l` to auto-bold a column.

### Colored Rows

Requires `\usepackage{colortbl}` and `\usepackage{xcolor}`.

```latex
\definecolor{headerblue}{RGB}{200, 220, 255}
\definecolor{lightgray}{RGB}{240, 240, 240}

\begin{tabularx}{\textwidth}{|l|X|c|}
\hline
\rowcolor{headerblue}
\textbf{Metric} & \textbf{Value} & \textbf{Change} \\
\hline
\rowcolor{lightgray}
Revenue & \$1.2M & \textcolor{green}{\textbf{+15\%}} \\
\hline
Costs & \$800K & \textcolor{red}{\textbf{+5\%}} \\
\hline
\end{tabularx}
```

### Multi-row and Multi-column

Requires `\usepackage{multirow}`.

```latex
\begin{tabular}{|l|c|c|c|}
\hline
\multirow{2}{*}{\textbf{Name}} & \multicolumn{3}{c|}{\textbf{Scores}} \\
\cline{2-4}
 & Math & Science & English \\
\hline
Alice & 95 & 88 & 92 \\
\hline
\end{tabular}
```

### Borderless Modern Table

Using `booktabs` for professional look:

```latex
\begin{tabular}{lrr}
\toprule
\textbf{Project} & \textbf{Users} & \textbf{Uptime} \\
\midrule
Platform A & 2M+ & 99.9\% \\
Platform B & 50K & 99.5\% \\
Platform C & 5K  & 99.8\% \\
\bottomrule
\end{tabular}
```

### Long Tables

For tables that span pages, use `longtable`:

```latex
\usepackage{longtable}
% ...
\begin{longtable}{|l|p{8cm}|r|}
\hline
\textbf{ID} & \textbf{Description} & \textbf{Amount} \\
\hline
\endfirsthead
\hline
\textbf{ID} & \textbf{Description} & \textbf{Amount} \\
\hline
\endhead
\hline
\endfoot
001 & First item & \$100 \\
\hline
% ... many rows ...
\end{longtable}
```

---

## Images

Required packages:
```latex
\usepackage{graphicx}    % \includegraphics
\usepackage{tikz}        % Programmatic drawings
\usepackage{wrapfig}     % Text wrapping around images
\usepackage{subcaption}  % Subfigures
```

### Including External Images

```latex
% Basic inclusion
\includegraphics[width=0.5\textwidth]{photo.png}

% With figure environment (adds caption + label)
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\textwidth]{chart.png}
  \caption{Sales data for Q1 2025}
  \label{fig:sales}
\end{figure}

% Fixed dimensions
\includegraphics[width=5cm, height=3cm, keepaspectratio]{logo.png}
```

Supported formats: PNG, JPG, PDF (vector). Use `keepaspectratio` to prevent distortion.

### TikZ Drawings

Placeholder shapes when no image file is available:

```latex
% Simple person icon (for profile photo placeholder)
\begin{tikzpicture}
  \draw[fill=gray!20] (0,0) circle (1.2cm);
  \draw[fill=white] (0,-0.2) circle (0.4cm);
  \draw[fill=white] (0,0.5) circle (0.5cm);
\end{tikzpicture}

% Bar chart
\begin{tikzpicture}
  \fill[blue!60] (0,0) rectangle (1,3);
  \fill[blue!40] (1.5,0) rectangle (2.5,2);
  \fill[blue!20] (3,0) rectangle (4,4);
  \node at (0.5,-0.3) {Q1};
  \node at (2,-0.3) {Q2};
  \node at (3.5,-0.3) {Q3};
\end{tikzpicture}

% Star rating
\begin{tikzpicture}
  \foreach \i in {1,...,5} {
    \fill[yellow!80!orange] (\i*0.5,0) -- ++(0.18,0.35) -- ++(0.35,0)
      -- ++(-0.25,0.22) -- ++(0.1,0.38) -- ++(-0.28,-0.25)
      -- ++(-0.28,0.25) -- ++(0.1,-0.38) -- ++(-0.25,-0.22)
      -- ++(0.35,0) -- cycle;
  }
\end{tikzpicture}
```

### Circular Clipped Photo

```latex
\usepackage{tikz}
% ...
\begin{tikzpicture}
  \clip (0,0) circle (1.5cm);
  \node at (0,0) {\includegraphics[width=3cm]{photo.jpg}};
\end{tikzpicture}
```

### Side-by-Side Images

```latex
\begin{figure}[htbp]
  \centering
  \begin{minipage}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{image1.png}
    \caption{First image}
  \end{minipage}
  \hfill
  \begin{minipage}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{image2.png}
    \caption{Second image}
  \end{minipage}
\end{figure}
```

### Text Wrapping Around Images

```latex
\usepackage{wrapfig}
% ...
\begin{wrapfigure}{r}{0.3\textwidth}
  \centering
  \includegraphics[width=0.28\textwidth]{photo.png}
  \caption{Profile}
\end{wrapfigure}
The text here flows around the image on the right side.
```

Position options: `r` right, `l` left, `R`/`L` for float versions.
