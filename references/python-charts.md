# Python Charts for LaTeX

## Overview

**Matplotlib** is Python's most popular plotting library for creating high-quality charts and visualizations. It produces publication-ready figures that integrate seamlessly with LaTeX documents.

### When to Use Matplotlib vs pgfplots

**Matplotlib:**
- Complex data processing with pandas/numpy
- Quick exploratory analysis
- Custom visualizations
- Python-based workflow
- External data sources (databases, APIs)

**pgfplots:**
- Simple data, small datasets
- Perfect LaTeX integration
- Vector graphics with LaTeX fonts
- Direct CSV reading in LaTeX
- No external dependencies

---

## Installation

### Required Packages

```bash
# Install matplotlib and dependencies
pip install matplotlib numpy pandas seaborn

# For additional chart types
pip install scipy scikit-learn
```

### LaTeX Packages

```latex
\usepackage{graphicx}  % For \includegraphics
\usepackage{float}     % For H placement
```

---

## Using the generate_chart.py Script

The skill includes a helper script for generating charts.

### Basic Usage

```bash
# Generate from Python data
python generate_chart.py \
    --type bar \
    --data "Category A:10,Category B:15,Category C:8" \
    --output chart.png \
    --title "Sales by Category"

# Generate from CSV file
python generate_chart.py \
    --type line \
    --csv data.csv \
    --x-col "Month" \
    --y-col "Revenue" \
    --output revenue_trend.pdf \
    --title "Monthly Revenue"

# Multiple series line chart
python generate_chart.py \
    --type line \
    --csv quarterly_data.csv \
    --x-col "Quarter" \
    --y-cols "Product A,Product B,Product C" \
    --output products.pdf \
    --title "Product Sales Comparison"

# Scatter plot with regression
python generate_chart.py \
    --type scatter \
    --csv experiment.csv \
    --x-col "Temperature" \
    --y-col "Yield" \
    --regression \
    --output scatter.pdf
```

### Script Options

- `--type` - Chart type (bar, line, scatter, pie, heatmap, box, histogram, area, radar)
- `--data` - Inline data (format varies by type)
- `--csv` - CSV file path
- `--x-col`, `--y-col`, `--y-cols` - Column names
- `--output` - Output filename (PNG or PDF)
- `--title` - Chart title
- `--xlabel`, `--ylabel` - Axis labels
- `--style` - Style preset (default, seaborn, ggplot, bmh)
- `--colormap` - Color palette
- `--dpi` - Resolution (default: 300)
- `--figsize` - Figure size in inches (e.g., "8x6")
- `--regression` - Add trend line (scatter plots)

---

## Bar Charts

Bar charts compare categorical data.

### Vertical Bar Chart

```python
import matplotlib.pyplot as plt
import numpy as np

# Data
categories = ['Q1', 'Q2', 'Q3', 'Q4']
values = [23, 45, 56, 78]

# Create figure with appropriate size for LaTeX
fig, ax = plt.subplots(figsize=(6, 4))

# Create bars
bars = ax.bar(categories, values, color='steelblue', edgecolor='black', linewidth=0.7)

# Add value labels on top of bars
for bar in bars:
    height = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2., height,
            f'{height}',
            ha='center', va='bottom', fontsize=10)

# Styling
ax.set_xlabel('Quarter', fontsize=12)
ax.set_ylabel('Sales (thousands)', fontsize=12)
ax.set_title('Quarterly Sales Performance', fontsize=14, fontweight='bold')
ax.grid(axis='y', alpha=0.3, linestyle='--')
ax.set_axisbelow(True)

# Save with high resolution for LaTeX
plt.tight_layout()
plt.savefig('quarterly_sales.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

**LaTeX Integration:**
```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{quarterly_sales.pdf}
    \caption{Quarterly sales performance showing consistent growth trend}
    \label{fig:quarterly-sales}
\end{figure}
```

### Grouped Bar Chart

```python
import matplotlib.pyplot as plt
import numpy as np

# Data
categories = ['Product A', 'Product B', 'Product C', 'Product D']
year_2023 = [23, 34, 45, 29]
year_2024 = [28, 39, 52, 35]

x = np.arange(len(categories))
width = 0.35

fig, ax = plt.subplots(figsize=(8, 5))

# Create grouped bars
bars1 = ax.bar(x - width/2, year_2023, width, label='2023',
               color='lightcoral', edgecolor='black', linewidth=0.7)
bars2 = ax.bar(x + width/2, year_2024, width, label='2024',
               color='steelblue', edgecolor='black', linewidth=0.7)

# Styling
ax.set_xlabel('Products', fontsize=12)
ax.set_ylabel('Sales (thousands)', fontsize=12)
ax.set_title('Year-over-Year Product Sales Comparison', fontsize=14, fontweight='bold')
ax.set_xticks(x)
ax.set_xticklabels(categories)
ax.legend(fontsize=10, frameon=True, shadow=True)
ax.grid(axis='y', alpha=0.3, linestyle='--')
ax.set_axisbelow(True)

plt.tight_layout()
plt.savefig('yoy_comparison.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Stacked Bar Chart

```python
import matplotlib.pyplot as plt
import numpy as np

categories = ['Q1', 'Q2', 'Q3', 'Q4']
online = [15, 22, 28, 35]
retail = [8, 12, 15, 18]
wholesale = [5, 11, 13, 25]

fig, ax = plt.subplots(figsize=(7, 5))

# Create stacked bars
ax.bar(categories, online, label='Online', color='#3498db')
ax.bar(categories, retail, bottom=online, label='Retail', color='#2ecc71')
ax.bar(categories, wholesale, bottom=np.array(online) + np.array(retail),
       label='Wholesale', color='#e74c3c')

ax.set_xlabel('Quarter', fontsize=12)
ax.set_ylabel('Revenue (millions)', fontsize=12)
ax.set_title('Revenue by Channel', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('stacked_revenue.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Horizontal Bar Chart

```python
import matplotlib.pyplot as plt

categories = ['Customer Service', 'Product Quality', 'Delivery Speed',
              'Price Value', 'Website UX']
scores = [4.2, 4.5, 3.8, 4.0, 4.3]

fig, ax = plt.subplots(figsize=(7, 5))

# Create horizontal bars
bars = ax.barh(categories, scores, color='mediumseagreen', edgecolor='black', linewidth=0.7)

# Add value labels
for i, bar in enumerate(bars):
    width = bar.get_width()
    ax.text(width + 0.05, bar.get_y() + bar.get_height()/2.,
            f'{scores[i]:.1f}',
            ha='left', va='center', fontsize=10, fontweight='bold')

ax.set_xlabel('Rating (out of 5)', fontsize=12)
ax.set_title('Customer Satisfaction Ratings', fontsize=14, fontweight='bold')
ax.set_xlim(0, 5)
ax.grid(axis='x', alpha=0.3)

plt.tight_layout()
plt.savefig('satisfaction_ratings.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Line Charts

Line charts show trends over time.

### Single Line Chart

```python
import matplotlib.pyplot as plt
import numpy as np

# Data
months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
users = [120, 135, 158, 172, 198, 225, 245, 268, 290, 315, 342, 380]

fig, ax = plt.subplots(figsize=(9, 5))

# Create line plot
ax.plot(months, users, marker='o', linewidth=2.5, markersize=6,
        color='steelblue', markerfacecolor='white', markeredgewidth=2)

# Styling
ax.set_xlabel('Month', fontsize=12)
ax.set_ylabel('Active Users (thousands)', fontsize=12)
ax.set_title('Monthly Active User Growth', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3, linestyle='--')
ax.set_axisbelow(True)

# Annotate peak
peak_idx = users.index(max(users))
ax.annotate(f'Peak: {max(users)}k',
            xy=(peak_idx, max(users)),
            xytext=(peak_idx-1, max(users)+20),
            arrowprops=dict(arrowstyle='->', color='red', lw=1.5),
            fontsize=10, fontweight='bold', color='red')

plt.tight_layout()
plt.savefig('user_growth.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Multi-Series Line Chart

```python
import matplotlib.pyplot as plt
import numpy as np

months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
product_a = [23, 25, 28, 32, 35, 40]
product_b = [18, 21, 24, 23, 26, 30]
product_c = [15, 16, 19, 22, 25, 28]

fig, ax = plt.subplots(figsize=(8, 5))

# Plot multiple lines
ax.plot(months, product_a, marker='o', linewidth=2, label='Product A', color='#e74c3c')
ax.plot(months, product_b, marker='s', linewidth=2, label='Product B', color='#3498db')
ax.plot(months, product_c, marker='^', linewidth=2, label='Product C', color='#2ecc71')

ax.set_xlabel('Month', fontsize=12)
ax.set_ylabel('Sales (thousands)', fontsize=12)
ax.set_title('Product Sales Trends', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left', frameon=True, shadow=True)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('product_trends.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Line Chart with Confidence Interval

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 10, 50)
y = 2 * x + 3 + np.random.randn(50) * 2
y_smooth = 2 * x + 3
y_upper = y_smooth + 4
y_lower = y_smooth - 4

fig, ax = plt.subplots(figsize=(8, 5))

# Plot confidence interval
ax.fill_between(x, y_lower, y_upper, alpha=0.2, color='steelblue', label='95% CI')
# Plot mean line
ax.plot(x, y_smooth, linewidth=2.5, color='steelblue', label='Mean')
# Plot actual data
ax.scatter(x, y, s=20, alpha=0.5, color='darkblue', label='Observed')

ax.set_xlabel('Time (hours)', fontsize=12)
ax.set_ylabel('Temperature (°C)', fontsize=12)
ax.set_title('Temperature Measurements with Confidence Interval', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('confidence_interval.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Scatter Plots

Scatter plots show relationships between two variables.

### Basic Scatter Plot

```python
import matplotlib.pyplot as plt
import numpy as np

# Generate sample data
np.random.seed(42)
x = np.random.randn(100) * 10 + 50
y = 2.5 * x + np.random.randn(100) * 20 + 10

fig, ax = plt.subplots(figsize=(7, 5))

# Create scatter plot
ax.scatter(x, y, s=50, alpha=0.6, color='steelblue', edgecolors='black', linewidth=0.5)

ax.set_xlabel('Study Hours', fontsize=12)
ax.set_ylabel('Test Score', fontsize=12)
ax.set_title('Relationship Between Study Time and Test Performance', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('scatter_basic.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Scatter Plot with Trend Line

```python
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats

np.random.seed(42)
x = np.random.randn(100) * 10 + 50
y = 2.5 * x + np.random.randn(100) * 20 + 10

# Calculate regression line
slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)
line = slope * x + intercept

fig, ax = plt.subplots(figsize=(7, 5))

# Scatter plot
ax.scatter(x, y, s=50, alpha=0.6, color='steelblue',
           edgecolors='black', linewidth=0.5, label='Data points')

# Regression line
ax.plot(x, line, 'r-', linewidth=2.5, label=f'Fit: y={slope:.2f}x+{intercept:.2f}')

# Add R² value
ax.text(0.05, 0.95, f'$R^2$ = {r_value**2:.3f}',
        transform=ax.transAxes, fontsize=11,
        verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

ax.set_xlabel('Study Hours', fontsize=12)
ax.set_ylabel('Test Score', fontsize=12)
ax.set_title('Study Time vs Test Performance with Linear Regression', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('scatter_regression.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Scatter Plot with Color Coding

```python
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(42)
x = np.random.rand(100) * 100
y = np.random.rand(100) * 100
colors = np.random.rand(100) * 100  # Color by third variable
sizes = np.random.rand(100) * 500 + 50  # Size by fourth variable

fig, ax = plt.subplots(figsize=(8, 6))

scatter = ax.scatter(x, y, c=colors, s=sizes, alpha=0.6,
                     cmap='viridis', edgecolors='black', linewidth=0.5)

# Add colorbar
cbar = plt.colorbar(scatter, ax=ax)
cbar.set_label('Performance Score', fontsize=11)

ax.set_xlabel('Feature A', fontsize=12)
ax.set_ylabel('Feature B', fontsize=12)
ax.set_title('Multi-dimensional Data Visualization', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('scatter_colored.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Pie and Donut Charts

### Pie Chart

```python
import matplotlib.pyplot as plt

categories = ['Mobile', 'Desktop', 'Tablet', 'Other']
values = [45, 35, 15, 5]
colors = ['#ff9999', '#66b3ff', '#99ff99', '#ffcc99']
explode = (0.1, 0, 0, 0)  # Explode first slice

fig, ax = plt.subplots(figsize=(7, 5))

wedges, texts, autotexts = ax.pie(values, explode=explode, labels=categories,
                                    colors=colors, autopct='%1.1f%%',
                                    shadow=True, startangle=90)

# Styling
for text in texts:
    text.set_fontsize(12)
    text.set_fontweight('bold')

for autotext in autotexts:
    autotext.set_color('white')
    autotext.set_fontsize(11)
    autotext.set_fontweight('bold')

ax.set_title('Traffic by Device Type', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('device_pie.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Donut Chart

```python
import matplotlib.pyplot as plt

categories = ['Development', 'Marketing', 'Operations', 'Research']
values = [40, 25, 20, 15]
colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']

fig, ax = plt.subplots(figsize=(7, 5))

# Create donut (pie with center circle)
wedges, texts, autotexts = ax.pie(values, labels=categories, colors=colors,
                                    autopct='%1.1f%%', startangle=90,
                                    pctdistance=0.85)

# Draw center circle
centre_circle = plt.Circle((0, 0), 0.70, fc='white')
ax.add_artist(centre_circle)

# Add center text
ax.text(0, 0, 'Budget\n$1.2M', ha='center', va='center',
        fontsize=14, fontweight='bold')

for autotext in autotexts:
    autotext.set_color('white')
    autotext.set_fontsize(10)
    autotext.set_fontweight('bold')

ax.set_title('Department Budget Allocation', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('budget_donut.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Heatmaps

Heatmaps visualize matrix data with colors.

```python
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

# Sample correlation matrix
np.random.seed(42)
data = np.random.rand(8, 8)
correlation = np.corrcoef(data)

labels = ['Feature 1', 'Feature 2', 'Feature 3', 'Feature 4',
          'Feature 5', 'Feature 6', 'Feature 7', 'Feature 8']

fig, ax = plt.subplots(figsize=(9, 7))

# Create heatmap
im = ax.imshow(correlation, cmap='coolwarm', aspect='auto', vmin=-1, vmax=1)

# Set ticks and labels
ax.set_xticks(np.arange(len(labels)))
ax.set_yticks(np.arange(len(labels)))
ax.set_xticklabels(labels, rotation=45, ha='right')
ax.set_yticklabels(labels)

# Add colorbar
cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Correlation Coefficient', fontsize=11)

# Add text annotations
for i in range(len(labels)):
    for j in range(len(labels)):
        text = ax.text(j, i, f'{correlation[i, j]:.2f}',
                      ha="center", va="center", color="black", fontsize=8)

ax.set_title('Feature Correlation Heatmap', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('heatmap.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Heatmap with Seaborn

```python
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd

# Create sample data
np.random.seed(42)
data = np.random.rand(10, 12)
df = pd.DataFrame(data,
                  columns=[f'M{i}' for i in range(1, 13)],
                  index=[f'Product {i}' for i in range(1, 11)])

fig, ax = plt.subplots(figsize=(10, 6))

# Create heatmap with seaborn
sns.heatmap(df, annot=True, fmt='.2f', cmap='YlOrRd',
            linewidths=0.5, cbar_kws={'label': 'Sales (millions)'},
            ax=ax)

ax.set_title('Monthly Sales by Product', fontsize=14, fontweight='bold')
ax.set_xlabel('Month', fontsize=12)
ax.set_ylabel('Product', fontsize=12)

plt.tight_layout()
plt.savefig('sales_heatmap.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Box Plots and Violin Plots

### Box Plot

```python
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(42)
data = [np.random.normal(100, 10, 200),
        np.random.normal(110, 15, 200),
        np.random.normal(105, 12, 200),
        np.random.normal(115, 20, 200)]

fig, ax = plt.subplots(figsize=(8, 5))

bp = ax.boxplot(data, labels=['Method A', 'Method B', 'Method C', 'Method D'],
                patch_artist=True, notch=True, showmeans=True)

# Color boxes
colors = ['lightblue', 'lightgreen', 'lightyellow', 'lightcoral']
for patch, color in zip(bp['boxes'], colors):
    patch.set_facecolor(color)

ax.set_ylabel('Performance Score', fontsize=12)
ax.set_title('Performance Comparison Across Methods', fontsize=14, fontweight='bold')
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('boxplot.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Violin Plot

```python
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(42)
data = [np.random.normal(100, 10, 200),
        np.random.normal(110, 15, 200),
        np.random.normal(105, 12, 200),
        np.random.normal(115, 20, 200)]

fig, ax = plt.subplots(figsize=(8, 5))

parts = ax.violinplot(data, showmeans=True, showmedians=True)

# Color violins
colors = ['lightblue', 'lightgreen', 'lightyellow', 'lightcoral']
for pc, color in zip(parts['bodies'], colors):
    pc.set_facecolor(color)
    pc.set_alpha(0.7)

ax.set_xticks([1, 2, 3, 4])
ax.set_xticklabels(['Method A', 'Method B', 'Method C', 'Method D'])
ax.set_ylabel('Performance Score', fontsize=12)
ax.set_title('Performance Distribution Across Methods', fontsize=14, fontweight='bold')
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('violinplot.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Histograms

```python
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats

np.random.seed(42)
data = np.random.normal(100, 15, 1000)

fig, ax = plt.subplots(figsize=(8, 5))

# Create histogram
n, bins, patches = ax.hist(data, bins=30, density=True, alpha=0.7,
                           color='steelblue', edgecolor='black')

# Fit normal distribution
mu, sigma = stats.norm.fit(data)
x = np.linspace(data.min(), data.max(), 100)
ax.plot(x, stats.norm.pdf(x, mu, sigma), 'r-', linewidth=2.5,
        label=f'Normal fit\n$\mu={mu:.1f}$, $\sigma={sigma:.1f}$')

ax.set_xlabel('Value', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Distribution of Sample Data', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('histogram.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Area Charts

```python
import matplotlib.pyplot as plt
import numpy as np

months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
product_a = [20, 25, 30, 35, 40, 45]
product_b = [15, 18, 22, 25, 28, 32]
product_c = [10, 12, 15, 18, 20, 23]

fig, ax = plt.subplots(figsize=(9, 5))

# Stacked area chart
ax.fill_between(months, 0, product_a, alpha=0.7, label='Product A', color='#3498db')
ax.fill_between(months, product_a, np.array(product_a) + np.array(product_b),
                alpha=0.7, label='Product B', color='#2ecc71')
ax.fill_between(months, np.array(product_a) + np.array(product_b),
                np.array(product_a) + np.array(product_b) + np.array(product_c),
                alpha=0.7, label='Product C', color='#e74c3c')

ax.set_xlabel('Month', fontsize=12)
ax.set_ylabel('Sales (thousands)', fontsize=12)
ax.set_title('Product Sales Composition Over Time', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('area_chart.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Radar/Spider Charts

```python
import matplotlib.pyplot as plt
import numpy as np

categories = ['Speed', 'Reliability', 'Ease of Use', 'Features', 'Support', 'Price']
values = [4.5, 4.2, 4.8, 3.9, 4.1, 4.6]

# Number of variables
N = len(categories)

# Compute angle for each axis
angles = [n / float(N) * 2 * np.pi for n in range(N)]
values += values[:1]  # Complete the circle
angles += angles[:1]

fig, ax = plt.subplots(figsize=(7, 7), subplot_kw=dict(projection='polar'))

# Plot data
ax.plot(angles, values, 'o-', linewidth=2, color='steelblue')
ax.fill(angles, values, alpha=0.25, color='steelblue')

# Fix axis labels
ax.set_xticks(angles[:-1])
ax.set_xticklabels(categories, fontsize=11)

# Set y-axis limits
ax.set_ylim(0, 5)
ax.set_yticks([1, 2, 3, 4, 5])
ax.set_yticklabels(['1', '2', '3', '4', '5'], fontsize=9)

ax.set_title('Product Evaluation Radar Chart', fontsize=14, fontweight='bold', pad=20)
ax.grid(True)

plt.tight_layout()
plt.savefig('radar_chart.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Using CSV Data with Pandas

### Reading and Plotting CSV

```python
import matplotlib.pyplot as plt
import pandas as pd

# Read CSV file
df = pd.read_csv('sales_data.csv')

# Example CSV structure:
# Month,Product_A,Product_B,Product_C
# Jan,23,18,15
# Feb,25,21,16
# ...

fig, ax = plt.subplots(figsize=(9, 5))

# Plot each column
ax.plot(df['Month'], df['Product_A'], marker='o', linewidth=2, label='Product A')
ax.plot(df['Month'], df['Product_B'], marker='s', linewidth=2, label='Product B')
ax.plot(df['Month'], df['Product_C'], marker='^', linewidth=2, label='Product C')

ax.set_xlabel('Month', fontsize=12)
ax.set_ylabel('Sales (thousands)', fontsize=12)
ax.set_title('Product Sales from CSV Data', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
plt.xticks(rotation=45)

plt.tight_layout()
plt.savefig('csv_chart.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

### Grouped Bar Chart from CSV

```python
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

df = pd.read_csv('comparison.csv')

# Example CSV:
# Category,Method_A,Method_B
# Task1,23,28
# Task2,34,39
# ...

categories = df['Category']
x = np.arange(len(categories))
width = 0.35

fig, ax = plt.subplots(figsize=(9, 5))

bars1 = ax.bar(x - width/2, df['Method_A'], width, label='Method A', color='lightcoral')
bars2 = ax.bar(x + width/2, df['Method_B'], width, label='Method B', color='steelblue')

ax.set_xlabel('Task', fontsize=12)
ax.set_ylabel('Performance', fontsize=12)
ax.set_title('Method Comparison from CSV', fontsize=14, fontweight='bold')
ax.set_xticks(x)
ax.set_xticklabels(categories)
ax.legend(fontsize=10)
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('csv_comparison.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Styling for LaTeX

### Font Configuration

```python
import matplotlib.pyplot as plt
import matplotlib

# Use LaTeX for text rendering (requires LaTeX installation)
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['font.family'] = 'serif'
matplotlib.rcParams['font.serif'] = ['Computer Modern Roman']

# Or use standard fonts
matplotlib.rcParams['font.family'] = 'sans-serif'
matplotlib.rcParams['font.size'] = 11
```

### Figure Sizes for LaTeX

```python
# Common LaTeX column widths
SINGLE_COLUMN = 3.5  # inches
DOUBLE_COLUMN = 7.0  # inches

# Create figure with appropriate size
fig, ax = plt.subplots(figsize=(SINGLE_COLUMN, SINGLE_COLUMN*0.75))
```

### DPI Settings

```python
# High resolution for publication
plt.savefig('chart.pdf', dpi=300, bbox_inches='tight')

# For screen display
plt.savefig('chart.png', dpi=150, bbox_inches='tight')

# Extra high resolution for posters
plt.savefig('chart.pdf', dpi=600, bbox_inches='tight')
```

### Style Presets

```python
import matplotlib.pyplot as plt

# Use built-in styles
plt.style.use('seaborn-v0_8-paper')  # Clean academic style
# plt.style.use('ggplot')  # R ggplot2 style
# plt.style.use('bmh')  # Bayesian Methods for Hackers style

# Or create custom style
plt.rcParams.update({
    'font.size': 11,
    'axes.labelsize': 12,
    'axes.titlesize': 14,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10,
    'legend.fontsize': 10,
    'figure.figsize': (7, 5),
    'axes.grid': True,
    'grid.alpha': 0.3,
    'grid.linestyle': '--',
})
```

---

## Color Palettes

### Colorblind-Friendly Palettes

```python
import matplotlib.pyplot as plt

# IBM colorblind-safe palette
colors_ibm = ['#648FFF', '#785EF0', '#DC267F', '#FE6100', '#FFB000']

# Tableau 10 (colorblind-safe)
colors_tableau = plt.cm.tab10.colors

# Seaborn colorblind palette
import seaborn as sns
colors_sns = sns.color_palette('colorblind')

# Use in plot
fig, ax = plt.subplots()
for i, color in enumerate(colors_ibm):
    ax.bar(i, i+1, color=color)
```

### Custom Color Maps

```python
from matplotlib.colors import LinearSegmentedColormap

# Define custom colormap
colors = ['#2E86AB', '#A23B72', '#F18F01']
n_bins = 100
cmap = LinearSegmentedColormap.from_list('custom', colors, N=n_bins)

# Use in heatmap
import numpy as np
data = np.random.rand(10, 10)
plt.imshow(data, cmap=cmap)
plt.colorbar()
```

---

## Saving as PNG vs PDF

### When to Use PNG

- **Raster graphics** with many data points
- **Web publishing** or presentations
- **Quick previews** during development
- **Complex visualizations** (heatmaps with many cells)

```python
plt.savefig('chart.png', dpi=300, bbox_inches='tight',
            facecolor='white', edgecolor='none')
```

### When to Use PDF

- **Publication-quality** figures
- **LaTeX documents** (vector graphics scale perfectly)
- **Simple plots** (lines, bars, scatter)
- **When file size matters less**

```python
plt.savefig('chart.pdf', dpi=300, bbox_inches='tight')
```

### Best Practices

```python
# Always use bbox_inches='tight' to avoid clipping
# Set appropriate DPI (300 for print, 150 for screen)
# Close figure after saving to free memory

plt.savefig('output.pdf', dpi=300, bbox_inches='tight')
plt.close()
```

---

## Integration in LaTeX

### Basic Inclusion

```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{chart.pdf}
    \caption{Descriptive caption explaining the chart}
    \label{fig:my-chart}
\end{figure}
```

### Side-by-Side Charts

```latex
\usepackage{subcaption}

\begin{figure}[H]
    \centering
    \begin{subfigure}[b]{0.48\textwidth}
        \centering
        \includegraphics[width=\textwidth]{chart1.pdf}
        \caption{First chart}
        \label{fig:chart1}
    \end{subfigure}
    \hfill
    \begin{subfigure}[b]{0.48\textwidth}
        \centering
        \includegraphics[width=\textwidth]{chart2.pdf}
        \caption{Second chart}
        \label{fig:chart2}
    \end{subfigure}
    \caption{Comparison of two methods}
    \label{fig:comparison}
\end{figure}
```

### Wrapping Text Around Figure

```latex
\usepackage{wrapfig}

\begin{wrapfigure}{r}{0.5\textwidth}
    \centering
    \includegraphics[width=0.48\textwidth]{chart.pdf}
    \caption{Small chart with text wrap}
    \label{fig:wrap}
\end{wrapfigure}

Text flows around the figure...
```

---

## Comparison: Matplotlib vs pgfplots

| Feature | Matplotlib | pgfplots |
|---------|-----------|----------|
| **Data Processing** | Excellent (numpy/pandas) | Limited (reads CSV) |
| **Syntax** | Python code | LaTeX code |
| **Learning Curve** | Moderate | Steep |
| **Customization** | Very flexible | Very flexible |
| **Quality** | High (raster/vector) | Excellent (native vector) |
| **File Size** | Can be large | Usually smaller |
| **Compilation** | Pre-compile (fast LaTeX) | Compile-time (slower) |
| **Font Matching** | External (config needed) | Native LaTeX fonts |
| **Complex Data** | Excellent | Poor |
| **Interactivity** | Yes (Jupyter) | No |
| **Version Control** | Python scripts | LaTeX code |
| **Dependencies** | Python + packages | LaTeX + pgfplots |
| **Best For** | Complex analysis, large data | Simple plots, perfect LaTeX integration |

### Use Matplotlib When:

- Processing complex datasets (CSV, databases, APIs)
- Using pandas for data manipulation
- Need statistical analysis (scipy, scikit-learn)
- Creating many charts programmatically
- Exploratory data analysis
- Large datasets (1000+ points)
- Custom visualizations not easily done in pgfplots

### Use pgfplots When:

- Small datasets (< 100 points)
- Need perfect LaTeX font matching
- Want inline data in LaTeX
- Simpler plots (line, bar, scatter basics)
- Minimizing external dependencies
- Vector graphics with minimal file size
- Native LaTeX compilation

---

## Complete Example Workflow

### 1. Python Script (generate_charts.py)

```python
#!/usr/bin/env python3
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Set style
plt.style.use('seaborn-v0_8-paper')
plt.rcParams['font.size'] = 11

# Read data
df = pd.read_csv('experiment_data.csv')

# Chart 1: Line plot
fig, ax = plt.subplots(figsize=(7, 4))
ax.plot(df['time'], df['measurement'], marker='o', linewidth=2)
ax.set_xlabel('Time (s)')
ax.set_ylabel('Measurement (units)')
ax.set_title('Experimental Results Over Time')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('figures/time_series.pdf', dpi=300, bbox_inches='tight')
plt.close()

# Chart 2: Bar plot
fig, ax = plt.subplots(figsize=(6, 4))
methods = ['Method A', 'Method B', 'Method C']
scores = [85, 92, 78]
ax.bar(methods, scores, color='steelblue', edgecolor='black')
ax.set_ylabel('Performance Score')
ax.set_title('Method Comparison')
ax.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.savefig('figures/method_comparison.pdf', dpi=300, bbox_inches='tight')
plt.close()

print("Charts generated successfully!")
```

### 2. LaTeX Document

```latex
\documentclass{article}
\usepackage{graphicx}
\usepackage{float}
\usepackage{subcaption}

\begin{document}

\section{Results}

Figure~\ref{fig:time-series} shows the experimental measurements
collected over a 10-hour period. The data exhibits a clear upward
trend with some periodic variations.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{figures/time_series.pdf}
    \caption{Time series of experimental measurements}
    \label{fig:time-series}
\end{figure}

We compared three different methods (Figure~\ref{fig:methods}).
Method B achieved the highest performance score of 92\%, followed
by Method A at 85\%.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.7\textwidth]{figures/method_comparison.pdf}
    \caption{Performance comparison across three methods}
    \label{fig:methods}
\end{figure}

\end{document}
```

### 3. Makefile

```makefile
.PHONY: all charts clean

all: paper.pdf

charts:
	python3 generate_charts.py

paper.pdf: paper.tex charts
	pdflatex paper.tex
	pdflatex paper.tex

clean:
	rm -f *.aux *.log *.out
	rm -f figures/*.pdf
```

### 4. Usage

```bash
# Generate all charts and compile document
make

# Regenerate just the charts
make charts

# Clean build files
make clean
```

---

## Additional Resources

- **Matplotlib Documentation**: https://matplotlib.org/stable/index.html
- **Matplotlib Gallery**: https://matplotlib.org/stable/gallery/index.html
- **Seaborn**: https://seaborn.pydata.org/ (high-level plotting)
- **Pandas Plotting**: https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.plot.html
- **Color Palettes**: https://colorbrewer2.org/
- **LaTeX Graphics**: https://en.wikibooks.org/wiki/LaTeX/Importing_Graphics
