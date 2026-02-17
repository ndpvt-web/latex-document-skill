# LaTeX Accessibility and PDF Compliance Guide

A comprehensive reference for creating accessible, PDF/A-compliant documents from LaTeX, with a focus on thesis submissions and academic publications.

---

## Table of Contents

1. [PDF/A Compliance (Priority for Thesis Submissions)](#1-pdfa-compliance-priority-for-thesis-submissions)
2. [PDF/UA (Universal Accessibility)](#2-pdfua-universal-accessibility)
3. [Accessible Document Design](#3-accessible-document-design)
4. [Font Embedding](#4-font-embedding)
5. [Metadata](#5-metadata)
6. [Validation Tools](#6-validation-tools)

---

## 1. PDF/A Compliance (Priority for Thesis Submissions)

### What is PDF/A and Why Universities Require It

**PDF/A** (PDF for Archiving, ISO 19005) is an ISO-standardized subset of PDF specifically designed for long-term document preservation. Universities, government agencies, and archives require PDF/A because:

**Key characteristics:**
- **Self-contained**: All content (fonts, images, color profiles) is embedded in the file
- **Device-independent**: No external dependencies or references to external resources
- **Reproducible**: Documents render identically across all systems and time periods
- **No encryption**: Ensures permanent accessibility without password barriers
- **Mandatory metadata**: Proper documentation of authorship, title, and keywords

**Why universities require it:**
- Graduate schools archive theses for decades or centuries
- Ensures future researchers can access documents unchanged
- Prevents font substitution issues across different systems
- Meets library and archive preservation standards
- Required by ProQuest/UMI and institutional repositories

**Common PDF/A conformance levels:**

| Variant | Description | When to Use |
|---------|-------------|-------------|
| **PDF/A-1b** | Based on PDF 1.4; basic visual preservation | Most common for thesis submissions; maximum compatibility |
| **PDF/A-1a** | PDF/A-1b + full accessibility tagging | When full screen reader support required |
| **PDF/A-2b** | Based on PDF 1.7; supports JPEG2000, transparency, better compression | Recommended for modern submissions; smaller file sizes |
| **PDF/A-2a** | PDF/A-2b + accessibility tagging | Modern submissions requiring accessibility |
| **PDF/A-3b** | PDF/A-2b + allows embedding non-PDF/A files | When attaching datasets, source code, or supplementary materials |

**Note:** The "b" suffix indicates "basic conformance" (visual appearance only), while "a" requires full structural/semantic tagging for accessibility.

### Using the `pdfx` Package for PDF/A-1b, PDF/A-2b, PDF/A-3b

The `pdfx` package is the most reliable tool for generating PDF/A-compliant documents from LaTeX. It automatically handles color profile embedding, font requirements, and XMP metadata.

#### Basic Setup for PDF/A-1b (Maximum Compatibility)

```latex
\documentclass{article}

% Load pdfx early in preamble for PDF/A-1b compliance
\usepackage[a-1b]{pdfx}

% Font encoding for proper embedding
\usepackage[T1]{fontenc}
\usepackage{lmodern}

% Your regular packages
\usepackage{graphicx}
\usepackage{amsmath}

% hyperref is loaded automatically by pdfx
% Additional hyperref configuration:
\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    citecolor=blue,
    urlcolor=blue,
}

\title{My Thesis Title}
\author{Your Name}

\begin{document}
\maketitle

\section{Introduction}
Your content here.

\end{document}
```

#### PDF/A-2b Setup (Recommended for Modern Submissions)

```latex
% For PDF/A-2b (better compression, smaller files)
\usepackage[a-2b]{pdfx}

% All other settings same as PDF/A-1b
```

**Advantages of PDF/A-2b over PDF/A-1b:**
- JPEG2000 compression support (smaller image file sizes)
- Transparency support (TikZ graphics with transparency work)
- Better compression algorithms (overall smaller PDFs)
- Based on newer PDF 1.7 specification
- OpenType font support

#### PDF/A-3b Setup (With Embedded Files)

```latex
% For PDF/A-3b (can embed supplementary files)
\usepackage[a-3b]{pdfx}

% Embed source files (optional)
\begin{filecontents*}{README.txt}
This thesis includes the source LaTeX files.
\end{filecontents*}

\usepackage{embedfile}
\embedfile{thesis.tex}
\embedfile{references.bib}
```

**Use cases for PDF/A-3:**
- Including raw data files alongside thesis
- Embedding source LaTeX code for reproducibility
- Attaching supplementary materials (CSV, XML, JSON)
- Research data archiving requirements

#### Package Loading Order

**Critical:** Load `pdfx` early in your preamble to avoid conflicts.

```latex
\documentclass{article}

% 1. Load pdfx FIRST (or very early)
\usepackage[a-2b]{pdfx}

% 2. Font encoding and fonts
\usepackage[T1]{fontenc}
\usepackage{lmodern}

% 3. Input encoding and language
\usepackage[utf8]{inputenc}
\usepackage[english]{babel}

% 4. Graphics and color
\usepackage{graphicx}
\usepackage{xcolor}

% 5. Math packages
\usepackage{amsmath,amssymb,amsthm}

% 6. Bibliography
\usepackage[style=numeric]{biblatex}

% 7. Additional hyperref configuration
% (hyperref is already loaded by pdfx)
\hypersetup{
    colorlinks=true,
    linkcolor=black,
    citecolor=black,
    urlcolor=blue,
}

% 8. Other packages
\usepackage{booktabs}
\usepackage{bookmark}
```

### Using `hyperxmp` for XMP Metadata

For advanced XMP (Extensible Metadata Platform) metadata without using `pdfx`, or for additional metadata fields:

```latex
\usepackage{hyperref}
\usepackage{hyperxmp}

\hypersetup{
    pdftitle={Machine Learning Approaches to Climate Prediction},
    pdfauthor={Dr. Jane Smith},
    pdfsubject={Doctoral Dissertation in Computer Science},
    pdfkeywords={machine learning, climate modeling, neural networks, deep learning},
    pdfcopyright={Copyright (C) 2024 by Jane Smith. All rights reserved.},
    pdflicenseurl={https://creativecommons.org/licenses/by/4.0/},
    pdfcaptionwriter={Jane Smith},
    pdfcontactaddress={123 University Avenue},
    pdfcontactcity={Cambridge},
    pdfcontactpostcode={02138},
    pdfcontactcountry={United States},
    pdfcontactemail={jane.smith@example.edu},
    pdfcontacturl={https://example.edu/~jsmith},
    pdflang={en-US},
    pdfmetalang={en-US},
}
```

**When to use hyperxmp:**
- Need more metadata fields than pdfx provides
- Want explicit control over XMP metadata
- Adding copyright and licensing information
- Including contact information
- Not requiring full PDF/A compliance (just metadata)

### Font Embedding Requirements (All Fonts Must Be Embedded)

**PDF/A requires 100% font embedding** - no exceptions. This ensures visual consistency across all systems forever.

#### Ensuring Font Embedding with pdfLaTeX

```latex
% Recommended approach for pdfLaTeX
\usepackage[T1]{fontenc}    % Use Type 1 encoding
\usepackage{lmodern}        % Latin Modern fonts (always embed)
```

**Why this works:**
- Default Computer Modern fonts can be bitmap (Type 3) in older setups
- `lmodern` provides vector versions of Computer Modern
- `[T1]{fontenc}` ensures proper glyph encoding and embedding

#### Safe Font Choices (Always Embed Correctly)

```latex
% Latin Modern (Computer Modern clone, excellent embedding)
\usepackage{lmodern}

% Times-like fonts
\usepackage{mathptmx}        % Times + math
\usepackage{newtxtext,newtxmath}  % Better Times alternative

% Palatino
\usepackage{mathpazo}
\usepackage{newpxtext,newpxmath}  % Better Palatino alternative

% Source fonts
\usepackage{sourceserifpro}
\usepackage{sourcesanspro}
\usepackage{sourcecodepro}

% TeX Gyre fonts (modern, high-quality)
\usepackage{tgtermes}        % Times clone
\usepackage{tgpagella}       % Palatino clone
\usepackage{tgschola}        % Century Schoolbook clone
```

#### XeLaTeX/LuaLaTeX Font Embedding

```latex
% Compile with: xelatex thesis.tex or lualatex thesis.tex
\documentclass{article}
\usepackage{fontspec}

% Use any system font - automatically embedded
\setmainfont{Times New Roman}
\setsansfont{Arial}
\setmonofont{Courier New}

\begin{document}
All fonts are automatically embedded with XeLaTeX/LuaLaTeX.
\end{document}
```

**Advantages of XeLaTeX/LuaLaTeX:**
- Native Unicode support
- Access to any system-installed font (TrueType, OpenType)
- Automatic font embedding
- Better handling of international characters
- Modern font features (ligatures, small caps)

**Requirements:**
- Fonts must be installed on your system
- Fonts must have embeddable license permissions
- Use with `fontspec` package

### Color Space Requirements (No Device-Dependent Colors)

PDF/A prohibits device-dependent color spaces (RGB, CMYK without ICC profiles). The `pdfx` package handles this automatically by embedding ICC color profiles.

#### Automatic Color Conversion

```latex
\usepackage[a-2b]{pdfx}  % Automatically handles color profiles
\usepackage{xcolor}

% Define colors normally - pdfx converts them automatically
\definecolor{customblue}{RGB}{0,83,155}
\definecolor{accentred}{HTML}{C41E3A}
\definecolor{lightgray}{gray}{0.85}

\begin{document}
\textcolor{customblue}{This text uses device-independent color.}
\end{document}
```

**What pdfx does automatically:**
- Embeds sRGB IEC61966-2.1 color profile
- Converts all colors to device-independent color space
- Handles RGB, CMYK, and grayscale correctly
- Ensures consistent color reproduction

#### Manual Color Profile Specification

If you need a specific color profile:

```latex
% In your .xmpdata file:
\OutputIntent{sRGB IEC61966-2.1}

% Or for print (CMYK):
% \OutputIntent{Coated FOGRA39}
```

**Common output intents:**
- `sRGB IEC61966-2.1` - Standard RGB for screen/web
- `Adobe RGB (1998)` - Wider RGB gamut
- `Coated FOGRA39` - Standard European printing
- `U.S. Web Coated (SWOP) v2` - Standard US printing

### Example Preamble for PDF/A Thesis

Complete working example for a thesis submission:

#### thesis.tex

```latex
\documentclass[12pt,oneside]{book}

% ============================================
% PDF/A COMPLIANCE SETUP
% ============================================

% PDF/A-2b compliance (load early!)
\usepackage[a-2b]{pdfx}

% Font encoding and embedding
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage[utf8]{inputenc}

% Language
\usepackage[english]{babel}

% ============================================
% GRAPHICS AND COLORS
% ============================================

\usepackage{graphicx}
\usepackage{xcolor}

% Accessible color definitions (WCAG AA compliant)
\definecolor{linkblue}{RGB}{0,51,160}    % 8.6:1 contrast ratio

% ============================================
% MATHEMATICS
% ============================================

\usepackage{amsmath,amssymb,amsthm}

% Define theorem environments
\newtheorem{theorem}{Theorem}[chapter]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}

% ============================================
% TABLES
% ============================================

\usepackage{booktabs}
\usepackage{array}

% ============================================
% BIBLIOGRAPHY
% ============================================

\usepackage[style=numeric,backend=biber,sorting=nyt]{biblatex}
\addbibresource{references.bib}

% ============================================
% HYPERLINKS AND BOOKMARKS
% ============================================

% hyperref is loaded automatically by pdfx
% Configure hyperref options:
\hypersetup{
    colorlinks=true,
    linkcolor=linkblue,
    citecolor=linkblue,
    urlcolor=linkblue,
    bookmarks=true,
    bookmarksopen=true,
    bookmarksnumbered=true,
    pdfstartview={FitH},
    pdfpagemode=UseOutlines,
}

% Better bookmarks
\usepackage{bookmark}

% ============================================
% DOCUMENT STRUCTURE
% ============================================

\setcounter{tocdepth}{3}        % TOC depth
\setcounter{secnumdepth}{3}     % Section numbering depth

\begin{document}

% ============================================
% FRONT MATTER
% ============================================

\frontmatter

\title{Advances in Machine Learning for Climate Prediction}
\author{Jane Elizabeth Smith}
\date{May 2024}

\maketitle

% Abstract
\begin{abstract}
This dissertation presents novel approaches to climate prediction
using deep learning techniques. We demonstrate significant improvements
in accuracy and computational efficiency.
\end{abstract}

% Table of contents
\tableofcontents
\listoffigures
\listoftables

% ============================================
% MAIN MATTER
% ============================================

\mainmatter

\chapter{Introduction}

This chapter introduces the research problem and motivation.

\section{Background}

Background information here.

\subsection{Climate Modeling}

Details about climate modeling.

\chapter{Related Work}

Literature review here.

\chapter{Methodology}

Our proposed approach.

\chapter{Experiments}

Experimental results and analysis.

\chapter{Conclusion}

Summary and future work.

% ============================================
% BACK MATTER
% ============================================

\backmatter

% Bibliography
\printbibliography[heading=bibintoc]

% Appendices (if needed)
\appendix
\chapter{Additional Results}

Supplementary material here.

\end{document}
```

#### thesis.xmpdata

Create this file in the same directory as `thesis.tex`:

```latex
% thesis.xmpdata - Metadata for PDF/A compliance

\Title{Advances in Machine Learning for Climate Prediction}
\Author{Jane Elizabeth Smith}
\Language{en-US}
\Subject{A dissertation submitted in partial fulfillment of the requirements for the degree of Doctor of Philosophy in Computer Science}
\Keywords{machine learning\sep climate prediction\sep deep learning\sep neural networks\sep time series forecasting}
\Publisher{Massachusetts Institute of Technology}
\PublicationType{Doctoral Thesis}
\Date{2024-05-15}
\Copyrighted{True}
\CopyrightOwner{Jane Elizabeth Smith}
\CopyrightYear{2024}
\Org{Department of Electrical Engineering and Computer Science}
\Producer{LaTeX with pdfx package}
\Contact{jane.smith@mit.edu}
```

**Critical metadata fields:**
- `\Title{}` - Full thesis title (appears in PDF properties)
- `\Author{}` - Your full name as it appears on title page
- `\Language{}` - ISO language code (en-US, en-GB, de-DE, etc.)
- `\Subject{}` - Brief description of the document
- `\Keywords{}` - Use `\sep` to separate keywords (not commas!)
- `\Date{}` - ISO format: YYYY-MM-DD
- `\Publisher{}` - Your university name
- `\Copyrighted{}` - True or False
- `\CopyrightOwner{}` - Copyright holder (usually you)

#### Compilation Commands

```bash
# Standard compilation
pdflatex thesis.tex
biber thesis           # or bibtex thesis
pdflatex thesis.tex    # Second pass for references
pdflatex thesis.tex    # Third pass for TOC/cross-refs

# Or use latexmk (recommended)
latexmk -pdf thesis.tex

# For XeLaTeX
latexmk -xelatex thesis.tex
```

---

## 2. PDF/UA (Universal Accessibility)

### Current State of `tagpdf` (Experimental, Expected Stable ~2027)

**PDF/UA** (PDF for Universal Accessibility, ISO 14289) is the international standard for accessible PDFs, requiring proper document structure and tagging for assistive technologies.

#### Current LaTeX Accessibility Landscape (2024-2025)

**The tagpdf package:**
- **Status**: Experimental, actively developed by the LaTeX Project
- **Expected stable release**: Approximately 2027
- **Current capabilities**: Basic tagging for standard document structures
- **Limitations**: Not production-ready for complex documents

**Important reality check:**
- Most thesis submissions currently **do not require** full PDF/UA compliance
- Universities typically require only PDF/A (archival format)
- Full PDF/UA compliance from LaTeX is still emerging technology
- Check your specific requirements before investing time in PDF/UA

#### Experimental tagpdf Usage

For those wanting to experiment with tagging:

```latex
\DocumentMetadata{
    lang=en-US,
    pdfversion=2.0,
    pdfstandard=ua-2,
    testphase={phase-III,math,table,title}
}
\documentclass{article}

\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{graphicx}

% tagpdf is loaded automatically with DocumentMetadata

\begin{document}

\title{Accessible Document Example}
\author{Author Name}
\maketitle

\section{Introduction}

This document has basic tagging support.

\begin{figure}[ht]
\centering
\includegraphics[width=0.6\textwidth]{chart.pdf}
\caption{Revenue by quarter}
\label{fig:revenue}
\end{figure}

\end{document}
```

**What works (as of 2024-2025):**
- Basic heading hierarchy (section, subsection, etc.)
- Paragraphs and text structure
- Simple lists (itemize, enumerate)
- Basic tables with clear structure
- Figures with captions
- Footnotes and citations

**What doesn't work well yet:**
- Complex tables with merged cells
- Advanced math tagging
- Multi-column layouts
- TikZ/PGF graphics tagging
- Some package combinations
- Complex float positioning

### What Tagged PDFs Mean

A **tagged PDF** contains a logical structure tree separate from the visual content. This structure defines:

**Document structure:**
- Semantic hierarchy (headings, paragraphs, lists)
- Reading order independent of visual layout
- Relationships between content elements
- Alternative descriptions for non-text content

**Benefits for users:**
- **Screen readers** can navigate by headings, skip to content
- **Text-to-speech** reads in logical order, not visual order
- **Reflow** for mobile devices and zooming
- **Content extraction** more reliable and semantic
- **Search** understands document structure

**Structure elements in PDF/UA:**

| PDF Tag | Purpose | LaTeX Equivalent |
|---------|---------|------------------|
| H1-H6 | Headings | `\section`, `\subsection`, etc. |
| P | Paragraph | Normal text blocks |
| L | List | `itemize`, `enumerate` |
| LI | List item | `\item` |
| Table | Table | `tabular` environment |
| TR | Table row | Table rows |
| TH | Table header | Bold header cells |
| TD | Table data | Regular cells |
| Figure | Figure/image | `\includegraphics` |
| Caption | Caption | `\caption{}` |
| Formula | Math | `$...$`, `\[...\]` |

### Basic Tagging with accessibility Package

The `accessibility` package provides minimal accessibility improvements without full tagging:

```latex
\usepackage{accessibility}

\begin{document}

% Provides some accessibility metadata hints
% but does NOT produce fully tagged PDFs

\section{Introduction}

The accessibility package adds basic metadata
but is NOT a substitute for full PDF/UA compliance.

\end{document}
```

**What it does:**
- Sets document language
- Adds basic metadata hints
- Improves hyperref compatibility
- Minor structural improvements

**What it doesn't do:**
- Full PDF/UA tagging
- Alternative text for images
- Complete structure tree
- Reading order definition

**Bottom line:** The `accessibility` package is better than nothing but far from full PDF/UA compliance.

### Alt Text for Figures: `\pdftooltip` and `\Description`

#### Method 1: Using pdfcomment for Tooltips

```latex
\usepackage{pdfcomment}
\usepackage{graphicx}

\begin{figure}[ht]
\centering
\pdftooltip{%
    \includegraphics[width=0.8\textwidth]{sales_chart.pdf}%
}{Bar chart showing monthly sales from January to December 2023.
Peak sales of $450K occurred in December, while the lowest sales
of $180K occurred in February. Overall trend shows 15% year-over-year
growth with seasonal peaks in Q4.}
\caption{Monthly sales figures for 2023}
\label{fig:sales}
\end{figure}
```

**Limitations:**
- Creates tooltip, not true PDF/UA alt text
- May not be read by all screen readers
- Better than nothing for PDF/A submissions

#### Method 2: Descriptive Captions (Practical Approach)

```latex
\begin{figure}[ht]
\centering
\includegraphics[width=0.9\textwidth]{system_architecture.pdf}
\caption{System architecture diagram showing three-tier design:
         client tier (web browsers and mobile apps) connects via
         HTTPS to application tier (load balancer distributing
         requests to three application servers running Node.js),
         which connects to data tier (PostgreSQL cluster with
         primary and two read replicas). Redis cache sits between
         application and database layers for performance.}
\label{fig:architecture}
\end{figure}
```

**Advantage:** Screen readers always read captions, so comprehensive captions provide context even without true alt text.

#### Method 3: Using tagpdf (Full Compliance)

```latex
\DocumentMetadata{
    lang=en-US,
    pdfstandard=ua-2,
    testphase={phase-III}
}
\documentclass{article}

\begin{document}

\begin{figure}[ht]
\centering
\tagstructbegin{tag=Figure}
\tagmcbegin{tag=Figure,alttext={Scatter plot showing positive
    correlation between training epochs (x-axis, 0-200) and
    model accuracy (y-axis, 60-95%). Accuracy increases rapidly
    until 100 epochs reaching 92%, then plateaus. Data points
    shown as blue circles with trend line in red.}}
\includegraphics[width=0.8\textwidth]{accuracy_plot.pdf}
\tagmcend
\tagstructend
\caption{Model accuracy versus training epochs}
\label{fig:accuracy}
\end{figure}

\end{document}
```

**Best practice:** This is the correct approach for true PDF/UA compliance, but requires tagpdf (experimental).

#### Guidelines for Writing Good Alt Text

**Principles:**
1. **Be concise but complete** - Typically 1-3 sentences
2. **Describe the content and purpose**, not appearance
3. **Include key data points** for charts and graphs
4. **Describe relationships** in diagrams
5. **Skip obvious information** already in caption or surrounding text
6. **Don't start with "Image of..."** - it's implied
7. **For decorative images**, mark as artifact (screen readers skip)

**Examples:**

❌ **Bad:** "A graph"
✅ **Good:** "Line graph showing exponential growth in user adoption from 100 users in January to 10,000 users in December"

❌ **Bad:** "Image of the system architecture diagram"
✅ **Good:** "Three-tier architecture with client layer, application layer containing load balancer and three servers, and database layer with primary database and two replicas"

❌ **Bad:** "This is a picture showing various colored bars"
✅ **Good:** "Bar chart comparing performance of five algorithms: Algorithm A scored 85%, B scored 91% (highest), C scored 78%, D scored 82%, and E scored 88%"

---

## 3. Accessible Document Design

### Color Contrast (WCAG 2.1 AA Minimum 4.5:1)

**WCAG 2.1 (Web Content Accessibility Guidelines)** defines minimum contrast ratios for accessible text:

#### WCAG AA Standards (Target This Level)

| Content Type | Minimum Contrast | Ratio |
|--------------|------------------|-------|
| Normal text (< 18pt) | 4.5:1 | AA |
| Large text (≥ 18pt or ≥ 14pt bold) | 3:1 | AA |
| UI components and graphics | 3:1 | AA |

#### WCAG AAA Standards (Enhanced)

| Content Type | Minimum Contrast | Ratio |
|--------------|------------------|-------|
| Normal text | 7:1 | AAA |
| Large text | 4.5:1 | AAA |

**Most organizations target WCAG AA (4.5:1 for normal text).**

#### Common Color Combinations and Contrast Ratios

```latex
\usepackage{xcolor}

% Excellent contrast (AAA level)
\definecolor{black}{RGB}{0,0,0}           % Black on white: 21:1
\definecolor{darkgray}{RGB}{51,51,51}     % on white: 12.6:1
\definecolor{darkblue}{RGB}{0,51,160}     % on white: 8.6:1

% Good contrast (AA level)
\definecolor{medgray}{RGB}{117,117,117}   % on white: 4.54:1 (just passes AA)

% Poor contrast (FAILS AA) - avoid
\definecolor{lightgray}{RGB}{180,180,180} % on white: 2.3:1 (FAILS)
\definecolor{lightblue}{RGB}{100,149,237} % on white: 3.4:1 (FAILS for normal text)
```

#### Accessible Color Palette for LaTeX Documents

```latex
\usepackage{xcolor}

% Text colors (all pass WCAG AA on white background)
\definecolor{textblack}{RGB}{0,0,0}           % 21:1
\definecolor{textdarkgray}{RGB}{51,51,51}     % 12.6:1
\definecolor{textblue}{RGB}{0,51,160}         % 8.6:1
\definecolor{textred}{RGB}{153,0,0}           % 6.1:1
\definecolor{textgreen}{RGB}{0,100,0}         % 5.3:1

% Paul Tol's colorblind-safe palette
\definecolor{tolblue}{RGB}{68,119,170}
\definecolor{tolcyan}{RGB}{102,204,238}
\definecolor{tolgreen}{RGB}{34,136,51}
\definecolor{tolyellow}{RGB}{204,187,68}
\definecolor{tolred}{RGB}{238,102,119}
\definecolor{tolpurple}{RGB}{170,51,119}
\definecolor{tolgrey}{RGB}{187,187,187}
```

#### Testing Color Contrast

**Online tools:**
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Coolors Contrast Checker: https://coolors.co/contrast-checker
- Colour Contrast Analyzer: https://www.tpgi.com/color-contrast-checker/

**Testing your PDF:**
```bash
# Print in grayscale to test
lp -o ColorModel=Gray thesis.pdf

# Or convert to grayscale PDF
gs -sOutputFile=thesis_gray.pdf -sDEVICE=pdfwrite \
   -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray \
   -dCompatibilityLevel=1.4 thesis.pdf
```

### Don't Use Color Alone to Convey Meaning

**The principle:** Information should be perceivable without color (for colorblind users and printed grayscale).

#### Bad Examples (Color-Only Information)

```latex
% DON'T DO THIS
In Figure~\ref{fig:results}, \textcolor{red}{red points}
represent errors and \textcolor{green}{green points}
represent successes.

% Also problematic:
See the \textcolor{blue}{blue line} for Method A and
\textcolor{red}{red line} for Method B.
```

**Problem:** Colorblind users (8% of men, 0.5% of women) cannot distinguish red/green.

#### Good Examples (Multiple Visual Cues)

```latex
% DO THIS INSTEAD
In Figure~\ref{fig:results}, errors are shown as red triangles (▲)
and successes are shown as green circles (●).

% Or:
Method A is shown as a solid blue line, while Method B is shown
as a dashed red line.
```

#### Implementing Redundant Encoding in Plots

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

\begin{tikzpicture}
\begin{axis}[
    xlabel=Time (s),
    ylabel=Temperature (°C),
    legend pos=north west,
    width=0.8\textwidth,
]
% Method A: Blue + solid + circles
\addplot[color=blue, mark=*, thick] coordinates {
    (0,20) (1,25) (2,32) (3,41) (4,52)
};

% Method B: Red + dashed + squares
\addplot[color=red, mark=square*, dashed, thick] coordinates {
    (0,20) (1,23) (2,27) (3,33) (4,40)
};

\legend{Method A (solid, circles), Method B (dashed, squares)}
\end{axis}
\end{tikzpicture}
```

**Multiple distinguishing features:**
- **Color** (blue vs red)
- **Line style** (solid vs dashed)
- **Markers** (circles vs squares)
- **Text labels** in legend

### Meaningful Alt Text for Images

See [Section 2: Alt Text for Figures](#alt-text-for-figures-pdftooltip-and-description) for detailed implementation.

**Quick guidelines:**
- Describe what the image conveys, not what it looks like
- Include specific data values for charts
- Describe relationships in diagrams
- Keep it concise (1-3 sentences usually sufficient)
- More complex images can have longer descriptions in surrounding text

### Logical Reading Order

**Reading order** determines how screen readers traverse your document. LaTeX typically produces correct reading order for standard document structures.

#### Good Practices for Reading Order

```latex
% CORRECT: Logical hierarchy
\section{Methods}
\subsection{Data Collection}
Text about data collection appears here.

\subsection{Analysis}
Text about analysis appears here.

% Figure near its reference maintains reading order
\begin{figure}[ht]  % 'ht' = here or top
\centering
\includegraphics{diagram.pdf}
\caption{Data collection workflow}
\end{figure}
```

#### Avoid Reading Order Problems

```latex
% PROBLEMATIC: Manual positioning breaks reading order
\begin{textblock*}{5cm}(10cm,5cm)
This text will be out of reading order!
\end{textblock*}

% PROBLEMATIC: Figures far from references
The workflow is shown in Figure~\ref{fig:workflow}.

% ... 5 pages of text ...

\begin{figure}[p]  % 'p' = separate page
\includegraphics{workflow.pdf}
\caption{Workflow}
\label{fig:workflow}
\end{figure}
```

**Best practices:**
- Use semantic commands (`\section`, `\subsection`)
- Keep figures near their textual references
- Avoid manual positioning with `textpos` or TikZ overlays
- Don't use tables for layout (only for tabular data)
- Use `[ht]` or `[htbp]` float placement, avoid `[p]` when possible

### Table Headers with `\thead` or Accessibility Markup

#### Basic Accessible Table

```latex
\usepackage{booktabs}

\begin{table}[ht]
\centering
\caption{Experimental results comparing three methods}
\label{tab:results}
\begin{tabular}{lrrr}
\toprule
\textbf{Method} & \textbf{Accuracy (\%)} & \textbf{Precision} & \textbf{Recall} \\
\midrule
Method A        & 85.3 & 0.82 & 0.88 \\
Method B        & 91.2 & 0.89 & 0.93 \\
Method C        & 78.1 & 0.76 & 0.81 \\
\bottomrule
\end{tabular}
\end{table}
```

**Key elements:**
- `\caption{}` provides table context
- First row is clearly headers (bold text)
- `\toprule`, `\midrule`, `\bottomrule` for visual structure
- Avoid vertical lines (visual clutter)

#### Using makecell for Complex Headers

```latex
\usepackage{booktabs}
\usepackage{makecell}

\begin{table}[ht]
\centering
\caption{Performance metrics across datasets}
\label{tab:performance}
\begin{tabular}{lccc}
\toprule
\textbf{Dataset} & \thead{Accuracy\\(\%)} & \thead{F1\\Score} & \thead{Training\\Time (min)} \\
\midrule
ImageNet  & 92.5 & 0.91 & 120 \\
CIFAR-10  & 95.3 & 0.94 & 45 \\
MNIST     & 99.1 & 0.99 & 15 \\
\bottomrule
\end{tabular}
\end{table}
```

**The `\thead` command:**
- Creates multi-line headers
- Automatically centers text
- Maintains header semantics

#### Avoid Complex Merged Cells

```latex
% PROBLEMATIC: Complex merged cells confuse screen readers
\begin{tabular}{|l|c|c|c|c|}
\hline
\multirow{2}{*}{Method} & \multicolumn{2}{c|}{Dataset A} & \multicolumn{2}{c|}{Dataset B} \\
\cline{2-5}
& Acc & Prec & Acc & Prec \\
\hline
Method A & 0.85 & 0.82 & 0.87 & 0.84 \\
\hline
\end{tabular}

% BETTER: Simpler structure
\begin{tabular}{lcccc}
\toprule
\textbf{Method} & \textbf{A-Acc} & \textbf{A-Prec} & \textbf{B-Acc} & \textbf{B-Prec} \\
\midrule
Method A & 0.85 & 0.82 & 0.87 & 0.84 \\
\bottomrule
\end{tabular}
```

### List Structure Preservation

Use semantic list environments to maintain structure:

#### Unordered Lists

```latex
\begin{itemize}
    \item Machine learning algorithms show promise for climate prediction
    \item Deep learning models require significant computational resources
    \item Transfer learning can reduce training time substantially
\end{itemize}
```

#### Ordered Lists

```latex
\begin{enumerate}
    \item Collect and preprocess historical climate data
    \item Train neural network model on 80\% of data
    \item Validate model performance on remaining 20\%
    \item Deploy model for real-time prediction
\end{enumerate}
```

#### Description Lists

```latex
\begin{description}
    \item[PDF/A] ISO standard for long-term document archival,
                 requiring font embedding and color profiles
    \item[PDF/UA] ISO standard for universal accessibility,
                  requiring tagged content and alt text
    \item[PDF/X] ISO standard for print production,
                 ensuring consistent color reproduction
\end{description}
```

**Never do this:**

```latex
% BAD: Manual list formatting loses semantic structure
1. First item\\
2. Second item\\
3. Third item\\

% BAD: Using tables to fake lists
\begin{tabular}{ll}
$\bullet$ & First item \\
$\bullet$ & Second item \\
\end{tabular}
```

---

## 4. Font Embedding

### Checking Font Embedding: `pdffonts` Command

The `pdffonts` utility (part of Poppler tools) displays all fonts used in a PDF:

```bash
pdffonts thesis.pdf
```

#### Sample Output (Good - All Fonts Embedded)

```
name                                 type              emb sub uni object ID
------------------------------------ ----------------- --- --- --- ---------
ABCDEF+LMRoman10-Regular             Type 1C           yes yes yes      8  0
GHIJKL+LMRoman12-Bold                Type 1C           yes yes yes     12  0
MNOPQR+LMRoman10-Italic              Type 1C           yes yes yes     15  0
STUVWX+LMMono10-Regular              Type 1C           yes yes yes     18  0
```

**What each column means:**

- **name**: Font name (prefix like "ABCDEF+" indicates subset)
- **type**: Font format (Type 1, Type 1C, TrueType, CID Type 0, Type 3)
- **emb**: Embedded? **MUST be "yes" for PDF/A**
- **sub**: Subsetted? (Only used characters embedded - saves space)
- **uni**: Unicode mapping? (Allows text search/copy)
- **object ID**: Internal PDF object reference

#### Problematic Output (Not PDF/A Compliant)

```
name                                 type              emb sub uni object ID
------------------------------------ ----------------- --- --- --- ---------
Helvetica                            Type 1            no  no  no      25  0
Times-Roman                          Type 1            no  no  yes     30  0
Symbol                               Type 3            yes yes no      35  0
```

**Problems identified:**
- ❌ Helvetica: **NOT embedded** (emb = no) → PDF/A validation will fail
- ❌ Times-Roman: **NOT embedded** → Will use substitute fonts on other systems
- ⚠️ Symbol: Type 3 font (bitmap) → Allowed if embedded, but vector fonts preferred

### Forcing Font Embedding with fontenc/lmodern

#### Standard Solution for pdfLaTeX

```latex
\documentclass{article}

% These three lines ensure font embedding
\usepackage[T1]{fontenc}     % Use Type 1 encoding
\usepackage{lmodern}         % Latin Modern fonts (vector)
\usepackage[utf8]{inputenc}  % UTF-8 input support

\begin{document}
All text will use embedded Latin Modern fonts.
Math symbols and special characters also embedded.
\end{document}
```

**Why this works:**
- Default LaTeX uses OT1 encoding (old, limited)
- Some OT1 fonts might not embed properly
- `[T1]{fontenc}` switches to T1 encoding (modern, better coverage)
- `lmodern` provides T1-encoded vector fonts guaranteed to embed
- `lmodern` is a modernized version of Computer Modern

#### Alternative Font Packages (All Embed Properly)

```latex
% Times-like serif font
\usepackage{mathptmx}
% or better:
\usepackage{newtxtext,newtxmath}

% Palatino-like serif font
\usepackage{mathpazo}
% or better:
\usepackage{newpxtext,newpxmath}

% TeX Gyre Termes (Times clone)
\usepackage{tgtermes}
\usepackage[T1]{fontenc}

% Source Serif Pro
\usepackage{sourceserifpro}

% Libertine
\usepackage{libertine}
\usepackage[libertine]{newtxmath}
```

All these packages provide fonts that embed correctly in PDF/A.

### XeLaTeX/LuaLaTeX Automatic Embedding

**Modern TeX engines (XeLaTeX and LuaLaTeX) automatically embed all fonts:**

```latex
% Compile with: xelatex thesis.tex or lualatex thesis.tex
\documentclass{article}

\usepackage{fontspec}

% Use any installed system font
\setmainfont{Times New Roman}
\setsansfont{Arial}
\setmonofont{Courier New}

% Or specify font files directly
\setmainfont{TeX Gyre Termes}[
    Extension=.otf,
    UprightFont=*-Regular,
    BoldFont=*-Bold,
    ItalicFont=*-Italic,
    BoldItalicFont=*-BoldItalic,
]

\begin{document}
All fonts automatically embedded with XeLaTeX/LuaLaTeX.
\end{document}
```

**Advantages:**
- Automatic font embedding (no manual configuration needed)
- Native Unicode support
- Access to OpenType font features (ligatures, small caps, etc.)
- Better international character support
- Can use system-installed fonts

**Font license check:**
- Ensure fonts have embedding permissions
- Commercial fonts may restrict embedding
- Free fonts (Google Fonts, SIL Open Font License) generally allow embedding

### Common Non-Embedded Font Issues

#### Issue 1: Standard PDF Base Fonts Not Embedded

```latex
% PROBLEM: These fonts may not embed
\usepackage{helvet}
\renewcommand{\familydefault}{\sfdefault}

% SOLUTION: Use embeddable alternatives
\usepackage{tgheros}  % TeX Gyre Heros (Helvetica clone)
\renewcommand{\familydefault}{\sfdefault}

% Or with lmodern:
\usepackage{lmodern}
\renewcommand{\familydefault}{\sfdefault}  % Use Latin Modern Sans
```

#### Issue 2: Math Fonts Missing

```latex
% PROBLEM: Math without proper font package
$E = mc^2$  % May use non-embedded fonts

% SOLUTION: Use complete font packages
\usepackage{lmodern}           % Includes math fonts
\usepackage{amsmath,amssymb}   % Extended math symbols

% Or specific math font packages:
\usepackage{mathptmx}  % Times math
\usepackage{mathpazo}  % Palatino math
\usepackage{newtxmath} % New TX math
```

#### Issue 3: Special Characters from External Fonts

```latex
% PROBLEM: Special characters may pull in external fonts
Copyright © 2024
Trademark ™

% SOLUTION: Use LaTeX commands
Copyright \textcopyright{} 2024
Trademark \texttrademark{}

% Or load textcomp
\usepackage{textcomp}
\textcopyright, \texttrademark, \textregistered
```

#### Issue 4: Including External PDFs

```latex
% When including external PDFs:
\includegraphics{external_figure.pdf}

% CRITICAL: Check the external PDF has embedded fonts!
% Run: pdffonts external_figure.pdf
```

**Solution for external PDFs with font issues:**
1. Regenerate the PDF with embedded fonts
2. Convert to image format (PNG/JPG) if vector not needed
3. Use Ghostscript to re-embed fonts:

```bash
gs -dBATCH -dNOPAUSE -dSAFER -sDEVICE=pdfwrite \
   -dEmbedAllFonts=true -dSubsetFonts=true \
   -sOutputFile=output.pdf input.pdf
```

---

## 5. Metadata

### `\hypersetup{pdftitle, pdfauthor, pdfsubject, pdfkeywords}`

Basic metadata using hyperref (works without pdfx):

```latex
\usepackage{hyperref}

\hypersetup{
    % Required metadata
    pdftitle={Machine Learning Approaches to Medical Image Analysis},
    pdfauthor={Dr. Jane Elizabeth Smith},
    pdfsubject={Doctoral Dissertation in Computer Science},
    pdfkeywords={machine learning, medical imaging, deep learning, computer vision, diagnostics},

    % Language
    pdflang={en-US},

    % Display settings
    pdfstartview={FitH},           % Fit width when opened
    pdfpagemode=UseOutlines,       % Show bookmarks panel

    % Link colors (accessibility-friendly)
    colorlinks=true,
    linkcolor=blue,                % Internal links
    citecolor=blue,                % Citations
    urlcolor=blue,                 % External URLs
    filecolor=blue,                % File links

    % Bookmarks
    bookmarks=true,
    bookmarksopen=true,
    bookmarksnumbered=true,
    bookmarksopenlevel=2,

    % PDF creator information
    pdfcreator={LaTeX with hyperref},
    pdfproducer={pdfTeX-1.40.25},
}
```

#### Metadata Fields Explained

**Core fields (always include):**
- `pdftitle` - Full document title (appears in PDF viewer title bar)
- `pdfauthor` - Author name(s) (separate multiple authors with commas)
- `pdfsubject` - Brief description (e.g., "Doctoral thesis in Physics")
- `pdfkeywords` - Comma-separated keywords for searchability
- `pdflang` - ISO language code (en-US, en-GB, de-DE, fr-FR, zh-CN, etc.)

**Display fields:**
- `pdfstartview` - How PDF opens: `FitH` (fit width), `FitV` (fit height), `Fit` (fit page)
- `pdfpagemode` - Initial view: `UseOutlines` (show bookmarks), `UseThumbs` (show thumbnails), `FullScreen`

**Technical fields:**
- `pdfcreator` - Application that created the source (e.g., "Microsoft Word")
- `pdfproducer` - PDF generator (e.g., "pdfTeX", "XeTeX")

### Document Language: `\usepackage[english]{babel}`

Declaring document language is critical for:
- Screen reader pronunciation
- Hyphenation patterns
- Spell checking
- Accessibility compliance

```latex
% Single language
\usepackage[english]{babel}

% Multiple languages (last one is default)
\usepackage[french,german,english]{babel}  % Main language: English

% Switching languages in document
\documentclass{article}
\usepackage[french,english]{babel}

\begin{document}

This text is in English.

\begin{otherlanguage}{french}
Ce texte est en français.
\end{otherlanguage}

Back to English.

\end{document}
```

#### Common Language Codes

| Language | Babel | ISO 639-1 | pdflang |
|----------|-------|-----------|---------|
| English (US) | `english` or `american` | en | en-US |
| English (UK) | `british` or `UKenglish` | en | en-GB |
| German | `german` or `ngerman` | de | de-DE |
| French | `french` | fr | fr-FR |
| Spanish | `spanish` | es | es-ES |
| Italian | `italian` | it | it-IT |
| Portuguese | `portuguese` | pt | pt-PT |
| Chinese | - | zh | zh-CN |
| Japanese | - | ja | ja-JP |

**For XeLaTeX/LuaLaTeX, use polyglossia:**

```latex
\usepackage{polyglossia}
\setdefaultlanguage{english}
\setotherlanguage{french}
\setotherlanguage{german}
```

### XMP Metadata with hyperxmp

For extended metadata beyond basic hyperref:

```latex
\usepackage{hyperref}
\usepackage{hyperxmp}

\hypersetup{
    % Basic metadata
    pdftitle={Advances in Quantum Computing Algorithms},
    pdfauthor={Dr. Jane Smith},
    pdfsubject={Doctoral Dissertation},
    pdfkeywords={quantum computing, algorithms, complexity theory},
    pdflang={en-US},

    % Copyright and licensing
    pdfcopyright={Copyright (C) 2024 by Jane Smith. All rights reserved.},
    pdflicenseurl={https://creativecommons.org/licenses/by/4.0/},
    pdfcaptionwriter={Jane Smith},

    % Publication metadata
    pdfpubtype={thesis},
    pdfpublication={Massachusetts Institute of Technology},
    pdfpublisher={MIT Libraries},

    % Contact information
    pdfcontactaddress={77 Massachusetts Avenue},
    pdfcontactcity={Cambridge},
    pdfcontactregion={MA},
    pdfcontactpostcode={02139},
    pdfcontactcountry={United States},
    pdfcontactemail={jane.smith@mit.edu},
    pdfcontacturl={https://example.edu/~jsmith},
    pdfcontactphone={+1-617-555-1234},

    % Additional author information
    pdfauthortitle={PhD Candidate},

    % Dates
    pdfdate={2024-05-15},

    % Technical
    pdfmetalang={en-US},
}
```

#### Creative Commons Licensing

```latex
% CC BY 4.0 (Attribution)
\hypersetup{
    pdfcopyright={Copyright (C) 2024 Jane Smith.
        Licensed under Creative Commons Attribution 4.0 International.},
    pdflicenseurl={https://creativecommons.org/licenses/by/4.0/},
}

% CC BY-NC-ND 4.0 (Attribution-NonCommercial-NoDerivs)
\hypersetup{
    pdfcopyright={Copyright (C) 2024 Jane Smith.
        Licensed under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0.},
    pdflicenseurl={https://creativecommons.org/licenses/by-nc-nd/4.0/},
}

% All Rights Reserved
\hypersetup{
    pdfcopyright={Copyright (C) 2024 Jane Smith. All rights reserved.},
    pdflicenseurl={},
}
```

---

## 6. Validation Tools

### veraPDF for PDF/A Validation

**veraPDF** is the industry-standard, open-source PDF/A validator officially endorsed by the PDF Association.

#### Installation

```bash
# macOS with Homebrew
brew install verapdf

# Download standalone installer
# Visit: https://verapdf.org/software/

# Docker
docker pull verapdf/verapdf
```

#### Command-Line Usage

```bash
# Validate PDF/A-1b
verapdf --flavour 1b thesis.pdf

# Validate PDF/A-2b (most common for modern submissions)
verapdf --flavour 2b thesis.pdf

# Validate PDF/A-3b
verapdf --flavour 3b thesis.pdf

# Detailed text report
verapdf --flavour 2b --format text thesis.pdf

# HTML report (human-readable)
verapdf --flavour 2b --format html thesis.pdf > report.html

# XML report (machine-readable)
verapdf --flavour 2b --format xml thesis.pdf > report.xml

# Validate multiple files
verapdf --flavour 2b *.pdf

# Recursive directory validation
verapdf --flavour 2b --recurse /path/to/pdfs/

# Docker usage
docker run --rm -v $(pwd):/data verapdf/verapdf \
    --flavour 2b /data/thesis.pdf
```

#### Understanding veraPDF Output

**Successful validation:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<validationReport
    profileName="PDF/A-2B validation profile"
    statement="PDF file is compliant with Validation Profile requirements."
    compliant="true">
  <details passedRules="127" failedRules="0" passedChecks="1543"/>
</validationReport>
```

Key indicator: `compliant="true"`

**Failed validation:**

```xml
<validationReport
    profileName="PDF/A-2B validation profile"
    statement="PDF file is not compliant with Validation Profile requirements."
    compliant="false">
  <details passedRules="125" failedRules="2" passedChecks="1540"/>
  <validationResults>
    <validationResult specification="ISO 19005-2:2011" clause="6.2.11.3">
      <rule status="failed">
        <description>All fonts must be embedded</description>
        <test>emb == true</test>
        <error>Font 'Helvetica' is not embedded</error>
      </rule>
    </validationResult>
  </validationResults>
</validationReport>
```

Key indicator: `compliant="false"` with detailed error descriptions.

#### Common Validation Errors and Fixes

**Error 1: Fonts not embedded**

```
Error: Font 'Helvetica' is not embedded
Clause: 6.2.11.3
```

**Fix:**
```latex
\usepackage[T1]{fontenc}
\usepackage{lmodern}
```

**Error 2: Missing XMP metadata**

```
Error: Document title is missing from XMP metadata
Clause: 6.7.11
```

**Fix:** Create `.xmpdata` file or use `\hypersetup{pdftitle={...}}`

**Error 3: Color profile missing**

```
Error: Output intent color profile is missing
Clause: 6.2.4.3
```

**Fix:** Use `pdfx` package which includes sRGB profile automatically

**Error 4: Transparency not allowed (PDF/A-1 only)**

```
Error: Transparency is not allowed in PDF/A-1
Clause: 6.4
```

**Fix:** Switch to PDF/A-2 or remove transparent elements

**Error 5: Encryption present**

```
Error: Encrypted documents are not allowed
Clause: 6.1.3
```

**Fix:** Remove password protection or encryption

### PAC (PDF Accessibility Checker)

**PAC 2024** is a free tool for checking PDF/UA compliance and accessibility features.

#### Download and Installation

- Website: https://pac.pdf-ua.org/
- Platform: Windows (works in Wine on macOS/Linux)
- License: Free

#### Features

- Validates PDF/UA compliance
- Checks document structure and tagging
- Screen reader preview mode
- Logical structure viewer
- Reading order display
- Alternative text checking
- Detailed accessibility reports

#### Using PAC

1. **Open PDF:** Launch PAC and open your PDF file
2. **Check PDF/UA:** Click "Check PDF" button
3. **Review Results:**
   - **Document tab:** Overall compliance summary
   - **Pages tab:** Page-by-page issues
   - **Errors tab:** Detailed error list
4. **Screen Reader Preview:** Click "Screen Reader Preview" to see how screen readers interpret the PDF
5. **Reading Order:** Click "Visual Read Order" to verify content sequence
6. **Export Report:** Save validation report for documentation

#### Common PAC Errors

**Error: No document title set**
```
Fix: Set pdftitle in \hypersetup{}
```

**Error: Document language not specified**
```
Fix: Add \usepackage[english]{babel} and pdflang={en-US}
```

**Error: Images without alternative text**
```
Fix: Add alt text using tagpdf or descriptive captions
```

**Error: Tables without headers**
```
Fix: Use \textbf{} for header row and proper table structure
```

**Error: Incorrect reading order**
```
Fix: Avoid manual positioning; use semantic structure
```

### Adobe Acrobat Pro Accessibility Checker

If you have Adobe Acrobat Pro ($239.88/year subscription):

#### Running Full Accessibility Check

1. Open PDF in Acrobat Pro
2. **Tools** → **Accessibility** → **Full Check**
3. Select report options:
   - Create Accessibility Report
   - Include repair hints
   - Check specific page range (optional)
4. Click **Start Checking**

#### Accessibility Report Checks

**Document properties:**
- Document title set
- Language specified
- Security allows accessibility
- Bookmarks present

**Page content:**
- All content tagged
- Reading order logical
- Images have alt text
- Color contrast sufficient
- Text not embedded in images

**Tables:**
- Headers marked
- Structure logical
- No merged cells or handled properly

**Forms (if applicable):**
- Form fields accessible
- Labels present
- Tab order logical

#### Fixing Issues in Acrobat

**Autotag Document:**
- Tools → Accessibility → Autotag Document
- Adds basic structure tags automatically
- Imperfect but good starting point

**Set Alternative Text:**
- Tools → Accessibility → Set Alternate Text
- Manually add descriptions to images

**Reading Order Tool:**
- Tools → Accessibility → Reading Order
- Visual interface to fix reading sequence
- Drag to reorder content blocks

**Add Tags to Document:**
- Tools → Accessibility → Add Tags to Document
- Manual tagging for complex structures

#### Limitations

- **Expensive:** Requires Pro subscription
- **Not reproducible:** Manual fixes don't persist if you regenerate PDF from LaTeX
- **Time-consuming:** Must repeat for every document version
- **Better for final polish:** Use for final submission, not iterative development

### Command-Line Validation Script

Automate validation with a shell script:

```bash
#!/bin/bash
# validate_pdf.sh - Comprehensive PDF validation

PDF="$1"

if [ ! -f "$PDF" ]; then
    echo "Usage: $0 <pdf_file>"
    exit 1
fi

echo "========================================="
echo "PDF Validation Report"
echo "========================================="
echo "File: $PDF"
echo "Date: $(date)"
echo

echo "========================================="
echo "1. PDF Information"
echo "========================================="
pdfinfo "$PDF"
echo

echo "========================================="
echo "2. Font Embedding Check"
echo "========================================="
echo "All fonts should show 'yes' in 'emb' column:"
pdffonts "$PDF"
echo

echo "========================================="
echo "3. PDF/A Validation (PDF/A-2b)"
echo "========================================="
verapdf --flavour 2b "$PDF"
echo

echo "========================================="
echo "4. File Size"
echo "========================================="
ls -lh "$PDF" | awk '{print "Size: " $5}'
echo

echo "========================================="
echo "5. Page Count"
echo "========================================="
pdfinfo "$PDF" | grep "Pages:"
echo

echo "========================================="
echo "Validation Complete"
echo "========================================="
```

**Usage:**

```bash
chmod +x validate_pdf.sh
./validate_pdf.sh thesis.pdf > validation_report.txt
```

---

## Summary: Quick Reference Checklist

### For PDF/A-Compliant Thesis (Most Common)

**Minimum requirements:**

```latex
\documentclass[12pt]{book}

% PDF/A-2b compliance
\usepackage[a-2b]{pdfx}

% Font embedding
\usepackage[T1]{fontenc}
\usepackage{lmodern}

% Language
\usepackage[english]{babel}

% Your packages here
\usepackage{graphicx}
\usepackage{amsmath}

% Configure hyperlinks
\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    citecolor=blue,
    urlcolor=blue,
}

\begin{document}
% Your content
\end{document}
```

**Create `thesis.xmpdata`:**

```latex
\Title{Your Thesis Title}
\Author{Your Name}
\Language{en-US}
\Subject{Doctoral dissertation description}
\Keywords{keyword1\sep keyword2\sep keyword3}
\Publisher{Your University}
\Date{2024-05-15}
\Copyrighted{True}
\CopyrightOwner{Your Name}
```

**Validate:**

```bash
pdffonts thesis.pdf       # Check all fonts embedded
verapdf --flavour 2b thesis.pdf  # Validate PDF/A-2b
```

### Pre-Submission Checklist

- [ ] PDF/A validated with veraPDF (compliant="true")
- [ ] All fonts embedded (pdffonts shows "yes" for all)
- [ ] Metadata complete (title, author, keywords, language)
- [ ] Color contrast meets WCAG AA (4.5:1 minimum)
- [ ] Figures have captions and descriptive text
- [ ] Tables have headers and captions
- [ ] Bookmarks/TOC present
- [ ] No encryption or security restrictions
- [ ] File size under university limits
- [ ] Tested in multiple PDF viewers

---

## Additional Resources

**Official standards:**
- ISO 19005 (PDF/A): https://www.iso.org/standard/76583.html
- ISO 14289 (PDF/UA): https://www.iso.org/standard/64599.html
- WCAG 2.1: https://www.w3.org/WAI/WCAG21/quickref/

**LaTeX packages:**
- pdfx: https://ctan.org/pkg/pdfx
- tagpdf: https://ctan.org/pkg/tagpdf
- hyperref: https://ctan.org/pkg/hyperref
- hyperxmp: https://ctan.org/pkg/hyperxmp

**Validation tools:**
- veraPDF: https://verapdf.org/
- PAC 2024: https://pac.pdf-ua.org/
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/

**Color resources:**
- Paul Tol's Palettes: https://personal.sron.nl/~pault/
- ColorBrewer: https://colorbrewer2.org/
- Coblis Color Blindness Simulator: https://www.color-blindness.com/coblis-color-blindness-simulator/

**Further reading:**
- PDF Association: https://pdfa.org/
- W3C Web Accessibility: https://www.w3.org/WAI/
- LaTeX Font Catalogue: https://tug.org/FontCatalogue/

---

**Document size: ~15.2 KB**

Good luck with your accessible LaTeX documents!
