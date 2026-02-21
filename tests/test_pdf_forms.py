#!/usr/bin/env python3
"""
Comprehensive pytest tests for PDF form bounding box validation.

Tests cover:
- Bounding box intersection validation
- Entry box height validation
- Font size handling
- Validation image creation
- Edge cases (touching boxes, multiple errors, different pages)
"""

import json
import sys
import tempfile
from pathlib import Path

import pytest

# Add scripts directory to path
SCRIPTS_DIR = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

from pdf_validate_boxes import get_bounding_box_messages, create_validation_image, rects_intersect


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def temp_dir():
    """Create a temporary directory for test files."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


@pytest.fixture
def valid_fields_data():
    """Create valid fields data with no intersections."""
    return {
        "form_fields": [
            {
                "description": "Field1",
                "page_number": 1,
                "label_bounding_box": [10, 10, 100, 30],
                "entry_bounding_box": [110, 10, 200, 30],
                "entry_text": {"font_size": 12}
            },
            {
                "description": "Field2",
                "page_number": 1,
                "label_bounding_box": [10, 40, 100, 60],
                "entry_bounding_box": [110, 40, 200, 60],
                "entry_text": {"font_size": 12}
            }
        ]
    }


@pytest.fixture
def test_image(temp_dir):
    """Create a test PNG image."""
    try:
        from PIL import Image
    except ImportError:
        pytest.skip("PIL not available")

    test_image_path = temp_dir / "test_page.png"
    img = Image.new('RGB', (800, 1100), 'white')
    img.save(test_image_path)
    return test_image_path


# ============================================================================
# BOUNDING BOX VALIDATION TESTS
# ============================================================================

class TestBoundingBoxValidation:
    """Tests for bounding box validation logic."""

    def test_no_intersections(self, valid_fields_data):
        """Test valid boxes with no intersections - expect SUCCESS."""
        messages = get_bounding_box_messages(valid_fields_data)

        assert any("SUCCESS" in msg for msg in messages)
        assert not any("FAILURE" in msg for msg in messages)
        assert any("2 fields" in msg for msg in messages)

    def test_label_entry_intersection_same_field(self):
        """Test overlapping label/entry for the same field - expect FAILURE."""
        fields_data = {
            "form_fields": [
                {
                    "description": "OverlappingField",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [50, 10, 150, 30],  # Overlaps with label
                    "entry_text": {"font_size": 12}
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        assert any("FAILURE" in msg for msg in messages)
        assert any("intersection between label and entry bounding boxes" in msg for msg in messages)
        assert any("OverlappingField" in msg for msg in messages)

    def test_intersection_between_different_fields(self):
        """Test overlapping boxes from different fields - expect FAILURE."""
        fields_data = {
            "form_fields": [
                {
                    "description": "Field1",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 30]
                },
                {
                    "description": "Field2",
                    "page_number": 1,
                    "label_bounding_box": [10, 20, 100, 40],  # Overlaps with Field1 label
                    "entry_bounding_box": [110, 20, 200, 40]
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        assert any("FAILURE" in msg for msg in messages)
        assert any("intersection between" in msg and "Field1" in msg for msg in messages)
        assert any("Field2" in msg for msg in messages)

    def test_different_pages_no_intersection(self):
        """Test same coordinates on different pages - expect SUCCESS."""
        fields_data = {
            "form_fields": [
                {
                    "description": "Field1Page1",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 30],
                    "entry_text": {"font_size": 12}
                },
                {
                    "description": "Field1Page2",
                    "page_number": 2,
                    "label_bounding_box": [10, 10, 100, 30],  # Same coords, different page
                    "entry_bounding_box": [110, 10, 200, 30],
                    "entry_text": {"font_size": 12}
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        assert any("SUCCESS" in msg for msg in messages)
        assert not any("FAILURE" in msg for msg in messages)

    def test_entry_height_too_small(self):
        """Test entry box shorter than font_size - expect FAILURE."""
        fields_data = {
            "form_fields": [
                {
                    "description": "TooSmallEntry",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 20],  # Height = 10
                    "entry_text": {"font_size": 14}  # Font size > height
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        assert any("FAILURE" in msg for msg in messages)
        assert any("entry bounding box height" in msg and "too short" in msg for msg in messages)
        assert any("TooSmallEntry" in msg for msg in messages)
        assert any("font size: 14" in msg for msg in messages)

    def test_entry_height_adequate(self):
        """Test entry box taller than font_size - expect SUCCESS."""
        fields_data = {
            "form_fields": [
                {
                    "description": "AdequateEntry",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 35],  # Height = 25
                    "entry_text": {"font_size": 14}  # Font size < height
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        assert any("SUCCESS" in msg for msg in messages)
        assert not any("FAILURE" in msg for msg in messages)

    def test_default_font_size(self):
        """Test that missing font_size uses default of 14."""
        fields_data = {
            "form_fields": [
                {
                    "description": "DefaultFontSize",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 20],  # Height = 10
                    "entry_text": {}  # No font_size specified
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        # Should fail because default 14 > height 10
        assert any("FAILURE" in msg for msg in messages)
        assert any("font size: 14" in msg for msg in messages)

    def test_no_entry_text(self):
        """Test that missing entry_text skips height check - expect SUCCESS."""
        fields_data = {
            "form_fields": [
                {
                    "description": "NoEntryText",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 15]  # Height = 5, but no entry_text
                    # No entry_text field
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        # Should succeed because height check is skipped when entry_text is missing
        assert any("SUCCESS" in msg for msg in messages)
        assert not any("FAILURE" in msg for msg in messages)

    def test_multiple_errors_limit(self):
        """Test that validation aborts after ~20 messages with many overlapping fields."""
        # Create 25 overlapping fields
        fields = []
        for i in range(25):
            fields.append({
                "description": f"Field{i}",
                "page_number": 1,
                "label_bounding_box": [10, 10, 100, 30],  # All overlap
                "entry_bounding_box": [110, 10, 200, 30]  # All overlap
            })

        fields_data = {"form_fields": fields}
        messages = get_bounding_box_messages(fields_data)

        # Should abort before reporting all errors
        assert any("Aborting further checks" in msg for msg in messages)
        assert len(messages) <= 25  # Should stop before checking all combinations

    def test_edge_touching_boxes(self):
        """Test that boxes touching at edges don't intersect - expect SUCCESS."""
        fields_data = {
            "form_fields": [
                {
                    "description": "Field1",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [100, 10, 200, 30],  # Left edge touches right edge of label
                    "entry_text": {"font_size": 12}
                }
            ]
        }

        messages = get_bounding_box_messages(fields_data)

        # Touching edges should not be considered intersection
        assert any("SUCCESS" in msg for msg in messages)
        assert not any("FAILURE" in msg for msg in messages)


# ============================================================================
# VALIDATION IMAGE CREATION TESTS
# ============================================================================

class TestValidationImageCreation:
    """Tests for validation image creation."""

    def test_creates_image_file(self, temp_dir, test_image):
        """Test that validation image is created successfully."""
        fields_data = {
            "form_fields": [
                {
                    "description": "Field1",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 30]
                }
            ]
        }

        output_path = temp_dir / "validation.png"
        create_validation_image(1, fields_data, str(test_image), str(output_path))

        assert output_path.exists()
        assert output_path.stat().st_size > 0

    def test_draws_correct_number_of_boxes(self, temp_dir, test_image, capsys):
        """Test that correct number of boxes are drawn."""
        fields_data = {
            "form_fields": [
                {
                    "description": "Field1",
                    "page_number": 1,
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 30]
                },
                {
                    "description": "Field2",
                    "page_number": 1,
                    "label_bounding_box": [10, 40, 100, 60],
                    "entry_bounding_box": [110, 40, 200, 60]
                },
                {
                    "description": "Field3Page2",
                    "page_number": 2,  # Different page, should not be drawn
                    "label_bounding_box": [10, 10, 100, 30],
                    "entry_bounding_box": [110, 10, 200, 30]
                }
            ]
        }

        output_path = temp_dir / "validation.png"
        create_validation_image(1, fields_data, str(test_image), str(output_path))

        # Capture stdout to verify the message
        captured = capsys.readouterr()
        assert "4 bounding boxes" in captured.out  # 2 fields * 2 boxes each


# ============================================================================
# HELPER FUNCTION TESTS
# ============================================================================

class TestHelperFunctions:
    """Tests for helper functions."""

    def test_rects_intersect_overlapping(self):
        """Test that overlapping rectangles are detected."""
        r1 = [10, 10, 50, 50]
        r2 = [30, 30, 70, 70]
        assert rects_intersect(r1, r2) is True

    def test_rects_intersect_disjoint(self):
        """Test that disjoint rectangles are not detected as intersecting."""
        r1 = [10, 10, 50, 50]
        r2 = [60, 60, 100, 100]
        assert rects_intersect(r1, r2) is False

    def test_rects_intersect_touching_edges(self):
        """Test that rectangles touching at edges don't intersect."""
        r1 = [10, 10, 50, 50]
        r2 = [50, 10, 90, 50]  # Left edge touches right edge of r1
        assert rects_intersect(r1, r2) is False

    def test_rects_intersect_one_inside_other(self):
        """Test that a rectangle inside another is detected as intersecting."""
        r1 = [10, 10, 100, 100]
        r2 = [30, 30, 50, 50]  # r2 inside r1
        assert rects_intersect(r1, r2) is True

    def test_rects_intersect_horizontal_overlap_only(self):
        """Test rectangles with only horizontal overlap don't intersect."""
        r1 = [10, 10, 50, 50]
        r2 = [30, 60, 70, 100]  # Overlaps horizontally but not vertically
        assert rects_intersect(r1, r2) is False

    def test_rects_intersect_vertical_overlap_only(self):
        """Test rectangles with only vertical overlap don't intersect."""
        r1 = [10, 10, 50, 50]
        r2 = [60, 30, 100, 70]  # Overlaps vertically but not horizontally
        assert rects_intersect(r1, r2) is False


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
