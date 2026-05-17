## 1. Project Overview

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

The dataset is organized as daily session tables. Each table represents website session data for one specific date.

For example:

- `ga_sessions_20170801` contains session data for August 1, 2017.
- `ga_sessions_20170601` contains session data for June 1, 2017.

In this project, wildcard tables such as `ga_sessions_2017*` are used to query multiple daily tables from 2017 at the same time.

### How to Access the Data

1. Log in to your Google Cloud Platform account.
2. Open the BigQuery Console.
3. In the Explorer panel, click **Add data**.
4. Choose **Star a project by name** or search for a public project.
5. Enter the project ID: `bigquery-public-data`.
6. Open the dataset: `google_analytics_sample`.
7. Select the daily session tables named `ga_sessions_YYYYMMDD`.
8. For example, open `ga_sessions_20170801` to explore the table schema and sample data.

In this project, the following wildcard table pattern is used to query multiple daily tables from 2017:

```sql
`bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
```

### Dataset Description

The dataset contains e-commerce website session data from the Google Analytics Sample Dataset in BigQuery. It includes information about visitors, session dates, traffic sources, device categories, pageviews, bounces, transactions, product interactions, product quantities, and product revenue.

The dataset contains both session-level data and nested e-commerce data. Session-level fields describe the overall visit, such as visitor ID, date, traffic source, device type, pageviews, bounces, and transactions. Nested fields provide more detailed information about user actions within each session, including product views, add-to-cart actions, purchases, and product-level revenue.

In BigQuery, fields such as `hits`, `hits.eCommerceAction`, and `hits.product` are nested or repeated fields. Therefore, `UNNEST()` is used in this project to access hit-level and product-level data for deeper e-commerce analysis.

### Key Fields Used

| Field Name | Description |
|---|---|
| `fullVisitorId` | Unique visitor ID |
| `date` | Session date in `YYYYMMDD` format |
| `totals.visits` | Number of sessions |
| `totals.pageviews` | Total number of pageviews in a session |
| `totals.bounces` | Bounce indicator. A bounced session has the value `1`; otherwise, the value is `null` |
| `totals.transactions` | Total number of e-commerce transactions in a session |
| `trafficSource.source` | Source of website traffic, such as search engine, referral website, or campaign source |
| `device.deviceCategory` | Device category, such as desktop, mobile, or tablet |
| `hits` | Nested and repeated field that contains hit-level data within a session |
| `hits.eCommerceAction.action_type` | E-commerce action type, such as product view, add-to-cart, checkout, or purchase |
| `hits.product.productQuantity` | Quantity of products purchased |
| `hits.product.productRevenue` | Product revenue, stored in micro-units |
| `hits.product.productSKU` | Product SKU |
| `hits.product.v2ProductName` | Product name |
