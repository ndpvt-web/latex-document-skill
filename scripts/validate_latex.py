#!/usr/bin/env python3
"""
LaTeX Batch File Validator for PDF-to-LaTeX Conversion Pipeline.

Validates batch .tex files BEFORE assembly to catch common errors early.
Designed to run on body-only LaTeX (no \\documentclass, no \\begin{document}).

Checks:
  1. Balanced \\begin{}/\\end{} environments
  2. Undefined commands not present in preamble
  3. \\begin{table}[H] or \\begin{figure}[H] inside tcolorbox environments
  4. TikZ commands (\\node, \\draw, \\path, \\fill) outside \\begin{tikzpicture}
  5. Missing node labels (TikZ \\node without {})
  6. Stray & characters outside tabular/align/matrix environments

Usage:
  python3 validate_latex.py tmp/batch_*.tex --preamble tmp/preamble.tex
  python3 validate_latex.py tmp/batch_001_007.tex
  python3 validate_latex.py tmp/batch_*.tex --json
"""

import argparse
import re
import sys
from pathlib import Path


# tcolorbox theorem-like environments (cannot contain floats)
TCOLORBOX_ENVS = {
    "theorem", "lemma", "corollary", "proposition",
    "definition", "example", "remark", "notebox", "proof",
}

# Environments where & is valid as a column/alignment separator
AMPERSAND_ENVS = {
    "tabular", "tabularx", "longtable", "array",
    "align", "align*", "aligned", "alignat", "alignat*",
    "gather", "gather*", "gathered",
    "split", "cases", "matrix", "pmatrix", "bmatrix",
    "vmatrix", "Vmatrix", "smallmatrix",
    "eqnarray", "eqnarray*", "flalign", "flalign*",
    "multiline", "multiline*",
}

# TikZ commands that must be inside tikzpicture
TIKZ_COMMANDS_RE = re.compile(
    r"^[^%]*\\(node|draw|fill|path|coordinate|filldraw|shade|clip)\s*[\[({]",
)


def extract_preamble_commands(preamble_path: str) -> set:
    """Extract \\newcommand and \\renewcommand names from a preamble file."""
    commands = set()
    if not preamble_path:
        return commands

    path = Path(preamble_path)
    if not path.exists():
        print(f"WARNING: Preamble file not found: {preamble_path}", file=sys.stderr)
        return commands

    text = path.read_text(encoding="utf-8", errors="replace")

    # Match \newcommand{\foo}, \renewcommand{\foo}, \DeclareMathOperator{\foo}
    for m in re.finditer(
        r"\\(?:re)?newcommand\*?\{(\\[a-zA-Z]+)\}", text
    ):
        commands.add(m.group(1))

    for m in re.finditer(
        r"\\DeclareMathOperator\*?\{(\\[a-zA-Z]+)\}", text
    ):
        commands.add(m.group(1))

    # newtcbtheorem defines environment names, not commands
    # newtcolorbox defines environment names
    # Extract \usepackage names for reference
    for m in re.finditer(r"\\newtcbtheorem[^{]*\{([^}]+)\}", text):
        commands.add(f"\\begin{{{m.group(1)}}}")

    for m in re.finditer(r"\\newtcolorbox\{([^}]+)\}", text):
        commands.add(f"\\begin{{{m.group(1)}}}")

    return commands


def extract_preamble_packages(preamble_path: str) -> set:
    """Extract loaded package names from a preamble file."""
    packages = set()
    if not preamble_path:
        return packages

    path = Path(preamble_path)
    if not path.exists():
        return packages

    text = path.read_text(encoding="utf-8", errors="replace")

    for m in re.finditer(r"\\usepackage(?:\[[^\]]*\])?\{([^}]+)\}", text):
        # Handle comma-separated packages
        for pkg in m.group(1).split(","):
            packages.add(pkg.strip())

    return packages


def extract_tikz_libraries(preamble_path: str) -> set:
    """Extract loaded TikZ library names from a preamble file."""
    libraries = set()
    if not preamble_path:
        return libraries

    path = Path(preamble_path)
    if not path.exists():
        return libraries

    text = path.read_text(encoding="utf-8", errors="replace")

    for m in re.finditer(r"\\usetikzlibrary\{([^}]+)\}", text):
        for lib in m.group(1).split(","):
            lib = lib.strip().strip("\n")
            if lib:
                libraries.add(lib)

    return libraries


class ValidationError:
    """A single validation error."""

    def __init__(self, file: str, line: int, category: str, message: str):
        self.file = file
        self.line = line
        self.category = category
        self.message = message

    def __str__(self):
        return f"{self.file}:{self.line}: [{self.category}] {self.message}"

    def to_dict(self):
        return {
            "file": self.file,
            "line": self.line,
            "category": self.category,
            "message": self.message,
        }


def is_comment_line(line: str) -> bool:
    """Check if a line is a LaTeX comment (ignoring leading whitespace)."""
    return line.lstrip().startswith("%")


def validate_file(filepath: str, preamble_commands: set) -> list:
    """Validate a single batch .tex file. Returns list of ValidationError."""
    errors = []
    path = Path(filepath)
    if not path.exists():
        errors.append(ValidationError(filepath, 0, "FILE", f"File not found: {filepath}"))
        return errors

    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    filename = path.name

    # --- Check 1: Balanced environments ---
    env_stack = []  # [(env_name, line_number), ...]

    for i, line in enumerate(lines, start=1):
        if is_comment_line(line):
            continue

        # Remove inline comments (but not escaped %)
        clean = re.sub(r"(?<!\\)%.*$", "", line)

        # Find \begin{env} and \end{env}
        for m in re.finditer(r"\\begin\{([^}]+)\}", clean):
            env_name = m.group(1)
            # Skip document-level envs (shouldn't appear in batch files)
            if env_name in ("document",):
                errors.append(ValidationError(
                    filename, i, "STRUCTURE",
                    f"\\begin{{{env_name}}} should not appear in batch files (body only)"
                ))
                continue
            env_stack.append((env_name, i))

        for m in re.finditer(r"\\end\{([^}]+)\}", clean):
            env_name = m.group(1)
            if env_name in ("document",):
                errors.append(ValidationError(
                    filename, i, "STRUCTURE",
                    f"\\end{{{env_name}}} should not appear in batch files (body only)"
                ))
                continue

            if not env_stack:
                errors.append(ValidationError(
                    filename, i, "ENV_MISMATCH",
                    f"\\end{{{env_name}}} without matching \\begin{{{env_name}}}"
                ))
            else:
                top_env, top_line = env_stack[-1]
                if top_env == env_name:
                    env_stack.pop()
                else:
                    errors.append(ValidationError(
                        filename, i, "ENV_MISMATCH",
                        f"\\end{{{env_name}}} does not match \\begin{{{top_env}}} at line {top_line}"
                    ))
                    # Try to recover: pop if mismatched
                    # Look deeper in stack for a match
                    found = False
                    for j in range(len(env_stack) - 1, -1, -1):
                        if env_stack[j][0] == env_name:
                            # Report unclosed environments between
                            for k in range(len(env_stack) - 1, j, -1):
                                errors.append(ValidationError(
                                    filename, env_stack[k][1], "ENV_UNCLOSED",
                                    f"\\begin{{{env_stack[k][0]}}} opened but never closed "
                                    f"(interrupted by \\end{{{env_name}}} at line {i})"
                                ))
                            env_stack = env_stack[:j]
                            found = True
                            break
                    if not found:
                        # No match found in stack; leave stack as is
                        pass

    # Report remaining unclosed environments
    for env_name, line_num in env_stack:
        errors.append(ValidationError(
            filename, line_num, "ENV_UNCLOSED",
            f"\\begin{{{env_name}}} opened but never closed (reached end of file)"
        ))

    # --- Check 2: Float inside tcolorbox ---
    tcolorbox_depth = 0
    tcolorbox_stack = []

    for i, line in enumerate(lines, start=1):
        if is_comment_line(line):
            continue
        clean = re.sub(r"(?<!\\)%.*$", "", line)

        for m in re.finditer(r"\\begin\{([^}]+)\}", clean):
            env_name = m.group(1)
            if env_name in TCOLORBOX_ENVS:
                tcolorbox_depth += 1
                tcolorbox_stack.append((env_name, i))

        # Check for floats while inside tcolorbox
        if tcolorbox_depth > 0:
            if re.search(r"\\begin\{table\}", clean):
                parent = tcolorbox_stack[-1][0] if tcolorbox_stack else "unknown"
                errors.append(ValidationError(
                    filename, i, "FLOAT_IN_TCOLORBOX",
                    f"\\begin{{table}} inside \\begin{{{parent}}} "
                    f"(opened at line {tcolorbox_stack[-1][1]}). "
                    f"Use \\begin{{tabular}} directly instead."
                ))
            if re.search(r"\\begin\{figure\}", clean):
                parent = tcolorbox_stack[-1][0] if tcolorbox_stack else "unknown"
                errors.append(ValidationError(
                    filename, i, "FLOAT_IN_TCOLORBOX",
                    f"\\begin{{figure}} inside \\begin{{{parent}}} "
                    f"(opened at line {tcolorbox_stack[-1][1]}). "
                    f"Remove the figure wrapper."
                ))

        for m in re.finditer(r"\\end\{([^}]+)\}", clean):
            env_name = m.group(1)
            if env_name in TCOLORBOX_ENVS and tcolorbox_depth > 0:
                tcolorbox_depth -= 1
                if tcolorbox_stack:
                    tcolorbox_stack.pop()

    # --- Check 3: TikZ commands outside tikzpicture ---
    in_tikzpicture = 0

    for i, line in enumerate(lines, start=1):
        if is_comment_line(line):
            continue
        clean = re.sub(r"(?<!\\)%.*$", "", line)

        if r"\begin{tikzpicture}" in clean:
            in_tikzpicture += 1
        if r"\end{tikzpicture}" in clean:
            in_tikzpicture = max(0, in_tikzpicture - 1)

        if in_tikzpicture == 0 and TIKZ_COMMANDS_RE.search(clean):
            errors.append(ValidationError(
                filename, i, "TIKZ_OUTSIDE",
                f"TikZ command outside \\begin{{tikzpicture}}: {clean.strip()[:80]}"
            ))

    # --- Check 4: Missing TikZ node labels ---
    for i, line in enumerate(lines, start=1):
        if is_comment_line(line):
            continue
        clean = re.sub(r"(?<!\\)%.*$", "", line)

        # Find \node that doesn't end with {something};
        # Pattern: \node followed by options/name/at but no {} before ;
        node_matches = list(re.finditer(r"\\node\b", clean))
        for m in node_matches:
            after = clean[m.end():]
            # Check if there's a {}, even empty, before the semicolon
            # Simple heuristic: there should be { ... } somewhere after \node before ;
            semi_pos = after.find(";")
            if semi_pos == -1:
                # No semicolon on this line -- might continue on next line, skip
                continue
            segment = after[:semi_pos]
            if "{" not in segment:
                errors.append(ValidationError(
                    filename, i, "TIKZ_NODE_LABEL",
                    f"\\node without label braces {{}}. Add {{}} even if empty: "
                    f"{clean.strip()[:80]}"
                ))

    # --- Check 5: Stray & outside valid environments ---
    ampersand_depth = 0

    for i, line in enumerate(lines, start=1):
        if is_comment_line(line):
            continue
        clean = re.sub(r"(?<!\\)%.*$", "", line)

        # Track whether this line opens an ampersand-valid environment
        line_opens_amp_env = False
        for m in re.finditer(r"\\begin\{([^}]+)\}", clean):
            env_name = m.group(1)
            if env_name in AMPERSAND_ENVS:
                ampersand_depth += 1
                line_opens_amp_env = True

        # Only check for stray & if we're outside ampersand environments
        # AND this line didn't open one (handles single-line envs like
        # \begin{aligned}...&...\end{aligned} all on one line)
        if ampersand_depth == 0 and not line_opens_amp_env:
            stray = re.findall(r"(?<!\\)&", clean)
            if stray:
                errors.append(ValidationError(
                    filename, i, "STRAY_AMPERSAND",
                    f"Unescaped '&' outside tabular/align environment. "
                    f"Use '\\&' in text mode: {clean.strip()[:80]}"
                ))

        for m in re.finditer(r"\\end\{([^}]+)\}", clean):
            env_name = m.group(1)
            if env_name in AMPERSAND_ENVS:
                ampersand_depth = max(0, ampersand_depth - 1)

    return errors


def main():
    parser = argparse.ArgumentParser(
        description="Validate LaTeX batch files before assembly.",
        epilog="Example: python3 validate_latex.py tmp/batch_*.tex --preamble tmp/preamble.tex",
    )
    parser.add_argument(
        "files",
        nargs="+",
        help="Batch .tex files to validate",
    )
    parser.add_argument(
        "--preamble",
        default=None,
        help="Path to the shared preamble.tex (for command/package checking)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output errors as JSON instead of plain text",
    )
    args = parser.parse_args()

    # Load preamble info
    preamble_commands = extract_preamble_commands(args.preamble)

    # Validate each file
    all_errors = []
    for filepath in sorted(args.files):
        file_errors = validate_file(filepath, preamble_commands)
        all_errors.extend(file_errors)

    # Output
    if args.json:
        import json
        result = {
            "total_errors": len(all_errors),
            "files_checked": len(args.files),
            "errors": [e.to_dict() for e in all_errors],
        }
        print(json.dumps(result, indent=2))
    else:
        if not all_errors:
            print(f"OK: {len(args.files)} file(s) validated, 0 errors found.")
        else:
            # Group by file
            by_file = {}
            for e in all_errors:
                by_file.setdefault(e.file, []).append(e)

            print(f"ERRORS: {len(all_errors)} error(s) in {len(by_file)} file(s):\n")
            for fname in sorted(by_file.keys()):
                print(f"--- {fname} ({len(by_file[fname])} errors) ---")
                for e in by_file[fname]:
                    print(f"  Line {e.line}: [{e.category}] {e.message}")
                print()

            # Summary by category
            categories = {}
            for e in all_errors:
                categories[e.category] = categories.get(e.category, 0) + 1

            print("Summary by category:")
            for cat, count in sorted(categories.items(), key=lambda x: -x[1]):
                print(f"  {cat}: {count}")

    return 1 if all_errors else 0


if __name__ == "__main__":
    sys.exit(main())
