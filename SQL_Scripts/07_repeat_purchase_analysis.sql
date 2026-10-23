/*

## REPEAT-PURCHASE RATE ANALYSIS
 Evaluates customer retention by measuring the percentage of customers who
placed another delivered order within 3, 6, and 12 months of their first
delivered purchase. Only customers with a full 12-month observation window
are included. The analysis also examines whether the rating of a customer's
first delivered order is associated with repeat purchasing within 12 months.

### Key Findings:
Only 3.33% of eligible customers made another delivered purchase within
12 months of their first delivered order. This indicates that repeat
purchasing was uncommon, even among customers with a full 12-month
observation window, highlighting a potential customer-retention challenge.
*/
	
DROP TABLE IF EXISTS #CustomerOrders;

-- Step 1: Create one row per customer and order.
-- Only delivered orders count as completed purchases.

SELECT DISTINCT
    customer_unique_id,
    order_id,
    order_date
    INTO #CustomerOrders
  FROM Olist_Ecommerce_data.dbo.vw_olist_analysis
WHERE customer_unique_id IS NOT NULL
     AND order_id IS NOT NULL
     AND order_date IS NOT NULL
     AND order_status = 'delivered'; 

-- Step 2: Identify each customer's first delivered order.

 ;WITH CustomerFirstOrder AS (
 SELECT
        customer_unique_id,
        MIN(order_date) AS first_order_date
    FROM #CustomerOrders
    GROUP BY customer_unique_id
),

-- Step 3: Include only customers with a full 12-month
-- observation window after their first delivered order.

  EligibleCustomers AS (
SELECT
        customer_unique_id,
        first_order_date
     FROM CustomerFirstOrder
    WHERE first_order_date <= DATEADD(
        MONTH,
        -12,
        (SELECT MAX(order_date) FROM #CustomerOrders)
    )
),

-- Step 4: Determine whether each eligible customer
-- completed another delivered order within each window.

  RepeatStatus AS (
SELECT
        ec.customer_unique_id,
  MAX(CASE
            WHEN co.order_date > ec.first_order_date
             AND co.order_date <= DATEADD(
                 MONTH, 3, ec.first_order_date
             )
            THEN 1 ELSE 0
        END) AS repeat_within_3_months,
       
  MAX(CASE
            WHEN co.order_date > ec.first_order_date
             AND co.order_date <= DATEADD(
                 MONTH, 6, ec.first_order_date
             )
            THEN 1 ELSE 0
        END) AS repeat_within_6_months,

  MAX(CASE
            WHEN co.order_date > ec.first_order_date
             AND co.order_date <= DATEADD(
                 MONTH, 12, ec.first_order_date
             )
            THEN 1 ELSE 0
        END) AS repeat_within_12_months

    FROM EligibleCustomers AS ec
    LEFT JOIN #CustomerOrders AS co
        ON co.customer_unique_id = ec.customer_unique_id
       AND co.order_date > ec.first_order_date
       AND co.order_date <= DATEADD(
           MONTH, 12, ec.first_order_date
       )
    GROUP BY ec.customer_unique_id
)

-- Step 5: Report all three repeat-purchase rates.
SELECT
    COUNT(*) AS eligible_customers,
    SUM(repeat_within_3_months)
        AS repeat_customers_3_months,

    CAST(
        100.0 * SUM(repeat_within_3_months)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS repeat_rate_3_months_pct,
    SUM(repeat_within_6_months)
        AS repeat_customers_6_months,

    CAST(
        100.0 * SUM(repeat_within_6_months)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS repeat_rate_6_months_pct,
    SUM(repeat_within_12_months)
        AS repeat_customers_12_months,

    CAST(
        100.0 * SUM(repeat_within_12_months)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS repeat_rate_12_months_pct
FROM RepeatStatus;

-- Clean up the temporary table.
DROP TABLE IF EXISTS #CustomerOrders;

/*
### Key Investigation:
   - Does the rating given for a customer's first delivered order
relate to repeat purchasing within 12 months?

### Finding:
Customers who gave higher ratings showed slightly higher
12-month repeat-purchase rates. The difference between the
lowest and highest rating groups was 0.55 percentage points.
Even among customers who gave five stars, only 3.49% made
another delivered purchase within the observation window.

These results show only a small difference in repeat-purchase
rates across rating groups. They do not establish that customer
satisfaction has no effect on repeat purchasing, and other
possible influences were not fully investigated.
*/

USE [Olist_Ecommerce_data];
DROP TABLE IF EXISTS #DeliveredOrders;

-- 1. Build one record per delivered order.
-- MAX(review_score), as each order has one consistent score.
 SELECT
    customer_unique_id,
    order_id,
    MIN(order_date) AS order_date,
    MAX(review_score) AS review_score
      INTO #DeliveredOrders
    FROM dbo.vw_olist_analysis
 WHERE customer_unique_id IS NOT NULL
    AND order_id IS NOT NULL
    AND order_date IS NOT NULL
    AND order_status = 'delivered'
 GROUP BY
    customer_unique_id,
    order_id;


-- 2. Identify each customer's first delivered order.
;WITH CustomerFirstOrder AS (
    SELECT
        customer_unique_id,
        order_id AS first_order_id,
        order_date AS first_order_date,
        review_score AS first_order_review_score,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_date, order_id
        ) AS rn
    FROM #DeliveredOrders
),

FirstOrders AS (
    SELECT
        customer_unique_id,
        first_order_id,
        first_order_date,
        first_order_review_score
    FROM CustomerFirstOrder
    WHERE rn = 1
),

-- 3. Keep customers whose first delivered order has a review and a full 12-month observation window.
EligibleCustomers AS (
    SELECT *
    FROM FirstOrders
    WHERE first_order_review_score BETWEEN 1 AND 5
      AND first_order_date <= DATEADD(
          MONTH,
          -12,
          (SELECT MAX(order_date) FROM #DeliveredOrders)
      )
),

-- 4. Determine whether each customer completed another delivered order within 12 months.
CustomerRetention AS (
    SELECT
        ec.customer_unique_id,
        ec.first_order_review_score,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM #DeliveredOrders AS d
                WHERE d.customer_unique_id = ec.customer_unique_id
                  AND d.order_id <> ec.first_order_id
                  AND d.order_date > ec.first_order_date
                  AND d.order_date <= DATEADD(
                      MONTH, 12, ec.first_order_date
                  )
            )
            THEN 1
            ELSE 0
        END AS returned_within_12_months
    FROM EligibleCustomers AS ec
)

-- 5. Comparing repeat-purchase rates by first-order rating.
SELECT
    first_order_review_score AS first_order_rating,
    COUNT(*) AS customers,
    SUM(returned_within_12_months) AS repeat_customers,
    CAST(
        100.0 * SUM(returned_within_12_months)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS repeat_purchase_rate_pct
FROM CustomerRetention
GROUP BY first_order_review_score
ORDER BY first_order_review_score;

DROP TABLE IF EXISTS #DeliveredOrders;
