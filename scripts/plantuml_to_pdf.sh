#!/usr/bin/env bash

# plantuml_to_pdf.sh
# Converts PlantUML .puml files to PDF, PNG, or SVG for LaTeX inclusion
#
# Examples:
#   ./plantuml_to_pdf.sh diagram.puml
#   ./plantuml_to_pdf.sh diagram.puml --output result.pdf --format pdf
#   ./plantuml_to_pdf.sh diagram.puml --format svg
#   ./plantuml_to_pdf.sh diagrams/source/  # Batch mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_deps.sh"

# Default values
FORMAT="pdf"
OUTPUT_FILE=""
RESOLUTION="300"

# Print usage
usage() {
    cat << EOF
Usage: $0 <input.puml|directory> [OPTIONS]

Convert PlantUML .puml files to PDF, PNG, or SVG for LaTeX inclusion.

Arguments:
  input.puml        Input PlantUML .puml file
  directory         Directory containing .puml files (batch mode)

Options:
  --output FILE     Output file path (default: input name with format extension)
  --format FORMAT   Output format: pdf, png, or svg (default: pdf)
  --resolution RES  Resolution for PNG output (default: 300)
  -h, --help        Show this help message

Examples:
  $0 diagram.puml
  $0 diagram.puml --output result.pdf
  $0 diagram.puml --format png
  $0 diagrams/source/ --format pdf

Requires: plantuml and Java (auto-installs if missing)
EOF
    exit 0
}

# Check if help is requested or no args
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

INPUT_PATH="$1"
shift

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --resolution)
            RESOLUTION="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Run '$0 --help' for usage information" >&2
            exit 1
            ;;
    esac
done

# Validate format
case "$FORMAT" in
    pdf|png|svg)
        ;;
    *)
        echo "Error: Format must be 'pdf', 'png', or 'svg', got: $FORMAT" >&2
        exit 1
        ;;
esac

# Validate resolution is a number
if ! [[ "$RESOLUTION" =~ ^[0-9]+$ ]]; then
    echo "Error: Resolution must be a number, got: $RESOLUTION" >&2
    exit 1
fi

# Check if Java is installed (required for PlantUML)
if ! command -v java &>/dev/null; then
    echo "Java not found. PlantUML requires Java." >&2
    echo "" >&2
    echo "Installing Java..." >&2

    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apt)
            run_pkg_install default-jre
            ;;
        brew)
            run_pkg_install openjdk
            ;;
        dnf)
            run_pkg_install java-latest-openjdk
            ;;
        apk)
            run_pkg_install openjdk11-jre
            ;;
        pacman)
            run_pkg_install jre-openjdk
            ;;
        *)
            echo "Error: Could not auto-install Java" >&2
            echo "" >&2
            echo "Please install Java manually:" >&2
            echo "  Debian/Ubuntu:  sudo apt-get install default-jre" >&2
            echo "  macOS:          brew install openjdk" >&2
            echo "  Fedora/RHEL:    sudo dnf install java-latest-openjdk" >&2
            echo "  Alpine:         sudo apk add openjdk11-jre" >&2
            echo "  Arch:           sudo pacman -S jre-openjdk" >&2
            echo "" >&2
            echo "Or download from: https://adoptium.net/" >&2
            exit 1
            ;;
    esac
fi

# Check if PlantUML is installed
PLANTUML_CMD=""

if command -v plantuml &>/dev/null; then
    # PlantUML is installed as a command
    PLANTUML_CMD="plantuml"
elif [[ -f "$HOME/.local/share/plantuml/plantuml.jar" ]]; then
    # PlantUML JAR is in local directory
    PLANTUML_CMD="java -jar $HOME/.local/share/plantuml/plantuml.jar"
elif [[ -f "/usr/share/plantuml/plantuml.jar" ]]; then
    # PlantUML JAR is in system directory
    PLANTUML_CMD="java -jar /usr/share/plantuml/plantuml.jar"
else
    # Try to install PlantUML
    echo "PlantUML not found. Installing..." >&2

    mgr="$(detect_pkg_manager)"
    case "$mgr" in
        apt)
            run_pkg_install plantuml
            PLANTUML_CMD="plantuml"
            ;;
        brew)
            run_pkg_install plantuml
            PLANTUML_CMD="plantuml"
            ;;
        dnf)
            run_pkg_install plantuml
            PLANTUML_CMD="plantuml"
            ;;
        apk)
            run_pkg_install plantuml
            PLANTUML_CMD="plantuml"
            ;;
        pacman)
            run_pkg_install plantuml
            PLANTUML_CMD="plantuml"
            ;;
        *)
            # Download PlantUML JAR manually
            echo "Package manager installation not available. Downloading PlantUML JAR..." >&2
            mkdir -p "$HOME/.local/share/plantuml"
            PLANTUML_JAR="$HOME/.local/share/plantuml/plantuml.jar"

            if command -v curl &>/dev/null; then
                curl -L -o "$PLANTUML_JAR" "https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar"
            elif command -v wget &>/dev/null; then
                wget -O "$PLANTUML_JAR" "https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar"
            else
                echo "Error: Neither curl nor wget found. Cannot download PlantUML." >&2
                echo "" >&2
                echo "Please install PlantUML manually:" >&2
                echo "  1. Download from: https://plantuml.com/download" >&2
                echo "  2. Save as: $PLANTUML_JAR" >&2
                exit 1
            fi

            if [[ -f "$PLANTUML_JAR" ]]; then
                echo "Successfully downloaded PlantUML to $PLANTUML_JAR" >&2
                PLANTUML_CMD="java -jar $PLANTUML_JAR"
            else
                echo "Error: Failed to download PlantUML" >&2
                exit 1
            fi
            ;;
    esac
fi

# Verify PlantUML works
if ! $PLANTUML_CMD -version &>/dev/null; then
    echo "Error: PlantUML installation failed or is not working" >&2
    exit 1
fi

# Function to convert a single file
convert_file() {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file not found: $input_file" >&2
        return 1
    fi

    # Validate .puml extension
    if [[ ! "$input_file" =~ \.(puml|plantuml|pu)$ ]]; then
        echo "Warning: Input file does not have .puml extension: $input_file" >&2
    fi

    echo "Converting $input_file -> $output_file (format: $FORMAT)" >&2

    # Build command based on format
    local format_flag=""
    case "$FORMAT" in
        pdf)
            format_flag="-tpdf"
            ;;
        png)
            format_flag="-tpng"
            ;;
        svg)
            format_flag="-tsvg"
            ;;
    esac

    # PlantUML outputs to the same directory as input by default
    # We need to handle output path specially
    local output_dir
    output_dir="$(dirname "$output_file")"
    local output_filename
    output_filename="$(basename "$output_file")"

    # Create a temporary copy if we need to control output location
    if [[ "$output_dir" != "$(dirname "$input_file")" ]]; then
        # Output to different directory - use -o flag
        if [[ "$FORMAT" == "png" ]]; then
            $PLANTUML_CMD "$format_flag" -Sresolution="$RESOLUTION" -o "$(realpath "$output_dir")" "$input_file" 2>&1
        else
            $PLANTUML_CMD "$format_flag" -o "$(realpath "$output_dir")" "$input_file" 2>&1
        fi

        # PlantUML uses input filename, may need to rename
        local default_output
        default_output="$output_dir/$(basename "${input_file%.*}").$FORMAT"
        if [[ "$default_output" != "$output_file" ]] && [[ -f "$default_output" ]]; then
            mv "$default_output" "$output_file"
        fi
    else
        # Output to same directory as input
        if [[ "$FORMAT" == "png" ]]; then
            $PLANTUML_CMD "$format_flag" -Sresolution="$RESOLUTION" "$input_file" 2>&1
        else
            $PLANTUML_CMD "$format_flag" "$input_file" 2>&1
        fi

        # Rename if needed
        local default_output
        default_output="$(dirname "$input_file")/$(basename "${input_file%.*}").$FORMAT"
        if [[ "$default_output" != "$output_file" ]] && [[ -f "$default_output" ]]; then
            mv "$default_output" "$output_file"
        fi
    fi

    if [[ -f "$output_file" ]]; then
        echo "Successfully created: $output_file" >&2
        return 0
    else
        echo "Error: Failed to convert $input_file" >&2
        return 1
    fi
}

# Check if input is a directory (batch mode) or a file
if [[ -d "$INPUT_PATH" ]]; then
    # Batch mode: convert all .puml files in directory
    echo "Batch mode: converting all .puml files in $INPUT_PATH" >&2

    # Remove trailing slash
    INPUT_PATH="${INPUT_PATH%/}"

    # Find all .puml files (and variants)
    shopt -s nullglob
    puml_files=("$INPUT_PATH"/*.puml "$INPUT_PATH"/*.plantuml "$INPUT_PATH"/*.pu)

    if [[ ${#puml_files[@]} -eq 0 ]]; then
        echo "Error: No .puml files found in $INPUT_PATH" >&2
        exit 1
    fi

    echo "Found ${#puml_files[@]} .puml file(s)" >&2

    success_count=0
    fail_count=0

    for puml_file in "${puml_files[@]}"; do
        # Handle different extensions
        if [[ "$puml_file" =~ \.puml$ ]]; then
            filename=$(basename "$puml_file" .puml)
        elif [[ "$puml_file" =~ \.plantuml$ ]]; then
            filename=$(basename "$puml_file" .plantuml)
        elif [[ "$puml_file" =~ \.pu$ ]]; then
            filename=$(basename "$puml_file" .pu)
        else
            filename=$(basename "$puml_file")
        fi

        output_file="$INPUT_PATH/${filename}.$FORMAT"

        if convert_file "$puml_file" "$output_file"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done

    echo "" >&2
    echo "Batch conversion complete:" >&2
    echo "  Success: $success_count" >&2
    echo "  Failed: $fail_count" >&2

    if [[ $fail_count -gt 0 ]]; then
        exit 1
    fi

elif [[ -f "$INPUT_PATH" ]]; then
    # Single file mode

    # Determine output file
    if [[ -z "$OUTPUT_FILE" ]]; then
        # Default: replace extension with format
        if [[ "$INPUT_PATH" =~ \.puml$ ]]; then
            OUTPUT_FILE="${INPUT_PATH%.puml}.$FORMAT"
        elif [[ "$INPUT_PATH" =~ \.plantuml$ ]]; then
            OUTPUT_FILE="${INPUT_PATH%.plantuml}.$FORMAT"
        elif [[ "$INPUT_PATH" =~ \.pu$ ]]; then
            OUTPUT_FILE="${INPUT_PATH%.pu}.$FORMAT"
        else
            OUTPUT_FILE="${INPUT_PATH}.$FORMAT"
        fi
    fi

    convert_file "$INPUT_PATH" "$OUTPUT_FILE"

else
    echo "Error: Input path not found: $INPUT_PATH" >&2
    exit 1
fi
