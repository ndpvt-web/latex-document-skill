# PDF-to-Cheatsheet: LLM Prompt Templates

Ready-to-use prompts for each stage of extracting content from large academic PDFs and compressing into cheat sheets.

---

## Stage 1: Document Structure Analysis

### Prompt: Build Structure Map
```
You are analyzing an academic document to create a cheat sheet. This is the beginning of a [PAGES]-page document.

Analyze the content and produce a structured outline:

For each chapter/major section:
- Title
- Approximate page range
- Key topics covered
- Content type: THEORY | APPLIED | EXAMPLES | EXERCISES | REFERENCE
- Importance for exams: HIGH | MEDIUM | LOW

Importance signals:
- Boxed content, numbered theorems = HIGH
- Worked examples showing techniques = MEDIUM
- Historical context, motivation = LOW
- End-of-chapter summaries = HIGH (professor-curated)

Output as a structured list. Be thorough.
```

---

## Stage 2: Content Extraction

### Prompt: Mathematics (Calculus, Linear Algebra, Analysis)
```
Extract ALL exam-relevant content from this mathematics section. Be exhaustive.

EXTRACT:
1. **Formulas**: Every equation, with all variables defined
2. **Theorems**: Name + formal statement + conditions for applicability
3. **Definitions**: Term + precise mathematical definition
4. **Lemmas/Corollaries**: Statement + which theorem they support
5. **Proof techniques**: Name + core trick (not full proof)
6. **Common pitfalls**: Mistakes students frequently make

FORMAT each item as:
[TYPE] Name/Label
Content in LaTeX: $...$
When to use: (one line)
Prerequisites: (what must be known)

PRESERVE all LaTeX mathematical notation exactly as written.
Use \frac, \sum, \int, \lim, etc. for all math expressions.
SKIP: motivational text, history, lengthy explanations, full proofs.
```

### Prompt: Computer Science (Algorithms, Data Structures, Theory)
```
Extract ALL exam-relevant content from this computer science section. Be exhaustive.

EXTRACT:
1. **Algorithms**: Name, key steps (compact pseudocode), time complexity O(...), space complexity
2. **Data structures**: Operations with complexities, when to use each
3. **Theorems**: Formal statements (especially: NP-completeness, decidability, lower bounds)
4. **Definitions**: Precise CS definitions (e.g., "a graph G is bipartite iff...")
5. **Comparison tables**: X vs Y (e.g., BFS vs DFS, array vs linked list)
6. **Design patterns**: Name + when to apply + core idea

FORMAT:
- Algorithms as numbered step-lists (max 5-7 steps)
- Complexities in Big-O notation
- Tables as | col1 | col2 | col3 | format

SKIP: implementation details, code in specific languages (keep pseudocode), long proofs.
```

### Prompt: Physics (Mechanics, E&M, Quantum, Thermo)
```
Extract ALL exam-relevant content from this physics section. Be exhaustive.

EXTRACT:
1. **Equations**: In standard form with SI units for EVERY variable
2. **Laws/Principles**: Name + equation + applicability conditions
3. **Constants**: Symbol, value, units (e.g., $c = 3 \times 10^8$ m/s)
4. **Approximations**: When valid (e.g., "for $v \ll c$", "small angle: $\sin\theta \approx \theta$")
5. **Sign conventions**: Which direction is positive, reference frames
6. **Key relationships**: How quantities relate (e.g., "F and a are in same direction")

FORMAT:
- Each equation on its own line with variable legend
- Note which form to use when (e.g., "use $F=qv\times B$ for moving charges")
- Group by topic (e.g., Kinematics, Dynamics, Energy)

SKIP: derivations (unless the derivation technique itself is testable), history.
```

### Prompt: Chemistry (Organic, Inorganic, Physical)
```
Extract ALL exam-relevant content from this chemistry section. Be exhaustive.

EXTRACT:
1. **Reactions**: Reactants → Products, with conditions (catalyst, temperature, solvent)
2. **Mechanisms**: Step-by-step with arrow notation (nucleophilic attack, etc.)
3. **Equilibrium expressions**: Ka, Kb, Ksp, Kw with formulas
4. **Nomenclature rules**: IUPAC naming conventions, functional group priorities
5. **Periodic trends**: Electronegativity, atomic radius, ionization energy patterns
6. **Constants**: Gas constant R, Avogadro's number, Faraday constant, etc.

FORMAT:
- Reactions: A + B → C + D (conditions above arrow)
- Mechanisms: numbered steps
- Use standard chemistry notation

SKIP: historical discovery, detailed lab procedures.
```

### Prompt: Biology (Molecular, Genetics, Ecology)
```
Extract ALL exam-relevant content from this biology section. Be exhaustive.

EXTRACT:
1. **Processes/Cycles**: Stage-by-stage (e.g., "Krebs: 1) Acetyl-CoA + OAA → Citrate, 2)...")
2. **Pathways**: Input → [steps] → Output, with key enzymes
3. **Classifications**: Taxonomic hierarchies, domain/kingdom/phylum
4. **Comparative tables**: Feature comparison (e.g., DNA vs RNA, mitosis vs meiosis)
5. **Key molecules**: Name, function, location
6. **Regulatory mechanisms**: What activates/inhibits what

FORMAT:
- Cycles as numbered stage-lists
- Pathways as: Input →(enzyme)→ Intermediate →(enzyme)→ Output
- Comparisons as tables

SKIP: detailed experimental methods, case studies.
```

### Prompt: Statistics & Probability
```
Extract ALL exam-relevant content from this statistics/probability section. Be exhaustive.

EXTRACT:
1. **Distributions**: Name, PDF/PMF formula, mean, variance, when to use
2. **Formulas**: All statistical formulas (mean, variance, std dev, correlation, regression)
3. **Theorems**: CLT, LLN, Bayes' theorem, etc. with formal statements
4. **Test procedures**: Name, null hypothesis form, test statistic, rejection rule
5. **Assumptions**: What each test requires (normality, independence, etc.)
6. **Tables**: Critical values, common distribution parameters

FORMAT:
- Distributions: Name | $f(x) = ...$ | $E[X] = ...$ | $Var(X) = ...$ | Use when: ...
- Tests: Name | $H_0$ | Test stat | Reject when | Assumptions

SKIP: lengthy examples, simulation descriptions.
```

### Prompt: Engineering (General)
```
Extract ALL exam-relevant content from this engineering section. Be exhaustive.

EXTRACT:
1. **Design equations**: With all variables, units, and applicable standards
2. **Procedures**: Step-by-step design/analysis methods
3. **Safety factors**: Required values for different scenarios
4. **Material properties**: Tables of values (yield strength, modulus, etc.)
5. **Code references**: AISC, ASME, NEC, etc. with relevant clause numbers
6. **Conversion factors**: Between unit systems

FORMAT:
- Equations with units explicitly stated
- Procedures as numbered checklists
- Reference values in tables

SKIP: detailed case studies, historical context.
```

---

## Stage 3: Content Compression

### Prompt: Compress to Cheat Sheet Density
```
You have [N] extracted items for a cheat sheet. The target is 2 pages (approximately 60-80 items, ~1000 words of content).

Current items:
[INSERT ALL EXTRACTED ITEMS HERE]

Tasks:
1. RANK all items by exam-lookup-probability (how likely a student needs this during an exam)
2. MERGE items that are redundant or highly related (e.g., multiple forms of same equation)
3. COMPRESS each item to minimum words while preserving meaning:
   - Definitions: one-line maximum
   - Formulas: just the equation + variable legend
   - Theorems: statement + conditions only
   - Procedures: max 5 numbered steps
4. CUT lowest-priority items to hit the page target
5. ORGANIZE remaining items by topic in logical lookup order

Apply these compression techniques:
- Use symbols: → ⇒ ∀ ∃ ⇔ ∴ s.t. iff wrt
- Eliminate filler: "is defined as" → ":", "it follows that" → "⇒"
- Inline short equations instead of display mode
- Stack related formulas horizontally where possible

Output: The final compressed content, organized by section, ready for LaTeX formatting.
```

### Prompt: Convert to LaTeX Format
```
Convert this cheat sheet content into LaTeX using the [exam/general/code] template format.

Template environments available:
- \sheetsection{Title} — major section headers
- \sheetsubsection{Title} — subsection headers
- \begin{thmbox}{Name} — for theorems (most important results)
- \begin{defbox}{Name} — for definitions
- \begin{formulabox}{Name} — for formulas/equations
- \begin{procbox}{Name} — for procedures/algorithms

Rules:
- NO blank lines between consecutive box environments
- Use $...$ for inline math, \begin{align*} for display math
- Use \tfrac not \frac in inline math
- Use \textstyle in align* environments for compact math
- Use \hfill to put two short formulas on one line
- Use @{} in tabular column specs to remove padding
- Keep variable definitions on same line as formula where possible
- Use \fontsize{5.5pt}{6.5pt}\selectfont for less-critical content

Content to format:
[INSERT COMPRESSED CONTENT HERE]

Output: Complete LaTeX code for the content area (between \begin{multicols} and \end{multicols}).
```

---

## Stage 4: Quality & Space Management

### Prompt: Verify Mathematical Correctness
```
Review these LaTeX math expressions for correctness:

[INSERT ALL MATH EXPRESSIONS]

For each expression, check:
1. Is the LaTeX syntax valid? (matching braces, proper commands)
2. Is the mathematical content correct? (signs, indices, limits)
3. Are variable definitions consistent across the document?
4. Are there any missing conditions or constraints?

Report any errors found with corrections.
```

### Prompt: Space Budget Check
```
This cheat sheet content must fit on [1/2] page(s) with these settings:
- Font: [6pt/7pt]
- Columns: [2/3/4]
- Orientation: [portrait/landscape]
- Paper: [letter/A4]

Estimated capacity: [N] lines per column × [M] columns × [P] pages = [TOTAL] lines

Current content has approximately [X] items.

If over budget: suggest specific items to cut or compress further.
If under budget: suggest what to add from the source material.
If close to budget: suggest using \scalebox{0.95} or \enlargethispage{1cm} for fine adjustment.
```
