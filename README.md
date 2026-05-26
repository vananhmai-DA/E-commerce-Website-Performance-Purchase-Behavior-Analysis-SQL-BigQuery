## Table of Contents

- [1. Project Overview](#1-project-overview)
- [2. Data Source & Dataset Description](#2-data-source--dataset-description)
- [3. Main Analysis Process](#3-main-analysis-process)
- [4. Summary & Recommendations](#4-summary--recommendations)

## 1. Project Overview

This project analyzes e-commerce website performance using the Google Analytics Sample Dataset in BigQuery.

The analysis uses SQL to explore website traffic, user behavior, product interactions, conversion funnel, and revenue performance.

### 📌 Business Questions

- How did traffic, pageviews, and transactions change over time?
- Which traffic sources generated better traffic quality and revenue?
- How do purchasers and non-purchasers behave differently?
- Which devices and products contributed most to revenue?
- Where do users drop off before purchase?

### 📌 Project Value

This project turns raw web analytics data into business insights to support marketing, sales, and website performance decisions.

## 2. Data Source & Dataset Description

This project uses the Google Analytics Sample Dataset from BigQuery Public Datasets.

The dataset contains session-level and product-level data from the Google Merchandise Store, an e-commerce website that sells Google-branded merchandise. It includes website visits, traffic sources, user behavior, product interactions, transactions, and revenue.

### 📌 Dataset Information

| Item | Description |
|---|---|
| Data source | Google Analytics Sample Dataset |
| Platform | BigQuery Public Datasets |
| Project ID | `bigquery-public-data` |
| Dataset | `google_analytics_sample` |
| Tables used | `ga_sessions_YYYYMMDD` |
| Example table | `ga_sessions_20170801` |
| Query pattern | `bigquery-public-data.google_analytics_sample.ga_sessions_2017*` |

The dataset is stored in daily session tables, where each table represents website session data for one specific date. In this project, wildcard tables are used to query multiple daily tables from 2017 at the same time.

### 📌 How to Access the Data

1. Log in to your Google Cloud Platform account and create a new project.
2. Open the BigQuery Console and select your project.
3. Click **Add data** in the Explorer panel, then choose **Star a project by name** or search for a public project.
4. In the search bar, enter the project ID: `bigquery-public-data`.
5. Open the dataset: `google_analytics_sample`.
6. Select the daily session tables named `ga_sessions_YYYYMMDD`.
7. For example, open the table `ga_sessions_20170801` to explore its structure and sample data.

In this project, the following wildcard table pattern is used to query multiple daily tables from 2017:

`bigquery-public-data.google_analytics_sample.ga_sessions_2017*`

## 3. Main Analysis Process

### 📌 Query 01: Monthly Website Traffic Overview

#### Business Question

How did total visits, pageviews, and transactions change across January, February, and March 2017?

#### SQL Query

```sql
SELECT
  FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
  SUM(totals.visits) AS visits,
  SUM(totals.pageviews) AS pageviews,
  SUM(totals.transactions) AS transactions,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
GROUP BY 1
ORDER BY 1;
```

#### Query Result

![Monthly Website Traffic Overview](images/Q1_traffic_trends.png)

Insight: March 2017 showed the strongest performance among the three months, with the highest number of visits, pageviews, and transactions. Although February had lower visits and pageviews than January, transactions still increased slightly, suggesting that traffic volume was not the only factor affecting purchase performance.

---

### 📌 Query 02: Bounce Rate by Traffic Source

#### Business Question

Which traffic sources had the highest bounce rate in July 2017?

#### SQL Query

```sql
SELECT
    trafficSource.source AS source,
    SUM(totals.visits) AS total_visits,
    SUM(totals.Bounces) AS total_no_of_bounces,
    (SUM(totals.Bounces)/SUM(totals.visits))* 100.00 AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY source
ORDER BY total_visits DESC;
```

#### Query Result

![Bounce Rate by Traffic Source](images/Q2_bounce_rate_by_source.png)

Insight: Among the displayed traffic sources, `youtube.com` had the highest bounce rate, suggesting that visitors from this source were less likely to continue browsing after landing on the website. Google generated the highest number of visits, but its bounce rate was also relatively high, indicating that high traffic volume does not always mean high traffic quality.

---

### 📌 Query 03: Revenue by Traffic Source Over Time

#### Business Question

How much revenue did each traffic source generate by week and by month in June 2017?

#### SQL Query

```sql
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
```

#### Query Result

![Revenue by Traffic Source Over Time](images/Q3_revenue_by_source_week_month.png)

Insight: In June 2017, direct traffic generated the highest monthly revenue by a large margin, while Google was also an important revenue source. At the weekly level, revenue varied across traffic sources, showing that traffic source performance should be reviewed over time instead of only looking at the total monthly result.

---

### 📌 Query 04: Conversion Rate by Traffic Source

#### Business Question

Which traffic sources had the highest conversion rate in 2017?

#### SQL Query

```sql
SELECT
  trafficSource.source,
  SUM(totals.visits) visits,
  SUM(totals.transactions) AS transactions,
  ROUND((SUM(totals.transactions)/ SUM(totals.visits)),2) * 100.00 AS conversion_rate
FROM  `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
GROUP BY source
HAVING SUM(totals.transactions) >= 50
ORDER BY conversion_rate DESC;
```

#### Query Result

![Conversion Rate by Traffic Source](images/Q4_conversion_rate_by_source.png)

Insight: DFA had the highest conversion rate at 3%, followed by direct traffic at 2% and Google at 1%. Although direct and Google brought much higher visit volume, DFA converted more efficiently, suggesting that traffic quality should be evaluated together with traffic volume.

---

### 📌 Query 05: Average Pageviews by Purchaser Type

#### Business Question

How did average pageviews differ between purchasers and non-purchasers in June and July 2017?

#### SQL Query

```sql
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
```

#### Query Result

![Average Pageviews by Purchaser Type](images/Q5_avg_pageviews_purchaser_vs_non_purchaser.png)

Insight: Non-purchasers had higher average pageviews than purchasers in both June and July 2017. This may suggest that non-purchasing users spent more time browsing but did not convert, indicating a possible gap between product exploration and purchase decision.

---

### 📌 Query 06: Average Transactions per Purchasing User

#### Business Question

How many transactions did each purchasing user make on average in July 2017?

#### SQL Query

```sql
SELECT
    FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
    SUM(totals.transactions)/COUNT(DISTINCT fullvisitorid) AS Avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,UNNEST (hits) hits
    ,UNNEST (product) product
WHERE  totals.transactions>=1
AND product.productRevenue IS NOT NULL
GROUP BY month;
```

#### Query Result

![Average Transactions per Purchasing User](images/Q6_avg_transactions_per_user.png)

Insight: In July 2017, purchasing users made an average of about 4.16 transactions. This suggests that users who converted were not limited to one-time purchases and may have shown repeat purchasing behavior within the period.

---

### 📌 Query 07: Revenue Contribution by Device Category

#### Business Question

Which device categories contributed the most to total revenue?

#### SQL Query

```sql
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
```

#### Query Result

![Revenue Contribution by Device Category](images/Q7_revenue_by_device.png)

Insight: Desktop contributed the majority of total revenue, accounting for 96.14%, while mobile and tablet contributed only a small share. This suggests that desktop was the main revenue-driving device category, and mobile performance may need further review despite its role in e-commerce traffic.

---

### 📌 Query 08: Product Cross-Sell Analysis

#### Business Question

Which other products were commonly purchased by customers who bought "YouTube Men's Vintage Henley" in July 2017?

#### SQL Query

```sql
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
```

#### Query Result

![Product Cross-Sell Analysis](images/Q8_cross_sell_products.png)

Insight: Google Sunglasses was the most commonly purchased product together with “YouTube Men's Vintage Henley”, with 20 units ordered. This suggests a possible cross-selling opportunity by recommending frequently co-purchased products to customers who view or buy the Henley product.

---

### 📌 Query 09: Product Funnel Analysis

#### Business Question

How did users move through the product funnel from product view to add-to-cart to purchase in January, February, and March 2017?

#### SQL Query

```sql
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
```

#### Query Result

![Product Funnel Analysis](images/Q9_product_funnel.png)

Insight: Although product views fluctuated across the three months, both add-to-cart rate and purchase rate improved steadily from January to March 2017. March recorded the strongest funnel performance, with an add-to-cart rate of 37.29% and a purchase rate of 12.64%, suggesting improved conversion efficiency from product view to purchase.

---

### 📌 Query 10: Monthly and Cumulative Revenue

#### Business Question

How did monthly revenue and cumulative revenue change from April to June 2017?

#### SQL Query

```sql
WITH raw_data AS ( 
  SELECT
    FORMAT_DATE("%Y-%m", PARSE_DATE("%Y%m%d", date)) AS month,
    SUM(p.productRevenue) / 1000000 AS monthly_revenue
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS p
  WHERE _table_suffix BETWEEN '0401' AND '0630'
    AND p.productRevenue IS NOT NULL
  GROUP BY month
),

final AS (
  SELECT
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
      ORDER BY month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue,
    SUM(monthly_revenue) OVER () AS total_revenue
  FROM raw_data
)

SELECT
  month,
  monthly_revenue,
  cumulative_revenue,
  ROUND(monthly_revenue / total_revenue * 100, 2) AS monthly_revenue_pct,
  ROUND(cumulative_revenue / total_revenue * 100, 2) AS cumulative_revenue_pct
FROM final
ORDER BY month;
```

#### Query Result

![Weekly and Cumulative Revenue](images/Q10_monthly_cumulative_revenue.png)

Insight: Revenue decreased steadily from April to June 2017. April generated the highest revenue, contributing 45.75% of total revenue in the three-month period. By the end of May, cumulative revenue had already reached 73.71%, while June contributed the remaining 26.29%. This suggests that revenue performance was strongest at the beginning of Q2 and weakened slightly toward the end of the quarter.

## 4. Summary & Recommendations

### Key Insights

- March 2017 showed the strongest overall performance, with the highest visits, pageviews, transactions, and purchase rate.
- High traffic did not always lead to high-quality performance. Google generated high visits but also had a relatively high bounce rate, while DFA achieved the highest conversion rate.
- Revenue performance weakened during Q2. April contributed the largest share of revenue from April to June, accounting for 45.75% of the three-month total.
- Direct traffic generated the highest revenue, while desktop users contributed most of the total revenue.
- Non-purchasers viewed more pages than purchasers, suggesting that some users were interested in products but did not complete the purchase.
- Customers who bought “YouTube Men's Vintage Henley” also commonly purchased Google Sunglasses, showing a potential cross-selling opportunity.

### Recommendations

- Evaluate traffic sources based on conversion rate, bounce rate, and revenue, not only visit volume.
- Improve landing pages and campaign quality for high-traffic sources with high bounce rates.
- Investigate the purchase journey to understand why users browse many pages but do not complete transactions.
- Review the mobile and tablet experience because desktop currently contributes most revenue.
- Use product recommendation strategies to increase cross-selling and average order value.
- Analyze the reasons behind the revenue decline from April to June and identify whether it came from traffic, conversion rate, or product performance.
