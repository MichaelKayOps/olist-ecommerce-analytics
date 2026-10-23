 /*
 
## Task 02: Table Joins

### Actions
- Identified and joined the source tables required for the planned analyses.
- Selected relevant columns to support sales, delivery performance, and customer satisfaction analysis.
- Considered table relationships and differences in data grain to reduce duplication and preserve the accuracy of analytical measures.

### Tables Joined
- orders_dataset
- order_items_dataset
- customers_dataset
- products_dataset
- product_category_translation
- sellers_dataset
- order_payments_dataset
- order_reviews_dataset

### Outcome
Combined relevant information from the source tables into a structured dataset for subsequent data cleaning, transformation, validation, and analysis.

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
    , S.seller_state
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
