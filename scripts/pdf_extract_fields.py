#!/usr/bin/env python3
"""
pdf_extract_fields.py
Extract fillable form field metadata from a PDF to JSON.

Extracts field IDs, types (text, checkbox, radio_group, choice), page numbers,
bounding rectangles, and option values. Output is used by pdf_fill_form.py.

Examples:
    python3 pdf_extract_fields.py form.pdf field_info.json
    python3 pdf_extract_fields.py /path/to/form.pdf /tmp/fields.json
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
from pypdf import PdfReader


def get_full_annotation_field_id(annotation):
    """Build the full hierarchical field ID by walking parent chain.

    This matches the format used by PdfReader's get_fields() and
    update_page_form_field_values() methods.
    """
    components = []
    while annotation:
        field_name = annotation.get('/T')
        if field_name:
            components.append(field_name)
        annotation = annotation.get('/Parent')
    return ".".join(reversed(components)) if components else None


def make_field_dict(field, field_id):
    """Create a field info dictionary from a PDF form field."""
    field_dict = {"field_id": field_id}
    ft = field.get('/FT')
    if ft == "/Tx":
        field_dict["type"] = "text"
    elif ft == "/Btn":
        field_dict["type"] = "checkbox"  # radio groups handled separately
        states = field.get("/_States_", [])
        if len(states) == 2:
            # "/Off" is always the unchecked value per PDF spec
            # https://opensource.adobe.com/dc-acrobat-sdk-docs/standards/pdfstandards/pdf/PDF32000_2008.pdf#page=448
            if "/Off" in states:
                field_dict["checked_value"] = states[0] if states[0] != "/Off" else states[1]
                field_dict["unchecked_value"] = "/Off"
            else:
                print(f"Warning: Unexpected state values for checkbox `{field_id}`. "
                      "Its checked/unchecked values may not be correct; visually verify results.",
                      file=sys.stderr)
                field_dict["checked_value"] = states[0]
                field_dict["unchecked_value"] = states[1]
    elif ft == "/Ch":
        field_dict["type"] = "choice"
        states = field.get("/_States_", [])
        field_dict["choice_options"] = [{
            "value": state[0],
            "text": state[1],
        } for state in states]
    else:
        field_dict["type"] = f"unknown ({ft})"
    return field_dict


def get_field_info(reader: PdfReader):
    """Extract all fillable field metadata from a PDF.

    Returns a list of field info dicts:
    [
      {
        "field_id": str,
        "page": int (1-based),
        "rect": [left, bottom, right, top],
        "type": "text" | "checkbox" | "radio_group" | "choice",
        // type-specific fields (checked_value, radio_options, choice_options)
      }
    ]
    """
    fields = reader.get_fields()
    if not fields:
        return []

    field_info_by_id = {}
    possible_radio_names = set()

    for field_id, field in fields.items():
        # Skip container fields with children, except radio button parent groups
        if field.get("/Kids"):
            if field.get("/FT") == "/Btn":
                possible_radio_names.add(field_id)
            continue
        field_info_by_id[field_id] = make_field_dict(field, field_id)

    # Bounding rects are stored in annotations on page objects
    # Radio button options have a separate annotation for each choice
    radio_fields_by_id = {}

    for page_index, page in enumerate(reader.pages):
        annotations = page.get('/Annots', [])
        for ann in annotations:
            field_id = get_full_annotation_field_id(ann)
            if field_id in field_info_by_id:
                field_info_by_id[field_id]["page"] = page_index + 1
                field_info_by_id[field_id]["rect"] = ann.get('/Rect')
            elif field_id in possible_radio_names:
                try:
                    on_values = [v for v in ann["/AP"]["/N"] if v != "/Off"]
                except KeyError:
                    continue
                if len(on_values) == 1:
                    rect = ann.get("/Rect")
                    if field_id not in radio_fields_by_id:
                        radio_fields_by_id[field_id] = {
                            "field_id": field_id,
                            "type": "radio_group",
                            "page": page_index + 1,
                            "radio_options": [],
                        }
                    radio_fields_by_id[field_id]["radio_options"].append({
                        "value": on_values[0],
                        "rect": rect,
                    })

    # Filter out fields without location data (orphaned definitions)
    fields_with_location = []
    for field_info in field_info_by_id.values():
        if "page" in field_info:
            fields_with_location.append(field_info)
        else:
            print(f"Warning: Unable to determine location for field: {field_info.get('field_id')}, ignoring",
                  file=sys.stderr)

    # Sort by page number, then Y position (flipped), then X
    def sort_key(f):
        if "radio_options" in f:
            rect = f["radio_options"][0]["rect"] or [0, 0, 0, 0]
        else:
            rect = f.get("rect") or [0, 0, 0, 0]
        adjusted_position = [-rect[1], rect[0]]
        return [f.get("page"), adjusted_position]

    sorted_fields = fields_with_location + list(radio_fields_by_id.values())
    sorted_fields.sort(key=sort_key)

    return sorted_fields


def parse_args():
    parser = argparse.ArgumentParser(
        description="Extract fillable form field metadata from a PDF to JSON.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s form.pdf field_info.json
  %(prog)s /path/to/form.pdf /tmp/fields.json

Output JSON format:
  [
    {"field_id": "name", "page": 1, "type": "text", "rect": [x1,y1,x2,y2]},
    {"field_id": "agree", "page": 1, "type": "checkbox", "checked_value": "/Yes", "unchecked_value": "/Off"},
    {"field_id": "gender", "page": 2, "type": "radio_group", "radio_options": [...]},
    {"field_id": "country", "page": 2, "type": "choice", "choice_options": [...]}
  ]
        """
    )
    parser.add_argument("pdf_file", help="Path to the PDF file")
    parser.add_argument("output_json", help="Path for the output JSON file")
    return parser.parse_args()


def main():
    args = parse_args()
    pdf_path = Path(args.pdf_file)
    output_path = Path(args.output_json)

    if not pdf_path.exists():
        print(f"Error: File not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)

    try:
        reader = PdfReader(str(pdf_path))
        field_info = get_field_info(reader)
        with open(output_path, "w") as f:
            json.dump(field_info, f, indent=2)
        print(f"Wrote {len(field_info)} fields to {output_path}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
