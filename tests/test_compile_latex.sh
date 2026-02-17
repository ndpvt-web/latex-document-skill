#!/usr/bin/env bash
# test_compile_latex.sh - Comprehensive tests for compile_latex.sh
#
# Run with: bash tests/test_compile_latex.sh

set -euo pipefail

# --- Color codes ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Test counters ---
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# --- Setup ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPILE_SCRIPT="${SCRIPT_DIR}/../scripts/compile_latex.sh"
TEST_TEMP_DIR=""

# Create temp directory for tests
setup_test_env() {
  TEST_TEMP_DIR=$(mktemp -d)
  echo -e "${BLUE}:: Test environment: ${TEST_TEMP_DIR}${NC}"
}

# Cleanup temp directory
cleanup_test_env() {
  if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
    rm -rf "$TEST_TEMP_DIR"
  fi
}

# --- Test framework functions ---
assert_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ "$expected" == "$actual" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    echo -e "  Expected: ${YELLOW}${expected}${NC}"
    echo -e "  Actual:   ${YELLOW}${actual}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_true() {
  local condition="$1"
  local test_name="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  if eval "$condition"; then
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    echo -e "  Condition failed: ${YELLOW}${condition}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_false() {
  local condition="$1"
  local test_name="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  if ! eval "$condition"; then
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    echo -e "  Condition should have failed: ${YELLOW}${condition}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_exists() {
  local file_path="$1"
  local test_name="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ -f "$file_path" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    echo -e "  File not found: ${YELLOW}${file_path}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_contains() {
  local file_path="$1"
  local pattern="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if grep -q "$pattern" "$file_path" 2>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    echo -e "  Pattern not found: ${YELLOW}${pattern}${NC}"
    echo -e "  In file: ${YELLOW}${file_path}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_not_contains() {
  local file_path="$1"
  local pattern="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if ! grep -q "$pattern" "$file_path" 2>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    echo -e "  Pattern should not be present: ${YELLOW}${pattern}${NC}"
    echo -e "  In file: ${YELLOW}${file_path}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# --- Helper functions to create test .tex files ---
create_minimal_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\begin{document}
Hello World
\end{document}
EOF
}

create_fontspec_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{fontspec}
\begin{document}
Hello World with fontspec
\end{document}
EOF
}

create_xecjk_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{xeCJK}
\begin{document}
你好世界
\end{document}
EOF
}

create_luacode_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{luacode}
\begin{document}
Hello from Lua
\end{document}
EOF
}

create_fontspec_and_luacode_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{fontspec}
\usepackage{luacode}
\begin{document}
Both fontspec and luacode
\end{document}
EOF
}

create_commented_fontspec_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
%\usepackage{fontspec}
\begin{document}
fontspec is commented out
\end{document}
EOF
}

create_bibtex_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\begin{document}
Citation: \cite{example}
\bibliography{refs}
\bibliographystyle{plain}
\end{document}
EOF
}

create_biber_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{biblatex}
\addbibresource{refs.bib}
\begin{document}
Citation: \cite{example}
\printbibliography
\end{document}
EOF
}

create_both_bib_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{biblatex}
\bibliography{refs}
\addbibresource{refs.bib}
\begin{document}
Both bibliography commands
\end{document}
EOF
}

create_makeindex_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\makeindex
\begin{document}
\index{test}
\printindex
\end{document}
EOF
}

create_glossary_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{glossaries}
\makeglossaries
\newacronym{cpu}{CPU}{Central Processing Unit}
\begin{document}
\gls{cpu}
\printglossaries
\end{document}
EOF
}

create_naked_float_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\begin{document}
\begin{figure}
\caption{A naked figure}
\end{figure}

\begin{table}
\caption{A naked table}
\end{table}
\end{document}
EOF
}

create_positioned_float_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{float}
\begin{document}
\begin{figure}[H]
\caption{Figure with H placement}
\end{figure}

\begin{figure}[htbp]
\caption{Figure with htbp}
\end{figure}

\begin{table}[t]
\caption{Table with t placement}
\end{table}
\end{document}
EOF
}

create_microtype_present_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\usepackage{microtype}
\begin{document}
Already has microtype
\end{document}
EOF
}

create_no_packages_tex() {
  local file_path="$1"
  cat > "$file_path" <<'EOF'
\documentclass{article}
\begin{document}
No packages at all
\end{document}
EOF
}

# --- Source the detection functions from compile_latex.sh ---
# We need to extract and source only the detection functions for unit testing
extract_detect_functions() {
  # Extract detect_engine function
  sed -n '/^detect_engine()/,/^}/p' "$COMPILE_SCRIPT" > "${TEST_TEMP_DIR}/detect_functions.sh"
  # Extract detect_bibliography function
  sed -n '/^detect_bibliography()/,/^}/p' "$COMPILE_SCRIPT" >> "${TEST_TEMP_DIR}/detect_functions.sh"
  # Extract detect_makeindex function
  sed -n '/^detect_makeindex()/,/^}/p' "$COMPILE_SCRIPT" >> "${TEST_TEMP_DIR}/detect_functions.sh"
  # Extract detect_glossary function
  sed -n '/^detect_glossary()/,/^}/p' "$COMPILE_SCRIPT" >> "${TEST_TEMP_DIR}/detect_functions.sh"
  # Extract auto_fix_floats function
  sed -n '/^auto_fix_floats()/,/^}/p' "$COMPILE_SCRIPT" >> "${TEST_TEMP_DIR}/detect_functions.sh"
  # Extract auto_inject_microtype function
  sed -n '/^auto_inject_microtype()/,/^}/p' "$COMPILE_SCRIPT" >> "${TEST_TEMP_DIR}/detect_functions.sh"
}

# --- Unit Tests: Engine Detection ---
test_engine_detection() {
  echo -e "\n${BLUE}=== Testing Engine Detection ===${NC}"

  # Test 1: Default to pdflatex for minimal document
  local test_file="${TEST_TEMP_DIR}/minimal.tex"
  create_minimal_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE=""
  source "${TEST_TEMP_DIR}/detect_functions.sh"
  local result=$(detect_engine)
  assert_equals "pdflatex" "$result" "Minimal document should use pdflatex"

  # Test 2: fontspec triggers xelatex
  test_file="${TEST_TEMP_DIR}/fontspec.tex"
  create_fontspec_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE=""
  result=$(detect_engine)
  assert_equals "xelatex" "$result" "fontspec should trigger xelatex"

  # Test 3: xeCJK triggers xelatex
  test_file="${TEST_TEMP_DIR}/xecjk.tex"
  create_xecjk_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE=""
  result=$(detect_engine)
  assert_equals "xelatex" "$result" "xeCJK should trigger xelatex"

  # Test 4: luacode triggers lualatex
  test_file="${TEST_TEMP_DIR}/luacode.tex"
  create_luacode_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE=""
  result=$(detect_engine)
  assert_equals "lualatex" "$result" "luacode should trigger lualatex"

  # Test 5: fontspec + luacode -> which wins? (fontspec is checked first)
  test_file="${TEST_TEMP_DIR}/both.tex"
  create_fontspec_and_luacode_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE=""
  result=$(detect_engine)
  assert_equals "xelatex" "$result" "fontspec takes precedence over luacode (checked first)"

  # Test 6: Commented fontspec should NOT trigger xelatex
  test_file="${TEST_TEMP_DIR}/commented.tex"
  create_commented_fontspec_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE=""
  result=$(detect_engine)
  # Bug fix: engine detection now filters out commented lines
  assert_equals "pdflatex" "$result" "Commented fontspec should NOT trigger xelatex"

  # Test 7: Manual engine override
  test_file="${TEST_TEMP_DIR}/override.tex"
  create_fontspec_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE="lualatex"
  result=$(detect_engine)
  assert_equals "lualatex" "$result" "Manual engine override should take precedence"
}

# --- Unit Tests: Bibliography Detection ---
test_bibliography_detection() {
  echo -e "\n${BLUE}=== Testing Bibliography Detection ===${NC}"

  # Test 1: No bibliography
  local test_file="${TEST_TEMP_DIR}/no_bib.tex"
  create_minimal_tex "$test_file"
  INPUT_TEX="$test_file"
  source "${TEST_TEMP_DIR}/detect_functions.sh"
  local result=$(detect_bibliography)
  assert_equals "none" "$result" "No bibliography should return 'none'"

  # Test 2: bibtex
  test_file="${TEST_TEMP_DIR}/bibtex.tex"
  create_bibtex_tex "$test_file"
  INPUT_TEX="$test_file"
  result=$(detect_bibliography)
  assert_equals "bibtex" "$result" "\\bibliography should trigger bibtex"

  # Test 3: biber
  test_file="${TEST_TEMP_DIR}/biber.tex"
  create_biber_tex "$test_file"
  INPUT_TEX="$test_file"
  result=$(detect_bibliography)
  assert_equals "biber" "$result" "\\addbibresource should trigger biber"

  # Test 4: Both present - which wins? (bibtex checked first)
  test_file="${TEST_TEMP_DIR}/both_bib.tex"
  create_both_bib_tex "$test_file"
  INPUT_TEX="$test_file"
  result=$(detect_bibliography)
  assert_equals "bibtex" "$result" "bibtex takes precedence when both present"
}

# --- Unit Tests: makeindex Detection ---
test_makeindex_detection() {
  echo -e "\n${BLUE}=== Testing makeindex Detection ===${NC}"

  # Test 1: No makeindex
  local test_file="${TEST_TEMP_DIR}/no_index.tex"
  create_minimal_tex "$test_file"
  INPUT_TEX="$test_file"
  source "${TEST_TEMP_DIR}/detect_functions.sh"
  if detect_makeindex; then
    assert_true "false" "No makeindex should return false"
  else
    assert_true "true" "No makeindex should return false"
  fi

  # Test 2: Has makeindex
  test_file="${TEST_TEMP_DIR}/has_index.tex"
  create_makeindex_tex "$test_file"
  INPUT_TEX="$test_file"
  if detect_makeindex; then
    assert_true "true" "\\makeindex should be detected"
  else
    assert_true "false" "\\makeindex should be detected"
  fi
}

# --- Unit Tests: Glossary Detection ---
test_glossary_detection() {
  echo -e "\n${BLUE}=== Testing Glossary Detection ===${NC}"

  # Test 1: No glossary
  local test_file="${TEST_TEMP_DIR}/no_gloss.tex"
  create_minimal_tex "$test_file"
  INPUT_TEX="$test_file"
  source "${TEST_TEMP_DIR}/detect_functions.sh"
  if detect_glossary; then
    assert_true "false" "No glossary should return false"
  else
    assert_true "true" "No glossary should return false"
  fi

  # Test 2: Has glossary
  test_file="${TEST_TEMP_DIR}/has_gloss.tex"
  create_glossary_tex "$test_file"
  INPUT_TEX="$test_file"
  if detect_glossary; then
    assert_true "true" "Glossary commands should be detected"
  else
    assert_true "false" "Glossary commands should be detected"
  fi
}

# --- Unit Tests: Auto-fix Floats ---
test_auto_fix_floats() {
  echo -e "\n${BLUE}=== Testing Auto-fix Floats ===${NC}"

  source "${TEST_TEMP_DIR}/detect_functions.sh"

  # Test 1: Add [htbp] to naked floats
  local input_file="${TEST_TEMP_DIR}/naked_float.tex"
  local output_file="${TEST_TEMP_DIR}/fixed_float.tex"
  create_naked_float_tex "$input_file"
  auto_fix_floats "$input_file" "$output_file" 2>/dev/null

  assert_file_contains "$output_file" 'begin{figure}\[htbp\]' "Naked figure should get [htbp]"
  assert_file_contains "$output_file" 'begin{table}\[htbp\]' "Naked table should get [htbp]"

  # Test 2: Don't modify already-positioned floats
  input_file="${TEST_TEMP_DIR}/positioned_float.tex"
  output_file="${TEST_TEMP_DIR}/positioned_fixed.tex"
  create_positioned_float_tex "$input_file"
  auto_fix_floats "$input_file" "$output_file" 2>/dev/null

  assert_file_contains "$output_file" 'begin{figure}\[H\]' "Figure with [H] should not be modified"
  assert_file_contains "$output_file" 'begin{figure}\[htbp\]' "Figure already with [htbp] should remain"
  assert_file_contains "$output_file" 'begin{table}\[t\]' "Table with [t] should not be modified"

  # Count occurrences - should still have only the original positioned ones
  local h_count=$(grep -c 'begin{figure}\[H\]' "$output_file" 2>/dev/null || echo 0)
  assert_equals "1" "$h_count" "Should have exactly 1 figure with [H]"
}

# --- Unit Tests: Auto-inject microtype ---
test_auto_inject_microtype() {
  echo -e "\n${BLUE}=== Testing Auto-inject microtype ===${NC}"

  source "${TEST_TEMP_DIR}/detect_functions.sh"

  # Test 1: Inject microtype when not present
  local input_file="${TEST_TEMP_DIR}/no_microtype.tex"
  local output_file="${TEST_TEMP_DIR}/with_microtype.tex"
  create_minimal_tex "$input_file"
  auto_inject_microtype "$input_file" "$output_file" 2>/dev/null

  assert_file_contains "$output_file" '\\usepackage{microtype}' "microtype should be injected"

  # Test 2: Don't duplicate microtype if already present
  input_file="${TEST_TEMP_DIR}/has_microtype.tex"
  output_file="${TEST_TEMP_DIR}/has_microtype_out.tex"
  create_microtype_present_tex "$input_file"
  auto_inject_microtype "$input_file" "$output_file" 2>/dev/null

  local microtype_count=$(grep -c '\\usepackage.*{microtype}' "$output_file" 2>/dev/null || echo 0)
  assert_equals "1" "$microtype_count" "microtype should appear only once when already present"

  # Test 3: Inject after last \usepackage if present
  input_file="${TEST_TEMP_DIR}/multi_packages.tex"
  output_file="${TEST_TEMP_DIR}/multi_packages_out.tex"
  cat > "$input_file" <<'EOF'
\documentclass{article}
\usepackage{graphicx}
\usepackage{amsmath}
\begin{document}
Test
\end{document}
EOF
  auto_inject_microtype "$input_file" "$output_file" 2>/dev/null

  assert_file_contains "$output_file" '\\usepackage{microtype}' "microtype should be injected after last package"

  # Verify it comes after amsmath
  local amsmath_line=$(grep -n '\\usepackage{amsmath}' "$output_file" | cut -d: -f1)
  local microtype_line=$(grep -n '\\usepackage{microtype}' "$output_file" | cut -d: -f1)
  if [[ $microtype_line -gt $amsmath_line ]]; then
    assert_true "true" "microtype should come after last usepackage"
  else
    assert_true "false" "microtype should come after last usepackage"
  fi

  # Test 4: Inject after \documentclass if no \usepackage
  input_file="${TEST_TEMP_DIR}/no_packages.tex"
  output_file="${TEST_TEMP_DIR}/no_packages_out.tex"
  create_no_packages_tex "$input_file"
  auto_inject_microtype "$input_file" "$output_file" 2>/dev/null

  assert_file_contains "$output_file" '\\usepackage{microtype}' "microtype should be injected after documentclass"

  local docclass_line=$(grep -n '\\documentclass' "$output_file" | cut -d: -f1)
  microtype_line=$(grep -n '\\usepackage{microtype}' "$output_file" | cut -d: -f1)
  if [[ $microtype_line -gt $docclass_line ]]; then
    assert_true "true" "microtype should come after documentclass"
  else
    assert_true "false" "microtype should come after documentclass"
  fi
}

# --- Integration Tests ---
test_integration_minimal_compile() {
  echo -e "\n${BLUE}=== Integration Test: Minimal Compile ===${NC}"

  # Skip if pdflatex not available
  if ! command -v pdflatex &>/dev/null; then
    echo -e "${YELLOW}⊘ SKIP${NC}: pdflatex not available"
    return
  fi

  local test_file="${TEST_TEMP_DIR}/integration_minimal.tex"
  create_minimal_tex "$test_file"

  # Run compile script
  if bash "$COMPILE_SCRIPT" "$test_file" 2>/dev/null; then
    local pdf_file="${TEST_TEMP_DIR}/integration_minimal.pdf"
    assert_file_exists "$pdf_file" "PDF should be generated from minimal document"
  else
    echo -e "${RED}✗ FAIL${NC}: Compilation failed"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_integration_auto_fix() {
  echo -e "\n${BLUE}=== Integration Test: Auto-fix Mode ===${NC}"

  # Skip if pdflatex not available
  if ! command -v pdflatex &>/dev/null; then
    echo -e "${YELLOW}⊘ SKIP${NC}: pdflatex not available"
    return
  fi

  local test_file="${TEST_TEMP_DIR}/integration_autofix.tex"
  create_naked_float_tex "$test_file"

  # Run with --auto-fix
  if bash "$COMPILE_SCRIPT" "$test_file" --auto-fix 2>/dev/null; then
    local pdf_file="${TEST_TEMP_DIR}/integration_autofix.pdf"
    assert_file_exists "$pdf_file" "PDF should be generated with auto-fix"

    # Original file should NOT be modified
    assert_file_not_contains "$test_file" '\[htbp\]' "Original file should not be modified by auto-fix"
  else
    echo -e "${RED}✗ FAIL${NC}: Auto-fix compilation failed"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# --- Error Case Tests ---
test_error_missing_file() {
  echo -e "\n${BLUE}=== Error Test: Missing File ===${NC}"

  local nonexistent="${TEST_TEMP_DIR}/nonexistent.tex"

  if bash "$COMPILE_SCRIPT" "$nonexistent" 2>/dev/null; then
    echo -e "${RED}✗ FAIL${NC}: Should fail on missing file"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_true "true" "Should fail gracefully on missing file"
  fi
}

test_error_bad_latex() {
  echo -e "\n${BLUE}=== Error Test: Bad LaTeX Syntax ===${NC}"

  # Skip if pdflatex not available
  if ! command -v pdflatex &>/dev/null; then
    echo -e "${YELLOW}⊘ SKIP${NC}: pdflatex not available"
    return
  fi

  local test_file="${TEST_TEMP_DIR}/bad_syntax.tex"
  cat > "$test_file" <<'EOF'
\documentclass{article}
\begin{document}
\undefined_command{test}
\end{document}
EOF

  if bash "$COMPILE_SCRIPT" "$test_file" 2>/dev/null; then
    # LaTeX might still produce PDF with errors
    echo -e "${YELLOW}! NOTE${NC}: LaTeX produced PDF despite errors"
  else
    assert_true "true" "Should handle bad LaTeX syntax"
  fi
}

test_error_no_document_env() {
  echo -e "\n${BLUE}=== Error Test: Missing \\begin{document} ===${NC}"

  # Skip if pdflatex not available
  if ! command -v pdflatex &>/dev/null; then
    echo -e "${YELLOW}⊘ SKIP${NC}: pdflatex not available"
    return
  fi

  local test_file="${TEST_TEMP_DIR}/no_document.tex"
  cat > "$test_file" <<'EOF'
\documentclass{article}
Hello World
EOF

  if bash "$COMPILE_SCRIPT" "$test_file" 2>/dev/null; then
    echo -e "${RED}✗ FAIL${NC}: Should fail without \\begin{document}"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_true "true" "Should fail without \\begin{document}"
  fi
}

# --- Edge Case Tests ---
test_edge_case_empty_file() {
  echo -e "\n${BLUE}=== Edge Case: Empty File ===${NC}"

  local test_file="${TEST_TEMP_DIR}/empty.tex"
  touch "$test_file"

  if bash "$COMPILE_SCRIPT" "$test_file" 2>/dev/null; then
    echo -e "${RED}✗ FAIL${NC}: Should fail on empty file"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_true "true" "Should fail gracefully on empty file"
  fi
}

test_edge_case_multiple_engines() {
  echo -e "\n${BLUE}=== Edge Case: Manual Override with Conflicting Packages ===${NC}"

  local test_file="${TEST_TEMP_DIR}/manual_override.tex"
  create_fontspec_tex "$test_file"
  INPUT_TEX="$test_file"
  ENGINE="pdflatex"  # Force pdflatex despite fontspec

  source "${TEST_TEMP_DIR}/detect_functions.sh"
  local result=$(detect_engine)
  assert_equals "pdflatex" "$result" "Manual override should work even with conflicting packages"
}

test_edge_case_nested_floats() {
  echo -e "\n${BLUE}=== Edge Case: Complex Float Patterns ===${NC}"

  source "${TEST_TEMP_DIR}/detect_functions.sh"

  local input_file="${TEST_TEMP_DIR}/nested_floats.tex"
  local output_file="${TEST_TEMP_DIR}/nested_floats_out.tex"

  cat > "$input_file" <<'EOF'
\documentclass{article}
\begin{document}
\begin{figure}
  \caption{Naked}
\end{figure}

\begin{figure}[!h]
  \caption{With !h}
\end{figure}

\begin{figure}[htbp]
  \caption{Already has htbp}
\end{figure}

\begin{figure*}
  \caption{Two column figure}
\end{figure*}
\end{document}
EOF

  auto_fix_floats "$input_file" "$output_file" 2>/dev/null

  # First figure should get [htbp]
  local naked_fixed=$(grep -c '\\begin{figure}\[htbp\]' "$output_file" 2>/dev/null || echo 0)
  # Should be at least 2 (the original one + the naked one we fixed)
  if [[ $naked_fixed -ge 2 ]]; then
    assert_true "true" "Naked figure should be fixed"
  else
    assert_true "false" "Naked figure should be fixed"
  fi

  # Figure with [!h] should not be modified to [htbp]
  assert_file_contains "$output_file" 'begin{figure}\[!h\]' "Figure with [!h] should not be changed"
}

# --- Test Runner ---
print_summary() {
  echo -e "\n${BLUE}================================${NC}"
  echo -e "${BLUE}       TEST SUMMARY${NC}"
  echo -e "${BLUE}================================${NC}"
  echo -e "Tests run:    $TESTS_RUN"
  echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
  if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
  else
    echo -e "Failed:       $TESTS_FAILED"
  fi
  echo -e "${BLUE}================================${NC}"

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    return 0
  else
    echo -e "${RED}Some tests failed.${NC}"
    return 1
  fi
}

# --- Main ---
main() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}  compile_latex.sh Test Suite${NC}"
  echo -e "${BLUE}========================================${NC}"

  setup_test_env
  extract_detect_functions

  # Run all test suites
  test_engine_detection
  test_bibliography_detection
  test_makeindex_detection
  test_glossary_detection
  test_auto_fix_floats
  test_auto_inject_microtype
  test_integration_minimal_compile
  test_integration_auto_fix
  test_error_missing_file
  test_error_bad_latex
  test_error_no_document_env
  test_edge_case_empty_file
  test_edge_case_multiple_engines
  test_edge_case_nested_floats

  cleanup_test_env

  print_summary
}

# Run tests
main
exit $?
