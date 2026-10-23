/*
## Task 01: Exploring and Understanding the Data

1. **Multiple items per order:** A single `order_id` may contain several items, each identified by an `order_item_id`. This affects the level of detail in the data and how order-level measures should be calculated.

2. **Missing customer reviews:** Some orders have no recorded `review_id` or `review_score`. These records were retained for relevant analyses because the absence of a review does not establish customer dissatisfaction. Further investigation would examine whether missing reviews show patterns associated with delivery performance, order status or other relevant factors.

### Preliminary Data Validity Checks

- Confirm that each `order_id` is associated with a `customer_unique_id` and has a recorded `order_status`.
- Identify review records that contain a `review_id` and `review_score` but have NULL values for both `customer_unique_id` and `order_id`. These unlinked records were excluded from analyses requiring a valid customer or order relationship.
- Investigate missing identifiers and potential duplication introduced by table joins.

**Note:** Orders without a recorded review were retained for relevant analyses. The absence of a review does not, by itself, indicate customer dissatisfaction.

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
