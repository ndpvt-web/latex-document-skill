# Beamer Presentations Guide

A comprehensive guide to creating professional presentations with LaTeX Beamer, covering themes, layouts, animations, code inclusion, and advanced features.

## Table of Contents

1. [Beamer Basics](#1-beamer-basics)
2. [Modern Themes](#2-modern-themes)
3. [Slide Layouts](#3-slide-layouts)
4. [Animations & Overlays](#4-animations--overlays)
5. [Blocks & Environments](#5-blocks--environments)
6. [Including Code](#6-including-code)
7. [Charts and Diagrams](#7-charts-and-diagrams-in-beamer)
8. [Handout Generation](#8-handout-generation)
9. [Presenter Notes](#9-presenter-notes)
10. [Beamer + Bibliography](#10-beamer--bibliography)
11. [Advanced Tips](#11-advanced-tips)
12. [Complete Example Presentation](#12-complete-example-presentation)
13. [Common Pitfalls](#13-common-pitfalls)

---

## 1. Beamer Basics

### Document Class Options

Beamer presentations start with the `beamer` document class. Modern presentations typically use widescreen aspect ratios:

```latex
% 16:9 widescreen (modern, recommended)
\documentclass[aspectratio=169]{beamer}

% 16:10 widescreen
\documentclass[aspectratio=1610]{beamer}

% 4:3 traditional (legacy)
\documentclass{beamer}
```

Other useful document class options:
- `t` - Top-align content in frames (default is centered)
- `handout` - Remove overlays for printing
- `12pt`, `11pt`, `10pt` - Font sizes (default is 11pt)

### Frame Anatomy

The basic building block of a Beamer presentation is the **frame**:

```latex
\begin{frame}{Frame Title}
  Content goes here
\end{frame}

% Frame with subtitle
\begin{frame}{Main Title}{Subtitle}
  Content
\end{frame}

% Frame without title
\begin{frame}
  Content
\end{frame}
```

### Title Slide

Define metadata in the preamble and generate the title slide with `\maketitle`:

```latex
\title{My Presentation Title}
\subtitle{Optional Subtitle}
\author{Author Name}
\institute{University or Institution}
\date{\today}  % or specific date

\begin{document}
\begin{frame}
  \titlepage
\end{frame}
% or simply:
\frame{\titlepage}
\end{document}
```

### Frame Options

Frames can have various options specified in square brackets:

```latex
% [fragile] - Required for verbatim content (code, lstlisting, minted)
\begin{frame}[fragile]{Code Example}
  \begin{verbatim}
    Code here
  \end{verbatim}
\end{frame}

% [plain] - Full-bleed slide with no header/footer
\begin{frame}[plain]
  Full screen content
\end{frame}

% [noframenumbering] - Don't count this slide in numbering
\begin{frame}[noframenumbering]{Backup Slide}
  Not counted in total
\end{frame}

% [allowframebreaks] - Auto-split long content across multiple slides
\begin{frame}[allowframebreaks]{Bibliography}
  \bibliography{refs}
\end{frame}

% [shrink=20] - Shrink content by percentage
\begin{frame}[shrink=20]{Lots of Content}
  Content will be scaled down
\end{frame}

% [t] - Top-align content (center is default)
\begin{frame}[t]{Top Aligned}
  Content
\end{frame}
```

### Basic Preamble Example

```latex
\documentclass[aspectratio=169]{beamer}

\usetheme{Madrid}
\usecolortheme{whale}

\title{Introduction to Beamer}
\author{John Doe}
\institute{University of Example}
\date{\today}

\begin{document}

\begin{frame}
  \titlepage
\end{frame}

\begin{frame}{Outline}
  \tableofcontents
\end{frame}

\section{First Section}
\begin{frame}{First Slide}
  Content
\end{frame}

\end{document}
```

---

## 2. Modern Themes

### Built-in Themes (with recommendations)

Beamer comes with numerous built-in themes. Here are the most commonly used:

| Theme | Look | Best For | Navigation | Notes |
|-------|------|----------|------------|-------|
| `default` | Minimal, clean white | Quick presentations, minimalist style | None | Very basic |
| `Madrid` | Blue header, rounded boxes | Business, formal lectures | Minimal top nav | Professional, polished |
| `Boadilla` | Compact sidebar | Academic seminars | Sidebar | Space-efficient |
| `CambridgeUS` | Red/navy theme | Formal presentations | Tree navigation | Traditional academic |
| `Singapore` | Clean, modern minimal | Tech, data science | Minimal | Very clean |
| `Copenhagen` | Blue with sidebar | Structured talks | Sidebar tree | Good for long talks |
| `Berlin` | Blue with top navigation | Conference talks | Top tree nav | Clear structure |
| `Frankfurt` | Minimalist with top nav | Technical presentations | Top nav | Clean but structured |

#### Applying Themes

```latex
\documentclass[aspectratio=169]{beamer}
\usetheme{Madrid}
```

### Modern External Theme: Metropolis

**Metropolis** is a modern, flat design theme inspired by Material Design. It's clean, professional, and popular in tech talks.

#### Installing Metropolis

```bash
# Using TeX Live Manager
tlmgr install beamertheme-metropolis

# Or download from CTAN and install manually
# https://www.ctan.org/pkg/beamertheme-metropolis
```

#### Using Metropolis

```latex
\documentclass[aspectratio=169]{beamer}
\usetheme{metropolis}

% Optional: use package options
\usetheme[progressbar=frametitle]{metropolis}

% Metropolis works best with these fonts
\usepackage[T1]{fontenc}
\usepackage{FiraSans}
\usepackage{FiraMono}
```

Metropolis options:
- `progressbar=none|head|frametitle|foot` - Progress bar location
- `block=transparent|fill` - Block style
- `background=dark|light` - Background color

### Custom Color Schemes

Beamer allows extensive color customization using color themes and manual definitions:

```latex
% Built-in color themes
\usecolortheme{whale}     % dark blue
\usecolortheme{orchid}    % purple
\usecolortheme{dove}      % gray
\usecolortheme{seahorse}  % light colors
\usecolortheme{beetle}    % gray and blue

% Custom colors
\definecolor{myprimary}{RGB}{0,102,153}
\definecolor{myaccent}{RGB}{204,51,0}

% Set specific elements
\setbeamercolor{palette primary}{bg=myprimary,fg=white}
\setbeamercolor{palette secondary}{bg=myaccent,fg=white}
\setbeamercolor{title}{fg=myprimary}
\setbeamercolor{frametitle}{bg=myprimary,fg=white}
\setbeamercolor{block title}{bg=myprimary,fg=white}
\setbeamercolor{block body}{bg=myprimary!10,fg=black}
\setbeamercolor{itemize item}{fg=myprimary}
\setbeamercolor{enumerate item}{fg=myprimary}
```

### Complete Custom Theme Example

```latex
\documentclass[aspectratio=169]{beamer}

% Base theme
\usetheme{Madrid}
\usecolortheme{default}

% Custom colors
\definecolor{darkblue}{RGB}{0,51,102}
\definecolor{lightblue}{RGB}{51,153,204}
\definecolor{orange}{RGB}{255,102,0}

% Apply colors
\setbeamercolor{palette primary}{bg=darkblue,fg=white}
\setbeamercolor{palette secondary}{bg=lightblue,fg=white}
\setbeamercolor{palette tertiary}{bg=orange,fg=white}
\setbeamercolor{frametitle}{bg=darkblue,fg=white}
\setbeamercolor{title}{fg=darkblue}
\setbeamercolor{block title}{bg=darkblue,fg=white}
\setbeamercolor{block body}{bg=darkblue!5,fg=black}

% Custom fonts
\setbeamerfont{title}{size=\Large,series=\bfseries}
\setbeamerfont{frametitle}{size=\large,series=\bfseries}

% Remove navigation symbols
\setbeamertemplate{navigation symbols}{}

% Custom footline with slide numbers
\setbeamertemplate{footline}{
  \hbox{%
  \begin{beamercolorbox}[wd=.5\paperwidth,ht=2.5ex,dp=1ex,left]{author in head/foot}%
    \hspace*{2ex}\insertshortauthor
  \end{beamercolorbox}%
  \begin{beamercolorbox}[wd=.5\paperwidth,ht=2.5ex,dp=1ex,right]{title in head/foot}%
    \insertshorttitle\hspace*{2ex}
    \insertframenumber{} / \inserttotalframenumber\hspace*{2ex}
  \end{beamercolorbox}}%
}
```

---

## 3. Slide Layouts

### Two-Column Layout

The most common advanced layout splits content into columns:

```latex
\begin{frame}{Two Column Layout}
\begin{columns}

\begin{column}{0.5\textwidth}
  \textbf{Left Column}
  \begin{itemize}
    \item Point 1
    \item Point 2
    \item Point 3
  \end{itemize}
\end{column}

\begin{column}{0.5\textwidth}
  \textbf{Right Column}
  \begin{itemize}
    \item Point A
    \item Point B
    \item Point C
  \end{itemize}
\end{column}

\end{columns}
\end{frame}
```

#### Asymmetric Columns

```latex
\begin{frame}{70-30 Split}
\begin{columns}

\begin{column}{0.7\textwidth}
  Main content goes here with more space
\end{column}

\begin{column}{0.3\textwidth}
  \includegraphics[width=\textwidth]{figure.png}
\end{column}

\end{columns}
\end{frame}
```

#### Three Columns

```latex
\begin{frame}{Three Columns}
\begin{columns}

\begin{column}{0.33\textwidth}
  Column 1
\end{column}

\begin{column}{0.33\textwidth}
  Column 2
\end{column}

\begin{column}{0.33\textwidth}
  Column 3
\end{column}

\end{columns}
\end{frame}
```

### Image Slides

#### Full-Width Image

```latex
\begin{frame}{Research Results}
  \begin{center}
    \includegraphics[width=0.8\textwidth]{results.png}
  \end{center}
\end{frame}
```

#### Image with Caption

```latex
\begin{frame}{Experimental Setup}
  \begin{figure}
    \centering
    \includegraphics[width=0.7\textwidth]{setup.jpg}
    \caption{Laboratory equipment configuration}
  \end{figure}
\end{frame}
```

#### Image and Text Side-by-Side

```latex
\begin{frame}{Image with Description}
\begin{columns}

\begin{column}{0.5\textwidth}
  \includegraphics[width=\textwidth]{diagram.png}
\end{column}

\begin{column}{0.5\textwidth}
  \textbf{Key Features:}
  \begin{itemize}
    \item Feature A
    \item Feature B
    \item Feature C
  \end{itemize}

  This diagram shows the relationship between components.
\end{column}

\end{columns}
\end{frame}
```

#### Multiple Images in Grid

```latex
\begin{frame}{Comparison}
  \begin{columns}
    \begin{column}{0.5\textwidth}
      \centering
      \includegraphics[width=0.9\textwidth]{before.png}\\
      \textbf{Before}
    \end{column}
    \begin{column}{0.5\textwidth}
      \centering
      \includegraphics[width=0.9\textwidth]{after.png}\\
      \textbf{After}
    \end{column}
  \end{columns}

  \vspace{1em}

  \begin{columns}
    \begin{column}{0.5\textwidth}
      \centering
      \includegraphics[width=0.9\textwidth]{method1.png}\\
      \textbf{Method 1}
    \end{column}
    \begin{column}{0.5\textwidth}
      \centering
      \includegraphics[width=0.9\textwidth]{method2.png}\\
      \textbf{Method 2}
    \end{column}
  \end{columns}
\end{frame}
```

### Code Slides (with minted or listings)

Code examples are covered in detail in Section 6, but here's a basic layout:

```latex
\begin{frame}[fragile]{Code Example}
\begin{lstlisting}[language=Python]
def calculate_sum(numbers):
    total = 0
    for num in numbers:
        total += num
    return total
\end{lstlisting}
\end{frame}
```

### Table Slides

#### Simple Table

```latex
\begin{frame}{Results Summary}
  \begin{center}
  \begin{tabular}{lcc}
    \toprule
    Method & Accuracy & Speed \\
    \midrule
    Algorithm A & 92\% & Fast \\
    Algorithm B & 95\% & Medium \\
    Algorithm C & 89\% & Slow \\
    \bottomrule
  \end{tabular}
  \end{center}
\end{frame}
```

#### Table with Text

```latex
\begin{frame}{Performance Metrics}
  \textbf{Experimental Results:}

  \vspace{1em}

  \begin{center}
  \begin{tabular}{lccc}
    \toprule
    \textbf{Dataset} & \textbf{Precision} & \textbf{Recall} & \textbf{F1-Score} \\
    \midrule
    Training   & 0.94 & 0.91 & 0.92 \\
    Validation & 0.92 & 0.89 & 0.90 \\
    Test       & 0.91 & 0.88 & 0.89 \\
    \bottomrule
  \end{tabular}
  \end{center}

  \vspace{1em}

  All metrics computed on 10,000 samples.
\end{frame}
```

#### Resizing Large Tables

```latex
\begin{frame}{Large Dataset}
  \resizebox{\textwidth}{!}{
    \begin{tabular}{lccccc}
      \toprule
      Model & Param1 & Param2 & Param3 & Accuracy & Time \\
      \midrule
      Model A & 0.1 & 0.2 & 0.3 & 87\% & 5s \\
      Model B & 0.2 & 0.3 & 0.4 & 89\% & 8s \\
      Model C & 0.3 & 0.4 & 0.5 & 91\% & 12s \\
      \bottomrule
    \end{tabular}
  }
\end{frame}
```

### Math Slides

#### Centered Equation

```latex
\begin{frame}{Pythagorean Theorem}
  The fundamental relationship in Euclidean geometry:

  \begin{equation}
    a^2 + b^2 = c^2
  \end{equation}

  where $c$ is the hypotenuse and $a, b$ are the other sides.
\end{frame}
```

#### Multiple Equations

```latex
\begin{frame}{Maxwell's Equations}
  \begin{align}
    \nabla \cdot \mathbf{E} &= \frac{\rho}{\epsilon_0} \\
    \nabla \cdot \mathbf{B} &= 0 \\
    \nabla \times \mathbf{E} &= -\frac{\partial \mathbf{B}}{\partial t} \\
    \nabla \times \mathbf{B} &= \mu_0\mathbf{J} + \mu_0\epsilon_0\frac{\partial \mathbf{E}}{\partial t}
  \end{align}
\end{frame}
```

#### Math and Text Side-by-Side

```latex
\begin{frame}{Derivation}
\begin{columns}

\begin{column}{0.5\textwidth}
  \textbf{Starting from:}
  \begin{equation*}
    F = ma
  \end{equation*}

  \textbf{We derive:}
  \begin{equation*}
    E = \frac{1}{2}mv^2
  \end{equation*}
\end{column}

\begin{column}{0.5\textwidth}
  \begin{itemize}
    \item Force equals mass times acceleration
    \item Integrate over distance
    \item Apply work-energy theorem
    \item Result: kinetic energy formula
  \end{itemize}
\end{column}

\end{columns}
\end{frame}
```

### Quote Slides

```latex
\begin{frame}[plain]
  \vfill
  \begin{center}
    \Large
    \textit{"The best way to predict the future is to invent it."}

    \vspace{1em}

    \normalsize
    --- Alan Kay
  \end{center}
  \vfill
\end{frame}
```

Or with a quote block:

```latex
\begin{frame}{Motivation}
  \begin{quote}
    In theory, theory and practice are the same. In practice, they are not.
  \end{quote}
  \hfill --- Albert Einstein (attributed)

  \vspace{1em}

  This observation motivates our empirical approach.
\end{frame}
```

---

## 4. Animations & Overlays

Beamer's overlay system creates animated reveals within a single frame.

### Basic Pause

The simplest animation uses `\pause`:

```latex
\begin{frame}{Sequential Reveal}
  First item appears immediately.

  \pause

  Second item appears on click.

  \pause

  Third item appears on another click.
\end{frame}
```

### Overlay Specifications

Overlays are controlled with angle bracket specifications:

```latex
\begin{frame}{Overlay Specifications}
  \onslide<1->{Always visible from slide 1 onward}

  \onslide<2->{Visible from slide 2 onward}

  \onslide<3->{Visible from slide 3 onward}

  \onslide<2-3>{Only visible on slides 2 and 3}

  \onslide<1,3>{Visible on slides 1 and 3 only}
\end{frame}
```

### Only vs. Onslide

- `\onslide` reserves space even when hidden
- `\only` doesn't reserve space (content shifts)

```latex
\begin{frame}{Only vs Onslide}
  \textbf{Using onslide (space reserved):}

  \onslide<1>{This is slide 1}
  \onslide<2>{This is slide 2}

  Text below doesn't move.

  \vspace{2em}

  \textbf{Using only (no space):}

  \only<1>{This is slide 1}
  \only<2>{This is slide 2}

  Text below moves!
\end{frame}
```

### Alert and Highlighting

Highlight specific content on certain slides:

```latex
\begin{frame}{Emphasis}
  Consider these three factors:

  \begin{itemize}
    \item \alert<2>{Speed} - highlighted on slide 2
    \item \alert<3>{Accuracy} - highlighted on slide 3
    \item \alert<4>{Cost} - highlighted on slide 4
  \end{itemize}

  \only<2>{Speed is critical for real-time applications.}
  \only<3>{Accuracy determines reliability.}
  \only<4>{Cost affects scalability.}
\end{frame}
```

### Itemize with Overlays

Reveal list items one at a time:

```latex
\begin{frame}{Incremental Lists}
  \begin{itemize}[<+->]
    \item First item
    \item Second item
    \item Third item
    \item Fourth item
  \end{itemize}
\end{frame}
```

Or with specific timing:

```latex
\begin{frame}{Custom Timing}
  \begin{itemize}
    \item<1-> Always visible
    \item<2-> Appears second
    \item<3-> Appears third
    \item<2-> Also appears second
  \end{itemize}
\end{frame}
```

### Enumerate with Overlays

```latex
\begin{frame}{Steps}
  Follow these steps:

  \begin{enumerate}[<+->]
    \item Initialize the system
    \item Load the data
    \item Process the input
    \item Generate output
    \item Validate results
  \end{enumerate}
\end{frame}
```

### Complex Overlay Examples

#### Progressive Disclosure

```latex
\begin{frame}{Building an Argument}
  \textbf{Hypothesis:} Algorithm X is faster than Algorithm Y.

  \pause

  \textbf{Evidence:}
  \begin{itemize}[<+->]
    \item Theoretical complexity: $O(n \log n)$ vs $O(n^2)$
    \item Benchmark results: 2.3s vs 15.7s
    \item Scalability tests confirm hypothesis
  \end{itemize}

  \pause

  \textbf{Conclusion:} Algorithm X should be preferred for large datasets.
\end{frame}
```

#### Replace Content

```latex
\begin{frame}{Transformation}
  \textbf{Original Problem:}
  \begin{equation*}
    \only<1>{\int_0^1 x^2 \, dx}
    \only<2->{\int_0^1 x^2 \, dx = \left[\frac{x^3}{3}\right]_0^1}
    \only<3->{= \frac{1}{3}}
  \end{equation*}

  \only<1>{How do we solve this?}
  \only<2>{Apply the power rule...}
  \only<3>{Final answer!}
\end{frame}
```

### Animate Value (Advanced)

For smooth transitions, use `\animatevalue`:

```latex
\begin{frame}{Animation}
  \animatevalue<1-20>{\x}{0}{100}

  Progress: \x\%

  \begin{tikzpicture}
    \fill[blue] (0,0) rectangle (\x/20,1);
    \draw (0,0) rectangle (5,1);
  \end{tikzpicture}
\end{frame}
```

---

## 5. Blocks & Environments

Beamer provides special block environments for organizing content.

### Standard Blocks

```latex
\begin{frame}{Block Examples}

  \begin{block}{Normal Block}
    This is a standard block with neutral colors.
  \end{block}

  \begin{alertblock}{Warning}
    Important information that needs attention!
  \end{alertblock}

  \begin{exampleblock}{Example}
    This is an example or demonstration.
  \end{exampleblock}

\end{frame}
```

### Theorem Environments

Beamer includes predefined theorem-like environments:

```latex
\begin{frame}{Mathematical Results}

  \begin{theorem}[Pythagorean Theorem]
    In a right triangle, $a^2 + b^2 = c^2$.
  \end{theorem}

  \begin{proof}
    Consider a square with side length $a+b$...
  \end{proof}

\end{frame}
```

### All Theorem Environments

```latex
\begin{frame}{Theorem-like Environments}

  \begin{theorem}
    A general theorem.
  \end{theorem}

  \begin{lemma}
    A helper result.
  \end{lemma}

  \begin{corollary}
    An immediate consequence.
  \end{corollary}

  \begin{proposition}
    A claimed result.
  \end{proposition}

  \begin{definition}
    A formal definition.
  \end{definition}

  \begin{example}
    An illustrative example.
  \end{example}

\end{frame}
```

### Customizing Theorem Names

```latex
\begin{frame}{Custom Names}

  \begin{theorem}[Fermat's Last Theorem]
    No three positive integers $a$, $b$, and $c$ satisfy
    $a^n + b^n = c^n$ for any integer value of $n > 2$.
  \end{theorem}

  \begin{definition}[Prime Number]
    A natural number greater than 1 that has no positive divisors
    other than 1 and itself.
  \end{definition}

\end{frame}
```

### Blocks with Overlays

```latex
\begin{frame}{Progressive Blocks}

  \begin{block}{Step 1}<1->
    First, we collect the data.
  \end{block}

  \begin{block}{Step 2}<2->
    Then, we process the data.
  \end{block}

  \begin{block}{Step 3}<3->
    Finally, we analyze the results.
  \end{block}

\end{frame}
```

### Customizing Block Colors

```latex
% In preamble:
\setbeamercolor{block title}{bg=blue!20,fg=black}
\setbeamercolor{block body}{bg=blue!5,fg=black}

\setbeamercolor{block title alerted}{bg=red!50,fg=white}
\setbeamercolor{block body alerted}{bg=red!10,fg=black}

\setbeamercolor{block title example}{bg=green!30,fg=black}
\setbeamercolor{block body example}{bg=green!5,fg=black}
```

---

## 6. Including Code

Beamer supports multiple methods for including source code, each with advantages.

### Method 1: Verbatim

The simplest approach uses `verbatim` (requires `[fragile]`):

```latex
\begin{frame}[fragile]{Simple Code}
\begin{verbatim}
def hello():
    print("Hello, World!")
\end{verbatim}
\end{frame}
```

### Method 2: Listings Package

The `listings` package provides syntax highlighting and customization:

```latex
\usepackage{listings}
\usepackage{xcolor}

% Configure listings style
\lstset{
  language=Python,
  basicstyle=\ttfamily\small,
  keywordstyle=\color{blue}\bfseries,
  commentstyle=\color{green!50!black}\itshape,
  stringstyle=\color{red},
  numbers=left,
  numberstyle=\tiny\color{gray},
  stepnumber=1,
  numbersep=5pt,
  backgroundcolor=\color{gray!10},
  frame=single,
  rulecolor=\color{gray!30},
  breaklines=true,
  showstringspaces=false
}

\begin{frame}[fragile]{Python Code}
\begin{lstlisting}[language=Python]
def fibonacci(n):
    """Generate Fibonacci sequence."""
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

# Print first 10 numbers
for num in fibonacci(10):
    print(num)
\end{lstlisting}
\end{frame}
```

### Method 3: Minted (Best Syntax Highlighting)

`minted` uses Pygments for superior syntax highlighting but requires `-shell-escape`:

```latex
\usepackage{minted}

% Configure minted
\setminted{
  linenos=true,
  frame=lines,
  framesep=2mm,
  fontsize=\small,
  bgcolor=lightgray!10
}

\begin{frame}[fragile]{Python with Minted}
\begin{minted}{python}
class DataProcessor:
    def __init__(self, data):
        self.data = data

    def process(self):
        return [x * 2 for x in self.data if x > 0]

processor = DataProcessor([1, -2, 3, -4, 5])
result = processor.process()
print(result)  # Output: [2, 6, 10]
\end{minted}
\end{frame}
```

Compile with: `pdflatex -shell-escape presentation.tex`

### Multiple Languages

```latex
\begin{frame}[fragile]{JavaScript Example}
\begin{minted}{javascript}
const fetchData = async (url) => {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};
\end{minted}
\end{frame}

\begin{frame}[fragile]{C++ Example}
\begin{minted}{cpp}
#include <iostream>
#include <vector>

template<typename T>
void print_vector(const std::vector<T>& vec) {
    for (const auto& elem : vec) {
        std::cout << elem << " ";
    }
    std::cout << std::endl;
}
\end{minted}
\end{frame}
```

### Code from External File

```latex
\begin{frame}[fragile]{Loading External Code}
\lstinputlisting[language=Python, firstline=10, lastline=25]{script.py}
\end{frame}

% Or with minted:
\begin{frame}[fragile]{External File with Minted}
\inputminted[firstline=10, lastline=25]{python}{script.py}
\end{frame}
```

### Highlighting Specific Lines

```latex
\begin{frame}[fragile]{Highlighted Lines}
\begin{minted}[highlightlines={3-4}]{python}
def calculate_total(prices):
    total = 0
    for price in prices:  # These lines
        total += price    # are highlighted
    return total
\end{minted}
\end{frame}
```

### Code and Explanation Side-by-Side

```latex
\begin{frame}[fragile]{Code Walkthrough}
\begin{columns}

\begin{column}{0.55\textwidth}
\begin{minted}[fontsize=\tiny]{python}
import numpy as np

def train_model(X, y):
    weights = np.random.randn(X.shape[1])
    for epoch in range(100):
        predictions = X @ weights
        error = y - predictions
        gradient = X.T @ error
        weights += 0.01 * gradient
    return weights
\end{minted}
\end{column}

\begin{column}{0.45\textwidth}
  \textbf{Key Steps:}
  \begin{enumerate}\small
    \item Initialize random weights
    \item Loop for 100 epochs
    \item Compute predictions
    \item Calculate error
    \item Update via gradient descent
  \end{enumerate}
\end{column}

\end{columns}
\end{frame}
```

### Inline Code

For inline code, use `\texttt{}` or minted's inline option:

```latex
\begin{frame}{Inline Code}
  The function \texttt{calculate\_sum()} returns an integer.

  % Or with minted:
  Use \mintinline{python}{lambda x: x**2} for squaring.
\end{frame}
```

---

## 7. Charts and Diagrams in Beamer

### PGFPlots for Charts

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

\begin{frame}{Performance Comparison}
\begin{center}
\begin{tikzpicture}
  \begin{axis}[
    width=0.8\textwidth,
    height=0.6\textwidth,
    xlabel={Dataset Size},
    ylabel={Time (seconds)},
    legend pos=north west,
    grid=major
  ]
  \addplot coordinates {
    (100, 0.5) (200, 1.2) (500, 3.1) (1000, 7.5)
  };
  \addplot coordinates {
    (100, 0.8) (200, 2.1) (500, 5.8) (1000, 13.2)
  };
  \legend{Algorithm A, Algorithm B}
  \end{axis}
\end{tikzpicture}
\end{center}
\end{frame}
```

### Bar Chart

```latex
\begin{frame}{Survey Results}
\begin{center}
\begin{tikzpicture}
  \begin{axis}[
    ybar,
    width=0.8\textwidth,
    height=0.6\textwidth,
    symbolic x coords={Method A, Method B, Method C, Method D},
    xtick=data,
    ylabel={Accuracy (\%)},
    ymin=0, ymax=100,
    nodes near coords,
    enlargelimits=0.15
  ]
  \addplot coordinates {
    (Method A, 87) (Method B, 92) (Method C, 78) (Method D, 95)
  };
  \end{axis}
\end{tikzpicture}
\end{center}
\end{frame}
```

### Pie Chart

```latex
\usepackage{pgf-pie}

\begin{frame}{Distribution}
\begin{center}
\begin{tikzpicture}
  \pie[radius=2]{
    45/Category A,
    30/Category B,
    15/Category C,
    10/Category D
  }
\end{tikzpicture}
\end{center}
\end{frame}
```

### TikZ Diagrams

```latex
\begin{frame}{System Architecture}
\begin{center}
\begin{tikzpicture}[
  node distance=2cm,
  block/.style={rectangle, draw, fill=blue!20, text width=2cm, text centered, rounded corners, minimum height=1cm}
]
  \node[block] (input) {Input Layer};
  \node[block, right of=input] (hidden) {Hidden Layer};
  \node[block, right of=hidden] (output) {Output Layer};

  \draw[->, thick] (input) -- (hidden);
  \draw[->, thick] (hidden) -- (output);
\end{tikzpicture}
\end{center}
\end{frame}
```

### Flowchart

```latex
\usepackage{tikz}
\usetikzlibrary{shapes.geometric, arrows, positioning}

\tikzstyle{startstop} = [rectangle, rounded corners, minimum width=3cm, minimum height=1cm, text centered, draw=black, fill=red!30]
\tikzstyle{process} = [rectangle, minimum width=3cm, minimum height=1cm, text centered, draw=black, fill=blue!30]
\tikzstyle{decision} = [diamond, minimum width=3cm, minimum height=1cm, text centered, draw=black, fill=green!30]
\tikzstyle{arrow} = [thick,->,>=stealth]

\begin{frame}{Algorithm Flow}
\begin{center}
\begin{tikzpicture}[node distance=2cm]
  \node (start) [startstop] {Start};
  \node (process1) [process, below of=start] {Initialize};
  \node (decision1) [decision, below of=process1, yshift=-1cm] {Converged?};
  \node (process2) [process, below of=decision1, yshift=-1cm] {Update};
  \node (stop) [startstop, right of=decision1, xshift=3cm] {Stop};

  \draw [arrow] (start) -- (process1);
  \draw [arrow] (process1) -- (decision1);
  \draw [arrow] (decision1) -- node[anchor=east] {no} (process2);
  \draw [arrow] (process2) -- ++(-3,0) |- (process1);
  \draw [arrow] (decision1) -- node[anchor=south] {yes} (stop);
\end{tikzpicture}
\end{center}
\end{frame}
```

### Including External Images/PDFs

```latex
\begin{frame}{External Graphics}
  \begin{center}
    % PNG/JPG
    \includegraphics[width=0.7\textwidth]{diagram.png}

    % PDF (specific page)
    \includegraphics[page=3, width=0.7\textwidth]{document.pdf}
  \end{center}
\end{frame}
```

### Resizing Charts

```latex
\begin{frame}{Large Chart}
  \resizebox{\textwidth}{!}{
    \begin{tikzpicture}
      % Your complex chart here
    \end{tikzpicture}
  }
\end{frame}
```

---

## 8. Handout Generation

### Basic Handout Mode

Compile presentation without overlays for printing:

```latex
% Handout mode (removes all overlays)
\documentclass[handout]{beamer}

% Rest of document unchanged
```

This creates a PDF with one page per frame (overlays merged).

### N-up Handouts (Multiple Slides Per Page)

```latex
\documentclass[handout]{beamer}
\usepackage{pgfpages}

% 2 slides per page
\pgfpagesuselayout{2 on 1}[a4paper,border shrink=5mm]

% 4 slides per page
\pgfpagesuselayout{4 on 1}[a4paper,landscape,border shrink=5mm]

% 6 slides per page
\pgfpagesuselayout{6 on 1}[a4paper,border shrink=5mm]

% 8 slides per page
\pgfpagesuselayout{8 on 1}[a4paper,border shrink=5mm]
```

### Handout with Notes

```latex
\documentclass[handout]{beamer}
\usepackage{pgfpages}

% Slides with note space
\pgfpagesuselayout{2 on 1 with notes}[a4paper,border shrink=5mm]
```

### Separate Presentation and Handout Builds

Use conditional compilation:

```latex
% presentation.tex
\documentclass[aspectratio=169]{beamer}
\input{content.tex}

% handout.tex
\documentclass[handout]{beamer}
\usepackage{pgfpages}
\pgfpagesuselayout{4 on 1}[a4paper,landscape,border shrink=5mm]
\input{content.tex}
```

### Handout-Only Content

Show content only in handout mode:

```latex
\begin{frame}{Summary}
  Presentation content here.

  \mode<handout>{
    \vspace{1em}
    \textbf{Additional notes for handout:}
    \begin{itemize}
      \item Extra detail 1
      \item Extra detail 2
    \end{itemize}
  }
\end{frame}
```

---

## 9. Presenter Notes

### Basic Notes

Add speaker notes that appear in presenter mode:

```latex
\begin{frame}{Introduction}
  Content visible to audience
  \note{
    - Remember to introduce yourself
    - Mention the three main goals
    - Ask if there are questions
  }
\end{frame}
```

### Dual-Screen Presenter Mode

Enable notes on a second screen:

```latex
% In preamble:
\usepackage{pgfpages}
\setbeameroption{show notes on second screen=right}

\begin{document}
\begin{frame}{Slide Title}
  Slide content
  \note{Speaker notes for this slide}
\end{frame}
```

Options:
- `show notes on second screen=right`
- `show notes on second screen=left`
- `show notes on second screen=bottom`

### Notes with Itemization

```latex
\begin{frame}{Complex Topic}
  Main slide content

  \note{
    \textbf{Key talking points:}
    \begin{itemize}
      \item Point 1: Explain the background
      \item Point 2: Show the connection to previous slide
      \item Point 3: Mention the upcoming demo
    \end{itemize}

    \textbf{Timing:} 3-4 minutes
  }
\end{frame}
```

### Notes Only Pages

Create notes-only pages (no slide content):

```latex
\note{
  \textbf{Transition notes:}

  Now we're moving from theory to practical examples.
  Take a moment to ask if anyone has questions before proceeding.
}
```

---

## 10. Beamer + Bibliography

### Basic Bibliography

```latex
\begin{frame}[allowframebreaks]{References}
  \bibliographystyle{plain}
  \bibliography{references}
\end{frame}
```

The `allowframebreaks` option automatically splits long bibliographies across multiple slides.

### BibLaTeX with Beamer

```latex
\usepackage[backend=biber, style=authoryear]{biblatex}
\addbibresource{references.bib}

% In document:
\begin{frame}[allowframebreaks]{References}
  \printbibliography
\end{frame}
```

### Citing in Frames

```latex
\begin{frame}{Previous Work}
  Smith showed that algorithm A outperforms B \cite{smith2020}.

  More recent work \cite{jones2021, doe2022} confirms these findings.
\end{frame}
```

### Footcite (Footnote Citations)

Citations in footnotes on each slide:

```latex
\begin{frame}{Literature Review}
  The original algorithm was developed by Smith\footcite{smith2020}.

  Later improvements\footcite{jones2021} increased efficiency by 40\%.

  Recent work\footcite{doe2022} extends this to parallel systems.
\end{frame}
```

### Custom Bibliography Style

```latex
\usepackage[backend=biber, style=authoryear, maxnames=2]{biblatex}

% Customize appearance
\setbeamertemplate{bibliography item}{\insertbiblabel}
\setbeamerfont{bibliography item}{size=\footnotesize}
\setbeamerfont{bibliography entry author}{size=\footnotesize}
\setbeamerfont{bibliography entry title}{size=\footnotesize}
\setbeamerfont{bibliography entry location}{size=\footnotesize}
\setbeamerfont{bibliography entry note}{size=\footnotesize}
```

### Splitting Bibliography by Topic

```latex
\begin{frame}[allowframebreaks]{Theoretical Work}
  \printbibliography[keyword=theory]
\end{frame}

\begin{frame}[allowframebreaks]{Experimental Work}
  \printbibliography[keyword=experimental]
\end{frame}
```

---

## 11. Advanced Tips

### Appendix and Backup Slides

Create slides that don't count toward total slide count:

```latex
\appendix

\begin{frame}[noframenumbering]{Backup: Extra Details}
  Additional information not in main presentation
\end{frame}

\begin{frame}[noframenumbering]{Backup: Technical Specifications}
  Detailed specifications
\end{frame}
```

Or use custom commands:

```latex
% In preamble:
\newcommand{\backupbegin}{
   \newcounter{finalframe}
   \setcounter{finalframe}{\value{framenumber}}
}
\newcommand{\backupend}{
   \setcounter{framenumber}{\value{finalframe}}
}

% In document:
% ... main slides ...

\backupbegin

\begin{frame}{Backup Slide}
  Extra content
\end{frame}

\backupend
```

### Custom Footline with Slide Numbers

```latex
\setbeamertemplate{footline}{
  \leavevmode%
  \hbox{%
    \begin{beamercolorbox}[wd=.33\paperwidth,ht=2.25ex,dp=1ex,center]{author in head/foot}%
      \usebeamerfont{author in head/foot}\insertshortauthor
    \end{beamercolorbox}%
    \begin{beamercolorbox}[wd=.34\paperwidth,ht=2.25ex,dp=1ex,center]{title in head/foot}%
      \usebeamerfont{title in head/foot}\insertshorttitle
    \end{beamercolorbox}%
    \begin{beamercolorbox}[wd=.33\paperwidth,ht=2.25ex,dp=1ex,right]{date in head/foot}%
      \usebeamerfont{date in head/foot}\insertshortdate{}\hspace*{2em}
      \insertframenumber{} / \inserttotalframenumber\hspace*{2ex}
    \end{beamercolorbox}
  }%
  \vskip0pt%
}
```

### Logo in Corner

```latex
% In preamble:
\logo{\includegraphics[height=0.8cm]{logo.png}}

% Or position manually:
\addtobeamertemplate{frametitle}{}{%
  \begin{tikzpicture}[remember picture,overlay]
    \node[anchor=north east,yshift=-2pt] at (current page.north east) {\includegraphics[height=0.8cm]{logo.png}};
  \end{tikzpicture}
}
```

### Progress Bar

Add a progress bar at the top of each slide:

```latex
\usepackage{tikz}

\addtobeamertemplate{frametitle}{}{%
  \begin{tikzpicture}[remember picture,overlay]
    \fill[blue!30] (current page.north west) rectangle ([yshift=-0.5cm]current page.north east);
    \fill[blue!70] (current page.north west) rectangle ([yshift=-0.5cm,xshift=\paperwidth*\insertframenumber/\inserttotalframenumber]current page.north west);
  \end{tikzpicture}
}
```

### Section Slides

Automatically insert section title slides:

```latex
\AtBeginSection[]{
  \begin{frame}
    \vfill
    \centering
    \begin{beamercolorbox}[sep=8pt,center,shadow=true,rounded=true]{title}
      \usebeamerfont{title}\insertsectionhead\par%
    \end{beamercolorbox}
    \vfill
  \end{frame}
}
```

### Aspect Ratio Comparison

```latex
% 4:3 traditional (1.33:1)
\documentclass{beamer}

% 16:9 widescreen (1.78:1) - RECOMMENDED
\documentclass[aspectratio=169]{beamer}

% 16:10 widescreen (1.60:1)
\documentclass[aspectratio=1610]{beamer}

% 14:9 semi-wide (1.56:1)
\documentclass[aspectratio=149]{beamer}

% 5:4 (1.25:1)
\documentclass[aspectratio=54]{beamer}
```

**Recommendation:** Use 16:9 for modern projectors and screens.

### Remove Navigation Symbols

```latex
% Completely remove navigation symbols
\setbeamertemplate{navigation symbols}{}

% Or show only specific symbols
\setbeamertemplate{navigation symbols}{
  \insertframenavigationsymbol
  \insertbackfindforwardnavigationsymbol
}
```

### Custom Bullet Points

```latex
% Triangle bullets
\setbeamertemplate{itemize items}[triangle]

% Circle bullets
\setbeamertemplate{itemize items}[circle]

% Ball bullets
\setbeamertemplate{itemize items}[ball]

% Custom symbol
\setbeamertemplate{itemize items}{\textbullet}

% Different symbols per level
\setbeamertemplate{itemize item}{\textbullet}
\setbeamertemplate{itemize subitem}{\textendash}
\setbeamertemplate{itemize subsubitem}{\textasteriskcentered}
```

---

## 12. Complete Example Presentation

Here's a full working presentation demonstrating key features:

```latex
\documentclass[aspectratio=169]{beamer}

% Theme and colors
\usetheme{Madrid}
\usecolortheme{whale}

% Packages
\usepackage[utf8]{inputenc}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{minted}
\usepackage{tikz}
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

% Custom colors
\definecolor{myblue}{RGB}{0,102,153}
\setbeamercolor{frametitle}{bg=myblue,fg=white}
\setbeamercolor{title}{fg=myblue}

% Remove navigation symbols
\setbeamertemplate{navigation symbols}{}

% Metadata
\title{Introduction to Machine Learning}
\subtitle{A Practical Overview}
\author{Dr. Jane Smith}
\institute{University of Example}
\date{February 17, 2026}

\begin{document}

% Title slide
\begin{frame}
  \titlepage
\end{frame}

% Outline
\begin{frame}{Outline}
  \tableofcontents
\end{frame}

% Section 1
\section{Introduction}

\begin{frame}{What is Machine Learning?}
  \begin{definition}
    Machine Learning is the study of algorithms that improve automatically through experience.
  \end{definition}

  \pause

  \textbf{Key characteristics:}
  \begin{itemize}[<+->]
    \item Learn from data
    \item Improve over time
    \item Make predictions
    \item Adapt to new situations
  \end{itemize}
\end{frame}

\begin{frame}{Types of Learning}
\begin{columns}

\begin{column}{0.5\textwidth}
  \begin{block}{Supervised Learning}
    \begin{itemize}
      \item Labeled data
      \item Classification
      \item Regression
    \end{itemize}
  \end{block}

  \begin{exampleblock}{Example}
    Email spam detection
  \end{exampleblock}
\end{column}

\begin{column}{0.5\textwidth}
  \begin{block}{Unsupervised Learning}
    \begin{itemize}
      \item Unlabeled data
      \item Clustering
      \item Dimensionality reduction
    \end{itemize}
  \end{block}

  \begin{exampleblock}{Example}
    Customer segmentation
  \end{exampleblock}
\end{column}

\end{columns}
\end{frame}

% Section 2
\section{Mathematical Foundations}

\begin{frame}{Linear Regression}
  The goal is to find the best-fit line:

  \begin{equation}
    y = \beta_0 + \beta_1 x + \epsilon
  \end{equation}

  \pause

  We minimize the sum of squared errors:

  \begin{equation}
    \text{SSE} = \sum_{i=1}^{n} (y_i - \hat{y}_i)^2
  \end{equation}

  \pause

  The solution is:
  \begin{equation}
    \hat{\beta} = (X^T X)^{-1} X^T y
  \end{equation}
\end{frame}

% Section 3
\section{Implementation}

\begin{frame}[fragile]{Python Implementation}
\begin{minted}[fontsize=\small]{python}
import numpy as np
from sklearn.linear_model import LinearRegression

# Training data
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([2, 4, 5, 4, 5])

# Create and train model
model = LinearRegression()
model.fit(X, y)

# Make predictions
predictions = model.predict([[6], [7]])
print(predictions)
\end{minted}
\end{frame}

% Section 4
\section{Results}

\begin{frame}{Performance Comparison}
\begin{center}
\begin{tikzpicture}
  \begin{axis}[
    ybar,
    width=0.8\textwidth,
    height=0.5\textwidth,
    symbolic x coords={Linear, Polynomial, Neural Net},
    xtick=data,
    ylabel={Accuracy (\%)},
    ymin=0, ymax=100,
    nodes near coords,
    enlargelimits=0.2
  ]
  \addplot coordinates {
    (Linear, 78) (Polynomial, 85) (Neural Net, 92)
  };
  \end{axis}
\end{tikzpicture}
\end{center}
\end{frame}

\begin{frame}{Results Table}
  \begin{center}
  \begin{tabular}{lccc}
    \toprule
    \textbf{Model} & \textbf{Accuracy} & \textbf{Training Time} & \textbf{Complexity} \\
    \midrule
    Linear Regression & 78\% & 0.1s & Low \\
    Polynomial Regression & 85\% & 0.3s & Medium \\
    Neural Network & 92\% & 15.2s & High \\
    \bottomrule
  \end{tabular}
  \end{center}

  \vspace{1em}

  \only<2>{
    \textbf{Key insight:} Neural networks achieve highest accuracy but require more computational resources.
  }
\end{frame}

% Section 5
\section{Conclusion}

\begin{frame}{Summary}
  \textbf{What we covered:}

  \begin{enumerate}
    \item<1-> Machine learning fundamentals
    \item<2-> Mathematical foundations
    \item<3-> Practical implementation
    \item<4-> Performance comparison
  \end{enumerate}

  \vspace{1em}

  \only<5>{
    \begin{alertblock}{Next Steps}
      Try implementing these algorithms on your own datasets!
    \end{alertblock}
  }
\end{frame}

\begin{frame}[plain]
  \vfill
  \centering
  \Large
  \textbf{Thank You!}

  \vspace{1em}

  \normalsize
  Questions?

  \vspace{1em}

  \small
  jane.smith@university.edu
  \vfill
\end{frame}

% Backup slides
\appendix

\begin{frame}[noframenumbering]{Backup: Advanced Topics}
  Additional material available upon request:
  \begin{itemize}
    \item Deep learning architectures
    \item Hyperparameter tuning
    \item Cross-validation strategies
    \item Model deployment
  \end{itemize}
\end{frame}

\end{document}
```

---

## 13. Common Pitfalls

### 1. Missing [fragile] for Code

**Problem:** Compilation errors when including verbatim/code content.

```latex
% WRONG - will fail
\begin{frame}{Code}
\begin{verbatim}
code here
\end{verbatim}
\end{frame}

% CORRECT
\begin{frame}[fragile]{Code}
\begin{verbatim}
code here
\end{verbatim}
\end{frame}
```

### 2. Using \newpage Instead of New Frames

**Problem:** `\newpage` doesn't work in Beamer.

```latex
% WRONG
\begin{frame}{First}
Content
\newpage
More content
\end{frame}

% CORRECT
\begin{frame}{First}
Content
\end{frame}

\begin{frame}{Second}
More content
\end{frame}
```

### 3. Tables Don't Auto-Resize

**Problem:** Large tables overflow the slide.

```latex
% WRONG - table may overflow
\begin{frame}{Large Table}
\begin{tabular}{lcccccc}
% ... many columns ...
\end{tabular}
\end{frame}

% CORRECT - manually resize
\begin{frame}{Large Table}
\resizebox{\textwidth}{!}{
  \begin{tabular}{lcccccc}
  % ... many columns ...
  \end{tabular}
}
\end{frame}

% ALTERNATIVE - scale box
\begin{frame}{Large Table}
\scalebox{0.8}{
  \begin{tabular}{lcccccc}
  % ... many columns ...
  \end{tabular}
}
\end{frame}
```

### 4. Overlay Specification Errors

**Problem:** Incorrect overlay syntax.

```latex
% WRONG
\begin{frame}{Items}
\begin{itemize}
  \item<1> First  % Missing dash
  \item<2> Second
\end{itemize}
\end{frame}

% CORRECT
\begin{frame}{Items}
\begin{itemize}
  \item<1-> First
  \item<2-> Second
\end{itemize}
\end{frame}
```

### 5. Beamer Redefines Environments

**Problem:** Some standard LaTeX environments behave differently.

```latex
% figure environment doesn't float in Beamer
\begin{frame}{Image}
  % Don't use \begin{figure}[h] or [t]
  \begin{figure}  % No placement specifier needed
    \includegraphics{image.png}
    \caption{My image}
  \end{figure}
\end{frame}
```

### 6. Forgetting to Load Required Packages

**Problem:** Missing package for special features.

```latex
% For code highlighting
\usepackage{listings}  % or minted

% For tables
\usepackage{booktabs}

% For math
\usepackage{amsmath,amssymb}

% For diagrams
\usepackage{tikz}
\usepackage{pgfplots}

% For better fonts
\usepackage[T1]{fontenc}
```

### 7. Minted Without -shell-escape

**Problem:** Minted requires special compilation flag.

```bash
# WRONG
pdflatex presentation.tex

# CORRECT
pdflatex -shell-escape presentation.tex

# Or with latexmk
latexmk -pdf -shell-escape presentation.tex
```

### 8. Too Much Content Per Slide

**Problem:** Slides become cluttered and unreadable.

**Solution:** Follow the 6×6 rule (maximum 6 bullet points, 6 words each) or use multiple slides.

### 9. Inconsistent Overlay Numbering

**Problem:** Overlays don't align as expected.

```latex
% WRONG - numbers don't match
\begin{frame}{Misaligned}
  \only<1>{First}
  \only<3>{Third}  % Skipped 2!
  \only<2>{Second}
\end{frame}

% CORRECT - sequential
\begin{frame}{Aligned}
  \only<1>{First}
  \only<2>{Second}
  \only<3>{Third}
\end{frame}
```

### 10. Not Testing in Presentation Mode

**Problem:** What looks good in PDF viewer may not work in full-screen mode.

**Solution:** Always test with actual presentation software and projector if possible.

---

## Quick Reference Card

```latex
% Document class
\documentclass[aspectratio=169]{beamer}

% Basic frame
\begin{frame}{Title}
  Content
\end{frame}

% Frame options
[fragile]            % For code
[plain]              % No header/footer
[noframenumbering]   % Don't count
[allowframebreaks]   % Auto-split
[t]                  % Top-align

% Overlays
\pause                      % Sequential reveal
\onslide<2->{text}         % Show from slide 2
\only<1-3>{text}           % Show on slides 1-3
\alert<2>{text}            % Highlight on slide 2
\begin{itemize}[<+->]      % Reveal items sequentially

% Blocks
\begin{block}{Title}       % Normal block
\begin{alertblock}{Title}  % Alert block
\begin{exampleblock}{Title}% Example block

% Columns
\begin{columns}
\begin{column}{0.5\textwidth}
\end{column}
\end{columns}

% Code
\begin{frame}[fragile]
\begin{verbatim}...\end{verbatim}
\begin{lstlisting}...\end{lstlisting}
\begin{minted}{python}...\end{minted}

% Bibliography
\begin{frame}[allowframebreaks]{References}
  \bibliography{refs}
\end{frame}

% Handout
\documentclass[handout]{beamer}
\pgfpagesuselayout{4 on 1}[a4paper,landscape]
```

---

**Total guide size:** ~15KB of practical Beamer content covering all essential topics for creating professional LaTeX presentations.
