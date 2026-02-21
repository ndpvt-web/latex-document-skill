# PDF Operations Reference Guide

Comprehensive reference for advanced PDF manipulation beyond the LaTeX compilation pipeline. Covers form filling, text/table extraction, OCR, programmatic creation, watermarking, rotation, metadata, and more.

## Python Libraries Overview

| Library | License | Best For |
|---|---|---|
| **pypdf** | BSD | Form filling, merging, splitting, metadata, watermarking, rotation, encryption |
| **pdfplumber** | MIT | Text extraction with coordinates, table extraction with fine-tuned settings |
| **reportlab** | BSD | Programmatic PDF creation from scratch (Canvas API + Platypus high-level) |
| **pypdfium2** | Apache/BSD | Fast rendering, text extraction, alternative to poppler |
| **pytesseract** | Apache | OCR for scanned PDFs (wrapper around Tesseract) |
| **pdf2image** | MIT | Convert PDF pages to PIL images (wrapper around poppler) |

All Python libraries auto-install via `_ensure_package()` in the skill's scripts.

---

## Form Filling Workflow

### Step 1: Check if the PDF has fillable fields

```bash
python3 <skill_path>/scripts/pdf_check_form.py form.pdf
```

This determines which workflow to follow:
- **Fillable** -- use `pdf_extract_fields.py` + `pdf_fill_form.py`
- **Non-fillable** -- use `pdf_fill_annotations.py` with visual analysis

### Fillable PDF Workflow

```bash
# 1. Extract field metadata to JSON
python3 <skill_path>/scripts/pdf_extract_fields.py form.pdf field_info.json

# 2. Create field_values.json with values for each field
# Format: [{"field_id": "name", "page": 1, "value": "John Smith"}, ...]

# 3. Fill the form (validates field IDs, pages, and values before writing)
python3 <skill_path>/scripts/pdf_fill_form.py form.pdf field_values.json filled.pdf
```

**Field types supported:**

| Type | JSON Format | Example |
|---|---|---|
| Text | `{"field_id": "name", "page": 1, "value": "John"}` | Free text entry |
| Checkbox | `{"field_id": "agree", "page": 1, "value": "/Yes"}` | Use `checked_value` or `unchecked_value` from field_info |
| Radio group | `{"field_id": "gender", "page": 1, "value": "/Male"}` | Use one of `radio_options[].value` |
| Choice/dropdown | `{"field_id": "country", "page": 2, "value": "US"}` | Use one of `choice_options[].value` |

### Non-Fillable PDF Workflow

```bash
# 1. Convert PDF to images for visual analysis
bash <skill_path>/scripts/pdf_to_images.sh form.pdf ./tmp/pages

# 2. Examine images and create fields.json with bounding boxes
# (See fields.json format below)

# 3. Create validation images to verify bounding box accuracy
python3 <skill_path>/scripts/pdf_validate_boxes.py fields.json \
    --image ./tmp/pages/page-001.png --output validation.png --page 1

# 4. Validate bounding boxes (no intersections, adequate height)
python3 <skill_path>/scripts/pdf_validate_boxes.py fields.json

# 5. Fill the form with text annotations
python3 <skill_path>/scripts/pdf_fill_annotations.py form.pdf fields.json filled.pdf
```

**fields.json format:**
```json
{
  "pages": [
    {"page_number": 1, "image_width": 1654, "image_height": 2339}
  ],
  "form_fields": [
    {
      "page_number": 1,
      "description": "Last name field",
      "field_label": "Last name",
      "label_bounding_box": [30, 125, 95, 142],
      "entry_bounding_box": [100, 125, 280, 142],
      "entry_text": {
        "text": "Johnson",
        "font_size": 14,
        "font_color": "000000"
      }
    }
  ]
}
```

Bounding boxes use image coordinates: `[left, top, right, bottom]` with origin at top-left.

---

## Text & Table Extraction (pdfplumber)

### Basic text extraction

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

### Text with coordinates

```python
with pdfplumber.open("document.pdf") as pdf:
    page = pdf.pages[0]
    for word in page.extract_words():
        print(f"{word['text']} at ({word['x0']:.1f}, {word['top']:.1f})")
```

### Table extraction

```python
with pdfplumber.open("document.pdf") as pdf:
    page = pdf.pages[0]
    tables = page.extract_tables()
    for table in tables:
        for row in table:
            print(row)
```

### Advanced table settings

```python
table_settings = {
    "vertical_strategy": "lines",      # "lines", "text", "explicit"
    "horizontal_strategy": "lines",
    "snap_tolerance": 3,
    "join_tolerance": 3,
    "edge_min_length": 3,
    "min_words_vertical": 3,
    "min_words_horizontal": 1,
}

tables = page.extract_tables(table_settings)
```

### Export to pandas/Excel

```python
import pandas as pd
import pdfplumber

with pdfplumber.open("report.pdf") as pdf:
    all_tables = []
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            df = pd.DataFrame(table[1:], columns=table[0])
            all_tables.append(df)

    # Combine and export
    combined = pd.concat(all_tables, ignore_index=True)
    combined.to_excel("extracted_tables.xlsx", index=False)
```

---

## OCR for Scanned PDFs

### Basic OCR with pytesseract

```python
import pytesseract
from pdf2image import convert_from_path

def ocr_pdf(pdf_path):
    """Extract text from a scanned PDF using OCR."""
    images = convert_from_path(pdf_path, dpi=300)
    text = ""
    for i, image in enumerate(images):
        page_text = pytesseract.image_to_string(image)
        text += f"\n--- Page {i+1} ---\n{page_text}"
    return text
```

### OCR with language support

```python
# For non-English documents
text = pytesseract.image_to_string(image, lang='fra')  # French
text = pytesseract.image_to_string(image, lang='deu')  # German
text = pytesseract.image_to_string(image, lang='jpn')  # Japanese
text = pytesseract.image_to_string(image, lang='eng+fra')  # Multi-language
```

### OCR with bounding boxes

```python
# Get word-level bounding boxes
data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)
for i, word in enumerate(data['text']):
    if word.strip():
        x, y, w, h = data['left'][i], data['top'][i], data['width'][i], data['height'][i]
        conf = data['conf'][i]
        print(f"{word} at ({x},{y},{w},{h}) confidence={conf}")
```

### Smart extraction (try text first, fall back to OCR)

```python
import pdfplumber
import pytesseract
from pdf2image import convert_from_path

def extract_text_smart(pdf_path):
    """Try pdfplumber first; if no text found, fall back to OCR."""
    with pdfplumber.open(pdf_path) as pdf:
        text = ""
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text and page_text.strip():
                text += page_text + "\n"

    if text.strip():
        return text

    # Fall back to OCR
    images = convert_from_path(pdf_path, dpi=300)
    ocr_text = ""
    for image in images:
        ocr_text += pytesseract.image_to_string(image) + "\n"
    return ocr_text
```

---

## Programmatic PDF Creation (reportlab)

### Canvas API (low-level)

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("output.pdf", pagesize=letter)
width, height = letter

# Text
c.setFont("Helvetica-Bold", 24)
c.drawString(72, height - 72, "Document Title")

c.setFont("Helvetica", 12)
c.drawString(72, height - 120, "This is body text.")

# Shapes
c.setStrokeColorRGB(0.2, 0.5, 0.8)
c.setFillColorRGB(0.9, 0.95, 1.0)
c.rect(72, height - 200, 200, 50, fill=1)

# Lines
c.line(72, height - 220, 540, height - 220)

# Images
c.drawImage("logo.png", 72, height - 350, width=150, height=100)

c.save()
```

### Platypus (high-level with flowables)

```python
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib import colors

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

# Title
story.append(Paragraph("Monthly Report", styles['Title']))
story.append(Spacer(1, 0.5 * inch))

# Body text
story.append(Paragraph("This report covers Q4 performance metrics.", styles['Normal']))
story.append(Spacer(1, 0.25 * inch))

# Table
data = [
    ['Metric', 'Q3', 'Q4', 'Change'],
    ['Revenue', '$1.2M', '$1.5M', '+25%'],
    ['Users', '10,000', '15,000', '+50%'],
    ['Churn', '5%', '3%', '-40%'],
]
table = Table(data, colWidths=[1.5*inch, 1*inch, 1*inch, 1*inch])
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2C3E50')),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('ALIGN', (1, 0), (-1, -1), 'CENTER'),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#ECF0F1')]),
]))
story.append(table)

doc.build(story)
```

---

## Watermarking Existing PDFs

```python
from pypdf import PdfReader, PdfWriter
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
import io

def add_watermark(input_pdf, output_pdf, watermark_text="CONFIDENTIAL"):
    """Add a diagonal text watermark to every page."""
    # Create watermark PDF in memory
    packet = io.BytesIO()
    c = canvas.Canvas(packet, pagesize=letter)
    c.setFont("Helvetica-Bold", 60)
    c.setFillColorRGB(0.85, 0.85, 0.85)  # Light gray
    c.saveState()
    c.translate(300, 400)
    c.rotate(45)
    c.drawCentredString(0, 0, watermark_text)
    c.restoreState()
    c.save()
    packet.seek(0)

    watermark_reader = PdfReader(packet)
    watermark_page = watermark_reader.pages[0]

    reader = PdfReader(input_pdf)
    writer = PdfWriter()

    for page in reader.pages:
        page.merge_page(watermark_page)
        writer.add_page(page)

    with open(output_pdf, "wb") as f:
        writer.write(f)
```

---

## Page Rotation & Cropping

### Rotation

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.rotate(90)  # 90, 180, 270 degrees clockwise
    writer.add_page(page)

with open("rotated.pdf", "wb") as f:
    writer.write(f)
```

### Cropping

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    # Crop to specific region (in PDF points, 72 points = 1 inch)
    page.mediabox.lower_left = (72, 72)       # 1 inch from left, 1 inch from bottom
    page.mediabox.upper_right = (540, 720)     # 7.5 inches wide, 10 inches tall
    writer.add_page(page)

with open("cropped.pdf", "wb") as f:
    writer.write(f)
```

---

## Metadata Extraction

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")

# Basic metadata
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Subject: {meta.subject}")
print(f"Creator: {meta.creator}")
print(f"Producer: {meta.producer}")
print(f"Creation date: {meta.creation_date}")
print(f"Modification date: {meta.modification_date}")

# Page count and dimensions
print(f"Pages: {len(reader.pages)}")
for i, page in enumerate(reader.pages):
    box = page.mediabox
    print(f"  Page {i+1}: {float(box.width):.0f} x {float(box.height):.0f} points")
```

---

## Image Extraction (CLI)

```bash
# Extract all images from a PDF using poppler-utils
pdfimages -all document.pdf ./images/prefix

# Extract as PNG only
pdfimages -png document.pdf ./images/prefix

# Extract from specific pages
pdfimages -f 1 -l 5 -png document.pdf ./images/prefix

# List images without extracting
pdfimages -list document.pdf
```

---

## JavaScript Libraries

### pdf-lib (Node.js -- create and modify PDFs)

```javascript
const { PDFDocument, rgb, StandardFonts } = require('pdf-lib');
const fs = require('fs');

async function createPDF() {
    const doc = await PDFDocument.create();
    const page = doc.addPage([612, 792]);  // Letter size
    const font = await doc.embedFont(StandardFonts.HelveticaBold);

    page.drawText('Hello from pdf-lib!', {
        x: 50, y: 700, size: 30, font, color: rgb(0, 0.2, 0.6)
    });

    const bytes = await doc.save();
    fs.writeFileSync('output.pdf', bytes);
}

async function modifyPDF() {
    const bytes = fs.readFileSync('existing.pdf');
    const doc = await PDFDocument.load(bytes);
    const pages = doc.getPages();
    const firstPage = pages[0];

    firstPage.drawText('Added text', {
        x: 50, y: 50, size: 14, color: rgb(1, 0, 0)
    });

    const modified = await doc.save();
    fs.writeFileSync('modified.pdf', modified);
}
```

### pdfjs-dist (Browser/Node.js -- read and render PDFs)

```javascript
const pdfjsLib = require('pdfjs-dist');

async function extractText(pdfPath) {
    const doc = await pdfjsLib.getDocument(pdfPath).promise;
    for (let i = 1; i <= doc.numPages; i++) {
        const page = await doc.getPage(i);
        const content = await page.getTextContent();
        const text = content.items.map(item => item.str).join(' ');
        console.log(`Page ${i}: ${text}`);
    }
}
```

---

## Advanced CLI Operations

### poppler-utils

```bash
# Extract text with layout preservation
pdftotext -layout document.pdf output.txt

# Extract text from specific pages
pdftotext -f 3 -l 7 document.pdf output.txt

# Get PDF info (page count, dimensions, metadata)
pdfinfo document.pdf

# Get bounding box layout info
pdftotext -bbox-layout document.pdf output.html

# High-quality image conversion
pdftoppm -png -r 300 document.pdf output_prefix
pdftoppm -jpeg -r 150 -f 1 -l 1 document.pdf single_page
```

### qpdf (repair and debug)

```bash
# Check PDF integrity
qpdf --check document.pdf

# Repair a corrupted PDF
qpdf --replace-input document.pdf

# Linearize for web (fast first-page display)
qpdf --linearize input.pdf output.pdf

# Decrypt a PDF (if you have the password)
qpdf --decrypt --password=secret encrypted.pdf decrypted.pdf

# Show PDF structure (debugging)
qpdf --show-object=1 document.pdf
qpdf --show-pages document.pdf
```

---

## Batch Processing Patterns

### Process multiple PDFs with error handling

```python
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def batch_process(input_dir, output_dir, process_func):
    """Process all PDFs in a directory with error handling."""
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    pdfs = sorted(input_path.glob("*.pdf"))
    logger.info(f"Found {len(pdfs)} PDFs to process")

    results = {"success": 0, "failed": 0, "errors": []}
    for pdf in pdfs:
        try:
            out_file = output_path / pdf.name
            process_func(str(pdf), str(out_file))
            results["success"] += 1
            logger.info(f"OK: {pdf.name}")
        except Exception as e:
            results["failed"] += 1
            results["errors"].append((pdf.name, str(e)))
            logger.error(f"FAIL: {pdf.name}: {e}")

    logger.info(f"Done: {results['success']} succeeded, {results['failed']} failed")
    return results
```

### Parallel processing with concurrent.futures

```python
from concurrent.futures import ProcessPoolExecutor, as_completed

def batch_process_parallel(input_dir, output_dir, process_func, max_workers=4):
    """Process PDFs in parallel."""
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    pdfs = sorted(input_path.glob("*.pdf"))

    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        futures = {}
        for pdf in pdfs:
            out_file = output_path / pdf.name
            future = executor.submit(process_func, str(pdf), str(out_file))
            futures[future] = pdf.name

        for future in as_completed(futures):
            name = futures[future]
            try:
                future.result()
                print(f"OK: {name}")
            except Exception as e:
                print(f"FAIL: {name}: {e}")
```

---

## Performance Optimization

### Large PDF handling

```python
# Stream reading for large files (pypdf)
from pypdf import PdfReader

reader = PdfReader("large.pdf")
# Process one page at a time instead of loading all
for i in range(len(reader.pages)):
    page = reader.pages[i]
    text = page.extract_text()
    # Process text immediately, don't accumulate
    process_page(i, text)
```

### Memory management for pdfplumber

```python
import pdfplumber

# Process pages individually to avoid memory issues
with pdfplumber.open("large.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        text = page.extract_text()
        # Process and discard
        save_results(i, tables, text)
        # pdfplumber releases page resources automatically
```

### Chunked merging for many PDFs

```python
from pypdf import PdfReader, PdfWriter
from pathlib import Path

def merge_pdfs_chunked(pdf_paths, output_path, chunk_size=50):
    """Merge many PDFs in chunks to avoid memory issues."""
    if len(pdf_paths) <= chunk_size:
        writer = PdfWriter()
        for path in pdf_paths:
            writer.append(str(path))
        with open(output_path, "wb") as f:
            writer.write(f)
        return

    # Merge in chunks, then merge the chunks
    temp_files = []
    for i in range(0, len(pdf_paths), chunk_size):
        chunk = pdf_paths[i:i + chunk_size]
        temp_path = f"/tmp/chunk_{i}.pdf"
        writer = PdfWriter()
        for path in chunk:
            writer.append(str(path))
        with open(temp_path, "wb") as f:
            writer.write(f)
        temp_files.append(temp_path)

    # Final merge of chunks
    merge_pdfs_chunked(temp_files, output_path, chunk_size)
```

---

## Troubleshooting Common Issues

### Encrypted PDFs

```python
from pypdf import PdfReader

try:
    reader = PdfReader("encrypted.pdf")
    if reader.is_encrypted:
        reader.decrypt("password")
except Exception as e:
    print(f"Failed to decrypt: {e}")
```

### Corrupted PDFs

```bash
# Check and repair with qpdf
qpdf --check corrupted.pdf
qpdf --replace-input corrupted.pdf
```

### Text extraction returns empty

```python
# Likely a scanned PDF -- fall back to OCR
import pytesseract
from pdf2image import convert_from_path

def extract_text_with_ocr(pdf_path):
    images = convert_from_path(pdf_path, dpi=300)
    text = ""
    for image in images:
        text += pytesseract.image_to_string(image)
    return text
```

### pypdf form filling bug with selection lists

The skill's `pdf_fill_form.py` includes a monkey-patch for a pypdf bug where `get_inherited` returns list-of-pairs instead of strings for selection list options. This is handled automatically.

---

## License Information

- **pypdf**: BSD License
- **pdfplumber**: MIT License
- **pypdfium2**: Apache/BSD License
- **reportlab**: BSD License
- **poppler-utils**: GPL-2 License
- **qpdf**: Apache License
- **pdf-lib**: MIT License
- **pdfjs-dist**: Apache License
- **pytesseract**: Apache License
- **pdf2image**: MIT License
