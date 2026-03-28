# Northstar Trail Supply: Shopify Sales Analytics in BigQuery

## Project Overview
This project analyzes a **synthetic but realistic Shopify-style ecommerce dataset** for **Northstar Trail Supply**, built to simulate a real-world analyst workflow in BigQuery.

The objective was to complete the full analytics process end to end:

- understand a messy raw dataset
- load raw CSVs into BigQuery
- clean and validate the data using SQL
- build a master analytical table
- answer business questions around revenue, customers, products, trends, and refunds

This project is presented as a **portfolio case study** designed to reflect the type of messy, multi-table ecommerce environment analysts often work with. :contentReference[oaicite:1]{index=1}

---

## Business Context
**Brand:** Northstar Trail Supply  
**Business model:** Shopify-style ecommerce  
**Product focus:** coffee products, subscriptions, and branded accessories  
**Analysis period:** 2024-01-01 to 2025-06-30  

The business context and source files were structured to resemble a realistic ecommerce operation with transactional, customer, refund, marketing, inventory, and FX data. :contentReference[oaicite:2]{index=2}

---

## Dataset Scope
The project uses 9 raw source tables:

- `raw_customers.csv`
- `raw_products.csv`
- `raw_orders.csv`
- `raw_order_line_items.csv`
- `raw_refunds.csv`
- `raw_inventory_snapshots.csv`
- `raw_marketing_spend_daily.csv`
- `raw_web_sessions_daily.csv`
- `raw_fx_rates_daily.csv`

These files cover customer, sales, product, operations, marketing, and exchange-rate data. The dataset includes realistic ecommerce issues such as missing IDs, inconsistent timestamps, mixed text/numeric fields, refunds, guest checkouts, and one-to-many relationships between orders and line items. :contentReference[oaicite:3]{index=3}

---

## Tools Used
- **Google BigQuery**
- **SQL**
- **GitHub**
- **CSV source files**

---

## Project Workflow

### 1. Dataset Understanding
I first reviewed the raw files to understand the business structure, table relationships, and likely data quality issues.

This included identifying:
- missing values
- inconsistent timestamps
- messy free-text fields
- mixed numeric/text fields
- guest checkout and customer tracking gaps

### 2. Data Loading
All raw files were uploaded into BigQuery using the console upload flow with schema auto-detection for initial ingestion.

### 3. Data Cleaning and Validation
Each raw table was transformed into a structured analysis-ready version in BigQuery.

Cleaned tables created:
- `shopify_clean.orders_clean`
- `shopify_clean.customers_clean`
- `shopify_clean.products_clean`
- `shopify_clean.inventory_clean`
- `shopify_clean.order_line_items_clean`
- `shopify_clean.refunds_clean`
- `shopify_clean.channel_performance_clean`
- `shopify_clean.marketing_spend_clean`
- `shopify_clean.fx_rates_clean`

Key cleaning tasks included:
- parsing inconsistent timestamps
- converting text-based numbers into numeric fields
- standardizing text values
- cleaning phone numbers and identifiers
- handling nulls and blanks
- converting boolean-like fields into proper TRUE/FALSE values
- validating row counts and critical fields after transformation

### 4. Data Modeling
A unified analytical table, `master_sales`, was built by joining:
- orders
- order line items
- customers
- products
- refunds

This created a single analytical layer for product-level, customer-level, and revenue-level analysis.

### 5. Business Analysis
Using the cleaned tables and `master_sales`, I analyzed:
- revenue performance
- top products
- customer behavior
- monthly revenue trends
- refund impact
- product-level refund risk

---

## Key Insights

### Revenue
- Gross revenue: **$286,446**
- Net revenue: **$271,218**
- Revenue lost to refunds: **$15,228**
- Refunds account for roughly **5.3%** of gross revenue

### Product Performance
Revenue is concentrated among a relatively small number of core products.

- **Trail Brew Blend 12oz** contributes about **20%** of total revenue
- **High Ridge Espresso 12oz** contributes about **17%**
- the top 2 products generate more than **36%** of total revenue

This suggests strong SKU concentration and dependence on a few flagship products.

### Customer Behavior
A meaningful share of revenue is tied to orders without a customer ID, pointing to guest checkout or customer tracking gaps.

Among identified customers, spend is relatively distributed, suggesting a high-volume, low individual spend model rather than dependence on a few very high-value buyers.

### Revenue Trend
Revenue grows steadily through 2024, peaks strongly in Q4, and stabilizes at a higher baseline in early 2025.

This indicates:
- growth momentum
- clear seasonality
- a stronger post-peak baseline than early 2024

### Refunds
Refund rates are moderate overall, but meaningful enough to affect profitability.

At the product level, refund patterns suggest the issue is more likely systemic than isolated to one defective product, although the **Northstar Camp Mug** stands out as a possible product-specific concern.

---

## Repository Structure

```text
northstar-trail-supply-analytics/
├─ README.md
├─ data/
│  └─ raw/
├─ docs/
│  ├─ company_profile.md
│  ├─ data_dictionary.md
│  ├─ github_checkpoints.md
│  └─ project_plan.md
├─ sql/
│  ├─ 01_bigquery_upload_guide.md
│  ├─ 02_staging_cleaning.sql
│  ├─ 03_data_quality_checks.sql
│  ├─ 04_marts.sql
│  ├─ 05_analysis_queries.sql
│  └─ 06_final_report_queries.sql
└─ reports/
   ├─ analysis.md
   ├─ final_report_template.md
   └─ sample_final_report.md
