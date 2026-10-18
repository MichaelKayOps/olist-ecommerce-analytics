/*	
	
	TASK3: DATA ENRICHMENT

  Actions:
    1- Performance Analysis: Added a Delivery Status column to provide more insight 
into delivery performance by classifying orders as Early, On Time, or Late, while separately
identifying orders that were not delivered.

*/

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
  
  -- Calculated for Delivery delay days to provide insight into deviations from the estimated delivery date.
  
       CASE 
          WHEN
            OD.order_delivered_customer_date > OD.order_estimated_delivery_date
                THEN DATEDIFF(DAY,OD.order_estimated_delivery_date,OD.order_delivered_customer_date)
          WHEN 
            OD.order_delivered_customer_date IS NULL
                THEN NULL
                    ELSE 0
      END AS delivery_delay_days,	 

