# Olist Order Funnel & Delivery CX Bottleneck Analysis (BigQuery SQL)

## Overview
This project defines an operational funnel (Order → Approved → Carrier → Delivered → Review) using the public Olist Brazilian e-commerce dataset (2016–2018).  
Without clickstream logs, the funnel is built from order status timestamps. The analysis identifies where delays originate and how those bottlenecks correlate with customer satisfaction (review scores).

## Business Problem
Olist operates nationwide in Brazil, where logistics complexity can create delivery delays that negatively impact customer experience (CX).  
Goal: quantify stage-level lead times, define “bad experience drop” as delivery delay, and diagnose bottlenecks by region to propose actionable improvements.

## Dataset
- Brazilian E-Commerce Public Dataset by Olist (Kaggle)
- Core tables used:
  - `orders`, `customers`, `order_reviews` (plus derived views)

## Tech Stack
- BigQuery (Standard SQL)
- GitHub (SQL scripts + documentation)

## Key Definitions
- **Funnel Stage Flags**
  - `has_purchase`, `has_approved`, `has_carrier`, `has_delivered`, `has_review`
- **Delivery Delay (Bad Experience Drop)**
  - `delay_days = DATE(delivered_ts) - estimated_delivery_date`
  - `is_delayed = 1` if `delay_days > 0` (only defined for delivered orders; otherwise NULL)

## Data Modeling (Views)
All analysis is built on order-level, 1-row-per-order views to avoid join explosion.

1. `v_reviews_1per_order`  
   - Aggregates `order_reviews` to one row per `order_id`.
2. `v_order_fact`  
   - Order-level fact view joining `orders` + `customers` + `v_reviews_1per_order`.
3. `v_funnel_flags`  
   - Creates funnel stage flags.
4. `v_delay_flags`  
   - Creates `delay_days` and `is_delayed`.
5. `v_lead_times`  
   - Decomposes lead times:
     - purchase→approved
     - approved→carrier (seller handoff)
     - carrier→delivered (shipping transit)
6. `v_lead_time_with_delay`  
   - Lead times joined with delay labels for analysis.

## Key Findings

### 1) Delayed orders show both early and late bottlenecks
Comparing delivered orders by delay status:

- Non-delayed orders:
  - avg approved→carrier: **2.503 days**
  - avg carrier→delivered: **7.932 days**
- Delayed orders:
  - avg approved→carrier: **5.424 days**
  - avg carrier→delivered: **27.875 days**

Interpretation: delayed orders start slower at the seller handoff stage, then the transit stage expands dramatically.

### 2) Seller handoff time correlates with customer satisfaction
Average review score by approved→carrier bucket:

- 0–1 days: **4.248**
- 2–3 days: **4.152**
- 4–7 days: **4.018**
- 8+ days: **3.592**
- NULL (no carrier stage): **1.627**

Interpretation: when seller handoff exceeds ~4 days, review scores deteriorate significantly.

### 3) Delay rates and bottlenecks vary by state (region-specific drivers)
State-level delay rate ranking (delivered orders, min 500 samples) showed highest delay rates in:
- **MA (17.4%)**, **CE (13.8%)**, **BA (12.2%)**, **RJ (12.1%)**, …

Delayed-orders-only bottleneck decomposition indicates different regional drivers:
- RJ/BA/RS: carrier→delivered dominates (30+ days on average in delayed orders)
- SP: seller handoff (approved→carrier) is unusually high in delayed orders (7+ days)

## Actionable Recommendations
- **Operations (SLA / Fulfillment):** enforce seller handoff SLAs (e.g., intervene at >4 days) and incentivize fulfillment programs for slow sellers.
- **Logistics Partnerships:** prioritize last-mile improvements or alternative carriers for high-delay states where transit time dominates (e.g., RJ/BA).
- **Product / CX:** region-sensitive delivery estimates to manage expectations and reduce review score drops.

## How to Reproduce
1. Upload Olist tables into BigQuery dataset: `olist_funnel_cx`
2. Run SQL scripts in order:
   - `sql/01_views_reviews.sql`
   - `sql/02_views_order_fact.sql`
   - `sql/03_views_funnel_delay.sql`
   - `sql/04_views_lead_times.sql`
3. Run analysis queries:
   - `sql/05_analysis_state_bottlenecks.sql`

## Repository Structure
- `sql/` : view definitions and analysis queries
- `README.md` : project narrative, results, and recommendations
