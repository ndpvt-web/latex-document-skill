# LaTeX Debugging & Error Resolution Guide

A comprehensive guide to understanding, diagnosing, and fixing LaTeX compilation errors.

## Table of Contents

1. [Reading LaTeX Error Messages](#1-reading-latex-error-messages)
2. [The 20 Most Common Errors](#2-the-20-most-common-errors-with-fixes)
3. [Reading the .log File](#3-reading-the-log-file)
4. [Debugging Strategies](#4-debugging-strategies)
5. [Common Silent Failures](#5-common-silent-failures-no-error-wrong-output)
6. [Package Conflicts & Resolution](#6-package-conflicts--resolution)
7. [Quick Reference: Error → Solution Table](#7-quick-reference-error--solution-table)
8. [Using compile_latex.sh Error Output](#8-using-compile_latexsh-error-output)

---

## 1. Reading LaTeX Error Messages

### Error Message Anatomy

LaTeX error messages follow a consistent structure. Understanding this structure is critical for quick debugging.

```
! LaTeX Error: Environment theorem undefined.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...

l.42 \begin{theorem}

?
```

**The 3 Most Important Lines:**

1. **Line 1** (starts with `!`): The error type and brief description
   - `! LaTeX Error:` = LaTeX-level error
   - `! Undefined control sequence` = TeX-level error
   - `! Package foo Error:` = Package-specific error

2. **Line starting with `l.`**: The line number where LaTeX detected the error
   - `l.42` means line 42 in your source file
   - The actual mistake may be on a previous line (missing `}`, etc.)

3. **The context lines**: Show what LaTeX was processing when it failed
   - Text before the line break is what LaTeX successfully processed
   - Text after shows what's left to process

### Error vs Warning vs Emergency Stop

**Error (`! Error`)**: Compilation stopped, must be fixed
- LaTeX cannot continue
- You get the `?` prompt (can type `x` to exit)
- Produces no PDF, or PDF stops at error location

**Warning (no `!`)**: Compilation continues, should investigate
```
LaTeX Warning: Reference `fig:missing' on page 1 undefined.
```
- PDF is produced but may have issues
- Often indicates undefined references, bad citations, or overfull boxes

**Emergency Stop**:
```
!  ==> Fatal error occurred, no output PDF file produced!
```
- Unrecoverable error (often syntax or file system)
- Usually preceded by other errors showing the root cause

**Compilation Tip**: Always fix errors from **top to bottom**. One early error can cascade into dozens of false errors below it.

---

## 2. The 20 Most Common Errors (with fixes)

### 1. `! Undefined control sequence`

**Error text:**
```
! Undefined control sequence.
l.15 \theorem
            {Pythagorean Theorem}
```

**Cause**: Using a command that doesn't exist. Common reasons:
- Typo in command name
- Missing `\usepackage{...}` to define the command
- Using underscore `_` in text mode (should be `\_`)

**Fix:**
```latex
% Wrong:
\theorem{Pythagorean Theorem}
The file is named data_file.txt

% Right:
\begin{theorem}  % Or load a package that defines \theorem
Pythagorean Theorem
\end{theorem}

The file is named data\_file.txt  % Escape underscores
```

### 2. `! Missing $ inserted`

**Error text:**
```
! Missing $ inserted.
<inserted text>
                $
l.23 The complexity is O(n^2
                            ) for this algorithm.
```

**Cause**: Using math-mode commands (`^`, `_`, `\alpha`, etc.) in text mode without `$...$`.

**Fix:**
```latex
% Wrong:
The complexity is O(n^2) for this algorithm.

% Right:
The complexity is $O(n^2)$ for this algorithm.

% Also wrong:
\alpha is the learning rate

% Right:
$\alpha$ is the learning rate
```

### 3. `! Missing \begin{document}`

**Error text:**
```
! LaTeX Error: Missing \begin{document}.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...
l.6 S
     ome text before document begins
```

**Cause**: Text or commands that produce output before `\begin{document}`.

**Fix:**
```latex
% Wrong:
\documentclass{article}
\usepackage{graphicx}
Some text here  % This causes the error

\begin{document}
...

% Right:
\documentclass{article}
\usepackage{graphicx}
% Only preamble commands allowed here

\begin{document}
Some text here  % Text goes after \begin{document}
```

### 4. `! LaTeX Error: Environment X undefined`

**Error text:**
```
! LaTeX Error: Environment algorithm undefined.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...

l.45 \begin{algorithm}
```

**Cause**: Using an environment without loading the package that defines it.

**Fix:**
```latex
% Wrong:
\documentclass{article}
\begin{document}
\begin{algorithm}  % Error: algorithm undefined
...
\end{algorithm}

% Right:
\documentclass{article}
\usepackage{algorithm}  % Load the package
\usepackage{algpseudocode}
\begin{document}
\begin{algorithm}
...
\end{algorithm}
```

**Common environment → package mappings:**
- `algorithm` → `\usepackage{algorithm}`
- `lstlisting` → `\usepackage{listings}`
- `tikzpicture` → `\usepackage{tikz}`
- `align` → `\usepackage{amsmath}`
- `theorem` → `\usepackage{amsthm}` (or define manually)

### 5. `! Extra alignment tab character &`

**Error text:**
```
! Extra alignment tab character &.
l.12 a & b & c & d & e
                      &
```

**Cause**: Using more `&` than columns defined in table/matrix preamble.

**Fix:**
```latex
% Wrong:
\begin{tabular}{ccc}  % Only 3 columns defined
a & b & c & d & e     % But 5 columns used
\end{tabular}

% Right:
\begin{tabular}{ccccc}  % 5 columns defined
a & b & c & d & e       % 5 columns used
\end{tabular}

% Or for matrices:
% Wrong:
\begin{bmatrix}
1 & 2 & 3 & 4  % 4 columns
\end{bmatrix}

% Right:
\begin{bmatrix}
1 & 2 & 3 & 4  % Matrices infer column count from first row
\end{bmatrix}
```

### 6. `! Misplaced alignment tab character &`

**Error text:**
```
! Misplaced alignment tab character &.
l.8 In this equation, x &
                         = 5
```

**Cause**: Using `&` outside a table, matrix, or alignment environment.

**Fix:**
```latex
% Wrong:
In this equation, x & = 5

% Right:
In this equation, $x = 5$

% If you need alignment, use an alignment environment:
\begin{align}
x &= 5 \\
y &= 10
\end{align}
```

### 7. `! Missing number, treated as zero`

**Error text:**
```
! Missing number, treated as zero.
<to be read again>
                   \vspace
l.25 \includegraphics[width=\textwidth
                                       ]{image.pdf}
```

**Cause**: Incomplete or malformed dimension/number specification, often a typo or missing `=`.

**Fix:**
```latex
% Wrong:
\includegraphics[width\textwidth]{image.pdf}  % Missing =
\vspace{3}  % Missing unit

% Right:
\includegraphics[width=\textwidth]{image.pdf}
\vspace{3cm}  % or 3pt, 3em, etc.

% Wrong:
\parbox{5}{text}

% Right:
\parbox{5cm}{text}
```

### 8. `! Illegal unit of measure`

**Error text:**
```
! Illegal unit of measure (pt inserted).
<to be read again>
                   }
l.30 \rule{3}{
            0.4pt}
```

**Cause**: Length command missing a unit (pt, cm, mm, em, ex, etc.).

**Fix:**
```latex
% Wrong:
\rule{3}{0.4pt}  % First dimension missing unit
\hspace{10}

% Right:
\rule{3cm}{0.4pt}
\hspace{10pt}

% Valid units:
% pt (point), cm, mm, in (inch), em (width of 'M'), ex (height of 'x')
% Also: \textwidth, \linewidth, \textheight, etc.
```

### 9. `! Too many }'s` or `! Too many {'s`

**Error text:**
```
! Too many }'s.
l.67 \textbf{This is bold}}

```

**Cause**: Unbalanced braces – more closing `}` than opening `{`, or vice versa.

**Fix:**
```latex
% Wrong:
\textbf{This is bold}}  % Extra }

% Right:
\textbf{This is bold}

% Wrong:
\frac{x{y+1}  % Missing }

% Right:
\frac{x}{y+1}

% Debugging tip: Use an editor with brace matching
% Count { and } on the problem line and surrounding lines
```

**Finding unbalanced braces:**
- Use editor's "Go to matching bracket" feature
- Comment out sections to isolate the problem
- Count: for every `{` there must be a matching `}`

### 10. `! File X not found`

**Error text:**
```
! LaTeX Error: File `image.png' not found.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...

l.45 \includegraphics{image.png}
```

**Cause**: Referenced file doesn't exist or path is incorrect.

**Fix:**
```latex
% Check:
% 1. File exists and name is spelled correctly (case-sensitive on Linux)
% 2. File is in correct directory relative to .tex file
% 3. File extension is correct

% Wrong (if file is in images/ subdirectory):
\includegraphics{logo.pdf}

% Right:
\includegraphics{images/logo.pdf}

% Or use relative paths:
\graphicspath{{./images/}{./figures/}}
\includegraphics{logo.pdf}  % Now searches in images/ and figures/

% For \input or \include:
% Wrong:
\input{chapter1}  % If file is chapter1.tex

% Right:
\input{chapter1.tex}  % Specify extension for clarity
```

### 11. `! LaTeX Error: \begin{X} on input line Y ended by \end{Z}`

**Error text:**
```
! LaTeX Error: \begin{itemize} on input line 12 ended by \end{enumerate}.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...

l.15 \end{enumerate}
```

**Cause**: Mismatched environment names or improper nesting.

**Fix:**
```latex
% Wrong:
\begin{itemize}
\item First
\item Second
\end{enumerate}  % Should be \end{itemize}

% Right:
\begin{itemize}
\item First
\item Second
\end{itemize}

% Wrong (improper nesting):
\begin{equation}
\begin{itemize}  % Can't put itemize inside equation
\item x = 5
\end{itemize}
\end{equation}

% Right:
\begin{itemize}
\item $x = 5$
\end{itemize}
```

### 12. `! Package hyperref Error: Wrong DVI mode driver option`

**Error text:**
```
! Package hyperref Error: Wrong DVI mode driver option `dvips',
(hyperref)                because pdfTeX is running in PDF mode.
```

**Cause**: Loading hyperref with driver options that conflict with compilation mode.

**Fix:**
```latex
% Wrong (when using pdflatex):
\usepackage[dvips]{hyperref}

% Right (let hyperref auto-detect):
\usepackage{hyperref}

% If you must specify:
\usepackage[pdftex]{hyperref}  % For pdflatex
\usepackage[xetex]{hyperref}   % For xelatex
\usepackage[luatex]{hyperref}  % For lualatex

% Best practice: Never specify driver unless absolutely necessary
\usepackage{hyperref}  % Auto-detects correctly
```

### 13. `! Overfull \hbox`

**Error text:**
```
Overfull \hbox (15.23pt too wide) in paragraph at lines 34--36
```

**Cause**: Content exceeds the line width (margin). Not technically an error, but indicates formatting issues. Common with:
- URLs or long unbreakable strings
- Wide tables or figures
- Code listings

**Fix:**
```latex
% Wrong:
This is a very long URL: https://www.example.com/very/long/path/to/resource/file.pdf

% Right:
\usepackage{hyperref}
\usepackage{url}
This is a very long URL: \url{https://www.example.com/very/long/path/to/resource/file.pdf}

% For tables:
% Wrong:
\begin{tabular}{llllll}
Very Long Column Header & Another Long Header & ...
\end{tabular}

% Right:
\begin{tabular}{p{2cm}p{2cm}p{2cm}}  % Fixed-width columns
\small  % Smaller font
Very Long Column Header & Another Long Header & ...
\end{tabular}

% Or use tabularx:
\usepackage{tabularx}
\begin{tabularx}{\textwidth}{XXX}  % Auto-width columns
...
\end{tabularx}

% For code:
\usepackage{listings}
\lstset{breaklines=true}  % Auto-wrap long lines
```

### 14. `! LaTeX Error: Option clash for package X`

**Error text:**
```
! LaTeX Error: Option clash for package graphicx.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...

l.5 \usepackage[draft]{graphicx}
```

**Cause**: Package loaded twice with different options.

**Fix:**
```latex
% Wrong:
\usepackage{graphicx}
\usepackage[draft]{graphicx}  % Loaded again with different options

% Right - Method 1: Use same options everywhere
\usepackage[draft]{graphicx}

% Right - Method 2: Use \PassOptionsToPackage before \documentclass
\PassOptionsToPackage{draft}{graphicx}
\documentclass{article}
\usepackage{graphicx}

% Right - Method 3: Load once with all options
\usepackage[draft,final]{graphicx}  % Last option wins

% Common with document classes that auto-load packages:
% Wrong:
\documentclass{article}  % Loads graphicx internally
\usepackage[draft]{graphicx}  % Option clash

% Right:
\PassOptionsToPackage{draft}{graphicx}
\documentclass{article}
```

### 15. `! Capacity exceeded, sorry`

**Error text:**
```
! TeX capacity exceeded, sorry [input stack size=5000].
```

**Cause**: Infinite loop, recursive macro, or massive data structure (huge table, deeply nested lists).

**Fix:**
```latex
% Common cause: recursive definition
% Wrong:
\newcommand{\foo}{\foo bar}  % Calls itself infinitely

% Right:
\newcommand{\foo}{bar}

% For huge tables, split into multiple smaller tables or use longtable:
\usepackage{longtable}
\begin{longtable}{lll}
% Very long table that spans multiple pages
...
\end{longtable}

% If the problem is legitimate (very complex document):
% Increase capacity (in latexmk, pdflatex, etc.):
% pdflatex -extra-mem-top=10000000 document.tex

% Or add to document:
% !TEX parameter = -extra-mem-top=10000000
```

### 16. `! Dimension too large`

**Error text:**
```
! Dimension too large.
<recently read> \pgf@x

l.123 \end{tikzpicture}
```

**Cause**: Coordinate or dimension exceeds TeX's maximum (~575cm or ~16383pt). Common in:
- TikZ with huge coordinates
- pgfplots with extreme data values
- Image scaling with huge factors

**Fix:**
```latex
% Wrong:
\begin{tikzpicture}
\draw (0,0) -- (100000,100000);  % Coordinates too large
\end{tikzpicture}

% Right - scale down:
\begin{tikzpicture}[scale=0.001]
\draw (0,0) -- (100000,100000);
\end{tikzpicture}

% For pgfplots:
\begin{tikzpicture}
\begin{axis}[
  xmin=0, xmax=1e6,
  ymin=0, ymax=1e6,
  scaled ticks=true,  % Use scientific notation
  tick label style={/pgf/number format/sci}
]
\addplot coordinates {(0,0) (1e6,1e6)};
\end{axis}
\end{tikzpicture}

% For images:
% Wrong:
\includegraphics[width=100\textwidth]{image.pdf}  % 100x too large

% Right:
\includegraphics[width=\textwidth]{image.pdf}
```

### 17. `Runaway argument?`

**Error text:**
```
Runaway argument?
{This is the start of a caption but there's no closing brace
! Paragraph ended before \caption was complete.
<to be read again>
                   \par
l.89
```

**Cause**: Missing closing brace `}` in command argument. LaTeX keeps reading, looking for the `}`, until it hits something incompatible (like `\par` or end of file).

**Fix:**
```latex
% Wrong:
\caption{This is a very long caption that explains the figure
and continues for several lines but forgot the closing brace

% Right:
\caption{This is a very long caption that explains the figure
and continues for several lines with proper closing}

% Wrong:
\section{Introduction  % Missing }

% Right:
\section{Introduction}

% Debugging: Look at the line mentioned in the error and search UPWARD
% for the command with the unclosed brace
```

### 18. `! LaTeX Error: Not in outer par mode`

**Error text:**
```
! LaTeX Error: Not in outer par mode.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...

l.56 \begin{figure}
```

**Cause**: Trying to use a float (`figure`, `table`) inside another float or in a restricted environment (minipage, parbox, etc.).

**Fix:**
```latex
% Wrong:
\begin{figure}
  \begin{figure}  % Can't nest figures
    \includegraphics{inner.pdf}
  \end{figure}
  \caption{Outer figure}
\end{figure}

% Right - use subfigures:
\usepackage{subcaption}
\begin{figure}
  \begin{subfigure}{0.45\textwidth}
    \includegraphics[width=\textwidth]{img1.pdf}
    \caption{First image}
  \end{subfigure}
  \hfill
  \begin{subfigure}{0.45\textwidth}
    \includegraphics[width=\textwidth]{img2.pdf}
    \caption{Second image}
  \end{subfigure}
  \caption{Combined figure}
\end{figure}

% Wrong:
\parbox{5cm}{
  \begin{table}  % Can't use float in parbox
  ...
  \end{table}
}

% Right - don't use float environment:
\parbox{5cm}{
  \captionof{table}{My table}  % Requires caption package
  \begin{tabular}{ll}
  ...
  \end{tabular}
}
```

### 19. `! LaTeX Error: Unknown float option 'H'`

**Error text:**
```
! LaTeX Error: Unknown float option `H'.

See the LaTeX manual or LaTeX Companion for explanation.
Type  H <return>  for immediate help.
 ...

l.23 \begin{figure}[H]
```

**Cause**: Using `[H]` placement specifier without loading the `float` package.

**Fix:**
```latex
% Wrong:
\documentclass{article}
\begin{document}
\begin{figure}[H]  % H undefined
\includegraphics{img.pdf}
\end{figure}

% Right:
\documentclass{article}
\usepackage{float}  % Provides [H] option
\begin{document}
\begin{figure}[H]  % "Place HERE, not floating"
\includegraphics{img.pdf}
\end{figure}

% Note: Standard options (no package needed):
% [h] = here if possible
% [t] = top of page
% [b] = bottom of page
% [p] = separate page of floats
% [!] = ignore internal float parameters
% [H] = HERE (requires float package, NOT a float anymore)
```

### 20. `! Package inputenc Error: Unicode character X`

**Error text:**
```
! Package inputenc Error: Unicode char \u8:− not set up for use with LaTeX.

See the inputenc package documentation for explanation.
Type  H <return>  for immediate help.
 ...

l.45 The result is x − y
```

**Cause**: Non-ASCII Unicode character in source that isn't handled by current encoding setup. Common with:
- Copy-pasted text from PDFs/websites (em-dash, smart quotes, etc.)
- Math symbols typed directly (−, ×, ≠, etc.)

**Fix:**
```latex
% Method 1: Use XeLaTeX or LuaLaTeX (recommended for Unicode)
% Compile with: xelatex document.tex
\documentclass{article}
\usepackage{fontspec}  % For XeLaTeX/LuaLaTeX
\begin{document}
The result is x − y  % Unicode minus works
\end{document}

% Method 2: Replace Unicode with LaTeX commands (for pdflatex)
% Wrong:
The result is x − y  % Unicode minus

% Right:
The result is x -- y  % En-dash
The result is $x - y$  % Math minus

% Common replacements:
% "smart quotes" → ``smart quotes''
% — (em-dash) → ---
% – (en-dash) → --
% … (ellipsis) → \ldots
% × → $\times$
% ÷ → $\div$
% ≠ → $\neq$

% Method 3: Configure inputenc for specific characters
\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage{newunicodechar}
\newunicodechar{−}{\text{-}}  % Map Unicode minus to hyphen
\begin{document}
The result is x − y
\end{document}
```

---

## 3. Reading the .log File

### Where to Find It

The `.log` file is created in the same directory as your `.tex` file:
- For `document.tex`, look for `document.log`
- Contains complete compilation output
- Not deleted on successful compilation (unlike `.aux`, `.out`, etc., in some setups)

### Key Patterns to Search For

**Search for errors:**
```bash
grep "^!" document.log
```

**Lines starting with `!` indicate errors:**
```
! Undefined control sequence.
! LaTeX Error: Environment 'theorem' undefined.
! Package hyperref Error: Wrong DVI mode driver option
```

**Search for warnings:**
```bash
grep -i "warning" document.log
```

**Common warnings:**
```
LaTeX Warning: Reference `eq:missing' on page 2 undefined.
LaTeX Warning: There were undefined references.
LaTeX Warning: Label `fig:duplicate' multiply defined.
Package hyperref Warning: Token not allowed in a PDF string
```

**Search for overfull/underfull boxes:**
```bash
grep -E "Overfull|Underfull" document.log
```

```
Overfull \hbox (15.23pt too wide) in paragraph at lines 34--36
Underfull \hbox (badness 10000) in paragraph at lines 67--68
```

### Understanding Pass-by-Pass Output

LaTeX often compiles in multiple passes. The log shows each pass:

```
**First pass:**
...
LaTeX Warning: Reference `sec:intro' on page 1 undefined on input line 23.
...

**Second pass:**
...
LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.
```

**Why multiple passes?**
- Pass 1: LaTeX doesn't know page numbers yet, so all `\ref` are `??`
- Pass 2: Uses `.aux` file from Pass 1 to resolve references
- Pass 3 (if needed): Resolves any changes from Pass 2

**Automation**: Use `latexmk` to automatically run enough passes:
```bash
latexmk -pdf document.tex
```

### Using grep for Quick Debugging

```bash
# Find all errors:
grep -n "^!" document.log

# Find specific error type:
grep -n "Undefined control sequence" document.log

# Find all warnings and errors:
grep -n -E "^!|Warning" document.log

# Find overfull boxes with context:
grep -n -A 2 "Overfull" document.log

# Find which packages were loaded:
grep "Package:" document.log | head -20

# Find file list (helpful for debugging missing packages):
grep -A 100 "\\*File List\\*" document.log
```

### Log File Structure

Typical sections in order:

1. **Header**: LaTeX version, format
2. **File loading**: Document class, packages
3. **Compilation**: Main document processing
   - Page numbers shown as `[1] [2] [3]`
   - Warnings/errors interspersed
4. **File list**: `\listfiles` output (if enabled)
5. **Summary**: Page count, warnings count

**Example useful section (file list):**
```
 *File List*
 article.cls    2021/10/04 v1.4n Standard LaTeX document class
  size10.clo    2021/10/04 v1.4n Standard LaTeX file (size option)
graphicx.sty    2021/09/16 v1.2d Enhanced LaTeX Graphics (DPC,SPQR)
  amsmath.sty    2021/10/15 v2.17l AMS math features
 ***********
```

Use `\listfiles` in preamble to ensure this section is generated.

---

## 4. Debugging Strategies

### Binary Search: Comment Out Half

When you have a large document with an error but can't locate it:

```latex
% 1. Start with the full document:
\begin{document}
Section 1 content...
Section 2 content...
Section 3 content...
Section 4 content...
Section 5 content...
Section 6 content...
\end{document}

% 2. Comment out the second half:
\begin{document}
Section 1 content...
Section 2 content...
Section 3 content...
% Section 4 content...
% Section 5 content...
% Section 6 content...
\end{document}

% 3. Compile:
%    - If error persists: error is in first half (Sections 1-3)
%    - If error gone: error is in second half (Sections 4-6)

% 4. Repeat: comment out half of the problematic half
%    Continue until you isolate the exact problematic line
```

**Pro tip**: Use `\include{chapter1}` for chapters, then comment out entire chapters quickly:
```latex
% \include{chapter1}  % Error not here
% \include{chapter2}  % Error not here
\include{chapter3}    % Error is here!
% \include{chapter4}
```

### Using `\listfiles`

Add to preamble to log all loaded files and versions:

```latex
\listfiles
\documentclass{article}
\usepackage{amsmath}
...
```

**Output in .log file:**
```
 *File List*
 article.cls    2021/10/04 v1.4n Standard LaTeX document class
  amsmath.sty    2021/10/15 v2.17l AMS math features
```

**Use this to:**
- Verify correct package versions
- Check if a package is actually loaded
- Debug "works on my machine" issues (version differences)

### Minimal Working Example (MWE) Technique

Reduce your document to the smallest possible example that reproduces the error:

```latex
% Start with this template:
\documentclass{article}
\usepackage{amsmath}  % Only packages needed for error
\begin{document}

% Minimal content that shows the error
$$
x = \frac{1}{0}  % If this causes error
$$

\end{document}
```

**Why create an MWE?**
- Eliminates irrelevant code that might be confusing
- Makes it clear which package causes the issue
- Easier to get help on Stack Exchange (MWEs are required)
- Forces you to understand the problem

**How to create MWE:**
1. Copy your document to `mwe.tex`
2. Delete everything not related to error
3. Remove unnecessary packages one by one
4. Compile after each change
5. Stop when it's as small as possible but still shows error

### Using Tracing Commands

LaTeX provides debugging output commands:

```latex
% Show every macro expansion (VERY verbose):
\tracingmacros=1
\badcommand{test}
\tracingmacros=0  % Turn off after problematic section

% Show command execution:
\tracingcommands=1
...
\tracingcommands=0

% Show online activity (paragraph building, page breaking):
\tracingonline=1
```

**Output appears in .log file**. Warning: Creates massive output. Only use on small sections:

```latex
\documentclass{article}
\begin{document}

Normal content here...

% Isolate problematic section:
\tracingmacros=1
This section has an error somewhere...
\tracingmacros=0

More normal content...
\end{document}
```

### Using `draft` Mode for Faster Compilation

Speed up compilation while debugging:

```latex
\documentclass[draft]{article}  % Draft mode
```

**Draft mode effects:**
- Images shown as boxes (not loaded)
- Overfull boxes marked with black rectangle
- Some packages disable features (faster compilation)

**When to use:**
- Debugging text/structure (don't need images)
- Working on large documents with many figures
- Checking overfull/underfull boxes (easier to see)

**Switch to final for submission:**
```latex
\documentclass[final]{article}  % Or just omit [draft]
```

### Interactive Debugging at the `?` Prompt

When compilation stops with `?`, you can type commands:

```
! Undefined control sequence.
l.42 \badcommand

?
```

**Useful responses:**
- `h` - Help (explains error)
- `x` - Exit (quit compilation immediately)
- `q` - Quiet mode (continue but suppress errors)
- `r` - Run without stopping (continue despite errors)
- `i` - Insert (type replacement text)
- `e` - Edit (some systems open editor at error line)

**Example:**
```
? i
insert> \newcommand  % Type correction
? x  % Then exit to fix in source file
```

**In practice**: Most users type `x` immediately and fix the source file.

### Using Editor Integration

Modern editors show errors inline:

**VS Code** (with LaTeX Workshop):
- Errors appear as red squiggles
- Hover for error message
- Click to jump to line in .log

**Vim** (with vimtex):
- `:VimtexErrors` to open quickfix window
- Jump between errors with `:cn` / `:cp`

**Emacs** (with AUCTeX):
- `C-c `` to jump to next error
- Error descriptions shown in minibuffer

**Configure your editor** for LaTeX to save significant debugging time.

---

## 5. Common Silent Failures (No Error, Wrong Output)

### Angle Brackets Showing as Inverted Question Marks

**Symptom:**
```
You write: <HTML>
You see in PDF: ¡HTML¿
```

**Cause**: Default font encoding (OT1) doesn't include `<` and `>`.

**Fix:**
```latex
% Add to preamble:
\usepackage[T1]{fontenc}

% Now < and > work correctly:
\begin{document}
The HTML tag <div> is used for divisions.
\end{document}
```

**Why**: OT1 encoding is optimized for English and lacks many characters. T1 encoding includes full Western character set.

### Missing Bibliography Entries (But No Error)

**Symptom:**
```latex
\cite{Smith2020}  % Shows as [?] in PDF, no error
```

**Cause**: Bibliography entry not in `.bib` file, or BibTeX not run.

**Fix:**

```latex
% 1. Verify entry exists in references.bib:
@article{Smith2020,
  author = {Smith, John},
  title = {Great Paper},
  year = {2020}
}

% 2. Ensure compilation sequence:
pdflatex document.tex    % First pass
bibtex document          % Process bibliography
pdflatex document.tex    # Resolve citations
pdflatex document.tex    # Resolve references

% Or use latexmk:
latexmk -pdf document.tex  # Does everything automatically

% 3. Check .bib file is referenced:
\bibliography{references}  % For BibTeX
% OR
\addbibresource{references.bib}  % For BibLaTeX
```

**Check .blg file** for BibTeX warnings:
```bash
cat document.blg
```

Look for:
```
Warning--I didn't find a database entry for "Smith2020"
```

### Figures Appearing in Wrong Position

**Symptom**: Figure appears on page 5 when you defined it on page 2.

**Cause**: This is intentional! LaTeX floats figures to optimal positions.

**Fix (if you really want to force position):**

```latex
% Option 1: Use [h] to prefer "here"
\begin{figure}[h]
\includegraphics{img.pdf}
\caption{My image}
\end{figure}

% Option 2: Use [H] to force "HERE" (requires float package)
\usepackage{float}
\begin{figure}[H]  % "HERE, not floating"
\includegraphics{img.pdf}
\caption{My image}
\end{figure}

% Option 3: Increase float placement tolerance
\renewcommand{\topfraction}{0.85}  % Allow up to 85% of page for top floats
\renewcommand{\textfraction}{0.1}  % Require only 10% text per page

% Option 4: Use \FloatBarrier to prevent floats crossing points
\usepackage{placeins}
\section{Introduction}
Content with figures...
\FloatBarrier  % Flush all pending floats before next section
\section{Methods}
```

**Best practice**: Let LaTeX position floats, and use `\ref{fig:label}` to refer to them by number, not position.

### Package Silently Overriding Another Package

**Symptom**: You load two packages that define the same command, and one silently wins.

**Example:**
```latex
\usepackage{algorithm}
\usepackage{algorithm2e}  % Redefines 'algorithm' environment
```

**How to detect:**

```bash
# Check log for "redefined" warnings:
grep -i "redefined" document.log
```

**Fix**: Only load compatible packages, or load in correct order:

```latex
% Check documentation for compatibility
% Usually mentioned in package docs

% If both needed, sometimes renaming works:
\usepackage{algorithm2e}
\renewcommand{\algorithm}{algorithmtwo}  % Rename to avoid clash
```

### Font Substitution Warnings

**Symptom**: Log file shows:
```
LaTeX Font Warning: Font shape `OT1/cmr/m/n' in size <142.26378> not available
(Font)              size <24.88> substituted on input line 10.
```

**Cause**: Requesting font size that doesn't exist; LaTeX substitutes closest available size.

**Fix:**

```latex
% For vector fonts (Type1, TrueType), this is usually fine
% But for bitmap fonts, can look pixelated

% Option 1: Use scalable fonts
\usepackage{lmodern}  % Latin Modern (scalable version of Computer Modern)

% Option 2: Use different font package
\usepackage{times}    % Times Roman
\usepackage{helvet}   % Helvetica
\usepackage{mathptmx} % Times with math support

% Option 3: Ignore if output looks fine
% Substitution warnings are usually harmless
```

---

## 6. Package Conflicts & Resolution

### Common Conflicting Pairs

| Package 1 | Package 2 | Issue | Solution |
|-----------|-----------|-------|----------|
| `hyperref` | Most packages | `hyperref` redefines many internals | Load `hyperref` **last** |
| `amsmath` | `empheq` | `empheq` extends `amsmath` | Load `empheq` after `amsmath` |
| `graphicx` | `color` | Both provide color support | Use only `graphicx` (includes color) |
| `algorithm` | `algorithm2e` | Both define `algorithm` environment | Use only one |
| `enumerate` | `enumitem` | Both customize lists | Use only `enumitem` (more powerful) |
| `caption` | Document classes (KOMA, memoir) | Class has own caption style | Load `caption` with `compatibility` option |
| `subfigure` | `subfig` | Both provide subfigures | Use only `subfig` or `subcaption` (newer) |
| `natbib` | `biblatex` | Different bibliography systems | Use only one |

### Load Order Matters

**General rule**: Specific → General → Hyperref

```latex
% GOOD LOAD ORDER:
\documentclass{article}

% 1. Font and encoding
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{lmodern}

% 2. Math packages (order matters)
\usepackage{amsmath}   % First
\usepackage{amssymb}   % After amsmath
\usepackage{amsthm}    % After amsmath

% 3. Graphics
\usepackage{graphicx}
\usepackage{tikz}

% 4. Tables
\usepackage{booktabs}
\usepackage{array}

% 5. Bibliography (if using natbib)
\usepackage{natbib}

% 6. Floats and captions
\usepackage{float}
\usepackage{caption}
\usepackage{subcaption}

% 7. Other packages
\usepackage{algorithm}
\usepackage{listings}

% 8. hyperref (usually LAST)
\usepackage{hyperref}

% 9. Packages that must come after hyperref
\usepackage{cleveref}  % Must be after hyperref
```

**Why hyperref last?**
- `hyperref` redefines many commands to add hyperlink support
- If loaded early, later packages might break hyperlinks
- Exception: `cleveref` and a few others must come **after** hyperref

### Using `\PassOptionsToPackage`

**Problem**: Document class loads package, but you need different options.

**Wrong approach:**
```latex
\documentclass{article}  % Loads graphicx internally
\usepackage[draft]{graphicx}  % ERROR: Option clash
```

**Correct approach:**
```latex
\PassOptionsToPackage{draft}{graphicx}
\documentclass{article}
% Now graphicx is loaded with draft option
```

**How it works**: `\PassOptionsToPackage` must come **before** package is loaded (even by document class).

**Multiple options:**
```latex
\PassOptionsToPackage{pdftex,draft}{graphicx}
\PassOptionsToPackage{colorlinks,linkcolor=blue}{hyperref}
\documentclass{article}
```

### Checking Which Packages Conflict

**Method 1: Read documentation**
- Most package docs list incompatibilities
- Search for "conflicts" or "compatibility"

**Method 2: Load incrementally**
```latex
\documentclass{article}
\usepackage{packageA}
% \usepackage{packageB}  % Comment out
% \usepackage{packageC}
\begin{document}
Test
\end{document}

% Compile. If works, uncomment packageB and recompile.
% Continue until you find the conflicting pair.
```

**Method 3: Check for redefinition warnings**
```bash
grep -i "redefin" document.log
```

**Output:**
```
LaTeX Warning: Command \algorithm already defined.
```

This tells you which packages are fighting over the same command.

### Resolving Option Clashes

**Scenario**: Two packages need same package with different options.

**Example:**
```latex
\usepackage[option1]{foo}
% ...later in preamble, another package does:
% \RequirePackage[option2]{foo}  % Would cause option clash
```

**Solution 1**: Load with both options (if compatible):
```latex
\usepackage[option1,option2]{foo}
```

**Solution 2**: Check if options are compatible:
```latex
% Some options override each other:
\usepackage[draft,final]{foo}  % final wins (loaded last)
```

**Solution 3**: Use `\PassOptionsToPackage`:
```latex
\PassOptionsToPackage{option1,option2}{foo}
\documentclass{article}  % Or wherever foo gets loaded
```

**Solution 4**: Don't load package explicitly if class loads it:
```latex
% Check if document class already loads the package
% If so, use \PassOptionsToPackage BEFORE \documentclass
```

---

## 7. Quick Reference: Error → Solution Table

| Error Message | Likely Cause | Quick Fix |
|---------------|--------------|-----------|
| `Undefined control sequence` | Typo or missing package | Check spelling; add `\usepackage{...}` |
| `Missing $ inserted` | Math command in text mode | Wrap with `$...$` |
| `Missing \begin{document}` | Text before `\begin{document}` | Move content after `\begin{document}` |
| `Environment X undefined` | Missing package for environment | Add `\usepackage{...}` |
| `Extra alignment tab character &` | Too many `&` in table | Match columns: `{ccc}` for 3 columns |
| `Misplaced alignment tab character &` | `&` outside table/align | Use `&` only in tabular/align environments |
| `Missing number, treated as zero` | Incomplete dimension | Add unit: `3cm` not `3` |
| `Illegal unit of measure` | Missing unit | Use `pt`, `cm`, `em`, etc. |
| `Too many }'s` | Unbalanced braces | Count braces; match `{` with `}` |
| `File X not found` | Missing file or wrong path | Check filename, path, extension |
| `\begin{X} ended by \end{Y}` | Mismatched environments | Match begin/end names |
| `Wrong DVI mode driver option` | Wrong hyperref driver | Remove driver option; let hyperref auto-detect |
| `Overfull \hbox` | Text exceeds margin | Use `\url{...}`; scale tables; use `breaklines` |
| `Option clash for package X` | Package loaded twice with different options | Use `\PassOptionsToPackage` |
| `Capacity exceeded` | Infinite loop or huge structure | Check for recursive macros; split large tables |
| `Dimension too large` | Coordinate/value exceeds TeX max | Scale down coordinates; use scientific notation |
| `Runaway argument?` | Missing closing `}` | Find unclosed brace in command |
| `Not in outer par mode` | Float inside float | Use subfigure; don't nest floats |
| `Unknown float option 'H'` | Missing float package | Add `\usepackage{float}` |
| `Unicode character X` | Non-ASCII character | Use XeLaTeX/LuaLaTeX, or replace with LaTeX command |
| `Undefined reference` | Missing label or need recompile | Run pdflatex again; check `\label{...}` |
| `Citation X undefined` | Missing .bib entry or need bibtex | Run bibtex; check .bib file |
| `There were multiply-defined labels` | Duplicate `\label{...}` | Use unique label names |
| `Command X already defined` | Redefining existing command | Use `\renewcommand` instead of `\newcommand` |

---

## 8. Tool-Assisted Debugging

### Using compile_latex.sh Error Output

The `compile_latex.sh` script parses the `.log` file and presents errors in a more readable format:

**Script behavior:**
1. Runs `pdflatex` (or `xelatex`, `lualatex`)
2. Parses `.log` file for lines starting with `!`
3. Extracts line numbers (lines starting with `l.`)
4. Groups errors by type
5. Provides suggestions based on error patterns

**Example output:**
```bash
$ ./compile_latex.sh document.tex

Compiling document.tex...
Error on line 42: Undefined control sequence
  \theorem
Suggestion: Did you mean \begin{theorem}? Or missing package?

Error on line 67: Missing $ inserted
Suggestion: Math command used outside math mode. Wrap with $...$

Compilation failed with 2 errors.
```

### Understanding Its Suggestions

The script recognizes common error patterns and provides hints:

| Error Pattern | Suggestion |
|---------------|------------|
| `Undefined control sequence: \theorem` | Check if you meant `\begin{theorem}` or need `\usepackage{amsthm}` |
| `Missing $ inserted` | Math command used in text mode; wrap with `$...$` |
| `Environment X undefined` | Add `\usepackage{...}` – check documentation for package name |
| `File X.pdf not found` | Check if file exists and path is correct |
| `Option clash` | Use `\PassOptionsToPackage{...}{...}` before `\documentclass` |
| `Package hyperref Error` | Move `\usepackage{hyperref}` to near end of preamble |
| `Overfull \hbox` | Consider using `\usepackage{url}` or scaling content |

**Suggestions are heuristics**, not guaranteed fixes. Always verify the suggestion makes sense for your specific case.

### When to Use `--auto-fix`

Some scripts provide an `--auto-fix` flag that attempts automatic corrections:

```bash
./compile_latex.sh --auto-fix document.tex
```

**What auto-fix might do:**
- Add missing packages to preamble
- Escape underscores `_` to `\_`
- Add missing `$` around detected math commands
- Fix common brace imbalances

**When to use it:**
- For known simple errors (missing packages, unescaped underscores)
- When working with auto-generated LaTeX (from scripts/tools)
- For quick prototyping (then review changes)

**When NOT to use it:**
- On important documents (always review changes)
- For complex structural errors (nested environments, etc.)
- When you don't understand the error (auto-fix might mask the real issue)

**Best practice:**
```bash
# Make backup first
cp document.tex document.tex.backup

# Run auto-fix
./compile_latex.sh --auto-fix document.tex

# Review changes
diff document.tex.backup document.tex

# Compile and test
pdflatex document.tex
```

### Interpreting Error Location

The script shows line numbers, but remember:

**Line number is where LaTeX detected the error, not necessarily where you made the mistake.**

```latex
% Line 10: Missing {
\textbf Text that should be bold}

% Line 30: LaTeX reports error here
\section{Next Section}
! Too many }'s.
l.30 \section{Next Section}
```

**The actual error is on line 10**, but LaTeX doesn't detect it until line 30.

**Debugging tip**: When script reports error on line N, check:
1. Line N itself
2. Lines N-1, N-2, ... (look backwards)
3. For brace/environment errors, search upward for unclosed `{` or `\begin{...}`

### Using lacheck - Syntax Checker

**lacheck** is a simple syntax checker that catches common LaTeX errors before compilation.

**Installation:**
```bash
# Usually included with TeX distributions
# Standalone installation:
apt-get install lacheck         # Debian/Ubuntu
brew install lacheck            # macOS
```

**Basic usage:**
```bash
lacheck document.tex
```

**Example output:**
```
"document.tex", line 15: possible unwanted space at "{"
"document.tex", line 23: double space at " ~"
"document.tex", line 42: missing `\begin{document}'
"document.tex", line 67: `{' expected, found `}'
```

**What lacheck detects:**
- Unmatched braces `{}`
- Misplaced spaces around punctuation
- Common command typos
- Missing `\begin{document}`
- Doubled spaces before tie `~`
- Unescaped special characters

**Limitations:**
- Only checks syntax, not semantics
- Many false positives (especially with complex macros)
- Doesn't understand custom commands
- Can't check package-specific syntax

**Best practices:**
```bash
# Run lacheck before compiling
lacheck document.tex && pdflatex document.tex

# Ignore false positives by piping through grep
lacheck document.tex | grep -v "unwanted space"

# Check all .tex files in project
find . -name "*.tex" -exec lacheck {} \;
```

**Common false positives:**
```latex
% lacheck warns: "possible unwanted space at '{'"
\textbf {text}  % lacheck flags this, but it's harmless

% lacheck warns: "double space at ' ~'"
Word ~\cite{ref}  % This is correct, ignore warning
```

### Using ChkTeX - Comprehensive Linter

**ChkTeX** is a more sophisticated LaTeX linter that provides style and semantic checking.

**Installation:**
```bash
apt-get install chktex         # Debian/Ubuntu
brew install chktex            # macOS
# Or included in TeX Live full installation
```

**Basic usage:**
```bash
chktex document.tex
```

**Example output:**
```
Warning 1 in document.tex line 15: Command terminated with space.
  \LaTeX is great
              ^

Warning 8 in document.tex line 23: Wrong length of dash may have been used.
  pages 1-10
         ^

Warning 13 in document.tex line 34: Interword spacing should perhaps be used.
  e.g.this
      ^

Warning 24 in document.tex line 45: Delete this space to maintain correct pagereferences.
  Figure ~\ref{fig:example}
        ^
```

**ChkTeX warning categories:**

| Warning | Description | Example |
|---------|-------------|---------|
| 1 | Command terminated with space | `\LaTeX is` → `\LaTeX{} is` |
| 2 | Non-breaking space before citation/ref | `ref~\cite{x}` |
| 8 | Wrong dash length | `1-10` → `1--10` (en-dash) |
| 11 | Comment text with actual percent | `% 50%` → `% 50\%` |
| 13 | Interword spacing issue | `e.g.this` → `e.g.\ this` |
| 17 | Number followed by word | `3times` → `3 times` |
| 24 | Space before tilde | `fig ~\ref` → `fig~\ref` |
| 26 | Space before punctuation | `text .` → `text.` |
| 36 | Space before superscript/subscript | `x ^2` → `x^2` |

**Configuration with .chktexrc:**

Create `~/.chktexrc` to customize behavior:

```bash
# Suppress specific warnings globally
CmdLine
{
    -n 1    # Ignore "command terminated with space"
    -n 8    # Ignore "wrong dash length"
}

# Set quiet mode
QuietMode { True }

# Add custom abbreviations (to avoid Warning 13)
Abbrev
{
    etc. fig. vs. e.g. i.e. cf. et al.
}

# User-defined patterns to ignore
UserWarn
{
    # Custom rules can be added here
}

# Verbosity level (0-4)
VerbosityLevel { 2 }
```

**Suppress warnings inline:**

```latex
% chktex-file 1 8
% ^ Suppress warnings 1 and 8 for entire file

\LaTeX is great  % chktex 1
% ^ Suppress warning 1 for this line only

% chktex-begin
\LaTeX is great
Many lines here
% chktex-end
% ^ Suppress all warnings for this block
```

**Advanced usage:**

```bash
# Suppress specific warnings from command line
chktex -n 1 -n 2 document.tex

# Machine-readable output (for IDE integration)
chktex -v0 -q document.tex

# Output format: filename:line:column:error
chktex -v0 -q -f "%f:%l:%c:%n:%k:%m\n" document.tex

# Check all .tex files recursively
find . -name "*.tex" -print0 | xargs -0 chktex

# Show only errors (level 3), suppress warnings
chktex -l3 document.tex

# Detailed statistics
chktex -s document.tex
```

**Integration with editors:**

**VS Code (LaTeX Workshop):**
```json
{
    "latex-workshop.linting.chktex.enabled": true,
    "latex-workshop.linting.chktex.exec.args": [
        "-n", "1", "-n", "8",  // Suppress warnings 1 and 8
        "-wall",
        "-I0",
        "-f%f:%l:%c:%d:%k:%m\n"
    ]
}
```

**Vim (with syntastic or ALE):**
```vim
" In ~/.vimrc
let g:syntastic_tex_checkers = ['chktex']
let g:syntastic_tex_chktex_args = '-n 1 -n 8'
```

**Emacs (with AUCTeX):**
```elisp
;; In ~/.emacs
(setq LaTeX-command-style '(("" "%(PDF)%(latex) -file-line-error %S%(PDFout)")))
(add-hook 'LaTeX-mode-hook 'flycheck-mode)
```

### Combining Tools for Maximum Coverage

**Recommended debugging workflow:**

```bash
#!/bin/bash
# check_latex.sh - Comprehensive LaTeX checking script

TEX_FILE="$1"

echo "=== Step 1: Syntax check with lacheck ==="
lacheck "$TEX_FILE" 2>&1 | grep -v "unwanted space" || true

echo -e "\n=== Step 2: Style check with ChkTeX ==="
chktex -n 1 -n 24 "$TEX_FILE" 2>&1 || true

echo -e "\n=== Step 3: Compilation test ==="
pdflatex -interaction=nonstopmode "$TEX_FILE" > /dev/null

echo -e "\n=== Step 4: Check compilation errors ==="
grep "^!" "${TEX_FILE%.tex}.log" || echo "No errors found"

echo -e "\n=== Step 5: Check warnings ==="
grep -i "warning" "${TEX_FILE%.tex}.log" | head -10 || echo "No warnings found"

echo -e "\n=== Step 6: Check overfull boxes ==="
grep "Overfull" "${TEX_FILE%.tex}.log" || echo "No overfull boxes"

echo -e "\n=== Step 7: Summary ==="
ERROR_COUNT=$(grep -c "^!" "${TEX_FILE%.tex}.log" 2>/dev/null || echo "0")
WARN_COUNT=$(grep -c -i "warning" "${TEX_FILE%.tex}.log" 2>/dev/null || echo "0")
echo "Errors: $ERROR_COUNT | Warnings: $WARN_COUNT"

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "✓ Document compiled successfully!"
    exit 0
else
    echo "✗ Document has compilation errors"
    exit 1
fi
```

**Make it executable and use:**
```bash
chmod +x check_latex.sh
./check_latex.sh document.tex
```

### IDE Integration for Real-Time Debugging

**VS Code with LaTeX Workshop:**

Provides real-time error detection and inline annotations.

**Features:**
- Error highlighting in editor
- Clickable error messages
- Jump-to-error from Problems panel
- Integrated PDF viewer with SyncTeX

**Setup:**
```json
{
    "latex-workshop.latex.autoBuild.run": "onSave",
    "latex-workshop.view.pdf.viewer": "tab",
    "latex-workshop.latex.clean.enabled": true,
    "latex-workshop.linting.chktex.enabled": true
}
```

**Overleaf:**

Cloud-based LaTeX editor with built-in error detection.

**Features:**
- Real-time compilation
- Error panel with file/line context
- Click error to jump to source
- Collaborative debugging
- Version history for reverting mistakes

**TeXstudio:**

Desktop LaTeX IDE with advanced debugging features.

**Features:**
- Integrated error panel
- Syntax highlighting with error detection
- Structure validation
- Brace matching
- Auto-completion reduces errors

**Configure TeXstudio:**
1. Options → Configure TeXstudio
2. Build → Default Compiler → PdfLaTeX
3. Advanced Editor → Enable "Check Spelling" and "Syntax Check"

### Getting More Details

If script's summary isn't enough:

```bash
# View full log file
less document.log

# Search for errors
grep "^!" document.log

# Get error with context
grep -A 5 "^!" document.log

# Check warnings too
grep -i "warning" document.log
```

Most scripts also support verbose mode:
```bash
./compile_latex.sh --verbose document.tex
# Shows full pdflatex output, not just summary
```

---

## Final Tips

1. **Fix errors from top to bottom** – Early errors cascade into fake errors later
2. **Read the first line of the error message** – It usually tells you exactly what's wrong
3. **Check line numbers, but look upward too** – Missing braces detected late
4. **Use an editor with LaTeX support** – Syntax highlighting catches many errors before compilation
5. **Compile frequently** – Easier to find error when you've only changed a few lines
6. **Keep a minimal preamble** – Fewer packages = fewer conflicts
7. **Use latexmk** – Automatically runs multiple passes and bibtex
8. **Search for exact error text** – Stack Exchange has answers for almost every LaTeX error
9. **Create MWEs** – Smallest example that reproduces error helps debugging
10. **Read package documentation** – Most errors come from misusing packages

---

## Resources

- **TeX Stack Exchange**: https://tex.stackexchange.com/
  - Search your exact error message; likely already answered
- **CTAN (Package Documentation)**: https://ctan.org/
  - Official package documentation and examples
- **LaTeX Wikibook**: https://en.wikibooks.org/wiki/LaTeX
  - Comprehensive tutorial and reference
- **The Not So Short Introduction to LaTeX**: Classic beginner guide
  - Search for "lshort.pdf"

**When asking for help**, always provide:
1. Minimal Working Example (MWE)
2. Full error message from .log file
3. LaTeX distribution and version (`pdflatex --version`)
4. Compilation command used

---

**Document Version**: 1.0
**Last Updated**: 2026-02-17
**Word Count**: ~14,500 words (~14.5KB)