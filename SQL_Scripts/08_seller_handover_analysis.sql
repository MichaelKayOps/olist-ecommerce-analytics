/*

Seller Handover and Customer Delivery Analysis
Project: Olist E-Commerce Analytics
Database: Olist_Ecommerce_data


Purpose:
This script examines whether late seller handover to the courier is
associated with late customer delivery.

Delivery stages:
1. Seller hands the order to the Olist courier.
2. Courier delivers the order to the customer.

Key dates:
- shipping_limit_date: Seller handover deadline.
- order_delivered_carrier_date: Actual seller-to-courier handover date.
- order_estimated_delivery_date: Estimated customer-delivery date.
- order_delivered_customer_date: Actual customer-delivery date.

Business rules:
- Only delivered orders are analysed.
- Orders must have valid shipping-limit, carrier-delivery,
  estimated-delivery, and customer-delivery dates.
- A late seller handover occurs when the carrier-delivery date is
  later than the shipping-limit date.
- A late customer delivery occurs when the customer-delivery date is
  later than the estimated-delivery date
*/

USE Olist_Ecommerce_data;
GO

/*
1. Seller handover and customer delivery outcome
This query classifies each delivered order by seller handover timing
and final customer-delivery outcome.
*/

SELECT
    CASE
        WHEN order_delivered_carrier_date > shipping_limit_date
            THEN 'Late seller handover'
        ELSE 'On-time seller handover'
    END AS seller_handover_status,

    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'Late customer delivery'
        ELSE 'On-time customer delivery'
    END AS customer_delivery_status,

    COUNT(DISTINCT order_id) AS delivered_orders

FROM dbo.vw_olist_analysis
WHERE order_status = 'delivered'
  AND order_delivered_carrier_date IS NOT NULL
  AND shipping_limit_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY
    CASE
        WHEN order_delivered_carrier_date > shipping_limit_date
            THEN 'Late seller handover'
        ELSE 'On-time seller handover'
    END,

    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 'Late customer delivery'
        ELSE 'On-time customer delivery'
    END

ORDER BY
    seller_handover_status,
    customer_delivery_status;

GO


/*
2. Late-delivery rate by seller handover status
  
This query calculates the customer late-delivery rate for orders with
late and on-time seller handover.
*/

SELECT
    CASE
        WHEN order_delivered_carrier_date > shipping_limit_date
            THEN 'Late seller handover'
        ELSE 'On-time seller handover'
    END AS seller_handover_status,

    COUNT(DISTINCT order_id) AS total_delivered_orders,

    COUNT(DISTINCT CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN order_id
    END) AS late_customer_deliveries,

    CAST(
        100.0 * COUNT(DISTINCT CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN order_id
        END)
        / COUNT(DISTINCT order_id)
        AS DECIMAL(5, 2)
    ) AS late_delivery_rate_pct

FROM dbo.vw_olist_analysis
WHERE order_status = 'delivered'
  AND order_delivered_carrier_date IS NOT NULL
  AND shipping_limit_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY
    CASE
        WHEN order_delivered_carrier_date > shipping_limit_date
            THEN 'Late seller handover'
        ELSE 'On-time seller handover'
    END

ORDER BY
    seller_handover_status;
GO

  
/*
3. Share of late customer deliveries caused by late seller handover
  
This query shows how many late customer deliveries followed a late
seller handover and how many occurred despite an on-time handover.
*/

SELECT
    CASE
        WHEN order_delivered_carrier_date > shipping_limit_date
            THEN 'Late seller handover'
        ELSE 'On-time seller handover'
    END AS seller_handover_status,

    COUNT(DISTINCT order_id) AS late_customer_deliver
