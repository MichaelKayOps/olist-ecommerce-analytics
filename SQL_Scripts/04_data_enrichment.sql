/*	
	
## Task 04: Data Enrichment

### Actions

**1. Added a Delivery Status column**

Created a derived `Delivery Status` column to classify orders according to their recorded delivery outcome.

- **On Time:** The order was delivered on or before the estimated delivery date.
- **Late:** The order was delivered after the estimated delivery date.
- **Not Delivered:** The `order_delivered_customer_date` field is NULL, indicating that no customer-delivery date is recorded in the dataset.

Orders without a recorded delivery date were classified separately because their delivery timeliness could not be assessed. This includes orders that were still processing, had been shipped but had no recorded customer-delivery date, or were cancelled.

**2. Added a Delivery Delay Days column**

Created a derived `Delivery Delay Days` column to measure lateness relative to the estimated delivery date.

- **Zero days:** The order was delivered on or before the estimated delivery date.
- **Positive values:** The number of days the order arrived after the estimated delivery date.
- **No negative values:** Early deliveries were assigned zero rather than recorded as negative delays.

### Purpose

These derived fields distinguish orders with confirmed delivery dates from those without recorded customer delivery, quantify late deliveries, and support comparisons of delivery performance across periods and customer locations.
*/

USE Olist_Ecommerce_data
SELECT c.customer_unique_id,
       C.[customer_city],
       C.customer_state,
CASE 
     WHEN    
            OD.order_status IN('canceled','processing','unavailable') 
                THEN 'Not Delivered'
     WHEN
            OD.order_delivered_customer_date IS NULL
                THEN 'Not Delivered'
     WHEN    
            OD.order_delivered_customer_date < OD.order_estimated_delivery_date 
                THEN 'On Time'
     WHEN  
            OD.order_delivered_customer_date = OD.order_estimated_delivery_date
                THEN 'On Time'
     WHEN        
            OD.order_delivered_customer_date > OD.order_estimated_delivery_date
                THEN 'Late'
                    ELSE 'Unknown'
     END AS delivery_status,
  
  -- Delivery delay days calculation.
       CASE 
          WHEN
            OD.order_delivered_customer_date > OD.order_estimated_delivery_date
                THEN DATEDIFF(DAY,OD.order_estimated_delivery_date,OD.order_delivered_customer_date)
          WHEN 
            OD.order_delivered_customer_date IS NULL
                THEN NULL
                    ELSE 0
      END AS delivery_delay_days,
      
REPLACE
        (CN.product_category,'_',' ') AS 
		     product_category,
         OI.price,
CAST
                (OD.order_purchase_timestamp AS date) AS order_date,
CAST
                (OI.shipping_limit_date AS date) AS shipping_limit_date,
CAST
                (OD.order_delivered_carrier_date AS date) AS order_delivered_carrier_date,
CAST
                (OD.order_estimated_delivery_date AS date) AS order_estimated_delivery_date,
						
				
--	3- Standardised price, frieght and payment columns with the relevant data figures.
	  ROUND  (OI.price,2) AS price,
CAST
                (OD.order_purchase_timestamp AS DATE) AS order_date,
CAST
                (OI.shipping_limit_date AS DATE) AS shipping_limit_date,
CAST
                (OD.order_delivered_carrier_date AS DATE) AS order_delivered_carrier_date,
CAST
                (OD.order_estimated_delivery_date AS DATE) AS order_estimated_delivery_date,
CAST          
           (OD.order_delivered_customer_date AS DATE) AS order_delivered_customer_date,
     ROUND   (OI.freight_value,2) AS freight_value,
     ROUND      (OP.payment_value,2) AS payment_value
FROM 	 
           [dbo].[orders_dataset] OD   
    LEFT JOIN 
          [Olist_Ecommerce_data].[dbo].[order_reviews_dataset] O
                      ON OD.order_id = O.order_id
    LEFT JOIN 
          [dbo].[order_items_dataset] OI
                        ON OD.order_id = OI.order_id
    LEFT JOIN
          [dbo].[products_dataset] P
                        ON OI.product_id = P.product_id
    LEFT JOIN 
          [dbo].[order_payments_dataset] OP
                        ON OI.order_id = OP.order_id
    LEFT JOIN 
          [dbo].[customers_dataset] C
                        ON OD.customer_id = C.customer_id
    LEFT JOIN 
          [dbo].[sellers_dataset] S
                        ON OI.seller_id = S.seller_id
    LEFT JOIN 
          [dbo].[product_category_translation] CN   
                        ON P.product_category_name = CN.Portugues;
