# Advanced Visual & Diagram Packages Reference

This guide covers 24 specialized TikZ and visualization packages that are **already installed** and ready to use in the TeX Live distribution. No additional installation required—just `\usepackage{...}` and start creating.

## Table of Contents
- [Mathematics & Computer Science](#mathematics--computer-science)
- [Physics & Engineering](#physics--engineering)
- [Chemistry](#chemistry)
- [Data Visualization](#data-visualization)
- [Network & Graph Theory](#network--graph-theory)
- [Business & General](#business--general)
- [Music & Games](#music--games)
- [Scientific Computing](#scientific-computing)
- [Quick Reference Table](#quick-reference-table)

---

## Mathematics & Computer Science

### tikz-cd (Commutative Diagrams)

**Use for:** Category theory, abstract algebra, topology, homological algebra, type theory, functional programming diagrams

**Package:** `\usepackage{tikz-cd}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{tikz-cd}
\begin{document}

\begin{tikzcd}
A \arrow{r}{f} \arrow{d}{\alpha} & B \arrow{d}{\beta} \\
C \arrow{r}{g} & D
\end{tikzcd}

\end{document}
```

**Notes:** Specialized syntax for arrows (`\arrow{r}` for right, `\arrow{d}` for down). Much cleaner than raw TikZ for commutative diagrams. Supports curved arrows with `\arrow[bend left]` and diagonal arrows.

---

### forest (Tree Structures)

**Use for:** Syntax trees (linguistics), parse trees (compilers), decision trees, organizational charts, file system hierarchies, game trees, proof trees

**Package:** `\usepackage{forest}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{forest}
\begin{document}

\begin{forest}
[S
  [NP [Det [The]] [N [cat]]]
  [VP [V [sat]] [PP [P [on]] [NP [Det [the]] [N [mat]]]]]
]
\end{forest}

\end{document}
```

**Notes:** Simple bracket notation for tree structure. Automatically handles node placement and spacing. Supports custom node styles, edge labels, and triangular subtrees for linguistic diagrams.

---

### tikz-3dplot (3D Coordinate Systems)

**Use for:** 3D geometry, linear algebra (vectors, planes), physics (coordinate transformations), crystallography, 3D projections

**Package:**
```latex
\usepackage{tikz}
\usepackage{tikz-3dplot}
```

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{tikz,tikz-3dplot}
\begin{document}

\tdplotsetmaincoords{60}{120}
\begin{tikzpicture}[tdplot_main_coords]
\draw[thick,->] (0,0,0) -- (3,0,0) node[anchor=north east]{$x$};
\draw[thick,->] (0,0,0) -- (0,3,0) node[anchor=north west]{$y$};
\draw[thick,->] (0,0,0) -- (0,0,3) node[anchor=south]{$z$};
\draw[blue,thick] (0,0,0) -- (2,2,2);
\end{tikzpicture}

\end{document}
```

**Notes:** `\tdplotsetmaincoords{theta}{phi}` sets viewing angle. Use `tdplot_main_coords` coordinate system. Good for 3D vectors and simple surfaces, but pgfplots is better for 3D data plots.

---

## Physics & Engineering

### tikz-feynman (Feynman Diagrams)

**Use for:** Particle physics, quantum field theory, high-energy physics papers

**Package:** `\usepackage[compat=1.1.0]{tikz-feynman}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage[compat=1.1.0]{tikz-feynman}
\begin{document}

\feynmandiagram[horizontal=a to b]{
  i1 -- [fermion] a -- [fermion] i2,
  a -- [photon] b,
  f1 -- [fermion] b -- [fermion] f2,
};

\end{document}
```

**Notes:** **REQUIRES LuaLaTeX** (compile with `lualatex` instead of `pdflatex`). Automatic graph layout using Lua. Supports fermion lines, photon wavy lines, gluon springs, scalar dashed lines.

---

### circuitikz (Electronic Circuits)

**Use for:** Electrical engineering, analog/digital circuits, schematics, signal flow diagrams

**Package:** `\usepackage{circuitikz}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{circuitikz}
\begin{document}

\begin{circuitikz}
\draw (0,0) to[battery1, l=$V$] (0,3)
  to[R, l=$R_1$] (3,3)
  to[L, l=$L$] (3,0)
  to[short] (0,0);
\draw (3,3) to[C, l=$C$] (3,0);
\end{circuitikz}

\end{document}
```

**Notes:** Rich component library (resistors, capacitors, inductors, op-amps, transistors, logic gates). Use `l=` for labels, `v=` for voltage labels. Supports European and American circuit symbols.

---

### tikz-timing (Timing Diagrams)

**Use for:** Digital logic, hardware verification, signal processing, embedded systems, FPGA design

**Package:** `\usepackage{tikz-timing}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{tikz-timing}
\begin{document}

\begin{tikztimingtable}
CLK & 10{C} \\
DATA & 2L 3H 2L 3H \\
\end{tikztimingtable}

\end{document}
```

**Notes:** `C` = clock pulse, `H` = high, `L` = low, `Z` = high-impedance, `X` = unknown/transition. Number prefix repeats pattern (e.g., `10{C}` = 10 clock cycles).

---

## Chemistry

### chemfig (Chemical Structures)

**Use for:** Organic chemistry, molecular diagrams, structural formulas, reaction mechanisms

**Package:** `\usepackage{chemfig}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{chemfig}
\begin{document}

\chemfig{H-C(-[2]H)(-[6]H)-C(=[1]O)-O-H}

\chemfig{*6(-=-(-)=-=)}

\end{document}
```

**Notes:** Linear syntax for bonds: `-` (single), `=` (double), `~` (triple). Angles: `[0]` = right, `[1]` = 45°, `[2]` = up, etc. `*6(...)` creates hexagon (benzene ring). Supports stereochemistry wedges and ring structures.

---

### mhchem (Chemical Equations)

**Use for:** Chemical equations, reaction stoichiometry, molecular formulas, isotope notation

**Package:** `\usepackage{mhchem}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{mhchem}
\begin{document}

\ce{2H2 + O2 -> 2H2O}

\ce{H2SO4 <=> H+ + HSO4-}

\ce{^{14}_6C}

\end{document}
```

**Notes:** Use `\ce{...}` for chemical notation. Subscripts/superscripts automatic. `->` for reactions, `<=>` for equilibrium. Supports phase notation `(s)`, `(l)`, `(g)`, `(aq)`.

---

## Data Visualization

### pgf-pie (Pie Charts)

**Use for:** Market share, budget breakdowns, survey results, categorical proportions

**Package:** `\usepackage{pgf-pie}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{pgf-pie}
\begin{document}

\begin{tikzpicture}
\pie[radius=2]{
  35/Product A,
  25/Product B,
  20/Product C,
  15/Product D,
  5/Other
}
\end{tikzpicture}

\end{document}
```

**Notes:** Syntax: `percentage/label`. Options: `radius=`, `color=`, `explode=` (separate slice), `text=legend` (legend instead of labels). Auto-colored slices.

---

### pgfplots (fillbetween library)

**Use for:** Area between curves, confidence intervals, statistical ranges, integration visualizations

**Package:**
```latex
\usepackage{pgfplots}
\usepgfplotslibrary{fillbetween}
\pgfplotsset{compat=1.18}
```

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{pgfplots}
\usepgfplotslibrary{fillbetween}
\pgfplotsset{compat=1.18}
\begin{document}

\begin{tikzpicture}
\begin{axis}
\addplot[name path=A, blue] {x^2};
\addplot[name path=B, red] {2*x};
\addplot[fill=green, opacity=0.3] fill between[of=A and B];
\end{axis}
\end{tikzpicture}

\end{document}
```

**Notes:** Use `name path=` to name curves, then `fill between[of=A and B]`. Supports `soft clip` for restricting fill region.

---

### pgfplots (3D Surface Plots)

**Use for:** Multivariable calculus, heat maps, terrain visualization, response surfaces, optimization landscapes

**Package:**
```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
```

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
\begin{document}

\begin{tikzpicture}
\begin{axis}[view={60}{30}]
\addplot3[surf, domain=-2:2, samples=20] {x^2 - y^2};
\end{axis}
\end{tikzpicture}

\end{document}
```

**Notes:** `surf` = surface plot, `mesh` = wireframe, `scatter` = 3D scatter. `view={azimuth}{elevation}` controls viewing angle. Can plot from data files with `\addplot3 table {data.txt};`.

---

## Network & Graph Theory

### tikz-network (Network Graphs)

**Use for:** Social networks, computer networks, neural networks, graph visualization, network topology

**Package:** `\usepackage{tikz-network}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{tikz-network}
\begin{document}

\begin{tikzpicture}
\Vertex[x=0, y=0, label=A]{a}
\Vertex[x=2, y=1, label=B]{b}
\Vertex[x=2, y=-1, label=C]{c}
\Edge[label=5](a)(b)
\Edge[label=3](a)(c)
\Edge[label=2, bend=20](b)(c)
\end{tikzpicture}

\end{document}
```

**Notes:** `\Vertex` creates nodes with position and label. `\Edge` creates connections with optional labels and bend. Supports directed edges with `Direct` option, and styled vertices/edges.

---

### tikz-dependency (Dependency Parsing)

**Use for:** Natural language processing, dependency grammar, syntactic parsing, computational linguistics

**Package:** `\usepackage{tikz-dependency}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{tikz-dependency}
\begin{document}

\begin{dependency}
\begin{deptext}
The \& cat \& sat \& on \& the \& mat \\
\end{deptext}
\deproot{3}{ROOT}
\depedge{2}{1}{det}
\depedge{3}{2}{nsubj}
\depedge{3}{4}{prep}
\depedge{6}{5}{det}
\depedge{4}{6}{pobj}
\end{dependency}

\end{document}
```

**Notes:** `\deptext` defines word sequence. `\depedge{from}{to}{label}` creates dependency arcs. `\deproot{word}{label}` marks root. Automatically manages arc positioning to avoid overlaps.

---

## Business & General

### smartdiagram (Preset Diagram Types)

**Use for:** Presentations, business diagrams, process flows, cyclic diagrams, organizational structures

**Package:** `\usepackage{smartdiagram}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{smartdiagram}
\begin{document}

\smartdiagram[circular diagram]{
  Planning, Design, Development, Testing, Deployment
}

\smartdiagram[priority descriptive diagram]{
  Goal 1/Primary objective,
  Goal 2/Secondary objective,
  Goal 3/Tertiary objective
}

\end{document}
```

**Notes:** Multiple preset types: `circular diagram`, `flow diagram`, `bubble diagram`, `priority descriptive diagram`, `sequence diagram`. Minimal syntax—just list items. Good for quick professional diagrams.

---

### pgfgantt (Gantt Charts)

**Use for:** Project management, timeline planning, task scheduling, resource allocation

**Package:** `\usepackage{pgfgantt}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{pgfgantt}
\begin{document}

\begin{ganttchart}[hgrid, vgrid]{1}{12}
\gantttitle{2026 Project Timeline}{12} \\
\gantttitlelist{1,...,12}{1} \\
\ganttbar{Task 1}{1}{3} \\
\ganttbar{Task 2}{4}{7} \\
\ganttbar{Task 3}{8}{12}
\end{ganttchart}

\end{document}
```

**Notes:** `\ganttbar{label}{start}{end}` creates task bars. `\ganttlink{elem1}{elem2}` adds dependencies. Supports milestones with `\ganttmilestone`, grouped tasks with `\ganttgroup`.

---

### genealogytree (Family Trees)

**Use for:** Genealogy, pedigree charts, family history, inheritance diagrams

**Package:** `\usepackage{genealogytree}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{genealogytree}
\begin{document}

\begin{genealogypicture}
parent{
  g[male]{John Smith}
  p[female]{Jane Doe}
  c[male]{Bob Smith}
  c[female]{Alice Smith}
}
\end{genealogypicture}

\end{document}
```

**Notes:** `g` = grandparent, `p` = parent, `c` = child. Gender specified with `[male]` or `[female]`. Supports multiple generations, marriage links, and custom node styles.

---

### chronosys (Timelines)

**Use for:** Historical timelines, project milestones, biographical chronologies, event sequences

**Package:** `\usepackage{chronosys}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{chronosys}
\begin{document}

\startchronology[startyear=2020, stopyear=2026]
\chronoevent{2020}{Project Start}
\chronoevent{2022}{Milestone 1}
\chronoevent{2024}{Milestone 2}
\chronoevent{2026}{Completion}
\stopchronology

\end{document}
```

**Notes:** Define year range with `startyear`/`stopyear`. Use `\chronoevent{year}{label}` for events. Supports horizontal and vertical timelines, custom styling, and period spans.

---

## Music & Games

### xskak / chessboard (Chess Positions)

**Use for:** Chess puzzles, game notation, chess analysis, chess instruction

**Package:**
```latex
\usepackage{xskak}
\usepackage{chessboard}
```

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{xskak}
\usepackage{chessboard}
\begin{document}

\chessboard[setfen=rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR]

\newchessgame
\mainline{1. e4 e5 2. Nf3 Nc6}
\chessboard

\end{document}
```

**Notes:** `\chessboard[setfen=...]` displays position from FEN notation. `\mainline{...}` parses algebraic notation and updates position. Supports move highlighting, arrows, and custom piece styles.

---

### guitarchordschemes (Guitar Chords)

**Use for:** Guitar instruction, chord charts, music theory, songbooks

**Package:** `\usepackage{guitarchordschemes}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{guitarchordschemes}
\begin{document}

\chordscheme[name=C Major]{x,3,2,0,1,0}

\chordscheme[name=G Major]{3,2,0,0,0,3}

\chordscheme[name=D Minor, barre=1/1-5]{x,x,0,2,3,1}

\end{document}
```

**Notes:** Syntax: 6 strings from low E to high E. `x` = muted, `0` = open string, numbers = fret positions. `barre=fret/string-string` for barre chords. Displays standard chord diagram grid.

---

## Scientific Computing

### siunitx (SI Units & Scientific Notation)

**Use for:** Physics, engineering, scientific papers, data tables with units, measurement reporting

**Package:** `\usepackage{siunitx}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{siunitx}
\begin{document}

\SI{3.0e8}{\meter\per\second}

\SI{9.81}{\meter\per\second\squared}

\num{1.234e-5}

\SI{25}{\celsius}

\end{document}
```

**Notes:** `\SI{value}{unit}` for quantities with units. `\num{value}` for pure numbers with proper formatting. Automatic spacing, exponent formatting, and unit notation. Use `\per` for division, `\squared` for powers.

---

### animate (PDF Animations)

**Use for:** Animated algorithms, step-by-step proofs, dynamic visualizations, presentation builds

**Package:** `\usepackage{animate}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{animate}
\usepackage{tikz}
\begin{document}

\begin{animateinline}[loop, controls]{2}
\multiframe{10}{i=0+1}{
  \begin{tikzpicture}
  \draw (0,0) circle (\i mm);
  \end{tikzpicture}
}
\end{animateinline}

\end{document}
```

**Notes:** **Animations only work in Adobe Reader**. `\begin{animateinline}{fps}` creates inline animation. `\multiframe{n}{counter=start+step}{...}` generates frames. Use `loop` for continuous play, `controls` for play/pause buttons.

---

### standalone (Compile Individual Graphics)

**Use for:** Extracting single diagrams, creating reusable graphics, figure generation pipelines, cropped PDFs

**Package:** `\documentclass{standalone}` (document class, not package)

**Minimal Example:**
```latex
\documentclass{standalone}
\usepackage{tikz}
\begin{document}
\begin{tikzpicture}
\draw (0,0) rectangle (3,2);
\node at (1.5,1) {Diagram};
\end{tikzpicture}
\end{document}
```

**Notes:** Compiles to tightly-cropped PDF containing only the diagram. Use `\standaloneconfig{border=5pt}` to add padding. Perfect for generating figures separately and including via `\includegraphics`.

---

### algorithm2e (Algorithm Typesetting)

**Use for:** Computer science papers, algorithm pseudocode, complexity analysis, technical documentation

**Package:** `\usepackage{algorithm2e}`

**Minimal Example:**
```latex
\documentclass{article}
\usepackage{algorithm2e}
\begin{document}

\begin{algorithm}
\KwData{Array $A$ of size $n$}
\KwResult{Sorted array $A$}
\For{$i \gets 1$ \KwTo $n-1$}{
  \For{$j \gets i+1$ \KwTo $n$}{
    \If{$A[i] > A[j]$}{
      Swap $A[i]$ and $A[j]$\;
    }
  }
}
\caption{Bubble Sort}
\end{algorithm}

\end{document}
```

**Notes:** `\KwData` and `\KwResult` for input/output specification. Control structures: `\For`, `\While`, `\If`, `\ElseIf`, `\Else`. Line terminator `\;` is optional. Use `\caption{}` for algorithm title.

---

### listings / minted (Code Listings with Syntax Highlighting)

**Use for:** Technical documentation, code examples, programming tutorials, software papers

**Package (listings):** `\usepackage{listings}`

**Minimal Example (listings):**
```latex
\documentclass{article}
\usepackage{listings}
\usepackage{xcolor}
\lstset{
  basicstyle=\ttfamily,
  keywordstyle=\color{blue},
  commentstyle=\color{green!60!black},
  stringstyle=\color{red},
  numbers=left
}
\begin{document}

\begin{lstlisting}[language=Python]
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n-1)
\end{lstlisting}

\end{document}
```

**Package (minted):** `\usepackage{minted}`

**Minimal Example (minted):**
```latex
\documentclass{article}
\usepackage{minted}
\begin{document}

\begin{minted}{python}
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n-1)
\end{minted}

\end{document}
```

**Notes:** `listings` is pure LaTeX, works everywhere. `minted` uses Pygments for better syntax highlighting but **requires `-shell-escape` flag** and Python with Pygments installed. Compile with: `pdflatex -shell-escape document.tex`

---

## Quick Reference Table

| Package | Use Case | Special Requirements | Minimal \usepackage |
|---------|----------|---------------------|---------------------|
| tikz-cd | Commutative diagrams (category theory) | None | `\usepackage{tikz-cd}` |
| forest | Tree structures (syntax trees, parse trees) | None | `\usepackage{forest}` |
| tikz-3dplot | 3D coordinate systems and vectors | Requires `\usepackage{tikz}` | `\usepackage{tikz-3dplot}` |
| circuitikz | Electronic circuit diagrams | None | `\usepackage{circuitikz}` |
| pgf-pie | Pie charts | None | `\usepackage{pgf-pie}` |
| tikz-feynman | Feynman diagrams (particle physics) | **Requires LuaLaTeX** | `\usepackage[compat=1.1.0]{tikz-feynman}` |
| tikz-timing | Timing diagrams (digital logic) | None | `\usepackage{tikz-timing}` |
| tikz-network | Network and graph visualization | None | `\usepackage{tikz-network}` |
| tikz-dependency | Dependency parsing (NLP) | None | `\usepackage{tikz-dependency}` |
| smartdiagram | Preset diagram types (circular, flow, bubble) | None | `\usepackage{smartdiagram}` |
| pgfplots fillbetween | Area between curves | Requires pgfplots | `\usepgfplotslibrary{fillbetween}` |
| chemfig | Chemical structure diagrams | None | `\usepackage{chemfig}` |
| mhchem | Chemical equations and formulas | None | `\usepackage{mhchem}` |
| pgfplots 3D | 3D surface plots | Requires pgfplots | `\usepackage{pgfplots}` |
| xskak/chessboard | Chess positions and notation | None | `\usepackage{xskak,chessboard}` |
| guitarchordschemes | Guitar chord diagrams | None | `\usepackage{guitarchordschemes}` |
| pgfgantt | Gantt charts (project management) | None | `\usepackage{pgfgantt}` |
| genealogytree | Family trees and pedigrees | None | `\usepackage{genealogytree}` |
| chronosys | Historical timelines | None | `\usepackage{chronosys}` |
| siunitx | SI units and scientific notation | None | `\usepackage{siunitx}` |
| animate | PDF animations (frame-based) | Adobe Reader only | `\usepackage{animate}` |
| standalone | Compile individual graphics (cropped PDF) | Document class | `\documentclass{standalone}` |
| algorithm2e | Algorithm pseudocode | None | `\usepackage{algorithm2e}` |
| listings | Code syntax highlighting (pure LaTeX) | None | `\usepackage{listings}` |
| minted | Code syntax highlighting (Pygments) | **Requires `-shell-escape` and Python/Pygments** | `\usepackage{minted}` |

---

## Tips

1. **Test compilation:** Most packages work with standard `pdflatex`, but tikz-feynman requires `lualatex` and minted requires `pdflatex -shell-escape`.

2. **Combine packages:** Many packages work together. Use tikz-cd for category theory diagrams in a beamer presentation, or circuitikz with siunitx for labeled circuit values.

3. **Documentation:** All packages have extensive documentation. Run `texdoc <packagename>` (e.g., `texdoc forest`) to view the full manual.

4. **Performance:** Complex TikZ diagrams can slow compilation. Use `standalone` class to compile diagrams separately, then include the resulting PDF.

5. **Color schemes:** Most packages respect TikZ/pgfplots color settings. Define custom colors with `\definecolor` for consistent styling.

6. **External data:** pgfplots can read CSV/TSV files. Use `\addplot table {data.csv};` for data-driven plots.

7. **Minimal examples compile:** Every example in this guide is complete and compilable. Copy-paste to test, then customize for your needs.
