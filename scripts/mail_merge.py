#!/usr/bin/env python3
"""
mail_merge.py - Generate personalized LaTeX documents from templates + data sources.

Reads a LaTeX template with {{placeholder}} variables and a CSV or JSON data source,
generates one .tex file per record, compiles each to PDF, and optionally merges all PDFs.

Supports:
  - CSV and JSON data sources
  - Jinja2-style {{variable}} placeholders in LaTeX templates
  - Conditional sections: {% if variable %}...{% endif %}
  - Loop sections: {% for item in items %}...{% endfor %}
  - LaTeX special character auto-escaping in data values
  - Parallel compilation with configurable worker count
  - Output file naming from data fields
  - Merged PDF output (all documents in one file)
  - Error logging and graceful failure handling

Examples:
    # Basic mail merge from CSV
    python3 mail_merge.py template.tex data.csv --output-dir ./outputs

    # Mail merge from JSON with custom naming
    python3 mail_merge.py template.tex students.json --output-dir ./outputs --name-field "last_name"

    # Merge all into single PDF
    python3 mail_merge.py template.tex data.csv --output-dir ./outputs --merge --merge-name "all_letters.pdf"

    # Parallel compilation (4 workers)
    python3 mail_merge.py template.tex data.csv --output-dir ./outputs --workers 4

    # Custom compile script
    python3 mail_merge.py template.tex data.csv --output-dir ./outputs --compile-script ./scripts/compile_latex.sh

Dependencies:
    - Python 3.7+
    - jinja2 (pip install jinja2)
    - pandas (pip install pandas) -- for CSV reading
    - pdflatex/xelatex/lualatex -- for compilation
    - pdfunite (from poppler-utils) -- for PDF merging (optional)
"""

import argparse
import csv
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

# Try importing optional dependencies
try:
    import jinja2
    HAS_JINJA2 = True
except ImportError:
    HAS_JINJA2 = False

try:
    import pandas as pd
    HAS_PANDAS = True
except ImportError:
    HAS_PANDAS = False


# --- LaTeX escaping ---

LATEX_SPECIAL_CHARS = {
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

def escape_latex(value):
    """Escape special LaTeX characters in a string value."""
    if value is None:
        return ''
    s = str(value)
    # First escape backslashes (must be first to avoid double-escaping)
    s = s.replace('\\', r'\textbackslash{}')
    # Then escape other special chars
    for char, replacement in LATEX_SPECIAL_CHARS.items():
        s = s.replace(char, replacement)
    return s


def escape_latex_preserve_commands(value):
    """Escape LaTeX specials but preserve intentional LaTeX commands.

    If a value starts with '\\' (literal backslash indicating a LaTeX command),
    it is returned as-is. Otherwise, standard escaping is applied.
    """
    if value is None:
        return ''
    s = str(value)
    if s.startswith('\\'):
        return s  # Assume intentional LaTeX
    return escape_latex(s)


# --- Data loading ---

def load_csv(path):
    """Load records from a CSV file. Returns list of dicts."""
    if HAS_PANDAS:
        df = pd.read_csv(path, keep_default_na=False)
        return df.to_dict('records')
    else:
        with open(path, 'r', newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            return list(reader)


def load_json(path):
    """Load records from a JSON file. Supports array of objects or {records: [...]}."""
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if isinstance(data, list):
        return data
    elif isinstance(data, dict):
        # Look for common wrapper keys
        for key in ('records', 'data', 'items', 'rows', 'entries'):
            if key in data and isinstance(data[key], list):
                return data[key]
        # Single record
        return [data]
    else:
        raise ValueError(f"Unsupported JSON structure in {path}")


def load_data(path):
    """Auto-detect format and load data records."""
    path = Path(path)
    ext = path.suffix.lower()

    if ext == '.csv':
        return load_csv(path)
    elif ext in ('.json', '.jsonl'):
        if ext == '.jsonl':
            records = []
            with open(path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line:
                        records.append(json.loads(line))
            return records
        return load_json(path)
    else:
        raise ValueError(f"Unsupported data format: {ext}. Use .csv or .json")


# --- Template rendering ---

def setup_jinja_env():
    """Create a Jinja2 environment configured for LaTeX templates."""
    env = jinja2.Environment(
        # Use block/variable/comment strings that don't conflict with LaTeX
        block_start_string='<%',
        block_end_string='%>',
        variable_start_string='<<',
        variable_end_string='>>',
        comment_start_string='<#',
        comment_end_string='#>',
        # Auto-escape is off (we handle LaTeX escaping ourselves)
        autoescape=False,
        # Keep trailing newline
        keep_trailing_newline=True,
        # Undefined variables raise errors
        undefined=jinja2.StrictUndefined,
    )
    # Add LaTeX escape filter
    env.filters['e'] = escape_latex
    env.filters['escape_latex'] = escape_latex
    env.filters['raw'] = lambda x: x  # Pass through without escaping
    return env


def render_simple(template_str, record):
    """Simple {{variable}} replacement without Jinja2.

    Supports only basic variable substitution (no conditionals or loops).
    Variables are auto-escaped for LaTeX.
    """
    def replace_var(match):
        var_name = match.group(1).strip()
        if var_name in record:
            return escape_latex(record[var_name])
        else:
            print(f"  Warning: Variable '{var_name}' not found in record", file=sys.stderr)
            return match.group(0)  # Leave placeholder as-is

    # Match {{variable_name}} patterns
    return re.sub(r'\{\{(\s*\w+\s*)\}\}', replace_var, template_str)


def render_jinja(template_str, record, env):
    """Render template using Jinja2 with LaTeX-safe delimiters.

    Uses << >> for variables and <% %> for blocks to avoid LaTeX conflicts.
    Data values are auto-escaped unless |raw filter is used.
    """
    template = env.from_string(template_str)

    # Auto-escape all string values in record
    escaped_record = {}
    for key, value in record.items():
        if isinstance(value, str):
            escaped_record[key] = escape_latex(value)
        elif isinstance(value, list):
            escaped_record[key] = [
                {k: escape_latex(v) if isinstance(v, str) else v for k, v in item.items()}
                if isinstance(item, dict) else
                escape_latex(item) if isinstance(item, str) else item
                for item in value
            ]
        else:
            escaped_record[key] = value

    return template.render(**escaped_record)


def render_template(template_str, record, use_jinja=None):
    """Render a template with the given record data.

    Auto-detects whether to use Jinja2 or simple replacement based on
    template content (presence of <% %> or << >> delimiters).
    """
    if use_jinja is None:
        # Auto-detect: use Jinja2 if template contains block/advanced syntax
        # Strip LaTeX comment lines (lines starting with %) before checking
        non_comment_lines = '\n'.join(
            line for line in template_str.split('\n')
            if not line.lstrip().startswith('%')
        )
        use_jinja = bool(re.search(r'<%|<<|<#', non_comment_lines))

    if use_jinja:
        if not HAS_JINJA2:
            print("Error: Jinja2 required for advanced templates. Install with: pip install jinja2",
                  file=sys.stderr)
            sys.exit(1)
        env = setup_jinja_env()
        return render_jinja(template_str, record, env)
    else:
        return render_simple(template_str, record)


# --- Compilation ---

def compile_tex(tex_path, compile_script=None, engine=None):
    """Compile a .tex file to PDF. Returns (success, pdf_path, error_msg)."""
    tex_path = Path(tex_path)
    pdf_path = tex_path.with_suffix('.pdf')

    if compile_script:
        cmd = ['bash', compile_script, str(tex_path)]
    else:
        # Direct compilation
        eng = engine or 'pdflatex'
        cmd = [eng, '-interaction=nonstopmode', '-output-directory',
               str(tex_path.parent), str(tex_path)]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120,
            cwd=str(tex_path.parent)
        )

        if pdf_path.exists():
            return (True, str(pdf_path), None)
        else:
            error_lines = result.stderr[-500:] if result.stderr else result.stdout[-500:]
            return (False, None, f"No PDF produced. Output:\n{error_lines}")

    except subprocess.TimeoutExpired:
        return (False, None, "Compilation timed out (120s)")
    except FileNotFoundError as e:
        return (False, None, f"Command not found: {e}")
    except Exception as e:
        return (False, None, str(e))


def compile_record(args_tuple):
    """Wrapper for parallel compilation. Takes (tex_path, compile_script, engine, index)."""
    tex_path, compile_script, engine, index = args_tuple
    success, pdf_path, error = compile_tex(tex_path, compile_script, engine)
    return (index, success, pdf_path, error)


# --- PDF merging ---

def merge_pdfs(pdf_paths, output_path):
    """Merge multiple PDFs into one using pdfunite (poppler-utils)."""
    if not pdf_paths:
        print("Warning: No PDFs to merge", file=sys.stderr)
        return False

    # Check for pdfunite
    if not shutil.which('pdfunite'):
        print("Installing poppler-utils for PDF merging...", file=sys.stderr)
        # Cross-platform package installation
        install_cmds = [
            (['apt-get', 'install', '-y', '-q', 'poppler-utils'], 'apt-get'),
            (['dnf', 'install', '-y', '-q', 'poppler-utils'], 'dnf'),
            (['brew', 'install', 'poppler'], 'brew'),
            (['apk', 'add', '--no-cache', 'poppler-utils'], 'apk'),
            (['pacman', '-S', '--noconfirm', 'poppler'], 'pacman'),
        ]
        installed = False
        for cmd, mgr in install_cmds:
            if shutil.which(mgr):
                # Prepend sudo for non-brew package managers if available
                if mgr != 'brew' and shutil.which('sudo'):
                    cmd = ['sudo'] + cmd
                result = subprocess.run(cmd, capture_output=True)
                if result.returncode == 0:
                    installed = True
                break
        if not installed and not shutil.which('pdfunite'):
            print("Error: pdfunite not available. Install poppler-utils.", file=sys.stderr)
            return False

    cmd = ['pdfunite'] + [str(p) for p in pdf_paths] + [str(output_path)]
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0 and Path(output_path).exists():
        return True
    else:
        print(f"Error merging PDFs: {result.stderr}", file=sys.stderr)
        return False


# --- Output naming ---

def sanitize_filename(name):
    """Make a string safe for use as a filename."""
    # Replace spaces and special chars with underscores
    name = re.sub(r'[^\w\-.]', '_', str(name))
    # Collapse multiple underscores
    name = re.sub(r'_+', '_', name)
    # Remove leading/trailing underscores
    name = name.strip('_')
    return name or 'document'


def generate_output_name(record, name_field=None, index=0, prefix=''):
    """Generate an output filename for a record."""
    if name_field and name_field in record:
        base = sanitize_filename(record[name_field])
    elif 'name' in record:
        base = sanitize_filename(record['name'])
    elif 'Name' in record:
        base = sanitize_filename(record['Name'])
    else:
        base = f"document_{index + 1:04d}"

    if prefix:
        base = f"{prefix}_{base}"

    return base


# --- Main workflow ---

def main():
    parser = argparse.ArgumentParser(
        description='Generate personalized LaTeX documents from templates + data sources',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )

    parser.add_argument('template', help='LaTeX template file (.tex)')
    parser.add_argument('data', help='Data source file (.csv or .json)')
    parser.add_argument('--output-dir', '-o', default='./outputs',
                        help='Output directory (default: ./outputs)')
    parser.add_argument('--name-field', '-n', default=None,
                        help='Data field to use for output filenames')
    parser.add_argument('--prefix', default='',
                        help='Prefix for output filenames')
    parser.add_argument('--compile-script', default=None,
                        help='Path to compile script (default: use pdflatex directly)')
    parser.add_argument('--engine', default=None,
                        choices=['pdflatex', 'xelatex', 'lualatex'],
                        help='LaTeX engine (default: pdflatex)')
    parser.add_argument('--workers', '-w', type=int, default=1,
                        help='Number of parallel compilation workers (default: 1)')
    parser.add_argument('--merge', action='store_true',
                        help='Merge all PDFs into a single file')
    parser.add_argument('--merge-name', default='merged_output.pdf',
                        help='Filename for merged PDF (default: merged_output.pdf)')
    parser.add_argument('--no-compile', action='store_true',
                        help='Generate .tex files only, do not compile')
    parser.add_argument('--no-escape', action='store_true',
                        help='Disable auto-escaping of LaTeX special characters')
    parser.add_argument('--jinja', action='store_true',
                        help='Force Jinja2 rendering (auto-detected by default)')
    parser.add_argument('--simple', action='store_true',
                        help='Force simple {{var}} replacement (no Jinja2)')
    parser.add_argument('--limit', type=int, default=None,
                        help='Process only first N records')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be generated without creating files')
    parser.add_argument('--copy-assets', nargs='*', default=[],
                        help='Additional files to copy to each compilation directory (images, .bib, etc.)')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Verbose output')

    args = parser.parse_args()

    # --- Validate inputs ---
    template_path = Path(args.template)
    data_path = Path(args.data)

    if not template_path.exists():
        print(f"Error: Template not found: {args.template}", file=sys.stderr)
        sys.exit(1)

    if not data_path.exists():
        print(f"Error: Data file not found: {args.data}", file=sys.stderr)
        sys.exit(1)

    # --- Load template ---
    template_str = template_path.read_text(encoding='utf-8')
    print(f":: Loaded template: {template_path}")

    # --- Load data ---
    try:
        records = load_data(data_path)
    except Exception as e:
        print(f"Error loading data: {e}", file=sys.stderr)
        sys.exit(1)

    if not records:
        print("Error: No records found in data file", file=sys.stderr)
        sys.exit(1)

    if args.limit:
        records = records[:args.limit]

    print(f":: Loaded {len(records)} records from {data_path}")

    # Detect rendering mode
    if args.simple:
        use_jinja = False
    elif args.jinja:
        use_jinja = True
    else:
        use_jinja = None  # Auto-detect

    # --- Dry run ---
    if args.dry_run:
        print("\n:: DRY RUN -- would generate:")
        for i, record in enumerate(records):
            name = generate_output_name(record, args.name_field, i, args.prefix)
            print(f"   [{i+1}] {name}.tex → {name}.pdf")
            if args.verbose:
                for key, val in record.items():
                    print(f"       {key}: {val}")
        print(f"\n:: Total: {len(records)} documents")
        return

    # --- Create output directory ---
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # --- Generate .tex files ---
    tex_files = []
    errors = []

    print(f"\n:: Generating {len(records)} documents...")

    for i, record in enumerate(records):
        name = generate_output_name(record, args.name_field, i, args.prefix)
        tex_path = output_dir / f"{name}.tex"

        try:
            rendered = render_template(template_str, record, use_jinja=use_jinja)
            tex_path.write_text(rendered, encoding='utf-8')
            tex_files.append((str(tex_path), i, name))

            if args.verbose:
                print(f"   [{i+1}/{len(records)}] Generated: {tex_path}")

        except Exception as e:
            error_msg = f"Record {i+1}: {e}"
            errors.append(error_msg)
            print(f"   Error generating {name}: {e}", file=sys.stderr)

    print(f":: Generated {len(tex_files)} .tex files ({len(errors)} errors)")

    # --- Copy assets ---
    for asset in args.copy_assets:
        asset_path = Path(asset)
        if asset_path.exists():
            dest = output_dir / asset_path.name
            shutil.copy2(asset_path, dest)
            if args.verbose:
                print(f"   Copied asset: {asset_path.name}")
        else:
            print(f"   Warning: Asset not found: {asset}", file=sys.stderr)

    # --- Compile ---
    if args.no_compile:
        print(":: Skipping compilation (--no-compile)")
        print(f"\n:: Done. {len(tex_files)} .tex files in {output_dir}/")
        return

    print(f"\n:: Compiling {len(tex_files)} documents (workers: {args.workers})...")

    pdf_files = []
    compile_errors = []

    if args.workers > 1:
        # Parallel compilation
        tasks = [(tex_path, args.compile_script, args.engine, idx)
                 for tex_path, idx, name in tex_files]

        with ProcessPoolExecutor(max_workers=args.workers) as executor:
            futures = {executor.submit(compile_record, task): task for task in tasks}

            for future in as_completed(futures):
                idx, success, pdf_path, error = future.result()
                if success:
                    pdf_files.append((idx, pdf_path))
                    if args.verbose:
                        print(f"   Compiled: {Path(pdf_path).name}")
                else:
                    compile_errors.append(f"Record {idx+1}: {error}")
                    print(f"   Error compiling record {idx+1}: {error}", file=sys.stderr)
    else:
        # Sequential compilation
        for tex_path, idx, name in tex_files:
            success, pdf_path, error = compile_tex(tex_path, args.compile_script, args.engine)
            if success:
                pdf_files.append((idx, pdf_path))
                if args.verbose:
                    print(f"   [{idx+1}/{len(tex_files)}] Compiled: {Path(pdf_path).name}")
            else:
                compile_errors.append(f"Record {idx+1}: {error}")
                print(f"   Error compiling record {idx+1}: {error}", file=sys.stderr)

    # Sort PDFs by original index
    pdf_files.sort(key=lambda x: x[0])
    pdf_paths = [p for _, p in pdf_files]

    print(f":: Compiled {len(pdf_paths)} PDFs ({len(compile_errors)} errors)")

    # --- Merge PDFs ---
    if args.merge and pdf_paths:
        merge_path = output_dir / args.merge_name
        print(f"\n:: Merging {len(pdf_paths)} PDFs into {merge_path}...")

        if merge_pdfs(pdf_paths, merge_path):
            print(f":: Merged PDF: {merge_path}")
        else:
            print(":: PDF merge failed", file=sys.stderr)

    # --- Summary ---
    print(f"\n:: Done.")
    print(f"   Generated: {len(tex_files)} .tex files")
    print(f"   Compiled:  {len(pdf_paths)} PDFs")
    if errors or compile_errors:
        print(f"   Errors:    {len(errors) + len(compile_errors)}")
    print(f"   Output:    {output_dir}/")

    if compile_errors and args.verbose:
        print("\n:: Compilation errors:")
        for err in compile_errors:
            print(f"   - {err}")

    # Exit with error if any failures
    if errors or compile_errors:
        sys.exit(1)


if __name__ == '__main__':
    main()
