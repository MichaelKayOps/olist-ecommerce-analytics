# DAX Measures — Olist E-commerce Analytics

This document defines the key DAX measures used in the Olist E-commerce Analytics Power BI report.

Each measure includes its business question, definition, DAX formula, business use, and interpretation notes. The measures support consistent analysis of sales performance, delivery reliability, customer satisfaction, and repeat purchasing.

## Model and Calculation Notes

The Power BI model contains data at different levels of detail. These modelling decisions affect how each measure should be calculated and interpreted.

- `dbo.vw_olist_analysis` is an order-item-level analytical view. One order can appear in multiple rows when it contains multiple items.
- Distinct `order_id` values must be used when counting orders.
- Distinct `customer_unique_id` values must be used when counting customers.
- Revenue is calculated from the original payment records at their proper grain, avoiding duplication introduced by joins in the analytical view.
- Delivery metrics use delivered orders and the project’s documented delivery-status rules.
- Repeat-purchase analysis uses qualifying delivered orders, `customer_unique_id`, and clearly defined observation windows.

## Measure Standards

-Revenue is calculated from payment_value in the prepared analytical view by aggregating the value once per distinct delivered order_id, then summing those order-level totals. This prevents payment values from being counted multiple times when an order appears across multiple item rows.
- Orders are counted using distinct `order_id` values.
- Customers are counted using distinct `customer_unique_id` values.
- Delivery metrics are calculated for delivered orders with valid actual and estimated delivery dates.
- Repeat-purchase analysis uses qualifying delivered orders and clearly defined observation windows.
- `DIVIDE()` is used for ratio calculations to handle possible division-by-zero cases safely.
- Year-over-year measures compare 2018 with 2017 using matching date windows.

## 1. Total Orders

### Business question

How many distinct orders were placed?

### Definition

Total Orders counts the number of unique orders in the dataset.

### DAX measure

```dax
Total Orders = DISTINCTCOUNT('vw_olist_analysis'[order_id])
```

### Business use

This measure establishes the volume of marketplace activity and supports revenue, customer, and delivery analysis.

### Interpretation notes

- Uses `DISTINCTCOUNT` on `order_id` to prevent an order with multiple items or payment records from being counted more than once.
- Apply the relevant order-status filter when analysing delivered orders only.

---

## 2. Total Revenue

### Business question

How much revenue was generated from delivered orders?

### Definition

Total Revenue is the sum of payment values for delivered orders, calculated once per distinct order_id.

### DAX measure

`dax
Total Revenue = 
CALCULATE(
    SUMX(
        DISTINCT(vw_olist_analysis[order_id]),
        CALCULATE(MAX(vw_olist_analysis[payment_value]))
    ),
    vw_olist_analysis[order_status] = "delivered"
)

### Business use

This measure tracks commercial performance, revenue trends, and the financial scale of the marketplace.

### Interpretation notes

The prepared analytical view is at order-item grain, so one order can appear across multiple rows.
DISTINCT(order_id) returns each delivered order once.
MAX(payment_value) returns the order’s payment value once for that order.
SUMX sums the order-level payment values.
This prevents revenue from being inflated when an order contains multiple items.
Only delivered orders are included in the project’s revenue definition.
This approach assumes payment_value is the same across all rows for the same order_id.
---

## 3. Revenue Growth: 2018 vs 2017

### Business question

How much did revenue change in 2018 compared with 2017?

### Definition

Revenue Growth measures the percentage change in revenue between 2018 and 2017.

### DAX measure

```dax
Revenue Growth 2018 vs 2017 = 
VAR Revenue2018 =
    CALCULATE(
        [Total Revenue],
        YEAR('vw_olist_analysis'[order_date]) = 2018
    )
VAR Revenue2017 =
    CALCULATE(
        [Total Revenue],
        YEAR('vw_olist_analysis'[order_date]) = 2017
    )
RETURN
DIVIDE(
    Revenue2018 - Revenue2017,
    Revenue2017
)
```

### Business use

This measure shows whether commercial performance improved year over year and helps identify periods of accelerating or slowing growth.

### Interpretation notes

- Compares 2018 revenue with 2017 revenue.
- Uses revenue from delivered orders.
- The 2017 and 2018 calculations use matching date windows to avoid comparing a partial year with a longer period.
- A positive result indicates revenue growth; a negative result indicates revenue decline.

---

## 4. Customer Growth: 2018 vs 2017

### Business question

How much did the active customer base change in 2018 compared with 2017?

### Definition

Customer Growth measures the percentage change in distinct customers who placed orders in 2018 compared with 2017.

### DAX measure

```dax
Customer Growth 2018 vs 2017 = 
VAR Customers2018 =
    CALCULATE(
        [Total Customers],
        YEAR('vw_olist_analysis'[order_date]) = 2018
    )
VAR Customers2017 =
    CALCULATE(
        [Total Customers],
        YEAR('vw_olist_analysis'[order_date]) = 2017
    )
RETURN
DIVIDE(
    Customers2018 - Customers2017,
    Customers2017
)
```

### Business use

This measure helps assess whether revenue growth is being supported by more active customers or by changes in purchasing behaviour.

### Interpretation notes

- Customers are identified using `customer_unique_id`, not `customer_id`, to recognise the same customer across orders.
- This measure counts distinct customers with orders in each period; it measures the change in active customers, not necessarily newly acquired customers.
- New-customer acquisition would require identifying each customer’s first purchase date.
- The 2017 and 2018 calculations use matching date windows to avoid comparing a partial year with a longer period.
- A high customer-growth rate alongside a low repeat-purchase rate suggests acquisition-led growth.

---

## 5. Order Growth: 2018 vs 2017

### Business question

How much did order volume change in 2018 compared with 2017?

### Definition

Order Growth measures the percentage change in distinct delivered orders between 2018 and 2017.

### DAX measure

```dax
Orders Growth 2018 vs 2017 = 
VAR Orders2018 =
    CALCULATE(
        [Total Orders],
        YEAR('vw_olist_analysis'[order_date]) = 2018
    )
VAR Orders2017 =
    CALCULATE(
        [Total Orders],
        YEAR('vw_olist_analysis'[order_date]) = 2017
    )
RETURN
DIVIDE(
    Orders2018 - Orders2017,
    Orders2017
)
```

### Business use

This measure shows whether marketplace activity is expanding and helps explain changes in revenue.

### Interpretation notes

- Compares 2018 orders with 2017 orders.
- Uses distinct `order_id` values to avoid double-counting orders with multiple items.
- The 2017 and 2018 calculations use matching date windows to avoid comparing a partial year with a longer period.
- Order growth can differ from revenue growth if average order value changes.

---

## 6. Repeat Customer Rate

### Business question

What proportion of customers with at least one delivered order made another delivered purchase?

### Definition

Repeat Customer Rate measures the percentage of customers with at least one delivered order who made at least one additional delivered order, regardless of when their first delivered order occurred.

### DAX measure

```dax
Repeat Customer Rate = 
VAR CustomerOrderCounts =
    ADDCOLUMNS(
        VALUES('vw_olist_analysis'[customer_unique_id]),
        "OrderCount",
            CALCULATE(
                DISTINCTCOUNT('vw_olist_analysis'[order_id])
            )
    )
VAR RepeatCustomers =
    COUNTROWS(
        FILTER(
            CustomerOrderCounts,
            [OrderCount] > 1
        )
    )
VAR TotalCustomers =
    DISTINCTCOUNT('vw_olist_analysis'[customer_unique_id])
RETURN
    DIVIDE(
        RepeatCustomers,
        TotalCustomers
    )
```

### Business use

This measure provides a high-level view of repeat purchasing among customers with completed, delivered orders.

### Interpretation notes

- Customers are identified using `customer_unique_id`.
- The denominator is 93,358 customers with at least one delivered order.
- The numerator is the number of those customers with more than one delivered order.
- Only delivered orders are treated as qualifying purchases.
- Orders with statuses such as cancelled, shipped, processing, or unavailable are excluded.
- The overall repeat-purchase rate is approximately 3.0%.
- This measure is different from the 12-month cohort repeat-purchase rate, which uses only customers with enough observation time after their first delivered order.

---

## 7. Customer Average Rating

### Business question

How satisfied are customers with their shopping experience?

### Definition

Customer Average Rating is the average review score submitted by customers.

### DAX measure

```dax
Customer Average Rating = 
AVERAGEX(
    VALUES('vw_olist_analysis'[customer_unique_id]),
    CALCULATE(
        AVERAGE('vw_olist_analysis'[review_score])
    )
)
```

### Business use

This measure monitors customer satisfaction and helps identify whether operational or product-related issues may be affecting customer experience.

### Interpretation notes

- Review scores generally range from 1 to 5.
- The measure reflects customers who submitted reviews and may not represent all customers.
- Review scores should be analysed at the review or order grain to avoid repeated review values receiving extra weight.

---

## 8. On-Time Delivery Rate

### Business question

What proportion of delivered orders arrived on or before the estimated delivery date?

### Definition

On-Time Delivery Rate measures the percentage of qualifying delivered orders classified as on time.

### DAX measure

```dax
On-Time Delivery Rate = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT('vw_olist_analysis'[order_id]),
        'vw_olist_analysis'[order_status] = "delivered",
        'vw_olist_analysis'[delivery_status] = "On Time"
    ),
    [Delivered Orders]
)
```

### Business use

This measure evaluates delivery reliability and helps identify regional, temporal, or operational performance issues.

### Interpretation notes

- Calculated using the prepared `delivery_status` field.
- The delivery-status classification is based on the comparison between the actual customer delivery date and the estimated delivery date.
- Orders without a valid delivery date are excluded from the on-time and late-delivery calculation.
- The precise classification rule is documented in the SQL preparation script and data dictionary.

---
