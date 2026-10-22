/*	
	TASK 04: DATA ENRICHMENT

  Actions:
    1- Performance Analysis: Added a Delivery Status column to provide more insight 
     into delivery performance by classifying orders as Early, On Time, or Late, while separately
     identifying orders that were not delivered.

    2. Calculated and included Delivery delay days column to provide insight into deviations from the estimated delivery date.
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
                THEN 'Early'
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