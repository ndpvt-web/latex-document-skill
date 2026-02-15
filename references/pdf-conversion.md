# PDF-to-LaTeX Conversion Pipeline

## Overview

Convert PDFs of any type (handwritten notes, printed reports, legal contracts, math lectures) to LaTeX using a scaling strategy based on document size, with document-type profiles for accurate conversion.

## Step 1: Determine Document Type

Scan a few representative pages and select the matching conversion profile:

| Content Type | Profile | Key Indicators |
|---|---|---|
| Math / science | `references/profiles/math-notes.md` | Equations, theorems, proofs, Greek symbols, integrals |
| Business | `references/profiles/business-document.md` | Data tables, bullet points, meeting notes, financial figures |
| Legal | `references/profiles/legal-document.md` | Numbered clauses, "WHEREAS", signature blocks, articles/sections |
| General | `references/profiles/general-notes.md` | Informal notes, mixed content, journals, letters |

Each profile provides a suggested preamble, structural patterns to recognize, worker hints, and pitfalls.

## Step 2: Prepare Images

```bash
bash <skill_path>/scripts/pdf_to_images.sh input.pdf ./tmp/pages --dpi 200 --max-dim 2000
```

This creates `page-001.png` through `page-NNN.png`, resized for API compatibility (max 2000px dimension).

## Step 3: Apply Scaling Strategy

### Empirical Basis

Tested on 15 identical pages with batch sizes 3, 5, 7, 10, and 15:

| Batch Size | LaTeX Errors | Errors/Page | Content/Page | Structure Recognition |
|---|---|---|---|---|
| 3 | 0 | 0.00 | 22.3 lines | **Poor** (2 envs) -- structural blindness |
| 5 | 1 | 0.07 | 24.3 lines | Good (9 envs) |
| **7** | **0** | **0.00** | **24.8 lines** | **Best** (11 envs) |
| 10 | 2 | 0.13 | 26.3 lines | Good (13 envs) |
| 15 | 11 | 0.73 | 21.3 lines | Poor (5 envs) -- catastrophic errors |

**Error analysis at 10 pages**: 2 structural errors -- an unclosed `\begin{remark}` environment caused by a typo (`\end{remark>}` instead of `\end{remark}`). Not trivial, but fixable with one edit.

**Error analysis at 15 pages**: 11 severe errors -- multiple unclosed environments, mismatched nesting (`\begin{definition}` ended by `\end{align*}`), stray `&` characters, math mode corruption. The model loses track of structural state past ~10 pages.

### Scaling Thresholds

| PDF Size | Strategy | Agents | Rationale |
|---|---|---|---|
| **1-10 pages** | Single agent | 1 | 0-2 minor errors, trivially fixable. Batching overhead (launching agents, merging files, fixing boundaries) exceeds the cost of fixing 2 errors. |
| **11-20 pages** | Split in half | 2 | Error rate climbs steeply past 10 pages. Two agents of ~7-10 pages each stay in the low-error zone. One merge point to handle. |
| **21+ pages** | Batch-7 pipeline | ceil(N/7) | Each agent gets 7 pages (0-error sweet spot). Full parallel processing with `run_in_background: true`. |

### Why Not Always Batch at 7?

Batching has real costs:
- **Agent launch overhead**: Each agent needs the prompt, preamble reference, context about what comes before/after
- **Merge complexity**: Concatenating files can introduce boundary errors (split mid-theorem, mid-proof)
- **Coordination time**: Waiting for all agents, checking outputs, fixing merge points

For a 10-page PDF, splitting into 7+3 means: 2 agent launches + 1 merge point + potential boundary error vs. 1 agent with ~2 fixable errors. The single agent wins.

For a 25-page PDF, the single agent would produce ~15+ catastrophic errors. Three agents of ~8 each produce 0-2 errors total with 2 merge points. Batching wins decisively.

## Step 4: Create Shared Preamble

Before launching workers, one agent scans 3-5 representative pages to build the preamble:

1. Read the selected profile's suggested preamble as a starting point
2. **For math-notes profile**: Default to **beautiful mode** -- copy the preamble from `assets/templates/lecture-notes.tex` (everything before `\begin{document}`). This gives you tcolorbox theorem environments, TikZ graph styles, Palatino font, and microtype. Only use plain mode if the user explicitly requests it.
3. Scan pages to identify additional packages or custom commands needed beyond the profile's base
4. Write `tmp/preamble.tex` with everything from `\documentclass` through the last `\newcommand`
5. Do NOT include `\begin{document}` -- that goes in the assembly step

## Step 5: Launch Workers

### For single agent (1-10 pages):

One agent reads all page images and writes body-only LaTeX to `tmp/batch_001_NNN.tex`.

### For split (11-20 pages):

Two agents, each with ~half the pages. Use `run_in_background: true` for the second agent.

### For batch-7 pipeline (21+ pages):

Launch `ceil(N/7)` agents with `run_in_background: true`.

**Worker prompt template**:
```
Convert pages [START]-[END] of the document to LaTeX body content.

Read the preamble at [path/preamble.tex] for available commands and environments.
Read the conversion profile at [path/profile.md] for structural patterns and hints.
Read page images: [path/page-XXX.png] through [path/page-YYY.png]

CONTEXT: You are continuing from [section/content context from previous batch].
The document is a [type: math notes / business report / legal contract / general notes].

OUTPUT: Write ONLY to [path/batch_XXX_YYY.tex]

RULES:
- Output ONLY body content (no \documentclass, \usepackage, \begin{document})
- Use custom commands from preamble
- Follow the structural patterns described in the profile
- Be faithful to the original content
- Close ALL open environments before the end of your output
- Be CONCISE -- write the LaTeX, nothing else

CRITICAL LATEX CONSTRAINTS (violation = compilation failure):

1. UNDEFINED COMMANDS -- Do NOT use:
   - \sout{} (use \cancel{} instead, or plain strikethrough text)
   - \circled{} (use \textcircled{1} or the \circled command if defined in preamble)
   - \pentagon, \hexagon, or invented symbol commands (draw shapes with TikZ instead)
   - Any command you are not certain exists. Check the preamble first.

2. TIKZ SYNTAX:
   - EVERY \node, \draw, \path command MUST end with semicolon ;
   - EVERY \node MUST have label text in braces: \node[vertex] (v1) at (0,0) {$v_1$};
   - Empty labels still need braces: \node[vertex] (v1) at (0,0) {};
   - ALL TikZ commands MUST be inside \begin{tikzpicture}...\end{tikzpicture}
   - Use POLAR coordinates for circular layouts: (60:1.5cm) not ({cos(60)},{sin(60)})
   - edge/dedge/hedge are EDGE styles: use \draw[edge], NEVER \node[edge]

3. ENVIRONMENT NESTING:
   - Do NOT use \begin{table}[H] or \begin{figure}[H] inside tcolorbox environments (theorem, example, definition, etc.)
   - Use \begin{tabular} directly inside boxes (no table wrapper needed)
   - Do NOT put \begin{tabular} inside align* or equation* environments
   - \begin{proof} inside \begin{example} is allowed, but you MUST close proof BEFORE closing example

4. ENUMERATE/ITEMIZE:
   - Use \begin{enumerate} without inline label options (labels are pre-configured in preamble)
   - First level: (i), (ii), (iii); second level: (a), (b), (c)
   - If you need a specific label, use: \begin{enumerate}[label=(\alph*)]

5. COMMANDS AVAILABLE IN PREAMBLE (beautiful mode):
   - Number sets: \R, \N, \Z, \Q, \C
   - Graph theory: \V, \E, \deg, \diam, \dist, \Aut, \chr
   - Delimiters: \abs{}, \norm{}, \floor{}, \ceil{}
   - Circled numbers: \circled{1}, \circled{2}
   - Strikethrough: \sout{text} (ulem loaded), \cancel{expr} (in math)
```

## Step 6: Validate Batch Outputs

Before assembling, run the validation script on each batch file to catch errors early:

```bash
python3 <skill_path>/scripts/validate_latex.py tmp/batch_*.tex --preamble tmp/preamble.tex
```

This checks for:
- Balanced `\begin{}`/`\end{}` environments
- Undefined commands not present in preamble
- `\begin{table}[H]` or `\begin{figure}[H]` inside tcolorbox environments
- TikZ commands (`\node`, `\draw`) outside `\begin{tikzpicture}`
- Missing node labels (TikZ `\node` without `{};`)

Fix any reported errors in the batch files BEFORE assembling.

## Step 7: Assemble and Compile

After all workers complete and validation passes:

```bash
# 1. Build the full document
cat tmp/preamble.tex > outputs/document.tex
echo '' >> outputs/document.tex
echo '\begin{document}' >> outputs/document.tex
echo '\maketitle' >> outputs/document.tex       # if title/author set in preamble
echo '\tableofcontents' >> outputs/document.tex  # if document has sections
echo '\newpage' >> outputs/document.tex
for f in $(ls tmp/batch_*.tex | sort); do
  echo "" >> outputs/document.tex
  echo "% === $(basename $f) ===" >> outputs/document.tex
  cat "$f" >> outputs/document.tex
done
echo '' >> outputs/document.tex
echo '\end{document}' >> outputs/document.tex

# 2. Compile
bash <skill_path>/scripts/compile_latex.sh outputs/document.tex --preview --preview-dir outputs
```

### If compilation fails:

1. Read the `.log` file for error details
2. For large documents (20+ pages), use **parallel error-fixing agents**: split the body into N sections (e.g., 5), assign each to an agent, fix independently, then reassemble
3. Common fixes:
   - **Mismatched `\begin`/`\end`**: Find and close orphaned environments
   - **Misplaced `&`**: Ensure `&` only appears inside tabular/align environments
   - **Undefined commands**: Add missing `\newcommand` to preamble or remove the command usage
   - **Package conflicts**: Remove `hyperref` if `\set@color` errors appear
   - **Missing `$`**: Find unclosed inline math
   - **`\newcommand` conflict**: Use `\renewcommand` if overriding a built-in command (e.g., `\deg`)
   - **CT@row@color errors**: Caused by `\begin{tabular}` inside math environments -- move tabular outside
   - **"Not in outer par mode"**: Caused by `\begin{table}[H]` inside tcolorbox -- remove the `table` wrapper
   - **TikZ "Undefined control sequence"**: TikZ commands outside `\begin{tikzpicture}` -- find and wrap them
4. Fix errors in the `.tex` file and recompile

## Scaling Examples

| Document | Pages | Agents | Batch Config |
|---|---|---|---|
| Meeting notes | 3 | 1 | Single agent |
| Contract | 8 | 1 | Single agent |
| Quarterly report | 15 | 2 | 8 + 7 |
| Thesis chapter | 20 | 2 | 10 + 10 |
| Full textbook chapter | 30 | 5 | 7+7+7+7+2 |
| Course notes | 50 | 8 | 7 each, last gets 1 |
| Full textbook | 100 | 15 | 7 each, last gets 2 |
| Lecture series | 115 | 17 | 7 each, last gets 3 |
| Large manual | 200 | 29 | 7 each, last gets 4 |

## Common Pitfalls (All Document Types)

1. **Do NOT use `sed` to clean control characters**. Regex `[^[:print:][:space:]]` strips `\b`, `\t`, `\n`, `\e` which destroys `\begin`, `\tableofcontents`, `\newpage`, `\end`.

2. **Do NOT use `hyperref` in converted documents**. Causes `\set@color` / `\@pdfcolorstack` errors with theorem environments and colored text.

3. **Always compile from a clean directory** if the compile script has issues with stale aux files.

4. **Workers must be CONCISE**. Agents that add verbose comments or explanations waste context window and may overflow.

5. **Close environments at batch boundaries**. If a proof/theorem/table spans the end of a batch, close it and add a comment: `% continues in next batch`.

6. **Select the correct profile**. A math profile on a business document will produce unnecessary theorem environments. A business profile on math notes will miss structural patterns.
