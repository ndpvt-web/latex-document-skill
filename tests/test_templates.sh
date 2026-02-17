#!/usr/bin/env bash
# test_templates.sh - Comprehensive template compilation test
#
# Tests all 27 templates in the latex-document skill to ensure they compile cleanly

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNED_TESTS=0

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/../assets/templates"
COMPILE_SCRIPT="${SCRIPT_DIR}/../scripts/compile_latex.sh"
TEMP_BASE_DIR=$(mktemp -d)

# Test summary data
declare -a TEST_RESULTS
declare -a TEST_TIMES
declare -a TEST_MESSAGES

echo "=========================================="
echo "Template Compilation Test Suite"
echo "=========================================="
echo "Templates directory: ${TEMPLATES_DIR}"
echo "Temporary directory: ${TEMP_BASE_DIR}"
echo ""

# Cleanup function
cleanup() {
  if [[ -d "$TEMP_BASE_DIR" ]]; then
    rm -rf "$TEMP_BASE_DIR"
  fi
}
trap cleanup EXIT

# Helper: Check if template needs specific engine
detect_required_engine() {
  local tex_file="$1"

  # Check for fontspec/xeCJK -> xelatex
  if grep -qE '\\usepackage\{fontspec\}|\\usepackage\{xeCJK\}|\\usepackage\{polyglossia\}' "$tex_file"; then
    echo "xelatex"
    return
  fi

  # Check for luacode -> lualatex
  if grep -qE '\\usepackage\{luacode\}|\\usepackage\{luatextra\}|\\directlua' "$tex_file"; then
    echo "lualatex"
    return
  fi

  echo "pdflatex"
}

# Helper: Check if template needs bibliography
needs_bibliography() {
  local tex_file="$1"
  grep -qE '\\bibliography\{|\\addbibresource\{' "$tex_file"
}

# Helper: Check if template needs makeindex
needs_makeindex() {
  local tex_file="$1"
  grep -qE '\\makeindex|\\printindex' "$tex_file"
}

# Test a single template
test_template() {
  local template_name="$1"
  local template_path="${TEMPLATES_DIR}/${template_name}.tex"

  TOTAL_TESTS=$((TOTAL_TESTS + 1))

  if [[ ! -f "$template_path" ]]; then
    echo -e "${RED}[SKIP]${NC} ${template_name} - File not found"
    TEST_RESULTS+=("SKIP")
    TEST_TIMES+=("0")
    TEST_MESSAGES+=("File not found")
    return
  fi

  # Create temp directory for this template
  local test_dir="${TEMP_BASE_DIR}/${template_name}"
  mkdir -p "$test_dir"

  # Copy template to test directory
  cp "$template_path" "$test_dir/"

  # Copy references.bib if needed
  if needs_bibliography "$template_path"; then
    if [[ -f "${TEMPLATES_DIR}/references.bib" ]]; then
      cp "${TEMPLATES_DIR}/references.bib" "$test_dir/"
    fi
  fi

  # Detect engine
  local engine=$(detect_required_engine "$template_path")

  # Show test info
  echo -n "Testing ${template_name} [${engine}]... "

  # Compile and measure time
  local start_time=$(date +%s.%N)
  local compile_log="${test_dir}/compile.log"
  local compile_exit=0

  if [[ "$engine" == "pdflatex" ]]; then
    "${COMPILE_SCRIPT}" "${test_dir}/${template_name}.tex" > "$compile_log" 2>&1 || compile_exit=$?
  else
    "${COMPILE_SCRIPT}" "${test_dir}/${template_name}.tex" --engine "$engine" > "$compile_log" 2>&1 || compile_exit=$?
  fi

  local end_time=$(date +%s.%N)
  local duration=$(echo "$end_time - $start_time" | bc)

  # Check if PDF was produced
  local pdf_path="${test_dir}/${template_name}.pdf"
  local log_path="${test_dir}/${template_name}.log"

  if [[ ! -f "$pdf_path" ]]; then
    echo -e "${RED}FAIL${NC} (${duration}s) - No PDF produced"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TEST_RESULTS+=("FAIL")
    TEST_TIMES+=("$duration")
    TEST_MESSAGES+=("No PDF produced, exit code: $compile_exit")

    # Show last 20 lines of compile log for debugging
    echo "  Last 20 lines of compilation output:"
    tail -20 "$compile_log" | sed 's/^/    /'
    return
  fi

  # PDF was produced - check for warnings/errors in log
  local has_errors=0
  local has_warnings=0
  local warning_count=0
  local error_messages=""

  if [[ -f "$log_path" ]]; then
    # Check for fatal errors (shouldn't happen if PDF exists, but check anyway)
    if grep -qE "^! |Emergency stop|Fatal error" "$log_path"; then
      has_errors=1
      error_messages=$(grep -E "^! |Emergency stop|Fatal error" "$log_path" | head -3 | tr '\n' ';')
    fi

    # Check for warnings
    if grep -qE "Warning|Overfull|Underfull" "$log_path"; then
      has_warnings=1
      warning_count=$(grep -cE "Warning|Overfull|Underfull" "$log_path" || true)
    fi
  fi

  # Determine test result
  if [[ $has_errors -eq 1 ]]; then
    echo -e "${RED}FAIL${NC} (${duration}s) - Errors in log despite PDF"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TEST_RESULTS+=("FAIL")
    TEST_TIMES+=("$duration")
    TEST_MESSAGES+=("Errors: $error_messages")
  elif [[ $has_warnings -eq 1 ]]; then
    echo -e "${YELLOW}WARN${NC} (${duration}s) - PDF produced with $warning_count warnings"
    WARNED_TESTS=$((WARNED_TESTS + 1))
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TEST_RESULTS+=("WARN")
    TEST_TIMES+=("$duration")
    TEST_MESSAGES+=("$warning_count warnings")
  else
    echo -e "${GREEN}PASS${NC} (${duration}s) - Clean compilation"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TEST_RESULTS+=("PASS")
    TEST_TIMES+=("$duration")
    TEST_MESSAGES+=("Clean")
  fi
}

# Main test execution
echo "Starting template compilation tests..."
echo ""

# List of all templates (27 total)
TEMPLATES=(
  "academic-cv"
  "academic-paper"
  "book"
  "cheatsheet"
  "cheatsheet-code"
  "cheatsheet-exam"
  "conditional-document"
  "cover-letter"
  "exam"
  "fillable-form"
  "homework"
  "invoice"
  "lab-report"
  "lecture-notes"
  "letter"
  "mail-merge-letter"
  "poster"
  "poster-landscape"
  "presentation"
  "report"
  "resume"
  "resume-classic-ats"
  "resume-entry-level"
  "resume-executive"
  "resume-modern-professional"
  "resume-technical"
  "thesis"
)

# Run tests
for template in "${TEMPLATES[@]}"; do
  test_template "$template"
done

# Print summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Total templates tested: ${BLUE}${TOTAL_TESTS}${NC}"
echo -e "Passed (clean):         ${GREEN}$((PASSED_TESTS - WARNED_TESTS))${NC}"
echo -e "Passed (with warnings): ${YELLOW}${WARNED_TESTS}${NC}"
echo -e "Failed:                 ${RED}${FAILED_TESTS}${NC}"
echo ""

# Detailed results table
echo "Detailed Results:"
echo "----------------"
printf "%-30s %-8s %-10s %s\n" "Template" "Result" "Time (s)" "Notes"
printf "%-30s %-8s %-10s %s\n" "--------" "------" "--------" "-----"

for i in "${!TEMPLATES[@]}"; do
  template="${TEMPLATES[$i]}"
  result="${TEST_RESULTS[$i]}"
  time="${TEST_TIMES[$i]}"
  message="${TEST_MESSAGES[$i]}"

  case "$result" in
    PASS)
      printf "%-30s ${GREEN}%-8s${NC} %-10s %s\n" "$template" "$result" "$time" "$message"
      ;;
    WARN)
      printf "%-30s ${YELLOW}%-8s${NC} %-10s %s\n" "$template" "$result" "$time" "$message"
      ;;
    FAIL)
      printf "%-30s ${RED}%-8s${NC} %-10s %s\n" "$template" "$result" "$time" "$message"
      ;;
    SKIP)
      printf "%-30s %-8s %-10s %s\n" "$template" "$result" "$time" "$message"
      ;;
  esac
done

echo ""
echo "=========================================="

# Exit with appropriate code
if [[ $FAILED_TESTS -gt 0 ]]; then
  echo -e "${RED}Some tests failed!${NC}"
  exit 1
else
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
fi
