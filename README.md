# Customer Segmentation using RFM Model

Tools: SQL Server, Power BI

## What this is

I used the Online Retail II dataset (Kaggle) to practice RFM segmentation with SQL. The idea behind RFM: not every customer is worth the same to a business, so instead of sending the same email to everyone, you group customers by how recently they bought (Recency), how often (Frequency) and how much they spent (Monetary) and treat each group differently.

## About the data

- UK-based online retailer, transactions from 2009-2011
- Around 1 million rows
- Main columns I used: Invoice, Customer_ID, Quantity, Price, InvoiceDate

## What I did

- Cleaned the data first: dropped cancelled orders (negative Quantity), rows with no Customer_ID and rows where Price wasn't a valid number (`TRY_CONVERT` handled that)
- Made `TotalAmount = Quantity * Price`
- Calculated Recency (`DATEDIFF` from each customer's last purchase to the most recent date in the whole dataset), Frequency (`COUNT(DISTINCT Invoice)`) and Monetary (`SUM(TotalAmount)`) per customer
- Scored each of R/F/M into 5 buckets with `NTILE(5)`, I added `Customer_ID` as a tiebreaker in the `ORDER BY` to keep the `NTILE(5)` results consistent when values are tied.
- Used `CASE WHEN` on the three scores to assign a segment name (VIP, Loyal, At Risk, Churn, New Customer, Potential or Others if none of the rules fit)

### Checking whether the segments made sense

I ran a quick sanity check: average Recency/Frequency/Monetary per segment to see if e.g. VIP customers actually look like VIPs and not just some random group.

| Segment | Avg Recency (days) | Avg Frequency (orders) | Avg Monetary |
|---|---:|---:|---:|
| VIP | 18.8 | 17.1 | $9,355 |
| Loyal | 83.2 | 7.8 | $2,723 |
| At Risk | 358.3 | 5.6 | $2,515 |
| New Customer | 9.6 | 1.5 | $1,614 |
| Others | 126.0 | 2.6 | $861 |
| Potential | 36.5 | 1.4 | $492 |
| Churn | 458.0 | 1.3 | $437 |

VIP has the lowest Recency (bought most recently) and highest Frequency/Monetary, Churn is the opposite. If VIP had shown up with high Recency or low Monetary I'd know something was off in my CASE WHENlogic.

## What I found

| Segment | Customers | % of Customers | Revenue | % of Revenue |
|---|---:|---:|---:|---:|
| VIP | 1,293 | 22.0% | $12.10M | 68.2% |
| Loyal | 704 | 12.0% | $1.92M | 10.8% |
| At Risk | 616 | 10.5% | $1.55M | 8.7% |
| Others | 1,300 | 22.1% | $1.12M | 6.3% |
| Churn | 1,528 | 26.0% | $0.67M | 3.8% |
| New Customer | 161 | 2.7% | $0.26M | 1.4% |
| Potential | 279 | 4.7% | $0.14M | 0.8% |
| **Total** | **5,881** | **100%** | **$17.74M** | **100%** |

The thing that stood out most to me: VIP is only 22% of customers but brings in 68% of the revenue. It's not a perfect 80/20 split, but the concentration of revenue is still quite strong, and it's bigger than I expected before running the numbers.

Churn is the largest group by customer count (26%) but only accounts for 3.8% of revenue. This means many customers in this group have relatively low revenue compared with the other segments. At Risk customers still average $2,515 in revenue each, much closer to Loyal ($2,723) than to Churn ($437). This shows that At Risk customers still have relatively high value compared with Churn customers.

### About the "Others" segment

Others ended up being 22% of customers, which is a decent chunk. I checked and this isn't a bug - it's customers who just don't clearly match any of my 6 rules (e.g. someone with high Frequency but low Monetary and mediocre Recency doesn't fit VIP, Loyal, At Risk, or Churn as I defined them). This is just a limitation of doing segmentation with hand-written rules instead of something like clustering.

## Power BI

The dashboard has KPI cards (Total Customers, Total Revenue, Avg Spend), customer count by segment, revenue by segment and slicers for filtering.

## Things I'd be careful about saying

- These segments are based on rules I wrote, not a model, so "Others" existing is expected, not something wrong with the data
- The 80/20-like pattern is specific to this dataset and time period (2009-2011, UK retailer), so I wouldn't assume the same pattern holds everywhere
- I'm not making business recommendations here like spend more on VIP retention since that would need more context than what's in this dataset. I'm just describing the pattern I found


## Files

```text
├── rfm_query.sql
├── dashboard.pbix
```
