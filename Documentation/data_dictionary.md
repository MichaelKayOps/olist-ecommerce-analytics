# Data Dictionary — Olist E-commerce Analytics

## 1. Overview

This document describes the source data, prepared analytical dataset, field definitions, table relationships, validation results, aggregation rules, and interpretation considerations for the Olist E-commerce Analytics project.

The project analyses sales performance, delivery reliability, customer satisfaction, and repeat purchasing using the Brazilian E-Commerce Public Dataset by Olist.

| Item | Details |
|---|---|
| Source | [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |
| Database | Olist_Ecommerce_data |
| Prepared analytical object | dbo.vw_olist_analysis |
| Analysis period | 4 September 2016 – 17 October 2018 |
| Tools | SQL Server, Power BI, DAX |
| Currency | Brazilian reais (R$) |

## 2. Purpose

This data dictionary provides a single reference for understanding:

- The source tables used in the project.
- How the prepared analytical dataset was created.
- The meaning and analytical use of each column.
- The grain of the prepared dataset.
- How revenue, delivery, review, and customer metrics should be calculated.
- The validation checks performed during data preparation.
- The limitations that affect interpretation.

## 3. Prepared Dataset Grain

The prepared analytical view, dbo.vw_olist_analysis, is an order-item-level dataset.

One row represents one order item, enriched with customer, seller, product, payment, review, and delivery information.

This means:

- One order can appear in multiple rows if it contains multiple items.
- Payment values can repeat across item rows for the same order.
- Order-level metrics must use distinct order identifiers or an appropriately aggregated order-level dataset.
- Revenue must not be calculated by summing payment_value directly from dbo.vw_olist_analysis.

## 4. Source Tables and Relationships

The prepared dataset was created by joining eight source tables using LEFT JOIN operations.

| Source table | Purpose | Join key |
|---|---|---|
| orders_dataset | Order status, purchase date, and delivery dates | order_id |
| order_reviews_dataset | Customer review identifiers and review scores | order_id |
| order_items_dataset | Products, sellers, item prices, and freight values | order_id |
| products_dataset | Product information and original category names | product_id |
| order_payments_dataset | Payment records and payment values | order_id |
| customers_dataset | Customer identifiers and location | customer_id |
| sellers_dataset | Seller identifiers and location | seller_id |
| product_category_translation | English translations of product categories | product_category_name |


### Join relationships

- Orders were joined to reviews using order_id.
- Orders were joined to order items using order_id.
- Order items were joined to products using product_id.
- Order items were joined to payments using order_id.
- Orders were joined to customers using customer_id.
- Order items were joined to sellers using seller_id.
- Products were joined to category translations using the Portuguese product-category name.

LEFT JOIN was used to retain orders even where related records were unavailable. However, because an order can contain multiple items, payments, or reviews, the joined output can contain multiple rows per order.

## 5. Column Definitions

### 5.1 Customer fields

| Column | Data type | Nullable | Description | Analytical use |
|---|---|---:|---|---|
| customer_unique_id | NVARCHAR(50) | Yes | Persistent identifier used to recognise the same customer across orders. | Customer counts, repeat-purchase analysis, and retention cohorts. |
| customer_city | NVARCHAR(50) | Yes | City associated with the customer’s recorded address. | Geographic customer analysis. |
| customer_state | NVARCHAR(50) | Yes | Brazilian state associated with the customer’s recorded address. | Regional sales, delivery, and retention analysis. |

### 5.2 Order fields

| Column | Data type | Nullable | Description | Analytical use |
|---|---|---:|---|---|
| order_id | NVARCHAR(50) | No | Identifier for an order. Multiple rows may share the same order ID. | Distinct order counts and order-level linking. |
| order_date | DATE | Yes | Date the order was purchased. | Revenue trends, order trends, and purchase timelines. |
| order_status | NVARCHAR(50) | No | Status recorded for the order in the source data. | Filtering delivered orders and analysing order outcomes. |


### 5.3 Product and seller fields

| Column | Data type | Nullable | Description | Analytical use |
|---|---|---:|---|---|
| product_category | NVARCHAR(4000) | Yes | Product category, using the translated English category name where available. | Category performance and product-mix analysis. |
| price | DECIMAL(10,2) | Yes | Price of the order item, in Brazilian reais. | Item-level sales and product analysis. |
| seller_id | NVARCHAR(50) | Yes | Identifier of the seller associated with the order item. | Seller-level analysis. |
| seller_city | NVARCHAR(50) | Yes | City associated with the seller. | Seller geography analysis. |
| seller_state | NVARCHAR(50) | Yes | Brazilian state associated with the seller. | Seller distribution and regional supply analysis. |

### 5.4 Payment and shipping fields

| Column | Data type | Nullable | Description | Analytical use |
|---|---|---:|---|---|
| payment_value | DECIMAL(10,2) | Yes | Payment value associated with an order payment record. | Revenue analysis, subject to correct payment-grain handling. |
| freight_value | DECIMAL(10,2) | Yes | Freight charge associated with the order item. | Shipping-cost and item-level analysis. |
| shipping_limit_date | DATE | Yes | Date by which the seller was expected to hand the item to the carrier. | Seller dispatch-timing analysis. |

Important: payment_value can repeat across item rows for the same order. Revenue is therefore calculated by aggregating payment values once per delivered order_id, not by summing payment_value directly from the joined item-level view.


### 5.5 Delivery fields

| Column | Data type | Nullable | Description | Analytical use |
|---|---|---:|---|---|
| order_delivered_carrier_date | DATE | Yes | Date the order was handed to the logistics carrier. | Dispatch and carrier-handover analysis. |
| order_estimated_delivery_date | DATE | Yes | Estimated delivery date provided for the order. | Delivery-performance comparison. |
| order_delivered_customer_date | DATE | Yes | Date the order was delivered to the customer. | Actual delivery timing and delay analysis. |
| delivery_status | VARCHAR(13) | No | Derived classification of delivery performance. | On-time and late-delivery analysis. |
| delivery_delay_days | INT | Yes | Derived difference in days between actual and estimated delivery dates. | Measuring delivery delay. |

Delivery-delay rule:

delivery_delay_days = order_delivered_customer_date - order_estimated_delivery_date
- Positive value: order was delivered late.
- Zero: order was delivered within the estimated date.

### 5.6 Customer review fields

| Column | Data type | Nullable | Description | Analytical use |
|---|---|---:|---|---|
| review_score | TINYINT | Yes | Customer review score, generally from 1 to 5. | Customer-satisfaction analysis. |
| review_id | NVARCHAR(50) | Yes | Identifier for the customer review record. | Review validation and review-level analysis. |

Review scores should be analysed at the review or order grain. If an order has multiple rows in the prepared dataset, repeating its review score across those rows can distort averages and counts.


## 6. Revenue Calculation

Revenue is calculated from payment_value at the order level, using delivered orders only.

The prepared analytical view is an order-item-level dataset. When an order contains multiple items, its payment value can appear on multiple rows. Summing payment_value directly from this view would inflate revenue because thesame order’s payment value would be counted once for each item row.

### Revenue rule

1. Filter the data to delivered orders only.
2. Group payment records by order_id.
3. Sum payment_value for each order.
4. Sum the resulting order-level payment totals to calculate total revenue.

This ensures that each delivered order contributes its payment value once, regardless of how many items, sellers, or joined rows are associated with that order.


### Revenue validation

Revenue was calculated for 96,478 distinct delivered orders, out of 98,832 distinct orders in the dataset.

The remaining orders were excluded because they were not delivered and therefore did not meet the project’s revenue definition.

### SQL approach

WITH order_revenue AS
(
    SELECT
        p.order_id,
        SUM(p.payment_value) AS order_revenue
    FROM dbo.order_payments_dataset AS p
    INNER JOIN dbo.orders_dataset AS o
        ON p.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        p.order_id
)
SELECT
    SUM(order_revenue) AS total_revenue,
    COUNT(DISTINCT order_id) AS delivered_order_count
FROM order_revenue;

## 7. Validation Results

The following checks were performed during data preparation.

| Validation check | Expected result | Actual result | Status |
|---|---:|---:|---|
| Valid records in prepared dataset | 106,354 | 106,354 | Pass |
| Unique orders | 98,832 | 98,832 | Pass |
| Unique customers, 2016–2018 | 95,526 | 95,526 | Pass |
| Delivered orders used for revenue | 96,478 | 96,478 | Pass |

These checks confirm that the tested record, order, customer, and delivered-order totals match expected values. They do not remove the need to handle join duplication when calculating item-level or payment-level measures.


## 8. Aggregation Rules

| Metric | Correct approach |
|---|---|
| Total orders | Count distinct order_id. |
| Total customers | Count distinct customer_unique_id, applying the intended filters. |
| Total revenue | Aggregate payment_value by order_id for delivered orders, then sum the order-level totals. |
| Item sales | Sum price only after confirming item records have not been duplicated by joins. |
| Average review score | Calculate at the review or order grain to prevent repeated review values from receiving extra weight. |
| On-time delivery rate | Calculate using delivered orders with valid actual and estimated delivery dates. |
| Repeat-purchase rate | Use distinct customer_unique_id, qualifying delivered orders, and a clearly defined observation window. |

### Why SELECT DISTINCT is not enough

SELECT DISTINCT removes rows that are identical across every selected column. It does not guarantee one row per order or item.

For example, if one order contains three items and has a payment value of R$150, that payment value may appear on all three item rows. Summing the joined rows would incorrectly return R$450.

Similarly, SUM(DISTINCT payment_value) is not a reliable correction because different legitimate payments can have the same amount.

## 9. Business Definitions

| Metric | Definition |
|---|---|
| Revenue | Total payment value for delivered orders, calculated by aggregating payment values once per distinct delivered order_id. |
| Total orders | Count of distinct qualifying order_id values. |
| Total customers | Count of distinct qualifying customer_unique_id values. |
| Delivered orders | Distinct orders with a delivered order status. |
| Average order value | Revenue divided by the number of qualifying distinct delivered orders. |
| On-time delivery rate | Delivered orders arriving on or before the estimated delivery date, divided by qualifying delivered orders. |
| Delivery delay | Difference in days between actual customer delivery date and estimated delivery date. |
| Repeat customer | A customer with more than one qualifying delivered order, identified using customer_unique_id. |
| Repeat-purchase rate | Repeat customers divided by the eligible customer population within the stated observation window. |
| Average review score | Average of valid review scores, calculated at the appropriate review or order grain. |


## 10. Data Quality Considerations

The following issues were considered during preparation and analysis:

- Multiple rows per order are expected because an order can contain multiple items.
- SELECT DISTINCT removes exact duplicate rows but does not resolve many-to-many join duplication.
- Payment values can repeat across item rows and must be aggregated at the order level before calculating revenue.
- Nullable fields may contain missing values, especially for orders that have not reached a delivery stage.
- Delivery classifications and delay calculations depend on valid actual and estimated delivery dates.
- Review scores should be aggregated at the correct grain to avoid duplicated review values.
- Metric definitions must remain consistent across SQL, DAX, dashboard labels, and documentation.

## 11. Limitations

- The dataset covers historical activity from 2016 to 2018 and does not represent Olist’s current performance.
- The prepared dataset combines order, item, payment, review, customer, seller, and delivery information at different grains.
- Revenue is calculated only for delivered orders and may exclude orders with missing or invalid payment records.
- Delivery analysis should use delivered orders and handle missing delivery dates consistently.
- Repeat-purchase results depend on the customer identifier, eligibility rules, observation window, and order-status filter.
- Relationships between delivery performance, review scores, and repeat purchasing are observational and do not establish causation.


## 12. Related Documentation

| File | Purpose |
|---|---|
| business_questions.md | Business questions and project objectives. |
| methodology_and_validation.md | Data-preparation methods, validation checks, and analytical decisions. |
| dax_measures.md | Power BI DAX measures and calculation definitions. |
| findings_and_recommendations.md | Key findings and recommended actions. |
| limitations.md | Project limitations and interpretation boundaries. |




