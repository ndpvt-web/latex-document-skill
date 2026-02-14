# ATS-Optimized Resume Guide for LaTeX

## Table of Contents
- [ATS Overview](#ats-overview)
- [LaTeX-Specific ATS Rules](#latex-specific-ats-rules)
- [ATS-Safe Section Headings](#ats-safe-section-headings)
- [Resume Format Selection Guide](#resume-format-selection-guide)
- [Keyword Optimization](#keyword-optimization)
- [Formatting Rules](#formatting-rules)
- [Common LaTeX ATS Mistakes](#common-latex-ats-mistakes)
- [Quantified Achievement Patterns](#quantified-achievement-patterns)
- [Action Verbs by Category](#action-verbs-by-category)

---

## ATS Overview

**Critical Context**: 98% of Fortune 500 companies use Applicant Tracking Systems (ATS). Your resume must pass ATS parsing before human eyes see it.

**Major ATS Systems**:
- Workday (most common)
- Greenhouse
- Lever
- Taleo (Oracle)
- iCIMS
- BambooHR
- SmartRecruiters

**ATS Parsing Pipeline**:
1. **Text Extraction**: Converts PDF to plain text (quality varies by system)
2. **Field Identification**: Attempts to identify name, contact info, sections
3. **Keyword Matching**: Compares extracted text against job description keywords
4. **Scoring/Ranking**: Assigns match percentage and ranks candidates

**Failure Points**: Complex layouts, embedded graphics, text in images, unusual fonts, multi-column formats.

---

## LaTeX-Specific ATS Rules

### DO: ATS-Safe LaTeX Practices

1. **Single-Column Layout**: Use standard linear top-to-bottom flow
   ```latex
   \documentclass{article}
   \begin{document}
   Name and contact info here
   \section{Experience}
   \section{Education}
   \end{document}
   ```

2. **Standard Document Class**: Use `article` or `report` class
   ```latex
   \documentclass[11pt,letterpaper]{article}
   ```

3. **Contact Info in Body**: Place directly in document body, not headers
   ```latex
   \begin{center}
   {\LARGE\bfseries John Doe} \\[4pt]
   john.doe@email.com $|$ (555) 123-4567 $|$ linkedin.com/in/johndoe
   \end{center}
   ```

4. **Use \section for Headings**: Standard LaTeX sections for clear structure
   ```latex
   \section*{Experience}
   \section*{Education}
   \section*{Skills}
   ```

5. **Bullet Points with itemize**: Standard list environment
   ```latex
   \begin{itemize}
     \item Reduced API latency by 40%
     \item Led team of 8 engineers
   \end{itemize}
   ```

6. **Standard Fonts**: Stick to widely-supported fonts
   - Computer Modern (default LaTeX)
   - Latin Modern: `\usepackage{lmodern}`
   - Helvetica: `\usepackage{helvet}` + `\renewcommand{\familydefault}{\sfdefault}`

### DO NOT: ATS-Breaking LaTeX Patterns

1. **NO Multi-Column with minipage**: Creates side-by-side layout ATS can't parse
   ```latex
   % AVOID THIS:
   \begin{minipage}[t]{0.5\textwidth}
   Left column content
   \end{minipage}
   \begin{minipage}[t]{0.5\textwidth}
   Right column content
   \end{minipage}
   ```

2. **NO Tables for Layout**: Tables (tabularx, tabular) confuse field extraction
   ```latex
   % AVOID FOR MAIN LAYOUT:
   \begin{tabularx}{\textwidth}{X X}
   Content & Content
   \end{tabularx}
   ```
   **Exception**: Simple skills list in single row may be acceptable

3. **NO Graphics/TikZ**: Images, logos, profile pictures are ignored or break parsing
   ```latex
   % AVOID:
   \includegraphics[width=2cm]{photo.jpg}
   \begin{tikzpicture}...\end{tikzpicture}
   ```

4. **NO Header/Footer Content**: Info in `\pagestyle{fancy}` is often missed
   ```latex
   % AVOID:
   \usepackage{fancyhdr}
   \fancyhead[L]{John Doe}
   ```

5. **NO Excessive Colored Hyperlinks**: Some ATS strip links; use sparingly
   ```latex
   % USE CAUTIOUSLY:
   \usepackage[colorlinks=true]{hyperref}
   % BETTER:
   \usepackage[hidelinks]{hyperref}
   ```

6. **NO Custom Font Packages**: fontspec, custom TTF/OTF fonts may not embed
   ```latex
   % AVOID:
   \usepackage{fontspec}
   \setmainfont{CustomFont}
   ```

7. **NO Color Fills/Backgrounds**: `\rowcolor`, `\cellcolor`, colored boxes
   ```latex
   % AVOID:
   \usepackage[table]{xcolor}
   \rowcolor{gray}
   ```

---

## ATS-Safe Section Headings

ATS systems are trained to recognize standard section names. Use these exact headings:

### Recognized Headings (USE THESE):

- **Professional Summary** or **Summary** or **Profile**
- **Experience** or **Work Experience** or **Professional Experience**
- **Education** or **Academic Credentials**
- **Skills** or **Technical Skills** or **Core Competencies**
- **Certifications** or **Licenses & Certifications**
- **Projects** or **Key Projects**
- **Awards** or **Honors & Awards**
- **Publications**
- **Volunteer Experience** or **Community Involvement**

### Non-Standard Headings (AVOID):

- "About Me" (use "Summary")
- "Who I Am" (use "Summary")
- "My Journey" (use "Experience")
- "Career Path" (use "Experience")
- "What I Can Do" (use "Skills")
- "Academic Background" (use "Education")
- "Where I've Worked" (use "Experience")

**Rule**: If you wouldn't find the heading in a 1990s resume book, don't use it.

---

## Resume Format Selection Guide

| Template | Best For | Key Features | ATS Rating | Page Limit |
|----------|----------|--------------|------------|------------|
| **resume-classic-ats** | Conservative industries (finance, law, government, healthcare) | Maximum simplicity, zero graphics, chronological | 10/10 | 1-2 pages |
| **resume-modern-professional** | Tech, corporate, consulting, marketing | Clean design, subtle dividers, balanced visuals | 9/10 | 1-2 pages |
| **resume-executive** | Senior/C-suite, 15+ years experience | Multi-page, leadership focus, board experience | 8/10 | 2-3 pages |
| **resume-technical** | Software engineers, data scientists, DevOps | Skills-first hybrid, dedicated projects section | 9/10 | 1-2 pages |
| **resume-entry-level** | Recent graduates, career changers, <2 years exp | Education-first, relevant coursework, internships | 9/10 | 1 page |

### Decision Tree:

1. **Are you applying to finance/law/government?** → Use `resume-classic-ats`
2. **Do you have <2 years experience?** → Use `resume-entry-level`
3. **Are you a senior executive (VP+)?** → Use `resume-executive`
4. **Are you in technical role (engineering, data)?** → Use `resume-technical`
5. **Everything else** → Use `resume-modern-professional`

---

## Keyword Optimization

### Strategy 1: Mirror Job Description Language

**Example Job Description**: "Looking for Senior Software Engineer with expertise in React, Node.js, and AWS cloud infrastructure..."

**Your Resume Should Include**:
- Exact phrase "React" (not just "JavaScript frameworks")
- Exact phrase "Node.js" (not just "backend development")
- Exact phrase "AWS cloud infrastructure" (not just "cloud computing")

### Strategy 2: Acronyms + Spelled-Out Forms

Always include both versions:

- "Search Engine Optimization (SEO)"
- "Application Programming Interface (API)"
- "Continuous Integration/Continuous Deployment (CI/CD)"
- "Customer Relationship Management (CRM)"
- "Key Performance Indicator (KPI)"

### Strategy 3: Context Keywords in Experience

Don't just list keywords in Skills section. Integrate them into Experience bullets:

**Bad**:
```
Skills: Python, Machine Learning, TensorFlow
Experience:
- Developed predictive models for customer churn
```

**Good**:
```
Skills: Python, Machine Learning, TensorFlow, Scikit-learn
Experience:
- Developed machine learning models in Python using TensorFlow and Scikit-learn, reducing customer churn by 23%
```

### Strategy 4: Industry-Specific Certifications

Include certification keywords: "AWS Certified Solutions Architect", "PMP", "CPA", "Six Sigma Black Belt"

### What NOT to Do:

- **Keyword Stuffing**: Don't add invisible white text or repeat keywords 50 times
- **Irrelevant Keywords**: Don't claim skills you don't have just because they're in the JD
- **Over-Abbreviation**: Don't assume ATS knows "GCP" means "Google Cloud Platform"

---

## Formatting Rules

### Font Specifications

- **Body Text**: 10-12pt (11pt is optimal)
- **Name**: 14-18pt (16pt recommended)
- **Section Headings**: 12-14pt
- **Font Family**: Computer Modern, Latin Modern, Helvetica, Times New Roman

### Margin Specifications

- **Minimum**: 0.5 inches (0.5in) on all sides
- **Recommended**: 0.5in-0.75in
- **Never**: <0.5in (content may be cut off)

LaTeX code:
```latex
\usepackage[margin=0.75in]{geometry}
% or
\usepackage[top=0.75in, bottom=0.75in, left=0.5in, right=0.5in]{geometry}
```

### File Naming Convention

**Format**: `FirstName_LastName_Resume.pdf`

**Examples**:
- `John_Doe_Resume.pdf` (correct)
- `Jane_Smith_Resume.pdf` (correct)
- `resume.pdf` (BAD)
- `JD_Resume_2026.pdf` (BAD - don't use initials or dates)

### Page Length Guidelines

| Experience Level | Page Count | Rule |
|------------------|------------|------|
| 0-5 years | 1 page | Strict |
| 5-10 years | 1-2 pages | 2 pages if strong justification |
| 10-15 years | 2 pages | Standard |
| 15+ years / Executive | 2-3 pages | Leadership focus |

### Bullet Point Rules

1. **Start with Action Verb**: "Led", "Developed", "Increased" (not "Responsible for")
2. **Include Metrics**: Quantify impact with numbers, percentages, dollar amounts
3. **Length**: 1-2 lines per bullet (never >2 lines)
4. **Count**: 3-5 bullets per job (most recent jobs get 5, older jobs get 3)

### Date Formats

**Standard**: `Month Year - Month Year` or `MM/YYYY - MM/YYYY`

**Examples**:
- `January 2023 - Present`
- `01/2023 - Present`
- `Jan 2023 - Dec 2025`

**Avoid**:
- `2023-2025` (too vague)
- `1/23 - 12/25` (ambiguous)

---

## Common LaTeX ATS Mistakes

### Mistake #1: Two-Column Header with minipage

**Problem**:
```latex
\begin{minipage}[t]{0.5\textwidth}
John Doe \\
Senior Engineer
\end{minipage}%
\begin{minipage}[t]{0.5\textwidth}
\raggedleft
john@email.com \\
(555) 123-4567
\end{minipage}
```

**Solution**: Linear layout
```latex
\begin{center}
{\LARGE\bfseries John Doe} \\[4pt]
Senior Software Engineer \\[4pt]
john@email.com $|$ (555) 123-4567 $|$ linkedin.com/in/johndoe
\end{center}
```

### Mistake #2: Skills Grid with tabularx

**Problem**:
```latex
\begin{tabularx}{\textwidth}{X X X}
Python & React & AWS \\
Docker & PostgreSQL & Git
\end{tabularx}
```

**Solution**: Comma-separated or bulleted list
```latex
\textbf{Languages:} Python, JavaScript, Java, SQL \\
\textbf{Frameworks:} React, Node.js, Django, Flask \\
\textbf{Cloud:} AWS (EC2, S3, Lambda), Azure, GCP
```

### Mistake #3: Profile Photo with includegraphics

**Problem**:
```latex
\includegraphics[width=3cm]{profile.jpg}
```

**Solution**: Remove entirely. Photos are not ATS-friendly and can introduce bias.

### Mistake #4: Contact Info in fancyhdr

**Problem**:
```latex
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhead[L]{John Doe}
\fancyhead[R]{john@email.com}
```

**Solution**: Put contact info in document body (see Mistake #1 solution)

### Mistake #5: Colored Section Dividers

**Problem**:
```latex
\usepackage{xcolor}
\section*{{\color{blue}Experience}}
\textcolor{gray}{\hrulefill}
```

**Solution**: Keep it simple
```latex
\section*{Experience}
```

### Mistake #6: Custom Fonts

**Problem**:
```latex
\usepackage{fontspec}
\setmainfont{Montserrat}
```

**Solution**: Use standard fonts
```latex
\usepackage{lmodern}
```

### Mistake #7: Unescaped Special Characters

**Problem**: Using `&`, `%`, `$`, `#` without escaping

**Solution**: Escape them: `\&`, `\%`, `\$`, `\#`

---

## Quantified Achievement Patterns

### Formula: Verb + Action + Metric

**Template**: `[Action Verb] + [what you did] + [quantified result/impact]`

### Examples by Category:

#### Leadership
- "Led team of 8 engineers to deliver $2M project 3 weeks ahead of schedule"
- "Managed cross-functional team of 12 across 3 time zones, improving delivery velocity by 35%"
- "Mentored 5 junior developers, resulting in 100% promotion rate within 18 months"

#### Technical Achievement
- "Reduced API latency by 40% by implementing Redis caching layer"
- "Optimized database queries, improving page load time from 3.2s to 0.8s (75% reduction)"
- "Architected microservices infrastructure serving 10M+ daily active users"

#### Business Impact
- "Increased revenue by $1.2M annually through conversion rate optimization (15% improvement)"
- "Reduced customer churn by 23% via predictive machine learning model"
- "Cut infrastructure costs by $150K/year by migrating to containerized architecture"

#### Process Improvement
- "Automated deployment pipeline, reducing release time from 4 hours to 15 minutes"
- "Established CI/CD best practices, increasing deployment frequency from weekly to daily"
- "Implemented code review standards, reducing production bugs by 62%"

#### Scale/Volume
- "Built data pipeline processing 5TB daily across 200+ data sources"
- "Designed RESTful API handling 50K requests/second with 99.99% uptime"
- "Migrated 2.5M user accounts to new authentication system with zero downtime"

### Metrics Checklist

When writing bullets, include at least ONE of these:
- **Percentage**: "increased by X%", "reduced by Y%"
- **Dollar Amount**: "$X revenue", "$Y cost savings"
- **Time Savings**: "reduced from X hours to Y minutes"
- **Scale**: "X million users", "Y terabytes"
- **Team Size**: "led team of X"
- **Frequency**: "from X per week to Y per day"

---

## Action Verbs by Category

### Leadership & Management
Chaired, Coordinated, Delegated, Directed, Drove, Executed, Guided, Headed, Led, Managed, Mentored, Orchestrated, Oversaw, Piloted, Spearheaded, Supervised

### Technical & Engineering
Architected, Automated, Built, Coded, Compiled, Debugged, Deployed, Designed, Developed, Engineered, Implemented, Integrated, Migrated, Optimized, Programmed, Refactored, Resolved, Scaled

### Analysis & Strategy
Analyzed, Assessed, Audited, Calculated, Evaluated, Examined, Forecasted, Identified, Investigated, Measured, Modeled, Projected, Quantified, Researched, Tested, Validated

### Achievement & Results
Achieved, Accelerated, Exceeded, Generated, Improved, Increased, Maximized, Outperformed, Reduced, Saved, Surpassed, Transformed

### Communication & Collaboration
Collaborated, Communicated, Coordinated, Presented, Documented, Facilitated, Interfaced, Liaised, Negotiated, Partnered

### Creation & Innovation
Authored, Created, Designed, Established, Formulated, Founded, Initiated, Innovated, Introduced, Invented, Launched, Pioneered

### Organization & Process
Consolidated, Organized, Planned, Prioritized, Restructured, Standardized, Streamlined, Systematized

---

## ATS Testing Checklist

Before submitting your resume, verify:

- [ ] Single-column layout (no side-by-side sections)
- [ ] Contact info in document body (not header/footer)
- [ ] Standard section headings from approved list
- [ ] No tables used for layout
- [ ] No images, graphics, or photos
- [ ] Standard fonts only (Computer Modern, Latin Modern, Helvetica)
- [ ] Font size 10-12pt for body text
- [ ] Margins ≥0.5in on all sides
- [ ] Keywords from job description present
- [ ] Acronyms spelled out on first use
- [ ] Every bullet starts with action verb
- [ ] At least 80% of bullets include metrics
- [ ] File named `FirstName_LastName_Resume.pdf`
- [ ] Page count appropriate for experience level

---

**Last Updated**: February 2026
**Recommended Review**: Before each resume generation or major template update
