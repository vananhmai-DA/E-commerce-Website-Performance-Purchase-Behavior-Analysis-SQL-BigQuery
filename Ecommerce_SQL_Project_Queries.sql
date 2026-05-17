Query 01: Monthly Website Traffic Overview
Business question:  How did total visits, pageviews, and transactions change across January, February, and March 2017?

SELECT
  FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
  SUM(totals.visits) AS visits,
  SUM(totals.pageviews) AS pageviews,
  SUM(totals.transactions) AS transactions,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
GROUP BY 1
ORDER BY 1;

=====================================================
Query 02: Bounce Rate by Traffic Source
Business question: Which traffic sources had the highest bounce rate in July 2017?
Metric definition: Bounce rate = total bounces / total visits

SELECT
    trafficSource.source AS source,
    SUM(totals.visits) AS total_visits,
    SUM(totals.Bounces) AS total_no_of_bounces,
    (SUM(totals.Bounces)/SUM(totals.visits))* 100.00 AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY source
ORDER BY total_visits DESC;

=====================================================
Query 03: Revenue by Traffic Source Over Time
Business question: How much revenue did each traffic source generate by week and by month in June 2017?

WITH 
month_data AS(
  SELECT
    "Month" AS time_type,
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    trafficSource.source AS source,
    SUM(p.productRevenue)/1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    UNNEST(hits) hits,
    UNNEST(product) p
  WHERE p.productRevenue IS NOT NULL
  GROUP BY 1,2,3
  ORDER BY revenue DESC
),
week_data AS(
  SELECT
    "Week" AS time_type,
    FORMAT_DATE("%Y%W", PARSE_DATE("%Y%m%d", date)) AS week,
    trafficSource.source AS source,
    SUM(p.productRevenue)/1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    UNNEST(hits) hits,
    UNNEST(product) p
  WHERE p.productRevenue IS NOT NULL
  GROUP BY 1,2,3
  ORDER BY revenue DESC
)

SELECT time_type, month, source, revenue  FROM month_data
UNION ALL
SELECT time_type, week, source, revenue  FROM week_data
ORDER BY revenue DESC;

=====================================================
Query 04: Conversion Rate by Traffic Source
Business question: Which traffic sources had the highest conversion rate in 2017?
Metric definition: Conversion rate = total transactions / total visits

SELECT
  trafficSource.source,
  SUM(totals.visits) visits,
  SUM(totals.transactions) AS transactions,
  ROUND((SUM(totals.transactions)/ SUM(totals.visits)),2) * 100.00 AS conversion_rate
FROM  `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
GROUP BY source
HAVING SUM(totals.transactions) >= 50
ORDER BY conversion_rate DESC;

=====================================================
Query 05: Average Pageviews by Purchaser Type
Business question:How did average pageviews differ between purchasers and non-purchasers in June and July 2017?

WITH 
purchaser_data AS(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
      (SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid)) AS avg_pageviews_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions>=1
  AND product.productRevenue IS NOT NULL
  GROUP BY month
),
non_purchaser_data AS(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
      SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid) AS avg_pageviews_non_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,UNNEST(hits) hits
      ,UNNEST(product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions IS NULL
  AND product.productRevenue IS NULL
  GROUP BY month
)

SELECT
    pd.*,
    avg_pageviews_non_purchase
FROM purchaser_data pd
FULL JOIN non_purchaser_data USING(month)
ORDER BY pd.month;

=====================================================
Query 06: Average Transactions per Purchasing User
Business question: How many transactions did each purchasing user make on average in July 2017?

SELECT
    FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
    SUM(totals.transactions)/COUNT(DISTINCT fullvisitorid) AS Avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,UNNEST (hits) hits
    ,UNNEST (product) product
WHERE  totals.transactions>=1
AND product.productRevenue IS NOT NULL
GROUP BY month;

=====================================================
Query 07: Revenue Contribution by Device Category
Business question: Which device categories contributed the most to total revenue?
Metric definition: Revenue contribution = device revenue / total revenue

WITH 
raw_data AS (
  SELECT
    device.deviceCategory AS device
    ,SUM(productRevenue)/1000000 AS revenue_by_device
    ,(SELECT SUM(productRevenue)/1000000 AS total_revenue
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
            ,UNNEST(hits) hits
            ,UNNEST(product) product
      WHERE totals.transactions>=1
        AND product.productRevenue IS NOT NULL) AS total_revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
        ,UNNEST(hits) hits
        ,UNNEST(product) product
  WHERE totals.transactions>=1
    AND product.productRevenue IS NOT NULL
  GROUP BY device
  ORDER BY revenue_by_device DESC)

SELECT
  device
  ,revenue_by_device
  ,total_revenue
  ,ROUND(100.00*(revenue_by_device/total_revenue),2) AS ratio
FROM raw_data;

=====================================================
Query 08: Product Cross-Sell Analysis
Business question: Which other products were commonly purchased by customers who bought "YouTube Men's Vintage Henley" in July 2017?

WITH 
buyer_list AS(
    SELECT
        DISTINCT fullVisitorId  
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    , UNNEST(hits) AS hits
    , UNNEST(hits.product) AS product
    WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
    AND totals.transactions>=1
    AND product.productRevenue IS NOT NULL
)
SELECT
  product.v2ProductName AS other_purchased_products,
  SUM(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
, UNNEST(hits) AS hits
, UNNEST(hits.product) AS product
JOIN buyer_list USING(fullVisitorId)
WHERE product.v2ProductName != "YouTube Men's Vintage Henley"
 AND product.productRevenue IS NOT NULL
 AND totals.transactions>=1
GROUP BY other_purchased_products
ORDER BY quantity DESC;

=====================================================
Query 09: Product Funnel Analysis
Business question: How did users move through the product funnel from product view to add-to-cart to purchase in January, February, and March 2017?
Metric definitions:
    Add-to-cart rate = number of products added to cart / number of product views
    Purchase rate = number of products purchased / number of product views

WITH
product_view AS(
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    COUNT(product.productSKU) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  GROUP BY 1
),
add_to_cart AS(
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    COUNT(product.productSKU) AS num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  GROUP BY 1
),
purchase AS(
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    COUNT(product.productSKU) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  AND product.productRevenue IS NOT NULL   
  GROUP BY 1
)
SELECT
    pv.*,
    num_addtocart,
    num_purchase,
    ROUND(num_addtocart*100/num_product_view,2) AS add_to_cart_rate,
    ROUND(num_purchase*100/num_product_view,2) AS purchase_rate
FROM product_view pv
LEFT JOIN add_to_cart a ON pv.month = a.month
LEFT JOIN purchase p ON pv.month = p.month
ORDER BY pv.month;

=====================================================
Query 10: Weekly and Cumulative Revenue
Business question: How did weekly revenue and cumulative revenue change from May to July 2017?

WITH 
raw_data AS ( 
  SELECT
    FORMAT_DATE("%Y-%W", PARSE_DATE("%Y%m%d", date)) AS week
    ,SUM(p.productRevenue)/1000000 AS weekly_revenue
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST(hits) hits,
      UNNEST(product) p
  WHERE _table_suffix BETWEEN '0501' AND '0731'
  AND p.productRevenue IS NOT NULL
  GROUP BY week
  ORDER BY week
)
SELECT
  week
  ,weekly_revenue
  ,SUM(weekly_revenue) OVER(ORDER BY week
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) As cumulative_revenue
FROM raw_data
ORDER BY week;
