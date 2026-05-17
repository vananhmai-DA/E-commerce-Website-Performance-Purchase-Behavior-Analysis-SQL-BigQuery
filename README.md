## Project Overview

### Context

This project analyzes e-commerce website data from the Google Analytics Sample Dataset in BigQuery. The dataset contains user sessions, traffic sources, device categories, pageviews, transactions, product interactions, and revenue.

Using SQL, this project transforms raw web analytics data into structured analysis to better understand website performance and customer purchasing behavior.

### Business Problem

An e-commerce business needs to understand which traffic sources, customer behaviors, and product interactions contribute most to revenue. Without this analysis, it is difficult to evaluate marketing effectiveness, identify weak points in the customer journey, and find opportunities to improve conversion and sales.

This project answers the following key business questions:

- How did website traffic, pageviews, and transactions change over time?
- Which traffic sources brought high-quality traffic and revenue?
- How do purchasers and non-purchasers behave differently?
- Which devices and products contributed most to revenue?
- Where do users drop off in the funnel from product view to purchase?

### Objectives

The objective of this project is to use SQL in BigQuery to measure and compare key e-commerce performance indicators.

The analysis includes:

- Traffic, pageview, and transaction trends
- Bounce rate and conversion rate by traffic source
- Revenue by traffic source, week, month, and device category
- Purchaser versus non-purchaser behavior
- Product cross-selling opportunities
- Product funnel performance from view to add-to-cart to purchase
- Weekly and cumulative revenue trends


## 2. Data Source & Dataset Description

### Data Source

This project uses the Google Analytics Sample Dataset available in BigQuery Public Datasets.

The dataset contains Google Analytics session data from the Google Merchandise Store, an e-commerce website that sells Google-branded merchandise. It provides information about website sessions, traffic sources, user behavior, product interactions, transactions, and revenue.

This dataset is suitable for analyzing e-commerce website performance because it includes both user session data and product-level e-commerce data.

### Dataset Information

- Data source: Google Analytics Sample Dataset
- BigQuery project: `bigquery-public-data`
- Dataset: `google_analytics_sample`
- Tables used: `ga_sessions_YYYYMMDD`
- Example table: `ga_sessions_20170801`
- Query pattern used in this project: `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
