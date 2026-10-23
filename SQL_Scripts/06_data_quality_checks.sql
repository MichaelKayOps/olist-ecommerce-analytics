/*
 ## TASK 06: DATA QUALITY CHECKS

   ### 1- Quality Test
         i-  Invalid Date Relationships: Checked for orders where the customer delivery
          date occurred before the order was purchaed, which would be an invalid record.(RESULT: PASS)

         ii- Checked that Every delivered order has a customer_id. Orders that don't would be 
          flagged an Invalid record.(RESULT: PASS - Non found without a customer_id) 
*/	

SELECT *
    FROM     Olist_Ecommerce_data.dbo.vw_olist_analysis
  WHERE order_delivered_customer_date < order_date
        OR    (order_status = 'delivered'
       AND   customer_unique_id IS NULL)

/*
  	     iii- NULL Values Check: I expect NULL values only in shipping/delivery date fields where the
          corresponding event did not occur; all other key analytical fields should not contain NULL values.
          (RESULT: PASS - No NULL values found in the key analytical columns)    
*/

SELECT
   SUM 
      (CASE 
          WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
   SUM
    (CASE 
        WHEN [customer_unique_id] IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
   SUM
    (CASE 
        WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
   SUM
    (CASE 
        WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value,
   SUM
    (CASE 
        WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score,
   SUM
    (CASE 
        WHEN product_category IS NULL THEN 1 ELSE 0 END) AS null_category,
   SUM
        (CASE 
    WHEN delivery_status IS NULL THEN 1 ELSE 0 END) AS null_delivery_status
FROM Olist_Ecommerce_data.dbo.vw_olist_analysis
;


/*	 
	   ### 2- Quantity Test
             i- Total number of VALID records:
                 Expected total = 106,354
                 Result: PASS - 106,354 COUNTED
     
             ii- Number of unique orders: 
                 Expected total = 98,832
                 Result: PASS - 98,832 COUNTED

             iii- Total Unique customers between 2016 to 2018
                 Expected total = 95,526
                 Result: PASS - 95,526 COUNTED
*/

SELECT
    COUNT(*) AS total_record,
    COUNT(DISTINCT customer_unique_id) AS Total_Unique_customers,
    COUNT(DISTINCT order_id) AS Total_unique_orders
 FROM Olist_Ecommerce_data.dbo.vw_olist_analysis
 ;


/*
      ### Additional Observations

 i-  Missing payment values: 174 records had no payment_value, mostly from cancelled, invoiced, shipped or created orders. 
   These were retained for the incomplete-order analysis. One delivered order was also missing its payment value; 
   it arrived 36 days late and received a review score of 1. It was retained for delivery and customer satisfaction analysis.

 ii- Missing product categories: 1,727 records had no product category. These were retained for the overall analysis, although the missing values may limit product-category analysis.
      
iii- Orders with cancelled, processing and delivered order status all have a
        payment_value. Therefore, I must factor this in my calculations.	 
*/

-- check for Number of delivered orders with null payment value.
    SELECT
	    COUNT(DISTINCT order_id) AS delivered_orders_with_null_payment_value
    FROM Olist_Ecommerce_data.dbo.vw_olist_analysis
	    WHERE order_status = 'delivered'
	    AND [payment_value] IS NULL
;

-- Key data on the delivered orders with null payment value.
    SELECT
		order_id
		freight_value,
		    payment_value,
		        order_status,
		          order_delivered_customer_date,
		        delivery_status,
		    delivery_delay_days,
		    review_score
    FROM Olist_Ecommerce_data.dbo.vw_olist_analysis
	    WHERE order_status = 'delivered'
	    AND [payment_value] IS NULL
;

-- All orders with null payment value.
 SELECT
	order_id,
	    order_status,
	     payment_value
     FROM Olist_Ecommerce_data.dbo.vw_olist_analysis
	    WHERE [payment_value] IS NULL
;


/*
    ### Repeat Customer Count check: 
       Result confirms only 2,801 out of 93,358 customers with completed orders placed more than one order from 2016 to 2018.
*/

SELECT
     COUNT(*) AS total_repeat_customers
FROM ( 
    SELECT customer_unique_id
FROM Olist_Ecommerce_data.[dbo].[vw_olist_analysis]
     WHERE order_status = 'delivered'
     AND customer_unique_id IS NOT NULL
 GROUP BY customer_unique_id
HAVING 
     COUNT(DISTINCT order_id) > 1)
     AS RepeatCustomers;
