# LaTeX Analysis Tools - Test Suite

Comprehensive test suite for all LaTeX analysis and quality assurance scripts.

## Test File

- **Location**: `test_analysis_tools.sh`
- **Total Tests**: 64 tests across 9 scripts
- **Executable**: Yes

## Usage

```bash
# Run all tests
bash test_analysis_tools.sh

# Or
./test_analysis_tools.sh
```

## Test Coverage

### Scripts Tested (9 total)

1. **latex_lint.sh** (5 tests) - chktex wrapper with colored output
2. **latex_analyze.sh** (9 tests) - Document statistics and issue detection
3. **latex_package_check.sh** (5 tests) - Package availability verification
4. **latex_citation_extract.sh** (7 tests) - Citation analysis and BibTeX cross-reference
5. **fetch_bibtex.sh** (5 tests) - DOI/arXiv to BibTeX fetcher
6. **graphviz_to_pdf.sh** (6 tests) - Graphviz diagram conversion
7. **plantuml_to_pdf.sh** (5 tests) - PlantUML diagram conversion
8. **mermaid_to_image.sh** (5 tests) - Mermaid diagram conversion
9. **latex_diff.sh** (7 tests) - latexdiff wrapper with git integration

## Test Fixtures

All fixtures are in `fixtures/`:

- `test_document.tex` - Complex document with known issues
- `references.bib` - BibTeX file with 5 entries
- `test_packages.tex` - Package testing document
- `simple_graph.dot` - Graphviz test file
- `simple_diagram.puml` - PlantUML test file
- `simple_mermaid.mmd` - Mermaid test file
- `test_v1.tex` / `test_v2.tex` - Diff testing files

## Critical Edge Cases Tested

1. Multiple citation variants (\cite, \citep, \citet, \citeauthor)
2. Comma-separated citations (\cite{a,b,c})
3. BibTeX cross-reference validation
4. Figure/table/equation counting
5. Unreferenced label detection
6. TODO/FIXME comment detection
7. kpsewhich package lookup
8. Nonexistent package detection
9. DOI and arXiv ID pattern matching
10. Multiple Graphviz layout engines
11. latexdiff markup output validation

## Test Features

- Color-coded output (pass=green, fail=red, skip=yellow)
- Graceful dependency handling (skips tests when tools unavailable)
- Comprehensive test summary
- Error handling validation
- Argument parsing validation
- Output correctness verification

## Example Output

```
========================================
LaTeX Analysis Tools - Test Suite
========================================

=== Testing latex_lint.sh ===
✓ PASS: latex_lint.sh - Help flag
✓ PASS: latex_lint.sh - Basic execution
...

========================================
Test Summary
========================================
Total tests run: 64
Passed: 58
Failed: 0
Skipped: 6
========================================
All tests passed!
```

## Test Development

The test framework provides helper functions:

- `pass(test_name)` - Mark test as passed
- `fail(test_name, reason)` - Mark test as failed
- `skip(test_name, reason)` - Skip test (e.g., missing dependency)
- `run_test(test_name)` - Start new test

Tests automatically handle dependencies and skip gracefully when tools are not available.
