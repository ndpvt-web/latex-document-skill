#!/usr/bin/env python3
"""
generate_chart.py
Generates publication-quality charts as PNG/PDF for LaTeX inclusion using matplotlib.

Examples:
    # Bar chart from JSON data
    ./generate_chart.py bar --data '{"x":["A","B","C"],"y":[10,20,15]}' --output bar.png --title "Sales by Region"

    # Line chart from CSV file
    ./generate_chart.py line --csv data.csv --output line.pdf --xlabel "Time" --ylabel "Value" --dpi 300

    # Scatter plot with custom styling
    ./generate_chart.py scatter --data '{"x":[1,2,3,4],"y":[2,4,1,3]}' --style seaborn-v0_8-darkgrid --figsize 10x6

    # Pie chart with custom colors
    ./generate_chart.py pie --data '{"labels":["A","B","C"],"values":[30,40,30]}' --colors "#FF6B6B,#4ECDC4,#45B7D1"
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path


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
            # PEP 668: retry with --break-system-packages for externally-managed envs
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


_ensure_package("numpy")
_ensure_package("pandas")
_ensure_package("matplotlib")

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt

# Chart type implementations
def plot_bar(data, ax, **kwargs):
    """Create a bar chart."""
    if 'x' in data and 'y' in data:
        x = data['x']
        y = data['y']
        legend_labels = kwargs.get('legend_labels', None)
        colors = kwargs.get('colors', None)

        # Check if y is multi-series (list of lists)
        is_multi_series = isinstance(y[0], (list, tuple)) if len(y) > 0 else False

        if is_multi_series:
            # Multi-series grouped bar chart
            n_series = len(y)
            n_groups = len(x)

            # Get colors for each series
            if colors is None:
                colors = get_colorblind_palette(n_series)

            # Calculate bar positions and width
            bar_width = 0.8 / n_series
            x_positions = np.arange(n_groups)

            for i, series in enumerate(y):
                offset = (i - n_series/2 + 0.5) * bar_width
                label = legend_labels[i] if legend_labels and i < len(legend_labels) else f"Series {i+1}"
                ax.bar(x_positions + offset, series, bar_width,
                      label=label, color=colors[i % len(colors)])

            ax.set_xticks(x_positions)
            ax.set_xticklabels(x)
        else:
            # Single-series bar chart (backward compatible)
            ax.bar(x, y, color=colors[0] if colors else None)
    else:
        raise ValueError("Bar chart requires 'x' and 'y' keys in data")

def plot_line(data, ax, **kwargs):
    """Create a line chart."""
    if 'x' in data and 'y' in data:
        x = data['x']
        y = data['y']
        legend_labels = kwargs.get('legend_labels', None)
        colors = kwargs.get('colors', None)
        show_grid = kwargs.get('show_grid', False)

        # Check if y is multi-series (list of lists)
        is_multi_series = isinstance(y[0], (list, tuple)) if len(y) > 0 else False

        if is_multi_series:
            # Multi-series line chart
            n_series = len(y)
            markers = ['o', 's', '^', 'D', 'v', '<', '>', 'p', '*', 'h']

            # Get colors for each series
            if colors is None:
                colors = get_colorblind_palette(n_series)

            for i, series in enumerate(y):
                label = legend_labels[i] if legend_labels and i < len(legend_labels) else f"Series {i+1}"
                marker = markers[i % len(markers)]
                ax.plot(x, series, marker=marker, linewidth=2,
                       label=label, color=colors[i % len(colors)])
        else:
            # Single-series line chart (backward compatible)
            ax.plot(x, y, marker='o', linewidth=2, color=colors[0] if colors else None)

        if show_grid:
            ax.grid(True, alpha=0.3)
    else:
        raise ValueError("Line chart requires 'x' and 'y' keys in data")

def plot_scatter(data, ax, **kwargs):
    """Create a scatter plot."""
    if 'x' in data and 'y' in data:
        x = data['x']
        y = data['y']
        sizes = data.get('sizes', 50)
        legend_labels = kwargs.get('legend_labels', None)
        colors = kwargs.get('colors', None)
        show_grid = kwargs.get('show_grid', False)

        # Check if y is multi-series (list of lists)
        is_multi_series = isinstance(y[0], (list, tuple)) if len(y) > 0 else False

        if is_multi_series:
            # Multi-series scatter plot
            n_series = len(y)
            markers = ['o', 's', '^', 'D', 'v', '<', '>', 'p', '*', 'h']

            # Get colors for each series
            if colors is None:
                colors = get_colorblind_palette(n_series)

            # Handle sizes for multi-series
            if isinstance(sizes, (int, float)):
                sizes = [sizes] * n_series

            for i, series in enumerate(y):
                label = legend_labels[i] if legend_labels and i < len(legend_labels) else f"Series {i+1}"
                marker = markers[i % len(markers)]
                size = sizes[i] if isinstance(sizes, list) and i < len(sizes) else 50
                ax.scatter(x, series, s=size, alpha=0.6,
                          label=label, color=colors[i % len(colors)], marker=marker)
        else:
            # Single-series scatter plot (backward compatible)
            ax.scatter(x, y, s=sizes, alpha=0.6, color=colors[0] if colors else None)

        if show_grid:
            ax.grid(True, alpha=0.3)
    else:
        raise ValueError("Scatter plot requires 'x' and 'y' keys in data")

def plot_pie(data, ax, **kwargs):
    """Create a pie chart."""
    if 'labels' in data and 'values' in data:
        labels = data['labels']
        values = data['values']
        colors = kwargs.get('colors', None)
        ax.pie(values, labels=labels, autopct='%1.1f%%', startangle=90, colors=colors)
        ax.axis('equal')
    else:
        raise ValueError("Pie chart requires 'labels' and 'values' keys in data")

def plot_heatmap(data, ax, **kwargs):
    """Create a heatmap."""
    if 'matrix' in data:
        matrix = np.array(data['matrix'])
        im = ax.imshow(matrix, cmap='viridis', aspect='auto')
        plt.colorbar(im, ax=ax)

        # Add row/column labels if provided
        if 'xlabels' in data:
            ax.set_xticks(range(len(data['xlabels'])))
            ax.set_xticklabels(data['xlabels'])
        if 'ylabels' in data:
            ax.set_yticks(range(len(data['ylabels'])))
            ax.set_yticklabels(data['ylabels'])
    else:
        raise ValueError("Heatmap requires 'matrix' key in data")

def plot_box(data, ax, **kwargs):
    """Create a box plot."""
    if 'data' in data:
        box_data = data['data']
        labels = data.get('labels', None)
        show_grid = kwargs.get('show_grid', False)
        ax.boxplot(box_data, labels=labels)
        if show_grid:
            ax.grid(True, alpha=0.3, axis='y')
    else:
        raise ValueError("Box plot requires 'data' key (list of lists)")

def plot_histogram(data, ax, **kwargs):
    """Create a histogram."""
    if 'values' in data:
        values = data['values']
        bins = data.get('bins', 10)
        colors = kwargs.get('colors', None)
        show_grid = kwargs.get('show_grid', False)
        ax.hist(values, bins=bins, edgecolor='black', alpha=0.7, color=colors[0] if colors else None)
        if show_grid:
            ax.grid(True, alpha=0.3, axis='y')
    else:
        raise ValueError("Histogram requires 'values' key in data")

def plot_area(data, ax, **kwargs):
    """Create an area chart."""
    if 'x' in data and 'y' in data:
        x = data['x']
        y = data['y']
        legend_labels = kwargs.get('legend_labels', None)
        colors = kwargs.get('colors', None)
        show_grid = kwargs.get('show_grid', False)

        # Check if y is multi-series (list of lists)
        is_multi_series = isinstance(y[0], (list, tuple)) if len(y) > 0 else False

        if is_multi_series:
            # Multi-series area chart (stacked)
            n_series = len(y)

            # Get colors for each series
            if colors is None:
                colors = get_colorblind_palette(n_series)

            # Convert to numpy array for stacking
            y_array = np.array(y)
            y_stack = np.zeros(len(x))

            for i in range(n_series):
                label = legend_labels[i] if legend_labels and i < len(legend_labels) else f"Series {i+1}"
                ax.fill_between(x, y_stack, y_stack + y_array[i],
                               alpha=0.7, label=label, color=colors[i % len(colors)])
                ax.plot(x, y_stack + y_array[i], linewidth=2, color=colors[i % len(colors)])
                y_stack += y_array[i]
        else:
            # Single-series area chart (backward compatible)
            ax.fill_between(x, y, alpha=0.7, color=colors[0] if colors else None)
            ax.plot(x, y, linewidth=2)

        if show_grid:
            ax.grid(True, alpha=0.3)
    else:
        raise ValueError("Area chart requires 'x' and 'y' keys in data")

def plot_radar(data, ax, **kwargs):
    """Create a radar chart."""
    if 'labels' in data and 'values' in data:
        labels = data['labels']
        values = data['values']

        num_vars = len(labels)
        angles = np.linspace(0, 2 * np.pi, num_vars, endpoint=False).tolist()
        values = values + [values[0]]  # Complete the circle
        angles += angles[:1]

        ax = plt.subplot(111, projection='polar')
        ax.plot(angles, values, 'o-', linewidth=2, color=kwargs.get('colors', [None])[0] if kwargs.get('colors') else None)
        ax.fill(angles, values, alpha=0.25, color=kwargs.get('colors', [None])[0] if kwargs.get('colors') else None)
        ax.set_xticks(angles[:-1])
        ax.set_xticklabels(labels)
        ax.set_ylim(0, max(values) * 1.1)
        ax.grid(True)
        return ax
    else:
        raise ValueError("Radar chart requires 'labels' and 'values' keys in data")

CHART_TYPES = {
    'bar': plot_bar,
    'line': plot_line,
    'scatter': plot_scatter,
    'pie': plot_pie,
    'heatmap': plot_heatmap,
    'box': plot_box,
    'histogram': plot_histogram,
    'area': plot_area,
    'radar': plot_radar,
}

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate publication-quality charts for LaTeX inclusion',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )

    parser.add_argument('chart_type', choices=CHART_TYPES.keys(),
                       help='Type of chart to generate')

    data_group = parser.add_mutually_exclusive_group(required=True)
    data_group.add_argument('--data', type=str,
                           help='Chart data as JSON string')
    data_group.add_argument('--csv', type=str,
                           help='Path to CSV file with chart data')

    parser.add_argument('--output', type=str, default='chart.png',
                       help='Output file path (default: chart.png)')
    parser.add_argument('--title', type=str, default='',
                       help='Chart title')
    parser.add_argument('--xlabel', type=str, default='',
                       help='X-axis label')
    parser.add_argument('--ylabel', type=str, default='',
                       help='Y-axis label')
    parser.add_argument('--style', type=str, default='seaborn-v0_8-whitegrid',
                       help='Matplotlib style (default: seaborn-v0_8-whitegrid)')
    parser.add_argument('--figsize', type=str, default='8x5',
                       help='Figure size as WxH in inches (default: 8x5)')
    parser.add_argument('--dpi', type=int, default=300,
                       help='DPI for output image (default: 300)')
    parser.add_argument('--colors', type=str, default=None,
                       help='Comma-separated hex color codes (e.g., #FF6B6B,#4ECDC4)')
    parser.add_argument('--legend', type=str, default=None,
                       help='Comma-separated series names for legend (e.g., "Series A,Series B,Series C")')
    parser.add_argument('--legend-loc', type=str, default='best',
                       help='Legend location: best, upper right, upper left, lower right, lower left, center, outside (default: best)')
    parser.add_argument('--grid', action='store_true',
                       help='Enable grid lines (default: off)')

    return parser.parse_args()

def load_data(args):
    """Load data from JSON string or CSV file."""
    if args.data:
        try:
            return json.loads(args.data)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON data: {e}", file=sys.stderr)
            sys.exit(1)
    elif args.csv:
        try:
            df = pd.read_csv(args.csv)
            # Convert DataFrame to dict format
            return {col: df[col].tolist() for col in df.columns}
        except Exception as e:
            print(f"Error: Failed to read CSV file: {e}", file=sys.stderr)
            sys.exit(1)

def parse_figsize(figsize_str):
    """Parse figsize string like '8x5' into tuple (8, 5)."""
    try:
        width, height = figsize_str.lower().split('x')
        return (float(width), float(height))
    except:
        print(f"Error: Invalid figsize format: {figsize_str}. Use format like '8x5'", file=sys.stderr)
        sys.exit(1)

def parse_colors(colors_str):
    """Parse comma-separated color string into list."""
    if not colors_str:
        return None
    return [c.strip() for c in colors_str.split(',')]

def parse_legend(legend_str):
    """Parse comma-separated legend string into list."""
    if not legend_str:
        return None
    return [label.strip() for label in legend_str.split(',')]

def get_colorblind_palette(n_colors):
    """Return a colorblind-friendly palette with n colors using Tol color scheme."""
    # Paul Tol's colorblind-friendly palette
    tol_bright = ['#4477AA', '#EE6677', '#228833', '#CCBB44', '#66CCEE', '#AA3377', '#BBBBBB']
    if n_colors <= len(tol_bright):
        return tol_bright[:n_colors]
    # If more colors needed, cycle through the palette
    return [tol_bright[i % len(tol_bright)] for i in range(n_colors)]

def main():
    args = parse_args()

    # Load data
    data = load_data(args)

    # Parse figsize, colors, and legend
    figsize = parse_figsize(args.figsize)
    colors = parse_colors(args.colors)
    legend_labels = parse_legend(args.legend)

    # Set style
    try:
        plt.style.use(args.style)
    except:
        print(f"Warning: Style '{args.style}' not found, using default", file=sys.stderr)

    # Create figure
    if args.chart_type == 'radar':
        fig = plt.figure(figsize=figsize, dpi=args.dpi)
        ax = None  # Radar chart creates its own axes
    else:
        fig, ax = plt.subplots(figsize=figsize, dpi=args.dpi)

    # Generate chart
    try:
        plot_func = CHART_TYPES[args.chart_type]
        result_ax = plot_func(data, ax, colors=colors, legend_labels=legend_labels, show_grid=args.grid)
        if result_ax is not None:
            ax = result_ax
    except Exception as e:
        print(f"Error: Failed to generate chart: {e}", file=sys.stderr)
        sys.exit(1)

    # Set labels and title
    if args.title:
        plt.title(args.title, fontsize=14, fontweight='bold')
    if args.xlabel and ax is not None:
        ax.set_xlabel(args.xlabel, fontsize=11)
    if args.ylabel and ax is not None:
        ax.set_ylabel(args.ylabel, fontsize=11)

    # Add legend if legend_labels were provided or if multi-series data exists
    if ax is not None and legend_labels is not None:
        # Handle legend location
        legend_loc = args.legend_loc
        if legend_loc == 'outside':
            ax.legend(bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)
        else:
            ax.legend(loc=legend_loc)

    # Tight layout for better spacing
    plt.tight_layout()

    # Save figure
    try:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(args.output, dpi=args.dpi, bbox_inches='tight')
        print(f"Successfully created: {args.output}", file=sys.stderr)
    except Exception as e:
        print(f"Error: Failed to save output: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
