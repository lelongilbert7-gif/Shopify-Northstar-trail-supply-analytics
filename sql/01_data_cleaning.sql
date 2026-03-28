-- ========================================
-- DATA CLEANING
-- ========================================

-- 1. CLEAN ORDERS
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.orders_clean` AS

SELECT
  CAST(order_id_raw AS STRING) AS order_id,
  TRIM(CAST(order_name_raw AS STRING)) AS order_name,

  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', CAST(created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M', CAST(created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S UTC', CAST(created_at_raw AS STRING))
  ) AS created_at,

  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', CAST(processed_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(processed_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M', CAST(processed_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S UTC', CAST(processed_at_raw AS STRING))
  ) AS processed_at,

  CAST(customer_id_raw AS STRING) AS customer_id,
  LOWER(TRIM(CAST(email_raw AS STRING))) AS email,

  REGEXP_REPLACE(TRIM(COALESCE(CAST(phone_raw AS STRING), '')), r'[^0-9+]', '') AS phone_clean,

  LOWER(TRIM(CAST(financial_status_raw AS STRING))) AS financial_status,
  LOWER(TRIM(CAST(fulfillment_status_raw AS STRING))) AS fulfillment_status,
  UPPER(TRIM(CAST(currency_raw AS STRING))) AS currency,

  SAFE_CAST(REGEXP_REPLACE(CAST(subtotal_price_raw AS STRING), r'[^0-9.\-]', '') AS FLOAT64) AS subtotal_price,
  SAFE_CAST(REGEXP_REPLACE(CAST(shipping_price_raw AS STRING), r'[^0-9.\-]', '') AS FLOAT64) AS shipping_price,
  SAFE_CAST(REGEXP_REPLACE(CAST(tax_price_raw AS STRING), r'[^0-9.\-]', '') AS FLOAT64) AS tax_price,
  SAFE_CAST(REGEXP_REPLACE(CAST(total_discounts_raw AS STRING), r'[^0-9.\-]', '') AS FLOAT64) AS total_discounts,
  SAFE_CAST(REGEXP_REPLACE(CAST(total_price_raw AS STRING), r'[^0-9.\-]', '') AS FLOAT64) AS total_price,

  NULLIF(TRIM(CAST(discount_code_raw AS STRING)), '') AS discount_code,
  NULLIF(TRIM(CAST(shipping_method_raw AS STRING)), '') AS shipping_method,
  LOWER(TRIM(CAST(gateway_raw AS STRING))) AS gateway,
  LOWER(TRIM(CAST(source_channel_raw AS STRING))) AS source_channel,
  NULLIF(TRIM(CAST(landing_site_raw AS STRING)), '') AS landing_site,
  NULLIF(TRIM(CAST(referring_site_raw AS STRING)), '') AS referring_site,

  UPPER(TRIM(CAST(billing_country_raw AS STRING))) AS billing_country,
  UPPER(TRIM(CAST(shipping_country_raw AS STRING))) AS shipping_country,
  UPPER(TRIM(CAST(shipping_province_raw AS STRING))) AS shipping_province,
  INITCAP(TRIM(CAST(shipping_city_raw AS STRING))) AS shipping_city,
  CAST(shipping_zip_raw AS STRING) AS shipping_zip,

  CASE
    WHEN UPPER(TRIM(CAST(is_guest_checkout_raw AS STRING))) = 'TRUE' THEN TRUE
    WHEN UPPER(TRIM(CAST(is_guest_checkout_raw AS STRING))) = 'FALSE' THEN FALSE
    ELSE NULL
  END AS is_guest_checkout,

  NULLIF(LOWER(TRIM(CAST(cancellation_reason_raw AS STRING))), '') AS cancellation_reason,

  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', CAST(cancelled_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(cancelled_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M', CAST(cancelled_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S UTC', CAST(cancelled_at_raw AS STRING))
  ) AS cancelled_at,

  NULLIF(TRIM(CAST(tags_raw AS STRING)), '') AS tags,
  NULLIF(TRIM(CAST(note_raw AS STRING)), '') AS note

FROM `northstar-analysis-project.shopify_raw.Orders-csv`
WHERE order_id_raw IS NOT NULL
-- 2. CLEAN CUSTOMERS
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.customers_clean` AS

SELECT
  CAST(customer_id_raw AS STRING) AS customer_id,

  INITCAP(TRIM(CAST(first_name_raw AS STRING))) AS first_name,
  INITCAP(TRIM(CAST(last_name_raw AS STRING))) AS last_name,

  CONCAT(
    INITCAP(TRIM(CAST(first_name_raw AS STRING))),
    ' ',
    INITCAP(TRIM(CAST(last_name_raw AS STRING)))
  ) AS full_name,

  LOWER(TRIM(CAST(email_raw AS STRING))) AS email,

  REGEXP_REPLACE(
    TRIM(COALESCE(CAST(phone_raw AS STRING), '')),
    r'[^0-9+]',
    ''
  ) AS phone_clean,

  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', CAST(created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M', CAST(created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S UTC', CAST(created_at_raw AS STRING))
  ) AS created_at,

  CASE
    WHEN LOWER(TRIM(CAST(accepts_marketing_raw AS STRING))) IN ('yes', 'true', '1') THEN TRUE
    WHEN LOWER(TRIM(CAST(accepts_marketing_raw AS STRING))) IN ('no', 'false', '0') THEN FALSE
    ELSE NULL
  END AS accepts_marketing,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(total_spent_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS total_spent,

  SAFE_CAST(CAST(orders_count_raw AS STRING) AS INT64) AS orders_count,

  INITCAP(TRIM(CAST(default_address_city_raw AS STRING))) AS city,
  UPPER(TRIM(CAST(default_address_province_raw AS STRING))) AS province,
  UPPER(TRIM(CAST(default_address_country_raw AS STRING))) AS country,
  CAST(default_address_zip_raw AS STRING) AS zip,

  NULLIF(TRIM(CAST(tags_raw AS STRING)), '') AS tags,
  NULLIF(TRIM(CAST(note_raw AS STRING)), '') AS note

FROM `northstar-analysis-project.shopify_raw.Customers-raw`
WHERE customer_id_raw IS NOT NULL;
-- 3. CLEAN PRODUCTS
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.products_clean` AS

SELECT
  CAST(product_id AS STRING) AS product_id,
  CAST(variant_id AS STRING) AS variant_id,

  LOWER(TRIM(CAST(handle_raw AS STRING))) AS handle,

  TRIM(CAST(title_raw AS STRING)) AS title,

  NULLIF(TRIM(CAST(body_html_raw AS STRING)), '') AS body_html,

  INITCAP(TRIM(CAST(vendor_raw AS STRING))) AS vendor,

  NULLIF(TRIM(CAST(product_category_raw AS STRING)), '') AS product_category,
  NULLIF(TRIM(CAST(type_raw AS STRING)), '') AS product_type,
  NULLIF(TRIM(CAST(tags_raw AS STRING)), '') AS tags,

  NULLIF(TRIM(CAST(option1_name_raw AS STRING)), '') AS option1_name,
  NULLIF(TRIM(CAST(option1_value_raw AS STRING)), '') AS option1_value,
  NULLIF(TRIM(CAST(option2_name_raw AS STRING)), '') AS option2_name,
  NULLIF(TRIM(CAST(option2_value_raw AS STRING)), '') AS option2_value,

  UPPER(TRIM(CAST(variant_sku_raw AS STRING))) AS variant_sku,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(variant_price_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS variant_price,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(variant_compare_at_price_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS compare_at_price,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(cost_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS cost,

  CASE
    WHEN LOWER(TRIM(CAST(variant_requires_shipping_raw AS STRING))) IN ('true', 'yes', '1') THEN TRUE
    WHEN LOWER(TRIM(CAST(variant_requires_shipping_raw AS STRING))) IN ('false', 'no', '0') THEN FALSE
    ELSE NULL
  END AS requires_shipping,

  CASE
    WHEN LOWER(TRIM(CAST(variant_taxable_raw AS STRING))) IN ('true', 'yes', '1') THEN TRUE
    WHEN LOWER(TRIM(CAST(variant_taxable_raw AS STRING))) IN ('false', 'no', '0') THEN FALSE
    ELSE NULL
  END AS taxable,

  LOWER(TRIM(CAST(status_raw AS STRING))) AS status,

  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', CAST(published_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d', CAST(published_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(published_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M', CAST(published_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S UTC', CAST(published_at_raw AS STRING))
  ) AS published_at,

  NULLIF(TRIM(CAST(image_src_raw AS STRING)), '') AS image_src,

  CASE
    WHEN SAFE_CAST(
      REGEXP_REPLACE(CAST(variant_price_raw AS STRING), r'[^0-9.\-]', '')
      AS FLOAT64
    ) IS NOT NULL
    AND SAFE_CAST(
      REGEXP_REPLACE(CAST(cost_raw AS STRING), r'[^0-9.\-]', '')
      AS FLOAT64
    ) IS NOT NULL
    THEN
      SAFE_CAST(
        REGEXP_REPLACE(CAST(variant_price_raw AS STRING), r'[^0-9.\-]', '')
        AS FLOAT64
      )
      -
      SAFE_CAST(
        REGEXP_REPLACE(CAST(cost_raw AS STRING), r'[^0-9.\-]', '')
        AS FLOAT64
      )
    ELSE NULL
  END AS gross_margin_value

FROM `northstar-analysis-project.shopify_raw.products-raw`
WHERE product_id IS NOT NULL;

-- 4. CLEAN INVENTORY
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.inventory_clean` AS

SELECT
  COALESCE(
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(snapshot_date_raw AS STRING)),
    SAFE.PARSE_DATE('%m/%d/%Y', CAST(snapshot_date_raw AS STRING)),
    SAFE.PARSE_DATE('%Y/%m/%d', CAST(snapshot_date_raw AS STRING))
  ) AS snapshot_date,

  UPPER(TRIM(CAST(sku_raw AS STRING))) AS sku,

  INITCAP(TRIM(CAST(location_name_raw AS STRING))) AS location_name,

  SAFE_CAST(CAST(available_raw AS STRING) AS INT64) AS available,
  SAFE_CAST(CAST(committed_raw AS STRING) AS INT64) AS committed,
  SAFE_CAST(CAST(incoming_raw AS STRING) AS INT64) AS incoming,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(unit_cost_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS unit_cost,

  NULLIF(UPPER(TRIM(CAST(bin_raw AS STRING))), '') AS bin,

  COALESCE(SAFE_CAST(CAST(available_raw AS STRING) AS INT64), 0)
  + COALESCE(SAFE_CAST(CAST(committed_raw AS STRING) AS INT64), 0)
  + COALESCE(SAFE_CAST(CAST(incoming_raw AS STRING) AS INT64), 0) AS total_stock_position

FROM `northstar-analysis-project.shopify_raw.inventory-raw`
WHERE sku_raw IS NOT NULL
-- 5. CLEAN ORDER LINE
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.order_line_items_clean` AS

SELECT
  CAST(line_item_id_raw AS STRING) AS line_item_id,
  CAST(order_id_raw AS STRING) AS order_id,
  CAST(product_id_raw AS STRING) AS product_id,
  CAST(variant_id_raw AS STRING) AS variant_id,

  UPPER(TRIM(CAST(sku_raw AS STRING))) AS sku,

  TRIM(CAST(product_title_raw AS STRING)) AS product_title,
  NULLIF(TRIM(CAST(variant_title_raw AS STRING)), '') AS variant_title,
  INITCAP(TRIM(CAST(vendor_raw AS STRING))) AS vendor,
  NULLIF(TRIM(CAST(product_type_raw AS STRING)), '') AS product_type,

  SAFE_CAST(CAST(quantity_raw AS STRING) AS INT64) AS quantity,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(price_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS unit_price,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(compare_at_price_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS compare_at_price,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(line_discount_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS line_discount,

  CASE
    WHEN LOWER(TRIM(CAST(taxable_raw AS STRING))) IN ('true', 'yes', '1') THEN TRUE
    WHEN LOWER(TRIM(CAST(taxable_raw AS STRING))) IN ('false', 'no', '0') THEN FALSE
    ELSE NULL
  END AS taxable,

  CASE
    WHEN LOWER(TRIM(CAST(requires_shipping_raw AS STRING))) IN ('true', 'yes', '1') THEN TRUE
    WHEN LOWER(TRIM(CAST(requires_shipping_raw AS STRING))) IN ('false', 'no', '0') THEN FALSE
    ELSE NULL
  END AS requires_shipping,

  LOWER(TRIM(CAST(fulfillment_service_raw AS STRING))) AS fulfillment_service,

  SAFE_CAST(CAST(grams_raw AS STRING) AS FLOAT64) AS grams,

  NULLIF(TRIM(CAST(properties_raw AS STRING)), '') AS properties,

  SAFE_CAST(CAST(quantity_raw AS STRING) AS INT64)
  * SAFE_CAST(
      REGEXP_REPLACE(CAST(price_raw AS STRING), r'[^0-9.\-]', '')
      AS FLOAT64
    ) AS gross_line_revenue,

  (
    SAFE_CAST(CAST(quantity_raw AS STRING) AS INT64)
    * SAFE_CAST(
        REGEXP_REPLACE(CAST(price_raw AS STRING), r'[^0-9.\-]', '')
        AS FLOAT64
      )
  )
  - COALESCE(
      SAFE_CAST(
        REGEXP_REPLACE(CAST(line_discount_raw AS STRING), r'[^0-9.\-]', '')
        AS FLOAT64
      ),
      0
    ) AS net_line_revenue

FROM `northstar-analysis-project.shopify_raw.order-line-raw`
WHERE line_item_id_raw IS NOT NULL
-- 6. CLEAN REFUNDS
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.refunds_clean` AS

SELECT
  CAST(refund_id_raw AS STRING) AS refund_id,
  CAST(order_id_raw AS STRING) AS order_id,

  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', CAST(refund_created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(refund_created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M', CAST(refund_created_at_raw AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S UTC', CAST(refund_created_at_raw AS STRING))
  ) AS refund_created_at,

  LOWER(TRIM(CAST(refund_type_raw AS STRING))) AS refund_type,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(refund_amount_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS refund_amount,

  LOWER(TRIM(CAST(refund_reason_raw AS STRING))) AS refund_reason,

  NULLIF(LOWER(TRIM(CAST(restock_type_raw AS STRING))), '') AS restock_type,
  NULLIF(TRIM(CAST(notes_raw AS STRING)), '') AS notes

FROM `northstar-analysis-project.shopify_raw.refunds-raw`
WHERE refund_id_raw IS NOT NULL
-- 7. CLEAN CHANNELS
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.channel_performance_clean` AS

SELECT
  COALESCE(
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(date_raw AS STRING)),
    SAFE.PARSE_DATE('%m/%d/%Y', CAST(date_raw AS STRING)),
    SAFE.PARSE_DATE('%Y/%m/%d', CAST(date_raw AS STRING))
  ) AS activity_date,

  LOWER(TRIM(CAST(channel_raw AS STRING))) AS channel,
  LOWER(TRIM(CAST(device_raw AS STRING))) AS device,

  SAFE_CAST(CAST(sessions_raw AS STRING) AS INT64) AS sessions,
  SAFE_CAST(CAST(users_raw AS STRING) AS INT64) AS users,
  SAFE_CAST(CAST(add_to_cart_raw AS STRING) AS INT64) AS add_to_cart,
  SAFE_CAST(CAST(checkouts_raw AS STRING) AS INT64) AS checkouts,
  SAFE_CAST(CAST(orders_attributed_raw AS STRING) AS INT64) AS orders_attributed,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(revenue_attributed_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS revenue_attributed,

  CASE
    WHEN SAFE_CAST(CAST(sessions_raw AS STRING) AS INT64) > 0
    THEN SAFE_CAST(CAST(add_to_cart_raw AS STRING) AS FLOAT64)
         / SAFE_CAST(CAST(sessions_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS add_to_cart_rate,

  CASE
    WHEN SAFE_CAST(CAST(sessions_raw AS STRING) AS INT64) > 0
    THEN SAFE_CAST(CAST(checkouts_raw AS STRING) AS FLOAT64)
         / SAFE_CAST(CAST(sessions_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS checkout_rate,

  CASE
    WHEN SAFE_CAST(CAST(sessions_raw AS STRING) AS INT64) > 0
    THEN SAFE_CAST(CAST(orders_attributed_raw AS STRING) AS FLOAT64)
         / SAFE_CAST(CAST(sessions_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS order_conversion_rate,

  CASE
    WHEN SAFE_CAST(CAST(orders_attributed_raw AS STRING) AS INT64) > 0
    THEN SAFE_CAST(
           REGEXP_REPLACE(CAST(revenue_attributed_raw AS STRING), r'[^0-9.\-]', '')
           AS FLOAT64
         )
         / SAFE_CAST(CAST(orders_attributed_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS revenue_per_order,

  CASE
    WHEN SAFE_CAST(CAST(sessions_raw AS STRING) AS INT64) > 0
    THEN SAFE_CAST(
           REGEXP_REPLACE(CAST(revenue_attributed_raw AS STRING), r'[^0-9.\-]', '')
           AS FLOAT64
         )
         / SAFE_CAST(CAST(sessions_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS revenue_per_session

FROM `northstar-analysis-project.shopify_raw.web-sessions-raw`
WHERE date_raw IS NOT NULL
-- 8. CLEAN MARKETING SPEND
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.marketing_spend_clean` AS

SELECT
  COALESCE(
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(date_raw AS STRING)),
    SAFE.PARSE_DATE('%m/%d/%Y', CAST(date_raw AS STRING)),
    SAFE.PARSE_DATE('%Y/%m/%d', CAST(date_raw AS STRING))
  ) AS activity_date,

  LOWER(TRIM(CAST(channel_raw AS STRING))) AS channel,
  NULLIF(TRIM(CAST(campaign_name_raw AS STRING)), '') AS campaign_name,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(spend_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS spend,

  SAFE_CAST(CAST(clicks_raw AS STRING) AS INT64) AS clicks,
  SAFE_CAST(CAST(impressions_raw AS STRING) AS INT64) AS impressions,
  SAFE_CAST(CAST(sessions_raw AS STRING) AS INT64) AS sessions,

  LOWER(TRIM(CAST(utm_medium_raw AS STRING))) AS utm_medium,
  LOWER(TRIM(CAST(utm_source_raw AS STRING))) AS utm_source,

  CASE
    WHEN SAFE_CAST(CAST(impressions_raw AS STRING) AS FLOAT64) > 0
    THEN SAFE_CAST(CAST(clicks_raw AS STRING) AS FLOAT64)
         / SAFE_CAST(CAST(impressions_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS ctr,

  CASE
    WHEN SAFE_CAST(CAST(clicks_raw AS STRING) AS FLOAT64) > 0
    THEN SAFE_CAST(
           REGEXP_REPLACE(CAST(spend_raw AS STRING), r'[^0-9.\-]', '')
           AS FLOAT64
         )
         / SAFE_CAST(CAST(clicks_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS cpc,

  CASE
    WHEN SAFE_CAST(CAST(impressions_raw AS STRING) AS FLOAT64) > 0
    THEN SAFE_CAST(
           REGEXP_REPLACE(CAST(spend_raw AS STRING), r'[^0-9.\-]', '')
           AS FLOAT64
         ) * 1000
         / SAFE_CAST(CAST(impressions_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS cpm,

  CASE
    WHEN SAFE_CAST(CAST(sessions_raw AS STRING) AS FLOAT64) > 0
    THEN SAFE_CAST(
           REGEXP_REPLACE(CAST(spend_raw AS STRING), r'[^0-9.\-]', '')
           AS FLOAT64
         )
         / SAFE_CAST(CAST(sessions_raw AS STRING) AS FLOAT64)
    ELSE NULL
  END AS cost_per_session

FROM `northstar-analysis-project.shopify_raw.Market-spend-raw`
WHERE date_raw IS NOT NULL
-- 9. CLEAN FX RATES
CREATE OR REPLACE TABLE `northstar-analysis-project.shopify_clean.fx_rates_clean` AS

SELECT
  COALESCE(
    SAFE.PARSE_DATE('%Y-%m-%d', CAST(date_raw AS STRING)),
    SAFE.PARSE_DATE('%m/%d/%Y', CAST(date_raw AS STRING)),
    SAFE.PARSE_DATE('%Y/%m/%d', CAST(date_raw AS STRING))
  ) AS fx_date,

  UPPER(TRIM(CAST(currency_raw AS STRING))) AS currency,

  SAFE_CAST(
    REGEXP_REPLACE(CAST(fx_to_usd_raw AS STRING), r'[^0-9.\-]', '')
    AS FLOAT64
  ) AS fx_to_usd

FROM `northstar-analysis-project.shopify_raw.discounts-raw`
WHERE date_raw IS NOT NULL
  AND currency_raw IS NOT NULL
