 /*
 TASK 02: Table_Joins
     Actions:
       - Identified and Joined tables required for each analysis.
       - Selected the relevant columns neded for Sales, Delivery, and Customer Satisfaction Informations.

     Key tables:
        - Orders (Joined)
        - Order items (Joined)
        - Customers (Joined)
        - Products (Joined)
        - Category Tranlation (Joined)
        - Sellers (Joined)
        - Payment (Joined)
        - Reviews (Joined)
*/ 

USE Olist_Ecommerce_data
SELECT distinct OD.order_id
     ,C.customer_id
        ,C.[customer_city]
             ,C.customer_state
              ,CN.product_category
                ,OI.price
              ,OD.order_purchase_timestamp
                ,OI.shipping_limit_date
                    ,OD.order_delivered_carrier_date
                ,OD.order_estimated_delivery_date
            ,OI.freight_value
        ,OP.payment_value
    ,OD.order_delivered_customer_date
    ,O.review_score
    ,OD.order_status
    ,S.seller_id
    ,S.seller_city
    ,S.seller_state
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