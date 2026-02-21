#!/usr/bin/env python3
"""
pdf_fill_form.py
Fill fillable form fields in a PDF with validated data.

Reads a field_values.json file specifying values for each field,
validates all field IDs, page numbers, and type-specific values,
then writes the filled PDF. Exits with error if any validation fails.

Examples:
    python3 pdf_fill_form.py form.pdf field_values.json filled_form.pdf
    python3 pdf_fill_form.py /path/to/form.pdf /tmp/values.json /tmp/output.pdf
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
import json
from pathlib import Path
from pypdf import PdfReader, PdfWriter
from pdf_extract_fields import get_field_info


def validation_error_for_field_value(field_info, field_value):
    """Validate a field value against its type constraints.

    Returns an error message string, or None if valid.
    """
    field_type = field_info["type"]
    field_id = field_info["field_id"]
    if field_type == "checkbox":
        checked_val = field_info["checked_value"]
        unchecked_val = field_info["unchecked_value"]
        if field_value != checked_val and field_value != unchecked_val:
            return (f'ERROR: Invalid value "{field_value}" for checkbox field "{field_id}". '
                    f'The checked value is "{checked_val}" and the unchecked value is "{unchecked_val}"')
    elif field_type == "radio_group":
        option_values = [opt["value"] for opt in field_info["radio_options"]]
        if field_value not in option_values:
            return (f'ERROR: Invalid value "{field_value}" for radio group field "{field_id}". '
                    f'Valid values are: {option_values}')
    elif field_type == "choice":
        choice_values = [opt["value"] for opt in field_info["choice_options"]]
        if field_value not in choice_values:
            return (f'ERROR: Invalid value "{field_value}" for choice field "{field_id}". '
                    f'Valid values are: {choice_values}')
    return None


def monkeypatch_pypdf_method():
    """Fix pypdf bug with selection list fields.

    pypdf (at least version 5.7.0) has a bug in _writer.py around line 966:
    For selection lists, get_inherited returns a list of two-element lists like
    [["value1", "Text 1"], ["value2", "Text 2"], ...] but join() expects strings.
    This patch extracts just the value strings when the result is a list of pairs.
    """
    from pypdf.generic import DictionaryObject
    from pypdf.constants import FieldDictionaryAttributes

    original_get_inherited = DictionaryObject.get_inherited

    def patched_get_inherited(self, key: str, default=None):
        result = original_get_inherited(self, key, default)
        if key == FieldDictionaryAttributes.Opt:
            if isinstance(result, list) and all(isinstance(v, list) and len(v) == 2 for v in result):
                result = [r[0] for r in result]
        return result

    DictionaryObject.get_inherited = patched_get_inherited


def fill_pdf_fields(input_pdf_path: str, fields_json_path: str, output_pdf_path: str):
    """Fill fillable form fields in a PDF.

    Args:
        input_pdf_path: Path to the input PDF with fillable fields.
        fields_json_path: Path to JSON file with field values.
        output_pdf_path: Path for the output filled PDF.

    The field_values.json format:
    [
      {"field_id": "last_name", "page": 1, "value": "Simpson"},
      {"field_id": "Checkbox12", "page": 1, "value": "/On"},
      ...
    ]
    """
    with open(fields_json_path) as f:
        fields = json.load(f)

    # Group by page number
    fields_by_page = {}
    for field in fields:
        if "value" in field:
            field_id = field["field_id"]
            page = field["page"]
            if page not in fields_by_page:
                fields_by_page[page] = {}
            fields_by_page[page][field_id] = field["value"]

    reader = PdfReader(input_pdf_path)

    # Pre-validate all fields before writing
    has_error = False
    field_info = get_field_info(reader)
    fields_by_ids = {f["field_id"]: f for f in field_info}

    for field in fields:
        existing_field = fields_by_ids.get(field["field_id"])
        if not existing_field:
            has_error = True
            print(f"ERROR: `{field['field_id']}` is not a valid field ID")
        elif field["page"] != existing_field["page"]:
            has_error = True
            print(f"ERROR: Incorrect page number for `{field['field_id']}` "
                  f"(got {field['page']}, expected {existing_field['page']})")
        else:
            if "value" in field:
                err = validation_error_for_field_value(existing_field, field["value"])
                if err:
                    print(err)
                    has_error = True

    if has_error:
        sys.exit(1)

    writer = PdfWriter(clone_from=reader)
    for page, field_values in fields_by_page.items():
        writer.update_page_form_field_values(
            writer.pages[page - 1], field_values, auto_regenerate=False
        )

    # Necessary for many PDF viewers to format the form values correctly
    writer.set_need_appearances_writer(True)

    with open(output_pdf_path, "wb") as f:
        writer.write(f)

    print(f"Successfully filled PDF form and saved to {output_pdf_path}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Fill fillable form fields in a PDF with validated data.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s form.pdf field_values.json filled_form.pdf

field_values.json format:
  [
    {"field_id": "last_name", "page": 1, "value": "Simpson"},
    {"field_id": "Checkbox12", "page": 1, "value": "/On"},
    {"field_id": "country", "page": 2, "value": "US"}
  ]

Workflow:
  1. python3 pdf_check_form.py form.pdf        # Check if fillable
  2. python3 pdf_extract_fields.py form.pdf fields.json  # Extract field info
  3. Create field_values.json with values for each field
  4. python3 pdf_fill_form.py form.pdf field_values.json output.pdf
        """
    )
    parser.add_argument("input_pdf", help="Path to the input PDF with fillable fields")
    parser.add_argument("field_values_json", help="Path to JSON file with field values")
    parser.add_argument("output_pdf", help="Path for the output filled PDF")
    return parser.parse_args()


def main():
    args = parse_args()

    input_path = Path(args.input_pdf)
    values_path = Path(args.field_values_json)

    if not input_path.exists():
        print(f"Error: Input PDF not found: {input_path}", file=sys.stderr)
        sys.exit(1)
    if not values_path.exists():
        print(f"Error: Field values JSON not found: {values_path}", file=sys.stderr)
        sys.exit(1)

    try:
        monkeypatch_pypdf_method()
        fill_pdf_fields(str(input_path), str(values_path), args.output_pdf)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
