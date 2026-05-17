## 1.Project Overview

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

