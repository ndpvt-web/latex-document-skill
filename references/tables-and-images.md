# Tables and Images in LaTeX

## Table of Contents
- [Tables](#tables)
  - [Basic Table](#basic-table)
  - [Full-Width Table with tabularx](#full-width-table-with-tabularx)
  - [Colored Rows](#colored-rows)
  - [Multi-row and Multi-column](#multi-row-and-multi-column)
  - [Borderless Modern Table](#borderless-modern-table)
  - [Long Tables](#long-tables)
- [Advanced Tables](#advanced-tables)
  - [Alternating Row Colors](#alternating-row-colors)
  - [Complex Multi-row/Multi-column](#complex-multi-rowmulti-column)
  - [Conditional Cell Formatting](#conditional-cell-formatting)
  - [Tables from CSV Data](#tables-from-csv-data)
  - [Rotated Column Headers](#rotated-column-headers)
  - [Adjustbox for Table Sizing](#adjustbox-for-table-sizing)
  - [nicematrix (Modern Alternative)](#nicematrix-modern-alternative)
  - [Long Table with Continuation Headers](#long-table-with-continuation-headers)
  - [Landscape Tables](#landscape-tables)
- [Images](#images)
  - [Including External Images](#including-external-images)
  - [TikZ Drawings](#tikz-drawings)
  - [Circular Clipped Photo](#circular-clipped-photo)
  - [Side-by-Side Images](#side-by-side-images)
  - [Text Wrapping Around Images](#text-wrapping-around-images)
- [Advanced Images](#advanced-images)
  - [Subfigures (Multiple Images with Sub-captions)](#subfigures-multiple-images-with-sub-captions)
  - [Image Grid (3x2, 2x2, etc.)](#image-grid-3x2-2x2-etc)
  - [Full-Page Images](#full-page-images)
  - [Image Borders and Shadows](#image-borders-and-shadows)
  - [Overlaying Text on Images](#overlaying-text-on-images)
- [Troubleshooting Tables & Images](#troubleshooting-tables--images)
  - [Common Table Errors](#common-table-errors)
  - [Common Image Errors](#common-image-errors)

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

---

## Advanced Tables

### Alternating Row Colors

Automatically color alternating rows for improved readability:

```latex
\usepackage[table]{xcolor}

% Set alternating row colors (starting from row 2)
\rowcolors{2}{gray!10}{white}

\begin{tabular}{lcc}
\toprule
\textbf{Product} & \textbf{Sales} & \textbf{Growth} \\
\midrule
Widget A & \$50K & +12\% \\
Widget B & \$35K & -3\% \\
Widget C & \$72K & +25\% \\
Widget D & \$41K & +8\% \\
\bottomrule
\end{tabular}
```

The `\rowcolors{starting_row}{odd_color}{even_color}` command applies colors automatically. Use `\hiderowcolors` and `\showrowcolors` to temporarily disable/enable.

### Complex Multi-row/Multi-column

A realistic example combining both `\multirow` and `\multicolumn` with nested spanning:

```latex
\usepackage{multirow}
\usepackage{booktabs}

\begin{tabular}{|l|c|c|c|c|}
\hline
\multirow{2}{*}{\textbf{Region}} & \multicolumn{2}{c|}{\textbf{Q1}} & \multicolumn{2}{c|}{\textbf{Q2}} \\
\cline{2-5}
 & Revenue & Units & Revenue & Units \\
\hline
\multirow{2}{*}{North} & \$120K & 1,200 & \$135K & 1,350 \\
 & \multicolumn{4}{c|}{(5\% growth in units)} \\
\hline
\multirow{2}{*}{South} & \$95K & 950 & \$110K & 1,100 \\
 & \multicolumn{4}{c|}{(15\% growth in units)} \\
\hline
\textbf{Total} & \multicolumn{2}{c|}{\$215K} & \multicolumn{2}{c|}{\$245K} \\
\hline
\end{tabular}
```

Tips:
- Use `\cline{2-5}` for partial horizontal lines
- Combine `\multirow` with `\multicolumn` by nesting them carefully
- Leave empty cells in subsequent rows when using `\multirow`

### Conditional Cell Formatting

Color individual cells based on their values:

```latex
\usepackage[table]{xcolor}

\begin{tabular}{|l|c|c|}
\hline
\textbf{Metric} & \textbf{Target} & \textbf{Actual} \\
\hline
Revenue & \$100K & \cellcolor{green!30}\$115K \\
\hline
Costs & \$80K & \cellcolor{red!30}\$95K \\
\hline
Margin & 20\% & \cellcolor{yellow!30}17\% \\
\hline
\end{tabular}
```

Advanced: Define custom commands for threshold-based coloring:

```latex
\newcommand{\goodcell}[1]{\cellcolor{green!30}#1}
\newcommand{\badcell}[1]{\cellcolor{red!30}#1}
\newcommand{\warncell}[1]{\cellcolor{yellow!30}#1}

\begin{tabular}{lc}
\toprule
Test & Status \\
\midrule
Unit Tests & \goodcell{Passed} \\
Integration & \badcell{Failed} \\
Performance & \warncell{Slow} \\
\bottomrule
\end{tabular}
```

### Tables from CSV Data

Automatically generate tables from CSV files:

```latex
\usepackage{csvsimple}

% Simple auto-table
\csvautotabular{data.csv}

% Custom formatting
\begin{table}[htbp]
\centering
\begin{tabular}{lrr}
\toprule
\bfseries Name & \bfseries Age & \bfseries Score \\
\midrule
\csvreader[head to column names]{data.csv}{}
{\name & \age & \score \\}
\bottomrule
\end{tabular}
\caption{Data imported from CSV}
\end{table}
```

Example `data.csv`:
```
name,age,score
Alice,28,95
Bob,32,87
Carol,25,92
```

Filtering rows:
```latex
\csvreader[filter expr={\value{score}>90}]{data.csv}{name=\name,score=\score}
{\name & \score \\}
```

### Rotated Column Headers

Useful for tables with many narrow columns:

```latex
\usepackage{rotating}
\usepackage{booktabs}
\usepackage{array}

\begin{tabular}{l*{5}{c}}
\toprule
\textbf{Team} & \rotatebox{90}{Velocity} & \rotatebox{90}{Quality} & \rotatebox{90}{Coverage} & \rotatebox{90}{Bugs} & \rotatebox{90}{Uptime} \\
\midrule
Alpha & 85 & 92 & 88 & 3 & 99.9\% \\
Beta & 78 & 87 & 91 & 5 & 99.7\% \\
Gamma & 92 & 95 & 94 & 1 & 99.99\% \\
\bottomrule
\end{tabular}
```

Alternative with `\rothead` custom command:
```latex
\newcommand{\rothead}[1]{\rotatebox{90}{\textbf{#1}}}

\begin{tabular}{l*{5}{c}}
\toprule
\textbf{Team} & \rothead{Velocity} & \rothead{Quality} & \rothead{Coverage} & \rothead{Bugs} & \rothead{Uptime} \\
\midrule
% ... data rows ...
\bottomrule
\end{tabular}
```

### Adjustbox for Table Sizing

Automatically scale tables to fit page width while maintaining aspect ratio:

```latex
\usepackage{adjustbox}

% Scale to fit text width
\begin{adjustbox}{max width=\textwidth}
\begin{tabular}{lccccccccc}
\toprule
\textbf{ID} & \textbf{Col1} & \textbf{Col2} & \textbf{Col3} & \textbf{Col4} & \textbf{Col5} & \textbf{Col6} & \textbf{Col7} & \textbf{Col8} & \textbf{Col9} \\
\midrule
001 & A & B & C & D & E & F & G & H & I \\
002 & J & K & L & M & N & O & P & Q & R \\
\bottomrule
\end{tabular}
\end{adjustbox}

% Scale to specific width
\begin{adjustbox}{width=0.9\textwidth}
\begin{tabular}{...}
% ...
\end{tabular}
\end{adjustbox}

% Center and scale
\begin{adjustbox}{center, max width=\textwidth}
\begin{tabular}{...}
% ...
\end{tabular}
\end{adjustbox}
```

Advantages over `\resizebox`:
- Maintains better font scaling
- More flexible options (max width, max height, etc.)
- Can center automatically

### nicematrix (Modern Alternative)

A modern package offering enhanced table features:

```latex
\usepackage{nicematrix}

% Basic usage with automatic rules
\begin{NiceTabular}{lcc}[hvlines, rules/color=gray]
\RowStyle{\bfseries}
Header 1 & Header 2 & Header 3 \\
A & B & C \\
D & E & F \\
\end{NiceTabular}

% With custom styling
\begin{NiceTabular}{lcc}[
    hvlines,
    cell-space-limits=3pt,
    code-before = \rowcolor{blue!15}{1}
]
\textbf{Product} & \textbf{Price} & \textbf{Stock} \\
Widget & \$29.99 & 150 \\
Gadget & \$49.99 & 87 \\
Tool & \$19.99 & 200 \\
\end{NiceTabular}
```

Advanced features:
```latex
% Diagonal lines in cells
\begin{NiceTabular}{cc}[hvlines]
\diagbox{Row}{Col} & Column 1 \\
Row 1 & Data \\
\end{NiceTabular}

% Custom block styling
\begin{NiceTabular}{cccc}[hvlines]
\Block{1-4}{\textbf{Quarterly Report}} \\
Q1 & Q2 & Q3 & Q4 \\
\$100K & \$120K & \$115K & \$140K \\
\end{NiceTabular}
```

### Long Table with Continuation Headers

Complete example with headers and footers that repeat across pages:

```latex
\usepackage{longtable}
\usepackage{booktabs}

\begin{longtable}{llrr}
% Header for first page
\toprule
\textbf{ID} & \textbf{Description} & \textbf{Quantity} & \textbf{Price} \\
\midrule
\endfirsthead

% Header for continuation pages
\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continued from previous page}} \\
\toprule
\textbf{ID} & \textbf{Description} & \textbf{Quantity} & \textbf{Price} \\
\midrule
\endhead

% Footer for all pages except last
\midrule
\multicolumn{4}{r}{\textit{Continued on next page}} \\
\endfoot

% Footer for last page
\bottomrule
\multicolumn{3}{r}{\textbf{Total:}} & \textbf{\$15,750.00} \\
\endlastfoot

% Data rows
001 & Premium Widget Set & 50 & \$1,250.00 \\
002 & Standard Gadget & 100 & \$2,500.00 \\
003 & Deluxe Tool Kit & 25 & \$1,875.00 \\
004 & Basic Component & 200 & \$1,000.00 \\
005 & Advanced Module & 30 & \$2,400.00 \\
% ... many more rows ...
050 & Final Item & 75 & \$1,875.00 \\
\end{longtable}
```

Key commands:
- `\endfirsthead` - Header for first page only
- `\endhead` - Header for subsequent pages
- `\endfoot` - Footer for all pages except last
- `\endlastfoot` - Footer for final page only

### Landscape Tables

For very wide tables, use landscape orientation:

```latex
\usepackage{pdflscape}
\usepackage{longtable}

\begin{landscape}
\begin{table}[htbp]
\centering
\begin{tabular}{lcccccccccc}
\toprule
\textbf{Project} & \textbf{Jan} & \textbf{Feb} & \textbf{Mar} & \textbf{Apr} & \textbf{May} & \textbf{Jun} & \textbf{Jul} & \textbf{Aug} & \textbf{Sep} & \textbf{Oct} \\
\midrule
Alpha & 85\% & 87\% & 92\% & 94\% & 95\% & 97\% & 98\% & 98\% & 99\% & 99\% \\
Beta & 72\% & 75\% & 78\% & 82\% & 85\% & 88\% & 91\% & 93\% & 95\% & 96\% \\
Gamma & 91\% & 92\% & 93\% & 94\% & 95\% & 96\% & 97\% & 98\% & 99\% & 99\% \\
\bottomrule
\end{tabular}
\caption{Monthly project completion rates}
\end{table}
\end{landscape}

% For multi-page landscape tables, combine with longtable:
\begin{landscape}
\begin{longtable}{lcccccccccc}
% ... longtable structure ...
\end{longtable}
\end{landscape}
```

Alternative using `rotating` package:
```latex
\usepackage{rotating}

\begin{sidewaystable}
\centering
\begin{tabular}{...}
% ... table content ...
\end{tabular}
\caption{Wide table in landscape}
\end{sidewaystable}
```

---

## Advanced Images

### Subfigures (Multiple Images with Sub-captions)

Display multiple related images with individual sub-captions and an overall caption:

```latex
\usepackage{subcaption}
\usepackage{graphicx}

\begin{figure}[htbp]
\centering
\begin{subfigure}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{chart1.png}
    \caption{Revenue trends}
    \label{fig:revenue}
\end{subfigure}
\hfill
\begin{subfigure}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{chart2.png}
    \caption{Cost breakdown}
    \label{fig:costs}
\end{subfigure}
\caption{Q1 2025 Financial Analysis}
\label{fig:financial}
\end{figure}

% Reference with: Figure \ref{fig:financial} shows...,
% specifically \ref{fig:revenue} indicates...
```

Vertical layout:
```latex
\begin{figure}[htbp]
\centering
\begin{subfigure}{\textwidth}
    \centering
    \includegraphics[width=0.6\textwidth]{top.png}
    \caption{Overview}
\end{subfigure}

\vspace{1em}

\begin{subfigure}{\textwidth}
    \centering
    \includegraphics[width=0.6\textwidth]{bottom.png}
    \caption{Detailed view}
\end{subfigure}
\caption{System architecture}
\end{figure}
```

Grid of four subfigures:
```latex
\begin{figure}[htbp]
\centering
\begin{subfigure}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img1.png}
    \caption{First}
\end{subfigure}
\hfill
\begin{subfigure}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img2.png}
    \caption{Second}
\end{subfigure}

\vspace{1em}

\begin{subfigure}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img3.png}
    \caption{Third}
\end{subfigure}
\hfill
\begin{subfigure}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img4.png}
    \caption{Fourth}
\end{subfigure}
\caption{Comparison of four approaches}
\end{figure}
```

### Image Grid (3x2, 2x2, etc.)

Create aligned grids of images using minipage:

```latex
% 2x2 grid without individual captions
\begin{figure}[htbp]
\centering
\begin{minipage}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img1.png}
\end{minipage}
\hfill
\begin{minipage}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img2.png}
\end{minipage}

\vspace{0.5cm}

\begin{minipage}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img3.png}
\end{minipage}
\hfill
\begin{minipage}{0.45\textwidth}
    \centering
    \includegraphics[width=\textwidth]{img4.png}
\end{minipage}
\caption{Image grid 2x2}
\end{figure}

% 3x2 grid
\begin{figure}[htbp]
\centering
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{a1.png}
\end{minipage}
\hfill
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{a2.png}
\end{minipage}
\hfill
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{a3.png}
\end{minipage}

\vspace{0.5cm}

\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{b1.png}
\end{minipage}
\hfill
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{b2.png}
\end{minipage}
\hfill
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{b3.png}
\end{minipage}
\caption{Image grid 3x2}
\end{figure}
```

With labels under each image:
```latex
\begin{figure}[htbp]
\centering
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{phase1.png}
    \small Phase 1: Planning
\end{minipage}
\hfill
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{phase2.png}
    \small Phase 2: Development
\end{minipage}
\hfill
\begin{minipage}{0.3\textwidth}
    \centering
    \includegraphics[width=\textwidth]{phase3.png}
    \small Phase 3: Deployment
\end{minipage}
\caption{Project phases}
\end{figure}
```

### Full-Page Images

Dedicate an entire page to a large figure:

```latex
% Dedicated page for figure
\begin{figure}[p]  % p = dedicated page
\centering
\includegraphics[width=\textwidth,height=0.9\textheight,keepaspectratio]{architecture.pdf}
\caption{Complete system architecture diagram}
\label{fig:fullpage}
\end{figure}

% Full page without margins
\begin{figure}[p]
\centering
\includegraphics[width=\paperwidth,height=\paperheight,keepaspectratio]{poster.png}
\end{figure}

% Landscape full page
\usepackage{pdflscape}
\begin{landscape}
\begin{figure}[p]
\centering
\includegraphics[width=\textwidth,height=\textheight,keepaspectratio]{wide_chart.pdf}
\caption{Full landscape figure}
\end{figure}
\end{landscape}
```

For true full-bleed images (no margins):
```latex
\usepackage{eso-pic}

\AddToShipoutPictureBG*{%
  \AtPageLowerLeft{%
    \includegraphics[width=\paperwidth,height=\paperheight]{background.jpg}%
  }%
}
```

### Image Borders and Shadows

Use `tcolorbox` for professional framing:

```latex
\usepackage{tcolorbox}
\usepackage{graphicx}

% Simple border
\begin{tcolorbox}[colback=white,colframe=black,boxrule=1pt]
\includegraphics[width=\textwidth]{photo.png}
\end{tcolorbox}

% With shadow
\begin{tcolorbox}[
    enhanced,
    drop shadow,
    colback=white,
    colframe=gray!50,
    boxrule=0.5pt
]
\includegraphics[width=\textwidth]{screenshot.png}
\end{tcolorbox}

% Rounded corners with caption
\begin{tcolorbox}[
    enhanced,
    drop shadow,
    colback=white,
    colframe=blue!50,
    arc=3mm,
    boxrule=1pt,
    title=Figure: Application Interface
]
\centering
\includegraphics[width=0.9\textwidth]{ui.png}
\end{tcolorbox}
```

Using `fancybox`:
```latex
\usepackage{fancybox}

\begin{figure}[htbp]
\centering
\shadowbox{\includegraphics[width=0.7\textwidth]{image.png}}
\caption{Image with shadow}
\end{figure}

\begin{figure}[htbp]
\centering
\doublebox{\includegraphics[width=0.7\textwidth]{image.png}}
\caption{Image with double border}
\end{figure}

\begin{figure}[htbp]
\centering
\ovalbox{\includegraphics[width=0.7\textwidth]{image.png}}
\caption{Image with rounded border}
\end{figure}
```

### Overlaying Text on Images

Use TikZ to place text over images:

```latex
\usepackage{tikz}

% Basic text overlay
\begin{figure}[htbp]
\centering
\begin{tikzpicture}
\node[anchor=south west,inner sep=0] (image) at (0,0) {
    \includegraphics[width=0.8\textwidth]{background.png}
};
\node[white,font=\Large\bfseries] at (image.center) {Overlay Text};
\end{tikzpicture}
\caption{Image with centered text}
\end{figure}

% Multiple text elements with positioning
\begin{tikzpicture}
\node[anchor=south west,inner sep=0] (image) at (0,0) {
    \includegraphics[width=\textwidth]{dashboard.png}
};
\node[white,font=\huge\bfseries,drop shadow] at (4,3) {Dashboard 2025};
\node[yellow,font=\Large] at (8,1) {Revenue: \$2.5M};
\node[green,font=\small] at (2,5) {+15\% Growth};
\end{tikzpicture}

% Text box with background
\begin{tikzpicture}
\node[anchor=south west,inner sep=0] at (0,0) {
    \includegraphics[width=\textwidth]{photo.jpg}
};
\node[
    fill=black,
    fill opacity=0.7,
    text=white,
    text opacity=1,
    font=\Large\bfseries,
    rounded corners,
    inner sep=10pt
] at (5,2) {Important Notice};
\end{tikzpicture}
```

Advanced positioning:
```latex
\begin{tikzpicture}
\node[anchor=south west,inner sep=0] (img) at (0,0) {
    \includegraphics[width=\textwidth]{chart.png}
};
% Top-left corner
\node[anchor=north west,fill=white,opacity=0.9,inner sep=5pt]
    at (img.north west) {\textbf{Q1 Results}};
% Bottom-right corner
\node[anchor=south east,fill=blue!20,inner sep=5pt]
    at (img.south east) {\small Source: Internal Data};
\end{tikzpicture}
```

---

## Troubleshooting Tables & Images

### Common Table Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Extra alignment tab has been changed to \\cr" | Too many `&` in a row | Count columns in preamble vs. `&` in rows |
| "Missing \\endgroup inserted" | Unmatched braces in cell | Check `{` and `}` balance in cells |
| Table overflows right margin | Too many/wide columns | Use `tabularx`, `adjustbox`, or reduce column widths |
| "Misplaced \\noalign" | `\hline` placement error | Ensure `\\` before `\hline`: `\\\\hline` |
| "Illegal pream-token" | Invalid column specifier | Check for typos in `\begin{tabular}{...}` |
| "Extra }, or forgotten \\endgroup" | Mismatched braces | Verify nested `\multirow` or `\multicolumn` braces |
| Vertical alignment issues | Cell content too tall | Use `\arraystretch` or `p{}` columns |
| "Undefined control sequence \\toprule" | Missing booktabs | Add `\usepackage{booktabs}` |
| Colored rows not working | Missing xcolor package | Add `\usepackage[table]{xcolor}` |
| `\multirow` spanning incorrect rows | Wrong row count | Check the `{n}` parameter in `\multirow{n}{*}{...}` |

Common fixes:
```latex
% Increase row height globally
\renewcommand{\arraystretch}{1.5}

% Fix column width overflow
\usepackage{tabularx}
\begin{tabularx}{\textwidth}{lXc}  % X expands to fill

% Center table horizontally
\begin{center}
\begin{tabular}{...}
...
\end{tabular}
\end{center}

% Or use table environment
\begin{table}[htbp]
\centering
\begin{tabular}{...}
...
\end{tabular}
\end{table}
```

### Common Image Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "File `image.png' not found" | Wrong path or missing file | Use path relative to `.tex` file location |
| "Cannot determine size of graphic" | Unsupported format or no BoundingBox | Convert to PNG/JPG/PDF; use `pdflatex` not `latex` |
| "Dimension too large" | Image resolution too high | Scale with `width=` or `scale=` option |
| Image appears in wrong location | Float placement | Use `[H]` (requires `\usepackage{float}`) or `[!htbp]` |
| "Unknown graphics extension" | Missing graphicx package | Add `\usepackage{graphicx}` |
| Image quality is poor | Scaled bitmap too much | Use vector format (PDF/SVG) or higher resolution |
| "Undefined control sequence \\includegraphics" | Missing graphicx | Add `\usepackage{graphicx}` |
| Image overlaps text | No spacing | Add `\vspace{1em}` before/after or use `figure` environment |
| Caption not appearing | Outside figure environment | Wrap in `\begin{figure}...\end{figure}` |
| "Option clash for package graphicx" | Loaded multiple times with different options | Load once in preamble with all options |

Common fixes:
```latex
% Force image at exact location
\usepackage{float}
\begin{figure}[H]  % H = "Here, definitely"
\centering
\includegraphics[width=0.8\textwidth]{image.png}
\end{figure}

% Constrain image dimensions
\includegraphics[width=0.8\textwidth,height=0.5\textheight,keepaspectratio]{large.jpg}

% Specify image directory
\graphicspath{{./images/}{./figures/}}
\includegraphics{photo.png}  % searches in specified directories

% Fix path issues in subdirectories
% If .tex is in project/docs/ and image in project/images/
\includegraphics{../images/photo.png}

% Supported formats check
% PDF/JPG/PNG work with pdflatex
% EPS works with latex (not pdflatex)
% Convert EPS to PDF: epstopdf image.eps
```

Debugging image paths:
```latex
% Show image search paths
\typeout{\the\graphicspath}

% Verify file existence with draft mode
\usepackage[draft]{graphicx}  % Shows boxes instead of images
```
