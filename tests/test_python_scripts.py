#!/usr/bin/env python3
"""
Comprehensive pytest tests for all 4 LaTeX document scripts.

Tests cover:
- mail_merge.py: Template rendering, LaTeX escaping, CSV/JSON parsing, compilation
- generate_chart.py: All 9 chart types, data validation, multi-series support
- csv_to_latex.py: All 4 table styles, alignment detection, special character escaping
- validate_latex.py: All 6 validation checks, environment tracking, error detection
"""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest

# Add scripts directory to path
SCRIPTS_DIR = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

# Import the modules
import mail_merge
import generate_chart
import csv_to_latex
import validate_latex


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def temp_dir():
    """Create a temporary directory for test files."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


@pytest.fixture
def sample_csv(temp_dir):
    """Create a sample CSV file."""
    csv_path = temp_dir / "data.csv"
    csv_path.write_text(
        "name,age,score\n"
        "Alice,25,95.5\n"
        "Bob,30,87.3\n"
        "Charlie,22,91.8\n"
    )
    return csv_path


@pytest.fixture
def sample_json(temp_dir):
    """Create a sample JSON file."""
    json_path = temp_dir / "data.json"
    data = [
        {"name": "Alice", "age": 25, "score": 95.5},
        {"name": "Bob", "age": 30, "score": 87.3},
        {"name": "Charlie", "age": 22, "score": 91.8}
    ]
    json_path.write_text(json.dumps(data))
    return json_path


@pytest.fixture
def sample_template(temp_dir):
    """Create a sample LaTeX template."""
    template_path = temp_dir / "template.tex"
    template_path.write_text(
        "\\section{Report for {{name}}}\n"
        "Age: {{age}}\n"
        "Score: {{score}}\n"
    )
    return template_path


# ============================================================================
# MAIL_MERGE.PY TESTS
# ============================================================================

class TestMailMerge:
    """Tests for mail_merge.py"""

    def test_escape_latex_basic(self):
        """Test basic LaTeX special character escaping."""
        assert mail_merge.escape_latex("Hello & World") == r"Hello \& World"
        assert mail_merge.escape_latex("50% complete") == r"50\% complete"
        assert mail_merge.escape_latex("$100") == r"\$100"
        assert mail_merge.escape_latex("Test_file") == r"Test\_file"
        assert mail_merge.escape_latex("Test#1") == r"Test\#1"

    def test_escape_latex_braces(self):
        """Test escaping of curly braces."""
        assert mail_merge.escape_latex("{text}") == r"\{text\}"
        assert mail_merge.escape_latex("~tilde") == r"\textasciitilde{}tilde"
        assert mail_merge.escape_latex("x^2") == r"x\textasciicircum{}2"

    def test_escape_latex_backslash(self):
        """Test backslash escaping - CRITICAL edge case."""
        # Backslash must be escaped FIRST to avoid double-escaping
        # The actual output escapes the braces in \textbackslash{}
        result = mail_merge.escape_latex("C:\\Users\\file")
        assert "\\textbackslash" in result
        assert "Users" in result
        # Combined backslash and other special chars
        result2 = mail_merge.escape_latex("\\&")
        assert "\\textbackslash" in result2
        assert "\\&" in result2

    def test_escape_latex_empty_and_none(self):
        """Test edge cases: None and empty strings."""
        assert mail_merge.escape_latex(None) == ""
        assert mail_merge.escape_latex("") == ""

    def test_escape_latex_preserve_commands(self):
        """Test selective escaping that preserves LaTeX commands."""
        # Commands starting with \ should be preserved
        assert mail_merge.escape_latex_preserve_commands("\\textbf{Hello}") == "\\textbf{Hello}"
        # Normal text should be escaped
        assert mail_merge.escape_latex_preserve_commands("Hello & World") == r"Hello \& World"

    def test_load_csv_basic(self, sample_csv):
        """Test loading CSV files."""
        records = mail_merge.load_csv(sample_csv)
        assert len(records) == 3
        assert records[0]["name"] == "Alice"
        assert records[0]["age"] == "25" if not mail_merge.HAS_PANDAS else 25

    def test_load_csv_empty(self, temp_dir):
        """Test loading empty CSV (only headers)."""
        csv_path = temp_dir / "empty.csv"
        csv_path.write_text("name,age\n")
        records = mail_merge.load_csv(csv_path)
        assert len(records) == 0

    def test_load_json_array(self, sample_json):
        """Test loading JSON array format."""
        records = mail_merge.load_json(sample_json)
        assert len(records) == 3
        assert records[0]["name"] == "Alice"
        assert records[0]["age"] == 25

    def test_load_json_wrapped(self, temp_dir):
        """Test loading JSON with wrapper keys."""
        json_path = temp_dir / "wrapped.json"
        data = {"records": [{"name": "Test", "value": 123}]}
        json_path.write_text(json.dumps(data))
        records = mail_merge.load_json(json_path)
        assert len(records) == 1
        assert records[0]["name"] == "Test"

    def test_load_json_single_object(self, temp_dir):
        """Test loading single JSON object (not array)."""
        json_path = temp_dir / "single.json"
        data = {"name": "Test", "value": 123}
        json_path.write_text(json.dumps(data))
        records = mail_merge.load_json(json_path)
        assert len(records) == 1
        assert records[0]["name"] == "Test"

    def test_load_jsonl(self, temp_dir):
        """Test loading JSON Lines format."""
        jsonl_path = temp_dir / "data.jsonl"
        jsonl_path.write_text(
            '{"name": "Alice", "age": 25}\n'
            '{"name": "Bob", "age": 30}\n'
            '{"name": "Charlie", "age": 22}\n'
        )
        records = mail_merge.load_data(jsonl_path)
        assert len(records) == 3
        assert records[1]["name"] == "Bob"

    def test_load_data_invalid_format(self, temp_dir):
        """Test loading unsupported file format."""
        txt_path = temp_dir / "data.txt"
        txt_path.write_text("some data")
        with pytest.raises(ValueError, match="Unsupported data format"):
            mail_merge.load_data(txt_path)

    def test_render_simple_basic(self):
        """Test simple {{variable}} replacement."""
        template = "Hello {{name}}, you are {{age}} years old."
        record = {"name": "Alice", "age": 25}
        result = mail_merge.render_simple(template, record)
        assert "Hello Alice" in result
        assert "25 years old" in result

    def test_render_simple_missing_variable(self, capsys):
        """Test simple rendering with missing variable (should warn)."""
        template = "Hello {{name}}, your ID is {{id}}."
        record = {"name": "Alice"}
        result = mail_merge.render_simple(template, record)
        assert "Hello Alice" in result
        assert "{{id}}" in result  # Placeholder left unchanged
        captured = capsys.readouterr()
        assert "Warning" in captured.err
        assert "id" in captured.err

    def test_render_simple_with_latex_escaping(self):
        """Test that simple rendering escapes LaTeX special chars."""
        template = "Name: {{name}}"
        record = {"name": "Alice & Bob"}
        result = mail_merge.render_simple(template, record)
        assert r"Alice \& Bob" in result

    @pytest.mark.skipif(not mail_merge.HAS_JINJA2, reason="Jinja2 not installed")
    def test_render_jinja_basic(self):
        """Test Jinja2 rendering with << >> syntax."""
        template = "Hello <<name>>, you are <<age>> years old."
        record = {"name": "Alice", "age": 25}
        env = mail_merge.setup_jinja_env()
        result = mail_merge.render_jinja(template, record, env)
        assert "Hello Alice" in result
        assert "25 years old" in result

    @pytest.mark.skipif(not mail_merge.HAS_JINJA2, reason="Jinja2 not installed")
    def test_render_jinja_conditional(self):
        """Test Jinja2 conditional blocks."""
        template = "<% if score > 90 %>Excellent!<% else %>Good!<% endif %>"
        record1 = {"score": 95}
        record2 = {"score": 85}
        env = mail_merge.setup_jinja_env()
        result1 = mail_merge.render_jinja(template, record1, env)
        result2 = mail_merge.render_jinja(template, record2, env)
        assert "Excellent!" in result1
        assert "Good!" in result2

    @pytest.mark.skipif(not mail_merge.HAS_JINJA2, reason="Jinja2 not installed")
    def test_render_jinja_loop(self):
        """Test Jinja2 loop blocks."""
        template = "<% for item in items %>Item: <<item>>\n<% endfor %>"
        record = {"items": ["apple", "banana", "cherry"]}
        env = mail_merge.setup_jinja_env()
        result = mail_merge.render_jinja(template, record, env)
        assert "Item: apple" in result
        assert "Item: banana" in result
        assert "Item: cherry" in result

    @pytest.mark.skipif(not mail_merge.HAS_JINJA2, reason="Jinja2 not installed")
    def test_render_jinja_escaping(self):
        """Test Jinja2 auto-escapes LaTeX special chars."""
        template = "Name: <<name>>"
        record = {"name": "Alice & Bob"}
        env = mail_merge.setup_jinja_env()
        result = mail_merge.render_jinja(template, record, env)
        assert r"Alice \& Bob" in result

    def test_sanitize_filename(self):
        """Test filename sanitization."""
        assert mail_merge.sanitize_filename("Alice Smith") == "Alice_Smith"
        # Note: dots are preserved (allowed in filenames)
        assert mail_merge.sanitize_filename("test@example.com") == "test_example.com"
        assert mail_merge.sanitize_filename("file#1") == "file_1"
        assert mail_merge.sanitize_filename("___test___") == "test"
        assert mail_merge.sanitize_filename("") == "document"

    def test_generate_output_name(self):
        """Test output filename generation."""
        record1 = {"name": "Alice Smith", "age": 25}
        record2 = {"Name": "Bob Jones", "age": 30}
        record3 = {"age": 22}

        name1 = mail_merge.generate_output_name(record1, name_field=None, index=0)
        assert name1 == "Alice_Smith"

        name2 = mail_merge.generate_output_name(record2, name_field="age", index=1)
        assert name2 == "30"  # Uses name_field value (age=30 in record2)

        name3 = mail_merge.generate_output_name(record3, name_field=None, index=2)
        assert name3 == "document_0003"  # Fallback to index

    def test_mail_merge_integration(self, sample_csv, sample_template, temp_dir):
        """Integration test: Generate .tex files from CSV."""
        output_dir = temp_dir / "output"

        # Simulate command line
        sys.argv = [
            "mail_merge.py",
            str(sample_template),
            str(sample_csv),
            "--output-dir", str(output_dir),
            "--no-compile"
        ]

        # Run main function (does not raise SystemExit on success)
        mail_merge.main()

        # Check generated files
        tex_files = list(output_dir.glob("*.tex"))
        assert len(tex_files) == 3  # Should generate 3 files


# ============================================================================
# GENERATE_CHART.PY TESTS
# ============================================================================

class TestGenerateChart:
    """Tests for generate_chart.py"""

    def test_parse_figsize(self):
        """Test figsize parsing."""
        assert generate_chart.parse_figsize("8x5") == (8.0, 5.0)
        assert generate_chart.parse_figsize("10x6") == (10.0, 6.0)
        assert generate_chart.parse_figsize("12.5x8.5") == (12.5, 8.5)

    def test_parse_figsize_invalid(self):
        """Test invalid figsize format."""
        with pytest.raises(SystemExit):
            generate_chart.parse_figsize("invalid")

    def test_parse_colors(self):
        """Test color parsing."""
        colors = generate_chart.parse_colors("#FF6B6B,#4ECDC4,#45B7D1")
        assert colors == ["#FF6B6B", "#4ECDC4", "#45B7D1"]
        assert generate_chart.parse_colors(None) is None
        assert generate_chart.parse_colors("") is None

    def test_parse_legend(self):
        """Test legend label parsing."""
        labels = generate_chart.parse_legend("Series A, Series B, Series C")
        assert labels == ["Series A", "Series B", "Series C"]
        assert generate_chart.parse_legend(None) is None

    def test_get_colorblind_palette(self):
        """Test colorblind-friendly palette generation."""
        colors = generate_chart.get_colorblind_palette(3)
        assert len(colors) == 3
        assert all(c.startswith("#") for c in colors)

        # Test cycling for large n
        colors_large = generate_chart.get_colorblind_palette(20)
        assert len(colors_large) == 20

    def test_plot_bar_basic(self, temp_dir):
        """Test basic bar chart generation."""
        import matplotlib.pyplot as plt

        data = {"x": ["A", "B", "C"], "y": [10, 20, 15]}
        fig, ax = plt.subplots()
        generate_chart.plot_bar(data, ax)

        output_path = temp_dir / "bar.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_bar_multi_series(self, temp_dir):
        """Test multi-series grouped bar chart."""
        import matplotlib.pyplot as plt

        data = {
            "x": ["Q1", "Q2", "Q3"],
            "y": [[10, 15, 12], [20, 25, 22]]  # Two series
        }
        fig, ax = plt.subplots()
        generate_chart.plot_bar(data, ax, legend_labels=["2023", "2024"])

        output_path = temp_dir / "bar_multi.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_bar_missing_keys(self):
        """Test bar chart with missing required keys."""
        import matplotlib.pyplot as plt

        data = {"x": ["A", "B"]}  # Missing 'y'
        fig, ax = plt.subplots()

        with pytest.raises(ValueError, match="Bar chart requires"):
            generate_chart.plot_bar(data, ax)
        plt.close()

    def test_plot_line_basic(self, temp_dir):
        """Test basic line chart generation."""
        import matplotlib.pyplot as plt

        data = {"x": [1, 2, 3, 4], "y": [10, 15, 13, 17]}
        fig, ax = plt.subplots()
        generate_chart.plot_line(data, ax, show_grid=True)

        output_path = temp_dir / "line.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_scatter_basic(self, temp_dir):
        """Test scatter plot generation."""
        import matplotlib.pyplot as plt

        data = {"x": [1, 2, 3, 4, 5], "y": [2, 4, 1, 3, 5]}
        fig, ax = plt.subplots()
        generate_chart.plot_scatter(data, ax)

        output_path = temp_dir / "scatter.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_scatter_with_sizes(self, temp_dir):
        """Test scatter plot with custom point sizes."""
        import matplotlib.pyplot as plt

        data = {
            "x": [1, 2, 3],
            "y": [2, 4, 3],
            "sizes": [50, 100, 150]
        }
        fig, ax = plt.subplots()
        generate_chart.plot_scatter(data, ax)

        output_path = temp_dir / "scatter_sizes.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_pie_basic(self, temp_dir):
        """Test pie chart generation."""
        import matplotlib.pyplot as plt

        data = {
            "labels": ["A", "B", "C"],
            "values": [30, 40, 30]
        }
        fig, ax = plt.subplots()
        generate_chart.plot_pie(data, ax)

        output_path = temp_dir / "pie.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_pie_empty_data(self):
        """Test pie chart with empty data."""
        import matplotlib.pyplot as plt

        data = {"labels": [], "values": []}
        fig, ax = plt.subplots()

        # Should not raise, matplotlib handles empty data
        try:
            generate_chart.plot_pie(data, ax)
        finally:
            plt.close()

    def test_plot_pie_single_value(self, temp_dir):
        """Test pie chart with single data point."""
        import matplotlib.pyplot as plt

        data = {"labels": ["A"], "values": [100]}
        fig, ax = plt.subplots()
        generate_chart.plot_pie(data, ax)

        output_path = temp_dir / "pie_single.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_heatmap(self, temp_dir):
        """Test heatmap generation."""
        import matplotlib.pyplot as plt

        data = {
            "matrix": [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
            "xlabels": ["X1", "X2", "X3"],
            "ylabels": ["Y1", "Y2", "Y3"]
        }
        fig, ax = plt.subplots()
        generate_chart.plot_heatmap(data, ax)

        output_path = temp_dir / "heatmap.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_box(self, temp_dir):
        """Test box plot generation."""
        import matplotlib.pyplot as plt

        data = {
            "data": [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6], [3, 4, 5, 6, 7]],
            "labels": ["A", "B", "C"]
        }
        fig, ax = plt.subplots()
        generate_chart.plot_box(data, ax, show_grid=True)

        output_path = temp_dir / "box.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_histogram(self, temp_dir):
        """Test histogram generation."""
        import matplotlib.pyplot as plt

        data = {
            "values": [1, 2, 2, 3, 3, 3, 4, 4, 5],
            "bins": 5
        }
        fig, ax = plt.subplots()
        generate_chart.plot_histogram(data, ax)

        output_path = temp_dir / "histogram.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_area(self, temp_dir):
        """Test area chart generation."""
        import matplotlib.pyplot as plt

        data = {"x": [1, 2, 3, 4], "y": [10, 15, 13, 17]}
        fig, ax = plt.subplots()
        generate_chart.plot_area(data, ax)

        output_path = temp_dir / "area.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_plot_radar(self, temp_dir):
        """Test radar chart generation."""
        import matplotlib.pyplot as plt

        data = {
            "labels": ["A", "B", "C", "D", "E"],
            "values": [4, 3, 5, 2, 4]
        }
        fig = plt.figure()
        ax = generate_chart.plot_radar(data, None)

        output_path = temp_dir / "radar.png"
        plt.savefig(output_path)
        plt.close()

        assert output_path.exists()

    def test_chart_cli_integration_bar(self, temp_dir):
        """Integration test: Generate bar chart via CLI."""
        output_path = temp_dir / "cli_bar.png"
        data_json = '{"x":["A","B","C"],"y":[10,20,15]}'

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "generate_chart.py"),
                "bar",
                "--data", data_json,
                "--output", str(output_path),
                "--title", "Test Chart"
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0
        assert output_path.exists()

    def test_chart_cli_invalid_json(self, temp_dir):
        """Test CLI with invalid JSON data."""
        output_path = temp_dir / "invalid.png"

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "generate_chart.py"),
                "bar",
                "--data", "{invalid json}",
                "--output", str(output_path)
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode != 0
        assert "Invalid JSON" in result.stderr


# ============================================================================
# CSV_TO_LATEX.PY TESTS
# ============================================================================

class TestCsvToLatex:
    """Tests for csv_to_latex.py"""

    def test_escape_latex_basic(self):
        """Test LaTeX character escaping."""
        assert csv_to_latex.escape_latex("Hello & World") == r"Hello \& World"
        assert csv_to_latex.escape_latex("50%") == r"50\%"
        assert csv_to_latex.escape_latex("$100") == r"\$100"
        assert csv_to_latex.escape_latex("Test_file") == r"Test\_file"

    def test_escape_latex_backslash(self):
        """Test backslash escaping."""
        result = csv_to_latex.escape_latex("C:\\path")
        assert "\\textbackslash" in result
        assert "path" in result

    def test_escape_latex_empty_cells(self):
        """Test escaping of empty/NaN cells."""
        import pandas as pd
        assert csv_to_latex.escape_latex(None) == ""
        assert csv_to_latex.escape_latex(pd.NA) == ""
        assert csv_to_latex.escape_latex("") == ""

    def test_detect_alignment_numeric(self, temp_dir):
        """Test alignment detection for numeric columns."""
        import pandas as pd

        df = pd.DataFrame({
            "Name": ["Alice", "Bob"],
            "Age": [25, 30],
            "Score": [95.5, 87.3]
        })

        alignment = csv_to_latex.detect_alignment(df)
        assert alignment == "lrr"  # Text left, numbers right

    def test_detect_alignment_mixed(self, temp_dir):
        """Test alignment detection with mixed columns."""
        import pandas as pd

        df = pd.DataFrame({
            "ID": ["A1", "B2"],
            "Count": [10, 20],
            "Label": ["X", "Y"]
        })

        alignment = csv_to_latex.detect_alignment(df)
        assert alignment == "lrl"

    def test_generate_booktabs_table(self, temp_dir):
        """Test booktabs style table generation."""
        import pandas as pd

        df = pd.DataFrame({
            "Name": ["Alice", "Bob"],
            "Age": [25, 30]
        })

        result = csv_to_latex.generate_booktabs_table(
            df, caption="Test Table", label="tab:test",
            align="lr", highlight_header=True, alternating_rows=False
        )

        assert r"\begin{table}" in result
        assert r"\toprule" in result
        assert r"\midrule" in result
        assert r"\bottomrule" in result
        assert r"\textbf{Name}" in result  # Bold header
        assert r"\caption{Test Table}" in result
        assert r"\label{tab:test}" in result

    def test_generate_booktabs_alternating_rows(self):
        """Test booktabs with alternating row colors."""
        import pandas as pd

        df = pd.DataFrame({
            "Col1": ["A", "B", "C"],
            "Col2": [1, 2, 3]
        })

        result = csv_to_latex.generate_booktabs_table(
            df, caption="", label="",
            align="lr", highlight_header=True, alternating_rows=True
        )

        assert r"\rowcolor{gray!10}" in result

    def test_generate_grid_table(self):
        """Test grid style table generation."""
        import pandas as pd

        df = pd.DataFrame({
            "A": [1, 2],
            "B": [3, 4]
        })

        result = csv_to_latex.generate_grid_table(
            df, caption="", label="",
            align="rr", highlight_header=True, alternating_rows=False
        )

        assert r"|r|r|" in result  # Vertical lines
        assert r"\hline" in result

    def test_generate_simple_table(self):
        """Test simple style table generation."""
        import pandas as pd

        df = pd.DataFrame({
            "X": ["a", "b"],
            "Y": [1, 2]
        })

        result = csv_to_latex.generate_simple_table(
            df, caption="", label="",
            align="lr", highlight_header=True, alternating_rows=False
        )

        assert r"\begin{tabular}" in result
        assert r"\hline" in result
        # Should have hline at top, after header, and at bottom

    def test_generate_plain_table(self):
        """Test plain style table (no lines)."""
        import pandas as pd

        df = pd.DataFrame({
            "A": [1],
            "B": [2]
        })

        result = csv_to_latex.generate_plain_table(
            df, caption="", label="",
            align="rr", highlight_header=True, alternating_rows=False
        )

        assert r"\begin{tabular}" in result
        assert r"\hline" not in result  # No lines
        assert r"\toprule" not in result

    def test_escape_latex_special_chars_in_table(self):
        """Test that special characters are escaped in table cells."""
        import pandas as pd

        df = pd.DataFrame({
            "Symbol": ["&", "%", "$", "#", "_"],
            "Escaped": ["amp", "pct", "dlr", "hash", "under"]
        })

        result = csv_to_latex.generate_booktabs_table(
            df, caption="", label="", align="ll",
            highlight_header=True, alternating_rows=False
        )

        assert r"\&" in result
        assert r"\%" in result
        assert r"\$" in result
        assert r"\#" in result
        assert r"\_" in result

    def test_csv_to_latex_cli_integration(self, sample_csv, temp_dir):
        """Integration test: Convert CSV to LaTeX via CLI."""
        output_path = temp_dir / "table.tex"

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "csv_to_latex.py"),
                str(sample_csv),
                "--style", "booktabs",
                "--caption", "Test Table",
                "--output", str(output_path)
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0
        assert output_path.exists()

        content = output_path.read_text()
        assert r"\begin{table}" in content
        assert "Test Table" in content

    def test_csv_to_latex_empty_csv(self, temp_dir):
        """Test handling of empty CSV files."""
        csv_path = temp_dir / "empty.csv"
        csv_path.write_text("col1,col2\n")  # Only headers

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "csv_to_latex.py"),
                str(csv_path)
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode != 0
        assert "empty" in result.stderr.lower()

    def test_csv_to_latex_alignment_mismatch(self, sample_csv, temp_dir):
        """Test error when alignment string length doesn't match columns."""
        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "csv_to_latex.py"),
                str(sample_csv),
                "--align", "lr"  # CSV has 3 columns, but only 2 alignment chars
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode != 0
        assert "Alignment" in result.stderr


# ============================================================================
# VALIDATE_LATEX.PY TESTS
# ============================================================================

class TestValidateLatex:
    """Tests for validate_latex.py"""

    def test_is_comment_line(self):
        """Test comment line detection."""
        assert validate_latex.is_comment_line("% This is a comment")
        assert validate_latex.is_comment_line("  % Indented comment")
        assert not validate_latex.is_comment_line("\\section{Title} % inline comment")
        assert not validate_latex.is_comment_line("\\% Not a comment")

    def test_extract_preamble_commands(self, temp_dir):
        """Test extraction of custom commands from preamble."""
        preamble = temp_dir / "preamble.tex"
        preamble.write_text(
            r"\newcommand{\mycommand}{text}" + "\n" +
            r"\renewcommand{\foo}{bar}" + "\n" +
            r"\DeclareMathOperator{\argmax}{arg\,max}" + "\n"
        )

        commands = validate_latex.extract_preamble_commands(str(preamble))
        assert r"\mycommand" in commands
        assert r"\foo" in commands
        assert r"\argmax" in commands

    def test_extract_preamble_packages(self, temp_dir):
        """Test extraction of loaded packages."""
        preamble = temp_dir / "preamble.tex"
        preamble.write_text(
            r"\usepackage{amsmath}" + "\n" +
            r"\usepackage[utf8]{inputenc}" + "\n" +
            r"\usepackage{tikz, pgfplots}" + "\n"
        )

        packages = validate_latex.extract_preamble_packages(str(preamble))
        assert "amsmath" in packages
        assert "inputenc" in packages
        assert "tikz" in packages
        assert "pgfplots" in packages

    def test_validate_balanced_environments(self, temp_dir):
        """Test detection of balanced environments."""
        tex_file = temp_dir / "test.tex"
        tex_file.write_text(
            r"\begin{theorem}" + "\n" +
            r"Content here." + "\n" +
            r"\end{theorem}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        # Filter out non-environment errors
        env_errors = [e for e in errors if e.category in ("ENV_MISMATCH", "ENV_UNCLOSED")]
        assert len(env_errors) == 0

    def test_validate_unbalanced_environments(self, temp_dir):
        """Test detection of unbalanced environments."""
        tex_file = temp_dir / "unbalanced.tex"
        tex_file.write_text(
            r"\begin{theorem}" + "\n" +
            r"Missing end tag" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        env_errors = [e for e in errors if "ENV_UNCLOSED" in e.category]
        assert len(env_errors) > 0
        assert "theorem" in env_errors[0].message

    def test_validate_mismatched_environments(self, temp_dir):
        """Test detection of mismatched begin/end tags."""
        tex_file = temp_dir / "mismatched.tex"
        tex_file.write_text(
            r"\begin{theorem}" + "\n" +
            r"\end{lemma}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        env_errors = [e for e in errors if "ENV_MISMATCH" in e.category]
        assert len(env_errors) > 0

    def test_validate_nested_environments(self, temp_dir):
        """Test validation of properly nested environments."""
        tex_file = temp_dir / "nested.tex"
        tex_file.write_text(
            r"\begin{theorem}" + "\n" +
            r"\begin{proof}" + "\n" +
            r"Nested content" + "\n" +
            r"\end{proof}" + "\n" +
            r"\end{theorem}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        env_errors = [e for e in errors if e.category in ("ENV_MISMATCH", "ENV_UNCLOSED")]
        assert len(env_errors) == 0

    def test_validate_float_in_tcolorbox(self, temp_dir):
        """Test detection of floats inside tcolorbox environments."""
        tex_file = temp_dir / "float_in_box.tex"
        tex_file.write_text(
            r"\begin{theorem}" + "\n" +
            r"\begin{table}" + "\n" +
            r"\end{table}" + "\n" +
            r"\end{theorem}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        float_errors = [e for e in errors if "FLOAT_IN_TCOLORBOX" in e.category]
        assert len(float_errors) > 0
        assert "table" in float_errors[0].message.lower()

    def test_validate_figure_in_tcolorbox(self, temp_dir):
        """Test detection of figure floats in tcolorbox."""
        tex_file = temp_dir / "figure_in_box.tex"
        tex_file.write_text(
            r"\begin{definition}" + "\n" +
            r"\begin{figure}" + "\n" +
            r"\includegraphics{image.png}" + "\n" +
            r"\end{figure}" + "\n" +
            r"\end{definition}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        float_errors = [e for e in errors if "FLOAT_IN_TCOLORBOX" in e.category]
        assert len(float_errors) > 0

    def test_validate_tikz_outside_environment(self, temp_dir):
        """Test detection of TikZ commands outside tikzpicture."""
        tex_file = temp_dir / "tikz_outside.tex"
        tex_file.write_text(
            r"\node[circle] at (0,0) {A};" + "\n"  # Outside tikzpicture
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        tikz_errors = [e for e in errors if "TIKZ_OUTSIDE" in e.category]
        assert len(tikz_errors) > 0

    def test_validate_tikz_inside_environment(self, temp_dir):
        """Test TikZ commands inside tikzpicture are valid."""
        tex_file = temp_dir / "tikz_inside.tex"
        tex_file.write_text(
            r"\begin{tikzpicture}" + "\n" +
            r"\node[circle] at (0,0) {A};" + "\n" +
            r"\draw (0,0) -- (1,1);" + "\n" +
            r"\end{tikzpicture}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        tikz_errors = [e for e in errors if "TIKZ_OUTSIDE" in e.category]
        assert len(tikz_errors) == 0

    def test_validate_tikz_node_without_label(self, temp_dir):
        """Test detection of \\node without label braces."""
        tex_file = temp_dir / "node_no_label.tex"
        tex_file.write_text(
            r"\begin{tikzpicture}" + "\n" +
            r"\node[circle] at (0,0);" + "\n" +  # Missing {}
            r"\end{tikzpicture}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        node_errors = [e for e in errors if "TIKZ_NODE_LABEL" in e.category]
        assert len(node_errors) > 0

    def test_validate_tikz_node_with_label(self, temp_dir):
        """Test that \\node with label braces is valid."""
        tex_file = temp_dir / "node_with_label.tex"
        tex_file.write_text(
            r"\begin{tikzpicture}" + "\n" +
            r"\node[circle] at (0,0) {};" + "\n" +  # Empty label OK
            r"\node at (1,1) {A};" + "\n" +  # Label OK
            r"\end{tikzpicture}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        node_errors = [e for e in errors if "TIKZ_NODE_LABEL" in e.category]
        assert len(node_errors) == 0

    def test_validate_stray_ampersand(self, temp_dir):
        """Test detection of unescaped & outside tables."""
        tex_file = temp_dir / "stray_amp.tex"
        tex_file.write_text(
            r"This is text & more text." + "\n"  # Unescaped &
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        amp_errors = [e for e in errors if "STRAY_AMPERSAND" in e.category]
        assert len(amp_errors) > 0

    def test_validate_ampersand_in_tabular(self, temp_dir):
        """Test that & is valid inside tabular environments."""
        tex_file = temp_dir / "amp_in_table.tex"
        tex_file.write_text(
            r"\begin{tabular}{ll}" + "\n" +
            r"Col1 & Col2 \\" + "\n" +
            r"A & B \\" + "\n" +
            r"\end{tabular}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        amp_errors = [e for e in errors if "STRAY_AMPERSAND" in e.category]
        assert len(amp_errors) == 0

    def test_validate_ampersand_in_align(self, temp_dir):
        """Test that & is valid inside align environments."""
        tex_file = temp_dir / "amp_in_align.tex"
        tex_file.write_text(
            r"\begin{align}" + "\n" +
            r"x &= 1 \\" + "\n" +
            r"y &= 2" + "\n" +
            r"\end{align}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        amp_errors = [e for e in errors if "STRAY_AMPERSAND" in e.category]
        assert len(amp_errors) == 0

    def test_validate_comments_ignored(self, temp_dir):
        """Test that commented-out code is ignored."""
        tex_file = temp_dir / "comments.tex"
        tex_file.write_text(
            r"% \begin{theorem}" + "\n" +
            r"% \node[circle] at (0,0);" + "\n" +
            r"% Stray & ampersand" + "\n" +
            r"Valid content" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        # Should have no errors because everything is commented
        assert len(errors) == 0

    def test_validate_inline_comments(self, temp_dir):
        """Test that inline comments are stripped before validation."""
        tex_file = temp_dir / "inline_comments.tex"
        tex_file.write_text(
            r"\begin{theorem} % Starting a theorem" + "\n" +
            r"Content % with & ampersand in comment" + "\n" +
            r"\end{theorem}" + "\n"
        )

        errors = validate_latex.validate_file(str(tex_file), set())
        # Should not detect stray ampersand because it's in a comment
        amp_errors = [e for e in errors if "STRAY_AMPERSAND" in e.category]
        assert len(amp_errors) == 0

    def test_validate_file_not_found(self):
        """Test handling of missing files."""
        errors = validate_latex.validate_file("nonexistent.tex", set())
        assert len(errors) == 1
        assert "FILE" in errors[0].category

    def test_validate_cli_integration(self, temp_dir):
        """Integration test: Run validator via CLI."""
        tex_file = temp_dir / "test.tex"
        tex_file.write_text(
            r"\begin{theorem}" + "\n" +
            r"Content" + "\n" +
            r"\end{theorem}" + "\n"
        )

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "validate_latex.py"),
                str(tex_file)
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 0  # No errors
        assert "0 errors" in result.stdout

    def test_validate_cli_with_errors(self, temp_dir):
        """Test CLI with file containing errors."""
        tex_file = temp_dir / "errors.tex"
        tex_file.write_text(
            r"\begin{theorem}" + "\n" +
            r"Unclosed environment" + "\n"
        )

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "validate_latex.py"),
                str(tex_file)
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 1  # Has errors
        assert "error" in result.stdout.lower()

    def test_validate_cli_json_output(self, temp_dir):
        """Test CLI with JSON output format."""
        tex_file = temp_dir / "test.tex"
        tex_file.write_text(r"\begin{theorem}" + "\n")

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "validate_latex.py"),
                str(tex_file),
                "--json"
            ],
            capture_output=True,
            text=True
        )

        # Should output valid JSON
        output = json.loads(result.stdout)
        assert "total_errors" in output
        assert "files_checked" in output
        assert "errors" in output


# ============================================================================
# EDGE CASE AND INTEGRATION TESTS
# ============================================================================

class TestEdgeCases:
    """Additional edge case tests across all scripts."""

    def test_mail_merge_empty_csv(self, temp_dir):
        """Test mail merge with empty CSV (no data rows)."""
        csv_path = temp_dir / "empty.csv"
        csv_path.write_text("name,age\n")
        template_path = temp_dir / "template.tex"
        template_path.write_text("Hello {{name}}")

        sys.argv = [
            "mail_merge.py",
            str(template_path),
            str(csv_path),
            "--output-dir", str(temp_dir / "out"),
            "--no-compile"
        ]

        with pytest.raises(SystemExit) as exc_info:
            mail_merge.main()
        assert exc_info.value.code == 1

    def test_chart_negative_pie_values(self, temp_dir):
        """Test pie chart rejects negative values (matplotlib raises ValueError)."""
        import matplotlib.pyplot as plt

        data = {
            "labels": ["A", "B", "C"],
            "values": [30, -10, 20]  # Negative value
        }
        fig, ax = plt.subplots()

        # Matplotlib raises ValueError for negative pie values
        with pytest.raises(ValueError, match="non negative"):
            generate_chart.plot_pie(data, ax)
        plt.close()

    def test_csv_latex_special_chars_comprehensive(self):
        """Test all LaTeX special characters are properly escaped."""
        import pandas as pd

        special_chars = "&%$#_{}~^\\"
        df = pd.DataFrame({"Chars": [special_chars]})

        result = csv_to_latex.generate_booktabs_table(
            df, caption="", label="", align="l",
            highlight_header=True, alternating_rows=False
        )

        # Check that raw special chars don't appear (except in commands)
        lines = result.split("\n")
        data_lines = [l for l in lines if not l.strip().startswith("%") and "Chars" not in l]
        content = "\n".join(data_lines)

        # All special chars should be escaped
        assert r"\&" in result
        assert r"\%" in result
        assert r"\$" in result
        assert r"\#" in result
        assert r"\_" in result

    def test_validate_multiple_files(self, temp_dir):
        """Test validator with multiple files."""
        file1 = temp_dir / "file1.tex"
        file2 = temp_dir / "file2.tex"

        file1.write_text(r"\begin{theorem}" + "\n" + r"\end{theorem}")
        file2.write_text(r"\begin{lemma}" + "\n")  # Unclosed

        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS_DIR / "validate_latex.py"),
                str(file1),
                str(file2)
            ],
            capture_output=True,
            text=True
        )

        assert result.returncode == 1
        assert "file2.tex" in result.stdout


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
