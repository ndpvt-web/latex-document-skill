# Document Format Conversion Reference

## Overview

**Pandoc** is a universal document converter that can transform documents between many different formats. It's particularly powerful for converting between Markdown, LaTeX, DOCX, HTML, and PDF formats.

### When to Use Pandoc

- **Markdown → LaTeX**: When you want to write in simple Markdown but need LaTeX output for academic papers or publications
- **LaTeX → Markdown**: When collaborating with non-LaTeX users or editing in a simpler format
- **DOCX → LaTeX**: When receiving Word documents that need to be converted to LaTeX
- **LaTeX → DOCX**: For journal submissions requiring Word format or collaboration with Word users
- **LaTeX → HTML**: For publishing documents on the web with proper math rendering
- **LaTeX → PDF**: Alternative to pdflatex/xelatex for simpler documents

### Key Features

- Preserves document structure (headings, lists, tables)
- Handles mathematical equations (LaTeX math syntax)
- Converts citations and bibliographies
- Supports images and figures
- Customizable via templates
- Extensible with filters

---

## Markdown to LaTeX

Converting Markdown to LaTeX is useful when you want to write content quickly in Markdown but need the typesetting power and requirements of LaTeX.

### Basic Conversion

```bash
pandoc input.md -o output.tex --standalone
```

The `--standalone` flag creates a complete LaTeX document with preamble and document environment.

### Example: Markdown Input

```markdown
# Introduction

This is a **simple** document with *emphasis*.

## Mathematical Equations

The quadratic formula is:

$$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$

Inline math: $E = mc^2$

## Lists

1. First item
2. Second item
   - Nested bullet
   - Another bullet
3. Third item

## Code

Here's some Python code:

\`\`\`python
def hello():
    print("Hello, world!")
\`\`\`

## Table

| Name    | Age | City     |
|---------|-----|----------|
| Alice   | 30  | New York |
| Bob     | 25  | Boston   |
| Charlie | 35  | Chicago  |

## Images

![A beautiful landscape](landscape.jpg)
```

### LaTeX Output Structure

```latex
\documentclass{article}
\usepackage{graphicx}
\usepackage{amsmath}

\begin{document}

\section{Introduction}
This is a \textbf{simple} document with \emph{emphasis}.

\subsection{Mathematical Equations}
The quadratic formula is:
\[x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}\]

Inline math: $E = mc^2$

\subsection{Lists}
\begin{enumerate}
\item First item
\item Second item
  \begin{itemize}
  \item Nested bullet
  \item Another bullet
  \end{itemize}
\item Third item
\end{enumerate}

% ... etc
\end{document}
```

### Handling Math

Pandoc automatically converts:
- `$...$` → inline math
- `$$...$$` → display math equations
- `\begin{equation}...\end{equation}` → numbered equations

### Handling Images

Markdown images are converted to `\includegraphics`:

```markdown
![Caption text](image.png)
```

Becomes:

```latex
\begin{figure}
\centering
\includegraphics{image.png}
\caption{Caption text}
\end{figure}
```

### Handling Tables

Pandoc converts Markdown tables to LaTeX `tabular` environment:

```latex
\begin{table}
\centering
\begin{tabular}{lll}
\toprule
Name & Age & City \\
\midrule
Alice & 30 & New York \\
Bob & 25 & Boston \\
Charlie & 35 & Chicago \\
\bottomrule
\end{tabular}
\end{table}
```

### Advanced: Custom LaTeX Template

Create a custom template for specific formatting:

```bash
pandoc input.md -o output.tex \
  --template=custom.latex \
  --variable documentclass=report \
  --variable fontsize=12pt \
  --variable geometry:margin=1in
```

---

## LaTeX to Markdown

Converting LaTeX to Markdown is useful for collaborative editing, web publishing, or creating simpler versions of documents.

### Basic Conversion

```bash
pandoc input.tex -o output.md --from=latex --to=markdown
```

### What Gets Preserved

- Section headings → Markdown headings
- `\textbf{}` → `**bold**`
- `\emph{}` → `*italic*`
- Math equations (preserved as `$...$` and `$$...$$`)
- Lists and tables
- Images (converted to Markdown image syntax)

### What May Be Lost

- Complex LaTeX packages and custom commands
- Precise formatting (margins, fonts, spacing)
- TikZ diagrams (converted to raw LaTeX blocks)
- Custom environments (may need manual cleanup)

### Example

**LaTeX Input:**
```latex
\section{Results}

Our experiment showed that \textbf{accuracy improved} by 15\%.

\begin{equation}
\text{Accuracy} = \frac{TP + TN}{TP + TN + FP + FN}
\end{equation}
```

**Markdown Output:**
```markdown
# Results

Our experiment showed that **accuracy improved** by 15%.

$$\text{Accuracy} = \frac{TP + TN}{TP + TN + FP + FN}$$
```

---

## DOCX to LaTeX

Converting Word documents to LaTeX is common when collaborating with non-LaTeX users or when receiving submissions in Word format.

### Basic Conversion

```bash
pandoc manuscript.docx -o manuscript.tex --standalone
```

### Preserving Formatting

Pandoc converts:
- **Bold** → `\textbf{}`
- *Italic* → `\emph{}`
- Headings → `\section{}`, `\subsection{}`
- Lists → `enumerate`, `itemize`
- Tables → `tabular`
- Images → `\includegraphics{}`

### Handling Images

Images embedded in DOCX are extracted to a media folder:

```bash
pandoc manuscript.docx -o manuscript.tex --extract-media=./media
```

This creates `./media/` containing extracted images, and the LaTeX file will reference them:

```latex
\includegraphics{./media/image1.png}
```

### Handling Equations

- Word equations (MathType/Office Math) are converted to LaTeX math
- Quality varies depending on how equations were created in Word

### Common Issues

1. **Complex formatting may not convert perfectly** - manual cleanup often needed
2. **Track changes are lost** - accept all changes before conversion
3. **Page numbers/headers/footers** - not preserved, need manual addition
4. **Custom fonts** - may need manual specification in LaTeX

### Example Workflow

```bash
# 1. Convert DOCX to LaTeX
pandoc paper.docx -o paper.tex --standalone --extract-media=./figures

# 2. Review and clean up paper.tex
# 3. Adjust preamble, add packages as needed
# 4. Compile with pdflatex or lualatex
```

---

## LaTeX to DOCX

Converting LaTeX to Word is often required for journal submissions that only accept DOCX format or for collaboration with non-LaTeX users.

### Basic Conversion

```bash
pandoc paper.tex -o paper.docx --standalone
```

### With Bibliography

```bash
pandoc paper.tex -o paper.docx \
  --bibliography=references.bib \
  --csl=apa.csl
```

Download CSL styles from: https://github.com/citation-style-language/styles

### Preserving Formatting

Pandoc converts:
- `\section{}` → Heading 1
- `\subsection{}` → Heading 2
- `\textbf{}` → Bold
- `\emph{}` → Italic
- Math equations → Office Math format
- Tables → Word tables
- Figures → Embedded images

### What May Be Lost

- Custom LaTeX commands
- TikZ diagrams (need to convert to images first)
- Precise spacing and layout
- Custom page headers/footers
- Some advanced math constructs

### Best Practices

1. **Use standard LaTeX commands** - avoid custom macros
2. **Convert TikZ to images** before running Pandoc
3. **Test early** - don't wait until submission deadline
4. **Keep LaTeX as source of truth** - DOCX is for distribution only

### Example: Journal Submission

```bash
# Convert to DOCX with bibliography
pandoc manuscript.tex -o submission.docx \
  --bibliography=refs.bib \
  --csl=ieee.csl \
  --toc

# Open in Word to:
# - Verify formatting
# - Add page numbers
# - Check that equations rendered correctly
# - Adjust figure placements
```

---

## LaTeX to HTML

Converting LaTeX to HTML is useful for web publishing, online documentation, or creating accessible versions of documents.

### Basic Conversion

```bash
pandoc paper.tex -o paper.html --standalone --mathjax
```

The `--mathjax` flag enables proper math rendering in browsers.

### With Table of Contents

```bash
pandoc document.tex -o document.html \
  --standalone \
  --mathjax \
  --toc \
  --toc-depth=3
```

### MathJax Integration

Pandoc automatically includes MathJax for rendering LaTeX math in HTML:

```html
<script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
```

Math is preserved in LaTeX syntax and rendered by MathJax:

```html
<p>The equation is \(E = mc^2\).</p>

<p>\[\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}\]</p>
```

### Custom CSS Styling

```bash
pandoc paper.tex -o paper.html \
  --standalone \
  --mathjax \
  --css=style.css
```

Example `style.css`:

```css
body {
    font-family: 'Latin Modern Roman', serif;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    line-height: 1.6;
}

h1, h2, h3 {
    color: #2c3e50;
}

pre {
    background-color: #f4f4f4;
    padding: 10px;
    border-radius: 5px;
}
```

### Handling Images

LaTeX `\includegraphics{}` is converted to HTML `<img>` tags:

```latex
\includegraphics[width=0.5\textwidth]{figure.png}
```

Becomes:

```html
<img src="figure.png" style="width:50%;" />
```

### Self-Contained HTML

Create a single HTML file with embedded images:

```bash
pandoc paper.tex -o paper.html --standalone --mathjax --self-contained
```

This embeds images as base64 data URIs.

---

## HTML to LaTeX

Converting HTML to LaTeX is useful when you have web content that needs to be typeset in LaTeX format.

### Basic Conversion

```bash
pandoc webpage.html -o document.tex --standalone
```

### What Gets Converted

- `<h1>` → `\section{}`
- `<h2>` → `\subsection{}`
- `<strong>` → `\textbf{}`
- `<em>` → `\emph{}`
- `<ul>`, `<ol>` → `itemize`, `enumerate`
- `<table>` → `tabular`
- `<img>` → `\includegraphics{}`
- Math (if using MathJax) → LaTeX math

### Limitations

- CSS styling is not converted
- JavaScript content is ignored
- Complex HTML layouts may not translate well
- Web fonts are not preserved

### Best Practices

1. Clean HTML (remove navigation, ads, etc.) before conversion
2. Ensure images are accessible via relative paths
3. Test and manually adjust formatting
4. May need to restructure for LaTeX document flow

---

## Using convert_document.sh

The `convert_document.sh` script provides a convenient wrapper around Pandoc with automatic format detection.

### Basic Usage

```bash
# Markdown to LaTeX
convert_document.sh report.md report.tex

# LaTeX to PDF
convert_document.sh paper.tex paper.pdf

# DOCX to LaTeX
convert_document.sh manuscript.docx manuscript.tex
```

### With Options

```bash
# With table of contents
convert_document.sh document.md document.tex --toc

# With bibliography
convert_document.sh paper.tex paper.pdf \
  --bibliography=refs.bib \
  --csl=ieee.csl

# With custom template
convert_document.sh report.md report.tex \
  --template=custom_template.latex \
  --standalone

# Multiple options
convert_document.sh thesis.md thesis.pdf \
  --toc \
  --bibliography=references.bib \
  --csl=chicago.csl \
  --standalone
```

### Auto-Detection Examples

The script automatically detects conversion direction:

```bash
# .md → .tex (auto-detected)
convert_document.sh input.md output.tex

# .tex → .html (auto-detected with MathJax)
convert_document.sh input.tex output.html

# .docx → .tex (auto-detected with media extraction)
convert_document.sh input.docx output.tex
```

### Script Features

- **Auto-installs Pandoc** if missing (checks first)
- **Colored output** for better readability
- **Error handling** with helpful messages
- **File size reporting** after conversion
- **Absolute path output** for easy reference

---

## Common Pitfalls

### 1. Character Encoding Issues

**Problem:** Special characters (é, ñ, 中文) don't display correctly.

**Solution:**
```bash
# Ensure UTF-8 encoding
pandoc input.md -o output.tex --standalone
# Then use lualatex or xelatex instead of pdflatex
lualatex output.tex
```

Or specify in LaTeX:
```latex
\usepackage[utf8]{inputenc}
```

### 2. Image Path Problems

**Problem:** Images don't appear in converted document.

**Solution:**
- Use relative paths from the document location
- Extract embedded images: `--extract-media=./media`
- Verify image files exist at specified paths
- Copy images to appropriate directory after conversion

### 3. Math Rendering Issues

**Problem:** Math equations don't render or appear as raw LaTeX.

**Solution:**
- For HTML: Use `--mathjax` flag
- For DOCX: Ensure Office Math support
- For LaTeX → MD: Math is preserved as `$...$`
- Complex math may need manual adjustment

### 4. Bibliography Not Appearing

**Problem:** Citations show as `[@ref]` instead of formatted references.

**Solution:**
```bash
# Include bibliography file
pandoc input.md -o output.pdf \
  --bibliography=refs.bib \
  --csl=style.csl

# Or use LaTeX's biblatex:
pandoc input.md -o output.tex --biblatex
# Then compile with biber
```

### 5. Tables Break Across Pages

**Problem:** Long tables split awkwardly in PDF output.

**Solution:**
- Use `longtable` package in LaTeX
- Add to Pandoc template or manually edit
- Consider rotating wide tables with `rotating` package

### 6. Custom LaTeX Commands Not Recognized

**Problem:** `\newcommand` definitions cause errors in conversion.

**Solution:**
- Define commands in Pandoc template
- Use `--include-in-header=defs.tex`
- Convert custom commands to standard LaTeX before conversion
- Use Pandoc filters for complex transformations

---

## Advanced Topics

### Custom Pandoc Templates

Create a custom LaTeX template for consistent formatting:

```bash
# Get default template
pandoc -D latex > my_template.latex

# Edit my_template.latex to customize
# - Add packages
# - Modify page layout
# - Change fonts
# - Add custom commands

# Use template
pandoc input.md -o output.tex --template=my_template.latex
```

### Pandoc Filters

Filters allow custom transformations during conversion:

**Example:** Convert all `<span class="todo">` to LaTeX `\todo{}` commands

```python
#!/usr/bin/env python3
# todo_filter.py
from pandocfilters import toJSONFilter, RawInline

def todo(key, value, format, meta):
    if key == 'Span':
        [[ident, classes, kvs], content] = value
        if 'todo' in classes:
            if format == 'latex':
                return RawInline('latex', '\\todo{' +
                    str(content) + '}')

if __name__ == "__main__":
    toJSONFilter(todo)
```

Usage:
```bash
pandoc input.md -o output.tex --filter=./todo_filter.py
```

### Metadata Blocks

Add document metadata in Markdown:

```markdown
---
title: "My Document Title"
author: "John Doe"
date: "2026-02-15"
abstract: "This is the abstract."
keywords: [pandoc, conversion, latex]
---

# Introduction

Document content here...
```

Pandoc uses this metadata in the generated document.

### Variables for Templates

Pass variables to customize output:

```bash
pandoc input.md -o output.pdf \
  --variable documentclass=report \
  --variable fontsize=12pt \
  --variable geometry:margin=1in \
  --variable colorlinks=true \
  --variable linkcolor=blue
```

### Batch Conversion

Convert multiple files:

```bash
# Convert all .md files to .tex
for file in *.md; do
    pandoc "$file" -o "${file%.md}.tex" --standalone
done

# Convert all .tex files to .pdf with bibliography
for file in *.tex; do
    pandoc "$file" -o "${file%.tex}.pdf" \
      --bibliography=refs.bib \
      --csl=ieee.csl
done
```

### Combining Documents

Concatenate multiple Markdown files:

```bash
pandoc chapter1.md chapter2.md chapter3.md \
  -o book.pdf \
  --toc \
  --number-sections \
  --bibliography=refs.bib
```

---

## Quick Reference

### Common Conversions

| From   | To     | Command |
|--------|--------|---------|
| MD     | TEX    | `pandoc input.md -o output.tex --standalone` |
| TEX    | MD     | `pandoc input.tex -o output.md` |
| MD     | PDF    | `pandoc input.md -o output.pdf` |
| TEX    | PDF    | `pandoc input.tex -o output.pdf` |
| DOCX   | TEX    | `pandoc input.docx -o output.tex --standalone --extract-media=./media` |
| TEX    | DOCX   | `pandoc input.tex -o output.docx --bibliography=refs.bib` |
| TEX    | HTML   | `pandoc input.tex -o output.html --mathjax --standalone` |
| HTML   | TEX    | `pandoc input.html -o output.tex --standalone` |

### Useful Flags

- `--standalone` - Complete document with preamble
- `--toc` - Include table of contents
- `--mathjax` - Enable math rendering in HTML
- `--bibliography=FILE` - Include bibliography
- `--csl=FILE` - Citation style
- `--template=FILE` - Custom template
- `--extract-media=DIR` - Extract embedded images
- `--self-contained` - Embed images in HTML
- `--number-sections` - Number sections automatically

### Resources

- **Pandoc Manual**: https://pandoc.org/MANUAL.html
- **CSL Styles**: https://github.com/citation-style-language/styles
- **Pandoc Templates**: https://github.com/jgm/pandoc/wiki/User-contributed-templates
- **Pandoc Filters**: https://pandoc.org/filters.html
