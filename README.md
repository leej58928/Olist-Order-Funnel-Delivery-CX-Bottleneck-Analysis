# Olist Order Funnel & Delivery CX Bottleneck Analysis (BigQuery SQL)

## Project Overview

This project analyzes 100K+ real e-commerce orders from the Brazilian marketplace Olist to understand where operational delays occur and how those delays translate into customer dissatisfaction.

Instead of relying on clickstream data, I designed a **status-based operational funnel** using real logistics timestamps. This allows delivery performance to be measured as a sequence of operational transitions rather than website behavior.

The goal is to identify bottlenecks that operations teams can directly act on and connect those bottlenecks to measurable customer experience impact.

---

## Business Problem

Marketplace logistics performance strongly influences customer trust. Delivery delays reduce satisfaction, increase complaints, and create long-term retention risk.

The central hypothesis:

**Delays during early fulfillment stages increase the probability of late delivery and lower review scores.**

This project tests that hypothesis by decomposing the order lifecycle into measurable stages and connecting operational latency with customer outcomes.

---

## Data Model

The analysis is performed entirely in BigQuery SQL using multi-table joins:

- **Orders table** – operational timestamps and order status
- **Customers table** – geographic segmentation
- **Reviews table** – customer satisfaction proxy

Because reviews can contain multiple rows per order, I constructed a 1-row-per-order analytical view to preserve correct aggregation and prevent double counting.

From this base, I built reusable analytical views:

- order-level fact table
- funnel stage flags
- delay definition (estimated vs actual delivery)
- stage-to-stage lead time decomposition

This structure mirrors how production analytics pipelines are organized.

---

## Analytical Approach

### 1. Status-based funnel construction

Each order is tracked through operational stages:

Purchase → Approval → Carrier Handoff → Delivery → Review

Funnel progression is inferred from timestamp availability rather than click logs. This transforms operational data into a measurable funnel.

---

### 2. Delivery delay definition

Delivery delay is defined as:

actual_delivery_date − estimated_delivery_date

This creates:

- `is_delayed` (binary risk flag)
- `delay_days` (severity metric)

Orders are then segmented into delayed vs non-delayed cohorts.

---

### 3. Lead time decomposition

To identify bottlenecks, the lifecycle is split into stage durations:

- Purchase → Approval
- Approval → Carrier (seller handoff)
- Carrier → Delivered (shipping transit)

Comparing lead times between delayed and non-delayed cohorts reveals where operational breakdown occurs.

---

### 4. Regional drill-down

Customer location is used to analyze whether delay risk is geographically concentrated rather than uniform across the system.

---

## Results

The analysis reveals two dominant patterns:

- Orders that become delayed show significantly longer seller handoff time before shipping begins
- Average review scores decline as seller handoff time increases
- Certain regions experience disproportionately higher delay rates
- Bottlenecks compound: once early stages slip, later stages degrade further

This confirms that operational latency is not random — it is structured and measurable.

---

## Key Insights & Actions

### Insight 1 — Seller handoff time is a CX risk lever

When the Approved → Carrier stage grows beyond a threshold, the probability of delay increases sharply and customer satisfaction declines.

**Action:**  
Treat seller handoff latency as a controllable SLA.  
Implement monitoring dashboards and escalation rules for high-latency vendors. Consider fulfillment support or penalty tiers for chronic offenders.

---

### Insight 2 — Logistics inefficiency is regionally concentrated

Delay risk is not evenly distributed. Some regions systematically underperform.

**Action:**  
Deploy targeted regional logistics interventions instead of global policy changes. Prioritize investment where delay density is highest.

---

### Insight 3 — Early delays compound downstream

Once early stages slip, later stages amplify the delay.

**Action:**  
Focus prevention efforts upstream. Early-stage correction has disproportionate downstream benefit.

---

## Business Impact

This framework enables:

- proactive SLA enforcement
- targeted regional optimization
- expectation management strategies
- measurable CX protection

The methodology transforms raw logistics timestamps into an operational decision system.

---

## Tools & Skills Demonstrated

BigQuery SQL • Analytical data modeling • Funnel analytics  
Lead-time decomposition • Operational performance measurement  
CX risk translation • Decision-oriented analytics
