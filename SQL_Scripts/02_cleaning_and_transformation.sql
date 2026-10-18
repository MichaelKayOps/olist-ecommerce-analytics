/*	

TASK2: DATA CLEANING & TRANSFORMATION
- Removed unwanted symbols and inconsistencies from the product_category column.
- Converted relevant datetime columns to DATE format, since the analysis focuses on dates
rather than specific timestamps.

*/

USE Olist_Ecommerce_data
SELECT c.customer_unique_id,
       C.[customer_city],
       C.customer_state,
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

	  ROUND  (OI.price,2) AS price
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
     ROUND      (OP.payment_value,2) AS payment_value,
