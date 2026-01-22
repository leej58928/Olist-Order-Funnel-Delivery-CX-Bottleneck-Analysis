-- 04_views_lead_times.sql
-- Purpose: lead time decomposition + join with delay label

CREATE OR REPLACE VIEW `olist-funnel-cx.olist_funnel_cx.v_lead_times` AS
SELECT
  order_id,
  order_status,
  review_score,
  estimated_delivery_date,
  delivered_ts,

  CASE
    WHEN purchase_ts IS NOT NULL AND approved_ts IS NOT NULL
      THEN DATE_DIFF(DATE(approved_ts), DATE(purchase_ts), DAY)
    ELSE NULL
  END AS purchase_to_approved_days,

  CASE
    WHEN approved_ts IS NOT NULL AND carrier_ts IS NOT NULL
      THEN DATE_DIFF(DATE(carrier_ts), DATE(approved_ts), DAY)
    ELSE NULL
  END AS approved_to_carrier_days,

  CASE
    WHEN carrier_ts IS NOT NULL AND delivered_ts IS NOT NULL
      THEN DATE_DIFF(DATE(delivered_ts), DATE(carrier_ts), DAY)
    ELSE NULL
  END AS carrier_to_delivered_days
FROM `olist-funnel-cx.olist_funnel_cx.v_funnel_flags`;


CREATE OR REPLACE VIEW `olist-funnel-cx.olist_funnel_cx.v_lead_time_with_delay` AS
SELECT
  lt.order_id,
  lt.approved_to_carrier_days,
  lt.carrier_to_delivered_days,
  d.delay_days,
  d.is_delayed,
  lt.review_score
FROM `olist-funnel-cx.olist_funnel_cx.v_lead_times` AS lt
LEFT JOIN `olist-funnel-cx.olist_funnel_cx.v_delay_flags` AS d
  ON lt.order_id = d.order_id;
