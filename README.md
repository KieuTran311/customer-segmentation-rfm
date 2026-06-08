# Customer Segmentation using RFM Model

Tools: SQL Server, Power BI

## Project Overview

This project applies the RFM framework to segment customers and analyze revenue contribution across different customer groups.

## Business Problem

The company has thousands of customers with different purchasing behaviors. Sending the same marketing campaign to every customer is often inefficient because high-value customers and inactive customers require different approaches. The goal of this project is to segment customers based on purchasing behavior and identify which groups contribute the most revenue and which groups are at risk of churning.

## Dataset

Online Retail II dataset from Kaggle.

- UK-based online retailer
- Transaction data from 2009-2011
- Around 1 million records
- Key fields: Invoice, Customer_ID, Quantity, Price, InvoiceDate, Country

## Technical Approach

### SQL Server

- Removed cancelled orders (`Quantity < 0`)
- Removed records with missing `Customer_ID`
- Used `TRY_CONVERT()` to filter invalid price values
- Created `TotalAmount = Quantity × Price`
- Calculated:
  - Recency using `DATEDIFF()`
  - Frequency using `COUNT(DISTINCT Invoice)`
  - Monetary using `SUM(TotalAmount)`
- Applied `NTILE(5)` to score each RFM dimension
- Used `CASE WHEN` to assign customer segments
- Used window functions to calculate segment-level percentages

### Power BI

- KPI cards for Total Customers, Total Revenue, and Average Spend
- Revenue contribution by segment
- Customer distribution by segment
- DAX measures for segment KPIs
- Interactive filtering using slicers

## Results

| Segment | Customers | % of Total | Total Revenue | Avg Revenue per Customer |
|---------|-----------|------------|---------------|--------------------------|
| VIP | 1,271 | 21.6% | $12.06M | $9,491 |
| Loyal | 625 | 10.6% | $1.83M | $2,935 |
| At Risk | 661 | 11.2% | $1.62M | $2,456 |
| Others | 1,393 | 23.7% | $1.22M | $876 |
| New Customer | 189 | 3.2% | $271K | $1,434 |
| Potential | 314 | 5.3% | $154K | $492 |
| Churn | 1,428 | 24.3% | $577K | $404 |
| Total | 5,881 | 100% | $17.74M | |

### Key Findings

- VIP customers represent 21.6% of customers but generate 68% of total revenue.
- Churn is the largest segment, accounting for 24.3% of customers.
- At Risk customers generate significantly more revenue per customer than Churn customers.
- Retaining At Risk customers may provide a higher return than running win-back campaigns for Churn customers.

## Recommendations

- Maintain loyalty programs and exclusive offers for VIP customers.
- Prioritize retention campaigns for At Risk customers.
- Develop onboarding campaigns for New Customers to increase repeat purchases.
- Use personalized recommendations to encourage Potential customers to purchase more frequently.
- Limit marketing spend on low-value Churn customers and focus resources on higher-value segments.

## Files

```text
├── rfm_query.sql
└── dashboard.pbix
