# Data Quality Validation Log: Demand Forecasting Analysis

## A. Project Overview
This document records the data-quality validation process for the Demand Forecasting Analysis project. The primary goal is to ensure the integrity, consistency, and reliability of the dataset before it is used for time-series forecasting. By systematically identifying missing values, duplicates, and anomalies, we mitigate the risk of biased forecasts and unreliable business insights.

**Project Details:**
- **Business Brand:** R&D | RetailPulse
- **Database:** MySQL (`demand_forecasting`)
- **Dataset:** Kaggle Store Sales - Time Series Forecasting (Favorita, Ecuador)
- **Primary Fact Table:** `fact_sales` (3,000,888 rows)
- **Analysis Range:** 2013-01-01 to 2017-08-15

## B. Validation Summary
The validation process is currently in progress. A calendar-date comparison has confirmed a recurring pattern of missing data on December 25th across multiple years, which is documented as expected behavior. All other data-quality checks are pending the execution of verification SQL scripts.

- **Confirmed Findings:** 1
- **Pending Checks:** 13

## C. Issue Log

| Issue | Table / Columns | Size | Decision | Reason / Action |
| :--- | :--- | :--- | :--- | :--- |
| Missing calendar dates | `fact_sales` / `sales_date` | 4 dates | **Ignore** | Dec 25 (2013-2016) missing; expected behavior (limited to these identified dates). |
| Missing or NULL values | All Tables | Pending | **Flag** | Awaiting SQL results. |
| Duplicate sales business keys | `fact_sales` / (`store_id`, `product_family`, `sales_date`) | Pending | **Flag** | Awaiting SQL results. |
| Duplicate store IDs | `dim_stores` / `store_id` | Pending | **Flag** | Awaiting SQL results. |
| Duplicate oil dates | `dim_oil_prices` / `oil_date` | Pending | **Flag** | Awaiting SQL results. |
| Duplicate transaction keys | `fact_transactions` / (`date`, `store_id`) | Pending | **Flag** | Awaiting SQL results. |
| Exact duplicate holiday/event rows | `dim_holidays_events` / All columns | Pending | **Flag** | Awaiting SQL results. |
| Negative sales values | `fact_sales` / `total_sales` | Pending | **Flag** | Awaiting SQL results. |
| Negative promotion counts | `fact_sales` / `on_promotion` | Pending | **Flag** | Awaiting SQL results. |
| Negative transaction counts | `fact_transactions` / `transactions_count` | Pending | **Flag** | Awaiting SQL results. |
| Negative oil prices | `dim_oil_prices` / `oil_price` | Pending | **Flag** | Awaiting SQL results. |
| Sales records without matching store | `fact_sales` $\rightarrow$ `dim_stores` | Pending | **Flag** | Awaiting SQL results. |
| Transactions without matching store | `fact_transactions` $\rightarrow$ `dim_stores` | Pending | **Flag** | Awaiting SQL results. |
| Zero-sales counts and percentages | `fact_sales` / `total_sales` | Pending | **Flag** | Valid observations; awaiting distribution analysis. |

## D. Business Impact
Data-quality issues can significantly degrade the performance of demand forecasting models:
- **Missing Dates:** Gaps in time-series data can disrupt seasonality detection and lead to inaccuracies in trend analysis.
- **Duplicates/NULLs:** Overcounting or missing values can skew mean demand, leading to overstocking or stockouts.
- **Invalid Values:** Negative sales values or oil prices may indicate data-quality issues, unusual business conditions, or data-specific conventions. Investigate these values and verify their meaning before deciding whether to exclude or retain them.
- **Referential Integrity:** Orphaned records (e.g., sales without a store) prevent accurate regional or store-type aggregation.

## E. Remediation and Follow-up
The following steps are scheduled to finalize the validation:
1. Execute the remaining SQL data-quality scripts.
2. Update the **Size** and **Decision** columns in the Issue Log based on results.
3. Perform a distribution analysis on zero-sales records to determine if they represent true "no-sale" days or missing data.

**Constraint:** No records shall be deleted automatically from the raw tables. Any necessary exclusions will be handled during the data transformation (ETL/View) layer to preserve the original dataset.

## F. Final Conclusion
At this stage, four expected missing dates (December 25th, 2013–2016) have been identified and do not require correction. Other data-quality checks remain pending, and overall data readiness for demand forecasting has not yet been confirmed. 

No raw records have been deleted. Any future exclusions will be justified, documented, and applied during transformation or analysis while preserving the original dataset.
