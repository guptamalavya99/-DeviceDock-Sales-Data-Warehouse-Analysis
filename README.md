
# DeviceDock – Sales Data Warehouse & Analysis

**An End-to-End Data Engineering and Data Analytics Project**

**Technologies:** PostgreSQL | SQL | Python | Power BI

## 1. Project Overview

DeviceDock is an end-to-end electronics retail sales analysis project built using PostgreSQL, Python, and Power BI.

The project focuses on transforming raw and inconsistent sales data into clean, structured, and business-ready information.

It follows the **Medallion Architecture (Bronze → Silver → Gold)** to manage data ingestion, cleaning, and transformation. Python is used for Exploratory Data Analysis (EDA), while Power BI is used to build an interactive dashboard.

The main objective is to understand sales performance, customer behaviour, product trends, store performance, and profitability through data analysis.

### Project Highlights

| Metric | Value |
|---|---:|
| Source Records | 38,506 |
| Source CSV Files | 5 |
| Cleaned Sales Records | 31,810 |
| Customers | 4,800 |
| Products | 162 |
| Stores | 28 |
| Total Revenue | ₹2.06 Billion |
| Total Profit | ₹605 Million |

---

## 2. Dataset Description

The project uses an electronics retail dataset covering **2023–2025**.

It contains five CSV files with 60 columns in total.

| Dataset | Records | Description |
|---|---:|---|
| Sales | 32,420 | Sales transactions, quantities, prices, discounts, taxes, and shipping details. |
| Customers | 4,800 | Customer information, age, location, segments, and loyalty tiers. |
| Products | 162 | Product names, brands, categories, prices, and costs. |
| Stores | 28 | Store names, locations, regions, and sales channels. |
| Dates | 1,096 | Calendar information, including dates, months, quarters, and years. |

### Data Quality Issues

The original datasets contained:

- Missing values and duplicate records.
- Inconsistent date formats.
- Incorrect and invalid numerical values.
- Different formats for currency, discounts, and taxes.
- Inconsistent product categories, brand names, and locations.
- Placeholder values such as N/A, NULL, and UNKNOWN.

These issues were addressed during the data cleaning process.

---

## 3. Project Folder Structure

```text
DeviceDock/
│
├── Charts/          # EDA visualizations
├── Dashboard/       # Power BI dashboard
├── Data Structure/  # Dataset structure
├── Dataset/         # Source and processed datasets
├── Notebook/        # Python analysis notebooks
├── Reports/         # Project reports
├── SQL Scripts/     # PostgreSQL scripts
│
└── README.md
```

---

## 4. Project Workflow

The project was completed in four major stages.

### Stage 1: Data Warehousing – PostgreSQL

Implemented the Medallion Architecture using three layers.

**Bronze Layer – Raw Data Ingestion**

- Created five raw tables in PostgreSQL.
- Stored source data without modifying the original values.
- Used `COPY` for bulk CSV data loading.
- Created a stored procedure `bronze.load_bronze()` to automate ingestion.

**Silver Layer – Data Cleaning**

- Created properly typed tables.
- Handled missing values and placeholders.
- Standardized dates, currencies, percentages, and numerical values.
- Corrected inconsistent product categories, brands, and geographical names.
- Removed duplicate customer records.
- Validated quantities, ages, and warranty periods.
- Developed a reusable date-cleaning function: `silver.parse_date()`.

Created the stored procedure `silver.load_silver()` to automate the transformation process.

**Gold Layer – Data Modeling**

Created a Star Schema using five SQL views:

| View | Description |
|---|---|
| `fact_sales` | Sales transactions and calculated financial measures. |
| `dim_customers` | Customer details and segments. |
| `dim_products` | Product information and pricing. |
| `dim_stores` | Store and geographical details. |
| `dim_dates` | Calendar information. |

Calculated important measures such as Sales Amount, Total Cost, Profit Amount, and Profit Percentage.

### Stage 2: Data Analysis – Python

Connected PostgreSQL with Python using SQLAlchemy and loaded data from the Gold layer.

Performed:

- Data profiling and validation.
- Missing value and outlier handling.
- Duplicate removal.
- Data type corrections.
- Exploratory Data Analysis (EDA).
- Business-focused statistical analysis.

**Libraries used:**

`Pandas` | `NumPy` | `Matplotlib` | `Seaborn` | `SQLAlchemy`

The final analytical dataset contained **31,810 cleaned sales records**.

### Stage 3: Exploratory Data Analysis

Analyzed the data across five major areas:

1. **Sales Analysis:** Revenue, profit, monthly trends, and seasonality.
2. **Product Analysis:** Category and subcategory performance.
3. **Customer Analysis:** Customer segments, age groups, and loyalty tiers.
4. **Store Analysis:** Store locations, channels, and geographical performance.
5. **Discount Analysis:** Relationship between discount percentages and revenue.

Created visualizations using Matplotlib and Seaborn to identify important business patterns.

### Stage 4: Power BI Dashboard

Used the cleaned datasets to develop an interactive Power BI dashboard.

The dashboard covers:

- Sales and profitability KPIs.
- Revenue and profit trends.
- Product category performance.
- Customer and loyalty analysis.
- Store and geographical performance.
- Sales channel analysis.
- Discount and revenue analysis.

---

## 5. Key Business Insights

The analysis revealed the following findings:

**1. Revenue Seasonality**
- Q4 (October–December) contributes approximately 33% of total orders.
- November records the highest order volume, with 3,654 orders.
- November also records the highest monthly profit of approximately ₹69.4 million.
- Average revenue per order peaks in March and April.

**2. Product Performance**
- Laptops generate the highest average revenue per order (₹147K).
- Smartphones lead in order volume with 7,673 orders.
- Tablets generate approximately ₹87K in average revenue per order.
- Audio and Accessories have relatively high order volumes but lower average revenue.

**3. Customer Performance**
- Consumer customers contribute approximately ₹1.14 billion in revenue.
- Standard-tier customers generate approximately ₹998 million.
- VIP customers contribute approximately ₹87 million.
- Customer age has almost no correlation with spending (r ≈ -0.003).

**4. Store Performance**
- Retail contributes approximately ₹1.31 billion, accounting for 64% of revenue.
- Business Parks generate approximately ₹639 million.
- Uttar Pradesh leads state-level revenue with ₹258 million.
- The North region contributes approximately ₹710 million.

**5. Discount Analysis**
- Discount percentage and revenue have a negligible correlation (r ≈ -0.02).
- Higher discounts do not necessarily result in higher revenue.

---

## 6. Technology Stack

| Tool | Purpose |
|---|---|
| PostgreSQL | Database and data warehouse |
| SQL / PL/pgSQL | Data ingestion, cleaning, and transformation |
| Python | Data analysis and EDA |
| Pandas | Data manipulation |
| NumPy | Numerical operations |
| Matplotlib | Data visualization |
| Seaborn | Statistical visualization |
| SQLAlchemy | Database connectivity |
| Power BI | Interactive dashboard |
| Git & GitHub | Version control and documentation |

---

## 7. Project Outcomes

Through this project, I gained practical experience in:

- Implementing Medallion Architecture.
- Building a PostgreSQL data warehouse.
- Writing SQL scripts, stored procedures, and reusable functions.
- Handling real-world data quality issues.
- Designing a Star Schema.
- Connecting PostgreSQL with Python.
- Performing EDA and extracting business insights.
- Developing interactive Power BI dashboards.

**Final Outcome:** Successfully built an end-to-end data pipeline that transforms raw electronics retail data into a structured data warehouse, analytical datasets, and business-ready insights.

---

**Project Name:** DeviceDock – Sales Data Warehouse & Analysis

**Author:** Malavya Gupta

**Domain:** Data Engineering | Data Analytics | Business Intelligence
