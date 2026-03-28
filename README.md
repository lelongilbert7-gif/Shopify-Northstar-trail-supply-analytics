# Northstar Trail Supply — messy Shopify dataset for BigQuery

This repository starter pack contains a **synthetic but realistic Shopify-style ecommerce dataset** plus a complete **BigQuery analytics project plan**.

## What is included
- Raw CSV files under `data/raw/`
- A company profile and data dictionary in `docs/`
- BigQuery SQL for:
  - staging / cleaning
  - data quality checks
  - marts / fact tables
  - analysis queries
  - final report queries
- A sample final report in `reports/`

## Dataset scope
- Store: **Northstar Trail Supply**
- Period: **2024-01-01 to 2025-06-30**
- Countries: primarily **US + Canada**
- Raw files:
- `raw_customers.csv`: 2,320 rows
- `raw_products.csv`: 31 rows
- `raw_orders.csv`: 4,081 rows
- `raw_order_line_items.csv`: 6,493 rows
- `raw_refunds.csv`: 161 rows
- `raw_inventory_snapshots.csv`: 2,449 rows
- `raw_marketing_spend_daily.csv`: 2,735 rows
- `raw_web_sessions_daily.csv`: 4,376 rows
- `raw_fx_rates_daily.csv`: 1,094 rows

## Recommended BigQuery layout
Use **three datasets** in BigQuery:
- `northstar_raw`
- `northstar_staging`
- `northstar_marts`

## Best way to load the raw CSVs
For a portfolio project, load the CSV files into standard BigQuery tables from the console upload flow, then transform them inside BigQuery. Google’s console quickstart shows the `Create table from > Upload` workflow and the schema text entry pattern. BigQuery also notes that if your source changes infrequently, **load jobs** are usually the cheaper and less resource-intensive option than keeping data external, and external tables can be slower than loaded tables.

See:
- https://docs.cloud.google.com/bigquery/docs/quickstarts/load-data-console
- https://docs.cloud.google.com/bigquery/docs/loading-data
- https://docs.cloud.google.com/bigquery/docs/external-tables

## Suggested repo structure
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
   ├─ final_report_template.md
   └─ sample_final_report.md
```

## Notes on realism
This dataset is **fictional**. It is designed to resemble common patterns in Shopify exports and ecommerce analytics:
- one order with multiple line items
- guest checkout
- messy free-text statuses
- inconsistent timestamps
- discounts, refunds, shipping, and tax
- multiple channels and campaign spend
- inventory snapshots
- CAD orders that require FX handling for USD reporting

## Official references used to design the project
- Shopify product CSV help: https://help.shopify.com/en/manual/products/import-export/using-csv
- Shopify order export help: https://help.shopify.com/en/manual/fulfillment/managing-orders/exporting-orders
- Shopify inventory CSV help: https://help.shopify.com/en/manual/products/inventory/setup/inventory-csv
- Shopify reports export help: https://help.shopify.com/en/manual/reports-and-analytics/shopify-reports/report-types/custom-reports/export-reports
- Shopify GraphQL Order object: https://shopify.dev/docs/api/admin-graphql/latest/objects/Order
- Shopify GraphQL LineItem object: https://shopify.dev/docs/api/admin-graphql/latest/objects/lineitem
## Stage 1: Understanding the Dataset

- Reviewed raw Shopify dataset
- Identified potential data quality issues
- Preparing for data cleaning stage
  ## Stage 2: Data Upload to BigQuery

- Uploaded raw Shopify datasets (orders, customers, products,market spend,fx-rates,inventory,orderline,refunds and web sessions) into BigQuery
- Used auto-detect schema for initial ingestion
- Verified data structure using preview and SQL queries
  ## Stage 3: Data Cleaning & Validation (Orders)

### Objective
Transform messy raw Shopify order data into a clean, structured, and analysis-ready table.
### Cleaning Steps Performed
- Converted raw fields into appropriate data types (STRING, FLOAT64, TIMESTAMP)
- Parsed inconsistent date formats into standardized timestamps
- Cleaned monetary values by removing symbols and converting to numeric format
- Standardized text fields:
  - Lowercased emails, statuses, and channels
  - Uppercased country and province values
  - Formatted city names properly
- Cleaned phone numbers using regex (removed unwanted characters)
- Handled missing and empty values using `NULLIF`, `COALESCE`, and `SAFE_CAST`
- Converted boolean-like fields (guest checkout) into TRUE/FALSE
### Data Quality Validation
Performed validation checks using SQL:
- Verified total row count consistency
- Checked for missing critical fields:
  - order_id
  - created_at
  - total_price
  - customer_id
- Ensured cleaned columns have correct formats and no parsing errors
### Result
Created a clean table:
`shopify_clean.orders_clean`
This table is now ready for downstream analysis and joins with other datasets.
### Key Learning
- Raw data types from ingestion cannot be trusted (auto-detect inconsistencies)
- Robust cleaning requires defensive SQL (casting, parsing, null handling)
- Data validation is critical before performing analysis
- ## Stage 3: Cleaning Customers Data
- Cleaned raw customer data in BigQuery
- Standardized names, emails, and phone numbers
- Parsed customer creation timestamps
- Converted marketing opt-in values into booleans
- Cleaned financial fields such as total_spent and orders_count
- Standardized customer address fields using Shopify default address columns
- Created `shopify_clean.customers_clean` for downstream analysis
## Stage 3: Cleaning Products Data
- Cleaned raw product and variant data in BigQuery
- Standardized product titles, handles, SKUs, and status values
- Converted price and cost fields into numeric format
- Normalized shipping and taxability fields into booleans
- Parsed product publish dates into timestamps
- Preserved optional product attributes such as categories, tags, images, and variant options
- Created `shopify_clean.products_clean` for downstream product and margin analysis
- ## Stage 3: Cleaning Inventory Data
- Cleaned raw inventory snapshot data in BigQuery
- Standardized SKU and location fields
- Converted stock quantities into integers
- Converted unit cost into numeric format
- Preserved storage bin values where available
- Created a derived `total_stock_position` field
- Created `shopify_clean.inventory_clean` for stock and availability analysis
  ## Stage 3: Cleaning Order Line Items Data
- Cleaned raw order line item data in BigQuery
- Standardized product and variant identifiers
- Cleaned price, compare-at-price, and discount fields
- Converted quantity and grams into numeric types
- Normalized taxable and requires_shipping flags into booleans
- Created derived revenue fields:
  - `gross_line_revenue`
  - `net_line_revenue`
- Created `shopify_clean.order_line_items_clean` for product-level sales analysis
  ## Stage 3: Cleaning Refunds Data
- Cleaned raw refunds data in BigQuery
- Parsed refund timestamps into standard format
- Standardized refund type, refund reason, and restock type fields
- Converted refund amount into numeric format
- Preserved operational notes for refund context
- Created `shopify_clean.refunds_clean` for downstream net revenue and returns analysis
## Stage 3: Cleaning Channel Performance Data
- Cleaned raw channel performance data in BigQuery
- Standardized channel and device values
- Converted sessions, users, add-to-cart, checkouts, and attributed orders into numeric format
- Converted attributed revenue into numeric format
- Created derived funnel and monetization metrics:
  - `add_to_cart_rate`
  - `checkout_rate`
  - `order_conversion_rate`
  - `revenue_per_order`
  - `revenue_per_session`
- Created `shopify_clean.channel_performance_clean` for marketing and conversion analysis
  ## Stage 3: Cleaning Marketing Spend Data
- Cleaned raw marketing campaign performance data in BigQuery
- Standardized channel, UTM medium, and UTM source values
- Converted spend into numeric format
- Converted clicks, impressions, and sessions into integer fields
- Created derived performance metrics:
  - `ctr`
  - `cpc`
  - `cpm`
  - `cost_per_session`
- Created `shopify_clean.marketing_spend_clean` for paid media and campaign efficiency analysis
## Stage 3: Cleaning FX Rates Data
- Cleaned raw foreign exchange rate data in BigQuery
- Standardized currency codes
- Parsed FX dates into date format
- Converted exchange rate values into numeric format
- Created `shopify_clean.fx_rates_clean` to support currency normalization in downstream revenue analysis
## Stage 4: Building Master Sales Table

- Joined core datasets:
  - orders
  - order line items
  - customers
  - products
  - refunds
- Created a unified analytical table `master_sales`
- Enabled product-level, customer-level, and revenue analysis
- Derived net revenue after refunds at line-item level using refund adjustments
