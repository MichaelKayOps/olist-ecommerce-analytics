# Technical Process

This document explains how the Olist E-Commerce Analytics project was built, from raw data exploration to dashboard validation.

## 1. Project Workflow

```text
Raw CSV data
→ SQL Server import
→ Data exploration
→ Table joins
→ Cleaning and transformation
→ Data enrichment
→ Final analytical table
→ Data-quality validation
→ Power BI modelling
→ DAX measures
→ Dashboard development
→ SQL-to-Power BI reconciliation
→ Findings and recommendations
```

## 2. Tools and Environment

| Tool | Purpose |
|---|---|
| SQL Server | Data storage, exploration, joins, cleaning, transformation, and validation |
| SQL Server Management Studio | Query development and result review |
| Power BI Desktop | Data modelling, DAX, dashboard design, and analysis |
| DAX | Reusable business measures and calculated logic |
| Excel | Supplementary review and validation |
| GitHub | Version control and project documentation |

## 3. Source Data

The project uses the Brazilian E-Commerce Public Dataset by Olist.

### Tables used

| Table | Grain | Purpose |
|---|---|---|
| `olist_orders_dataset` | One row per order | Order status and delivery dates |
| `olist_customers_dataset` | One row per customer-order link | Customer location and unique customer identifier |
| `olist_order_items_dataset` | One row per order item | Product, seller, price, and freight information |
| `olist_order_payments_dataset` | One row per payment record | Payment value and payment type |
| `olist_order_reviews_dataset` | One row per review | Customer review score and review text |
| `olist_products_dataset` | One row per product | Product category and physical attributes |
| `olist_sellers_dataset` | One row per seller | Seller location |
| `product_category_name_translation` | One row per Portuguese category | English category translation |

### Key data-grain issue

The source tables do not share the same grain:

- An order can contain multiple items.
- An order can have multiple payment records.
- A joined analytical table can therefore contain repeated order, payment, customer, and review information.
- A direct `SUM(payment_value)` across the joined table would overstate revenue.

This is why revenue is calculated once per distinct delivered `order_id`.

## 4. Data Exploration

The first SQL script, `01_data_exploration.sql`, was used to understand the structure and quality of the source data.

### Checks performed

- Identified table row counts.
- Reviewed column names and data types.
- Checked primary and foreign-key fields.
- Identified missing values.
- Checked duplicate identifiers.
- Reviewed order-status values.
- Reviewed date ranges.
- Checked customer, seller, product, payment, and review coverage.

### Example exploration query

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    MIN(order_purchase_timestamp) AS earliest_order,
    MAX(order_purchase_timestamp) AS latest_order
FROM olist_orders_dataset;
```

### Screenshot placeholder

![Data exploration query results](../Images/sql/01_data_exploration.png)

## 5. Table Joins

The second script, `02_table_joins.sql`, combined the source tables into an analytical dataset.

### Join design

| Join | Join key | Purpose |
|---|---|---|
| Orders to customers | `customer_id` | Add customer state and unique customer identifier |
| Orders to order items | `order_id` | Add product, seller, price, and freight details |
| Order items to products | `product_id` | Add product category and attributes |
| Order items to sellers | `seller_id` | Add seller state |
| Orders to payments | `order_id` | Add payment value and payment type |
| Orders to reviews | `order_id` | Add review score |
| Products to category translation | `product_category_name` | Add English product-category names |

### Important decision

The analytical table was designed to retain the detail needed for product, seller, and delivery analysis. Because this creates repeated values at order level, all order-level financial metrics must be aggregated carefully.

## 6. Cleaning and Transformation

The third script, `03_data_cleaning_and_transformation.sql`, prepared the data for analysis.

### Actions taken

- Standardised column names and data types.
- Converted date fields to appropriate date types.
- Removed rows identical across selected columns using `SELECT DISTINCT`.
- Reviewed missing values in key analytical fields.
- Standardised categorical values where required.
- Prepared delivery-status and delivery-timing fields.
- Prepared fields for state-level and customer-level analysis.

### Example cleaning query

```sql
SELECT DISTINCT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS DATE) AS order_date
FROM olist_orders_dataset;
```

## 7. Data Enrichment

The fourth script, `04_data_enrichment.sql`, created analytical fields used in the dashboard and findings.

### Fields created

- Delivery duration.
- Estimated delivery duration.
- Delivery delay in days.
- On-time or late-delivery flag.
- Delivered-order flag.
- Order month and order year.
- Repeat-purchase analysis fields.

### Example enrichment logic

```sql
CASE
    WHEN order_delivered_customer_date <= order_estimated_delivery_date
    THEN 'On time'
    ELSE 'Late'
END AS delivery_performance
```

## 8. Final Analytical Table

The fifth script, `05_final_table_preparation.sql`, created the final analytical view used by Power BI.

### Final table purpose

The final table combines:

- Order information.
- Customer information.
- Product and category information.
- Seller information.
- Payment information.
- Review information.
- Delivery performance fields.
- Date fields for trend analysis.

### Important modelling note

The final table is at a detailed analytical grain. It supports product, seller, state, and delivery analysis, but it requires order-level aggregation for revenue and customer metrics.

## 9. Data-Quality Validation

The sixth script, `06_data_quality_checks.sql`, validated the prepared dataset before dashboard development.

### Checks performed

| Check | Purpose |
|---|---|
| Row count | Confirm expected volume after joins |
| Distinct order count | Confirm order-level uniqueness |
| Delivered-order count | Confirm the revenue population |
| Distinct customer count | Confirm customer coverage |
| Missing order IDs | Identify join issues |
| Missing customer IDs | Identify customer-link issues |
| Missing delivery dates | Identify incomplete delivery records |
| Duplicate order IDs | Identify unintended duplication |
| Revenue total | Confirm order-level revenue calculation |
| Date range | Confirm analysis period |

### Revenue validation query

```sql
WITH order_revenue AS
(
    SELECT
        order_id,
        MAX(payment_value) AS order_revenue
    FROM dbo.vw_olist_analysis
    WHERE order_status = 'delivered'
    GROUP BY
        order_id
)
SELECT
    COUNT(DISTINCT order_id) AS delivered_orders,
    SUM(order_revenue) AS total_revenue
FROM order_revenue;
```

### Validated result

| Metric | Result |
|---|---:|
| Delivered orders | 96,478 |
| Total revenue | R$15.28M |

### Screenshot placeholder

![Revenue validation query results](../Images/sql/02_revenue_validation.png)

## 10. Customer Retention Analysis

The seventh script, `07_customer_retention.sql`, measured repeat purchasing.

### Overall repeat-purchase rate

The overall repeat-purchase rate was calculated among customers with at least one delivered order.

```sql
WITH delivered_orders AS
(
    SELECT
        customer_unique_id,
        order_id,
        order_date
    FROM dbo.vw_olist_analysis
    WHERE order_status = 'delivered'
),
customer_first_order AS
(
    SELECT
        customer_unique_id,
        MIN(order_date) AS first_order_date
    FROM delivered_orders
    GROUP BY
        customer_unique_id
)
SELECT
    COUNT(DISTINCT d.customer_unique_id) AS customers_with_delivered_order,
    COUNT(DISTINCT CASE
        WHEN d.order_date > c.first_order_date
        THEN d.customer_unique_id
    END) AS repeat_customers
FROM delivered_orders AS d
INNER JOIN customer_first_order AS c
    ON d.customer_unique_id = c.customer_unique_id;
```

### Result

| Metric | Result |
|---|---:|
| Customers with at least one delivered order | 93,358 |
| Overall repeat-purchase rate | 3.0% |

### 12-month cohort analysis

The 12-month cohort analysis used a separate eligible population and observation window.

| Observation window | Eligible customers | Repeat customers | Repeat-purchase rate |
|---|---:|---:|---:|
| Within 3 months | 21,361 | 291 | 1.36% |
| Within 6 months | 21,361 | 463 | 2.17% |
| Within 12 months | 21,361 | 711 | 3.33% |

### Screenshot placeholder

![Customer retention query results](../Images/sql/03_customer_retention.png)

## 11. Power BI Data Model

The Power BI report used the prepared analytical view as its main fact table.

### Model decisions

- Used the prepared analytical table as the primary reporting source.
- Created a date table for time-based analysis.
- Established relationships using order, customer, product, seller, and date fields.
- Checked relationship cardinality and filter direction.
- Hid technical fields from the report view where appropriate.
- Created a dedicated measures table for reusable DAX logic.

### Screenshot placeholder

![Power BI data model](../Images/powerbi/01_data_model.png)

## 12. DAX Measures

Key measures were created in DAX to ensure consistent calculations across visuals.

### Total revenue

```dax
Total Revenue = 
CALCULATE(
    SUMX(
        DISTINCT(vw_olist_analysis[order_id]),
        CALCULATE(MAX(vw_olist_analysis[payment_value]))
    ),
    vw_olist_analysis[order_status] = "delivered"
)
```

### Why this measure is used

- The analytical view is at a detailed grain.
- One order can appear across multiple item rows.
- `DISTINCT(order_id)` returns each delivered order once.
- `MAX(payment_value)` returns the order payment value once.
- `SUMX` sums the order-level values.
- This prevents revenue from being inflated by repeated payment values.

### Other key measures

| Measure | Purpose |
|---|---|
| Delivered Orders | Count distinct delivered orders |
| Distinct Customers | Count distinct customers |
| Customers with Delivered Order | Count customers with at least one delivered order |
| Overall Repeat-Purchase Rate | Measure repeat purchasing among eligible customers |
| On-Time Delivery Rate | Measure delivery reliability |
| Late Delivery Rate | Measure late-delivery share |
| Average Review Score | Measure customer satisfaction |
| Positive Review Share | Measure the share of 4–5 star reviews |

## 13. Dashboard Development

The Power BI report contains four pages.

| Page | Purpose |
|---|---|
| Overview | Executive summary of headline KPIs and findings |
| Sales Performance | Revenue, orders, customers, trends, and state performance |
| Delivery Performance | On-time delivery, late delivery, and state-level logistics performance |
| Customer Satisfaction & Retention | Review scores, positive reviews, and repeat purchasing |

### Design decisions

- Placed headline KPIs at the top of each page.
- Used trend charts to show performance over time.
- Used state-level visuals to identify regional differences.
- Used filters to allow exploration by date, state, product category, and delivery outcome.
- Kept visual titles question-led rather than descriptive.
- Added insight text to explain what each page reveals.

### Screenshot placeholders

![Overview dashboard](../Images/01_overview_dashboard.png)

![Sales performance dashboard](../Images/02_sales_performance_dashboard.png)

![Delivery performance dashboard](../Images/03_delivery_performance_dashboard.png)

![Customer satisfaction dashboard](../Images/04_customer_satisfaction_dashboard.png)

## 14. SQL-to-Power BI Reconciliation

Before finalising the report, key Power BI measures were compared with SQL results.

| Metric | SQL result | Power BI result | Status |
|---|---:|---:|---|
| Distinct orders | 98,832 | 98,832 | Matched |
| Delivered orders | 96,478 | 96,478 | Matched |
| Distinct customers | 95,526 | 95,526 | Matched |
| Customers with at least one delivered order | 93,358 | 93,358 | Matched |
| Total revenue | R$15.28M | R$15.28M | Matched |
| Overall repeat-purchase rate | 3.0% | 3.0% | Matched |
| São Paulo revenue share | 37.42% | 37.42% | Matched |
| Revenue growth | 22.4% | 22.4% | Matched |

### Screenshot placeholder

![SQL and Power BI reconciliation](../Images/validation/01_reconciliation.png)

## 15. Lessons Learned

- Understand table grain before aggregating financial values.
- Do not treat a joined row count as a distinct order count.
- Validate revenue, customer, and order counts against SQL before publishing a dashboard.
- Separate the overall repeat-purchase rate from cohort-based retention analysis.
- Document assumptions and limitations alongside findings.
- Build dashboards around business questions, not available fields.
