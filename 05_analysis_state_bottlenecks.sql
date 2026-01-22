-- 05_analysis_state_bottlenecks.sql
-- Purpose: State-level delay rate ranking + bottleneck decomposition

-- Q1) State-level delay rate ranking (delivered orders only, min sample size)
SELECT
  vof.customer_state,
  COUNTIF(vof.delivered_ts IS NOT NULL) AS delivered_orders,
  COUNTIF(vof.delivered_ts IS NOT NULL AND v.is_delayed = 1) AS delayed_orders,
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(vof.delivered_ts IS NOT NULL AND v.is_delayed = 1),
      COUNTIF(vof.delivered_ts IS NOT NULL)
    ),
    3
  ) AS delayed_rate
FROM `olist-funnel-cx.olist_funnel_cx.v_lead_time_with_delay` AS v
LEFT JOIN `olist-funnel-cx.olist_funnel_cx.v_order_fact` AS vof
  ON v.order_id = vof.order_id
GROUP BY vof.customer_state
HAVING delivered_orders >= 500
ORDER BY delayed_rate DESC
LIMIT 15;


-- Q2) State-level bottleneck decomposition (delivered orders only)
SELECT
  vof.customer_state,
  COUNT(vof.order_id) AS orders,
  ROUND(AVG(v.approved_to_carrier_days), 3) AS avg_approved_to_carrier_days,
  ROUND(AVG(v.carrier_to_delivered_days), 3) AS avg_carrier_to_delivered_days,
  ROUND(AVG(v.delay_days), 3) AS avg_delay_days
FROM `olist-funnel-cx.olist_funnel_cx.v_lead_time_with_delay` AS v
LEFT JOIN `olist-funnel-cx.olist_funnel_cx.v_order_fact` AS vof
  ON v.order_id = vof.order_id
WHERE vof.delivered_ts IS NOT NULL
GROUP BY vof.customer_state
HAVING orders >= 500
ORDER BY avg_delay_days DESC;


-- Q3) Delayed orders only: bottleneck decomposition
SELECT
  vof.customer_state,
  COUNT(*) AS delayed_orders,
  ROUND(AVG(v.approved_to_carrier_days), 3) AS avg_approved_to_carrier_days_delayed,
  ROUND(AVG(v.carrier_to_delivered_days), 3) AS avg_carrier_to_delivered_days_delayed,
  ROUND(AVG(v.delay_days), 3) AS avg_delay_days_delayed
FROM `olist-funnel-cx.olist_funnel_cx.v_lead_time_with_delay` AS v
LEFT JOIN `olist-funnel-cx.olist_funnel_cx.v_order_fact` AS vof
  ON v.order_id = vof.order_id
WHERE vof.delivered_ts IS NOT NULL
  AND v.is_delayed = 1
GROUP BY vof.customer_state
HAVING delayed_orders >= 200
ORDER BY avg_delay_days_delayed DESC
LIMIT 15;
