/*
TASK5: DATA QUALITY CHECKS
  1- Quality Test
     #- Invalid Date Relationships: Checked for orders where the customer delivery
      date occurred before the order was purchaed, which would be an invalid record.(RESULT: PASS)

     #- Checked that Every delivered order has a customer_id. Orders that don't would be 
      flagged an Invalid record.(RESULT: PASS - Non found without a customer_id) 
*/	 

	SELECT (*)
    FROM     [dbo].[vw_olist_analysis]
  WHERE order_delivered_customer_date < order_date
        OR    (order_status = 'delivered'
       AND   customer_id IS NULL)
	
	/*
  	#- NULL Values Check: I expect NULL values only in shipping/delivery date fields where the
corresponding event did not occur; all other key analytical fields should not contain NULL values.
(RESULT: PASS - No NULL values found in the key analytical columns)
    
 */

SELECT 
   SUM 
      (CASE 
          WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
   SUM
    (CASE 
        WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
   SUM
    (CASE 
        WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
   SUM
    (CASE 
        WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
   SUM
    (CASE 
        WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score,
   SUM
    (CASE 
        WHEN product_category IS NULL THEN 1 ELSE 0 END) AS null_category,
   SUM
        (CASE 
    WHEN delivery_status IS NULL THEN 1 ELSE 0 END) AS null_delivery_status
FROM [dbo].[vw_olist_analysis]
;


/*	 
	    2- Quantity Test
        #- Total number of VALID records:
             Expected total = 106,581
             Result: PASS - 106,581 COUNTED
     
        #- Number of unique orders: 
           Expected total = 99,441
           Result: PASS - 99,441 COUNTED

        #- Total Unique customers between 2016 to 2018
             Expected total = 96,096
             Result: PASS - 96,096 COUNTED
*/

USE [Olist_Ecommerce_data]
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_unique_id) AS Total_Unique_customers,
    COUNT(DISTINCT order_id) AS unique_orders
 FROM [dbo].[vw_olist_analysis]

/*

1. Orders with cancelled, processing and delivered order status all have a
    payment_value. Therefore, I must factor this in my calculations.
	
    
  2.  611 rows eliminated from the table containing orders with an 'unavailable'
                 order status. These orders lacked key information needed for the analysis.
                 This ensures the analysis is based on more complete and actionable orders.
*/
 
