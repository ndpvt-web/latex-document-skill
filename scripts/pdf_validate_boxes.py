#!/usr/bin/env python3
"""
pdf_validate_boxes.py
Validate bounding boxes in fields.json and optionally create validation images.

Checks that bounding boxes don't intersect and that entry boxes are tall enough
for their font sizes. Can also generate overlay images with colored rectangles
for visual verification (red = entry areas, blue = label areas).

Examples:
    # Validate only
    python3 pdf_validate_boxes.py fields.json

    # Validate + create validation image for page 1
    python3 pdf_validate_boxes.py fields.json --image page_1.png --output validation_1.png --page 1
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


import argparse
import json
from dataclasses import dataclass
from pathlib import Path


@dataclass
class RectAndField:
    rect: list
    rect_type: str
    field: dict


def rects_intersect(r1, r2):
    """Check if two rectangles [left, top, right, bottom] intersect."""
    disjoint_horizontal = r1[0] >= r2[2] or r1[2] <= r2[0]
    disjoint_vertical = r1[1] >= r2[3] or r1[3] <= r2[1]
    return not (disjoint_horizontal or disjoint_vertical)


def get_bounding_box_messages(fields_data) -> list:
    """Validate bounding boxes in fields data.

    Returns a list of validation messages (SUCCESS or FAILURE).
    """
    messages = []
    messages.append(f"Read {len(fields_data['form_fields'])} fields")

    rects_and_fields = []
    for f in fields_data["form_fields"]:
        rects_and_fields.append(RectAndField(f["label_bounding_box"], "label", f))
        rects_and_fields.append(RectAndField(f["entry_bounding_box"], "entry", f))

    has_error = False
    for i, ri in enumerate(rects_and_fields):
        for j in range(i + 1, len(rects_and_fields)):
            rj = rects_and_fields[j]
            if ri.field["page_number"] == rj.field["page_number"] and rects_intersect(ri.rect, rj.rect):
                has_error = True
                if ri.field is rj.field:
                    messages.append(
                        f"FAILURE: intersection between label and entry bounding boxes "
                        f"for `{ri.field['description']}` ({ri.rect}, {rj.rect})")
                else:
                    messages.append(
                        f"FAILURE: intersection between {ri.rect_type} bounding box "
                        f"for `{ri.field['description']}` ({ri.rect}) and {rj.rect_type} "
                        f"bounding box for `{rj.field['description']}` ({rj.rect})")
                if len(messages) >= 20:
                    messages.append("Aborting further checks; fix bounding boxes and try again")
                    return messages

        if ri.rect_type == "entry":
            if "entry_text" in ri.field:
                font_size = ri.field["entry_text"].get("font_size", 14)
                entry_height = ri.rect[3] - ri.rect[1]
                if entry_height < font_size:
                    has_error = True
                    messages.append(
                        f"FAILURE: entry bounding box height ({entry_height}) for "
                        f"`{ri.field['description']}` is too short for the text content "
                        f"(font size: {font_size}). Increase the box height or decrease the font size.")
                    if len(messages) >= 20:
                        messages.append("Aborting further checks; fix bounding boxes and try again")
                        return messages

    if not has_error:
        messages.append("SUCCESS: All bounding boxes are valid")
    return messages


def create_validation_image(page_number, fields_data, input_path, output_path):
    """Create a validation image with colored bounding box overlays.

    Red rectangles = entry areas (where text will be placed).
    Blue rectangles = label areas (field labels).

    Args:
        page_number: Page number to create validation image for (1-based).
        fields_data: Parsed fields.json data dict.
        input_path: Path to the source page image (PNG).
        output_path: Path for the output validation image.
    """
    _ensure_package("Pillow", "PIL")
    from PIL import Image, ImageDraw

    img = Image.open(input_path)
    draw = ImageDraw.Draw(img)
    num_boxes = 0

    for field in fields_data["form_fields"]:
        if field["page_number"] == page_number:
            entry_box = field['entry_bounding_box']
            label_box = field['label_bounding_box']
            draw.rectangle(entry_box, outline='red', width=2)
            draw.rectangle(label_box, outline='blue', width=2)
            num_boxes += 2

    img.save(output_path)
    print(f"Created validation image at {output_path} with {num_boxes} bounding boxes")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Validate bounding boxes in fields.json and optionally create validation images.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Validate bounding boxes only
  %(prog)s fields.json

  # Validate + create validation image for page 1
  %(prog)s fields.json --image page_1.png --output validation_1.png --page 1

Validation checks:
  - No intersections between bounding boxes on the same page
  - No overlap between label and entry boxes of the same field
  - Entry box height is sufficient for the font size

Validation image colors:
  - Red rectangles = entry areas (where text will be placed)
  - Blue rectangles = label areas (field labels)
        """
    )
    parser.add_argument("fields_json", help="Path to fields.json file")
    parser.add_argument("--image", help="Path to page image (PNG) for validation overlay")
    parser.add_argument("--output", help="Path for the output validation image")
    parser.add_argument("--page", type=int, help="Page number for validation image (1-based)")
    return parser.parse_args()


def main():
    args = parse_args()

    fields_path = Path(args.fields_json)
    if not fields_path.exists():
        print(f"Error: Fields JSON not found: {fields_path}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(fields_path) as f:
            fields_data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {fields_path}: {e}", file=sys.stderr)
        sys.exit(1)

    # Run validation
    messages = get_bounding_box_messages(fields_data)
    for msg in messages:
        print(msg)

    # Create validation image if requested
    if args.image:
        if not args.output:
            print("Error: --output is required when --image is specified", file=sys.stderr)
            sys.exit(1)
        if not args.page:
            print("Error: --page is required when --image is specified", file=sys.stderr)
            sys.exit(1)

        image_path = Path(args.image)
        if not image_path.exists():
            print(f"Error: Image not found: {image_path}", file=sys.stderr)
            sys.exit(1)

        create_validation_image(args.page, fields_data, str(image_path), args.output)

    # Exit with error if validation failed
    if any("FAILURE" in msg for msg in messages):
        sys.exit(1)


if __name__ == "__main__":
    main()
