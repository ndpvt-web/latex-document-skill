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
| `tikz` | Programmatic vector graphics |
| `wrapfig` | Wrap text around figures |
| `subcaption` | Subfigures within a figure |
| `float` | Force figure placement with `[H]` |

## Lists
| Package | Purpose |
|---------|---------|
| `enumitem` | Customize itemize/enumerate spacing and labels |

## Math
| Package | Purpose |
|---------|---------|
| `amsmath` | Advanced math environments |
| `amssymb` | Additional math symbols |

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
