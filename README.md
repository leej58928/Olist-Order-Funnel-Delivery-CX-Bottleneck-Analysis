# Olist Order Funnel & Delivery CX Bottleneck Analysis (BigQuery SQL)

## Overview
This project analyzes 100K+ real e-commerce orders from Olist (Brazilian marketplace) to understand where operational delays occur in the order lifecycle and how those delays translate into customer dissatisfaction.  
Unlike web analytics funnels that rely on clickstream logs, this work defines a **status-based operational funnel** using real order timestamps (purchase → approval → carrier handoff → delivery → review). The core objective is to identify bottlenecks that are actionable for operations (Ops) teams and measurable in terms of customer outcomes.

## Business Problem
In marketplace logistics, delivery experience is a major driver of customer satisfaction. When delivery reliability degrades, customer reviews tend to drop and customer trust weakens—ultimately creating downstream retention risk.  
The hypothesis behind this project is:

**Delays in early fulfillment stages (especially seller handoff) increase delivery delay probability and reduce review scores.**

To validate this, I measured lead times between each stage, defined delivery delay against the estimated delivery date, and examined how operational latency correlates with review outcomes across regions.

## Data
This analysis uses publicly available Olist datasets (orders, customers, and reviews). The work is performed in **BigQuery SQL** by building order-level analytical views:

- `orders`: order status and timestamp fields for each stage
- `customers`: customer location fields (state/city) for segmentation
- `order_reviews`: review score and timestamps for satisfaction proxy

Because review data can contain multiple rows per order, a 1-row-per-order view is created to model satisfaction at the order level.

## Approach
The project follows a production-style workflow: define an analytical grain, build reusable views, validate row counts and missingness, and only then run analysis queries.

1) **Order-level fact table**  
I created an order-level “fact” view by joining orders, customers, and deduplicated review signals. This view becomes the single source of truth for downstream funnel and lead-time analysis.

2) **Status-based funnel construction**  
Using timestamp availability, I generated flags indicating whether an order successfully reached each stage (purchased → approved → carrier → delivered → reviewed). This replicates a funnel without click logs by using operational transitions.

3) **Delay definition (Estimated vs Actual)**  
Delivery delay is defined as the difference between the **estimated delivery date** and the **actual delivered date**. This produces:
- `is_delayed` (0/1)
- `delay_days` (number of days late)

4) **Lead-time bottleneck analysis**  
I computed stage-to-stage lead times:
- purchase → approval
- approval → carrier (seller handoff latency)
- carrier → delivered (shipping transit time)

Then I compared average lead times between delayed and non-delayed cohorts and examined how lead-time buckets relate to review scores.

## Results (What the data showed)
Two patterns were consistently visible:

- **Delayed deliveries have much longer seller handoff time.**  
Orders that ended up delayed showed significantly higher average `approved_to_carrier_days` and dramatically higher `carrier_to_delivered_days` compared to non-delayed orders, indicating bottlenecks compound once the early stage slips.

- **Customer satisfaction drops as seller handoff time increases.**  
When the Approved → Carrier stage exceeded a week, average review scores noticeably declined. This suggests that “late handoff” is not just an ops problem—it is a CX risk that can be measured and prioritized.

## Key Insights & Actions (Decision-oriented)
### Insight 1 — Early-stage seller handoff is a CX risk lever
When the seller handoff time (Approved → Carrier) grows, orders become much more likely to be delayed and reviews decline.  
**Action:** Treat seller handoff latency as a controllable SLA. Create monitoring and escalation rules (e.g., alerts when handoff exceeds a threshold) and consider interventions such as vendor coaching, penalties, or fulfillment assistance for high-latency sellers.

### Insight 2 — Logistics problems are not uniform across regions
Delay rates vary meaningfully by customer state, showing that delivery risk is geographically concentrated.  
**Action:** Prioritize region-specific operational improvements (carrier capacity, fulfillment routing, or expectation management) rather than applying one global policy. Use region dashboards to focus resources where delay rates are systematically higher.

## Tools & Skills Demonstrated
- BigQuery SQL (CTEs, joins, conditional logic, aggregations)
- Analytical data modeling (order-level fact table + reusable views)
- Funnel analysis without clickstream logs (status-based funnel)
- Operational analytics: lead-time decomposition and delay definition
- Translating metrics into actionable ops + CX recommendations
