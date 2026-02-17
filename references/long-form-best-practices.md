# Long-Form Document Best Practices

This reference is for documents **5+ pages** (reports, theses, books, strategic documents). It addresses systematic problems that silently degrade document quality in long-form LaTeX documents. Violations produce documents that compile fine but look unprofessional.

---

## Anti-Pattern 1: "Wall of Bullets" — Over-reliance on itemize/enumerate

**The Problem:** When generating content about any complex topic, the default behavior is to put every group of related points into `\begin{itemize}`. A 40-page report can easily end up with 50-80 itemize blocks, making it look like a PowerPoint outline rather than a professional document.

**The Rule:** In reports and articles, **prose paragraphs are the default**. Bullet lists are the exception. Use this decision framework:

| Content Type | Format | Example |
|---|---|---|
| Analysis, explanation, argument | **Prose paragraph** | Market trends, strategic rationale, findings |
| Genuinely parallel items (specs, features) | **Table** (`tabularx` + `booktabs`) | Feature comparison, pricing tiers, specs |
| 3-5 labeled concepts | **Bold-label paragraphs** | `\textbf{Concept:} Explanation...` |
| Personas, callouts, key findings | **tcolorbox cards** | Customer profiles, executive summaries |
| Sequential steps (process, timeline) | **Numbered prose or table** | GTM phases, implementation roadmap |
| Raw data points, reference lists | **Bullet list (only here)** | Bibliography, tool lists, prerequisites |

**How to convert bullets to prose:** Take each bullet point and weave it into a flowing sentence. Connect points with transitions (furthermore, additionally, in contrast, this means that). Group related bullets into a single paragraph with a topic sentence.

**Bad (wall of bullets):**
```latex
\textbf{Market Trends:}
\begin{itemize}
  \item Multi-model adoption is increasing
  \item Open-source models growing at 46\%
  \item Startups adopt 3-5x faster than enterprises
  \item Web development is the largest use case
\end{itemize}
```

**Good (prose with structure):**
```latex
\textbf{Market Trends:} Multi-model adoption is accelerating, with nearly all
enterprises now testing multiple AI providers rather than standardizing on one.
Open-source models are gaining traction---46\% of organizations prefer them for
cost and control. Startups adopt agentic tools 3--5x faster than enterprises,
and web development represents the largest use case for AI coding tools.
```

**Good (bold-label paragraphs for distinct concepts):**
```latex
\textbf{Multi-Model Adoption:} Nearly all enterprises now test multiple AI
models rather than standardizing on one, favoring flexibility per task.

\textbf{Open-Source Surge:} 46\% of organizations prefer open-source models
for cost and control, creating demand for platforms supporting both commercial
and open-source models.
```

**Good (tcolorbox card for personas/profiles):**
```latex
\usepackage[most]{tcolorbox}
% ...
\begin{tcolorbox}[colback=blue!5, colframe=blue!70, title={\textbf{Target Persona: Solo Developer}}, fonttitle=\bfseries]
\textbf{Profile:} CS degree or bootcamp grad, 28--35, entrepreneurial mindset.
Active on Hacker News and indie communities.

\textbf{Pain Points:} Spends 80\% of time on boilerplate. Tool fatigue from
10+ subscriptions. Deployment complexity slows iteration.

\textbf{Value Prop:} \textit{``Ship your side project in a weekend, not a month.''}
\end{tcolorbox}
```

**Target:** A well-formatted 40-page report should have fewer than 15 itemize/enumerate blocks total. If you count more than 20, refactor.

## Anti-Pattern 2: Excessive \newpage Commands

**The Problem:** Inserting `\newpage` before every `\section` creates pages that are 30-50% empty. This mimics slide-deck formatting and wastes space.

**The Rule:** Let LaTeX handle page breaks naturally. Only use `\newpage` in these cases:
- Before `\tableofcontents` and after it (standard)
- Before the first `\section` (after front matter)
- Between truly independent major parts (e.g., between a 20-page analysis and a 10-page appendix)
- When a figure/table would look awkward split across pages

**Never** use `\newpage` before every `\section` or `\subsection`. LaTeX's page-breaking algorithm is sophisticated — let it work.

## Anti-Pattern 3: Oversized Images and Rigid Float Placement

**The Problem:** Images at `width=0.95\textwidth` consume almost the full page width, pushing surrounding text to the next page and creating whitespace. Combined with `[H]` float placement, this forces half-empty pages.

**The Rules:**
- Default image width: `0.75\textwidth` to `0.85\textwidth` (not 0.95)
- Use `[htbp]` for most figures (allows LaTeX to optimize placement)
- Only use `[H]` when the figure MUST appear at that exact spot (e.g., immediately after "as shown below:")
- For AI-generated images (often 1-2MB), `0.75\textwidth` is usually sufficient
- For charts and graphs, `0.80-0.85\textwidth` works well
- For full-page figures, use `0.90\textwidth` maximum

```latex
% Good: flexible placement, reasonable size
\begin{figure}[htbp]
\centering
\includegraphics[width=0.80\textwidth]{chart.png}
\caption{Revenue growth by quarter}
\end{figure}

% Only when exact placement is critical
\begin{figure}[H]
\centering
\includegraphics[width=0.75\textwidth]{diagram.png}
\caption{Architecture diagram referenced in text above}
\end{figure}
```

## Anti-Pattern 4: No Global List Compaction

**The Problem:** LaTeX's default list spacing (itemsep, topsep, parsep, partopsep) is generous. A 4-item bullet list can consume as much vertical space as a full paragraph. In a document with many lists, this creates enormous wasted space.

**The Rule:** Always add global list compaction to the preamble for reports and articles:

```latex
\usepackage{enumitem}
\setlist[itemize]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
\setlist[enumerate]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
```

This reduces list spacing to match body text density without eliminating indentation or readability.

## Anti-Pattern 5: Monotonous Section Structure

**The Problem:** Every subsection follows the identical pattern: intro sentence → bullet list → bold conclusion. Over 40+ pages, this repetition makes the document feel generated rather than authored.

**The Rule:** Vary presentation across sections. Use at least 3-4 different content formats throughout a long document:

1. **Prose paragraphs** (analysis, narrative, argument)
2. **Tables** (`booktabs` + `tabularx`) for comparisons and structured data
3. **tcolorbox cards** for profiles, callouts, executive summaries
4. **Bold-label paragraphs** for 3-5 distinct concepts
5. **Figures with captions** for charts, diagrams, images
6. **Longtable** for multi-page structured comparisons

Adjacent sections should NOT use the same format. If Section 3.1 uses a table, Section 3.2 should use prose or tcolorbox, not another table.

## Anti-Pattern 6: Silent Encoding Errors

**The Problem:** Documents compile without errors but the PDF contains garbage characters (inverted question marks, missing symbols). The agent doesn't notice because compilation succeeds.

**Common silent errors:**
| You Write | PDF Shows | Fix |
|---|---|---|
| `<5%` in text | ¿5% | `$<$5\%` |
| `>50` in text | ¡50 | `$>$50` |
| `~` in text | (nothing/tilde accent on next char) | `\textasciitilde` |
| `|` in text | (may render wrong) | `\textbar` or `$\vert$` |
| `\` in text | (starts a command) | `\textbackslash` |
| `{` or `}` in text | (grouping chars) | `\{` or `\}` |

**The Rule:** After generating LaTeX content, scan for these characters in text mode (outside math `$...$` and commands). The most commonly missed are `<` and `>`.

## Anti-Pattern 7: Hardcoded Dimensions

**The Problem:** Using absolute units (`12cm`, `5in`, `300pt`) for widths, margins, and spacing creates documents that break when paper size, font size, or column layout changes. A figure set to `width=15cm` overflows the margin on letter paper with 1-inch margins.

**The Rule:** Always use relative units that adapt to the current layout:

| Instead of | Use | Why |
|---|---|---|
| `width=15cm` | `width=0.8\textwidth` | Adapts to margins and columns |
| `\hspace{2cm}` | `\hspace{2em}` or `\quad` | Scales with font size |
| `\vspace{1in}` | `\vspace{\baselineskip}` | Consistent with line spacing |
| `\parindent=20pt` | `\parindent=1.5em` | Scales with font |
| `\setlength{\tabcolsep}{12pt}` | `\setlength{\tabcolsep}{1em}` | Font-relative |

**Exception:** Page margins in `geometry` package use absolute units by design (`margin=1in`).

## Anti-Pattern 8: Missing \noindent After Display Math

**The Problem:** LaTeX treats text after a display math environment (`\[ ... \]`, `equation`, `align`) as a new paragraph, adding indentation. This creates a visual discontinuity when the text after the equation is a continuation of the same paragraph.

**Wrong:**
```latex
The quadratic formula is:
\[ x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a} \]
where $a$, $b$, and $c$ are coefficients.    % ← Indented! Looks like new paragraph
```

**Correct:**
```latex
The quadratic formula is:
\[ x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a} \]
\noindent where $a$, $b$, and $c$ are coefficients.    % ← Flush left, continuation
```

**The Rule:** If text after a display equation continues the same thought (starts with "where", "for", "with", "so", "thus"), add `\noindent` to prevent false paragraph indentation.

## Anti-Pattern 9: Widow and Orphan Lines

**The Problem:** A single line of a paragraph appears alone at the bottom of a page (orphan) or top of the next page (widow). This looks unprofessional and wastes space. LaTeX's default penalties are too low to prevent this reliably.

**The Rule:** Add these penalties to the preamble for any document over 5 pages:

```latex
\widowpenalty=10000
\clubpenalty=10000
```

This tells LaTeX to strongly avoid breaking paragraphs such that only one line ends up isolated. For additional control in critical documents:

```latex
\widowpenalty=10000
\clubpenalty=10000
\brokenpenalty=10000     % Avoid page breaks after hyphenated lines
\predisplaypenalty=10000 % Avoid page breaks just before display math
```

---

## Quick Reference: Report Preamble Best Practices

Every report-class document (10+ pages) should include this baseline preamble setup:

```latex
\documentclass[11pt,a4paper]{article}

% Core packages
\usepackage[margin=1in]{geometry}
\usepackage{graphicx}
\usepackage[colorlinks=true, linkcolor=blue, urlcolor=blue]{hyperref}
\usepackage[table]{xcolor}
\usepackage{colortbl}
\usepackage{booktabs}
\usepackage{tabularx}
\usepackage{float}
\usepackage{enumitem}
\usepackage{longtable}
\usepackage{amsmath, amssymb}

% Recommended for professional reports
\usepackage[most]{tcolorbox}  % colored boxes for callouts, personas, highlights
\usepackage{titlesec}          % section heading customization
\usepackage{fancyhdr}          % headers and footers

% Global list compaction (ALWAYS include for reports)
\setlist[itemize]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
\setlist[enumerate]{nosep, leftmargin=*, topsep=2pt, partopsep=0pt}
```

---

## Content Generation Checklist (Run Before Compiling)

Before compiling a long-form document, verify:

- [ ] **Bullet count:** Fewer than 15 itemize/enumerate blocks per 40 pages? If not, convert excess to prose.
- [ ] **Angle brackets:** Search for `<` and `>` outside math mode. Replace with `$<$`/`$>$` or `\textless`/`\textgreater`.
- [ ] **\newpage abuse:** Are `\newpage` commands only at major transitions, not before every section?
- [ ] **Image sizing:** Are most images `0.75-0.85\textwidth`? No images at `0.95\textwidth` unless full-bleed is intended?
- [ ] **List compaction:** Is `\setlist[itemize]{nosep, leftmargin=*}` in the preamble?
- [ ] **Format variety:** Do adjacent sections use different content formats (prose, table, tcolorbox, figure)?
- [ ] **Float placement:** Are most figures `[htbp]`, with `[H]` only where exact placement matters?
- [ ] **Special characters:** Are `%`, `$`, `&`, `#`, `_`, `<`, `>` properly escaped in text mode?
