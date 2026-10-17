# Olist E-Commerce Analytics
### Sales Growth, Delivery Performance & Customer Retention

An end-to-end data analytics project exploring sales performance, delivery operations, customer satisfaction, and repeat purchasing in the Olist Brazilian e-commerce marketplace.

**Tools:** SQL Server · Power BI · DAX · Excel  
**Project type:** Business and Operations Analytics  
**Dataset:** Brazilian E-Commerce Public Dataset by Olist

---

## 1. Business Problem

Olist connects sellers with customers through an online marketplace. Revenue growth and customer acquisition are important, but they do not show whether the business is retaining customers or maintaining reliable delivery as demand increases.

This project investigates whether Olist’s sales growth is supported by strong delivery performance, positive customer experience, and repeat purchasing.

### Key business questions

- How are revenue, order volume, and customer numbers changing over time?
- Which states contribute the most revenue, orders, and sellers?
- How reliably are orders delivered, and where are delays most common?
- What does customer review data reveal about the shopping experience?
- How many customers make subsequent purchases, and what does this reveal about retention?
- Where should the business focus its next improvement efforts?

---

## 2. Project at a Glance

| Metric | Result |
|---|---:|
| Total orders | 98,832 |
| Total customers | 95,526 |
| Total revenue | R$16.28M |
| On-time delivery rate | 91.9% |
| Late delivery rate | 8.1% |
| Average review rating | 4.10/5 |
| Positive review share (4–5 stars) | 77.3% |
| Overall repeat-purchase rate | ~3.0% |

*The overall repeat-purchase rate and the 12-month cohort repeat rate use different definitions and denominators.*

---

## 3. Key Findings

### Finding 1: Revenue growth is currently driven more by acquisition than repeat purchasing

Revenue grew by 22.1% in 2018 versus 2017, while the customer base grew by 21.6%.

However, repeat purchasing remained low. Among 21,361 customers with enough observed time to make another purchase, only 711 customers—or 3.33%—made a subsequent delivered purchase within 12 months.

| Observation window | Eligible customers | Repeat customers | Repeat rate |
|---|---:|---:|---:|
| Within 3 months | 21,361 | 291 | 1.36% |
| Within 6 months | 21,361 | 463 | 2.17% |
| Within 12 months | 21,361 | 711 | 3.33% |

**Business implication:**  
Olist has an opportunity to increase customer lifetime value by better understanding and engaging first-time buyers. The result does not prove permanent churn, but it suggests that acquisition alone may be sustaining much of the platform’s growth.

**Recommended next step:**  
Segment first-time buyers by product category, order value, delivery outcome, and review score. Then test a targeted re-engagement campaign against a control group.

### Finding 2: São Paulo dominates marketplace activity

São Paulo (SP) contributed 37.47% of the total R$16.28 million revenue, equivalent to approximately R$6.10 million.

The state also recorded:

- 40,501 delivered orders.
- Approximately 40,029 unique customers.
- 1,848 sellers out of 3,093 sellers across the 27 states in my analysis.
- An average review rating of 4.22/5.
- A late-delivery rate of 5.9%.
- An overall repeat-customer rate of approximately 3.2%.

São Paulo's large customer base, high seller concentration, and strong sales contribution make it a useful reference point for understanding marketplace performance.

I also investigated possible reasons for its leading position using external research. São Paulo's large population and urbanisation provide relevant context for its market size. However, the analysis does not isolate how much each factor contributes to revenue.

Despite its strong sales performance, customer satisfaction, and relatively low late-delivery rate, São Paulo's repeat-customer rate remained low.

**Business implication:** Strong operational performance and positive reviews may not be enough on their own to encourage repeat purchases. Olist should investigate other factors, including product selection, customer needs, pricing, and the experience between purchases.

### Finding 3: Delivery performance varies considerably by state

The overall on-time delivery rate was 91.9%, with 8.1% of orders delivered late. However, the national average hides important regional differences.

| State | Delivered orders | Average rating | Late delivery rate | Repeat-customer rate |
|---|---:|---:|---:|---:|
| São Paulo (SP) | 40,501 | 4.22 | 5.9% | 3.2% |
| Acre (AC) | 80 | 4.06 | Not reported here | 5.2% |
| Maranhão (MA) | 717 | 3.78 | 19.7% | Not reported here |
| Overall | — | 4.10 | 8.1% | Approximately 3.0% |

Maranhão recorded a late-delivery rate more than twice the overall rate, alongside the lowest average rating among these three states.

Acre had the highest repeat-customer rate of the three, but it recorded only 80 delivered orders. Its small sample makes the result less reliable as a basis for wider conclusions.

São Paulo, meanwhile, combined a 4.22 average rating with a 5.9% late-delivery rate, yet its repeat-customer rate was only 3.2%.

**Business implication:** Delivery improvements should be targeted at regions with clear operational problems, while retention should be investigated separately. The figures suggest that delivery and satisfaction alone do not fully explain repeat purchasing. They do not prove that delivery performance has no influence on retention.

### Finding 4: Seller concentration may help explain São Paulo's sales lead

São Paulo accounted for approximately 59.7% of the sellers in the analysis, with 1,848 of the 3,093 sellers distributed across 27 states.

This concentration coincided with the state's leading share of orders and revenue. External research on population and urbanisation also provided context for why São Paulo represents such a large market.

However, these relationships do not establish that seller concentration caused the state's revenue advantage. Population, urbanisation, product availability, customer demand, and other factors may also contribute.

**Business implication:** Olist should monitor its geographic concentration and investigate whether seller availability, product range, and customer demand explain differences in performance across states.

### Finding 5: Revenue declined over several consecutive months in 2018

Monthly revenue declined from May to August 2018. Across the three month-over-month changes in this period, revenue declined by an average of 4.02% per month.

This decline should be investigated alongside order volume, average order value, product-category mix, and seasonality. A four-month decline does not by itself establish a long-term downward trend.

**Business implication:** The business should examine whether the decline was associated with changes in order volume, average order value, product-category performance, or seasonality before deciding on corrective action.

A short period of declining revenue does not, by itself, establish a long-term downward trend.

---

## 4. Dashboard Overview

The Power BI report is organised into three pages, each designed to answer a different set of business questions.

### 1. Sales Performance

![Sales Performance Dashboard](images/sales-dashboard.png)

This page examines revenue, order volume, customer numbers, monthly sales trends, and state-level contributions.

It helps identify where sales are concentrated, how performance changes over time, and whether growth is consistent across regions.

**Key questions answered:**
- How much revenue does the marketplace generate?
- How are revenue and customer numbers changing?
- Which states contribute most to sales?
- Are there periods of declining revenue that require further investigation?

### 2. Delivery Performance

![Delivery Performance Dashboard](images/delivery-dashboard.png)

This page evaluates delivery reliability and compares performance across states.

It highlights the overall on-time delivery rate, late deliveries, and regional differences that may require operational attention.

**Key questions answered:**
- What proportion of orders arrives on time?
- Which states have the highest late-delivery rates?
- Where should delivery performance be investigated further?

### 3. Customer Satisfaction & Retention

![Customer Satisfaction and Retention Dashboard](images/customer-dashboard.png)

This page examines customer review ratings, positive review share, and repeat purchasing.

It brings customer feedback and purchasing behaviour into the same business discussion while keeping their limitations in view.

**Key questions answered:**
- How do customers rate their shopping experience?
- What proportion of reviews is positive?
- How many customers make subsequent purchases?
- Does strong satisfaction necessarily coincide with a high repeat-customer rate?

---

## 5. Technical Approach

I used SQL Server to prepare and analyse the data, then Power BI to communicate the results through interactive dashboards.

### Step 1: Data collection and import

I obtained the Brazilian E-Commerce Public Dataset by Olist from Kaggle and imported the CSV tables into SQL Server.

The dataset contains related information about orders, customers, sellers, products, payments, reviews, and delivery.

### Step 2: Data understanding

Before joining the tables, I explored their structure and checked:

- Row counts and distinct identifiers.
- Missing values and duplicate records.
- Relationships between orders, customers, products, sellers, and reviews.
- The level of detail represented by each table.

This helped me understand where joins could multiply rows and distort the results.

### Step 3: Data cleaning and preparation

I reviewed inconsistent fields, missing values, date columns, data types, and category labels.

I also considered the appropriate level of detail for the analysis. For example, an order may contain multiple items or involve multiple sellers. Joining such tables without accounting for their relationships can duplicate order-level values.

I therefore checked record counts and distinct order identifiers before relying on joined data for analysis.

### Step 4: Data quality checks

I used SQL queries to validate record counts, inspect missing values, check duplicates, and compare results before and after joins.

I paid particular attention to ensuring that order-level revenue and customer counts were not overstated by duplicated records.

### Step 5: SQL analysis

I used SQL to investigate sales performance, delivery outcomes, regional differences, customer satisfaction, and repeat purchasing.

The repeat-purchase cohort analysis used customers' first delivered purchase and measured qualifying subsequent delivered purchases within 3-, 6-, and 12-month windows.

### Step 6: Power BI visualisation

I connected the prepared data to Power BI, created measures with DAX, and designed three dashboard pages.

The report uses KPIs, trend charts, state comparisons, and filters to make the findings easier to explore.

### Step 7: Interpretation and recommendations

I compared findings across the three analytical areas, used external research to add context where appropriate, and translated the results into business questions and practical recommendations.

---

## 6. Recommendations

| Priority | Recommendation | Owner | First action | Success measure |
|---|---|---|---|---|
| High | Improve repeat purchasing | Marketing / CRM | Segment first-time buyers by category, order value, delivery outcome, and review score | 3-, 6-, and 12-month repeat-purchase rate |
| High | Investigate late delivery in Maranhão | Logistics / Operations | Review late orders by carrier, seller, destination, and dispatch timing | Late-delivery rate and average delivery delay |
| Medium | Monitor geographic concentration | Commercial / Marketplace | Assess seller coverage, product availability, and demand outside São Paulo | Revenue and order share by state |
| Medium | Investigate May–August 2018 revenue decline | Commercial / Analytics | Separate changes in order volume, average order value, and product mix | Monthly revenue, orders, and AOV |
| Medium | Connect retention to financial outcomes | Analytics / Finance | Add margin, acquisition cost, and campaign cost data where available | Incremental repeat revenue and campaign ROI |
---

## 7. Limitations and Analytical Considerations

I considered the following limitations when interpreting the results:

- **Historical data:** The dataset covers an earlier period of Olist's operations. The findings should not be treated as a description of the current business.
- **Incomplete final year:** The dataset ends in October 2018. Year-over-year comparisons should use matching date ranges rather than comparing a partial year with a full year.
- **Observational analysis:** Relationships between delivery, ratings, revenue, and repeat purchasing do not establish causation.
- **Small regional samples:** Acre's 80 delivered orders make its repeat-customer rate less reliable as a benchmark.
- **Order-level duplication:** One order may contain multiple items or involve multiple sellers. Aggregations must respect the level of detail of the underlying data.
- **Review limitations:** Review ratings reflect customers who submitted reviews and may not represent every customer's experience.
- **Repeat-purchase definition:** The overall repeat-customer KPI and the 12-month cohort analysis use different populations and observation rules. They should not be compared as if they were the same metric.
- **Date precision:** The order date field does not provide a time of day. When multiple delivered orders for a customer occur on the same date, the sequence cannot be established reliably from the date alone. The cohort analysis therefore does not treat same-day orders as proof of a subsequent purchase.
- **Financial limitations:** Revenue is not profit. The dataset analysis does not establish customer lifetime value or the profitability of a retention campaign.

These limitations matter because they define what the analysis can support and where further investigation is needed.

---

## 8. Repository Structure

```text
olist-ecommerce-analytics/
│
├── README.md
│
├── sql/
│   ├── data_preparation.sql
│   ├── data_quality_checks.sql
│   ├── sales_analysis.sql
│   ├── delivery_analysis.sql
│   └── customer_retention_analysis.sql
│
├── powerbi/
│   ├── olist_ecommerce_dashboard.pbix
│   └── measures.md
│
└── images/
    ├── sales-dashboard.png
    ├── delivery-dashboard.png
    └── customer-dashboard.png
```

*The structure above is the intended organisation. Include only files that are actually present in the repository.*

---

## 9. Dataset and Acknowledgements

**Source:** [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains anonymised historical e-commerce records covering orders, customers, sellers, products, payments, reviews, and logistics.

External research was also used to provide context for regional differences in population and urbanisation. This context supports interpretation but does not independently prove the causes of the observed sales patterns.

---

## 10. What This Project Demonstrates

Through this project, I applied SQL and Power BI to a real-world-style business problem, from data preparation and quality checks to analysis, visualisation, and recommendations.

More importantly, I used the results to investigate questions that a business would need to answer: where revenue comes from, where delivery performance needs attention, and why customer acquisition may not be translating into repeat purchasing.

The aim was not simply to display metrics, but to understand what they reveal, what they do not prove, and what the business could investigate next.

---

## 11. How to Reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Import the CSV files into SQL Server.
3. Run the SQL scripts in the `sql/` folder in numerical or logical order.
4. Open `powerbi/olist_ecommerce_dashboard.pbix`.
5. Update the data-source path if required and refresh the model.
6. Review the dashboard pages and compare the results with the figures in this README.
