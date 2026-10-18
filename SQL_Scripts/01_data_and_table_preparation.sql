/*

TASK1.UNDERSTANDING THE DATA & TABLE PREPARATION ()

Things I will consider: 
    Some order_id records may 
           1. contain multiple items;
           2. not have any review_score, and will uncover any pattern behind it - Unsatisfied customer or what? analyis would tell us;
           3. have more than one review_score driven by each distinct items contained in it;
           4. be fulfilled by more than one seller when the order consists of distinctitems sold by different vendors.

What records do I consider Valid or Invalid?
           1. VALID: each unique order_id is tied to a customer_unique_id with their order_status field not NULL (empty).
           2. INVALID: Review_id and review_score with NULL (empty) values in their respective customer_id and order_id data field.
 
 */

 SELECT DISTINCT 
		 OD.customer_id,
		 O.order_id,
		 R.review_id,
		 R.review_score
FROM [dbo].[order_items_dataset] O
FULL JOIN [dbo].[order_reviews_dataset] R
ON O.order_id = R.order_id
FULL JOIN [dbo].[orders_dataset] OD
ON O.order_id = OD.order_id
WHERE OD.customer_id IS NULL
	OR O.order_id IS NULL
	OR R.review_id IS NULL
   
 /*
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
