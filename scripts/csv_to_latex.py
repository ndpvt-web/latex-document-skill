#!/usr/bin/env python3
"""
csv_to_latex.py
Converts CSV files to formatted LaTeX tabular code.

Examples:
    # Basic booktabs table with caption
    ./csv_to_latex.py data.csv --caption "Sales Data" --label "tab:sales"

    # Simple grid table with alternating row colors
    ./csv_to_latex.py data.csv --style grid --alternating-rows

    # Save to file with custom alignment
    ./csv_to_latex.py data.csv --align "lccr" --output table.tex

    # Truncate large tables
    ./csv_to_latex.py large_data.csv --max-rows 20 --caption "Truncated Results"
"""

import argparse
import sys
import pandas as pd
from pathlib import Path

def escape_latex(text):
    """Escape special LaTeX characters in text."""
    if pd.isna(text):
        return ""

    text = str(text)

    # Escape special characters
    replacements = {
        '\\': r'\textbackslash{}',
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
    }

    for char, replacement in replacements.items():
        text = text.replace(char, replacement)

    return text

def detect_alignment(df):
    """Auto-detect column alignment based on data types."""
    alignment = ""
    for col in df.columns:
        dtype = df[col].dtype
        if pd.api.types.is_numeric_dtype(dtype):
            alignment += "r"  # Right-align numbers
        else:
            alignment += "l"  # Left-align text
    return alignment

def generate_booktabs_table(df, caption, label, align, highlight_header, alternating_rows):
    """Generate a table using booktabs package (professional style)."""
    lines = []

    # Table environment
    lines.append(r"\begin{table}[htbp]")
    lines.append(r"    \centering")

    if caption:
        lines.append(f"    \\caption{{{escape_latex(caption)}}}")
    if label:
        lines.append(f"    \\label{{{label}}}")

    # Tabular environment
    lines.append(f"    \\begin{{tabular}}{{{align}}}")
    lines.append(r"        \toprule")

    # Header row
    headers = [escape_latex(col) for col in df.columns]
    if highlight_header:
        headers = [f"\\textbf{{{h}}}" for h in headers]
    lines.append("        " + " & ".join(headers) + r" \\")
    lines.append(r"        \midrule")

    # Data rows
    for idx, row in df.iterrows():
        escaped_row = [escape_latex(val) for val in row]
        row_str = " & ".join(escaped_row) + r" \\"

        if alternating_rows and idx % 2 == 1:
            lines.append(f"        \\rowcolor{{gray!10}} {row_str}")
        else:
            lines.append(f"        {row_str}")

    lines.append(r"        \bottomrule")
    lines.append(r"    \end{tabular}")
    lines.append(r"\end{table}")

    return "\n".join(lines)

def generate_grid_table(df, caption, label, align, highlight_header, alternating_rows):
    """Generate a table with full grid lines."""
    lines = []

    # Table environment
    lines.append(r"\begin{table}[htbp]")
    lines.append(r"    \centering")

    if caption:
        lines.append(f"    \\caption{{{escape_latex(caption)}}}")
    if label:
        lines.append(f"    \\label{{{label}}}")

    # Tabular environment with vertical lines
    align_with_lines = "|" + "|".join(list(align)) + "|"
    lines.append(f"    \\begin{{tabular}}{{{align_with_lines}}}")
    lines.append(r"        \hline")

    # Header row
    headers = [escape_latex(col) for col in df.columns]
    if highlight_header:
        headers = [f"\\textbf{{{h}}}" for h in headers]
    lines.append("        " + " & ".join(headers) + r" \\")
    lines.append(r"        \hline")

    # Data rows
    for idx, row in df.iterrows():
        escaped_row = [escape_latex(val) for val in row]
        row_str = " & ".join(escaped_row) + r" \\"

        if alternating_rows and idx % 2 == 1:
            lines.append(f"        \\rowcolor{{gray!10}} {row_str}")
        else:
            lines.append(f"        {row_str}")
        lines.append(r"        \hline")

    lines.append(r"    \end{tabular}")
    lines.append(r"\end{table}")

    return "\n".join(lines)

def generate_simple_table(df, caption, label, align, highlight_header, alternating_rows):
    """Generate a simple table with minimal lines."""
    lines = []

    # Table environment
    lines.append(r"\begin{table}[htbp]")
    lines.append(r"    \centering")

    if caption:
        lines.append(f"    \\caption{{{escape_latex(caption)}}}")
    if label:
        lines.append(f"    \\label{{{label}}}")

    # Tabular environment
    lines.append(f"    \\begin{{tabular}}{{{align}}}")
    lines.append(r"        \hline")

    # Header row
    headers = [escape_latex(col) for col in df.columns]
    if highlight_header:
        headers = [f"\\textbf{{{h}}}" for h in headers]
    lines.append("        " + " & ".join(headers) + r" \\")
    lines.append(r"        \hline")

    # Data rows
    for idx, row in df.iterrows():
        escaped_row = [escape_latex(val) for val in row]
        row_str = " & ".join(escaped_row) + r" \\"

        if alternating_rows and idx % 2 == 1:
            lines.append(f"        \\rowcolor{{gray!10}} {row_str}")
        else:
            lines.append(f"        {row_str}")

    lines.append(r"        \hline")
    lines.append(r"    \end{tabular}")
    lines.append(r"\end{table}")

    return "\n".join(lines)

def generate_plain_table(df, caption, label, align, highlight_header, alternating_rows):
    """Generate a plain table with no lines."""
    lines = []

    # Table environment
    lines.append(r"\begin{table}[htbp]")
    lines.append(r"    \centering")

    if caption:
        lines.append(f"    \\caption{{{escape_latex(caption)}}}")
    if label:
        lines.append(f"    \\label{{{label}}}")

    # Tabular environment
    lines.append(f"    \\begin{{tabular}}{{{align}}}")

    # Header row
    headers = [escape_latex(col) for col in df.columns]
    if highlight_header:
        headers = [f"\\textbf{{{h}}}" for h in headers]
    lines.append("        " + " & ".join(headers) + r" \\[0.5ex]")

    # Data rows
    for idx, row in df.iterrows():
        escaped_row = [escape_latex(val) for val in row]
        row_str = " & ".join(escaped_row) + r" \\"

        if alternating_rows and idx % 2 == 1:
            lines.append(f"        \\rowcolor{{gray!10}} {row_str}")
        else:
            lines.append(f"        {row_str}")

    lines.append(r"    \end{tabular}")
    lines.append(r"\end{table}")

    return "\n".join(lines)

STYLE_GENERATORS = {
    'booktabs': generate_booktabs_table,
    'grid': generate_grid_table,
    'simple': generate_simple_table,
    'plain': generate_plain_table,
}

def parse_args():
    parser = argparse.ArgumentParser(
        description='Convert CSV files to formatted LaTeX tabular code',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )

    parser.add_argument('csv_file', type=str,
                       help='Path to CSV file')
    parser.add_argument('--style', type=str, default='booktabs',
                       choices=STYLE_GENERATORS.keys(),
                       help='Table style (default: booktabs)')
    parser.add_argument('--caption', type=str, default='',
                       help='Table caption text')
    parser.add_argument('--label', type=str, default='',
                       help='Table label for cross-referencing (e.g., tab:results)')
    parser.add_argument('--align', type=str, default=None,
                       help='Column alignment string (e.g., "lcr") or auto-detect')
    parser.add_argument('--highlight-header', type=bool, default=True,
                       help='Bold headers (default: True)')
    parser.add_argument('--alternating-rows', action='store_true',
                       help='Use alternating row colors (requires xcolor package)')
    parser.add_argument('--max-rows', type=int, default=None,
                       help='Maximum number of rows (truncate with "..." row)')
    parser.add_argument('--output', type=str, default=None,
                       help='Output file path (default: stdout)')

    return parser.parse_args()

def main():
    args = parse_args()

    # Read CSV file
    try:
        csv_path = Path(args.csv_file)
        if not csv_path.exists():
            print(f"Error: CSV file not found: {args.csv_file}", file=sys.stderr)
            sys.exit(1)

        df = pd.read_csv(args.csv_file)

        if df.empty:
            print("Error: CSV file is empty", file=sys.stderr)
            sys.exit(1)

    except Exception as e:
        print(f"Error: Failed to read CSV file: {e}", file=sys.stderr)
        sys.exit(1)

    # Truncate if max_rows specified
    if args.max_rows and len(df) > args.max_rows:
        df = df.head(args.max_rows)
        # Add truncation row
        truncation_row = pd.DataFrame([["..." for _ in df.columns]], columns=df.columns)
        df = pd.concat([df, truncation_row], ignore_index=True)

    # Determine column alignment
    if args.align:
        if len(args.align) != len(df.columns):
            print(f"Error: Alignment string length ({len(args.align)}) must match number of columns ({len(df.columns)})", file=sys.stderr)
            sys.exit(1)
        align = args.align
    else:
        align = detect_alignment(df)

    # Generate table
    try:
        generator = STYLE_GENERATORS[args.style]
        latex_code = generator(
            df,
            args.caption,
            args.label,
            align,
            args.highlight_header,
            args.alternating_rows
        )
    except Exception as e:
        print(f"Error: Failed to generate LaTeX table: {e}", file=sys.stderr)
        sys.exit(1)

    # Add package requirements comment
    preamble = []
    preamble.append("% Required LaTeX packages:")
    if args.style == 'booktabs':
        preamble.append("% \\usepackage{booktabs}")
    if args.alternating_rows:
        preamble.append("% \\usepackage[table]{xcolor}")
    preamble.append("")

    output = "\n".join(preamble) + latex_code

    # Write output
    if args.output:
        try:
            output_path = Path(args.output)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(output)
            print(f"Successfully created: {args.output}", file=sys.stderr)
        except Exception as e:
            print(f"Error: Failed to write output file: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        print(output)

if __name__ == '__main__':
    main()
