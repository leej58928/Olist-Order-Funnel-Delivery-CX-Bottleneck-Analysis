# E-commerce Order Funnel & Delivery Bottleneck Analysis (SQL)

## Key Results

- Seller handoff time (Approval → Carrier) is the **strongest predictor of delivery delay**  
- Orders with longer seller handoff time show significantly higher delay risk  
- Delivery delays are directly associated with **lower customer review scores**, indicating measurable CX impact  
- Delay risk is **not evenly distributed** — certain regions consistently show higher delay rates  
- Operational delays are not random — they are **systematic and measurable across fulfillment stages**

---

## Project Overview

This project analyzes 100K+ real e-commerce orders from the Olist marketplace to identify where operational delays occur and how they impact customer satisfaction.

Instead of relying on clickstream data, this analysis models the order lifecycle as a **status-based operational funnel**, using real logistics timestamps to measure performance across fulfillment stages.

The goal is to identify **actionable operational bottlenecks** and connect them to measurable customer experience outcomes.

---

## Business Question

Which stages of the order fulfillment process drive delivery delays, and how do those delays impact customer satisfaction?

---

## Approach

- Transformed raw multi-table data into a **1-row-per-order analytical dataset** to ensure accurate aggregation  
- Built a status-based funnel using operational timestamps instead of behavioral logs  
- Defined delivery delay as the gap between estimated and actual delivery dates  
- Decomposed lead times across fulfillment stages to identify bottlenecks  
- Compared delayed vs non-delayed orders to isolate operational risk factors  

---

## Data Model

The analysis is implemented in BigQuery using multiple joined tables:

- Orders (timestamps and order lifecycle)  
- Customers (geographic segmentation)  
- Reviews (customer satisfaction proxy)  

To ensure correct aggregation, a **1-row-per-order fact table** was constructed, preventing duplication from multi-review records.

---

## Analytical Framework

### 1. Funnel Construction
Order lifecycle modeled as:

Purchase → Approval → Carrier → Delivery → Review  

Each stage is inferred from timestamp availability.

---

### 2. Delay Definition

- `delay_days = actual_delivery_date − estimated_delivery_date`  
- `is_delayed` (binary flag)  

Orders are segmented into delayed vs non-delayed cohorts.

---

### 3. Lead Time Decomposition

The fulfillment process is split into:

- Purchase → Approval  
- Approval → Carrier (**seller handoff**)  
- Carrier → Delivered (**shipping transit**)  

This decomposition isolates where delays originate.

---

### 4. Regional Analysis

Customer location is used to identify geographic concentration of delay risk.

---

## Key Insights

**1. Seller handoff is the primary operational bottleneck**  
Seller handoff time (Approval → Carrier) is the main driver of delivery delays and is strongly associated with lower customer satisfaction.

**2. Delay risk is regionally concentrated**  
Certain states consistently underperform, indicating localized logistics inefficiencies rather than system-wide issues.

**3. Early delays compound downstream**  
Once early stages are delayed, total delivery time increases disproportionately.

---

## Business Implications

- Monitor and enforce SLA on seller handoff time  
- Implement escalation rules for high-latency vendors  
- Apply targeted regional logistics improvements instead of global fixes  
- Focus on early-stage intervention to prevent downstream delays  

---

## Tools

- BigQuery SQL (data modeling, joins, analytical views)  
