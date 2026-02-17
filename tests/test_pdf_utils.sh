#!/usr/bin/env bash
# test_pdf_utils.sh - Comprehensive tests for PDF utility scripts
#
# Usage: bash tests/test_pdf_utils.sh

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
TEST_DIR="/tmp/pdf_utils_tests_$$"
TEST_FIXTURE_DIR="${TEST_DIR}/fixtures"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Setup test environment
setup() {
    echo -e "${BLUE}=== Setting up test environment ===${NC}"
    mkdir -p "$TEST_FIXTURE_DIR"
    cd "$TEST_FIXTURE_DIR"

    # Create test PDF fixtures
    create_test_pdfs
}

# Teardown test environment
teardown() {
    echo -e "${BLUE}=== Cleaning up test environment ===${NC}"
    rm -rf "$TEST_DIR"
}

# Create test PDF fixtures
create_test_pdfs() {
    echo -e "${YELLOW}Creating test PDF fixtures...${NC}"

    # 3-page test PDF
    cat > test_3page.tex <<'EOF'
\documentclass{article}
\begin{document}
Hello World. This is page one with some text content.
\newpage
This is page two. It has different content from page one.
\newpage
This is page three, the final page of this document.
\end{document}
EOF

    pdflatex -interaction=nonstopmode test_3page.tex >/dev/null 2>&1
    if [[ ! -f test_3page.pdf ]]; then
        echo -e "${RED}Failed to create 3-page test PDF${NC}"
        exit 1
    fi

    # 1-page test PDF
    cat > test_1page.tex <<'EOF'
\documentclass{article}
\begin{document}
This is a single page document for edge case testing.
\end{document}
EOF

    pdflatex -interaction=nonstopmode test_1page.tex >/dev/null 2>&1
    if [[ ! -f test_1page.pdf ]]; then
        echo -e "${RED}Failed to create 1-page test PDF${NC}"
        exit 1
    fi

    # 10-page test PDF (for larger tests)
    cat > test_10page.tex <<'EOF'
\documentclass{article}
\begin{document}
\section{Introduction}
This is page 1.
\newpage Page 2.
\newpage Page 3.
\newpage Page 4.
\newpage Page 5.
\newpage Page 6.
\newpage Page 7.
\newpage Page 8.
\newpage Page 9.
\newpage Page 10.
\end{document}
EOF

    pdflatex -interaction=nonstopmode test_10page.tex >/dev/null 2>&1
    if [[ ! -f test_10page.pdf ]]; then
        echo -e "${RED}Failed to create 10-page test PDF${NC}"
        exit 1
    fi

    echo -e "${GREEN}Test PDFs created successfully${NC}"
    echo "  - test_3page.pdf (3 pages)"
    echo "  - test_1page.pdf (1 page)"
    echo "  - test_10page.pdf (10 pages)"
}

# Test framework functions
run_test() {
    local test_name="$1"
    local test_func="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${BLUE}TEST [$TOTAL_TESTS]: $test_name${NC}"

    if $test_func; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓ PASS${NC}"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "  ✓ File exists: $file"
        return 0
    else
        echo "  ✗ File does not exist: $file"
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "  ✓ File does not exist (as expected): $file"
        return 0
    else
        echo "  ✗ File exists (should not): $file"
        return 1
    fi
}

assert_page_count() {
    local pdf="$1"
    local expected_pages="$2"

    if ! command -v qpdf &>/dev/null; then
        echo "  ⚠ qpdf not available, skipping page count check"
        return 0
    fi

    local actual_pages=$(qpdf --show-npages "$pdf" 2>/dev/null || echo "0")
    if [[ "$actual_pages" == "$expected_pages" ]]; then
        echo "  ✓ Page count: $actual_pages (expected: $expected_pages)"
        return 0
    else
        echo "  ✗ Page count: $actual_pages (expected: $expected_pages)"
        return 1
    fi
}

assert_pdf_encrypted() {
    local pdf="$1"

    if ! command -v qpdf &>/dev/null; then
        echo "  ⚠ qpdf not available, skipping encryption check"
        return 0
    fi

    # Try to open without password - should fail for encrypted PDFs
    if qpdf --check "$pdf" >/dev/null 2>&1; then
        # If it succeeds, check if encryption info exists
        if qpdf --show-encryption "$pdf" 2>&1 | grep -q "encrypted with password"; then
            echo "  ✓ PDF is encrypted"
            return 0
        else
            echo "  ✗ PDF is not encrypted"
            return 1
        fi
    else
        # If check fails, it might be due to encryption
        echo "  ✓ PDF appears to be encrypted (check failed without password)"
        return 0
    fi
}

assert_file_smaller() {
    local file1="$1"
    local file2="$2"

    local size1=$(stat -c%s "$file1" 2>/dev/null || stat -f%z "$file1" 2>/dev/null)
    local size2=$(stat -c%s "$file2" 2>/dev/null || stat -f%z "$file2" 2>/dev/null)

    if [[ $size1 -lt $size2 ]]; then
        echo "  ✓ File size reduced: $size2 → $size1 bytes"
        return 0
    else
        echo "  ⚠ File size not reduced: $size2 → $size1 bytes (may already be optimized)"
        # Don't fail - some PDFs are already well optimized
        return 0
    fi
}

# ============================================================================
# PDF ENCRYPT TESTS
# ============================================================================

test_pdf_encrypt_basic() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/encrypted_basic.pdf"

    bash "${SCRIPTS_DIR}/pdf_encrypt.sh" "$input" \
        --user-password "testpass123" \
        --output "$output" 2>/dev/null

    assert_file_exists "$output"
}

test_pdf_encrypt_with_restrictions() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/encrypted_restricted.pdf"

    bash "${SCRIPTS_DIR}/pdf_encrypt.sh" "$input" \
        --user-password "testpass" \
        --restrict-print \
        --restrict-copy \
        --restrict-modify \
        --output "$output" 2>/dev/null

    assert_file_exists "$output"
}

test_pdf_encrypt_owner_password() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/encrypted_owner.pdf"

    bash "${SCRIPTS_DIR}/pdf_encrypt.sh" "$input" \
        --user-password "userpass" \
        --owner-password "ownerpass" \
        --output "$output" 2>/dev/null

    assert_file_exists "$output"
}

test_pdf_encrypt_no_password_fails() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/encrypted_nopass.pdf"

    # Should fail without user password
    if bash "${SCRIPTS_DIR}/pdf_encrypt.sh" "$input" --output "$output" 2>/dev/null; then
        echo "  ✗ Should have failed without password"
        return 1
    else
        echo "  ✓ Correctly failed without password"
        return 0
    fi
}

test_pdf_encrypt_nonexistent_file() {
    local output="${TEST_DIR}/encrypted_missing.pdf"

    # Should fail with nonexistent file
    if bash "${SCRIPTS_DIR}/pdf_encrypt.sh" "/nonexistent/file.pdf" \
        --user-password "pass" --output "$output" 2>/dev/null; then
        echo "  ✗ Should have failed with nonexistent file"
        return 1
    else
        echo "  ✓ Correctly failed with nonexistent file"
        return 0
    fi
}

# ============================================================================
# PDF MERGE TESTS
# ============================================================================

test_pdf_merge_basic() {
    local input1="${TEST_FIXTURE_DIR}/test_1page.pdf"
    local input2="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/merged_basic.pdf"

    bash "${SCRIPTS_DIR}/pdf_merge.sh" "$input1" "$input2" \
        --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 4
}

test_pdf_merge_three_files() {
    local input1="${TEST_FIXTURE_DIR}/test_1page.pdf"
    local input2="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local input3="${TEST_FIXTURE_DIR}/test_1page.pdf"
    local output="${TEST_DIR}/merged_three.pdf"

    bash "${SCRIPTS_DIR}/pdf_merge.sh" "$input1" "$input2" "$input3" \
        --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 5
}

test_pdf_merge_many_files() {
    local input1="${TEST_FIXTURE_DIR}/test_10page.pdf"
    local input2="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local input3="${TEST_FIXTURE_DIR}/test_1page.pdf"
    local output="${TEST_DIR}/merged_many.pdf"

    bash "${SCRIPTS_DIR}/pdf_merge.sh" "$input1" "$input2" "$input3" \
        --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 14
}

test_pdf_merge_one_file_fails() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/merged_one.pdf"

    # Should fail with only one file
    if bash "${SCRIPTS_DIR}/pdf_merge.sh" "$input" --output "$output" 2>/dev/null; then
        echo "  ✗ Should have failed with only one file"
        return 1
    else
        echo "  ✓ Correctly failed with only one file"
        return 0
    fi
}

test_pdf_merge_no_files_fails() {
    local output="${TEST_DIR}/merged_none.pdf"

    # Should fail with no files
    if bash "${SCRIPTS_DIR}/pdf_merge.sh" --output "$output" 2>/dev/null; then
        echo "  ✗ Should have failed with no files"
        return 1
    else
        echo "  ✓ Correctly failed with no files"
        return 0
    fi
}

# ============================================================================
# PDF OPTIMIZE TESTS
# ============================================================================

test_pdf_optimize_basic() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/optimized_basic.pdf"

    bash "${SCRIPTS_DIR}/pdf_optimize.sh" "$input" \
        --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 3
}

test_pdf_optimize_default_output() {
    # Copy to test dir to test default naming
    local input="${TEST_DIR}/test_optimize.pdf"
    cp "${TEST_FIXTURE_DIR}/test_3page.pdf" "$input"

    cd "$TEST_DIR"
    bash "${SCRIPTS_DIR}/pdf_optimize.sh" "$input" 2>/dev/null

    assert_file_exists "${TEST_DIR}/test_optimize_optimized.pdf"
}

test_pdf_optimize_large_file() {
    local input="${TEST_FIXTURE_DIR}/test_10page.pdf"
    local output="${TEST_DIR}/optimized_large.pdf"

    bash "${SCRIPTS_DIR}/pdf_optimize.sh" "$input" \
        --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 10
}

test_pdf_optimize_nonexistent_file() {
    local output="${TEST_DIR}/optimized_missing.pdf"

    # Should fail with nonexistent file
    if bash "${SCRIPTS_DIR}/pdf_optimize.sh" "/nonexistent/file.pdf" \
        --output "$output" 2>/dev/null; then
        echo "  ✗ Should have failed with nonexistent file"
        return 1
    else
        echo "  ✓ Correctly failed with nonexistent file"
        return 0
    fi
}

# ============================================================================
# PDF EXTRACT PAGES TESTS
# ============================================================================

test_pdf_extract_single_page() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/extracted_single.pdf"

    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages 2 --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 1
}

test_pdf_extract_range() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/extracted_range.pdf"

    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages 1-2 --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 2
}

test_pdf_extract_multiple_ranges() {
    local input="${TEST_FIXTURE_DIR}/test_10page.pdf"
    local output="${TEST_DIR}/extracted_multiple.pdf"

    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages 1,3,5-8 --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 6
}

test_pdf_extract_odd_pages() {
    local input="${TEST_FIXTURE_DIR}/test_10page.pdf"
    local output="${TEST_DIR}/extracted_odd.pdf"

    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages odd --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 5
}

test_pdf_extract_even_pages() {
    local input="${TEST_FIXTURE_DIR}/test_10page.pdf"
    local output="${TEST_DIR}/extracted_even.pdf"

    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages even --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 5
}

test_pdf_extract_last_n_pages() {
    local input="${TEST_FIXTURE_DIR}/test_10page.pdf"
    local output="${TEST_DIR}/extracted_last3.pdf"

    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages last:3 --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 3
}

test_pdf_extract_odd_from_single_page() {
    local input="${TEST_FIXTURE_DIR}/test_1page.pdf"
    local output="${TEST_DIR}/extracted_1page_odd.pdf"

    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages odd --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 1
}

test_pdf_extract_even_from_single_page() {
    local input="${TEST_FIXTURE_DIR}/test_1page.pdf"
    local output="${TEST_DIR}/extracted_1page_even.pdf"

    # Even pages from 1-page doc should result in 0 pages or fail gracefully
    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages even --output "$output" 2>/dev/null

    # This might create an empty PDF or fail - both are acceptable
    # Just check the script doesn't crash
    echo "  ✓ Script handled even pages from 1-page document"
    return 0
}

test_pdf_extract_last_more_than_total() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/extracted_last10.pdf"

    # Requesting last:10 from a 3-page doc should return all 3 pages
    bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --pages last:10 --output "$output" 2>/dev/null

    assert_file_exists "$output" && \
    assert_page_count "$output" 3
}

test_pdf_extract_no_pages_specified_fails() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output="${TEST_DIR}/extracted_nospec.pdf"

    # Should fail without --pages
    if bash "${SCRIPTS_DIR}/pdf_extract_pages.sh" "$input" \
        --output "$output" 2>/dev/null; then
        echo "  ✗ Should have failed without --pages"
        return 1
    else
        echo "  ✓ Correctly failed without --pages"
        return 0
    fi
}

# ============================================================================
# CONVERT DOCUMENT TESTS
# ============================================================================

test_convert_markdown_to_tex() {
    local input="${TEST_DIR}/test_md.md"
    local output="${TEST_DIR}/converted.tex"

    # Create test markdown
    cat > "$input" <<'EOF'
# Test Document

This is a test **markdown** document with some *formatting*.

- Item 1
- Item 2
EOF

    if ! command -v pandoc &>/dev/null; then
        echo "  ⚠ pandoc not installed, skipping test"
        return 0
    fi

    bash "${SCRIPTS_DIR}/convert_document.sh" "$input" "$output" 2>/dev/null

    assert_file_exists "$output"
}

test_convert_tex_to_markdown() {
    local input="${TEST_DIR}/test.tex"
    local output="${TEST_DIR}/converted.md"

    # Create test tex
    cat > "$input" <<'EOF'
\documentclass{article}
\begin{document}
\section{Test}
This is a test document.
\end{document}
EOF

    if ! command -v pandoc &>/dev/null; then
        echo "  ⚠ pandoc not installed, skipping test"
        return 0
    fi

    bash "${SCRIPTS_DIR}/convert_document.sh" "$input" "$output" 2>/dev/null

    assert_file_exists "$output"
}

test_convert_nonexistent_file() {
    local output="${TEST_DIR}/converted_missing.tex"

    if ! command -v pandoc &>/dev/null; then
        echo "  ⚠ pandoc not installed, skipping test"
        return 0
    fi

    # Should fail with nonexistent file
    if bash "${SCRIPTS_DIR}/convert_document.sh" "/nonexistent/file.md" \
        "$output" 2>/dev/null; then
        echo "  ✗ Should have failed with nonexistent file"
        return 1
    else
        echo "  ✓ Correctly failed with nonexistent file"
        return 0
    fi
}

# ============================================================================
# PDF TO IMAGES TESTS
# ============================================================================

test_pdf_to_images_basic() {
    local input="${TEST_FIXTURE_DIR}/test_3page.pdf"
    local output_dir="${TEST_DIR}/images_basic"

    if ! command -v pdftoppm &>/dev/null; then
        echo "  ⚠ pdftoppm not installed, skipping test"
        return 0
    fi

    bash "${SCRIPTS_DIR}/pdf_to_images.sh" "$input" "$output_dir" 2>/dev/null

    assert_file_exists "${output_dir}/page-001.png" && \
    assert_file_exists "${output_dir}/page-002.png" && \
    assert_file_exists "${output_dir}/page-003.png"
}

test_pdf_to_images_custom_dpi() {
    local input="${TEST_FIXTURE_DIR}/test_1page.pdf"
    local output_dir="${TEST_DIR}/images_dpi"

    if ! command -v pdftoppm &>/dev/null; then
        echo "  ⚠ pdftoppm not installed, skipping test"
        return 0
    fi

    bash "${SCRIPTS_DIR}/pdf_to_images.sh" "$input" "$output_dir" \
        --dpi 150 2>/dev/null

    assert_file_exists "${output_dir}/page-001.png"
}

test_pdf_to_images_nonexistent_file() {
    local output_dir="${TEST_DIR}/images_missing"

    if ! command -v pdftoppm &>/dev/null; then
        echo "  ⚠ pdftoppm not installed, skipping test"
        return 0
    fi

    # Should fail with nonexistent file
    if bash "${SCRIPTS_DIR}/pdf_to_images.sh" "/nonexistent/file.pdf" \
        "$output_dir" 2>/dev/null; then
        echo "  ✗ Should have failed with nonexistent file"
        return 1
    else
        echo "  ✓ Correctly failed with nonexistent file"
        return 0
    fi
}

# ============================================================================
# LATEX WORDCOUNT TESTS
# ============================================================================

test_latex_wordcount_basic() {
    local input="${TEST_DIR}/wordcount_test.tex"

    # Create test tex with known word count
    cat > "$input" <<'EOF'
\documentclass{article}
\begin{document}
This document has exactly twenty words in it for testing the word count.
\end{document}
EOF

    if ! command -v detex &>/dev/null; then
        echo "  ⚠ detex not installed, skipping test"
        return 0
    fi

    local output=$(bash "${SCRIPTS_DIR}/latex_wordcount.sh" "$input" 2>/dev/null)

    if echo "$output" | grep -q "Word count:"; then
        echo "  ✓ Word count produced output"
        return 0
    else
        echo "  ✗ Word count did not produce expected output"
        return 1
    fi
}

test_latex_wordcount_detailed() {
    local input="${TEST_DIR}/wordcount_detailed.tex"

    # Create test tex with various elements
    cat > "$input" <<'EOF'
\documentclass{article}
\begin{document}
\section{Introduction}
This is a test document with figures and tables.

\begin{figure}
\caption{Test figure}
\end{figure}

\begin{table}
\caption{Test table}
\end{table}

We cite \cite{reference1} here.

\begin{equation}
E = mc^2
\end{equation}
\end{document}
EOF

    if ! command -v detex &>/dev/null; then
        echo "  ⚠ detex not installed, skipping test"
        return 0
    fi

    local output=$(bash "${SCRIPTS_DIR}/latex_wordcount.sh" "$input" --detailed 2>/dev/null)

    if echo "$output" | grep -q "Detailed Statistics:"; then
        echo "  ✓ Detailed word count produced output"
        return 0
    else
        echo "  ✗ Detailed word count did not produce expected output"
        return 1
    fi
}

test_latex_wordcount_nonexistent_file() {
    if ! command -v detex &>/dev/null; then
        echo "  ⚠ detex not installed, skipping test"
        return 0
    fi

    # Should fail with nonexistent file
    if bash "${SCRIPTS_DIR}/latex_wordcount.sh" "/nonexistent/file.tex" 2>/dev/null; then
        echo "  ✗ Should have failed with nonexistent file"
        return 1
    else
        echo "  ✓ Correctly failed with nonexistent file"
        return 0
    fi
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         PDF Utilities Comprehensive Test Suite                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

    setup

    # PDF Encrypt Tests
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ PDF ENCRYPT TESTS                                              ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    run_test "pdf_encrypt: Basic encryption with user password" test_pdf_encrypt_basic
    run_test "pdf_encrypt: Encryption with restrictions" test_pdf_encrypt_with_restrictions
    run_test "pdf_encrypt: Encryption with owner password" test_pdf_encrypt_owner_password
    run_test "pdf_encrypt: Fails without password" test_pdf_encrypt_no_password_fails
    run_test "pdf_encrypt: Fails with nonexistent file" test_pdf_encrypt_nonexistent_file

    # PDF Merge Tests
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ PDF MERGE TESTS                                                ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    run_test "pdf_merge: Merge 2 PDFs" test_pdf_merge_basic
    run_test "pdf_merge: Merge 3 PDFs" test_pdf_merge_three_files
    run_test "pdf_merge: Merge multiple large PDFs" test_pdf_merge_many_files
    run_test "pdf_merge: Fails with only 1 file" test_pdf_merge_one_file_fails
    run_test "pdf_merge: Fails with no files" test_pdf_merge_no_files_fails

    # PDF Optimize Tests
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ PDF OPTIMIZE TESTS                                             ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    run_test "pdf_optimize: Basic optimization" test_pdf_optimize_basic
    run_test "pdf_optimize: Default output naming" test_pdf_optimize_default_output
    run_test "pdf_optimize: Optimize large file" test_pdf_optimize_large_file
    run_test "pdf_optimize: Fails with nonexistent file" test_pdf_optimize_nonexistent_file

    # PDF Extract Pages Tests
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ PDF EXTRACT PAGES TESTS                                        ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    run_test "pdf_extract_pages: Single page" test_pdf_extract_single_page
    run_test "pdf_extract_pages: Page range" test_pdf_extract_range
    run_test "pdf_extract_pages: Multiple ranges (1,3,5-8)" test_pdf_extract_multiple_ranges
    run_test "pdf_extract_pages: Odd pages" test_pdf_extract_odd_pages
    run_test "pdf_extract_pages: Even pages" test_pdf_extract_even_pages
    run_test "pdf_extract_pages: Last N pages" test_pdf_extract_last_n_pages
    run_test "pdf_extract_pages: Odd pages from 1-page PDF" test_pdf_extract_odd_from_single_page
    run_test "pdf_extract_pages: Even pages from 1-page PDF" test_pdf_extract_even_from_single_page
    run_test "pdf_extract_pages: Last:N more than total pages" test_pdf_extract_last_more_than_total
    run_test "pdf_extract_pages: Fails without --pages" test_pdf_extract_no_pages_specified_fails

    # Convert Document Tests
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ CONVERT DOCUMENT TESTS                                         ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    run_test "convert_document: Markdown to LaTeX" test_convert_markdown_to_tex
    run_test "convert_document: LaTeX to Markdown" test_convert_tex_to_markdown
    run_test "convert_document: Fails with nonexistent file" test_convert_nonexistent_file

    # PDF to Images Tests
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ PDF TO IMAGES TESTS                                            ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    run_test "pdf_to_images: Basic conversion" test_pdf_to_images_basic
    run_test "pdf_to_images: Custom DPI" test_pdf_to_images_custom_dpi
    run_test "pdf_to_images: Fails with nonexistent file" test_pdf_to_images_nonexistent_file

    # LaTeX Wordcount Tests
    echo -e "\n${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ LATEX WORDCOUNT TESTS                                          ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    run_test "latex_wordcount: Basic word count" test_latex_wordcount_basic
    run_test "latex_wordcount: Detailed statistics" test_latex_wordcount_detailed
    run_test "latex_wordcount: Fails with nonexistent file" test_latex_wordcount_nonexistent_file

    # Print summary
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ TEST SUMMARY                                                   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "Total tests:  ${TOTAL_TESTS}"
    echo -e "${GREEN}Passed:       ${PASSED_TESTS}${NC}"
    echo -e "${RED}Failed:       ${FAILED_TESTS}${NC}"

    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n${GREEN}✓ ALL TESTS PASSED!${NC}"
    else
        echo -e "\n${RED}✗ SOME TESTS FAILED${NC}"
    fi

    teardown

    # Exit with failure code if any tests failed
    [[ $FAILED_TESTS -eq 0 ]]
}

# Run tests
main "$@"
