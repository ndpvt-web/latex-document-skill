# Font Selection & Typography Guide

A comprehensive guide to choosing and configuring fonts in LaTeX documents, covering everything from basic font selection to advanced typography techniques.

## Table of Contents

1. [Font Basics in LaTeX](#1-font-basics-in-latex)
2. [Engine-Specific Font Handling](#2-engine-specific-font-handling)
3. [Font Pairing Recommendations](#3-font-pairing-recommendations)
4. [Mathematical Fonts](#4-mathematical-fonts)
5. [Icons with fontawesome5](#5-icons-with-fontawesome5)
6. [Microtype (Typography Fine-Tuning)](#6-microtype-typography-fine-tuning)
7. [Font Size & Spacing](#7-font-size--spacing)
8. [CJK Font Setup](#8-cjk-font-setup)
9. [Common Font Problems & Solutions](#9-common-font-problems--solutions)
10. [Quick Reference: Font → Package Mapping](#10-quick-reference-font--package-mapping)

---

## 1. Font Basics in LaTeX

LaTeX fonts are controlled through three independent axes that can be combined to create different typographic effects:

### The Three Font Axes

1. **Family** - The overall design style
   - `\rmfamily` or `\textrm{...}` - Serif (roman) fonts with decorative strokes
   - `\sffamily` or `\textsf{...}` - Sans-serif fonts without strokes
   - `\ttfamily` or `\texttt{...}` - Monospace (typewriter) fonts with fixed width

2. **Series** - The weight or width
   - `\mdseries` or `\textmd{...}` - Medium weight (default)
   - `\bfseries` or `\textbf{...}` - Bold weight
   - Some fonts support `\lfseries` (light) through special packages

3. **Shape** - The posture or variation
   - `\upshape` or `\textup{...}` - Upright (default)
   - `\itshape` or `\textit{...}` - Italic (cursive, redesigned letters)
   - `\slshape` or `\textsl{...}` - Slanted (mechanically sloped)
   - `\scshape` or `\textsc{...}` - Small Caps

### Default LaTeX Fonts: Computer Modern

LaTeX's default font is Computer Modern (CM), designed by Donald Knuth specifically for TeX. This is why LaTeX documents have a distinctive "LaTeX-y" look:

- **Characteristics**: High stroke contrast, narrow letter spacing, geometric design
- **Advantages**: Excellent mathematical typography, crisp at all sizes, free
- **Disadvantages**: Looks dated to modern readers, limited character sets in original CM
- **Modern Alternative**: Latin Modern (extended CM with better encoding)

### Why Documents Look "LaTeX-y" and How to Change

The LaTeX aesthetic comes from:
1. Computer Modern font family
2. Tight letter spacing and specific kerning
3. Mathematical typesetting conventions
4. Default page margins (quite wide)

To modernize your documents:
```latex
% Switch to modern fonts
\usepackage[T1]{fontenc}  % Better font encoding
\usepackage{lmodern}       % Latin Modern (improved CM)
% OR choose a completely different font
\usepackage{mathpazo}      % Palatino
\usepackage{newtxtext,newtxmath}  % Times
```

---

## 2. Engine-Specific Font Handling

LaTeX has three main compilation engines, each with different font capabilities:

### pdfLaTeX Fonts (Package-Based)

pdfLaTeX uses traditional TeX fonts installed through packages. This is the most compatible but least flexible approach.

#### Serif (Text) Fonts

```latex
% Palatino - Elegant, highly readable, excellent for books
\usepackage{mathpazo}
% OR modern version with better math support:
\usepackage{newpxtext,newpxmath}

% Times - Compact, traditional, good for space-constrained docs
\usepackage{newtxtext,newtxmath}

% Latin Modern - Clean, modern version of Computer Modern
\usepackage{lmodern}

% Libertinus - Modern, open source, excellent math support
\usepackage{libertinus}

% Cochineal - Warm, readable, based on Crimson
\usepackage{cochineal}
\usepackage[cochineal]{newtxmath}

% Baskerville - Classic, elegant, good for literature
\usepackage{librebaskerville}

% Garamond - Traditional, refined, excellent for books
\usepackage{ebgaramond}
\usepackage[cmintegrals,cmbraces]{newtxmath}
\usepackage[italic]{mathastext}

% Charter - Clean, readable, designed for low-res output
\usepackage[bitstream-charter]{mathdesign}

% Utopia - Generous x-height, modern serif
\usepackage{fourier}
```

#### Sans-Serif Fonts

```latex
% Roboto - Google's geometric humanist font
\usepackage[sfdefault]{roboto}

% Fira Sans - Mozilla's humanist sans, great for tech docs
\usepackage[sfdefault]{FiraSans}

% Noto Sans - Google's font covering 800+ languages
\usepackage[sfdefault]{noto-sans}

% Source Sans Pro - Adobe's readable humanist sans
\usepackage[default]{sourcesanspro}

% Helvetica (clone) - Classic neutral sans-serif
\usepackage[scaled]{helvet}
\renewcommand\familydefault{\sfdefault}

% Avant Garde (clone) - Geometric, rounded
\usepackage{avant}
\renewcommand\familydefault{\sfdefault}

% Cabin - Humanist sans inspired by Gill Sans
\usepackage[sfdefault]{cabin}
```

#### Monospace Fonts

```latex
% Inconsolata - Most popular LaTeX monospace, great for code
\usepackage[scaled=0.95]{inconsolata}

% Fira Mono - Matches Fira Sans, excellent readability
\usepackage[scale=0.9]{FiraMono}

% Source Code Pro - Adobe's monospace, generous spacing
\usepackage[scale=0.9]{sourcecodepro}

% Anonymous Pro - Fixed-width with distinct characters
\usepackage[ttdefault]{anonymous-pro}

% Courier - Classic typewriter font
\usepackage{courier}
```

#### Complete Font Setup Example (pdfLaTeX)

```latex
\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}

% Text font: Palatino
\usepackage{newpxtext}
% Math font: Matching Palatino math
\usepackage{newpxmath}
% Monospace: Inconsolata for code
\usepackage[scaled=0.95]{inconsolata}

\begin{document}
Regular text in Palatino. \texttt{Code in Inconsolata}. $E = mc^2$ in Palatino math.
\end{document}
```

### XeLaTeX/LuaLaTeX Fonts (System Fonts with fontspec)

XeLaTeX and LuaLaTeX can use any font installed on your system through the `fontspec` package. This is more flexible but requires fonts to be installed system-wide.

```latex
\documentclass{article}
\usepackage{fontspec}

% Main text font (serif)
\setmainfont{TeX Gyre Pagella}[
  Ligatures=TeX,              % Enable LaTeX ligatures (-- → en-dash)
  Numbers=OldStyle,           % Use old-style figures (optional)
  BoldFont=TeX Gyre Pagella Bold,
  ItalicFont=TeX Gyre Pagella Italic
]

% Sans-serif font
\setsansfont{TeX Gyre Heros}[
  Scale=MatchLowercase,       % Match x-height of main font
  Ligatures=TeX
]

% Monospace font
\setmonofont{Fira Code}[
  Scale=0.9,
  Contextuals=Alternate       % Enable ligatures in code (optional)
]

\begin{document}
Main text. \textsf{Sans-serif text}. \texttt{Monospace code}.
\end{document}
```

#### Using System Fonts

```latex
% macOS examples
\setmainfont{Hoefler Text}
\setsansfont{Helvetica Neue}

% Windows examples
\setmainfont{Georgia}
\setsansfont{Segoe UI}

% Linux examples (requires fonts installed)
\setmainfont{Linux Libertine O}
\setsansfont{Linux Biolinum O}

% Adobe fonts (if installed)
\setmainfont{Minion Pro}
\setsansfont{Myriad Pro}
```

### Engine-Agnostic Setup (Modern Best Practice with iftex)

For maximum portability, write code that works with both pdfLaTeX and XeLaTeX/LuaLaTeX:

```latex
\documentclass{article}
\usepackage{iftex}

\ifPDFTeX
  % pdfLaTeX setup
  \usepackage[utf8]{inputenc}
  \usepackage[T1]{fontenc}
  \usepackage{newtxtext,newtxmath}
  \usepackage[scaled=0.95]{inconsolata}
\else
  % XeLaTeX/LuaLaTeX setup
  \usepackage{fontspec}
  \setmainfont{TeX Gyre Termes}
  \setmonofont{Inconsolata}[Scale=0.95]
  \usepackage{unicode-math}
  \setmathfont{TeX Gyre Termes Math}
\fi

\begin{document}
This document works with all engines!
\end{document}
```

#### Complete Engine-Agnostic Template

```latex
\documentclass[11pt]{article}
\usepackage{iftex}

\ifPDFTeX
  \usepackage[utf8]{inputenc}
  \usepackage[T1]{fontenc}
  \usepackage{newpxtext}           % Palatino text
  \usepackage{newpxmath}           % Palatino math
  \usepackage[scaled=0.95]{inconsolata}
\else
  \usepackage{fontspec}
  \setmainfont{TeX Gyre Pagella}[Ligatures=TeX]
  \setmonofont{Inconsolata}[Scale=0.95]
  \usepackage{unicode-math}
  \setmathfont{TeX Gyre Pagella Math}
\fi

\usepackage{microtype}  % Works with all engines

\begin{document}
Works everywhere: plain text, \textbf{bold}, \textit{italic},
\texttt{code}, and math: $\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}$
\end{document}
```

---

## 3. Font Pairing Recommendations

Good typography requires harmonious font combinations. Here are tested pairings for different document types.

### Academic/Formal Documents

| Text Font | Math Font | Package | Best For | Notes |
|-----------|-----------|---------|----------|-------|
| Palatino | Matching | `newpxtext` + `newpxmath` | Theses, books, elegant docs | Hermann Zapf's masterpiece, highly readable |
| Times | Matching | `newtxtext` + `newtxmath` | Papers, journals, compact docs | Industry standard, space-efficient |
| Libertinus | Matching | `libertinus` | Modern academic, open source | Based on Linux Libertine, excellent math |
| Latin Modern | Default CM | `lmodern` | Pure LaTeX aesthetic | For when you want the classic TeX look |
| Garamond | adapted | `ebgaramond` + `newtxmath` | Literary works, humanities | Classic elegance, best for long texts |
| Baskerville | adapted | `librebaskerville` + math | Historical documents, formal | Traditional British typography |
| Charter | Matching | `mathdesign` (charter) | Technical reports, preprints | Designed for low-resolution printing |
| Concrete | Matching | `ccfonts` + `eulervm` | Knuth's books, expository math | Used in "Concrete Mathematics" |

#### Example: Thesis Setup

```latex
\documentclass[12pt,twoside]{report}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}

% Palatino for elegant, readable body text
\usepackage{newpxtext}
\usepackage{newpxmath}

% Monospace for code listings
\usepackage[scaled=0.95]{inconsolata}

% Fine typography adjustments
\usepackage[final]{microtype}

\begin{document}
% Beautiful thesis content
\end{document}
```

### Modern/Technical Documents

| Text Font | Sans Font | Mono Font | Best For | Character |
|-----------|-----------|-----------|----------|-----------|
| Source Serif | Source Sans | Source Code | Adobe suite, tech docs | Cohesive Adobe family |
| Fira Sans | - | Fira Mono | Mozilla, data science | Modern, technical, great on-screen |
| Roboto | Roboto Condensed | Roboto Mono | Google-style, presentations | Geometric, friendly, versatile |
| Noto Serif | Noto Sans | Noto Mono | Multilingual, CJK support | Universal language coverage |
| Carlito + Caladea | Carlito | Courier | LibreOffice compatibility | MS Office metric-compatible |

#### Example: Technical Report

```latex
\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}

% Modern sans-serif throughout
\usepackage[sfdefault]{FiraSans}
\usepackage[scale=0.9]{FiraMono}

% No math font needed for technical docs without equations
\usepackage{microtype}

\begin{document}
Clean, modern technical documentation.
\end{document}
```

### Resume/Business Documents

| Font | Style | Best For | Impression |
|------|-------|----------|------------|
| Fira Sans | Modern, clean | Tech resumes, startups | Professional, contemporary |
| Roboto | Friendly, readable | Creative, marketing | Approachable, modern |
| EB Garamond | Classic, elegant | Finance, law, consulting | Traditional, prestigious |
| Libertinus | Scholarly, open | Research positions | Academic, sophisticated |
| Source Sans | Technical, clear | Engineering, data | Clean, technical |
| Charter | Readable, neutral | General business | Professional, safe choice |

#### Example: Modern Resume

```latex
\documentclass[10pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}

% Clean sans-serif
\usepackage[sfdefault,light]{roboto}

% Icons for contact info
\usepackage{fontawesome5}

% Tight margins for resume
\usepackage[margin=0.5in]{geometry}

\begin{document}
\section*{Contact}
\faEnvelope\ email@example.com \quad
\faPhone*\ (555) 123-4567 \quad
\faGithub\ github.com/username
\end{document}
```

### Presentation/Slide Pairings

| Heading Font | Body Font | Best For |
|--------------|-----------|----------|
| Fira Sans Bold | Fira Sans | Technical talks |
| Roboto Condensed | Roboto | Business presentations |
| Montserrat | Source Sans | Modern, creative |
| Raleway | Lato | Minimalist, clean |

---

## 4. Mathematical Fonts

Mathematics requires special font handling because of the vast number of symbols and strict spacing requirements.

### Key Math Font Packages (pdfLaTeX)

```latex
% Times-compatible math
\usepackage{newtxtext,newtxmath}
% Produces: text in Times, math in Times-styled symbols

% Palatino-compatible math
\usepackage{newpxtext,newpxmath}
% Produces: text in Palatino, math in Palatino-styled symbols

% Classic Palatino math (older package)
\usepackage{mathpazo}
% Still works but newpxmath is more complete

% Libertinus (text + math in one package)
\usepackage{libertinus}
% Modern, excellent coverage, open source

% Euler math (upright, calligraphic style)
\usepackage{eulervm}
% Used with Concrete fonts in Knuth's books

% Fourier (with Utopia text)
\usepackage{fourier}
% Generous x-height, modern appearance

% KP Serif math (with Kepler fonts)
\usepackage{kpfonts}
% Complete package with many options

% Antykwa Toruńska
\usepackage{anttor}
% Polish design, distinctive appearance
```

### Unicode Math (XeLaTeX/LuaLaTeX)

With modern engines, use the `unicode-math` package for OpenType math fonts:

```latex
\usepackage{unicode-math}

% Available OpenType math fonts:
\setmathfont{Latin Modern Math}           % Extended Computer Modern
\setmathfont{TeX Gyre Pagella Math}       % Palatino-style
\setmathfont{TeX Gyre Termes Math}        % Times-style
\setmathfont{TeX Gyre DejaVu Math}        % DejaVu-style
\setmathfont{STIX Two Math}               % Scientific/technical
\setmathfont{XITS Math}                   % Extended STIX
\setmathfont{Libertinus Math}             % Modern, complete
\setmathfont{Fira Math}                   % Sans-serif math (experimental)
\setmathfont{Asana Math}                  % Extensive symbol coverage
```

### Font Metrics: Matching X-Height

The x-height (height of lowercase 'x') must match between text and math for visual consistency:

```latex
% Bad: text and math x-heights don't match
\usepackage{charter}        % Charter text
\usepackage{newtxmath}      % Times math - MISMATCH!

% Good: matched pair
\usepackage[charter]{mathdesign}  % Charter text + matching math
% OR
\usepackage{newtxtext,newtxmath}  % Both Times-based
```

### Math Font Comparison

```latex
\documentclass{article}

% Test different math fonts:
\usepackage{newpxtext,newpxmath}  % Choice 1: Palatino

\begin{document}
Inline math: $E = mc^2$, $\alpha + \beta = \gamma$

Display math:
\[
\int_0^\infty \frac{x^3}{e^x-1}\,dx = \frac{\pi^4}{15}
\]

Matrix:
\[
\begin{pmatrix}
a & b \\
c & d
\end{pmatrix}
\]
\end{document}
```

### Advanced Math Font Configuration

```latex
% Mix and match for specific needs
\usepackage{newpxtext}       % Palatino text
\usepackage[vvarbb]{newpxmath}  % Palatino math with special options
% Options:
%   vvarbb  - variant blackboard bold
%   bigdelims - larger delimiters
%   noamssymbols - don't load AMS symbols

% Or use different fonts for different math alphabets
\usepackage{newpxtext,newpxmath}
\usepackage{bm}  % Bold math
% Now \mathbb, \mathcal, \mathfrak are available
```

---

## 5. Icons with fontawesome5

The `fontawesome5` package provides access to 1,500+ vector icons, essential for modern resumes and documents.

### Basic Setup

```latex
\usepackage{fontawesome5}

% Use icons inline:
\faEnvelope\ email@example.com
```

### Common Icons Reference

#### Contact Information
```latex
\faEnvelope          % email (outline)
\faEnvelope*         % email (solid)
\faPhone             % phone (outline)
\faPhone*            % phone (solid)
\faMobile            % mobile phone
\faMobile*           % mobile phone (solid)
\faMapMarker         % location (outline)
\faMapMarker*        % location (solid)
\faHome              % home address
\faGlobe             % website
```

#### Social Media
```latex
\faLinkedin          % LinkedIn logo
\faGithub            % GitHub logo
\faGitlab            % GitLab logo
\faTwitter           % Twitter/X logo
\faFacebook          % Facebook logo
\faInstagram         % Instagram logo
\faStackOverflow     % Stack Overflow logo
\faYoutube           % YouTube logo
\faMedium            % Medium logo
```

#### Professional/Resume
```latex
\faBriefcase         % work experience
\faGraduationCap     % education
\faCertificate       % certification
\faAward             % awards/honors
\faCode              % programming/code
\faLaptopCode        % software development
\faTools             % skills/tools
\faProjectDiagram    % projects
\faUsers             % teamwork
\faLightbulb         % ideas/innovation
\faChartLine         % growth/metrics
```

#### Document Elements
```latex
\faFile              % generic file
\faFilePdf           % PDF file
\faFileCode          % code file
\faFileAlt           % document
\faLink              % hyperlink
\faExternalLinkAlt   % external link
\faDownload          % download
\faInfoCircle        % information
\faExclamationTriangle  % warning
\faCheckCircle       % success/checkmark
\faTimesCircle       % error/close
```

### Icon Styles

Font Awesome has three styles: solid (default), regular (outline), and brands.

```latex
% Solid style (filled) - use * or -s suffix
\faHeart*            % filled heart
\faStar*             % filled star

% Regular style (outline) - use -r suffix or no suffix
\faHeart[-regular]   % outline heart
\faStar[-regular]    % outline star

% Brands style (logos) - automatic
\faGithub            % brand logos
```

### Sizing Icons

```latex
% Match text size
\faIcon{envelope}

% Custom size
\faIcon[regular]{star} \quad
{\Large \faIcon{star}} \quad
{\Huge \faIcon{star}}
```

### Resume Example with Icons

```latex
\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[sfdefault]{roboto}
\usepackage{fontawesome5}
\usepackage[margin=0.5in]{geometry}

\begin{document}

\section*{\faUser\ John Doe}

\faEnvelope\ john.doe@email.com \quad
\faPhone*\ (555) 123-4567 \quad
\faMapMarker*\ San Francisco, CA

\faLinkedin\ linkedin.com/in/johndoe \quad
\faGithub\ github.com/johndoe \quad
\faGlobe\ johndoe.com

\section*{\faBriefcase\ Experience}
\textbf{Senior Software Engineer} \quad \faCalendar\ 2020--Present

\section*{\faGraduationCap\ Education}
\textbf{B.S. Computer Science} \quad \faUniversity\ MIT \quad 2016

\section*{\faCode\ Skills}
Python \quad JavaScript \quad \faDatabase\ SQL \quad \faDocker\ Docker

\end{document}
```

---

## 6. Microtype (Typography Fine-Tuning)

The `microtype` package provides micro-typographic improvements that make text more readable and professional-looking.

### Basic Usage

```latex
% Minimal setup (recommended for all documents)
\usepackage{microtype}

% Full setup with all features
\usepackage[
  final,              % Enable in final mode (default)
  protrusion=true,    % Character protrusion
  expansion=true,     % Font expansion
  tracking=true,      % Letter spacing adjustments
  kerning=true        % Additional kerning
]{microtype}
```

### Character Protrusion (Margin Kerning)

Protrusion lets certain characters (hyphens, periods, commas) extend slightly into the margin for better optical alignment:

```latex
\usepackage[protrusion=true]{microtype}

% Customization (advanced)
\SetProtrusion{
  encoding = *,
  family = *
}{
  A = {50,50},    % Protrude both sides of 'A'
  . = {,700},     % Protrude period to the right
  - = {,500}      % Protrude hyphen to the right
}
```

**Effect**: Makes justified text appear more even, especially at line beginnings/ends.

### Font Expansion

Allows tiny stretching or shrinking of characters (typically ±2%) to improve line breaking:

```latex
\usepackage[expansion=true]{microtype}

% Customization
\SetExpansion[
  stretch = 20,     % Maximum stretch (1/1000 em)
  shrink = 20,      % Maximum shrink
  step = 5          % Granularity
]{
  encoding = *
}{
  A = 500,          % 'A' can expand more
  Q = 700           % 'Q' can expand even more
}
```

**Effect**: Reduces hyphenation and improves word spacing in justified text. **Note**: Only works with pdfLaTeX, not XeLaTeX/LuaLaTeX.

### Tracking (Letter Spacing)

Adjusts spacing between letters, particularly useful for small caps and all-caps text:

```latex
\usepackage[tracking=true]{microtype}

% Automatic tracking for small caps
\textsc{Small Caps Look Better}

% Manual tracking adjustment
{\textls[100]{WIDELY SPACED TEXT}}
{\textls[-50]{Tightly Spaced}}
```

### Draft vs Final Mode

```latex
% Disable microtype during drafting for faster compilation
\usepackage[draft]{microtype}

% Enable for final version
\usepackage[final]{microtype}

% OR respect document class option
\usepackage{microtype}  % Uses class's draft/final setting
```

### Complete Example

```latex
\documentclass[11pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{newpxtext,newpxmath}

% Full microtype configuration
\usepackage[
  final,
  protrusion=true,
  expansion=true,
  tracking=true,
  kerning=true,
  spacing=true
]{microtype}

\begin{document}
\section{Beautiful Typography}

This document uses microtype for professional-quality typesetting.
Notice how the line breaking is improved, margins are optically aligned,
and \textsc{Small Caps} are properly spaced. The difference is subtle
but significant in long documents.

Compare: \textsc{without tracking} vs \textls[75]{\textsc{with tracking}}

\end{document}
```

### When to Use Each Feature

| Feature | Use Case | Engine Support |
|---------|----------|----------------|
| Protrusion | Always (minimal cost, big benefit) | pdfLaTeX, XeLaTeX, LuaLaTeX |
| Expansion | Justified text, formal documents | pdfLaTeX only |
| Tracking | Small caps, headers, titles | All engines |
| Kerning | Fine-tuning specific fonts | All engines |

---

## 7. Font Size & Spacing

### Document Class Sizes

Standard LaTeX classes offer three sizes:

```latex
\documentclass[10pt]{article}  % Small (default)
\documentclass[11pt]{article}  % Medium (recommended for most)
\documentclass[12pt]{article}  % Large (formal documents, theses)
```

### Extended Sizes with extarticle

For non-standard sizes, use the `extarticle` or `extreport` classes:

```latex
\documentclass[8pt]{extarticle}   % Very small
\documentclass[9pt]{extarticle}   % Small
\documentclass[14pt]{extarticle}  % Large
\documentclass[17pt]{extarticle}  % Very large
\documentclass[20pt]{extarticle}  % Huge (posters, presentations)
```

### Custom Font Sizes

For precise size control, use `\fontsize{size}{baselineskip}\selectfont`:

```latex
% Syntax: \fontsize{size in pt}{baseline skip in pt}\selectfont

{\fontsize{14}{18}\selectfont Large text with 18pt baseline}

{\fontsize{8}{10}\selectfont Small text with 10pt baseline}

% Rule of thumb: baseline skip = 1.2 × font size
```

### Relative Size Commands

LaTeX provides relative size commands:

```latex
\tiny           % ~5pt in 10pt document
\scriptsize     % ~7pt
\footnotesize   % ~8pt
\small          % ~9pt
\normalsize     % document default (10/11/12pt)
\large          % ~12pt
\Large          % ~14pt
\LARGE          % ~17pt
\huge           % ~20pt
\Huge           % ~25pt
```

**Usage:**
```latex
{\Large This text is larger}  % Note the braces for grouping
```

### Line Spacing

Control vertical spacing between lines:

```latex
% Using setspace package (recommended)
\usepackage{setspace}

\singlespacing       % 1.0 spacing
\onehalfspacing      % 1.5 spacing (common for theses)
\doublespacing       % 2.0 spacing (manuscripts)

% Custom spacing
\setstretch{1.25}    % 1.25 spacing

% Local changes
\begin{spacing}{1.5}
This paragraph has 1.5 line spacing.
\end{spacing}
```

```latex
% Using linespread (primitive method)
\linespread{1.3}     % 1.3 × default spacing
\selectfont          % Activate the change

% Note: linespread uses different scale than setspace
% linespread{1.3} ≈ onehalfspacing
% linespread{1.6} ≈ doublespacing
```

### Paragraph Spacing

```latex
% Increase space between paragraphs
\setlength{\parskip}{0.5\baselineskip}
\setlength{\parindent}{0pt}  % Remove indentation when using parskip

% Or use parskip package
\usepackage{parskip}  % Adds space, removes indentation automatically
```

### Complete Example

```latex
\documentclass[11pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{newpxtext}
\usepackage{setspace}

% Document-wide 1.15 spacing
\setstretch{1.15}

\begin{document}

% Normal size section
\section{Standard Size}
This is 11pt text with 1.15 line spacing.

% Increase spacing locally
\begin{spacing}{1.5}
\section{Increased Spacing}
This section has 1.5 line spacing, often required for thesis submissions.
\end{spacing}

% Custom size for a block
{\fontsize{14}{18}\selectfont
\section*{Large Section}
This section uses 14pt font with 18pt baseline.
}

% Small print
{\small
\section*{Fine Print}
This section uses the small size relative to the document class.
}

\end{document}
```

---

## 8. CJK Font Setup

Chinese, Japanese, and Korean (CJK) languages require special font packages.

### XeLaTeX/LuaLaTeX (Recommended)

Modern engines handle CJK naturally with system fonts:

```latex
\documentclass{article}
\usepackage{xeCJK}

% Chinese (Simplified)
\setCJKmainfont{Noto Serif CJK SC}
\setCJKsansfont{Noto Sans CJK SC}
\setCJKmonofont{Noto Sans Mono CJK SC}

\begin{document}
中文测试 Chinese test 中英混排
\end{document}
```

#### Chinese Variants

```latex
% Simplified Chinese (mainland China)
\setCJKmainfont{Noto Serif CJK SC}

% Traditional Chinese (Taiwan)
\setCJKmainfont{Noto Serif CJK TC}

% Traditional Chinese (Hong Kong)
\setCJKmainfont{Noto Serif CJK HK}

% Alternative fonts
\setCJKmainfont{Source Han Serif SC}  % Adobe's font
\setCJKmainfont{FandolSong}           % Free font in TeX Live
```

#### Japanese

```latex
\usepackage{xeCJK}
\setCJKmainfont{Noto Serif CJK JP}
\setCJKsansfont{Noto Sans CJK JP}

% Alternative fonts
\setCJKmainfont{Source Han Serif JP}  % Adobe
\setCJKmainfont{IPAMincho}            % Free Japanese font
```

#### Korean

```latex
\usepackage{xeCJK}
\setCJKmainfont{Noto Serif CJK KR}
\setCJKsansfont{Noto Sans CJK KR}

% Alternative fonts
\setCJKmainfont{Source Han Serif KR}
\setCJKmainfont{Baekmuk Batang}       % Free Korean font
```

### Mixed CJK Languages

```latex
\documentclass{article}
\usepackage{xeCJK}

% Default CJK font
\setCJKmainfont{Noto Serif CJK SC}

% Specific language fonts
\newCJKfontfamily\chinesefont{Noto Serif CJK SC}
\newCJKfontfamily\japanesefont{Noto Serif CJK JP}
\newCJKfontfamily\koreanfont{Noto Serif CJK KR}

\begin{document}
English text.

{\chinesefont 中文文本}

{\japanesefont 日本語テキスト}

{\koreanfont 한국어 텍스트}
\end{document}
```

### pdfLaTeX CJK (Legacy)

For pdfLaTeX (not recommended, limited font support):

```latex
\documentclass{article}
\usepackage{CJKutf8}

\begin{document}
\begin{CJK}{UTF8}{gbsn}  % Simplified Chinese
中文测试
\end{CJK}

\begin{CJK}{UTF8}{bsmi}  % Traditional Chinese
中文測試
\end{CJK}

\begin{CJK}{UTF8}{min}   % Japanese
日本語テキスト
\end{CJK}
\end{document}
```

### Complete CJK Example

```latex
\documentclass[12pt]{article}
\usepackage{xeCJK}
\usepackage{fontspec}

% English fonts
\setmainfont{TeX Gyre Pagella}

% CJK fonts
\setCJKmainfont{Noto Serif CJK SC}[
  BoldFont=Noto Serif CJK SC Bold,
  ItalicFont=AR PL KaitiM GB  % Kaiti style for emphasis
]
\setCJKsansfont{Noto Sans CJK SC}
\setCJKmonofont{Noto Sans Mono CJK SC}

\begin{document}

\section{Introduction 介绍}

This document demonstrates CJK and English mixing.
本文档展示中英文混合排版。

\textbf{Bold text 粗体文本}

\textsf{Sans-serif 无衬线字体}

\texttt{Monospace 等宽字体}

\end{document}
```

---

## 9. Common Font Problems & Solutions

### Problem: "Font X not found"

**Symptoms:**
```
! Font \TU/FiraCode/m/n/10=FiraCode at 10pt not loadable
```

**Cause:** Font not installed on the system (XeLaTeX/LuaLaTeX) or package not installed (pdfLaTeX).

**Solutions:**

For XeLaTeX/LuaLaTeX:
```bash
# List available fonts
fc-list | grep "Fira"

# Install fonts (Ubuntu/Debian)
sudo apt install fonts-firacode

# Install fonts (macOS)
brew install --cask font-fira-code

# Or download and install manually to:
# - Linux: ~/.fonts/ or /usr/share/fonts/
# - macOS: ~/Library/Fonts/ or /Library/Fonts/
# - Windows: C:\Windows\Fonts\
```

For pdfLaTeX:
```bash
# Install package via TeX Live manager
tlmgr install firacode

# Or via Linux package manager
sudo apt install texlive-fonts-extra
```

### Problem: "Missing character" warnings

**Symptoms:**
```
Missing character: There is no é in font cmr10!
```

**Cause:** Font doesn't contain the character, or wrong encoding.

**Solutions:**

```latex
% pdfLaTeX: Use T1 encoding and inputenc
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}

% XeLaTeX/LuaLaTeX: Already supports Unicode
\usepackage{fontspec}

% If character still missing, use a font with better coverage
\usepackage{lmodern}  % Latin Modern has extended characters
% OR
\setmainfont{DejaVu Serif}  % Extensive Unicode coverage
```

### Problem: Font Substitution

**Symptoms:**
```
LaTeX Font Warning: Font shape `T1/cmr/bx/sc' undefined
(Font)              using `T1/cmr/bx/n' instead
```

**Cause:** Requested font variation (e.g., bold small caps) doesn't exist.

**Solutions:**

```latex
% 1. Choose a font family with more variations
\usepackage{newpxtext}  % Palatino has bold small caps

% 2. Or accept the substitution
% LaTeX will use available variant automatically

% 3. Or fake it (not recommended)
\usepackage{fontspec}
\setmainfont{Some Font}[
  SmallCapsFont = Some Font,
  SmallCapsFeatures = {Letters=SmallCaps}
]
```

### Problem: Bold Not Available (Faux Bold)

**Symptoms:**
```
LaTeX Font Warning: Font shape `TU/SomeFont/b/n' undefined
(Font)              using `TU/SomeFont/m/n' instead
```

**Cause:** Font family doesn't include a bold variant.

**Solutions:**

```latex
% 1. Manually specify bold font
\setmainfont{Some Font}[
  BoldFont = Some Bold Font,  % Use different font for bold
]

% 2. Allow synthetic (fake) bold (not recommended for print)
\setmainfont{Some Font}[
  BoldFont = Some Font,
  BoldFeatures = {FakeBold=1.5}
]

% 3. Use a complete font family
\setmainfont{TeX Gyre Pagella}  % Has all variants
```

### Problem: Math Symbols Missing

**Symptoms:** Math symbols appear blank or wrong.

**Cause:** Text font changed but math font not updated.

**Solutions:**

```latex
% pdfLaTeX: Use matching math package
\usepackage{newpxtext}
\usepackage{newpxmath}  % Must match!

% XeLaTeX/LuaLaTeX: Use unicode-math
\usepackage{unicode-math}
\setmainfont{TeX Gyre Pagella}
\setmathfont{TeX Gyre Pagella Math}
```

### Problem: Encoding Issues with Special Characters

**Symptoms:** Special characters (é, ñ, ü) appear wrong or cause errors.

**Cause:** File encoding doesn't match LaTeX encoding.

**Solutions:**

```latex
% pdfLaTeX: Ensure UTF-8 encoding
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}

% Save your .tex file as UTF-8 (no BOM) in your editor

% XeLaTeX/LuaLaTeX: UTF-8 by default, no inputenc needed
\usepackage{fontspec}
```

### Problem: Ligatures Not Working

**Symptoms:** "fi" and "fl" combinations don't form ligatures.

**Cause:** Ligatures disabled or wrong font encoding.

**Solutions:**

```latex
% pdfLaTeX: Use T1 encoding
\usepackage[T1]{fontenc}

% XeLaTeX/LuaLaTeX: Enable ligatures
\setmainfont{TeX Gyre Pagella}[
  Ligatures=TeX  % Enable TeX ligatures (-- --- `` '')
]

% Disable for monospace fonts
\setmonofont{Fira Code}[
  Ligatures=NoCommon  % Disable in code
]
```

### Problem: Poor Quality PDF Fonts

**Symptoms:** Fonts look blurry or pixelated in PDF.

**Cause:** Using bitmap fonts instead of vector fonts.

**Solutions:**

```latex
% Use vector fonts (Type 1 or OpenType)
\usepackage{lmodern}  % Latin Modern (vector)
% NOT the default Computer Modern (bitmap)

% Check in PDF viewer: zoom to 400%
% Vector fonts stay sharp, bitmap fonts pixelate

% For pdfLaTeX, ensure:
\usepackage[T1]{fontenc}  % T1 encoding uses vector fonts
```

---

## 10. Quick Reference: Font → Package Mapping

Fast lookup table for common fonts and their LaTeX packages.

### Serif Fonts (pdfLaTeX)

| Font Name | Package | Math Support | Notes |
|-----------|---------|--------------|-------|
| Palatino | `newpxtext,newpxmath` | Yes | Modern, complete, recommended |
| Palatino | `mathpazo` | Yes | Classic, older version |
| Times | `newtxtext,newtxmath` | Yes | Modern Times implementation |
| Times | `mathptmx` | Yes | Legacy, use newtxtext instead |
| Latin Modern | `lmodern` | Yes (default) | Extended Computer Modern |
| Garamond | `ebgaramond` | Partial | Use with adapted math font |
| Baskerville | `librebaskerville` | No | Pair with adapted math |
| Charter | `[charter]{mathdesign}` | Yes | Good for tech documents |
| Utopia | `fourier` | Yes | Generous x-height |
| Libertinus | `libertinus` | Yes | Modern, open source, excellent |
| Cochineal | `cochineal` + newtxmath | Yes | Crimson-like, warm |
| Bookman | `bookman` | No | Wide, readable |
| Century | `century` | No | Traditional |
| Concrete | `ccfonts` + `eulervm` | Yes | Knuth's design |

### Sans-Serif Fonts (pdfLaTeX)

| Font Name | Package | Notes |
|-----------|---------|-------|
| Roboto | `[sfdefault]{roboto}` | Google's geometric humanist |
| Fira Sans | `[sfdefault]{FiraSans}` | Mozilla, modern |
| Noto Sans | `[sfdefault]{noto-sans}` | Google, multilingual |
| Source Sans | `[default]{sourcesanspro}` | Adobe's humanist sans |
| Cabin | `[sfdefault]{cabin}` | Gill Sans inspired |
| Montserrat | `[defaultfam]{montserrat}` | Geometric sans |
| Raleway | `[default]{raleway}` | Elegant, thin available |
| Lato | `[default]{lato}` | Humanist, corporate-friendly |
| Helvetica | `helvet` | Classic neutral sans |
| Avant Garde | `avant` | Geometric, rounded |

### Monospace Fonts (pdfLaTeX)

| Font Name | Package | Notes |
|-----------|---------|-------|
| Inconsolata | `[scaled=0.95]{inconsolata}` | Most popular for code |
| Fira Mono | `[scale=0.9]{FiraMono}` | Pairs with Fira Sans |
| Source Code Pro | `[scale=0.9]{sourcecodepro}` | Adobe, generous spacing |
| Anonymous Pro | `[ttdefault]{anonymous-pro}` | Distinct characters |
| DejaVu Sans Mono | `{DejaVuSansMono}` | Wide Unicode support |
| Courier | `courier` | Classic typewriter |

### XeLaTeX/LuaLaTeX System Fonts

| Font Family | Main Font | Sans Font | Mono Font |
|-------------|-----------|-----------|-----------|
| TeX Gyre (Free) | TeX Gyre Pagella | TeX Gyre Heros | TeX Gyre Cursor |
| TeX Gyre (Free) | TeX Gyre Termes | TeX Gyre Heros | TeX Gyre Cursor |
| Libertinus (Free) | Libertinus Serif | Libertinus Sans | Libertinus Mono |
| Source (Adobe) | Source Serif Pro | Source Sans Pro | Source Code Pro |
| Noto (Google) | Noto Serif | Noto Sans | Noto Sans Mono |
| Fira (Mozilla) | Fira Serif | Fira Sans | Fira Mono |

### Math Fonts

| Math Style | Package (pdfLaTeX) | OpenType Font (XeLaTeX/LuaLaTeX) |
|------------|-------------------|----------------------------------|
| Computer Modern | Default or `lmodern` | Latin Modern Math |
| Palatino | `newpxmath` | TeX Gyre Pagella Math |
| Times | `newtxmath` | TeX Gyre Termes Math |
| Libertinus | `libertinus` | Libertinus Math |
| Euler (upright) | `eulervm` | - |
| STIX | `stix2` | STIX Two Math |

### Font Package Installation Commands

```bash
# TeX Live (Linux/macOS)
tlmgr install <package-name>
tlmgr install collection-fontsrecommended
tlmgr install collection-fontsextra

# Ubuntu/Debian
sudo apt install texlive-fonts-recommended
sudo apt install texlive-fonts-extra

# System fonts for XeLaTeX/LuaLaTeX
# Ubuntu/Debian
sudo apt install fonts-noto fonts-firacode fonts-roboto

# macOS (Homebrew)
brew install --cask font-fira-code
brew install --cask font-source-sans-pro
```

---

## Summary

This guide covers the essential aspects of font selection in LaTeX:

1. **Understand font basics**: Family, series, and shape axes
2. **Choose the right engine**: pdfLaTeX (packages) vs XeLaTeX/LuaLaTeX (system fonts)
3. **Pair fonts harmoniously**: Match text and math fonts by style and metrics
4. **Use microtype**: Professional typography with minimal effort
5. **Configure properly**: Set sizes, spacing, and encodings correctly
6. **Solve problems**: Know how to diagnose and fix common font issues

For most users:
- **Academic documents**: `newpxtext` + `newpxmath` (Palatino)
- **Technical documents**: `[sfdefault]{FiraSans}` (modern sans)
- **Modern workflow**: XeLaTeX + `fontspec` + system fonts
- **Always add**: `\usepackage{microtype}`

Remember: Good typography is invisible. The best font choice is one that serves the content without drawing attention to itself.
