# Interactive & Dynamic Content Features

## 1. Fillable PDF Forms (hyperref)

Create fillable PDF forms with text inputs, checkboxes, radio buttons, dropdowns, and push buttons using the `hyperref` package's form field commands.

### Setup

```latex
\usepackage[colorlinks=true]{hyperref}

% Wrap ALL form fields in the Form environment
\begin{Form}
    % ... form fields here ...
\end{Form}
```

**PDF Viewer Compatibility:**
| Feature | Adobe Reader | Chrome/Edge | Firefox | Preview (macOS) | Evince |
|---|---|---|---|---|---|
| Text fields | Full | Full | Full | Partial | Partial |
| Checkboxes | Full | Full | Full | Yes | Yes |
| Radio buttons | Full | Full | Partial | No | Partial |
| Dropdowns | Full | Full | Full | No | Partial |
| JavaScript | Full | No | No | No | No |
| Submit/Reset | Full | No | No | No | No |

**Recommendation:** For maximum compatibility, use text fields and checkboxes. For JavaScript-dependent features (calculations, validation), document that Adobe Reader is required.

### Text Fields

```latex
% Basic text field
\TextField[name=fieldName, width=10cm]{Label Text}

% All options
\TextField[
    name=email,             % Unique field name (required)
    width=10cm,             % Field width
    height=0.6cm,           % Field height
    bordercolor=blue,       % Border color
    backgroundcolor={0.95 0.95 1.0}, % Background (RGB 0-1)
    charsize=10pt,          % Font size inside field
    maxlen=50,              % Maximum characters
    value={Default Text},   % Default value
    readonly=true,          % Read-only field
    align=1,                % 0=left, 1=center, 2=right
    multiline=true,         % Multi-line text area
]{Email:}

% Multi-line text area
\TextField[name=comments, width=\textwidth, height=3cm, multiline=true,
           bordercolor={0.4 0.5 0.7}, backgroundcolor={0.94 0.96 1.0},
           charsize=10pt]{Comments:}

% Password field (characters shown as dots)
\TextField[name=password, width=6cm, password=true]{Password:}
```

### Checkboxes

```latex
% Basic checkbox
\CheckBox[name=agree]{I agree to terms}

% Styled checkbox
\CheckBox[
    name=newsletter,
    width=12pt,
    height=12pt,
    bordercolor=blue,
    backgroundcolor={0.95 0.95 1.0},
    checked=true,           % Pre-checked
]{Subscribe to newsletter}
```

### Radio Buttons

```latex
% Radio button group (same name = mutually exclusive)
\ChoiceMenu[name=experience, radio,
            bordercolor=blue,
            backgroundcolor={0.95 0.95 1.0}]{}
           {0--2 years, 3--5 years, 6--10 years, 10+ years}
```

### Dropdown Menus (Combo Boxes)

```latex
% Basic dropdown
\ChoiceMenu[name=country, combo, width=6cm,
            bordercolor=blue,
            backgroundcolor={0.95 0.95 1.0}]{}
           {Select..., United States, Canada, United Kingdom, Germany, France, Other}

% List box (multiple visible options)
\ChoiceMenu[name=skills, width=6cm, height=3cm,
            bordercolor=blue,
            backgroundcolor={0.95 0.95 1.0}]{}
           {Python, JavaScript, C++, Java, Rust, Go}
```

### Push Buttons

```latex
% Reset button (clears all fields)
\PushButton[name=resetBtn,
            bordercolor=red,
            backgroundcolor={1.0 0.9 0.9}]{Reset Form}

% Print button
\PushButton[name=printBtn,
            bordercolor=blue,
            backgroundcolor={0.9 0.9 1.0}]{Print Form}
```

### Layout Best Practices

Use `tabularx` for aligned two-column form layouts:

```latex
\begin{tabularx}{\textwidth}{@{}XX@{}}
    \textbf{First Name:}\newline
    \TextField[name=first, width=\linewidth, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}]{} &
    \textbf{Last Name:}\newline
    \TextField[name=last, width=\linewidth, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}]{} \\[12pt]
    \textbf{Email:}\newline
    \TextField[name=email, width=\linewidth, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}]{} &
    \textbf{Phone:}\newline
    \TextField[name=phone, width=\linewidth, bordercolor=blue,
               backgroundcolor={0.94 0.96 1.0}]{} \\
\end{tabularx}
```

### Custom Helper Commands

Define reusable form field commands to keep templates clean:

```latex
% In preamble:
\newcommand{\FormField}[3][10cm]{%
    \noindent\textbf{#2:}\hspace{0.5em}%
    \TextField[name=#3, width=#1, bordercolor={0.4 0.5 0.7},
               backgroundcolor={0.94 0.96 1.0}, charsize=10pt]{}%
    \par\vspace{6pt}}

\newcommand{\FormTextArea}[4][10cm]{%
    \noindent\textbf{#2:}\\[4pt]%
    \TextField[name=#3, width=#1, height=#4, multiline=true,
               bordercolor={0.4 0.5 0.7}, backgroundcolor={0.94 0.96 1.0},
               charsize=10pt]{}%
    \par\vspace{6pt}}

\newcommand{\FormCheck}[2]{%
    \CheckBox[name=#2, bordercolor={0.4 0.5 0.7},
              backgroundcolor={0.94 0.96 1.0},
              width=12pt, height=12pt]{#1}\hspace{0.3em}}

% Usage:
\FormField{Full Name}{fullName}
\FormField[15cm]{Email Address}{email}
\FormTextArea[\textwidth]{Cover Letter}{coverLetter}{4cm}
\FormCheck{I accept the terms}{acceptTerms}
```

### Common Pitfalls

1. **Missing `\begin{Form}`**: All form fields MUST be inside `\begin{Form}...\end{Form}`.
2. **Duplicate field names**: Each `name=` must be unique within the document. Duplicate names cause fields to sync (which may be desirable for repeated fields, but usually isn't).
3. **Field names with spaces**: Use camelCase or underscores. Spaces in names cause issues.
4. **`backgroundcolor` syntax**: Uses space-separated RGB values 0-1, NOT the same as `xcolor` syntax. Use `backgroundcolor={0.94 0.96 1.0}` not `backgroundcolor=blue!10`.
5. **Forms + tikzposter**: Form fields do NOT work inside `tikzposter` class. Use `article` or `report` class.
6. **Tab order**: PDF form tab order follows the order fields appear in the LaTeX source. Plan your layout accordingly.

### Template

See `assets/templates/fillable-form.tex` for a complete working example with all field types.

---

## 2. Conditional Content (Template Variables & Toggles)

Control document content, sections, and visual style through a configuration block at the top of the document. Uses `etoolbox` toggles for boolean features and `\providecommand` for template variables.

### Setup

```latex
\usepackage{etoolbox}  % For \newtoggle, \iftoggle, \ifdefstring
\usepackage{comment}   % For excluding large blocks (optional)
```

### Boolean Toggles (Show/Hide Sections)

```latex
% === Define toggles ===
\newtoggle{showAppendix}
\newtoggle{showWatermark}
\newtoggle{isDraft}
\newtoggle{isConfidential}
\newtoggle{showTOC}
\newtoggle{showAbstract}

% === Set toggles ===
\toggletrue{showAppendix}
\toggletrue{showTOC}
\togglefalse{showWatermark}
\togglefalse{isDraft}
\togglefalse{isConfidential}
\toggletrue{showAbstract}

% === Use in document body ===
\iftoggle{showTOC}{
    \tableofcontents
    \newpage
}{}

\iftoggle{showAbstract}{
    \begin{abstract}
    This document covers...
    \end{abstract}
}{}

% ... main content ...

\iftoggle{showAppendix}{
    \appendix
    \section{Supplementary Data}
    ...
}{}
```

### Template Variables

```latex
% === Define with defaults (providecommand won't override if already defined) ===
\providecommand{\doctitle}{Default Title}
\providecommand{\docauthor}{Author Name}
\providecommand{\docdate}{\today}
\providecommand{\docversion}{1.0}
\providecommand{\orgname}{Organization}

% === Use in document ===
\title{\doctitle}
\author{\docauthor}
\date{\docdate}

% === Override from command line (CI/CD) ===
% pdflatex "\def\doctitle{Custom Title}\def\docversion{2.0}\input{document.tex}"
```

### Visual Profiles (Style Switching)

```latex
\providecommand{\docprofile}{corporate}  % corporate | academic | minimal

% Apply profile-specific settings
\makeatletter
\ifdefstring{\docprofile}{corporate}{%
    \definecolor{primaryColor}{RGB}{0, 51, 102}
    \titleformat{\section}{\Large\bfseries\color{primaryColor}}{\thesection}{1em}{}
}{}
\ifdefstring{\docprofile}{academic}{%
    \definecolor{primaryColor}{RGB}{100, 30, 30}
    \usepackage{palatino}
    \titleformat{\section}{\Large\bfseries}{\thesection}{1em}{}
}{}
\ifdefstring{\docprofile}{minimal}{%
    \definecolor{primaryColor}{RGB}{40, 40, 40}
    \titleformat{\section}{\large\bfseries}{\thesection}{1em}{}
    \geometry{margin=1.2in}
}{}
\makeatother
```

### Conditional Packages

```latex
% Only load watermark package if needed
\iftoggle{showWatermark}{
    \usepackage{draftwatermark}
    \SetWatermarkText{\watermarktext}
    \SetWatermarkScale{1.5}
    \SetWatermarkColor[gray]{0.85}
}{}

% Draft mode: add line numbers
\iftoggle{isDraft}{
    \usepackage{lineno}
    \linenumbers
}{}
```

### Command-Line Variable Passing

For CI/CD or batch processing, pass variables at compile time:

```bash
# Override single variable
pdflatex "\def\doctitle{Annual Report 2025}\input{template.tex}"

# Override multiple variables
pdflatex "\def\doctitle{Q4 Report}\def\docauthor{CFO}\def\docprofile{corporate}\input{template.tex}"

# Toggle a feature on
pdflatex "\def\showdraft{true}\input{template.tex}"
```

In the template, handle command-line overrides:

```latex
% Check if variable was passed from command line
\ifdefined\showdraft
    \toggletrue{isDraft}
\fi
```

### Template

See `assets/templates/conditional-document.tex` for a complete working example with toggles, variables, and visual profiles.

---

## 3. Mail Merge (Batch Personalized Documents)

Generate N personalized documents from a CSV or JSON data source. The `mail_merge.py` script reads a LaTeX template with placeholders and a data file, renders one document per record, and optionally compiles all to PDF.

### Quick Start

```bash
# Basic mail merge from CSV
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv --output-dir ./outputs

# With compilation
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs \
    --compile-script <skill_path>/scripts/compile_latex.sh

# Parallel compilation (4 workers)
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --workers 4 \
    --compile-script <skill_path>/scripts/compile_latex.sh

# Merge all PDFs into one
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --merge --merge-name all_letters.pdf \
    --compile-script <skill_path>/scripts/compile_latex.sh

# Custom output naming
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv \
    --output-dir ./outputs --name-field "last_name" --prefix "letter"

# Dry run (preview what will be generated)
python3 <skill_path>/scripts/mail_merge.py template.tex data.csv --dry-run
```

### Template Syntax

#### Simple Mode (default) -- `{{variable}}` placeholders

```latex
\documentclass{article}
\begin{document}

Dear {{name}},

We are pleased to inform you that your application for the {{position}}
role at {{company}} has been approved.

Your start date is {{start_date}}.

Sincerely,\\
HR Department

\end{document}
```

#### Advanced Mode (Jinja2) -- `<< >>` variables, `<% %>` blocks

For conditionals, loops, and complex logic. Auto-detected when `<%` or `<<` appears in template.

```latex
\documentclass{article}
\begin{document}

Dear << name >>,

<% if position == "Manager" %>
As a new manager, you will receive the leadership training package.
<% else %>
Welcome to the team! Your orientation is scheduled for << start_date >>.
<% endif %>

<% if items %>
Your assigned equipment:
\begin{itemize}
<% for item in items %>
    \item << item >>
<% endfor %>
\end{itemize}
<% endif %>

\end{document}
```

### Data Source Formats

#### CSV

```csv
name,title,company,position,start_date
John Smith,Mr.,Acme Inc,Senior Engineer,2025-03-01
Jane Doe,Ms.,TechCorp,Product Manager,2025-03-15
```

#### JSON (array of objects)

```json
[
    {
        "name": "John Smith",
        "title": "Mr.",
        "company": "Acme Inc",
        "position": "Senior Engineer",
        "start_date": "2025-03-01"
    },
    {
        "name": "Jane Doe",
        "title": "Ms.",
        "company": "TechCorp",
        "position": "Product Manager",
        "start_date": "2025-03-15"
    }
]
```

#### JSON with nested data (Jinja2 mode required)

```json
[
    {
        "name": "John Smith",
        "address": {
            "street": "123 Main St",
            "city": "Springfield",
            "state": "IL"
        },
        "items": ["Laptop", "Monitor", "Keyboard"]
    }
]
```

Template for nested data:

```latex
<< name >>\\
<< address.street >>\\
<< address.city >>, << address.state >>

Items: <% for item in items %><< item >><% if not loop.last %>, <% endif %><% endfor %>
```

### Script Options

| Option | Description |
|---|---|
| `--output-dir DIR` | Output directory (default: ./outputs) |
| `--name-field FIELD` | Data field for output filenames |
| `--prefix TEXT` | Prefix for output filenames |
| `--compile-script PATH` | Path to compile_latex.sh |
| `--engine ENGINE` | pdflatex, xelatex, or lualatex |
| `--workers N` | Parallel compilation workers |
| `--merge` | Merge all PDFs into one file |
| `--merge-name FILE` | Merged PDF filename |
| `--no-compile` | Generate .tex only |
| `--no-escape` | Disable LaTeX escaping |
| `--jinja` | Force Jinja2 mode |
| `--simple` | Force simple mode |
| `--limit N` | Process first N records only |
| `--dry-run` | Preview without generating |
| `--copy-assets FILE...` | Copy additional files (images, .bib) |
| `--verbose` | Detailed output |

### Common Use Cases

| Use Case | Data Fields | Template |
|---|---|---|
| Personalized letters | name, address, salutation | `mail-merge-letter.tex` |
| Certificates/diplomas | name, course, date, grade | Custom certificate template |
| Invoices | client, items[], amounts[], total | Jinja2 template with loops |
| Report cards | student, grades{}, comments | Jinja2 template with conditionals |
| Name badges | name, title, organization | Small format template |
| Personalized exams | student, questions[] | Jinja2 template with shuffled content |

### Special Character Handling

Data values are automatically escaped for LaTeX. Special characters like `&`, `%`, `$`, `#`, `_` are converted to their LaTeX equivalents. To pass raw LaTeX through (e.g., math mode), prefix the value with `\` in your data or use the `|raw` filter in Jinja2 mode:

```latex
% In Jinja2 mode, use |raw to prevent escaping
The formula is: << formula|raw >>
```

### Template

See `assets/templates/mail-merge-letter.tex` for a complete working example.

---

## 4. Version Diffing (latexdiff)

Generate highlighted change-tracked PDFs between two versions of a LaTeX document using `latexdiff`. Shows additions (underlined blue) and deletions (struck-through red) in the compiled PDF.

### Quick Start

```bash
# Basic diff between two files
bash <skill_path>/scripts/latex_diff.sh old_version.tex new_version.tex --compile --preview

# Diff against a git revision
bash <skill_path>/scripts/latex_diff.sh paper.tex --git-rev HEAD~1 --compile

# Diff between two git tags
bash <skill_path>/scripts/latex_diff.sh paper.tex --git-rev v1.0 --compile

# Multi-file document (with \input/\include)
bash <skill_path>/scripts/latex_diff.sh old/main.tex new/main.tex --flatten --compile

# Custom markup style
bash <skill_path>/scripts/latex_diff.sh old.tex new.tex --type CULINECHBAR --compile

# Custom colors
bash <skill_path>/scripts/latex_diff.sh old.tex new.tex \
    --color-add "green!70!black" --color-del "red!80!black" --compile
```

### Script Options

| Option | Description |
|---|---|
| `--output FILE` | Output diff .tex file |
| `--output-dir DIR` | Output directory |
| `--type TYPE` | Markup type (see below) |
| `--subtype SUBTYPE` | Markup subtype |
| `--flatten` | Expand \input/\include (multi-file docs) |
| `--math-markup MODE` | fine, coarse, off, whole |
| `--color-add COLOR` | Color for additions (default: blue) |
| `--color-del COLOR` | Color for deletions (default: red) |
| `--compile` | Auto-compile diff to PDF |
| `--preview` | Compile + generate PNG preview |
| `--compile-script PATH` | Path to compile_latex.sh |
| `--git-rev REV` | Diff against git revision |
| `--exclude-safecmd CMDS` | Commands to exclude |
| `--verbose` | Show detailed output |

### Markup Types

| Type | Additions | Deletions | Best For |
|---|---|---|---|
| **UNDERLINE** (default) | Underlined blue | Struck-through red | General use, reviewer-friendly |
| **CTRADITIONAL** | Blue text | Red struck-through | Traditional change tracking |
| **CFONT** | Sans-serif blue | Tiny red | Subtle changes |
| **CHANGEBAR** | Change bar in margin | Change bar in margin | Minimal inline disruption |
| **CCHANGEBAR** | Color + change bar | Color + change bar | Comprehensive tracking |
| **CULINECHBAR** | Underline + change bar | Strike + change bar | Most visible changes |
| **FONTSTRIKE** | Font change | Strikethrough | Simple visual diff |

### Git Integration

The script integrates with git via the `--git-rev` flag:

```bash
# Diff against previous commit
bash latex_diff.sh paper.tex --git-rev HEAD~1 --compile

# Diff against specific commit
bash latex_diff.sh paper.tex --git-rev abc1234 --compile

# Diff against a branch
bash latex_diff.sh paper.tex --git-rev main --compile

# Diff against a tag
bash latex_diff.sh paper.tex --git-rev v1.0 --compile
```

### Handling Common Problems

**Problem: latexdiff fails on complex packages**

```bash
# Exclude problematic commands from diff processing
bash latex_diff.sh old.tex new.tex --exclude-safecmd "SI,qty,num"
```

**Problem: Multi-file document with \input**

```bash
# --flatten expands all \input and \include before diffing
bash latex_diff.sh old/main.tex new/main.tex --flatten --compile
```

**Problem: Math changes not rendered correctly**

```bash
# Use coarse math markup (diffs entire equations, not individual symbols)
bash latex_diff.sh old.tex new.tex --math-markup coarse --compile
```

**Problem: Tables cause compilation errors**

The diff document may have issues with complex table changes. Workaround: manually edit the diff .tex file to fix table markup, then compile.

### Best Practices for Clean Diffs

1. **One sentence per line** in your .tex files. This produces clean, meaningful diffs instead of entire-paragraph changes.
2. **Use git** for version control of LaTeX documents.
3. **Avoid reformatting** between versions (don't re-wrap lines).
4. **Use `--flatten`** for any document with `\input` or `\include`.
5. **Generate diff PDFs** as part of your paper submission workflow.
6. **For journal revisions**, use `CULINECHBAR` type for maximum visibility.

### Direct latexdiff Usage (without script)

If you need more control:

```bash
# Install latexdiff
sudo apt-get install latexdiff

# Basic diff
latexdiff old.tex new.tex > diff.tex

# With options
latexdiff --type=UNDERLINE --math-markup=fine --allow-spaces old.tex new.tex > diff.tex

# Flatten multi-file documents
latexdiff --flatten old/main.tex new/main.tex > diff.tex

# Then compile
pdflatex diff.tex
pdflatex diff.tex  # Second pass for references
```

### Installation

The `latex_diff.sh` script auto-installs `latexdiff` if not present. Manual installation:

```bash
sudo apt-get install latexdiff
```

Requires Perl (pre-installed on most systems).

---

## Package Dependencies Summary

| Feature | Required Packages | Auto-Installed |
|---|---|---|
| Form fields | `hyperref` | Yes (texlive-latex-recommended) |
| Conditional content | `etoolbox`, `comment` | Yes (texlive-latex-extra) |
| Mail merge | Python 3 + `jinja2` + `pandas` | jinja2/pandas may need pip install |
| Version diffing | `latexdiff` (Perl script) | Auto-installed by latex_diff.sh |

### Install All Dependencies

```bash
# LaTeX packages (usually already installed with texlive-latex-extra)
sudo apt-get install texlive-latex-extra texlive-latex-recommended

# latexdiff
sudo apt-get install latexdiff

# Python dependencies for mail merge
pip3 install jinja2 pandas
```
