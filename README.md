# Olist E-Commerce Analytics
### Sales Performance, Delivery Reliability, Seller Handover & Repeat Purchasing

An end-to-end SQL Server and Power BI analytics project examining Olist’s revenue performance, customer acquisition, delivery reliability, seller handover discipline, customer satisfaction, and repeat purchasing.

**Key result:** Revenue grew 22.4% in 2018 versus 2017, but only 3.0% of the 93,358 customers with at least one delivered order made another delivered purchase. Delivery performance was strong overall at 91.9% on time, while late seller handover increased the likelihood of a late customer delivery approximately 4.7 times.

**Technical walkthrough:** See [`Documentation/technical_process.md`](Documentation/technical_process.md) for the full SQL workflow, validation queries, data-modelling decisions, DAX measures, and dashboard development process.

**Tools:** SQL Server · Power BI · DAX  
**Project focus:** Business and Operations Analytics  
**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---
## Table of Contents

- [Executive Summary](#executive-summary)
- [Business Problem](#1-business-problem)
- [Project at a Glance](#2-project-at-a-glance)
- [Key Findings](#3-key-findings)
- [Power BI Dashboard](#4-power-bi-dashboard)
- [Technical Approach](#5-technical-approach)
  - [Data Collection and Understanding](#data-collection-and-understanding)
  - [Data Preparation and Validation](#data-preparation-and-validation)
  - [SQL Analysis](#sql-analysis)
  - [Power BI and DAX](#power-bi-and-dax)
  - [Interpretation and Recommendations](#interpretation-and-recommendations)
- [Recommendations](#6-recommendations)
- [Limitations](#7-limitations)
- [Repository Structure](#8-repository-structure)
- [Dataset and Acknowledgements](#9-dataset-and-acknowledgements)
- [What This Project Demonstrates](#10-what-this-project-demonstrates)
- [How to Reproduce](#11-how-to-reproduce)
---

## Executive Summary

**Business question:**  
Is Olist’s revenue growth supported by reliable delivery operations, positive customer experience, and repeat purchasing?

**Headline finding:**  
Olist grew strongly through customer acquisition. Revenue increased by 22.4% in 2018, supported by 21.6% customer growth. However, repeat purchasing remained low: only 3.0% of customers with at least one delivered order made another delivered purchase within the observed period.

Delivery performance was strong overall, with 91.9% of delivered orders arriving on or before the estimated delivery date. Customer sentiment was also positive, with an average review score of 4.10/5 and 77.3% of reviews rated four or five stars.

The seller-handover analysis showed that orders handed to the courier after the seller’s shipping-limit date had a 26.19% late-delivery rate, compared with 5.58% for orders handed over on time. However, late seller handover accounted for only 22.35% of all late customer deliveries, indicating that courier transit, destination, and delivery-estimate accuracy also require investigation.

**Recommendation:**  
Prioritise customer re-engagement to convert first-time buyers into returning customers. In parallel, investigate regional delivery bottlenecks, beginning with Maranhão, and monitor seller handover discipline alongside courier transit performance.

![Olist E-commerce Analytics Overview Dashboard](Images/01_overview_dashboard.png)

---

## 1. Business Problem

Olist connects sellers with customers through an online marketplace. Revenue growth and customer acquisition are important, but they do not show whether customers return to purchase again or whether the operational journey from seller dispatch to customer delivery remains reliable.

This project examines sales trends, state-level performance, delivery outcomes, seller handover timing, customer reviews, and repeat purchasing to identify where the business performs well and where operational or commercial intervention may be valuable.

### Key business questions

- How are revenue, order volume, and customer numbers changing over time?
- Which states contribute most to revenue, orders, and seller activity?
- How reliably are orders delivered, and where are delays most concentrated?
- Does late seller handover increase the likelihood of a late customer delivery?
- What do customer reviews reveal about the shopping experience?
- What proportion of customers with at least one delivered order make another delivered purchase?
- Which commercial and operational areas should Olist prioritise?

---

## 2. Project at a Glance

| Metric | Result |
|---|---:|
| Analysis period | 15 September 2016 – 17 October 2018 |
| Last complete month for trend analysis | August 2018 |
| Distinct orders | 98,832 |
| Delivered orders | 96,478 |
| Distinct customers | 95,526 |
| Customers with at least one delivered order | 93,358 |
| Revenue | R$15.28M |
| On-time delivery rate | 91.9% |
| Late delivery rate | 8.1% |
| Average review score | 4.10/5 |
| Positive review share (4–5 stars) | 77.3% |
| Overall repeat-purchase rate | 3.0% |
| 12-month cohort repeat-purchase rate | 3.33% |

*Revenue, delivery, and repeat-purchase measures are based on delivered orders. The overall repeat-purchase rate is calculated among the 93,358 customers with at least one delivered order. The 12-month cohort rate uses a separate eligible population with a complete 12-month observation window.*

---

## 3. Key Findings

### Finding 1: Strong customer acquisition has not produced comparable repeat purchasing

Revenue grew by 22.4%, and the customer base grew by 21.6% in 2018 versus 2017. Year-over-year comparisons use matching date ranges to avoid comparing unequal periods.

Among the 93,358 customers with at least one delivered order, 2,801 customers—3.0%—made at least one additional delivered purchase. In the separate 12-month cohort analysis, 711 of 21,361 eligible customers—3.33%—made a subsequent delivered purchase within 12 months.

| Observation window | Eligible customers | Repeat customers | Repeat-purchase rate |
|---|---:|---:|---:|
| Within 3 months | 21,361 | 291 | 1.36% |
| Within 6 months | 21,361 | 463 | 2.17% |
| Within 12 months | 21,361 | 711 | 3.33% |

**Business implication:** Growth is currently acquisition-led rather than repeat-purchase-led. Olist has a large base of customers with completed purchases, creating a clear opportunity to encourage a second purchase through relevant recommendations, cross-sells, post-purchase communication, and loyalty incentives.

Customers who did not purchase again cannot be classified as churned. Olist is not a subscription platform, so there is no cancellation event that proves customer loss. The low repeat-purchase rate identifies a re-engagement opportunity rather than proving that customers have left.

**Recommended next step:** Segment first-time customers by product category, order value, delivery outcome, and review score. Test targeted re-engagement campaigns against a control group and measure incremental repeat purchases, average order value, and customer lifetime value.

### Finding 2: São Paulo is Olist’s core revenue market and largest re-engagement opportunity

São Paulo contributed 37.42% of the R$15.28 million in analysed revenue, approximately R$5.72 million. It also recorded 40,501 delivered orders, approximately 40,029 unique customers, 1,848 sellers, a 4.22/5 average review score, and a 5.9% late-delivery rate.

Despite strong customer ratings and delivery performance, São Paulo’s repeat-purchase rate was approximately 3.2%. This suggests that a positive first purchase experience alone may not be sufficient to drive another purchase.

**Business implication:** São Paulo offers the largest immediate opportunity to test customer re-engagement initiatives. Relevant product recommendations, cross-sell and upsell offers, post-purchase communication, and early loyalty incentives should be tested and measured against a control group.

### Finding 3: Delivery performance is strong overall but varies materially by state

The overall on-time delivery rate was 91.9%, while 8.1% of delivered orders arrived late. State-level results reveal important differences.

Maranhão recorded a 19.7% late-delivery rate, more than twice the overall rate, alongside an average review score of 3.78/5. This makes it the first state to investigate for delivery reliability.

São Paulo recorded a 5.9% late-delivery rate and a 4.22/5 average review score, but a repeat-purchase rate of approximately 3.2%. This reinforces that strong delivery performance and positive ratings alone do not guarantee repeat purchasing.

**Business implication:** Delivery performance should be monitored at state level rather than assessed only through a national average. Maranhão should be investigated first, focusing on late orders by seller, carrier, destination, and dispatch timing.

### Finding 4: Seller coverage is uneven across Brazil

São Paulo accounted for 1,848 of the 3,093 sellers in the analysis, approximately 59.7%. Sellers were based in 23 states, while customers were located across 27 states. This means four customer states had no sellers based in them.

**Business implication:** Customers in states without local sellers may depend on sellers based elsewhere, potentially increasing delivery distance, freight cost, and product-availability constraints. This represents a potential regional seller-coverage opportunity.

### Finding 5: Monthly revenue remained strong through August 2018

Monthly delivered-order revenue remained above R$950,000 in every complete month from January to August 2018. Revenue peaked at R$1.12M in May and eased to R$0.98M in August.

The August result reflected slightly fewer delivered orders and a lower average order value. August 2018 is the last complete month because orders placed after 29 August 2018 had not been delivered within the observation window.

**Business implication:** Monthly revenue should be monitored alongside delivered-order volume and average order value. If the lower level continues, investigate product mix, pricing, demand, and state-level performance.

### Finding 6: Late seller handover increases delivery risk but is not the main cause of late customer delivery

Among 96,473 delivered orders with complete delivery dates, 6,533 arrived after the estimated customer-delivery date.

Orders handed to the courier after the seller’s shipping-limit date had a 26.19% late-delivery rate, compared with 5.58% for orders handed over on time. This means late seller handover was associated with an approximately 4.7 times higher risk of late customer delivery.

However, late seller handover accounted for only 1,460 of the 6,533 late customer deliveries, or 22.35%. The remaining 5,073 late deliveries—77.65%—occurred even though the seller handed the order to the courier on time.

| Seller handover | Late customer deliveries | On-time customer deliveries | Late-delivery rate |
|---|---:|---:|---:|
| Late seller handover | 1,460 | 4,114 | 26.19% |
| On-time seller handover | 5,073 | 85,826 | 5.58% |

**Business implication:** Seller handover discipline should be monitored, particularly for sellers with repeated late handovers. However, improving seller handover alone would not resolve most late deliveries. Courier transit performance, destination, delivery distance, and estimated-delivery accuracy are likely to explain more of the overall late-delivery volume.

---

## 4. Power BI Dashboard

The report contains four pages: an executive overview followed by three detailed analysis pages.

### Overview Dashboard

![Overview Dashboard](Images/01_overview_dashboard.png)

Provides an executive-level summary across sales, delivery performance, customer satisfaction, and repeat purchasing.

**Purpose:**
- Present headline KPIs in one view.
- Summarise the main findings from the analysis.
- Provide a starting point for exploring the detailed dashboards.

**Key metrics displayed:**
- Revenue
- Delivered orders
- Customers with at least one delivered order
- Revenue growth
- On-time and late-delivery rates
- Average review score
- Overall repeat-purchase rate

### Sales Performance

![Sales Performance Dashboard](Images/02_sales_performance_dashboard.png)

Examines revenue, order volume, customer numbers, monthly trends, and state-level sales contributions.

**Questions explored:**
- How are revenue and customer numbers changing?
- Which states contribute most to sales?
- Which periods require further investigation?

### Delivery Performance

![Delivery Performance Dashboard](Images/03_delivery_performance_dashboard.png)

Evaluates on-time delivery, late deliveries, and differences in delivery performance across states.

**Questions explored:**
- What proportion of delivered orders arrived on time?
- Which states have elevated late-delivery rates?
- Where should logistics performance be investigated?

### Customer Satisfaction & Repeat Purchasing

![Customer Satisfaction and Repeat Purchasing Dashboard](Images/04_customer_satisfaction_dashboard.png)

Explores review scores, positive review share, and repeat purchasing.

**Questions explored:**
- How do customers rate their shopping experience?
- What share of reviews is positive?
- What proportion of customers with at least one delivered order make another delivered purchase?
- Do customer ratings and repeat purchasing show the same pattern?

---

## 5. Technical Approach

The project followed an end-to-end workflow: data exploration, table joins, cleaning and transformation, enrichment, final-table preparation, data-quality validation, Power BI modelling, DAX development, dashboard design, and SQL-to-Power BI reconciliation.

For the full technical walkthrough, including SQL query examples, validation evidence, data-model decisions, and dashboard development notes, see [`Documentation/technical_process.md`](Documentation/technical_process.md).

### Data collection and understanding

Imported the Olist CSV tables into SQL Server and explored row counts, identifiers, missing values, data types, and relationships between orders, customers, items, products, sellers, payments, and reviews.

### Data preparation and validation

Used SQL to join source tables, clean and transform fields, translate product categories, enrich the analytical dataset, prepare the final analytical view, and validate record counts and distinct identifiers.

The joins required particular care because the source tables represent different levels of detail. An order may contain multiple items and payment records, so a joined row count cannot be treated as a distinct order count.

### SQL analysis

Analysed sales trends, state-level performance, delivery outcomes, review scores, seller handover, and repeat purchasing. The repeat-purchase analysis used `customer_unique_id` and qualifying delivered orders to measure subsequent purchases within 3-, 6-, and 12-month observation windows.

The seller-handover analysis compared `shipping_limit_date`, `order_delivered_carrier_date`, and `order_delivered_customer_date` to distinguish seller dispatch timing from courier delivery performance.

### Power BI and DAX

Built interactive dashboards using KPIs, trend charts, state comparisons, and filters. Revenue was calculated once per distinct delivered `order_id`, preventing payment values repeated across item-level rows from being summed multiple times.

### Interpretation and recommendations

Compared findings across sales, delivery, seller handover, and customer analysis. Recommendations are framed as areas for investigation or controlled testing rather than claims of proven causation.

---

## 6. Recommendations

| Priority | Recommendation | Suggested first action | Success measure |
|---|---|---|---|
| High | Improve repeat purchasing | Segment customers with one delivered order and test targeted re-engagement campaigns | Overall repeat-purchase rate; 3-, 6-, and 12-month cohort rates |
| High | Improve seller handover discipline | Identify sellers with repeated late handovers and implement dispatch reminders and performance reviews | Late seller-handover rate and late-delivery rate |
| High | Investigate courier and route performance | Analyse late deliveries by courier, destination state, delivery distance, and estimated-delivery accuracy | Late-delivery rate, average delay, and on-time delivery rate |
| High | Investigate late delivery in Maranhão | Review late orders by seller, carrier, destination, and dispatch timing | Late-delivery rate and average delay |
| Medium | Understand geographic performance | Compare seller coverage, product availability, and demand across states | Revenue and order share by state |
| Medium | Monitor monthly revenue, order volume, and AOV | Separate changes in order volume, AOV, and product mix | Monthly revenue, orders, and AOV |
| Medium | Assess retention economics | Add margin, acquisition cost, and campaign cost data where available | Incremental repeat revenue and campaign ROI |

These are proposed next steps based on observed patterns; their impact would need to be tested using additional data or controlled experiments.

---

## 7. Limitations

- **Incomplete final period:** Orders were placed up to 17 October 2018, but the latest completed delivered order was placed on 29 August 2018. August 2018 is therefore the last complete month for monthly revenue, delivery, and trend analysis.
- **Historical coverage:** The dataset does not represent Olist’s current performance.
- **Observational analysis:** Relationships between delivery, review scores, seller handover, sales, and repeat purchasing do not establish causation.
- **Small regional samples:** Acre’s 80 delivered orders limit the reliability of its repeat-purchase rate as a benchmark.
- **Different data grains:** Joined rows may represent item-level combinations rather than unique orders, payments, or reviews. Aggregations must account for these relationships.
- **Revenue calculation:** Payment values in the joined analytical view can repeat across item rows. Revenue is calculated once per distinct delivered `order_id`, not by directly summing repeated values.
- **Review coverage:** Review scores reflect submitted reviews and may not represent all customers.
- **Repeat-purchase definitions:** The overall repeat-purchase rate and 12-month cohort rate use different populations and observation windows and should not be treated as interchangeable.
- **Date precision:** The prepared order date is stored as a date, not a timestamp. Same-day purchases cannot reliably be sequenced using that field alone.
- **Financial scope:** Revenue is not profit. Profitability, customer lifetime value, and campaign return cannot be established without additional cost and margin data.

---

## 8. Repository Structure

```text
olist-ecommerce-analytics/
│
├── Documentation/
│   ├── business_questions.md
│   ├── data_dictionary.md
│   └── dax_measures.md
│
├── Images/
│   ├── 01_overview_dashboard.png
│   ├── 02_sales_performance_dashboard.png
│   ├── 03_delivery_performance_dashboard.png
│   └── 04_customer_satisfaction_dashboard.png
│
├── PowerBI_Dashboards/
│   └── olist_ecommerce_analytics.pbix
│
├── SQL_Scripts/
│   ├── 01_data_exploration.sql
│   ├── 02_table_joins.sql
│   ├── 03_data_cleaning_and_transformation.sql
│   ├── 04_data_enrichment.sql
│   ├── 05_final_table_preparation.sql
│   ├── 06_data_quality_checks.sql
│   ├── 07_customer_retention.sql
│   └── 08_seller_handover_analysis.sql
│
└── README.md
```

The `Documentation/` folder contains the project’s business questions, data dictionary, and DAX measure documentation. The `SQL_Scripts/` folder contains the full SQL workflow, while `PowerBI_Dashboards/` contains the interactive Power BI report.

---

## 9. Dataset and Acknowledgements

**Dataset:** [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains anonymised historical e-commerce records covering orders, customers, sellers, products, payments, reviews, and logistics.

---

## 10. What This Project Demonstrates

This project demonstrates the use of SQL Server and Power BI to prepare data, validate key counts, analyse business performance, build dashboards, and translate findings into practical recommendations.

The focus is not only on reporting metrics, but also on understanding what they reveal, recognising where joins can distort results, distinguishing observed patterns from conclusions requiring further evidence, and connecting commercial performance with operational delivery behaviour.

---

## 11. How to Reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Import the required CSV files into SQL Server.
3. Run the SQL scripts in `SQL_Scripts/` in the following order:

```text
01_data_exploration.sql
02_table_joins.sql
03_data_cleaning_and_transformation.sql
04_data_enrichment.sql
05_final_table_preparation.sql
06_data_quality_checks.sql
07_customer_retention.sql
08_seller_handover_analysis.sql
```

4. Open the Power BI report in `PowerBI_Dashboards/olist_ecommerce_analytics.pbix`.
5. Update the data-source settings as required and refresh the model.
6. Review the dashboard pages and compare the results with the figures reported here.
