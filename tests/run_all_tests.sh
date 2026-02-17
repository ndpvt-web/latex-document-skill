#!/usr/bin/env bash
# run_all_tests.sh - Master test runner for latex-document skill
#
# Runs all test suites and produces a comprehensive summary

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Test suite tracking
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
SKIPPED_SUITES=0

declare -a SUITE_NAMES
declare -a SUITE_RESULTS
declare -a SUITE_DURATIONS

# Print banner
print_banner() {
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}  LaTeX Document Skill - Test Suite${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""
}

# Print test suite header
print_suite_header() {
  local suite_name="$1"
  echo ""
  echo -e "${MAGENTA}┌────────────────────────────────────────┐${NC}"
  echo -e "${MAGENTA}│  Running: ${suite_name}${NC}"
  echo -e "${MAGENTA}└────────────────────────────────────────┘${NC}"
}

# Run a test suite
run_test_suite() {
  local test_script="$1"
  local suite_name="$2"

  TOTAL_SUITES=$((TOTAL_SUITES + 1))

  # Check if test script exists
  if [[ ! -f "$test_script" ]]; then
    echo -e "${YELLOW}[SKIP]${NC} $suite_name - Script not found: $test_script"
    SUITE_NAMES+=("$suite_name")
    SUITE_RESULTS+=("SKIP")
    SUITE_DURATIONS+=("0.00")
    SKIPPED_SUITES=$((SKIPPED_SUITES + 1))
    return
  fi

  # Check if script is executable
  if [[ ! -x "$test_script" ]]; then
    chmod +x "$test_script"
  fi

  print_suite_header "$suite_name"

  # Run test and measure time
  local start_time=$(date +%s.%N)
  local exit_code=0

  if bash "$test_script"; then
    exit_code=0
  else
    exit_code=$?
  fi

  local end_time=$(date +%s.%N)
  local duration=$(echo "$end_time - $start_time" | bc)

  # Record results
  SUITE_NAMES+=("$suite_name")
  SUITE_DURATIONS+=("$duration")

  if [[ $exit_code -eq 0 ]]; then
    echo -e "${GREEN}✓ PASSED${NC} - $suite_name (${duration}s)"
    SUITE_RESULTS+=("PASS")
    PASSED_SUITES=$((PASSED_SUITES + 1))
  else
    echo -e "${RED}✗ FAILED${NC} - $suite_name (${duration}s)"
    SUITE_RESULTS+=("FAIL")
    FAILED_SUITES=$((FAILED_SUITES + 1))
  fi
}

# Print final summary
print_summary() {
  echo ""
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}           FINAL SUMMARY${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""

  # Suite-by-suite results
  echo "Test Suite Results:"
  echo "-------------------"
  printf "%-35s %-10s %s\n" "Suite" "Result" "Duration"
  printf "%-35s %-10s %s\n" "-----" "------" "--------"

  for i in "${!SUITE_NAMES[@]}"; do
    local name="${SUITE_NAMES[$i]}"
    local result="${SUITE_RESULTS[$i]}"
    local duration="${SUITE_DURATIONS[$i]}"

    case "$result" in
      PASS)
        printf "%-35s ${GREEN}%-10s${NC} %ss\n" "$name" "$result" "$duration"
        ;;
      FAIL)
        printf "%-35s ${RED}%-10s${NC} %ss\n" "$name" "$result" "$duration"
        ;;
      SKIP)
        printf "%-35s ${YELLOW}%-10s${NC} %ss\n" "$name" "$result" "$duration"
        ;;
    esac
  done

  echo ""
  echo "Overall Statistics:"
  echo "-------------------"
  echo -e "Total test suites:  ${BLUE}${TOTAL_SUITES}${NC}"
  echo -e "Passed:             ${GREEN}${PASSED_SUITES}${NC}"
  echo -e "Failed:             ${RED}${FAILED_SUITES}${NC}"
  echo -e "Skipped:            ${YELLOW}${SKIPPED_SUITES}${NC}"

  # Calculate total time
  local total_time=0
  for duration in "${SUITE_DURATIONS[@]}"; do
    total_time=$(echo "$total_time + $duration" | bc)
  done
  echo -e "Total time:         ${CYAN}${total_time}s${NC}"

  echo ""
  echo -e "${CYAN}========================================${NC}"

  # Exit status
  if [[ $FAILED_SUITES -eq 0 ]]; then
    echo -e "${GREEN}All test suites passed!${NC}"
    return 0
  else
    echo -e "${RED}Some test suites failed.${NC}"
    return 1
  fi
}

# Main execution
main() {
  print_banner

  # Check if bc is available for time calculations
  if ! command -v bc &>/dev/null; then
    echo -e "${YELLOW}Warning: 'bc' not found. Duration calculations will be skipped.${NC}"
    echo "Install with: apt-get install bc (Debian/Ubuntu) or brew install bc (macOS)"
    echo ""
  fi

  # List of test suites to run
  # Note: Some test suites may not exist yet - they'll be skipped

  echo "Discovering test suites..."
  echo ""

  # Run test_compile_latex.sh
  run_test_suite "${SCRIPT_DIR}/test_compile_latex.sh" "compile_latex.sh Tests"

  # Run test_templates.sh
  run_test_suite "${SCRIPT_DIR}/test_templates.sh" "Template Compilation Tests"

  # Future test suites (will be skipped if not present)
  run_test_suite "${SCRIPT_DIR}/test_python_scripts.py" "Python Scripts Tests"
  run_test_suite "${SCRIPT_DIR}/test_pdf_utils.sh" "PDF Utilities Tests"
  run_test_suite "${SCRIPT_DIR}/test_analysis_tools.sh" "Analysis Tools Tests"

  # Print final summary
  print_summary
}

# Run main
main
exit $?
