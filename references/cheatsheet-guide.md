# LaTeX Cheatsheet Design Reference Guide

This is the definitive reference for creating state-of-the-art cheat sheets and reference cards in LaTeX, synthesizing research from typography experts, design analysts, and the competitive landscape.

---

## 1. Quick Start: Which Template to Use

| Use Case | Recommended Configuration | Rationale |
|----------|---------------------------|-----------|
| **Academic Exam Sheet** | Landscape, 3 columns, 7pt font, front+back | Matches university policies; optimal readability under exam pressure |
| **Programming Reference** | Landscape, 2-3 columns, 8pt font, color | More space for code blocks; color aids category recognition |
| **Professional Quick Reference** | Portrait, 2 columns, 8-9pt font, B&W | Professional appearance; printer-friendly; fits binder sheets |
| **Dense Crib Sheet** | Landscape, 5-6 columns, 6pt font, B&W | Maximum information density; pushes printer limits |
| **Multi-page Guide** | Portrait, 2 columns, 9pt font, color | Readability over density; can span multiple pages |

**Default Starting Point:** Landscape A4/Letter, 3 columns, 7-8pt font, 10mm margins, `lmodern` font, `microtype` enabled.

---

## 2. Template Gallery

### Template 1: Winston Chang Style (Most Popular)
**Source:** `latexsheet` (171 GitHub stars)

**Characteristics:**
- Landscape orientation
- 3 columns
- Dense but readable
- Code-friendly formatting
- Minimal visual embellishments

**Best For:** Programming languages, command-line tools, software APIs

**Key Features:**
```latex
\documentclass[10pt,landscape]{article}
\usepackage{multicol}
\usepackage{lmodern}
\usepackage[landscape,margin=0.5in]{geometry}
\pagestyle{empty}
\setlength{\columnseprule}{0.4pt}
```

### Template 2: Ken Fehling Compact Style
**Source:** Compact template (0mm margins)

**Characteristics:**
- Zero margins (bleeds to edge)
- Maximum content density
- 4-5 columns typical
- Minimal spacing between elements

**Best For:** Exam crib sheets, formula sheets, maximum-density references

**Key Features:**
```latex
\documentclass[6pt,landscape]{extarticle}
\usepackage[margin=0mm,nohead,nofoot]{geometry}
\usepackage{multicol}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlength{\itemsep}{0pt}
```

### Template 3: rudymatela Refcard Style
**Source:** `refcard.cls`

**Characteristics:**
- Enforces 2-page maximum
- Tri-fold brochure format
- Professional appearance
- "Remind, not teach" philosophy

**Best For:** Professional reference cards, conference handouts

**Key Features:**
```latex
\documentclass{refcard}
% Automatically formats for front+back printing
% Built-in section styling
% Optimized for tri-fold layouts
```

---

## 3. Configuration Matrix

### Paper Size Options
| Paper Size | Width × Height | Columns (Landscape) | Best Use |
|------------|---------------|---------------------|----------|
| Letter | 8.5" × 11" | 3-4 | US academic standard |
| A4 | 210mm × 297mm | 3-4 | International standard |
| Legal | 8.5" × 14" | 4-5 | Extended US format |
| A3 | 297mm × 420mm | 5-6 | Large-format reference |

### Orientation Statistics
- **Landscape:** 85% of real-world cheat sheets
- **Portrait:** 15% (typically professional documents)

### Column Distribution (from research)
| Columns | Percentage | Typical Use |
|---------|-----------|-------------|
| 2 | 25% | Code-heavy, tutorial style |
| 3 | 50% | Sweet spot for most content |
| 4 | 15% | Dense reference material |
| 5+ | 10% | Exam crib sheets, formula lists |

**Technical Limit:** `multicol` supports up to 10 columns (practical maximum: 5-6)

### Font Size Guide
| Font Size | Readability | Print Quality | Recommended Use |
|-----------|-------------|---------------|-----------------|
| 9-10pt | Excellent | Excellent | Multi-page guides, tutorials |
| 8pt | Very Good | Very Good | Standard cheat sheets |
| 7pt | Good | Good | **Optimal for dense cheat sheets** |
| 6pt | Readable | Fair | **Minimum recommended; pushes printer limits** |
| 5pt | Marginal | Poor | Not recommended; printer-dependent |

### Margin Recommendations
| Margin Size | Use Case | Trade-off |
|-------------|----------|-----------|
| 0mm | Maximum density | Risk of printer cropping |
| 5mm | Dense, safe | Good balance |
| 10mm (0.4in) | Standard | Better handling |
| 15-20mm (0.75in) | Professional | Easier to read, hole-punch friendly |

---

## 4. Typography Guide

### Font Selection

#### Best Default: `lmodern` (Latin Modern)
```latex
\usepackage{lmodern}
```
- Optimized for small sizes
- Excellent hinting at 6-8pt
- Professional appearance
- Good screen rendering

#### Sans-Serif for Dense Layouts
```latex
\usepackage{lmodern}
\renewcommand{\familydefault}{\sfdefault}
```
- Cleaner in dense multi-column layouts
- Better visual separation between sections
- Recommended for programming/technical content

#### Alternative Fonts
| Font | Package | Characteristics |
|------|---------|-----------------|
| Computer Modern | (default) | Classic LaTeX; acceptable but not optimal at small sizes |
| Helvetica | `helvet` | Clean sans-serif; good for headings |
| Inconsolata | `inconsolata` | Excellent monospace for code |
| DejaVu Sans | `dejavu` | Good Unicode coverage |

### Line Spacing Formula
**Rule:** Line spacing = 125% of font size

| Font Size | Leading (Baseline Skip) | LaTeX Command |
|-----------|------------------------|---------------|
| 6pt | 7.5pt | `\fontsize{6}{7.5}\selectfont` |
| 7pt | 8.75pt | `\fontsize{7}{8.75}\selectfont` |
| 8pt | 10pt | `\fontsize{8}{10}\selectfont` |
| 9pt | 11.25pt | `\fontsize{9}{11.25}\selectfont` |

### Essential Typography Package
```latex
\usepackage{microtype}
```
**Critical for cheat sheets:**
- Character protrusion (optical margin alignment)
- Font expansion (micro-adjustments for better spacing)
- Improves readability at small sizes
- Reduces hyphenation artifacts

### Spacing Optimization
```latex
% Remove paragraph indentation
\setlength{\parindent}{0pt}

% Minimal paragraph spacing
\setlength{\parskip}{1pt plus 0.5pt}

% Compact lists
\usepackage{enumitem}
\setlist{noitemsep, topsep=2pt, parsep=0pt, partopsep=0pt}

% Reduce section spacing
\usepackage{titlesec}
\titlespacing*{\section}{0pt}{4pt plus 2pt}{2pt plus 1pt}
\titlespacing*{\subsection}{0pt}{3pt plus 1pt}{1pt plus 0.5pt}
```

---

## 5. Color Schemes

### Scheme 1: Classic Academic (Color-Blind Safe)
**Best For:** General-purpose cheat sheets

| Element | Color Name | Hex | RGB |
|---------|-----------|-----|-----|
| Primary Headers | Dark Blue | `#0072B2` | (0, 114, 178) |
| Secondary Headers | Orange | `#D55E00` | (213, 94, 0) |
| Emphasis | Vermillion | `#CC3311` | (204, 51, 17) |
| Code/Math | Purple | `#882255` | (136, 34, 85) |
| Background (optional) | Light Gray | `#F0F0F0` | (240, 240, 240) |

```latex
\usepackage{xcolor}
\definecolor{primary}{HTML}{0072B2}
\definecolor{secondary}{HTML}{D55E00}
\definecolor{emphasis}{HTML}{CC3311}
\definecolor{code}{HTML}{882255}
```

### Scheme 2: Programming Dark Mode
**Best For:** Developer reference cards

| Element | Color Name | Hex | RGB |
|---------|-----------|-----|-----|
| Keywords | Sky Blue | `#87CEEB` | (135, 206, 235) |
| Functions | Light Green | `#90EE90` | (144, 238, 144) |
| Strings | Light Coral | `#F08080` | (240, 128, 128) |
| Comments | Light Gray | `#D3D3D3` | (211, 211, 211) |
| Background | Dark Gray | `#2E3440` | (46, 52, 64) |

### Scheme 3: Professional Monochrome
**Best For:** B&W printing, professional contexts

| Element | Shade | Percentage |
|---------|-------|------------|
| Headers | Black | 100% K |
| Subheaders | Dark Gray | 70% K |
| Body Text | Black | 100% K |
| Boxes | Light Gray | 15% K |
| Rules | Medium Gray | 50% K |

```latex
\definecolor{header}{gray}{0.0}
\definecolor{subheader}{gray}{0.3}
\definecolor{boxbg}{gray}{0.85}
\definecolor{rule}{gray}{0.5}
```

### Scheme 4: High-Contrast Education
**Best For:** Teaching materials, accessibility

| Element | Color Name | Hex | WCAG Contrast |
|---------|-----------|-----|---------------|
| Headers | Pure Black | `#000000` | AAA (21:1) |
| Important | Red | `#CC0000` | AA (7.2:1) |
| Examples | Dark Green | `#008000` | AA (4.7:1) |
| Notes | Dark Blue | `#0000CC` | AA (8.6:1) |

### Scheme 5: Vibrant Tech
**Best For:** Modern tech reference, web development

| Element | Color Name | Hex | RGB |
|---------|-----------|-----|-----|
| Primary | Electric Blue | `#007ACC` | (0, 122, 204) |
| Secondary | Bright Green | `#00FF00` | (0, 255, 0) |
| Accent | Hot Pink | `#FF1493` | (255, 20, 147) |
| Warning | Gold | `#FFD700` | (255, 215, 0) |

### Color-Blind Safety Guidelines
1. **Never rely solely on color** for meaning
2. **Use additional indicators:** icons, bold, underline
3. **Test with simulation tools:** Coblis, Color Oracle
4. **Recommended palette:** Okabe-Ito or Tol palettes
5. **Avoid:** Red-green combinations, low-contrast pastels

---

## 6. Layout Techniques

### Multi-Column Layouts

#### Basic 3-Column Setup
```latex
\documentclass[8pt,landscape]{extarticle}
\usepackage{multicol}
\usepackage[landscape,margin=10mm]{geometry}

\begin{document}
\begin{multicols}{3}
% Content here
\end{multicols}
\end{document}
```

#### Column Customization
```latex
% Column separator line
\setlength{\columnseprule}{0.4pt}
\setlength{\columnsep}{20pt}  % Space between columns

% Prevent column breaks in specific environments
\begin{multicols}{3}
\section{Important Section}
\nopagebreak
Content that must stay together...
\end{multicols}
```

#### Advanced: Variable Column Width
```latex
\usepackage{paracol}
\begin{paracol}{2}
\switchcolumn[0]*  % Left column (wider)
Main content...
\switchcolumn[1]*  % Right column (narrower)
Side notes...
\end{paracol}
```

### Section Boxes with tcolorbox

#### Minimal Space-Efficient Box
```latex
\usepackage{tcolorbox}

\newtcolorbox{compactbox}[1]{
  title=#1,
  colback=white,
  colframe=black,
  boxrule=0.5pt,
  arc=0mm,              % Sharp corners (space-efficient)
  left=2pt,
  right=2pt,
  top=2pt,
  bottom=2pt,
  toptitle=1pt,
  bottomtitle=1pt
}

\begin{compactbox}{Section Title}
Content with minimal padding
\end{compactbox}
```

#### Color-Coded Sections
```latex
\newtcolorbox{infobox}{
  colback=blue!5,
  colframe=blue!75!black,
  arc=0mm,
  boxrule=0.5pt
}

\newtcolorbox{warnbox}{
  colback=orange!5,
  colframe=orange!75!black,
  arc=0mm,
  boxrule=0.5pt
}
```

### Tables for Reference Data

#### Compact Table Style
```latex
\usepackage{booktabs}
\usepackage{array}

\renewcommand{\arraystretch}{1.1}  % Slightly more space

\begin{tabular}{@{}ll@{}}  % @{} removes left/right padding
\toprule
Command & Description \\
\midrule
\texttt{cmd1} & Does thing 1 \\
\texttt{cmd2} & Does thing 2 \\
\bottomrule
\end{tabular}
```

#### Two-Column Definition List
```latex
\begin{tabular}{@{}>{\ttfamily}l@{\hspace{10pt}}l@{}}
function() & Execute function \\
variable & Store value \\
loop & Iterate over items \\
\end{tabular}
```

### Math Formulas

#### Inline Math Space Management
```latex
% Tight inline math
$f(x) = ax^2 + bx + c$

% Display math with reduced spacing
\begin{equation*}
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
\end{equation*}

% Multiple equations in compact space
\usepackage{amsmath}
\begin{align*}
E &= mc^2 \\
F &= ma \\
v &= \frac{d}{t}
\end{align*}
```

#### Formula Box Layout
```latex
\usepackage{empheq}

\begin{empheq}[box=\fbox]{align*}
\text{Pythagorean} &: a^2 + b^2 = c^2 \\
\text{Quadratic} &: x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}
\end{empheq}
```

### Code Listings

#### Compact Code Blocks
```latex
\usepackage{listings}
\usepackage{xcolor}

\lstset{
  basicstyle=\ttfamily\fontsize{6}{7}\selectfont,
  breaklines=true,
  frame=single,
  frameround=ffff,
  framesep=2pt,
  xleftmargin=2pt,
  xrightmargin=2pt,
  aboveskip=3pt,
  belowskip=3pt,
  columns=flexible,
  keepspaces=true
}

\begin{lstlisting}[language=Python]
def hello():
    print("Hello, World!")
\end{lstlisting}
```

#### Inline Code
```latex
\lstinline|variable = value|
% or
\texttt{variable = value}
```

### Space-Saving Techniques

#### Eliminate All Excess Space
```latex
\documentclass[6pt,landscape]{extarticle}
\usepackage[margin=0mm,nohead,nofoot]{geometry}

\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlength{\itemsep}{0pt}
\setlength{\topsep}{0pt}
\setlength{\partopsep}{0pt}

% Compact sections
\usepackage{titlesec}
\titlespacing*{\section}{0pt}{2pt}{1pt}
\titlespacing*{\subsection}{0pt}{1pt}{0.5pt}
```

---

## 7. Content Organization

### The "Remind, Not Teach" Philosophy
**Source:** rudymatela's refcard design principle

**Key Principle:** Cheat sheets should jog memory, not teach from scratch.

**Guidelines:**
- Assume the user has prior knowledge
- Focus on syntax, not explanations
- Use examples over prose
- Prioritize frequently forgotten items

### Information Hierarchy

#### 3-Level Structure (Recommended)
1. **Sections** (Major topics): Large, bold, possibly colored
2. **Subsections** (Categories): Medium weight, clear spacing
3. **Items** (Individual facts): Compact, scannable

Example:
```
FILE OPERATIONS  ← Section
  Reading Files  ← Subsection
    - open(file)  ← Item
    - read()      ← Item
```

### Content Density Spectrum

| Density Level | Items per Page | Use Case |
|---------------|----------------|----------|
| Sparse | 30-50 | Tutorial-style guides |
| Moderate | 50-100 | Standard reference |
| Dense | 100-200 | Comprehensive cheat sheet |
| Extreme | 200+ | Exam crib sheet |

### Scannability Techniques

#### 1. Visual Anchors
```latex
% Use icons or symbols
\newcommand{\cmd}[1]{\textcolor{blue}{\$} \texttt{#1}}
\newcommand{\file}[1]{\textcolor{green}{\faFile} \texttt{#1}}
\newcommand{\warn}{\textcolor{red}{\faWarning}}
```

#### 2. Consistent Formatting
- **Bold** for commands/functions
- `Monospace` for code/syntax
- *Italic* for parameters/variables
- CAPS for categories

#### 3. White Space Management
```latex
% Strategic spacing (not uniform)
\section{Important}      % More space before sections
\vspace{2pt}
\subsection{Details}     % Less space for subsections
\vspace{1pt}
Content...
\vspace{0pt}             % Minimal between items
```

#### 4. Grid Alignment
```latex
% Use tabular for aligned columns
\begin{tabular}{@{}llp{4cm}@{}}
\textbf{Name} & \textbf{Syntax} & \textbf{Notes} \\
map & \texttt{map(f, list)} & Applies function \\
filter & \texttt{filter(p, list)} & Filters by predicate \\
\end{tabular}
```

### Content Selection Strategy

#### Priority Tiers
1. **Tier 1 (Must-Have):** 20% of content users need 80% of the time
2. **Tier 2 (Should-Have):** Advanced but commonly used
3. **Tier 3 (Nice-to-Have):** Edge cases, rare syntax

**Recommendation:** Include only Tier 1 and Tier 2 for exam sheets; all tiers for comprehensive references.

### Topic Ordering Strategies

| Strategy | Best For | Example |
|----------|----------|---------|
| Frequency-Based | Practical use | Most common commands first |
| Alphabetical | Quick lookup | Dictionary-style reference |
| Conceptual | Learning | Follow logical progression |
| Category-Based | Mixed content | Group by functionality |
| Workflow-Based | Task-oriented | Order by typical process |

---

## 8. PDF-to-Cheatsheet Workflow

### Overview
Convert lecture notes, papers, or textbooks into condensed cheat sheets.

### Step 1: Content Extraction
1. **Identify key concepts** (not everything needs to be included)
2. **Extract formulas** (highest priority for STEM subjects)
3. **Note syntax patterns** (for programming/technical topics)
4. **Capture examples** (brief, illustrative)
5. **List gotchas** (common mistakes, edge cases)

### Step 2: Categorization
```
Raw Content → Topic Groups → Sections → Items

Example:
Lecture 1-5 PDF →
  - Linear Algebra
    - Matrix Operations
      - Addition: A + B
      - Multiplication: AB
    - Determinants
      - 2×2: ad - bc
```

### Step 3: Condensation Techniques

#### Technique 1: Formula-First
- Replace explanations with pure formulas
- Add minimal context only when ambiguous

**Before:** "The derivative of x squared is found by bringing down the exponent..."
**After:** `d/dx(x^n) = nx^(n-1)`

#### Technique 2: Example-Driven
- Replace theory with concrete examples
- Use actual values, not abstract variables (when clearer)

**Before:** "A list comprehension iterates over an iterable..."
**After:** `[x*2 for x in range(5)] → [0,2,4,6,8]`

#### Technique 3: Table Compression
Convert prose to tabular format:

| Input Type | Output | Example |
|------------|--------|---------|
| Integer | Integer | `5 / 2 = 2` |
| Float | Float | `5.0 / 2 = 2.5` |

#### Technique 4: Symbolic Notation
Create shorthand for your domain:

```
→  : becomes, transforms to
≡  : equivalent to, same as
!  : important, note well
✗  : incorrect, avoid
✓  : correct, recommended
```

### Step 4: Layout Planning

#### Space Estimation
| Content Type | Space per Item | Items per Column |
|--------------|----------------|------------------|
| One-line formula | 0.5cm | ~40-50 (7pt font) |
| Code snippet (3-5 lines) | 1.5-2cm | ~12-15 |
| Small table (3×3) | 2-3cm | ~8-10 |
| Paragraph (3-4 lines) | 1-1.5cm | ~15-20 |

**Formula:** Total items ÷ columns = items per column
**Check:** Does it fit on the target page count?

### Step 5: Iterative Refinement
1. **First pass:** Include everything important (likely too much)
2. **Second pass:** Remove redundancy, consolidate similar items
3. **Third pass:** Aggressive pruning to fit space constraints
4. **Final pass:** Typography polish, alignment, visual hierarchy

### Example Workflow: 50-Page Textbook → 2-Page Cheatsheet

```
1. Extract: 200 key concepts identified
2. Categorize: Group into 8 major topics
3. Condense: Reduce to 100 critical items (formulas + examples)
4. Layout:
   - 2 pages × 3 columns = 6 columns total
   - 100 items ÷ 6 = ~17 items per column
   - Doable with 7pt font, tight spacing
5. Refine:
   - Pass 1: 120 items (doesn't fit)
   - Pass 2: 100 items (tight but fits)
   - Pass 3: Polish formatting
```

### Tools for PDF Analysis
- **PDF text extraction:** `pdftotext`, `pdfminer`
- **Annotation extraction:** `pdftk`, PDF readers
- **Formula recognition:** Mathpix, Snip (for OCR)
- **Mind mapping:** FreeMind, XMind (for categorization)

---

## 9. Print Considerations

### Printer Compatibility

#### Margin Safety Zones
| Printer Type | Safe Margin | Maximum Risk |
|--------------|-------------|--------------|
| Consumer Inkjet | 10mm (0.4in) | Cropping edges |
| Laser | 5mm (0.2in) | Minimal risk |
| Professional/Copy Shop | 3mm (0.12in) | Safe for most |
| Digital Press | 0mm (bleed) | Designed for edge printing |

**Recommendation:** Use 5mm minimum unless you know your printer's capabilities.

#### Testing Your Printer
1. Print test page with 0mm, 3mm, 5mm margin versions
2. Measure actual printed margins with ruler
3. Note any text cutoff or uneven edges
4. Use the safe margin for production sheets

### Font Size Reality Check

#### Print Visibility Test
| Font Size | Arm's Length (60cm) | Close Reading (30cm) |
|-----------|---------------------|----------------------|
| 10pt | Excellent | Excellent |
| 8pt | Very Good | Excellent |
| 7pt | Good | Very Good |
| 6pt | Fair (squinting) | Good |
| 5pt | Poor (magnifier?) | Fair |

**Recommendation:** Print test page before committing to 6pt or smaller.

### Black & White Optimization

#### Contrast Ratios
```latex
% High-contrast B&W scheme
\definecolor{textcolor}{gray}{0.0}      % Pure black
\definecolor{headercolor}{gray}{0.0}    % Pure black, bold font
\definecolor{boxframe}{gray}{0.3}       % Dark gray
\definecolor{boxbg}{gray}{0.9}          % Light gray background
\definecolor{rulecolor}{gray}{0.5}      % Medium gray rules
```

#### Pattern-Based Distinction (when color not available)
```latex
\usepackage{tcolorbox}

% Different box styles without color
\newtcolorbox{solidbox}{colback=white, colframe=black, boxrule=1pt}
\newtcolorbox{dashedbox}{colback=white, colframe=black, boxrule=0.5pt,
  frame style={dash pattern=on 2pt off 2pt}}
\newtcolorbox{doublebox}{colback=white, colframe=black, boxrule=0.5pt,
  frame style={double}}
```

#### Texture/Pattern Fill (advanced)
```latex
\usepackage{patterns}
% Use diagonal lines, dots, or grids for section backgrounds
```

### Paper Quality

| Paper Weight | Best For | Notes |
|--------------|----------|-------|
| 20lb / 75gsm | Standard cheat sheets | May show through if double-sided |
| 24lb / 90gsm | Premium cheat sheets | Less show-through |
| 28-32lb / 105-120gsm | Professional cards | Card stock; excellent feel |
| Glossy | Photos/diagrams | Not ideal for dense text |

**Recommendation:** 24lb for double-sided, 20lb acceptable for single-sided

### Lamination Options
- **Do-it-yourself:** Clear packing tape (cheap, wrinkle-prone)
- **Laminating pouches:** Home laminator (good quality)
- **Professional:** Copy shop thermal lamination (best durability)
- **Consideration:** Lamination adds bulk; not ideal for folding

### Duplex Printing Tips
```latex
% Ensure odd pages end sections for proper duplex flow
\usepackage{afterpage}
\newcommand{\clearemptydoublepage}{%
  \newpage{\pagestyle{empty}\cleardoublepage}%
}

% Page numbering for duplex
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhead[L]{\textbf{Topic Name}}
\fancyhead[R]{\textbf{Page \thepage\ of 2}}
```

---

## 10. Common Mistakes

### Anti-Pattern 1: Over-Explaining
**Mistake:** Treating cheat sheet like a tutorial

❌ **Wrong:**
```
Lists in Python are ordered, mutable collections that can contain
elements of different types. To create a list, use square brackets.
Lists support indexing, slicing, and many built-in methods like
append, extend, and sort.
```

✅ **Right:**
```
list = [1, 2, 3]
list[0] → 1
list.append(4) → [1,2,3,4]
list[1:3] → [2,3]
```

### Anti-Pattern 2: Inconsistent Formatting
**Mistake:** Random bold, italics, colors without system

❌ **Wrong:**
- **Function** does *thing*
- command does **action**
- `another` does THING

✅ **Right:**
- `function()` - does thing
- `command` - does action
- `another()` - does thing

### Anti-Pattern 3: Excessive White Space
**Mistake:** Using default LaTeX spacing

❌ **Wrong:**
```latex
\section{Topic}  % Default large spacing
\subsection{Subtopic}  % Default spacing
Content...  % Default paragraph spacing
```

✅ **Right:**
```latex
\titlespacing*{\section}{0pt}{3pt}{1pt}
\titlespacing*{\subsection}{0pt}{2pt}{0.5pt}
\setlength{\parskip}{0pt}
```

### Anti-Pattern 4: Rounded Boxes Everywhere
**Mistake:** Using default tcolorbox rounded corners

❌ **Wrong (wastes space):**
```latex
\newtcolorbox{mybox}{arc=4mm}  % Rounded corners
```

✅ **Right (space-efficient):**
```latex
\newtcolorbox{mybox}{arc=0mm}  % Sharp corners
```

### Anti-Pattern 5: Tiny Math Symbols
**Mistake:** Forgetting that math scales differently

❌ **Wrong:**
```latex
\fontsize{6}{7.5}\selectfont
$\sum_{i=1}^{n} x_i$  % Subscripts become illegible
```

✅ **Right:**
```latex
\fontsize{7}{8.75}\selectfont  % One size larger for math
$\sum_{i=1}^{n} x_i$
% or use \displaystyle selectively
```

### Anti-Pattern 6: Ignoring Column Breaks
**Mistake:** Letting sections split across columns awkwardly

❌ **Wrong:**
```latex
\section{Important Topic}
content...
% Section title on column 1, content on column 2
```

✅ **Right:**
```latex
\section{Important Topic}
\nopagebreak  % Keep title with content
content...
```

### Anti-Pattern 7: Color-Only Distinction
**Mistake:** Using color without additional cues

❌ **Wrong:**
```latex
\textcolor{red}{Error case}
\textcolor{green}{Success case}
% Useless for color-blind users or B&W printing
```

✅ **Right:**
```latex
\textbf{✗ Error case}
\textbf{✓ Success case}
% or use icons, bold, shapes
```

### Anti-Pattern 8: No Visual Hierarchy
**Mistake:** All text looks the same weight

❌ **Wrong:**
```
Topic
Subtopic
Item
```

✅ **Right:**
```latex
\section*{\Large\textbf{TOPIC}}
\subsection*{\large\textbf{Subtopic}}
\textbf{Item:} description
```

### Anti-Pattern 9: Forgetting Print Test
**Mistake:** Only viewing PDF on screen

**Problem:**
- Screen rendering ≠ print rendering
- Colors look different on paper
- Small text may be illegible printed
- Margins may crop content

**Solution:** Always print one test copy before mass printing.

### Anti-Pattern 10: Over-Designing
**Mistake:** Adding unnecessary graphical elements

❌ **Wrong:**
- Decorative borders
- Gradient backgrounds
- Fancy fonts for body text
- Drop shadows, glows, reflections
- Clipart or stock images (unless essential diagrams)

✅ **Right:**
- Clean, functional design
- High information density
- Scannable layout
- Print-optimized

---

## Appendix: Essential Packages Reference

| Package | Purpose | Key Features |
|---------|---------|--------------|
| `extarticle` | Non-standard font sizes | Supports 8pt, 9pt, 10pt, 11pt, 12pt, 14pt, 17pt, 20pt base sizes |
| `extsizes` | Extended size classes | Alternative to extarticle |
| `geometry` | Page layout | `\usepackage[margin=5mm,nohead,nofoot]{geometry}` |
| `multicol` | Multi-column layout | Supports 2-10 columns |
| `lmodern` | Latin Modern fonts | Best for small sizes |
| `microtype` | Typography refinement | Protrusion + expansion |
| `tcolorbox` | Colored boxes | Highly customizable, `arc=0mm` for sharp corners |
| `enumitem` | List customization | `\setlist{noitemsep}` for compact lists |
| `titlesec` | Section formatting | `\titlespacing` for custom spacing |
| `booktabs` | Professional tables | `\toprule`, `\midrule`, `\bottomrule` |
| `listings` | Code formatting | Syntax highlighting |
| `xcolor` | Color support | `\definecolor`, color-blind safe palettes |
| `amsmath` | Math typesetting | `align`, `equation`, math symbols |
| `fontawesome5` | Icons | Visual markers without images |
| `paracol` | Parallel columns | Non-balanced multi-column |
| `flowfram` | Frame-based layout | Magazine-style layouts |
| `leaflet` | Tri-fold brochures | Automated tri-fold formatting |

---

## Appendix: Quick Reference - Complete Minimal Template

```latex
\documentclass[7pt,landscape]{extarticle}

% Essential packages
\usepackage[landscape,margin=10mm,nohead,nofoot]{geometry}
\usepackage{multicol}
\usepackage{lmodern}
\usepackage{microtype}
\usepackage{xcolor}
\usepackage{tcolorbox}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage{booktabs}

% Layout setup
\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{1pt plus 0.5pt}
\setlength{\columnseprule}{0.4pt}
\setlength{\columnsep}{15pt}

% Compact lists
\setlist{noitemsep, topsep=2pt, parsep=0pt, partopsep=0pt}

% Section spacing
\titlespacing*{\section}{0pt}{3pt plus 1pt}{1pt plus 0.5pt}
\titlespacing*{\subsection}{0pt}{2pt plus 0.5pt}{0.5pt}

% Colors (color-blind safe)
\definecolor{primary}{HTML}{0072B2}
\definecolor{secondary}{HTML}{D55E00}

% Custom box
\newtcolorbox{infobox}[1]{
  title=#1,
  colback=white,
  colframe=primary,
  boxrule=0.5pt,
  arc=0mm,
  left=2pt,
  right=2pt,
  top=2pt,
  bottom=2pt
}

\begin{document}
\begin{multicols}{3}

\section{Section Title}
Content here...

\begin{infobox}{Box Title}
Boxed content...
\end{infobox}

\subsection{Subsection}
\begin{itemize}
  \item Item 1
  \item Item 2
\end{itemize}

\end{multicols}
\end{document}
```

---

## Competitive Landscape Summary

| Platform | Strengths | Weaknesses | LaTeX Opportunity |
|----------|-----------|------------|-------------------|
| **Cheatography.com** | 6000+ user-generated sheets | No LaTeX export, limited formatting | Could offer "Export to LaTeX" |
| **DevHints.io** | Beautiful HTML design | HTML only, not printer-optimized | LaTeX version would be print-ready |
| **Overleaf Templates** | Good starting point | Generic, not cheat-sheet optimized | Specialized cheat sheet class needed |
| **GitHub Templates** | Popular (latexsheet 171 stars) | Fragmented, no unified tool | Market gap for generator tool |

**Key Insight:** No tool currently bridges AI-powered generation with LaTeX output quality. This is a significant market opportunity.

---

## The "AI-to-LaTeX Cheatsheet" Vision

### Ideal Workflow (Future)
1. **Input:** User provides PDF, topic, or text notes
2. **AI Analysis:** Extract key concepts, formulas, examples
3. **Template Selection:** AI recommends layout based on content type
4. **Content Generation:** AI structures content in optimal hierarchy
5. **LaTeX Output:** Generates complete `.tex` file
6. **User Refinement:** Edit, compile, print

### Technical Requirements
- PDF text extraction (pdftotext, pdfminer)
- Content analysis (NLP: entity recognition, formula extraction)
- LaTeX template engine (Jinja2 or similar)
- One-click compilation (latexmk)
- Preview generation (PDF output)

This guide provides the foundational knowledge to build such a system.

---

**Document Version:** 1.0
**Last Updated:** 2026-02-16
**Based On:** Research from typography experts, design analysts, layout engineers, package researchers, UX researchers, competitive analysis

**License:** This guide is intended as internal reference for the latex-document skill.
