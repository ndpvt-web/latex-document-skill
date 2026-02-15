# latex-document

A Claude Code skill that turns natural language into production-grade PDFs. Say what you need -- a resume, a 300-page book, a conference poster, an exam -- and get a compiled PDF with PNG previews, charts, diagrams, and bibliography, all handled automatically.

**21 templates. 6 scripts. 12 reference guides. 4 conversion profiles. Zero LaTeX knowledge required.**

---

## What This Skill Does

You describe a document. The skill:

1. Selects the right template from 21 production-tested options
2. Asks clarifying questions (layout, color scheme, elements to include)
3. Generates charts, diagrams, tables, and images as needed
4. Compiles to PDF with the correct LaTeX engine (auto-detected)
5. Delivers the PDF + page-by-page PNG previews

It also converts between formats (Markdown/DOCX/HTML/LaTeX) and can reconstruct handwritten or printed PDFs into clean LaTeX using an empirically optimized batching strategy.

---

## Template Gallery

### Resumes -- 5 ATS-Optimized Variants

98% of Fortune 500 companies use Applicant Tracking Systems to filter resumes before a human sees them. These templates are designed to pass.

| Template | Best For | ATS Score | Key Feature |
|---|---|---|---|
| **Classic ATS** | Finance, law, government | 10/10 | Zero graphics, maximum parse safety |
| **Modern Professional** | Tech, corporate | 9/10 | Subtle color accents, clean design |
| **Executive** | VP / Director / C-suite | 9/10 | Two-page, P&L focus, Board roles |
| **Technical** | Software, data, engineering | 9/10 | Skills-first, projects section, GitHub |
| **Entry-Level** | New graduates | 9/10 | Education-first, one page |

| | | | |
|---|---|---|---|
| ![Classic ATS](examples/resume-classic-ats.png) | ![Modern Professional](examples/resume-modern-professional.png) | ![Executive p1](examples/resume-executive-p1.png) | ![Executive p2](examples/resume-executive-p2.png) |
| Classic ATS | Modern Professional | Executive (p1) | Executive (p2) |
| ![Technical](examples/resume-technical.png) | ![Entry-Level](examples/resume-entry-level.png) | | |
| Technical | Entry-Level | | |

There is also a **legacy resume template** (`resume.tex`) with photo area and table layout -- not ATS-compatible, but useful for regions where photo resumes are standard.

---

### Academic Documents

#### Lecture Notes (Beautiful Mode)

The `lecture-notes.tex` template produces publication-quality math and science notes with color-coded theorem environments (tcolorbox), TikZ graph theory macros, and 3 font options (Palatino, Libertine, MLModern).

- Blue theorems, green definitions, orange examples, purple remarks, red warnings
- Pre-built graph macros: `\CompleteGraph{n}`, `\CycleGraph{n}`, `\PathGraph{n}`
- Custom math commands: `\R`, `\N`, `\Z`, `\Q`, `\C`, `\abs`, `\norm`, `\floor`, `\ceil`
- Graph theory operators: `\adj`, `\deg`, `\diam`, `\chr`, `\Aut`

8 pages -- title, colored theorem boxes, TikZ graph drawings, Petersen graph, graph coloring:

| | | | |
|---|---|---|---|
| ![p1](examples/lecture-notes-p1.png) | ![p2](examples/lecture-notes-p2.png) | ![p3](examples/lecture-notes-p3.png) | ![p4](examples/lecture-notes-p4.png) |
| ![p5](examples/lecture-notes-p5.png) | ![p6](examples/lecture-notes-p6.png) | ![p7](examples/lecture-notes-p7.png) | ![p8](examples/lecture-notes-p8.png) |

#### Thesis / Dissertation

Full `book`-class document with Palatino fonts (`newpxtext`+`newpxmath`), `microtype` with protrusion and expansion, `mathtools`, `cleveref`, `bookmark`, `emptypage`, `csquotes`, and `algorithm`+`algpseudocode`. Front matter (title page, declaration, abstract, acknowledgments, TOC), main chapters with proper theorem environments, appendices, and bibliography. Bindingoffset for professional printing.

19 pages -- title page, abstract, TOC, chapters with math, algorithms, results tables, bibliography, appendix:

| | | | |
|---|---|---|---|
| ![p1](examples/thesis-p1.png) | ![p2](examples/thesis-p2.png) | ![p3](examples/thesis-p3.png) | ![p4](examples/thesis-p4.png) |
| ![p5](examples/thesis-p5.png) | ![p6](examples/thesis-p6.png) | ![p7](examples/thesis-p7.png) | ![p8](examples/thesis-p8.png) |

#### Academic Paper

Professional research paper with Times fonts (`newtxtext`+`newtxmath`), `microtype`, `mathtools` with `\DeclarePairedDelimiter`, `cleveref` with custom `\crefname` configs, `authblk` for multi-author affiliations, `siunitx`, `algorithm`+`algpseudocode`, `amsthm` theorem environments, and colorblind-safe Tol palette. arXiv-compatible (`\pdfoutput=1`). Structure: Abstract, Introduction, Related Work, Method (with theorem/proof/algorithm), Experiments (with subfigures and ablation), Conclusion.

| | | | |
|---|---|---|---|
| ![p1](examples/academic-paper-p1.png) | ![p2](examples/academic-paper-p2.png) | ![p3](examples/academic-paper-p3.png) | ![p4](examples/academic-paper-p4.png) |

#### Academic CV

Multi-page curriculum vitae with sections for publications (numbered: [J1], [C1], [W1]), grants with dollar amounts, teaching, student advising (current + graduated with placements), professional service, and invited talks. ORCID and Google Scholar links.

| | | | |
|---|---|---|---|
| ![p1](examples/academic-cv-p1.png) | ![p2](examples/academic-cv-p2.png) | ![p3](examples/academic-cv-p3.png) | ![p4](examples/academic-cv-p4.png) |

---

### Scientific Posters -- 2 Orientations, 5 Color Schemes, 3 Layouts

Full conference poster system built on `tikzposter` class with interactive workflow:

**Step A -- Conference & Orientation:**

| Conference | Orientation | Dimensions |
|---|---|---|
| Most conferences (default) | Portrait A0 | 841mm x 1189mm |
| NeurIPS / ICML / CVPR / ICLR | Landscape A0 | 1189mm x 841mm |
| NeurIPS workshop | Custom | 24" x 36" |
| CVPR | Custom | 84" x 42" |

**Step B -- Layout Archetype:**

| Layout | Usage | Description |
|---|---|---|
| **Traditional Column** | 70% of posters | 2-col (portrait) or 3-col (landscape) |
| **#BetterPoster** | 10% (growing) | Central billboard with ONE key finding in 60-80pt text |
| **Visual-Heavy** | 15% | Large central figure (40-50% of space) |

**Step C -- Color Scheme:**

| Scheme | Best For | Colors |
|---|---|---|
| Navy + Amber | Professional, high contrast | Dark navy headers, amber accents |
| Tech Purple | CS / ML / AI conferences | Deep purple + hot pink |
| Forest Green | Biology, environmental science | Deep green + lime |
| Medical Teal | Healthcare, neuroscience | Teal headers + rose accents |
| Minimal Dark | Modern, high contrast | Dark slate + white |

Both portrait and landscape templates include commented geometry presets for specific conference sizes, QR code support, `tikzfigure` environments for captioned figures, and `innerblock`/`coloredbox` for highlighted callouts.

| Portrait A0 | Landscape A0 |
|---|---|
| ![Portrait Poster](examples/poster.png) | ![Landscape Poster](examples/poster-landscape.png) |

---

### Book

Full `book`-class document with Palatino fonts (`newpxtext`+`newpxmath`), `microtype` with protrusion and expansion, classical asymmetric margins (inner/outer/top/bottom), `\linespread{1.35}` for comfortable reading, `lettrine` drop caps at chapter openings, `emptypage` for blank verso pages, `amsthm` theorem environments, `algorithm`+`algpseudocode`, `cleveref`, `csquotes`, `imakeidx` (modern index), `bookmark`, and colophon. Includes half-title, full title, copyright page (ISBN, edition, disclaimers), dedication, preface, acknowledgments, parts, chapters with epigraphs, index, and bibliography.

37 pages -- half title, full title, copyright, TOC, preface, acknowledgments, chapters with drop caps and epigraphs, theorems, algorithms, bibliography, index:

| | | | | |
|---|---|---|---|---|
| ![p1](examples/book-p1.png) | ![p2](examples/book-p2.png) | ![p3](examples/book-p3.png) | ![p4](examples/book-p4.png) | ![p5](examples/book-p5.png) |
| Half Title | Full Title | Copyright | TOC | Preface |
| ![p6](examples/book-p6.png) | ![p7](examples/book-p7.png) | ![p8](examples/book-p8.png) | ![p9](examples/book-p9.png) | ![p10](examples/book-p10.png) |
| Acknowledgments | Part I | Ch 1: Drop Caps | Definitions & Theorems | Notation & Summary |

---

### Exam / Quiz

Built on the `exam` class with automatic grading table, point tracking, and solution toggle (`\printanswers`).

**Question types:** Multiple choice, True/False, fill-in-the-blank, matching, short answer, long answer/essay -- each with configurable point values and solution spaces.

| | | | | | |
|---|---|---|---|---|---|
| ![p1](examples/exam-p1.png) | ![p2](examples/exam-p2.png) | ![p3](examples/exam-p3.png) | ![p4](examples/exam-p4.png) | ![p5](examples/exam-p5.png) | ![p6](examples/exam-p6.png) |

---

### Business Documents

| | | |
|---|---|---|
| ![Letter](examples/letter.png) | ![Cover Letter](examples/cover-letter.png) | ![Invoice](examples/invoice.png) |
| **Business Letter** -- Colored letterhead bar, logo placeholder, signature block, CC/enclosures | **Cover Letter** -- Job application format, 4-paragraph structure, color-matched to resume | **Invoice** -- Line items table, alternating row colors, totals with tax, payment terms |

---

### Report

Executive summary, findings, recommendations structure with TOC, pgfplots bar charts, TikZ flowcharts, colored data tables, and fancyhdr headers.

| | | | |
|---|---|---|---|
| ![p1](examples/report-p1.png) | ![p2](examples/report-p2.png) | ![p3](examples/report-p3.png) | ![p4](examples/report-p4.png) |

### Presentation (Beamer)

Widescreen (16:9) slides with Madrid theme. Title slide, outline, section frames, two-column layouts, block environments, equations, TikZ diagrams, booktabs tables.

| | | | | |
|---|---|---|---|---|
| ![p1](examples/presentation-p1.png) | ![p2](examples/presentation-p2.png) | ![p3](examples/presentation-p3.png) | ![p4](examples/presentation-p4.png) | ![p5](examples/presentation-p5.png) |
| ![p6](examples/presentation-p6.png) | ![p7](examples/presentation-p7.png) | ![p8](examples/presentation-p8.png) | ![p9](examples/presentation-p9.png) | ![p10](examples/presentation-p10.png) |

---

## Visual Elements

Every document can include any combination of:

### Charts & Graphs

**Inline (pgfplots):** Line, bar, scatter, pie charts compiled directly in LaTeX -- no external tools needed.

**External (matplotlib):** 9 chart types generated via script and included as images:

```
bar | line | scatter | pie | heatmap | box | histogram | area | radar
```

```bash
python3 scripts/generate_chart.py bar \
    --data '{"x":["Q1","Q2","Q3","Q4"],"y":[120,150,180,210]}' \
    --output chart.png --title "Quarterly Revenue"
```

Supports CSV input (`--csv data.csv`), custom colors, DPI, figure size, and matplotlib styles.

![Charts](examples/charts.png)

### Diagrams

**TikZ:** Flowcharts, architecture diagrams, block diagrams, graph theory diagrams -- compiled inline.

**Mermaid:** Flowcharts, sequence diagrams, class diagrams, ER diagrams, Gantt charts, pie charts, mindmaps -- rendered to PNG/PDF via mermaid-cli:

```bash
bash scripts/mermaid_to_image.sh diagram.mmd output.png --theme forest
```

### Tables

CSV-to-LaTeX conversion with 4 styles:

```bash
python3 scripts/csv_to_latex.py data.csv --style booktabs --alternating-rows --caption "Results"
```

Styles: `booktabs` (professional), `grid` (full borders), `simple` (minimal lines), `plain` (no lines).

### Other Visual Elements

- **QR codes** -- `\qrcode` package, used in posters and business documents
- **Watermarks** -- text (DRAFT, CONFIDENTIAL) or logo background
- **AI-generated images** -- via the `generate-image` skill
- **Code listings** -- `listings` or `minted` packages with syntax highlighting
- **Algorithms** -- `algorithm`/`algorithmic` packages
- **Colored boxes** -- `tcolorbox` for callouts, theorems, warnings
- **SI units** -- `siunitx` for consistent unit formatting

---

## Format Conversion

### Document Conversion (Pandoc)

Bidirectional conversion between any combination:

```
Markdown <-> LaTeX <-> DOCX <-> HTML <-> PDF
```

```bash
bash scripts/convert_document.sh input.md output.tex
bash scripts/convert_document.sh input.docx output.tex --bibliography refs.bib --toc
bash scripts/convert_document.sh input.tex output.pdf
```

Supports custom templates, bibliography (.bib), citation styles (.csl), table of contents, and MathJax for HTML output.

### PDF-to-LaTeX Reconstruction

Converts scanned, handwritten, or printed PDFs back into clean, compilable LaTeX. Uses a 3-tier scaling strategy empirically validated on a 115-page handwritten math PDF:

| PDF Size | Strategy | Agents | Error Rate |
|---|---|---|---|
| **1-10 pages** | Single agent | 1 | 0-2 minor (trivially fixable) |
| **11-20 pages** | Split in half | 2 | Avoids error cliff at 10+ pages |
| **21+ pages** | Batch-7 pipeline | ceil(N/7) | Optimal -- 0 errors per batch |

**Why batch-7:** Testing showed 0 errors at 7 pages, 2 structural errors at 10, and 11 catastrophic errors at 15. The error cliff between 10 and 15 pages is steep.

**4 conversion profiles** tune output for content type:

| Content Type | Profile | Specialization |
|---|---|---|
| Math / science | `math-notes.md` | amsmath, amsthm, theorem environments, beautiful mode |
| Business | `business-document.md` | fancyhdr, tabularx, financial tables |
| Legal | `legal-document.md` | Roman numeral sections, 1.5 spacing, nested clauses |
| General | `general-notes.md` | Minimal packages, adaptive |

---

## Compilation Engine

`compile_latex.sh` handles the entire build pipeline:

```bash
bash scripts/compile_latex.sh document.tex --preview --preview-dir ./outputs
```

**What it does automatically:**
- Detects the right engine: `fontspec`/`xeCJK`/`polyglossia` -> XeLaTeX, `luacode`/`luatextra` -> LuaLaTeX, otherwise pdfLaTeX
- Detects bibliography system: `\bibliography{}` -> bibtex, `\addbibresource{}` -> biber
- Detects and runs `makeindex` and `makeglossaries` when needed
- Runs 2-3 passes to resolve all cross-references
- Generates page-by-page PNG previews (via pdftoppm)
- Installs missing TeX Live packages automatically
- Cleans up auxiliary files (.aux, .log, .toc, .bbl, .idx, etc.)

**Options:**

```bash
--preview              # Generate PNG previews
--preview-dir <dir>    # Where to put PNGs
--scale <pixels>       # Max PNG dimension (default: 1200)
--engine <engine>      # Force pdflatex, xelatex, or lualatex
```

---

## Multi-Language Support

| Language Family | Package | Engine |
|---|---|---|
| European (French, German, Spanish...) | `babel` | pdfLaTeX |
| CJK (Chinese, Japanese, Korean) | `xeCJK` | XeLaTeX (auto-detected) |
| RTL (Arabic, Hebrew, Farsi) | `polyglossia` | XeLaTeX (auto-detected) |
| Cyrillic (Russian, Ukrainian) | `babel` or `polyglossia` | pdfLaTeX or XeLaTeX |

The compile script auto-selects the correct engine based on package imports.

---

## Reference Documentation

12 reference guides covering every aspect of the skill:

| Guide | What It Covers |
|---|---|
| `resume-ats-guide.md` | ATS parsing rules, LaTeX pitfalls, keyword optimization |
| `poster-design-guide.md` | Conference presets, #BetterPoster, typography at distance, 5 color schemes |
| `bibliography-guide.md` | BibTeX vs biblatex, citation commands, .bib format |
| `advanced-features.md` | Watermarks, landscape, multi-language, algorithms, tcolorbox, siunitx, AI images |
| `charts-and-graphs.md` | pgfplots patterns (line, bar, scatter, pie), TikZ chart examples |
| `python-charts.md` | matplotlib generation (9 types), CSV input, styling |
| `mermaid-diagrams.md` | Flowcharts, sequence, class, ER, Gantt, pie, mindmaps |
| `format-conversion.md` | Pandoc pipeline, templates, bibliography integration |
| `pdf-conversion.md` | Full PDF-to-LaTeX pipeline, scaling strategy, batch processing |
| `tables-and-images.md` | Colored rows, multi-row/column, booktabs, long tables, TikZ |
| `packages.md` | Common LaTeX package reference |
| `profiles/` | 4 conversion profiles (math, business, legal, general) |

---

## Installation

```bash
cp -r latex-document ~/.claude/skills/
```

The skill triggers automatically when you ask Claude Code to create any document, resume, poster, exam, report, book, thesis, or anything that should be a PDF.

---

## Project Structure

```
latex-document/
├── SKILL.md                              # Skill definition (workflow, rules, anti-patterns)
├── README.md
├── assets/templates/                     # 21 compile-tested templates
│   ├── resume-classic-ats.tex            #   ATS 10/10 -- finance, law, government
│   ├── resume-modern-professional.tex    #   ATS 9/10 -- tech, corporate
│   ├── resume-executive.tex              #   ATS 9/10 -- VP, Director, C-suite
│   ├── resume-technical.tex              #   ATS 9/10 -- software, data, engineering
│   ├── resume-entry-level.tex            #   ATS 9/10 -- new graduates
│   ├── resume.tex                        #   Legacy (photo, tables -- not ATS)
│   ├── lecture-notes.tex                 #   Beautiful math notes (tcolorbox, TikZ graphs)
│   ├── thesis.tex                        #   PhD dissertation (book class)
│   ├── academic-paper.tex                #   Research paper (natbib)
│   ├── academic-cv.tex                   #   Multi-page academic CV
│   ├── book.tex                          #   Full book (parts, chapters, index)
│   ├── poster.tex                        #   Portrait A0 poster (tikzposter)
│   ├── poster-landscape.tex              #   Landscape A0 poster (tikzposter)
│   ├── exam.tex                          #   Exam/quiz (exam class)
│   ├── letter.tex                        #   Formal business letter
│   ├── cover-letter.tex                  #   Job application cover letter
│   ├── invoice.tex                       #   Invoice with line items
│   ├── report.tex                        #   Business report with charts
│   ├── presentation.tex                  #   Beamer slides (16:9)
│   └── references.bib                    #   Example bibliography
├── scripts/
│   ├── compile_latex.sh                  #   .tex -> PDF + PNG (auto engine/bib/index)
│   ├── generate_chart.py                 #   matplotlib charts (9 types)
│   ├── csv_to_latex.py                   #   CSV -> LaTeX tables (4 styles)
│   ├── mermaid_to_image.sh               #   Mermaid .mmd -> PNG/PDF
│   ├── convert_document.sh               #   Pandoc format conversion
│   └── pdf_to_images.sh                  #   PDF -> page images (for OCR pipeline)
├── references/                           #   12 reference guides
│   ├── resume-ats-guide.md
│   ├── poster-design-guide.md
│   ├── bibliography-guide.md
│   ├── advanced-features.md
│   ├── charts-and-graphs.md
│   ├── python-charts.md
│   ├── mermaid-diagrams.md
│   ├── format-conversion.md
│   ├── pdf-conversion.md
│   ├── tables-and-images.md
│   ├── packages.md
│   └── profiles/                         #   4 conversion profiles
│       ├── math-notes.md
│       ├── business-document.md
│       ├── legal-document.md
│       └── general-notes.md
└── examples/                             #   Preview images
```

## License

MIT
