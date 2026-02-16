# latex-document

A Claude Code skill that turns natural language into production-grade PDFs. Say what you need -- a resume, a 300-page book, a conference poster, an exam -- and get a compiled PDF with PNG previews, charts, diagrams, and bibliography, all handled automatically.

**27 templates. 8 scripts. 13 reference guides. 4 conversion profiles. Zero LaTeX knowledge required.**

---

## What This Skill Does

You describe a document. The skill:

1. Selects the right template from 27 production-tested options
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

38 pages -- title page, abstract, TOC, chapters with math, algorithms, TikZ architecture diagrams, heatmaps, bar charts, results tables, bibliography, appendix:

| | | | |
|---|---|---|---|
| ![p1](examples/thesis-p1.png) | ![p2](examples/thesis-p2.png) | ![p3](examples/thesis-p3.png) | ![p4](examples/thesis-p4.png) |
| Title Page | Table of Contents | Literature Review | TikZ Architecture Diagram |
| ![p5](examples/thesis-p5.png) | ![p6](examples/thesis-p6.png) | ![p7](examples/thesis-p7.png) | ![p8](examples/thesis-p8.png) |
| Results Tables | Heatmap & Bar Chart | Chapter Content | Bibliography |

#### Academic Paper

Professional research paper with Times fonts (`newtxtext`+`newtxmath`), `microtype`, `mathtools` with `\DeclarePairedDelimiter`, `cleveref` with custom `\crefname` configs, `authblk` for multi-author affiliations, `siunitx`, `algorithm`+`algpseudocode`, `amsthm` theorem environments, and colorblind-safe Tol palette. arXiv-compatible (`\pdfoutput=1`). Structure: Abstract, Introduction, Related Work, Method (with theorem/proof/algorithm), Experiments (with subfigures and ablation), Conclusion.

11 pages -- title, abstract, theorems & proofs, algorithm, pgfplots line chart & TikZ scatter plot, results tables, ablation, bibliography:

| | | | |
|---|---|---|---|
| ![p1](examples/academic-paper-p1.png) | ![p2](examples/academic-paper-p2.png) | ![p3](examples/academic-paper-p3.png) | ![p4](examples/academic-paper-p4.png) |
| Title & Abstract | Table + Charts (pgfplots & TikZ) | Ablation Tables & Conclusion | References |

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

### Cheat Sheets / Reference Cards

Purpose-built templates for condensing large amounts of information into compact, scannable reference cards. Three specialized variants:

| Template | Best For | Layout | Features |
|---|---|---|---|
| **Cheat Sheet (General)** | Course references, quick lookups | Landscape 3-column | Colored sections, formulas, tables, code, lists. 7pt body text, front+back |
| **Cheat Sheet (Exam)** | Formula sheets, exam aids | Portrait 2-column | Maximum density, 6pt text, B&W printer friendly, theorem/definition/formula boxes |
| **Cheat Sheet (Code)** | Programming references, CLI guides | Landscape 4-column | Syntax highlighting, API docs, language quick references |

#### System Capabilities

- **3 purpose-built templates** optimized for different use cases (general reference, exam conditions, programming)
- **Interactive configuration workflow** -- type selection, source material upload, customization options
- **PDF-to-cheatsheet pipeline** -- condense lecture notes, textbooks, past papers into compact reference cards
- **Customizable color schemes** -- change 6 color values in preamble to match your preferences
- **Flexible layout** -- supports 2-5 columns, any paper size, portrait/landscape orientation
- **Production-tested packages:**
  - `extarticle` for small fonts (6pt-7pt body text)
  - `tcolorbox` for colored definition/theorem/formula boxes
  - `microtype` for maximum text density and readability
  - `listings` or `minted` for syntax-highlighted code blocks
- **Exam-aware design:**
  - B&W safe option for grayscale printing
  - Student name/ID header area
  - Grayscale-only color scheme (no color dependencies)

#### Usage Examples

```
"Create a calculus exam cheat sheet"
"Condense my lecture notes PDF into a reference card"
"Make a Python quick reference card"
"Generate a data structures cheat sheet with complexity tables"
"Create a physics formula sheet for my final exam"
```

The skill will:
1. Ask which template type fits your use case (general/exam/code)
2. Request source material (PDF, notes, or description of content)
3. Configure layout (columns, color scheme, content density)
4. Generate the cheat sheet with optimal typography for small-format printing
5. Compile to PDF with page-by-page PNG previews

---

### Interactive / Dynamic Content

Four systems for producing documents that go beyond static PDFs: fillable forms, conditional content, mail merge, and version diffing.

#### Fillable PDF Forms

The `fillable-form.tex` template produces PDFs with interactive form fields that can be filled in Adobe Reader or Acrobat. Built on hyperref's form support.

**Field types supported:**
| Field | Command | Usage |
|---|---|---|
| Text input | `\TextField` | Names, emails, addresses |
| Multi-line text | `\TextField[multiline=true]` | Comments, essays |
| Checkbox | `\CheckBox` | Agreement toggles, skill selection |
| Radio buttons | `\ChoiceMenu[radio]` | Single-select options |
| Dropdown | `\ChoiceMenu[combo]` | Country, education level |
| Push button | `\PushButton` | Reset, print, submit |

**Custom helpers** for rapid form building:

```latex
\FormField[10cm]{First Name}{firstName}        % labeled text field
\FormTextArea[\textwidth]{Comments}{notes}{3cm} % multi-line area
\FormCheck{Programming}{skill_prog}             % checkbox with label
\FormDropdown{Education}{edu}{High School, BA, MA, PhD} % dropdown
```

> **Note:** Full form interactivity requires Adobe Reader/Acrobat. Browser PDF viewers have limited support.

#### Conditional Content

The `conditional-document.tex` template demonstrates toggle-based conditional sections using `etoolbox`. Configure documents by flipping switches at the top of the file:

```latex
\toggletrue{showTOC}         % include table of contents
\togglefalse{showAppendix}   % exclude appendix
\toggletrue{isConfidential}  % add CONFIDENTIAL watermark
\toggletrue{isDraft}         % add line numbers + DRAFT watermark
```

**12 toggles:** showTOC, showLOF, showLOT, showAppendix, showAcknowledgments, showAbstract, showWatermark, isDraft, isConfidential, showCoverPage, showPageNumbers, showHeaders.

**3 visual profiles:** corporate (Helvetica, navy), academic (Palatino, dark green), minimal (Latin Modern, grayscale). Switch with one line: `\def\docprofile{corporate}`.

**Template variables** with CLI override:

```latex
\providecommand{\doctitle}{Default Title}  % override from command line:
% pdflatex "\def\doctitle{Custom Title}\input{document.tex}"
```

#### Mail Merge

Generate N personalized documents from a single template + CSV/JSON data source. The `mail_merge.py` script handles template rendering, compilation, and optional PDF merging.

```bash
# Basic: 3 records -> 3 personalized PDFs
python3 scripts/mail_merge.py template.tex data.csv --output-dir ./outputs

# With custom naming and merged output
python3 scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --name-field last_name \
    --merge --merge-name all_letters.pdf

# Parallel compilation (4 workers)
python3 scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --workers 4
```

**Two template modes:**
| Mode | Syntax | Features |
|---|---|---|
| Simple | `{{variable}}` | Variable substitution, auto LaTeX escaping |
| Jinja2 | `<< variable >>`, `<% if ... %>` | Conditionals, loops, filters |

**Data sources:** CSV, JSON (array or `{records: [...]}` wrapper), JSONL.

The `mail-merge-letter.tex` template is included as a starter -- company-branded letter with placeholders for name, title, company, address, salutation, and position.

#### Version Diffing (latexdiff)

Generate change-tracked PDFs that highlight additions and deletions between two versions of a document. The `latex_diff.sh` script wraps `latexdiff` with auto-installation, git integration, and compilation.

```bash
# Compare two files
bash scripts/latex_diff.sh old.tex new.tex --output diff.tex --compile

# Compare against a git commit
bash scripts/latex_diff.sh document.tex --git-rev HEAD~3 --compile

# Compare against a branch/tag
bash scripts/latex_diff.sh document.tex --git-rev v1.0 --compile

# Custom markup style and colors
bash scripts/latex_diff.sh old.tex new.tex \
    --type CFONT --color-add green --color-del red --compile
```

**6 markup types:** UNDERLINE (default), CTRADITIONAL, CFONT, CHANGEBAR, CULINECHBAR, FONTSTRIKE.

Additions are shown in blue (underlined by default), deletions in red (strikethrough). The `--flatten` flag handles multi-file documents with `\input`/`\include`.

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

13 reference guides covering every aspect of the skill:

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
| `interactive-features.md` | Forms, conditional content, mail merge, version diffing |
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
├── assets/templates/                     # 27 compile-tested templates
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
│   ├── cheatsheet-general.tex            #   Landscape 3-col reference card (colored)
│   ├── cheatsheet-exam.tex               #   Portrait 2-col exam formula sheet (B&W)
│   ├── cheatsheet-code.tex               #   Landscape 4-col programming reference
│   ├── fillable-form.tex                 #   Fillable PDF form (hyperref fields)
│   ├── conditional-document.tex          #   Toggle-based conditional sections
│   ├── mail-merge-letter.tex             #   Mail merge letter template
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
│   ├── pdf_to_images.sh                  #   PDF -> page images (for OCR pipeline)
│   ├── mail_merge.py                     #   Template + CSV/JSON -> N personalized PDFs
│   └── latex_diff.sh                     #   latexdiff wrapper (auto-install, git, compile)
├── references/                           #   13 reference guides
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
│   ├── interactive-features.md
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
