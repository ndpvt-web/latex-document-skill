#!/usr/bin/env python3
"""
pdf_check_form.py
Check whether a PDF has fillable form fields.

This is the first step in the form-filling workflow. Based on the result,
use either pdf_fill_form.py (fillable) or pdf_fill_annotations.py (non-fillable).

Examples:
    python3 pdf_check_form.py document.pdf
    python3 pdf_check_form.py /path/to/form.pdf
"""

import subprocess
import sys


def _ensure_package(pip_name, import_name=None):
    """Try importing a package; auto-install via pip if missing."""
    if import_name is None:
        import_name = pip_name
    try:
        __import__(import_name)
    except ImportError:
        print(f":: Package '{import_name}' not found. Installing {pip_name}...", file=sys.stderr)
        try:
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", "-q", pip_name],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
        except subprocess.CalledProcessError:
            try:
                subprocess.check_call(
                    [sys.executable, "-m", "pip", "install", "-q",
                     "--break-system-packages", pip_name],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                )
            except Exception as e:
                print(f"Error: Failed to install {pip_name}: {e}", file=sys.stderr)
                print(f"Please install manually: pip install {pip_name}", file=sys.stderr)
                sys.exit(1)


_ensure_package("pypdf")

import argparse
from pathlib import Path
from pypdf import PdfReader


def check_form(pdf_path: str) -> bool:
    """Check if a PDF has fillable form fields.

    Args:
        pdf_path: Path to the PDF file.

    Returns:
        True if the PDF has fillable form fields, False otherwise.
    """
    reader = PdfReader(pdf_path)
    fields = reader.get_fields()
    return bool(fields)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Check whether a PDF has fillable form fields.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s document.pdf
  %(prog)s /path/to/form.pdf

Based on the result, use:
  - Fillable:     pdf_fill_form.py
  - Non-fillable: pdf_fill_annotations.py
        """
    )
    parser.add_argument("pdf_file", help="Path to the PDF file to check")
    return parser.parse_args()


def main():
    args = parse_args()
    pdf_path = Path(args.pdf_file)

    if not pdf_path.exists():
        print(f"Error: File not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)

    try:
        has_fields = check_form(str(pdf_path))
        if has_fields:
            print("This PDF has fillable form fields")
            print("Use pdf_extract_fields.py to extract field info, then pdf_fill_form.py to fill them.")
        else:
            print("This PDF does not have fillable form fields; you will need to visually determine where to enter data")
            print("Use pdf_fill_annotations.py to add text annotations at specific positions.")
    except Exception as e:
        print(f"Error reading PDF: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
