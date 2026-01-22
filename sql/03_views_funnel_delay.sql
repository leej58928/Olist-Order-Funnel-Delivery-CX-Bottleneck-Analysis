-- 03_views_funnel_delay.sql
-- Purpose: funnel flags + delivery delay label (bad experience)

CREATE OR REPLACE VIEW `olist-funnel-cx.olist_funnel_cx.v_funnel_flags` AS
SELECT
  order_id,
  order_status,
  purchase_ts,
  approved_ts,
  carrier_ts,
  delivered_ts,
  estimated_delivery_date,
  review_score,
  review_answer_ts,

  CASE WHEN purchase_ts IS NOT NULL THEN 1 ELSE 0 END AS has_purchase,
  CASE WHEN approved_ts IS NOT NULL THEN 1 ELSE 0 END AS has_approved,
  CASE WHEN carrier_ts IS NOT NULL THEN 1 ELSE 0 END AS has_carrier,
  CASE WHEN delivered_ts IS NOT NULL THEN 1 ELSE 0 END AS has_delivered,
  CASE WHEN review_score IS NOT NULL THEN 1 ELSE 0 END AS has_review
FROM `olist-funnel-cx.olist_funnel_cx.v_order_fact`;


CREATE OR REPLACE VIEW `olist-funnel-cx.olist_funnel_cx.v_delay_flags` AS
SELECT
  order_id,
  order_status,
  delivered_ts,
  estimated_delivery_date,

  CASE
    WHEN delivered_ts IS NULL THEN NULL
    ELSE DATE_DIFF(DATE(delivered_ts), estimated_delivery_date, DAY)
  END AS delay_days,

  CASE
    WHEN delivered_ts IS NULL THEN NULL
    WHEN DATE(delivered_ts) > estimated_delivery_date THEN 1
    ELSE 0
  END AS is_delayed
FROM `olist-funnel-cx.olist_funnel_cx.v_funnel_flags`;
