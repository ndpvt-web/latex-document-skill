# Poster Design Guide

Comprehensive reference for creating professional academic conference posters. Read this when creating any poster.

## Conference Size Presets

Always ask the user which conference the poster is for. Use these presets:

| Preset | Orientation | Dimensions | tikzposter Options | Conferences |
|---|---|---|---|---|
| `a0-portrait` | Portrait | 841mm x 1189mm | `a0paper, portrait` | **DEFAULT.** Interspeech, SIGMOD, APS, AACR, AGU, most European |
| `a0-landscape` | Landscape | 1189mm x 841mm | `a0paper, landscape` | Some engineering, AAAI |
| `us-portrait` | Portrait | 36"x48" (914x1219mm) | `a0paper, portrait` (close fit) | Most US conferences, SfN, biomedical |
| `neurips-main` | Landscape | 96"x48" (2438x1219mm) | Custom paper size | NeurIPS main |
| `neurips-ws` | Portrait | 24"x36" (610x914mm) | Custom paper size | NeurIPS workshops |
| `icml-main` | Landscape | 36"Hx48-72"W | Custom paper size | ICML main |
| `icml-ws` | Portrait | 24"x36" (610x914mm) | Custom paper size | ICML workshops |
| `cvpr` | Landscape | 84"x42" (2133x1067mm) | Custom paper size | CVPR (2:1 ratio) |
| `iclr-main` | Landscape | 194cm x 95cm | Custom paper size | ICLR main |
| `iclr-ws` | Portrait | 24"x36" (610x914mm) | Custom paper size | ICLR workshops |

### Custom Paper Size (for non-A0 dimensions)

```latex
% Example: CVPR 84"x42" (2133mm x 1067mm)
\documentclass[25pt, landscape, margin=15mm,
    innermargin=15mm, blockverticalspace=12mm, colspace=20mm]{tikzposter}
\usepackage{geometry}
\geometry{paperwidth=2133mm, paperheight=1067mm}
```

### When Conference Is Unknown

Default to **A0 portrait** (841mm x 1189mm). This fits most conference boards worldwide.

## Typography Standards

### Font Sizes (A0 poster, 841mm x 1189mm)

| Element | Size | tikzposter Default | Notes |
|---|---|---|---|
| Title | 72-120pt | `\Huge` or `\veryHuge` | Readable from 15-20 feet / 5-6 meters |
| Authors | 48-60pt | `\LARGE` | Below title |
| Affiliations | 36-48pt | `\Large` | Below authors |
| Section headings | 48-60pt | `\large` (block titles) | Bold, contrasting color |
| Body text | 28-36pt | Default (~25pt at 25pt base) | Minimum 24pt |
| Bullet items | 28-36pt | Default | Same as body |
| Figure captions | 24-28pt | `\small` or `\normalsize` | Below figures |
| Table text | 24-28pt | `\large` in table env | Match or slightly smaller than body |
| References | 18-24pt | `\small` or `\footnotesize` | Smallest text on poster |

### Font Scaling for Non-A0 Sizes

Scale base font size proportionally to poster area:
- A0 (841x1189mm): 25pt base (default)
- 36"x48" (914x1219mm): 25pt base (similar to A0)
- 24"x36" (610x914mm): 18-20pt base (smaller poster)
- CVPR 84"x42": 25-30pt base (wide poster, same viewing distance)
- NeurIPS 96"x48": 28-32pt base (very wide poster)

### Font Family

- **Sans-serif** preferred: Better readability at distance
- tikzposter default: `\renewcommand{\familydefault}{\sfdefault}`
- Acceptable alternatives: Helvetica (`helvet`), Liberation Sans, Open Sans (via fontspec/XeLaTeX)
- Serif OK for body text if design calls for it (use `lmodern` or `mathpazo`)
- Maximum 2-3 font families per poster

## Color Schemes

### Scheme 1: Navy + Amber (Default in template)

Professional, high contrast, works for any field.

```latex
\definecolor{navyblue}{HTML}{1E3A8A}
\definecolor{steelblue}{HTML}{3B82F6}
\definecolor{amber}{HTML}{F59E0B}
\definecolor{darktext}{HTML}{1F2937}
\definecolor{lightbg}{HTML}{F8FAFC}
```

### Scheme 2: Forest Green (Biology / Environmental)

```latex
\definecolor{forestgreen}{HTML}{166534}
\definecolor{leafgreen}{HTML}{4ADE80}
\definecolor{earthbrown}{HTML}{92400E}
\definecolor{darktext}{HTML}{1C1917}
\definecolor{lightbg}{HTML}{F0FDF4}
```

### Scheme 3: Medical Teal (Healthcare / Clinical)

```latex
\definecolor{tealdark}{HTML}{0F766E}
\definecolor{teallight}{HTML}{5EEAD4}
\definecolor{coral}{HTML}{F43F5E}
\definecolor{darktext}{HTML}{1E293B}
\definecolor{lightbg}{HTML}{F0FDFA}
```

### Scheme 4: Tech Purple (CS / ML / AI)

```latex
\definecolor{deeppurple}{HTML}{6D28D9}
\definecolor{lavender}{HTML}{A78BFA}
\definecolor{hotpink}{HTML}{EC4899}
\definecolor{darktext}{HTML}{1E1B4B}
\definecolor{lightbg}{HTML}{FAF5FF}
```

### Scheme 5: Minimal Dark (High Contrast / Modern)

```latex
\definecolor{charcoal}{HTML}{1F2937}
\definecolor{midgray}{HTML}{6B7280}
\definecolor{crimson}{HTML}{DC2626}
\definecolor{darktext}{HTML}{111827}
\definecolor{lightbg}{HTML}{F9FAFB}
```

### Applying a Color Scheme

Replace the color definitions in the template, then update `\colorlet` assignments:

```latex
\colorlet{backgroundcolor}{white}          % or lightbg
\colorlet{titlebgcolor}{PRIMARY_COLOR}     % e.g., navyblue
\colorlet{titlefgcolor}{white}
\colorlet{blocktitlebgcolor}{PRIMARY_COLOR}
\colorlet{blocktitlefgcolor}{white}
\colorlet{blockbodybgcolor}{white}
\colorlet{blockbodyfgcolor}{darktext}
```

## Layout Archetypes

### Traditional Column Layout (Recommended Default)

Best for: Most conferences, physics, biology, medicine, engineering.

**Portrait (2 columns):**
```
+------------------------------------------+
|              TITLE BANNER                 |
|   Authors, Affiliations, Contact         |
+--------------------+---------------------+
|   Introduction     |   Results           |
|                    |   [Chart/Plot]      |
+--------------------+                     |
|   Methods          |   [Chart/Plot]      |
|   [Diagram]        |                     |
|                    +---------------------+
+--------------------+   Conclusions       |
|   Experimental     |                     |
|   Setup [Table]    +---------------------+
|                    |   References        |
+--------------------+   [QR Code]         |
+------------------------------------------+
```

**Landscape (3 columns):**
```
+----------------------------------------------------------------------+
|                         TITLE BANNER                                  |
|            Authors, Affiliations, Contact                             |
+---------------------+-------------------------+----------------------+
|   Introduction      |   Results               |   Analysis           |
|                     |   [Main Chart/Plot]     |   [Chart/Plot]       |
+---------------------+                         |                      |
|   Methods           |   [Table]               +----------------------+
|   [Flow Diagram]    |                         |   Conclusions        |
|                     +-------------------------+                      |
+---------------------+   More Results          +----------------------+
|   Setup [Table]     |   [Chart/Plot]          |   References         |
|                     |                         |   [QR Code]          |
+---------------------+-------------------------+----------------------+
```

### #BetterPoster Layout (Growing Trend)

Best for: Maximum "drive-by" readability. Stand out at poster sessions.

```
+------------------------------------------+
|              TITLE BANNER                 |
+----------+-----------------+-------------+
|          |                 |             |
| Methods  |  ONE KEY        | Additional  |
| & Setup  |  FINDING        | Results     |
|          |  IN LARGE       |             |
| (small   |  TEXT           | (small      |
|  text)   |  (60-80pt)     |  text)      |
|          |                 |             |
|          |  [QR Code]     |             |
|          |  Scan for      |             |
|          |  full paper    |             |
+----------+-----------------+-------------+
|              References (tiny)            |
+------------------------------------------+
```

### Visual-Heavy / Results-First Layout

Best for: Data visualization, astronomy, medical imaging.

```
+------------------------------------------+
|              TITLE BANNER                 |
+--------------------+---------------------+
|   Introduction     |                     |
|   (brief)          |   MAIN RESULT       |
+--------------------+   [LARGE FIGURE]    |
|   Methods          |   (40-50% of area)  |
|   (brief)          |                     |
+--------------------+---------------------+
|   Supporting Results     | Conclusions    |
|   [Small charts]         | References     |
+------------------------------------------+
```

## Content Guidelines

### Word Count

| Poster Size | Target | Maximum |
|---|---|---|
| A0 portrait | 400-500 words | 800 words |
| 24"x36" (workshop) | 200-300 words | 500 words |
| Landscape (CS/ML) | 300-500 words | 700 words |
| CVPR ultra-wide | 400-600 words | 800 words |

### Content Ratio

- **40% text, 60% visuals** (ideal)
- **20-30% white space** (breathing room)
- **Maximum 2-3 key equations** (poster is NOT the paper)
- **3-6 figures/charts** depending on poster size
- **References:** Limit to 3-5 most relevant

### Section-by-Section Guide

| Section | Length | Content |
|---|---|---|
| **Title** | 1-2 lines | Short, compelling, result-hinting |
| **Introduction/Motivation** | 50-80 words | Problem statement, why it matters |
| **Methods** | 80-120 words | Approach overview, key steps (not full detail) |
| **Results** | 100-150 words | Key findings with supporting visuals |
| **Conclusions** | 50-80 words | Main takeaway, impact, future work |
| **References** | 3-5 entries | Most relevant citations only |

## QR Code Placement

```latex
\usepackage{qrcode}

% Option 1: In references block
\block{References \& Resources}{
    {\small [1] Author et al. (2024). Paper Title. \textit{Conf}.}
    \vspace{1em}
    \begin{center}
    \qrcode[height=4cm]{https://arxiv.org/abs/XXXX.XXXXX}\\[0.5em]
    {\normalsize Scan for full paper \& code}
    \end{center}
}

% Option 2: Standalone block
\block{}{
    \begin{center}
    \qrcode[height=5cm]{https://github.com/user/repo}\\[0.5em]
    {\large Paper \& Code}
    \end{center}
}
```

- Place in bottom-right corner or references section
- Size: 3-5cm height on A0 poster
- Include brief label below QR code
- Link to: arXiv paper, GitHub repo, project page, or demo

## Common Mistakes to Avoid

1. **Too much text** -- poster is NOT a paper printout. Max 800 words.
2. **Font too small** -- minimum 24pt for any text on A0. Test: can you read it from 4 feet?
3. **No visual hierarchy** -- title should be readable from 15 feet, key finding from 10 feet
4. **Wall of text blocks** -- break up with figures, bullet points, white space
5. **Fixed dimensions for figures** -- use `width=0.9\linewidth`, not `width=20cm`
6. **Using `\begin{figure}` in tikzposter** -- use `\begin{tikzfigure}[Caption]` instead
7. **Cluttered layout** -- 20-30% white space is necessary for readability
8. **Low-contrast colors** -- yellow text on white, light gray on white = unreadable
9. **Too many fonts** -- max 2-3 font families
10. **Tiny references section** -- if references are unreadable, omit them and use a QR code instead
11. **No contact info** -- always include email, optionally GitHub/website
12. **Landscape for non-CS conference** -- check the conference guidelines first
