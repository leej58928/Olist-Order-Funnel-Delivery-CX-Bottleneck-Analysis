# E-commerce Order Funnel & Delivery Bottleneck Analysis (SQL)

## Dashboard Preview
<img width="1216" height="794" alt="image" src="https://github.com/user-attachments/assets/45c9eff5-93c4-45a4-8b70-b809ebff5b4c" />


## Project Overview
This project analyzes 100K+ real e-commerce orders from the Olist marketplace to understand how delivery delays impact customer satisfaction and how delay risk varies across regions.

Instead of relying on clickstream data, this analysis models the order lifecycle as a status-based operational funnel using real logistics timestamps. The goal is to identify where delays occur and how they translate into measurable customer experience outcomes.

The analytical dataset was built using SQL and further explored through a dashboard to analyze customer experience impact.

---

## Business Question
How do delivery delays affect customer satisfaction, and how does delay risk vary across fulfillment stages and geographic regions?

---

## Key Results

- Delivery delays are strongly associated with lower customer review scores, indicating clear customer experience impact.
- Delay risk is not evenly distributed — certain regions consistently show higher delay rates.
- The relationship between delays and satisfaction is not uniform. Some regions maintain relatively high review scores despite longer delivery times, suggesting additional factors beyond delivery speed.
- While all stages contribute to total lead time, early-stage delays (especially seller handoff) tend to propagate downstream and increase overall delivery time.

---

## Approach

- Transformed raw multi-table data into a 1-row-per-order analytical dataset to ensure accurate aggregation
- Built a status-based funnel using operational timestamps instead of behavioral logs
- Defined delivery delay as the gap between estimated and actual delivery dates
- Decomposed lead times across fulfillment stages to identify bottlenecks
- Compared delayed vs non-delayed orders to isolate operational risk factors
- Extended analysis to customer satisfaction and regional performance patterns

---

## Data Model

The analysis is implemented in BigQuery using multiple joined tables:

- Orders (timestamps and lifecycle)
- Customers (geographic segmentation)
- Reviews (customer satisfaction proxy)

A 1-row-per-order fact table was constructed to prevent duplication from multi-review records and ensure aggregation accuracy.

---

## Analytical Framework

### 1. Funnel Construction
Order lifecycle modeled as:

Purchase → Approval → Carrier → Delivery → Review

Each stage is inferred from timestamp availability.

---

### 2. Delay Definition

```
delay_days = actual_delivery_date − estimated_delivery_date
is_delayed = delay_days > 0
```

Orders are segmented into delayed vs non-delayed cohorts.

---

### 3. Lead Time Decomposition

The fulfillment process is split into:

- Purchase → Approval  
- Approval → Carrier (seller handoff)  
- Carrier → Delivered (shipping transit)  

This decomposition isolates where delays originate.

---

### 4. Regional Analysis

Customer location is used to identify geographic concentration of delay risk and variation in customer satisfaction.

---

## Key Insights

### 1. Delivery delays directly impact customer experience
Orders delivered late show significantly lower review scores, confirming that delivery performance is a key driver of customer satisfaction.

### 2. Delay impact varies by region
Some regions maintain relatively stable customer satisfaction despite delays, indicating that expectations, service quality, or other contextual factors influence perception.

### 3. Delay risk is structurally concentrated
Certain states consistently exhibit higher delay rates, suggesting localized operational inefficiencies rather than random variation.

### 4. Early-stage delays propagate downstream
Seller handoff time (Approval → Carrier) contributes significantly to early delays, which compound into longer total delivery times.

---

## Business Implications

- Monitor and enforce SLA on seller handoff time  
- Implement escalation rules for high-latency vendors  
- Apply targeted regional logistics improvements instead of global fixes  
- Focus on early-stage intervention to prevent downstream delays  
- Consider regional differences in customer expectations when evaluating performance  

---

## Tools

- BigQuery SQL (data modeling, joins, analytical views)
- Tableau (dashboard visualization & interaction)
