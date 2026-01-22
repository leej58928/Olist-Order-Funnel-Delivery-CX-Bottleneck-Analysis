-- 01_views_reviews.sql
-- Purpose: order_reviews can have multiple rows per order_id.
-- Create a 1-row-per-order review view.

CREATE OR REPLACE VIEW `olist-funnel-cx.olist_funnel_cx.v_reviews_1per_order` AS
SELECT
  order_id,
  MAX(CAST(review_score AS INT64)) AS review_score,
  MAX(TIMESTAMP(review_answer_timestamp)) AS review_answer_ts
FROM `olist-funnel-cx.olist_funnel_cx.order_reviews`
WHERE order_id IS NOT NULL
GROUP BY order_id;
