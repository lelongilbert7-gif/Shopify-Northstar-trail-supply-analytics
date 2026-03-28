-- ========================================
-- SHOPIFY ANALYSIS QUERIES
-- Project: Northstar Trail Supply
-- ========================================


-- ========================================
-- 1. REVENUE OVERVIEW
-- ========================================
#How much revenue is the business generating?
SELECT
  SUM(net_line_revenue) AS gross_revenue,
  SUM(net_revenue_after_refund) AS net_revenue,
  SUM(net_line_revenue) - SUM(net_revenue_after_refund) AS revenue_lost_to_refunds,
  (SUM(net_line_revenue) - SUM(net_revenue_after_refund))* 100
  / SUM(net_line_revenue) AS refund_rate

FROM `northstar-analysis-project.shopify_clean.master_sales`;


-- ========================================
-- 2. TOP PRODUCTS
-- ========================================
#Which products generate the most revenue?
SELECT
  product_title,
  SUM(net_revenue_after_refund) AS revenue,
  ROUND(SUM(net_revenue_after_refund) * 100
    / SUM(SUM(net_revenue_after_refund)) OVER()) AS revenue_share
FROM `northstar-analysis-project.shopify_clean.master_sales`
GROUP BY product_title
ORDER BY revenue DESC
LIMIT 10;

-- ========================================
-- 3. CUSTOMER VALUE
-- ========================================
#Who are the highest-value customers?
SELECT
  customer_id,
  full_name,
  SUM(net_revenue_after_refund) AS total_spent
FROM `northstar-analysis-project.shopify_clean.master_sales`
GROUP BY customer_id, full_name
ORDER BY total_spent DESC
LIMIT 10;

-- ========================================
-- 4. MONTHLY REVENUE TREND
-- ========================================
#Is the business growing?
SELECT
  DATE_TRUNC(order_date, MONTH) AS month,
  SUM(net_revenue_after_refund) AS revenue
FROM `northstar-analysis-project.shopify_clean.master_sales`
WHERE order_date IS NOT NULL
GROUP BY month
ORDER BY month;


-- ========================================
-- 5. REFUND ANALYSIS
-- ========================================
#How much revenue is lost to refunds?
SELECT
  SUM(net_line_revenue) AS gross_revenue,
  SUM(refund_amount) AS total_refunds,
  SUM(net_line_revenue) - SUM(net_revenue_after_refund) AS calculated_refund_loss
FROM `northstar-analysis-project.shopify_clean.master_sales`;

-- ========================================
-- 6. PROBLEM PRODUCTS (REFUND RATE)
-- ========================================
#Identify problem products
SELECT
  product_title,
  COUNT(*) AS transactions,
  SUM(net_line_revenue) AS revenue,
  SUM(refund_amount) AS total_refunds,

  SAFE_DIVIDE(SUM(refund_amount), SUM(net_line_revenue)) AS refund_rate,

  SAFE_DIVIDE(SUM(refund_amount), SUM(net_revenue_after_refund)) AS refund_pressure

FROM `northstar-analysis-project.shopify_clean.master_sales`

GROUP BY product_title

HAVING SUM(net_line_revenue) > 5000

ORDER BY refund_rate DESC;
-- ========================================
-- 7. PRODUCT PERFORMANCE
-- ========================================
#Which products have high sales but low margin?
SELECT
  product_title,
  SUM(net_revenue_after_refund) AS revenue,
  AVG(gross_margin_value) AS avg_margin
FROM `northstar-analysis-project.shopify_clean.master_sales`
GROUP BY product_title
ORDER BY revenue DESC;
