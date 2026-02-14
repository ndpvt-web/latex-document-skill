# Charts and Graphs in LaTeX

## Table of Contents
- [Required Packages](#required-packages)
- [Bar Charts](#bar-charts) (Vertical, Grouped, Horizontal, Stacked)
- [Line Charts](#line-charts) (Basic, Smooth, Error Bars)
- [Scatter Plots](#scatter-plots) (Basic, Trend Line)
- [Pie Charts](#pie-charts)
- [Axis Customization](#axis-customization) (Log Scale, Date Axis, Dual Y-Axis, Custom Grid)
- [Combining Chart with Table](#combining-chart-with-table)
- [Color Palettes](#color-palettes)
- [TikZ Diagrams (Non-Chart)](#tikz-diagrams-non-chart) (Flowchart, Timeline)
- [Tips](#tips)

---

## Required Packages

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
\usepackage{tikz}
\usetikzlibrary{shapes.geometric, arrows.meta, positioning}
```

The `pgfplots` package (built on TikZ) is the standard for data visualization in LaTeX. The TikZ libraries are needed for flowcharts (`shapes.geometric` for diamond nodes, `arrows.meta` for arrow tips, `positioning` for relative placement).

---

## Bar Charts

### Vertical Bar Chart

```latex
\begin{tikzpicture}
\begin{axis}[
    ybar,
    xlabel={Quarter},
    ylabel={Revenue (\$K)},
    symbolic x coords={Q1, Q2, Q3, Q4},
    xtick=data,
    nodes near coords,
    bar width=20pt,
    ymin=0,
]
\addplot coordinates {(Q1,120) (Q2,150) (Q3,180) (Q4,210)};
\end{axis}
\end{tikzpicture}
```

### Grouped Bar Chart

```latex
\begin{tikzpicture}
\begin{axis}[
    ybar,
    xlabel={Quarter},
    ylabel={Revenue (\$K)},
    symbolic x coords={Q1, Q2, Q3, Q4},
    xtick=data,
    legend style={at={(0.5,-0.2)}, anchor=north},
    bar width=12pt,
    ymin=0,
]
\addplot coordinates {(Q1,120) (Q2,150) (Q3,180) (Q4,210)};
\addplot coordinates {(Q1,100) (Q2,130) (Q3,160) (Q4,190)};
\legend{2025, 2024}
\end{axis}
\end{tikzpicture}
```

### Horizontal Bar Chart

```latex
\begin{tikzpicture}
\begin{axis}[
    xbar,
    xlabel={Score},
    symbolic y coords={Python, JavaScript, Go, Rust},
    ytick=data,
    nodes near coords,
    bar width=15pt,
    xmin=0,
]
\addplot coordinates {(95,Python) (88,JavaScript) (72,Go) (65,Rust)};
\end{axis}
\end{tikzpicture}
```

### Stacked Bar Chart

```latex
\begin{tikzpicture}
\begin{axis}[
    ybar stacked,
    xlabel={Quarter},
    ylabel={Revenue (\$K)},
    symbolic x coords={Q1, Q2, Q3, Q4},
    xtick=data,
    legend style={at={(0.5,-0.2)}, anchor=north, legend columns=3},
    bar width=20pt,
]
\addplot coordinates {(Q1,50) (Q2,60) (Q3,70) (Q4,80)};
\addplot coordinates {(Q1,40) (Q2,50) (Q3,60) (Q4,70)};
\addplot coordinates {(Q1,30) (Q2,40) (Q3,50) (Q4,60)};
\legend{Product A, Product B, Product C}
\end{axis}
\end{tikzpicture}
```

---

## Line Charts

### Basic Line Chart

```latex
\begin{tikzpicture}
\begin{axis}[
    xlabel={Month},
    ylabel={Users (K)},
    grid=major,
    legend pos=north west,
]
\addplot coordinates {(1,10) (2,15) (3,22) (4,28) (5,35) (6,42)};
\addplot coordinates {(1,8) (2,12) (3,18) (4,22) (5,30) (6,38)};
\legend{Product A, Product B}
\end{axis}
\end{tikzpicture}
```

### Smooth Line Chart

```latex
\begin{tikzpicture}
\begin{axis}[
    xlabel={Time},
    ylabel={Value},
    grid=both,
    smooth,
    thick,
]
\addplot[blue, mark=*] coordinates {(0,1) (1,2.5) (2,3) (3,4.5) (4,5) (5,7)};
\end{axis}
\end{tikzpicture}
```

### Line Chart with Error Bars

```latex
\begin{tikzpicture}
\begin{axis}[
    xlabel={Experiment},
    ylabel={Accuracy (\%)},
    grid=major,
]
\addplot+[error bars/.cd, y dir=both, y explicit]
    coordinates {
        (1, 85) +- (0, 3)
        (2, 88) +- (0, 2.5)
        (3, 91) +- (0, 2)
        (4, 93) +- (0, 1.5)
    };
\end{axis}
\end{tikzpicture}
```

---

## Scatter Plots

### Basic Scatter Plot

```latex
\begin{tikzpicture}
\begin{axis}[
    xlabel={Input Size},
    ylabel={Runtime (ms)},
    only marks,
    grid=major,
]
\addplot coordinates {(10,5) (20,12) (30,18) (50,45) (100,120) (200,350)};
\end{axis}
\end{tikzpicture}
```

### Scatter with Trend Line

```latex
\begin{tikzpicture}
\begin{axis}[
    xlabel={X},
    ylabel={Y},
    grid=major,
]
\addplot[only marks, blue] coordinates {(1,2) (2,3.5) (3,5) (4,6.2) (5,8) (6,9.5)};
\addplot[red, thick, domain=0:7, samples=2] {1.5*x + 0.5};
\legend{Data, Trend}
\end{axis}
\end{tikzpicture}
```

---

## Pie Charts

pgfplots doesn't have native pie charts, but TikZ handles them well:

```latex
\begin{tikzpicture}
\def\data{{35/blue!60/Product A},
           {25/red!60/Product B},
           {20/green!60/Product C},
           {15/orange!60/Product D},
           {5/purple!60/Other}}

\def\startangle{0}
\foreach \pct/\clr/\lbl [count=\i] in \data {
    \pgfmathsetmacro{\endangle}{\startangle + \pct*3.6}
    \pgfmathsetmacro{\midangle}{(\startangle + \endangle)/2}
    \fill[\clr] (0,0) -- (\startangle:2) arc (\startangle:\endangle:2) -- cycle;
    \node at (\midangle:1.4) {\small\textbf{\pct\%}};
    \node at (\midangle:2.6) {\small\lbl};
    \global\let\startangle\endangle
}
\end{tikzpicture}
```

---

## Axis Customization

### Logarithmic Scale

```latex
\begin{axis}[
    ymode=log,          % log scale on Y axis
    xlabel={Input Size},
    ylabel={Runtime (ms)},
]
```

### Date Axis

```latex
\usepackage{pgfplotstable}
\pgfplotsset{
    /pgf/number format/use comma,
}
\begin{axis}[
    date coordinates in=x,
    xticklabel=\month/\year,
    xlabel={Date},
]
\addplot coordinates {(2025-01-01,100) (2025-04-01,150) (2025-07-01,200)};
\end{axis}
```

### Dual Y-Axis

```latex
\begin{tikzpicture}
\begin{axis}[
    axis y line*=left,
    xlabel={Month},
    ylabel={Revenue (\$K)},
]
\addplot[blue, thick] coordinates {(1,100) (2,120) (3,150) (4,180)};
\label{plot:revenue}
\end{axis}
\begin{axis}[
    axis y line*=right,
    ylabel={Users (K)},
    axis x line=none,
]
\addplot[red, thick, dashed] coordinates {(1,10) (2,15) (3,22) (4,30)};
\label{plot:users}
\end{axis}
\end{tikzpicture}
```

### Custom Grid and Ticks

```latex
\begin{axis}[
    grid=both,
    minor tick num=1,
    major grid style={thick, gray!50},
    minor grid style={thin, gray!20},
    xtick={0,2,...,10},
    ytick={0,20,...,100},
    xmin=0, xmax=10,
    ymin=0, ymax=100,
]
```

---

## Combining Chart with Table

A common pattern for reports -- chart and data table together:

```latex
\begin{figure}[htbp]
\centering
\begin{tikzpicture}
\begin{axis}[
    ybar,
    width=0.7\textwidth,
    height=5cm,
    xlabel={Category},
    ylabel={Value},
    symbolic x coords={A, B, C, D},
    xtick=data,
    nodes near coords,
    ymin=0,
]
\addplot[fill=blue!40] coordinates {(A,45) (B,67) (C,38) (D,82)};
\end{axis}
\end{tikzpicture}
\caption{Visual comparison of categories.}
\end{figure}

\begin{table}[htbp]
\centering
\begin{tabular}{lrr}
\toprule
\textbf{Category} & \textbf{Value} & \textbf{Change} \\
\midrule
A & 45 & +12\% \\
B & 67 & +5\% \\
C & 38 & $-$8\% \\
D & 82 & +20\% \\
\bottomrule
\end{tabular}
\caption{Detailed data for each category.}
\end{table}
```

---

## Color Palettes

### Professional palette (colorblind-friendly)

```latex
\definecolor{chart1}{RGB}{0, 114, 178}    % blue
\definecolor{chart2}{RGB}{230, 159, 0}    % orange
\definecolor{chart3}{RGB}{0, 158, 115}    % green
\definecolor{chart4}{RGB}{204, 121, 167}  % pink
\definecolor{chart5}{RGB}{86, 180, 233}   % light blue
```

Usage:
```latex
\addplot[fill=chart1] coordinates {...};
\addplot[fill=chart2] coordinates {...};
```

### Using pgfplots color cycles

```latex
\pgfplotsset{
    cycle list={
        {blue, thick},
        {red, thick, dashed},
        {green!60!black, thick, dotted},
        {orange, thick, dashdotted},
    }
}
```

---

## TikZ Diagrams (Non-Chart)

### Flowchart

```latex
\begin{tikzpicture}[
    node distance=1.5cm,
    box/.style={draw, rounded corners, fill=blue!10, minimum width=3cm, minimum height=1cm, align=center},
    decision/.style={draw, diamond, fill=yellow!20, minimum width=2cm, aspect=2, align=center},
    arrow/.style={->, thick}
]
\node[box] (start) {Start};
\node[box, below of=start] (process) {Process Data};
\node[decision, below of=process] (check) {Valid?};
\node[box, below of=check] (output) {Output};
\node[box, right of=check, node distance=3.5cm] (fix) {Fix Errors};

\draw[arrow] (start) -- (process);
\draw[arrow] (process) -- (check);
\draw[arrow] (check) -- node[left] {Yes} (output);
\draw[arrow] (check) -- node[above] {No} (fix);
\draw[arrow] (fix) |- (process);
\end{tikzpicture}
```

### Timeline

```latex
\begin{tikzpicture}
\draw[thick, ->, >=stealth] (0,0) -- (12,0);
\foreach \x/\label in {1/Q1 2024, 4/Q2 2024, 7/Q3 2024, 10/Q4 2024} {
    \draw[thick] (\x,0.2) -- (\x,-0.2);
    \node[below] at (\x,-0.3) {\small\label};
}
\node[above, text width=2cm, align=center] at (1,0.3) {\small Planning};
\node[above, text width=2cm, align=center] at (4,0.3) {\small Development};
\node[above, text width=2cm, align=center] at (7,0.3) {\small Testing};
\node[above, text width=2cm, align=center] at (10,0.3) {\small Launch};
\end{tikzpicture}
```

---

## Tips

1. **Always set `\pgfplotsset{compat=1.18}`** (or latest) to avoid deprecation warnings.
2. **Use `\addplot+` (with `+`)** to auto-cycle through colors.
3. **`nodes near coords`** adds data labels on bars/points.
4. **`symbolic x coords`** for categorical (non-numeric) x-axis labels.
5. **Figure environment**: Wrap charts in `\begin{figure}...\end{figure}` for captions and cross-references.
6. **Size control**: Use `width=0.8\textwidth, height=6cm` in axis options.
7. **External data**: `\addplot table [col sep=comma] {data.csv};` reads from CSV files.
