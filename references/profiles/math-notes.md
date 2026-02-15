# Conversion Profile: Math / Science Notes

Use this profile when the PDF contains: equations, theorems, proofs, definitions, lemmas, Greek symbols, matrices, integrals, mathematical notation.

## Formatting Mode

This profile supports two formatting modes. **Default to beautiful mode** unless the user explicitly requests plain output.

### Beautiful Mode (Default)

Use the `lecture-notes.tex` template from `assets/templates/`. This produces professional, textbook-quality output with:
- KOMA-Script document class (`scrartcl`) with Palatino font
- Color-coded `tcolorbox` theorem environments (blue theorems, green definitions, orange examples)
- TikZ graph/diagram generation from hand-drawn figures
- Styled section headings, headers/footers, and micro-typography

### Plain Mode

Use the plain preamble below for maximum compatibility and minimal styling. Suitable when the user wants raw LaTeX output or needs to integrate into an existing document.

## Suggested Preamble (Plain Mode)

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

## Suggested Preamble (Beautiful Mode)

Use the preamble from `assets/templates/lecture-notes.tex` directly. It includes everything from the plain preamble plus:

- **Font**: `mathpazo` (Palatino) with `microtype` for professional typography
- **Document class**: `scrartcl` (KOMA-Script) for better type area and section styling
- **Colored theorem environments**: via `tcolorbox` with `tcbuselibrary{theorems, skins, breakable}`
  - `theorem` (blue, sharp corners) -- important statements
  - `lemma` (lighter blue) -- supporting results
  - `corollary` (blue-gray) -- consequences
  - `definition` (green, rounded corners) -- introduces concepts
  - `example` (orange, left accent bar) -- worked illustrations
  - `remark` (purple left border) -- observations
  - `notebox` (red left border) -- warnings / important notes
  - `proof` (gray-blue left border) -- derivations with auto QED
- **TikZ graph styles**: pre-defined `vertex`, `svertex`, `hvertex`, `edge`, `dedge`, `hedge` styles and reusable macros (`\CompleteGraph`, `\CycleGraph`, `\PathGraph`)
- **Section styling**: `titlesec` with colored headings and underline rule
- **Headers/footers**: `fancyhdr` with section name and page number
- **Navigation**: `hyperref` + `cleveref` for smart cross-references
- **Graph theory commands**: `\V`, `\E`, `\deg`, `\diam`, `\dist`, `\Aut`, `\chr`

**Important**: The beautiful mode preamble uses `hyperref`. This is safe because the theorem environments are defined with `tcolorbox` (not `amsthm`), which avoids the `\set@color` conflict. Do NOT mix `amsthm` theorem definitions with `hyperref` -- use `tcolorbox` theorems exclusively in beautiful mode.

## Structural Patterns to Recognize

- **Theorem/Lemma/Proposition**: Boxed or labeled statements
  - Plain mode: `\begin{theorem}...\end{theorem}`
  - Beautiful mode: `\begin{theorem}{Title}{label}...\end{theorem}`  (tcolorbox takes title + label args)
- **Definitions**: Usually underlined key term
  - Plain mode: `\begin{definition}...\end{definition}`
  - Beautiful mode: `\begin{definition}{Title}{label}...\end{definition}`
- **Proofs**: Starts with "Proof:" or "Pf:", ends with QED symbol -> `\begin{proof}...\end{proof}`
- **Examples**: Starts with "Example:" or "Ex:"
  - Plain mode: `\begin{example}...\end{example}`
  - Beautiful mode: `\begin{example}{Title}{label}...\end{example}`
- **Remarks**: Side notes, observations
  - Plain mode: `\begin{remark}...\end{remark}`
  - Beautiful mode: `\begin{remark}...\end{remark}` (no title/label args)
- **Important notes**: Warnings, critical observations
  - Beautiful mode only: `\begin{notebox}...\end{notebox}`
- **Multi-line derivations**: Aligned at `=` signs -> `align*` environment
- **Single important equations**: Standalone display -> `equation*` environment
- **Matrices**: Arrays of numbers in brackets -> `pmatrix` or `bmatrix`
- **Diagrams/Graphs**: Convert to TikZ code (see Diagram Conversion below)

## Diagram Conversion (Beautiful Mode)

When converting handwritten notes with diagrams, **generate TikZ code** instead of skipping figures or using `\includegraphics`. The template provides pre-defined styles:

### Node Styles
- `vertex` -- standard circle node (blue fill, 8mm)
- `svertex` -- small vertex for dense graphs (5mm)
- `hvertex` -- highlighted vertex (red border)
- `rvertex`, `bvertex`, `gvertex`, `yvertex` -- red/blue/green/yellow filled vertices (for graph coloring)

### Edge Styles
- `edge` -- standard thick gray edge
- `dedge` -- directed edge with arrow
- `hedge` -- highlighted edge (red, very thick)
- `weight` -- edge label style (white background)

### Reusable Macros
- `\CompleteGraph[radius]{n}` -- draws K_n in a circle
- `\CycleGraph[radius]{n}` -- draws C_n in a circle
- `\PathGraph{n}` -- draws P_n horizontally

### Common Graph Patterns

**Complete graph K_n:**
```latex
\begin{tikzpicture}
  \CompleteGraph[1.5cm]{5}
\end{tikzpicture}
```

**Complete bipartite K_{m,n}:**
```latex
\begin{tikzpicture}
  % Left partition
  \foreach \i in {1,...,3} {
    \node[bvertex] (l\i) at (0, {2.5 - 1.25*(\i-1)}) {$u_{\i}$};
  }
  % Right partition
  \foreach \i in {1,...,3} {
    \node[rvertex] (r\i) at (4, {2.5 - 1.25*(\i-1)}) {$v_{\i}$};
  }
  \foreach \i in {1,...,3} {
    \foreach \j in {1,...,3} {
      \draw[edge, opacity=0.7] (l\i) -- (r\j);
    }
  }
\end{tikzpicture}
```

**Petersen graph:**
```latex
\begin{tikzpicture}[scale=1.3]
  \foreach \i in {1,...,5} {
    \node[vertex] (out\i) at ({90 + 72*(\i-1)}:2cm) {};
  }
  \foreach \i in {1,...,5} {
    \node[vertex] (in\i) at ({90 + 72*(\i-1)}:0.9cm) {};
  }
  \foreach \i in {1,...,5} {
    \pgfmathtruncatemacro{\next}{mod(\i, 5) + 1}
    \draw[edge] (out\i) -- (out\next);
  }
  \foreach \i in {1,...,5} {
    \pgfmathtruncatemacro{\next}{mod(\i + 1, 5) + 1}
    \draw[edge] (in\i) -- (in\next);
  }
  \foreach \i in {1,...,5} {
    \draw[edge, dashed] (out\i) -- (in\i);
  }
\end{tikzpicture}
```

**Graph with adjacency matrix (side-by-side):**
```latex
\begin{tikzpicture}
  \node[vertex] (v1) at (0,2) {$v_1$};
  \node[vertex] (v2) at (2,2) {$v_2$};
  \node[vertex] (v3) at (2,0) {$v_3$};
  \node[vertex] (v4) at (0,0) {$v_4$};
  \draw[edge] (v1)--(v2) (v2)--(v3) (v3)--(v4) (v4)--(v1) (v1)--(v3);
  \node at (4,1) {\Large$\longrightarrow$};
  \node at (7,1) {$A(G) = \begin{pmatrix} 0&1&1&1 \\ 1&0&1&0 \\ 1&1&0&1 \\ 1&0&1&0 \end{pmatrix}$};
\end{tikzpicture>
```

**Graph coloring:**
```latex
\begin{tikzpicture}
  \node[rvertex] (v1) at ({90}:1.5cm) {$1$};
  \node[bvertex] (v2) at ({18}:1.5cm) {$2$};
  \node[gvertex] (v3) at ({-54}:1.5cm) {$3$};
  \node[rvertex] (v4) at ({-126}:1.5cm) {$4$};
  \node[bvertex] (v5) at ({-198}:1.5cm) {$5$};
  \draw[edge] (v1)--(v2)--(v3)--(v4)--(v5)--(v1);
\end{tikzpicture>
```

**Euler/Hamilton path highlighting:**
```latex
% Draw all edges in light gray first, then overlay the path in color
\draw[edge, gray!40] (v1) -- (v2);  % background
\draw[hedge, -{Stealth[length=3mm]}, HighlightRed] (v1) -- (v2);  % highlighted path
```

**Tree structure:**
```latex
\begin{tikzpicture}[
  level 1/.style={sibling distance=3cm},
  level 2/.style={sibling distance=1.5cm}
]
  \node[vertex] {1}
    child {node[vertex] {2}
      child {node[vertex] {4}}
      child {node[vertex] {5}}
    }
    child {node[vertex] {3}
      child {node[vertex] {6}}
      child {node[vertex] {7}}
    };
\end{tikzpicture>
```

### Diagram Conversion Rules

1. **Always attempt TikZ generation** for graph diagrams -- nodes + edges are structurally simple enough
2. **Describe what you see** before generating code: count vertices, identify edges, note layout
3. **Use pre-defined styles** (`vertex`, `edge`, etc.) for consistency
4. **For complex or ambiguous diagrams**: generate best-effort TikZ and add a comment `% TODO: verify diagram matches original`
5. **For non-graph diagrams** (coordinate systems, function plots): use `pgfplots` or describe in a comment for manual recreation
6. **Place diagrams in `\begin{center}...\end{center}`** inside example/theorem boxes, or as standalone figures

## Worker Agent Hints

- Use `\section*{}` for unnumbered section headings (matching handwritten headers)
- Red or colored annotations in original: `{\color{red}text}` (or use `{\color{NoteRed}text}` in beautiful mode)
- When equations span multiple lines, prefer `align*` with `&` alignment at `=`
- Close ALL environments before the end of your batch -- if a proof spans your boundary, close it and note `% continues in next batch`
- Subscript notation: be careful with `D_{x_i}f` vs `\frac{\partial f}{\partial x_i}`
- Use `\left( \right)` for auto-sized delimiters around fractions
- Inline math for short expressions: `$f(x) = x^2$`
- Display math for important results: `\[ f'(x) = 2x \]`

### Beautiful Mode Specific Hints

- **tcolorbox theorem syntax**: `\begin{theorem}{Title}{label}` not `\begin{theorem}` alone. Title can be descriptive (e.g., "Handshaking Lemma"). Label is a short key (e.g., "handshaking").
- **Remark and notebox** do NOT take title/label arguments: just `\begin{remark}...\end{remark}`
- **Proof** uses standard `\begin{proof}...\end{proof}` (rendered with left border via tcolorbox)
- **Diagrams inside boxes**: Place `\begin{center}\begin{tikzpicture}...\end{tikzpicture}\end{center}` inside example environments
- **Section headings**: Use numbered sections (`\section{}`) -- they auto-style with blue headings and underline
- **Labeled vertices in TikZ**: Use `{$v_1$}` or `{$1$}` for math-mode labels

## Critical LaTeX Constraints (Beautiful Mode)

Worker agents MUST follow these rules. Violation causes compilation failure.

### Commands You MUST NOT Invent

Do NOT use any command that is not defined in the preamble. Common mistakes:
- `\pentagon`, `\hexagon`, `\octagon` -- these do NOT exist. Draw shapes with TikZ `\node[regular polygon, regular polygon sides=5]` or use `\draw` commands.
- Any `\foo` command that "seems like it should exist" -- verify it is in the preamble first.

### Commands Available in the Preamble

| Command | Purpose | Example |
|---|---|---|
| `\R`, `\N`, `\Z`, `\Q`, `\C` | Number sets | `$f: \R \to \R$` |
| `\V`, `\E` | Vertex/edge set | `$\V(G) = \{1,2,3\}$` |
| `\deg` | Vertex degree | `$\deg(v) = 3$` |
| `\diam`, `\dist` | Diameter, distance | `$\diam(G) = 4$` |
| `\Aut`, `\chr` | Automorphism, chromatic | `$\chr(G) = 3$` |
| `\abs{}`, `\norm{}`, `\floor{}`, `\ceil{}` | Delimiters | `$\abs{x-y}$` |
| `\circled{n}` | Circled number (annotation) | `$\circled{1}$` |
| `\sout{text}` | Strikethrough text | `\sout{deleted}` |
| `\cancel{expr}` | Strikethrough in math | `$\cancel{x+1}$` |

### TikZ Strict Rules

1. **Every command ends with `;`**: `\node[vertex] (v1) at (0,0) {$v_1$};`
2. **Every `\node` has label braces**: Even empty: `\node[vertex] (v1) at (0,0) {};`
3. **All TikZ inside tikzpicture**: Never write `\node` or `\draw` outside `\begin{tikzpicture}...\end{tikzpicture}`
4. **Polar coordinates for circular layouts**: Use `(60:1.5cm)` NOT `({cos(60)},{sin(60)})`
5. **`edge`/`dedge`/`hedge` are EDGE styles**: Use `\draw[edge]`, NEVER `\node[edge]`
6. **`vertex`/`svertex`/`hvertex` are NODE styles**: Use `\node[vertex]`, NEVER `\draw[vertex]`

### Environment Nesting Rules

1. **No floats inside tcolorbox**: Do NOT use `\begin{table}[H]` or `\begin{figure}[H]` inside `theorem`, `example`, `definition`, `lemma`, `corollary`, `remark`, `notebox`, or `proof`. Use `\begin{tabular}` directly (no `table` wrapper).
2. **No `tabular` inside math**: Do NOT put `\begin{tabular}` inside `align*` or `equation*`. End the math first, then start the tabular.
3. **`proof` inside `example`**: Allowed, but MUST close `\end{proof}` BEFORE `\end{example}`.
4. **Enumerate labels**: Use `\begin{enumerate}` without options (labels pre-configured: level 1 = (i), level 2 = (a)). For custom labels: `\begin{enumerate}[label=(\alph*)]`.

## Common Pitfalls

1. **Mismatched environments**: The #1 error source. Always pair `\begin{X}` with `\end{X}`. Count your opens and closes before finishing.
2. **Stray `&` characters**: `&` is a column separator in tables/align. Outside these environments it causes errors. Escape as `\&` in text.
3. **Missing `$` delimiters**: Forgetting to close inline math mode. Every `$` needs a matching `$`.
4. **Nested environments**: `align*` inside `theorem` is fine. But don't cross-nest (`\begin{theorem}...\begin{align*}...\end{theorem}...\end{align*}` = error).
5. **Beautiful mode tcolorbox args**: `\begin{theorem}{Title}{label}` requires BOTH title AND label. Use `{}` for empty label if not needed: `\begin{theorem}{My Theorem}{}`.
6. **hyperref in plain mode**: Do NOT include `hyperref` in plain mode with `amsthm` theorems -- causes `\set@color` errors. In beautiful mode (tcolorbox theorems), `hyperref` is safe and included in the template.
7. **TikZ inside tcolorbox**: Works fine, but ensure `breakable` is set on the box if the diagram is large. The template already sets `breakable` on example boxes.
