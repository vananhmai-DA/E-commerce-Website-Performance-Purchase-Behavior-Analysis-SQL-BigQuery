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

### Dataset Description

The dataset contains e-commerce website session data, including visitor information, session date, traffic source, device category, pageviews, bounces, transactions, product interactions, product quantity, and product revenue.

The dataset includes both session-level fields and nested e-commerce fields.

Session-level fields describe the overall session, such as visitor ID, date, traffic source, device category, pageviews, bounces, and transactions.

Nested fields describe more detailed user interactions within each session. In BigQuery, fields such as `hits`, `hits.eCommerceAction`, and `hits.product` are nested or repeated fields. Therefore, `UNNEST()` is used to access hit-level and product-level data for analysis.

### Key Fields Used

| Field Name | Description |
|---|---|
| `fullVisitorId` | Unique visitor ID |
| `date` | Session date in `YYYYMMDD` format |
| `totals` | A record field that contains aggregate values across the session |
| `totals.bounces` | Bounce indicator. For a bounced session, the value is `1`; otherwise, it is `null` |
| `totals.hits` | Total number of hits within the session |
| `totals.pageviews` | Total number of pageviews within the session |
| `totals.visits` | Number of sessions. The value is usually `1` for sessions with interaction events |
| `totals.transactions` | Total number of e-commerce transactions within the session |
| `trafficSource.source` | Source of website traffic, such as search engine, referring hostname, or UTM source |
| `device.deviceCategory` | Device type, such as mobile, tablet, or desktop |
| `hits` | A nested and repeated field that contains hit-level data within a session |
| `hits.eCommerceAction` | A nested field that contains e-commerce actions during the session |
| `hits.eCommerceAction.action_type` | E-commerce action type, such as product detail view, add-to-cart, checkout, or completed purchase |
| `hits.product` | A nested field that contains product-level e-commerce data |
| `hits.product.productQuantity` | Quantity of the product purchased |
| `hits.product.productRevenue` | Product revenue, stored in micro-units |
| `hits.product.productSKU` | Product SKU |
| `hits.product.v2ProductName` | Product name |

