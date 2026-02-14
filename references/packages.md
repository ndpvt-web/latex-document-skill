# Common LaTeX Packages Quick Reference

## Essential (include in most documents)
| Package | Purpose |
|---------|---------|
| `inputenc` | UTF-8 input encoding (`\usepackage[utf8]{inputenc}`) |
| `fontenc` | T1 font encoding (`\usepackage[T1]{fontenc}`) |
| `geometry` | Page margins and dimensions |
| `hyperref` | Clickable links, URLs, cross-references |
| `xcolor` | Color definitions and usage |
| `graphicx` | Image inclusion (`\includegraphics`) |

## Typography
| Package | Purpose |
|---------|---------|
| `titlesec` | Customize section heading styles |
| `fancyhdr` | Custom headers and footers |
| `parskip` | Paragraph spacing instead of indentation |
| `microtype` | Improved text justification and kerning |
| `lmodern` | Latin Modern fonts (scalable) |
| `setspace` | Line spacing (`\singlespacing`, `\onehalfspacing`, `\doublespacing`) |

## Tables
| Package | Purpose |
|---------|---------|
| `tabularx` | Tables with auto-width `X` columns |
| `array` | Extended column definitions (`>{...}`, `p{width}`) |
| `booktabs` | Professional rules: `\toprule`, `\midrule`, `\bottomrule` |
| `colortbl` | `\rowcolor`, `\cellcolor`, `\columncolor` |
| `multirow` | `\multirow{rows}{width}{text}` |
| `longtable` | Tables spanning multiple pages |

## Images and Drawing
| Package | Purpose |
|---------|---------|
| `graphicx` | `\includegraphics[width=..]{file}` |
| `tikz` | Programmatic vector graphics, diagrams |
| `wrapfig` | Wrap text around figures |
| `subcaption` | Subfigures within a figure |
| `float` | Force figure placement with `[H]` |
| `caption` | Customize figure/table captions |

## Charts and Graphs
| Package | Purpose |
|---------|---------|
| `pgfplots` | Line charts, bar charts, scatter plots, histograms |
| `pgfplotstable` | Read and plot from CSV/TSV data files |
| `tikz` | Flowcharts, timelines, custom diagrams |

## Lists
| Package | Purpose |
|---------|---------|
| `enumitem` | Customize itemize/enumerate spacing, labels, nesting |

## Math
| Package | Purpose |
|---------|---------|
| `amsmath` | Advanced math environments (`align`, `gather`, `cases`) |
| `amssymb` | Additional math symbols (`\mathbb`, `\therefore`) |
| `amsthm` | Theorem environments (`\newtheorem`) |
| `mathtools` | Extensions to amsmath (paired delimiters, cases) |
| `mathrsfs` | Script math font (`\mathscr`) |
| `bbm` | Blackboard bold indicator (`\mathbbm{1}`) |
| `esint` | Extended surface integrals (`\oiint`) |
| `cancel` | Cancellation marks in equations (`\cancel{x}`) |

## Presentations
| Package | Purpose |
|---------|---------|
| `beamer` | Document class for slides/presentations |
| Common themes | `Madrid`, `Berlin`, `CambridgeUS`, `Boadilla`, `Warsaw` |

## Bibliography
| Package | Purpose |
|---------|---------|
| `natbib` | Author-year citations (`\citet`, `\citep`) |
| `biblatex` | Modern bibliography management (more flexible than natbib) |

## Legal / Long Documents
| Package | Purpose |
|---------|---------|
| `setspace` | Double/1.5 spacing for legal/academic docs |
| `footmisc` | Footnote customization |
| `lineno` | Line numbering (for legal documents, drafts) |
| `multicol` | Multi-column layouts |

## Special Characters
- `%` → `\%`
- `$` → `\$`
- `&` → `\&`
- `#` → `\#`
- `_` → `\_`
- `{` → `\{`
- `}` → `\}`
- `~` → `\textasciitilde`
- `^` → `\textasciicircum`
- `\` → `\textbackslash`
- `--` → en-dash (ranges: 2019--2025)
- `---` → em-dash (parenthetical)
- `§` → `\S` (section symbol)
- `¶` → `\P` (paragraph symbol)
- `©` → `\copyright`
- `®` → `\textregistered`
- `™` → `\texttrademark`
