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
