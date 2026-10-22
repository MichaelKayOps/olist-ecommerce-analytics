/*

TASK 01. Exploring and Understanding the Data

Things I will consider:
    Some order_id records may:
           1. contain multiple items;
           2. not have a review_score, and I will uncover any patterns behind this—unsatisfied customers, or something else? The analysis would tell us;
           3. have more than one review_score, driven by each distinct item contained in the order;
           4. be fulfilled by more than one seller when the order consists of distinct items sold by different vendors.

What records do I consider valid or invalid?
           1. VALID: Each unique order_id is tied to a customer_unique_id, and its order_status field is not NULL (empty).
           2. INVALID: Review_id and review_score have NULL (empty) values in their respective customer_id and order_id data fields.
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
;
