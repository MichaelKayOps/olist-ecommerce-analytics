# DAX Measures — Olist E-commerce Analytics

This document defines the DAX measures used in the Olist E-commerce Analytics Power BI report.

Each measure includes its business question, definition, DAX formula, business use, and interpretation notes. The measures support consistent analysis of sales performance, delivery reliability, seller handover, customer satisfaction, and repeat purchasing.

## Model and Calculation Notes

The Power BI model contains data at different levels of detail. These modelling decisions affect how each measure is calculated and interpreted.

- `vw_olist_analysis` is an order-item-level analytical view. One order can appear in multiple rows when it contains multiple items.
- Orders are counted using distinct `order_id` values.
- Customers are counted using distinct `customer_unique_id` values.
- Revenue is calculated once per distinct delivered `order_id` to prevent payment values from being repeated across item-level rows.
- Delivery metrics use delivered orders and the project’s documented delivery-status rules.
- Seller-handover metrics compare the seller shipping-limit date with the actual carrier-delivery date.
- Repeat-purchase analysis uses qualifying delivered orders, `customer_unique_id`, and clearly defined observation windows.
- `DIVIDE()` is used for ratio calculations to handle possible division-by-zero cases safely.
- Year-over-year measures compare 2018 with 2017 using matching date windows.

## Measure Standards

- Revenue is calculated from `payment_value` in the prepared analytical view by aggregating the value once per distinct delivered `order_id`, then summing those order-level totals.
- Orders are counted using distinct `order_id` values.
- Customers are counted using distinct `customer_unique_id` values.
- Delivery metrics are calculated for delivered orders with valid actual and estimated delivery dates.
- Seller-handover metrics are calculated for delivered orders with valid shipping-limit and carrier-delivery dates.
- Repeat-purchase analysis uses qualifying delivered orders and clearly defined observation windows.
- Review metrics include only orders with a submitted review score.
- Year-over-year measures compare 2018 with 2017 using matching date windows.

---

## 1. Total Orders

### Business question

How many distinct orders were placed?

### Definition

Total Orders counts the number of unique orders in the dataset.

### DAX measure

```dax
Total Orders = 
DISTINCTCOUNT(vw_olist_analysis[order_id])
```

### Business use

This measure establishes the volume of marketplace activity and supports revenue, customer, and delivery analysis.

### Interpretation notes

- Uses `DISTINCTCOUNT` on `order_id` to prevent an order with multiple items or payment records from being counted more than once.
- Apply the relevant order-status filter when analysing delivered orders only.

---

## 2. Delivered Orders

### Business question

How many distinct delivered orders were completed?

### Definition

Delivered Orders counts distinct orders with a delivered order status.

### DAX measure

```dax
Delivered Orders = 
CALCULATE(
    DISTINCTCOUNT(vw_olist_analysis[order_id]),
    vw_olist_analysis[order_status] = "delivered"
)
```

### Business use

This measure establishes the volume of completed marketplace activity and is the basis for revenue, delivery, and repeat-purchase analysis.

### Interpretation notes

- Uses distinct `order_id` values to prevent multi-item orders from being counted more than once.
- Includes only orders with an order status of `delivered`.

---

## 3. Total Customers

### Business question

How many distinct customers are represented in the analysis?

### Definition

Total Customers counts distinct customers using the customer-level identifier.

### DAX measure

```dax
Total Customers = 
DISTINCTCOUNT(vw_olist_analysis[customer_unique_id])
```

### Business use

This measure supports customer-growth, repeat-purchase, and market-coverage analysis.

### Interpretation notes

- Uses `customer_unique_id`, not `customer_id`, because `customer_unique_id` identifies the same customer across multiple orders.

---

## 4. Total Revenue

### Business question

How much revenue was generated from delivered orders?

### Definition

Total Revenue is the sum of payment values for delivered orders, calculated once per distinct `order_id`.

### DAX measure

```dax
Total Revenue = 
CALCULATE(
    SUMX(
        VALUES(vw_olist_analysis[order_id]),
        CALCULATE(MAX(vw_olist_analysis[payment_value]))
    ),
    vw_olist_analysis[order_status] = "delivered"
)
```

### Business use

This measure tracks commercial performance, revenue trends, and the financial scale of the marketplace.

### Interpretation notes

- The prepared analytical view is at order-item grain, so one order can appear across multiple rows.
- `VALUES(order_id)` returns each delivered order once.
- `MAX(payment_value)` returns the order’s payment value once for that order.
- `SUMX` sums the order-level payment values.
- This prevents revenue from being inflated when an order contains multiple items.
- Only delivered orders are included in the project’s revenue definition.
- This approach assumes `payment_value` is the same across all rows for the same `order_id`.

---

## 5. Revenue Growth: 2018 vs 2017

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
        YEAR(vw_olist_analysis[order_date]) = 2018
    )
VAR Revenue2017 =
    CALCULATE(
        [Total Revenue],
        YEAR(vw_olist_analysis[order_date]) = 2017
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

## 6. Customer Growth: 2018 vs 2017

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
        YEAR(vw_olist_analysis[order_date]) = 2018
    )
VAR Customers2017 =
    CALCULATE(
        [Total Customers],
        YEAR(vw_olist_analysis[order_date]) = 2017
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

## 7. Order Growth: 2018 vs 2017

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
        YEAR(vw_olist_analysis[order_date]) = 2018
    )
VAR Orders2017 =
    CALCULATE(
        [Total Orders],
        YEAR(vw_olist_analysis[order_date]) = 2017
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
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        vw_olist_analysis[delivery_status] = "On Time"
    ),
    [Delivered Orders]
)
```

### Business use

This measure evaluates delivery reliability and helps identify regional, temporal, or operational performance issues.

### Interpretation notes

- Calculated using the prepared `delivery_status` field.
- On-time deliveries include orders delivered on or before the estimated delivery date.
- Orders without a valid customer-delivery date are excluded from the on-time and late-delivery calculation.

---

## 9. Late Delivery Rate

### Business question

What proportion of delivered orders arrived after the estimated delivery date?

### Definition

Late Delivery Rate measures the percentage of qualifying delivered orders classified as late.

### DAX measure

```dax
Late Delivery Rate = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        vw_olist_analysis[delivery_status] = "Late"
    ),
    [Delivered Orders]
)
```

### Business use

This measure monitors delivery reliability and identifies states, periods, or operational segments with elevated delivery risk.

### Interpretation notes

- Uses the prepared `delivery_status` field.
- Late deliveries are orders delivered after the estimated delivery date.
- Orders without a valid customer-delivery date are excluded from the on-time and late-delivery calculation.

---

## 10. Customer Average Rating

### Business question

How satisfied are customers with their shopping experience?

### Definition

Customer Average Rating is the average review score across all submitted reviews.

### DAX measure

```dax
Customer Average Rating = 
AVERAGE(vw_olist_analysis[review_score])
```

### Business use

This measure monitors customer satisfaction and helps identify whether operational or product-related issues may be affecting customer experience.

### Interpretation notes

- Review scores range from 1 to 5.
- Orders without a review score are excluded automatically because their review score is blank.
- The measure reflects customers who submitted reviews and may not represent all customers.

---

## 11. Positive Review Share

### Business question

What proportion of submitted reviews were positive?

### Definition

Positive Review Share measures the percentage of review scores rated four or five stars.

### DAX measure

```dax
Positive Review Share = 
DIVIDE(
    CALCULATE(
        COUNTROWS(vw_olist_analysis),
        vw_olist_analysis[review_score] IN { 4, 5 }
    ),
    CALCULATE(
        COUNTROWS(vw_olist_analysis),
        NOT ISBLANK(vw_olist_analysis[review_score])
    )
)
```

### Business use

This measure summarises customer sentiment and complements the average review score.

### Interpretation notes

- Positive reviews are defined as review scores of 4 or 5.
- Orders without a review score are excluded from the denominator.
- The measure reflects submitted reviews only and may not represent all customers.

---

## 12. Repeat Customer Rate

### Business question

What proportion of customers with at least one delivered order made another delivered purchase?

### Definition

Repeat Customer Rate measures the percentage of customers with at least one delivered order who made at least one additional delivered order, regardless of when their first delivered order occurred.

### DAX measure

```dax
Repeat Customer Rate = 
VAR CustomerOrderCounts =
    ADDCOLUMNS(
        VALUES(vw_olist_analysis[customer_unique_id]),
        "OrderCount",
        CALCULATE(
            DISTINCTCOUNT(vw_olist_analysis[order_id]),
            vw_olist_analysis[order_status] = "delivered"
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
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[customer_unique_id]),
        vw_olist_analysis[order_status] = "delivered"
    )
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
- The overall repeat-purchase rate is 3.0%.
- This measure is different from the 12-month cohort repeat-purchase rate, which uses only customers with enough observation time after their first delivered order.

---

## 13. 12-Month Cohort Repeat-Purchase Rate

### Business question

Of customers with enough time to make another purchase, what proportion made another delivered purchase within 12 months of their first delivered order?

### Definition

The 12-month cohort repeat-purchase rate measures the percentage of eligible customers who made another delivered order within 12 months of their first delivered order.

### DAX measure

```dax
12-Month Cohort Repeat-Purchase Rate = 
VAR FirstDeliveredOrder =
    ADDCOLUMNS(
        VALUES(vw_olist_analysis[customer_unique_id]),
        "First Delivered Order Date",
        CALCULATE(
            MIN(vw_olist_analysis[order_date]),
            vw_olist_analysis[order_status] = "delivered"
        )
    )
VAR EligibleCustomers =
    FILTER(
        FirstDeliveredOrder,
        [First Delivered Order Date] <= DATE(2017, 8, 29)
    )
VAR RepeatCustomers =
    FILTER(
        EligibleCustomers,
        CALCULATE(
            DISTINCTCOUNT(vw_olist_analysis[order_id]),
            vw_olist_analysis[order_status] = "delivered",
            vw_olist_analysis[order_date] > [First Delivered Order Date],
            vw_olist_analysis[order_date] <=
                EDATE([First Delivered Order Date], 12)
        ) >= 1
    )
RETURN
DIVIDE(
    COUNTROWS(RepeatCustomers),
    COUNTROWS(EligibleCustomers)
)
```

### Business use

This measure provides a fixed-window view of repeat purchasing and avoids overstating repeat behaviour for customers acquired near the end of the observation period.

### Interpretation notes

- Only customers whose first delivered order occurred early enough to allow a complete 12-month observation window are included.
- The eligible population is 21,361 customers.
- The result is 3.33%.
- This measure is different from the overall repeat-purchase rate, which includes all customers with at least one delivered order.
- The eligible-customer cutoff should match the cohort logic used in the SQL repeat-purchase analysis.

---

## 14. Late Seller Handover Rate

### Business question

What proportion of delivered orders were handed to the courier after the seller’s shipping-limit date?

### Definition

Late Seller Handover Rate measures the percentage of qualifying delivered orders where the carrier-delivery date was later than the shipping-limit date.

### DAX measure

```dax
Late Seller Handover Rate = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        vw_olist_analysis[order_delivered_carrier_date] > vw_olist_analysis[shipping_limit_date]
    ),
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        NOT ISBLANK(vw_olist_analysis[order_delivered_carrier_date]),
        NOT ISBLANK(vw_olist_analysis[shipping_limit_date])
    )
)
```

### Business use

This measure monitors seller dispatch discipline and helps identify sellers or regions with repeated late handovers.

### Interpretation notes

- A late handover occurs when `order_delivered_carrier_date` is later than `shipping_limit_date`.
- Orders missing either date are excluded.
- This measure should be analysed alongside late customer-delivery rate, because late handover increases delivery risk but does not explain every late delivery.

---

## 15. Late Delivery Rate: Late Seller Handover

### Business question

What proportion of orders with a late seller handover were delivered late to the customer?

### Definition

This measure calculates the late customer-delivery rate among delivered orders that were handed to the courier after the seller’s shipping-limit date.

### DAX measure

```dax
Late Delivery Rate: Late Seller Handover = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        vw_olist_analysis[order_delivered_carrier_date] > vw_olist_analysis[shipping_limit_date],
        vw_olist_analysis[delivery_status] = "Late"
    ),
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        vw_olist_analysis[order_delivered_carrier_date] > vw_olist_analysis[shipping_limit_date]
    )
)
```

### Business use

This measure quantifies the relationship between late seller handover and late customer delivery.

### Interpretation notes

- The result is 26.19%.
- It should be compared with the late-delivery rate for on-time seller handover, which is 5.58%.
- The comparison identifies an association; it does not prove that late handover alone caused the late delivery.

---

## 16. Late Delivery Rate: On-Time Seller Handover

### Business question

What proportion of orders with an on-time seller handover were delivered late to the customer?

### Definition

This measure calculates the late customer-delivery rate among delivered orders that were handed to the courier on or before the seller’s shipping-limit date.

### DAX measure

```dax
Late Delivery Rate: On-Time Seller Handover = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        vw_olist_analysis[order_delivered_carrier_date] <= vw_olist_analysis[shipping_limit_date],
        vw_olist_analysis[delivery_status] = "Late"
    ),
    CALCULATE(
        DISTINCTCOUNT(vw_olist_analysis[order_id]),
        vw_olist_analysis[order_status] = "delivered",
        vw_olist_analysis[order_delivered_carrier_date] <= vw_olist_analysis[shipping_limit_date]
    )
)
```

### Business use

This measure provides the comparison group for the late seller-handover analysis.

### Interpretation notes

- The result is 5.58%.
- Comparing this measure with the late seller-handover result shows that late handover was associated with a higher risk of late customer delivery.
- Most late deliveries still occurred after an on-time seller handover, so courier transit, destination, delivery distance, and delivery-estimate accuracy should also be investigated.

---

## Validation Results

| Measure | Result |
|---|---:|
| Total Orders | 98,832 |
| Delivered Orders | 96,478 |
| Total Customers | 95,526 |
| Total Revenue | R$15.28M |
| Revenue Growth: 2018 vs 2017 | 22.4% |
| Customer Growth: 2018 vs 2017 | 21.6% |
| On-Time Delivery Rate | 91.9% |
| Late Delivery Rate | 8.1% |
| Customer Average Rating | 4.10/5 |
| Positive Review Share | 77.3% |
| Repeat Customer Rate | 3.0% |
| 12-Month Cohort Repeat-Purchase Rate | 3.33% |
| Late Delivery Rate: Late Seller Handover | 26.19% |
| Late Delivery Rate: On-Time Seller Handover | 5.58% |

These results were cross-checked between SQL and Power BI to confirm that the report uses consistent calculations.
