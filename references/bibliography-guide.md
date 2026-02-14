# Bibliography and Citation Guide

## Quick Start

### Using BibTeX (natbib) -- Recommended for most documents

1. Create a `.bib` file (see `assets/templates/references.bib` for examples)
2. Add to your `.tex` preamble:
```latex
\usepackage{natbib}
```
3. Add before `\end{document}`:
```latex
\bibliographystyle{plainnat}  % or: apalike, ieeetr, unsrt, alpha
\bibliography{references}     % references.bib (omit .bib extension)
```
4. Cite in text:
```latex
\citet{vaswani2017attention}   % Vaswani et al. (2017)
\citep{vaswani2017attention}   % (Vaswani et al., 2017)
\citep[p.~5]{he2016deep}      % (He et al., 2016, p. 5)
```

The compile script auto-detects `\bibliography{}` and runs bibtex automatically.

### Using biblatex (more flexible, modern)

1. Preamble:
```latex
\usepackage[backend=biber, style=authoryear]{biblatex}
\addbibresource{references.bib}
```
2. Before `\end{document}`:
```latex
\printbibliography
```
3. Cite:
```latex
\textcite{vaswani2017attention}  % Vaswani et al. (2017)
\parencite{vaswani2017attention} % (Vaswani et al., 2017)
\autocite{vaswani2017attention}  % auto-format based on style
```

The compile script auto-detects `\addbibresource{}` and runs biber automatically.

## .bib Entry Types

| Type | Use For | Required Fields |
|------|---------|-----------------|
| `@article` | Journal papers | author, title, journal, year |
| `@inproceedings` | Conference papers | author, title, booktitle, year |
| `@book` | Books | author/editor, title, publisher, year |
| `@incollection` | Book chapters | author, title, booktitle, publisher, year |
| `@techreport` | Technical reports | author, title, institution, year |
| `@phdthesis` | PhD dissertations | author, title, school, year |
| `@mastersthesis` | Master's theses | author, title, school, year |
| `@misc` | Preprints, websites, other | author, title, year |

## Bibliography Styles

### natbib styles
| Style | Format | Best For |
|-------|--------|----------|
| `plainnat` | Author-year, alphabetical | General academic |
| `apalike` | APA-like format | Social sciences |
| `ieeetr` | Numbered, order of appearance | Engineering, IEEE |
| `unsrt` | Numbered, order of citation | General numbered |
| `alpha` | Abbreviated author labels [VAS17] | Mathematics |
| `abbrvnat` | Author-year, abbreviated names | Compact references |

### biblatex styles
| Style | Format | Best For |
|-------|--------|----------|
| `authoryear` | (Author, Year) | Humanities, social sciences |
| `numeric` | [1], [2], [3] | Sciences, engineering |
| `ieee` | IEEE standard | Electrical engineering |
| `apa` | Full APA compliance | Psychology, education |
| `chicago-authordate` | Chicago Manual | Humanities |

## Citation Commands

### natbib
```latex
\citet{key}          % Author (Year)
\citet*{key}         % All Authors (Year)
\citep{key}          % (Author, Year)
\citep[p.~5]{key}    % (Author, Year, p. 5)
\citep{key1,key2}    % (Author1, Year1; Author2, Year2)
\citeauthor{key}     % Author
\citeyear{key}       % Year
```

### biblatex
```latex
\textcite{key}       % Author (Year)
\parencite{key}      % (Author, Year)
\autocite{key}       % Context-dependent
\fullcite{key}       % Full bibliography entry inline
\footcite{key}       % Citation in footnote
```

## Common Pitfalls

1. **Undefined citation**: Ensure the cite key in `.tex` matches the key in `.bib` exactly (case-sensitive)
2. **Missing .bib file**: The `.bib` file must be in the same directory as the `.tex` file (or specify path)
3. **Special characters**: Use `{\'e}` for accented characters in .bib files, or `{\"o}` for umlauts
4. **Capitalization**: BibTeX lowercases titles by default. Protect with braces: `title = {The {GPU} Architecture}`
5. **Compile order**: Must run pdflatex → bibtex → pdflatex → pdflatex (the compile script handles this)
