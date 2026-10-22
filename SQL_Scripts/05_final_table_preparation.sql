/*
TASK 05: DATA TABLE PREPARATION
  - Created view table for the final data testing and analysis.
*/

CREATE VIEW vw_olist_analysis AS
 SELECT DISTINCT 
       C.customer_unique_id,
       C.[customer_city],
       C.customer_state,
       OD.order_id,
  REPLACE
              (CN.product_category,'_',' ') AS product_category,
      CAST(ROUND (OI.price,2) AS DECIMAL(10,2)) AS price,
    CAST
                (OD.order_purchase_timestamp AS DATE) AS order_date,
                S.seller_id,
                S.seller_city,
                S.seller_state,
      CAST(ROUND   (OI.freight_value,2) AS DECIMAL(10,2)) AS freight_value,
    CAST
                  (OI.shipping_limit_date AS DATE) AS shipping_limit_date,
    CAST
                  (OD.order_delivered_carrier_date AS DATE) AS order_delivered_carrier_date,
    CAST
                  (OD.order_estimated_delivery_date AS DATE) AS order_estimated_delivery_date,
    CAST          
                  (OD.order_delivered_customer_date AS DATE) AS order_delivered_customer_date,
       CAST(ROUND  (OP.payment_value,2) AS decimal(10,2)) AS payment_value,OD.order_status,
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
CASE 
     WHEN
       OD.order_delivered_customer_date > OD.order_estimated_delivery_date
                THEN DATEDIFF(DAY,OD.order_estimated_delivery_date,OD.order_delivered_customer_date)
     WHEN 
       OD.order_delivered_customer_date IS NULL
                THEN 0
                    ELSE 0
END AS delivery_delay_days, O.review_score, O.review_id
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
                    ON P.product_category_name = CN.Portugues
WHERE OD.order_status != 'unavailable' 
 
 /*    
     NOTE: 611 rows of record were eliminated from the table containing orders with 'unavailable'
                 order status. These orders lacked key information needed for the analysis.
                 This ensures the analysis is based on more complete and actionable orders.
 */
