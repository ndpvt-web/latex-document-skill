# LaTeX Collaboration & CI/CD Workflows Guide

A comprehensive guide to version control, continuous integration, and collaborative workflows for LaTeX projects.

## Table of Contents

1. [Git Best Practices for LaTeX](#1-git-best-practices-for-latex)
2. [GitHub Actions CI/CD](#2-github-actions-cicd)
3. [Docker for LaTeX](#3-docker-for-latex)
4. [Makefile for LaTeX Projects](#4-makefile-for-latex-projects)
5. [Multi-Author Workflows](#5-multi-author-workflows)
6. [Overleaf ↔ Local Git Sync](#6-overleaf--local-git-sync)
7. [Pre-commit Hooks](#7-pre-commit-hooks)
8. [Troubleshooting CI/CD](#8-troubleshooting-cicd)

---

## 1. Git Best Practices for LaTeX

### Repository Setup

Structure your LaTeX project for version control:

```
project/
├── main.tex              # Main document
├── preamble.tex          # Packages and settings
├── chapters/             # Chapter files
│   ├── introduction.tex
│   ├── methodology.tex
│   └── conclusion.tex
├── sections/             # Section files for articles
├── figures/              # Generated images
│   ├── plots/
│   └── diagrams/
├── tables/               # Complex table files
├── bibliography.bib      # References
├── appendices/           # Appendix content
├── .gitignore           # LaTeX-specific ignores
├── .github/
│   └── workflows/       # CI/CD pipelines
├── Makefile             # Build automation
├── latexmkrc            # latexmk configuration
└── README.md            # Build instructions
```

### LaTeX .gitignore

Comprehensive `.gitignore` for LaTeX projects:

```gitignore
# LaTeX auxiliary files
*.aux
*.bbl
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.synctex.gz
*.toc
*.lof
*.lot
*.idx
*.ilg
*.ind
*.nav
*.snm
*.vrb
*.bcf
*.run.xml

# BibTeX files
*.bib.bak
*.bib.sav

# Build tools
*.fls
*.fdb_latexmk
*.synctex(busy)

# Glossaries
*.acn
*.acr
*.alg
*.glg
*.glo
*.gls
*.glsdefs
*.ist

# Hyperref
*.xdy

# Algorithms
*.alg
*.loa

# Theorems
*.thm

# Beamer
*.nav
*.pre
*.snm
*.vrb

# Changes
*.soc

# Generated files
*.pdf
!final/*.pdf
!published/*.pdf

# Editor files
*.swp
*.swo
*~
.DS_Store
.vscode/
.idea/

# OS files
Thumbs.db
```

### Writing for Clean Diffs

**Semantic Line Breaks**: One sentence per line for readable diffs.

```latex
% Bad (hard to review changes)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.

% Good (each sentence on its own line)
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam.
```

**Avoid Reflowing**: Don't reflow entire paragraphs when making small edits.

```latex
% Bad (entire paragraph changed)
- Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod
- tempor incididunt ut labore et dolore magna aliqua.
+ Lorem ipsum dolor sit amet, consectetur adipiscing elit. This is a new
+ sentence. Sed do eiusmod tempor incididunt ut labore et dolore magna
+ aliqua.

% Good (only new content added)
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
+ This is a new sentence.
  Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
```

**Modular Structure**: Use `\input{}` for chapters.

```latex
% main.tex
\documentclass{article}
\input{preamble}
\begin{document}
\input{chapters/introduction}
\input{chapters/methodology}
\input{chapters/results}
\input{chapters/conclusion}
\bibliography{bibliography}
\end{document}
```

**Separate Commits**: Keep .bib and .tex changes separate.

```bash
# Commit bibliography updates separately
git add bibliography.bib
git commit -m "Add references for methodology section"

# Then commit text changes
git add chapters/methodology.tex
git commit -m "Draft methodology section"
```

### Resolving Merge Conflicts

**Common Conflict Patterns**:

1. **Bibliography entries**: Usually safe to keep both versions
2. **\label{} conflicts**: Rename one to avoid duplicates
3. **Paragraph edits**: Use `latexdiff` to visualize changes

**Using latexdiff**:

```bash
# Generate diff between branches
latexdiff \
  <(git show main:main.tex) \
  main.tex \
  > diff.tex

# Compile to see changes
pdflatex diff.tex
```

**Visual Merge Tools**:

```bash
# Configure git to use meld
git config --global merge.tool meld

# Launch merge tool on conflicts
git mergetool
```

**Three-Way Merge Strategy**:

```bash
# For complex conflicts, use three-way merge
git checkout --conflict=diff3 main.tex
# Shows: <<<<<<< ours ||||||| base ======= theirs >>>>>>>
```

---

## 2. GitHub Actions CI/CD

### Basic: Compile on Push

Simple workflow to compile LaTeX on every push:

```yaml
name: Build LaTeX
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: texlive/texlive:latest

    steps:
      - uses: actions/checkout@v4

      - name: Compile LaTeX document
        run: pdflatex -interaction=nonstopmode main.tex

      - name: Upload PDF artifact
        uses: actions/upload-artifact@v4
        with:
          name: document
          path: main.pdf
```

### Advanced: Multi-Pass with Bibliography

Full compilation with bibliography and multiple passes:

```yaml
name: Build LaTeX Document
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: texlive/texlive:latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Compile document (full build)
        run: |
          # First pass
          pdflatex -interaction=nonstopmode main.tex

          # Bibliography (try biber first, fallback to bibtex)
          biber main || bibtex main || true

          # Second and third pass for references
          pdflatex -interaction=nonstopmode main.tex
          pdflatex -interaction=nonstopmode main.tex

      - name: Check for LaTeX errors
        run: |
          if grep -q "^!" main.log; then
            echo "LaTeX errors found:"
            grep "^!" main.log
            exit 1
          fi

      - name: Check for undefined references
        run: |
          if grep -q "LaTeX Warning: Reference" main.log; then
            echo "Warning: Undefined references found"
            grep "LaTeX Warning: Reference" main.log
          fi

      - name: Upload PDF
        uses: actions/upload-artifact@v4
        with:
          name: document-pdf
          path: main.pdf
          retention-days: 30

      - name: Upload logs
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: build-logs
          path: |
            *.log
            *.blg
```

### Using xu-cheng/latex-action

Simplified workflow with specialized action:

```yaml
name: Build LaTeX with latexmk
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Compile LaTeX document
        uses: xu-cheng/latex-action@v3
        with:
          root_file: main.tex
          compiler: latexmk
          args: -pdf -interaction=nonstopmode -halt-on-error

      - name: Upload PDF
        uses: actions/upload-artifact@v4
        with:
          name: PDF
          path: main.pdf
```

### Multiple Documents

Build multiple documents in parallel:

```yaml
name: Build All Documents
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        document: [main, supplementary, presentation]

    container:
      image: texlive/texlive:latest

    steps:
      - uses: actions/checkout@v4

      - name: Compile ${{ matrix.document }}.tex
        run: |
          pdflatex -interaction=nonstopmode ${{ matrix.document }}.tex
          biber ${{ matrix.document }} || bibtex ${{ matrix.document }} || true
          pdflatex -interaction=nonstopmode ${{ matrix.document }}.tex
          pdflatex -interaction=nonstopmode ${{ matrix.document }}.tex

      - name: Upload ${{ matrix.document }}.pdf
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.document }}-pdf
          path: ${{ matrix.document }}.pdf
```

### Auto-Release PDF on Tag

Automatically create a GitHub release with PDF:

```yaml
name: Release PDF
on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    container:
      image: texlive/texlive:latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build document
        run: |
          pdflatex -interaction=nonstopmode main.tex
          biber main || bibtex main || true
          pdflatex -interaction=nonstopmode main.tex
          pdflatex -interaction=nonstopmode main.tex

      - name: Rename PDF with version
        run: |
          VERSION=${GITHUB_REF#refs/tags/}
          mv main.pdf document-${VERSION}.pdf

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          files: document-*.pdf
          body: |
            Automated release of LaTeX document
            Built from commit: ${{ github.sha }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Spell Check Integration

```yaml
name: Spell Check
on: [push, pull_request]

jobs:
  spellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install aspell
        run: sudo apt-get install -y aspell aspell-en

      - name: Check spelling
        run: |
          # Extract text from LaTeX (skip commands)
          for file in *.tex chapters/*.tex; do
            aspell --mode=tex --lang=en list < "$file" | sort -u
          done | tee spelling-errors.txt

      - name: Upload spelling errors
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: spelling-errors
          path: spelling-errors.txt
```

---

## 3. Docker for LaTeX

### Basic Dockerfile

```dockerfile
FROM texlive/texlive:latest

WORKDIR /doc

# Copy project files
COPY . .

# Compile document
RUN pdflatex -interaction=nonstopmode main.tex && \
    biber main || bibtex main || true && \
    pdflatex -interaction=nonstopmode main.tex && \
    pdflatex -interaction=nonstopmode main.tex

# Output will be in /doc/main.pdf
CMD ["cat", "main.pdf"]
```

Build and extract PDF:

```bash
docker build -t my-latex-doc .
docker create --name temp-container my-latex-doc
docker cp temp-container:/doc/main.pdf ./output.pdf
docker rm temp-container
```

### Docker Compose for Development

Interactive LaTeX compilation with live reload:

```yaml
version: '3.8'

services:
  latex:
    image: texlive/texlive:latest
    volumes:
      - .:/doc
    working_dir: /doc
    command: latexmk -pdf -pvc -interaction=nonstopmode main.tex
    stdin_open: true
    tty: true
```

Usage:

```bash
# Start watching for changes
docker-compose up

# Compile once and exit
docker-compose run latex pdflatex -interaction=nonstopmode main.tex
```

### Lightweight Custom Docker Image

Build smaller images with only needed packages:

```dockerfile
FROM ubuntu:22.04

# Install minimal TeX Live
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-bibtex-extra \
    biber \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /doc

ENTRYPOINT ["pdflatex"]
CMD ["-interaction=nonstopmode", "main.tex"]
```

### Multi-Stage Build

Optimize for smaller final image:

```dockerfile
# Build stage
FROM texlive/texlive:latest AS builder

WORKDIR /build
COPY . .

RUN latexmk -pdf -interaction=nonstopmode main.tex

# Final stage
FROM alpine:latest

WORKDIR /output
COPY --from=builder /build/main.pdf .

CMD ["cat", "main.pdf"]
```

---

## 4. Makefile for LaTeX Projects

### Basic Makefile

```makefile
TEX = pdflatex
BIB = biber
MAIN = main

.PHONY: all clean watch

all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex chapters/*.tex bibliography.bib
	$(TEX) -interaction=nonstopmode $(MAIN)
	$(BIB) $(MAIN)
	$(TEX) -interaction=nonstopmode $(MAIN)
	$(TEX) -interaction=nonstopmode $(MAIN)

clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.toc *.lof *.lot \
	      *.fls *.fdb_latexmk *.synctex.gz *.bcf *.run.xml

watch:
	latexmk -pdf -pvc $(MAIN)
```

### Advanced Makefile

```makefile
# Compiler settings
TEX = pdflatex
TEXFLAGS = -interaction=nonstopmode -halt-on-error
BIB = biber
MAIN = main

# Derived filenames
PDF = $(MAIN).pdf
AUX = $(MAIN).aux
BBL = $(MAIN).bbl

# Source files
TEXFILES = $(wildcard *.tex chapters/*.tex sections/*.tex)
BIBFILES = $(wildcard *.bib)
FIGURES = $(wildcard figures/*.pdf figures/*.png)

.PHONY: all clean distclean watch fast continuous spell check

# Default target
all: $(PDF)

# Full build with bibliography
$(PDF): $(TEXFILES) $(BIBFILES) $(FIGURES)
	$(TEX) $(TEXFLAGS) $(MAIN)
	$(BIB) $(MAIN)
	$(TEX) $(TEXFLAGS) $(MAIN)
	$(TEX) $(TEXFLAGS) $(MAIN)

# Fast build (single pass, no bibliography)
fast:
	$(TEX) $(TEXFLAGS) $(MAIN)

# Continuous compilation
watch continuous:
	latexmk -pdf -pvc -interaction=nonstopmode $(MAIN)

# Spell check
spell:
	@for file in $(TEXFILES); do \
		echo "Checking $$file..."; \
		aspell --mode=tex --lang=en check $$file; \
	done

# Syntax check
check:
	@chktex -q -n1 -n2 -n3 $(MAIN).tex

# Clean auxiliary files
clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.toc *.lof *.lot \
	      *.fls *.fdb_latexmk *.synctex.gz *.bcf *.run.xml \
	      *.nav *.snm *.vrb *.idx *.ilg *.ind

# Clean everything including PDF
distclean: clean
	rm -f $(PDF)

# Show word count
wordcount:
	@texcount -inc -sum $(MAIN).tex
```

Usage:

```bash
make          # Full build
make fast     # Quick compile (no bib)
make watch    # Auto-recompile on changes
make clean    # Remove aux files
make spell    # Interactive spell check
```

---

## 5. Multi-Author Workflows

### Branch-per-Section Strategy

Each author works on their own branch:

```bash
# Author 1: Create branch for introduction
git checkout -b feature/introduction
# Edit chapters/introduction.tex
git add chapters/introduction.tex
git commit -m "Draft introduction section"
git push -u origin feature/introduction

# Author 2: Create branch for methodology
git checkout main
git checkout -b feature/methodology
# Edit chapters/methodology.tex
git add chapters/methodology.tex
git commit -m "Add methodology section"
git push -u origin feature/methodology
```

**Pull Request Review Process**:

1. Create PR from feature branch to main
2. CI automatically builds PDF artifact
3. Reviewers download PDF to review changes
4. Use latexdiff to generate comparison document

### Review with latexdiff

Generate visual diff between versions:

```bash
# Compare current version with main branch
git show main:main.tex > main-old.tex
latexdiff main-old.tex main.tex > diff.tex
pdflatex diff.tex

# Compare two commits
latexdiff-vc --git --flatten -r HEAD~5 main.tex
pdflatex main-diff*.tex
```

**Automated latexdiff in CI**:

```yaml
- name: Generate diff PDF
  if: github.event_name == 'pull_request'
  run: |
    git fetch origin ${{ github.base_ref }}
    git show origin/${{ github.base_ref }}:main.tex > old.tex
    latexdiff old.tex main.tex > diff.tex
    pdflatex diff.tex

- name: Upload diff PDF
  uses: actions/upload-artifact@v4
  with:
    name: changes-highlighted
    path: diff.pdf
```

### Comment Systems

**Using todonotes package**:

```latex
\usepackage{todonotes}

% In document
This is some text. \todo{Expand this section}
\todo[inline]{This paragraph needs references}
\todo[author=Alice]{Check this claim}
```

**Custom reviewer commands**:

```latex
% In preamble
\usepackage{xcolor}
\newcommand{\alice}[1]{\textcolor{blue}{[Alice: #1]}}
\newcommand{\bob}[1]{\textcolor{red}{[Bob: #1]}}

% In document
This result is significant. \alice{Add p-value here}
The methodology follows \bob{Which paper?} standard practice.
```

**Margin notes**:

```latex
This is the main text.
\marginpar{\footnotesize Reviewer: needs citation}
```

### Collaborative Editing Workflow

**Gitflow for papers**:

```
main (accepted versions)
  ├── develop (integration branch)
  │   ├── feature/intro (Author 1)
  │   ├── feature/methods (Author 2)
  │   └── feature/results (Author 3)
  └── hotfix/typos (Quick fixes)
```

**Daily sync routine**:

```bash
# Start of day: get latest changes
git checkout develop
git pull origin develop

# Create/switch to your feature branch
git checkout feature/my-section
git merge develop  # Integrate others' changes

# End of day: push your work
git add chapters/my-section.tex
git commit -m "Progress on my section"
git push origin feature/my-section
```

---

## 6. Overleaf ↔ Local Git Sync

### Initial Setup

Clone Overleaf project to local machine:

```bash
# Get your Overleaf project Git URL from Project menu → Git
git clone https://git.overleaf.com/PROJECT_ID local-copy
cd local-copy

# Set up dual remotes
git remote rename origin overleaf
git remote add github git@github.com:username/repo.git

# Verify remotes
git remote -v
# overleaf    https://git.overleaf.com/PROJECT_ID (fetch)
# overleaf    https://git.overleaf.com/PROJECT_ID (push)
# github      git@github.com:username/repo.git (fetch)
# github      git@github.com:username/repo.git (push)
```

### Sync Workflow

**Option 1: Overleaf as primary**

```bash
# Pull latest from Overleaf
git pull overleaf main

# Backup to GitHub
git push github main
```

**Option 2: GitHub as primary**

```bash
# Pull from GitHub
git pull github main

# Push to Overleaf
git push overleaf main
```

**Option 3: Bidirectional sync**

```bash
# Fetch all changes
git fetch overleaf
git fetch github

# Merge and push to both
git merge overleaf/main
git merge github/main

git push overleaf main
git push github main
```

### Automated Sync Script

```bash
#!/bin/bash
# sync-overleaf.sh

set -e

echo "Syncing Overleaf project..."

# Pull from Overleaf
echo "Pulling from Overleaf..."
git pull overleaf main

# Push to GitHub
echo "Pushing to GitHub..."
git push github main

echo "Sync complete!"
```

### Handling Conflicts

Overleaf commits are often automatic and may conflict:

```bash
# If push to Overleaf fails
git pull overleaf main --rebase

# If conflicts occur, resolve and continue
git add .
git rebase --continue

git push overleaf main
```

### Best Practices

1. **Never force push to Overleaf** - you may lose collaborators' work
2. **Commit frequently locally** - Overleaf auto-commits can be messy
3. **Use feature branches locally** - merge to main only when stable
4. **Communicate with team** - coordinate who pushes to Overleaf

---

## 7. Pre-commit Hooks

### Installation

```bash
# Install pre-commit framework
pip install pre-commit

# Create .pre-commit-config.yaml (see below)

# Install hooks
pre-commit install
```

### Configuration File

`.pre-commit-config.yaml`:

```yaml
repos:
  # Local hooks (custom scripts)
  - repo: local
    hooks:
      - id: latex-lint
        name: LaTeX Lint (chktex)
        entry: chktex -q -n1 -n2 -n3 -n6
        language: system
        files: '\.tex$'

      - id: check-compile
        name: Check LaTeX Compiles
        entry: pdflatex -interaction=nonstopmode -halt-on-error
        language: system
        files: 'main\.tex$'
        pass_filenames: false

      - id: trailing-whitespace
        name: Trim Trailing Whitespace
        entry: sed -i 's/[[:space:]]*$//'
        language: system
        files: '\.tex$'

  # Standard pre-commit hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-yaml
      - id: check-added-large-files
        args: ['--maxkb=1000']
      - id: end-of-file-fixer
        files: '\.tex$'
      - id: mixed-line-ending
        args: ['--fix=lf']
```

### Custom Hook Scripts

**scripts/latex-check.sh**:

```bash
#!/bin/bash
# Check LaTeX files before commit

set -e

echo "Running LaTeX checks..."

# Check for common issues
for file in "$@"; do
    if [[ "$file" == *.tex ]]; then
        # Check for \label without \ref
        if grep -q '\\label{' "$file"; then
            label=$(grep -o '\\label{[^}]*}' "$file" | sed 's/\\label{\([^}]*\)}/\1/')
            if ! grep -q "\\ref{$label}" *.tex chapters/*.tex 2>/dev/null; then
                echo "Warning: Unused label in $file: $label"
            fi
        fi

        # Check for TODO comments
        if grep -qi 'TODO\|FIXME\|XXX' "$file"; then
            echo "Warning: TODO comments found in $file"
            grep -n 'TODO\|FIXME\|XXX' "$file"
        fi
    fi
done

echo "LaTeX checks passed!"
```

Make executable and add to pre-commit:

```bash
chmod +x scripts/latex-check.sh
```

```yaml
- id: latex-custom-checks
  name: Custom LaTeX Checks
  entry: scripts/latex-check.sh
  language: script
  files: '\.tex$'
```

### Skip Hooks When Needed

```bash
# Skip all hooks for this commit
git commit --no-verify -m "WIP: draft section"

# Run hooks manually
pre-commit run --all-files
```

---

## 8. Troubleshooting CI/CD

### Common CI Failures

**Problem**: Missing LaTeX packages

```
! LaTeX Error: File `package.sty' not found.
```

**Solution**: Install package in workflow

```yaml
- name: Install additional packages
  run: tlmgr install package-name
```

Or use full TeX Live image: `texlive/texlive:latest`

**Problem**: Bibliography not found

```
LaTeX Warning: Citation 'key' on page 1 undefined
```

**Solution**: Ensure bibliography files are committed

```bash
git add bibliography.bib
git commit -m "Add bibliography"
```

**Problem**: Compilation timeout

**Solution**: Increase timeout and use faster compiler

```yaml
- name: Compile document
  timeout-minutes: 10
  run: pdflatex -interaction=batchmode main.tex
```

### Debugging Workflows

**Enable debug logging**:

```yaml
- name: Debug information
  run: |
    echo "Working directory:"
    pwd
    echo "Files present:"
    ls -la
    echo "TeX distribution:"
    pdflatex --version
```

**Upload logs on failure**:

```yaml
- name: Upload logs on failure
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: error-logs
    path: |
      *.log
      *.blg
      *.aux
```

### Performance Optimization

**Cache TeX Live installation**:

```yaml
- name: Cache TeX Live
  uses: actions/cache@v4
  with:
    path: /usr/local/texlive
    key: texlive-${{ runner.os }}-${{ hashFiles('**/*.tex') }}
```

**Conditional compilation** (only compile if .tex files changed):

```yaml
on:
  push:
    paths:
      - '**.tex'
      - '**.bib'
      - '.github/workflows/**'
```

---

## Conclusion

This guide covers the essential workflows for collaborative LaTeX development with modern CI/CD practices. Key takeaways:

- **Version control**: Use semantic line breaks and modular structure
- **Automation**: Set up GitHub Actions for every push
- **Collaboration**: Use branches, PRs, and latexdiff for reviews
- **Reliability**: Pre-commit hooks catch issues before CI

With these workflows, your LaTeX projects will be as maintainable as modern software projects.
