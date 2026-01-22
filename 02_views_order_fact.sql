-- 02_views_order_fact.sql
-- Purpose: create order-level fact table (1 row per order_id)

CREATE OR REPLACE VIEW `olist-funnel-cx.olist_funnel_cx.v_order_fact` AS
SELECT
  o.order_id,
  o.order_status,

  TIMESTAMP(o.order_purchase_timestamp) AS purchase_ts,
  TIMESTAMP(o.order_approved_at) AS approved_ts,
  TIMESTAMP(o.order_delivered_carrier_date) AS carrier_ts,
  TIMESTAMP(o.order_delivered_customer_date) AS delivered_ts,
  DATE(o.order_estimated_delivery_date) AS estimated_delivery_date,

  c.customer_unique_id,
  c.customer_city,
  c.customer_state,

  r.review_score,
  r.review_answer_ts
FROM `olist-funnel-cx.olist_funnel_cx.orders` AS o
LEFT JOIN `olist-funnel-cx.olist_funnel_cx.customers` AS c
  ON o.customer_id = c.customer_id
LEFT JOIN `olist-funnel-cx.olist_funnel_cx.v_reviews_1per_order` AS r
  ON o.order_id = r.order_id;
