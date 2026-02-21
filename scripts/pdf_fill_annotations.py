#!/usr/bin/env python3
"""
pdf_fill_annotations.py
Fill a non-fillable PDF by adding text annotations at specified positions.

For PDFs that don't have fillable form fields, this script adds FreeText
annotations at bounding box positions defined in a fields.json file.
Use pdf_validate_boxes.py to validate bounding boxes before filling.

Examples:
    python3 pdf_fill_annotations.py form.pdf fields.json filled_form.pdf
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
from pypdf.annotations import FreeText


def transform_coordinates(bbox, image_width, image_height, pdf_width, pdf_height):
    """Transform bounding box from image coordinates to PDF coordinates.

    Image coordinates: origin at top-left, y increases downward.
    PDF coordinates: origin at bottom-left, y increases upward.

    Args:
        bbox: [left, top, right, bottom] in image coordinates.
        image_width: Width of the source image in pixels.
        image_height: Height of the source image in pixels.
        pdf_width: Width of the PDF page in points.
        pdf_height: Height of the PDF page in points.

    Returns:
        Tuple of (left, bottom, right, top) in PDF coordinates.
    """
    x_scale = pdf_width / image_width
    y_scale = pdf_height / image_height

    left = bbox[0] * x_scale
    right = bbox[2] * x_scale

    # Flip Y coordinates for PDF
    top = pdf_height - (bbox[1] * y_scale)
    bottom = pdf_height - (bbox[3] * y_scale)

    return left, bottom, right, top


def fill_pdf_form(input_pdf_path, fields_json_path, output_pdf_path):
    """Fill a PDF form with data from fields.json using text annotations.

    Args:
        input_pdf_path: Path to the input PDF.
        fields_json_path: Path to fields.json with bounding box data.
        output_pdf_path: Path for the output filled PDF.
    """
    with open(fields_json_path, "r") as f:
        fields_data = json.load(f)

    reader = PdfReader(input_pdf_path)
    writer = PdfWriter()
    writer.append(reader)

    # Get PDF dimensions for each page
    pdf_dimensions = {}
    for i, page in enumerate(reader.pages):
        mediabox = page.mediabox
        pdf_dimensions[i + 1] = [float(mediabox.width), float(mediabox.height)]

    # Process each form field
    annotations = []
    for field in fields_data["form_fields"]:
        page_num = field["page_number"]

        # Get page dimensions and transform coordinates
        page_info = next(p for p in fields_data["pages"] if p["page_number"] == page_num)
        image_width = page_info["image_width"]
        image_height = page_info["image_height"]
        pdf_width, pdf_height = pdf_dimensions[page_num]

        transformed_entry_box = transform_coordinates(
            field["entry_bounding_box"],
            image_width, image_height,
            pdf_width, pdf_height
        )

        # Skip empty fields
        if "entry_text" not in field or "text" not in field["entry_text"]:
            continue
        entry_text = field["entry_text"]
        text = entry_text["text"]
        if not text:
            continue

        font_name = entry_text.get("font", "Arial")
        font_size = str(entry_text.get("font_size", 14)) + "pt"
        font_color = entry_text.get("font_color", "000000")

        # Note: Font size/color may render inconsistently across PDF viewers
        # https://github.com/py-pdf/pypdf/issues/2084
        annotation = FreeText(
            text=text,
            rect=transformed_entry_box,
            font=font_name,
            font_size=font_size,
            font_color=font_color,
            border_color=None,
            background_color=None,
        )
        annotations.append(annotation)
        writer.add_annotation(page_number=page_num - 1, annotation=annotation)

    with open(output_pdf_path, "wb") as output:
        writer.write(output)

    print(f"Successfully filled PDF form and saved to {output_pdf_path}")
    print(f"Added {len(annotations)} text annotations")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Fill a non-fillable PDF by adding text annotations at specified positions.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s form.pdf fields.json filled_form.pdf

fields.json format:
  {
    "pages": [
      {"page_number": 1, "image_width": 800, "image_height": 1100}
    ],
    "form_fields": [
      {
        "page_number": 1,
        "description": "Last name field",
        "field_label": "Last name",
        "label_bounding_box": [30, 125, 95, 142],
        "entry_bounding_box": [100, 125, 280, 142],
        "entry_text": {"text": "Johnson", "font_size": 14, "font_color": "000000"}
      }
    ]
  }

Workflow:
  1. python3 pdf_check_form.py form.pdf               # Confirm non-fillable
  2. Convert PDF to images (scripts/pdf_to_images.sh)
  3. Visually identify fields and create fields.json
  4. python3 pdf_validate_boxes.py fields.json          # Validate boxes
  5. python3 pdf_fill_annotations.py form.pdf fields.json output.pdf
        """
    )
    parser.add_argument("input_pdf", help="Path to the input PDF")
    parser.add_argument("fields_json", help="Path to fields.json with bounding box data")
    parser.add_argument("output_pdf", help="Path for the output filled PDF")
    return parser.parse_args()


def main():
    args = parse_args()

    input_path = Path(args.input_pdf)
    fields_path = Path(args.fields_json)

    if not input_path.exists():
        print(f"Error: Input PDF not found: {input_path}", file=sys.stderr)
        sys.exit(1)
    if not fields_path.exists():
        print(f"Error: Fields JSON not found: {fields_path}", file=sys.stderr)
        sys.exit(1)

    try:
        fill_pdf_form(str(input_path), str(fields_path), args.output_pdf)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
