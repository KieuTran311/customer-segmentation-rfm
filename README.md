# Customer Segmentation using RFM Model
Tools: SQL Server, Power BI

## The Business Problem

A common mistake in retail marketing is treating all customers the same - same email blast, same discount, same message sent to everyone. This wastes budget and misses the point entirely, because a customer who buys every week and spends $500 each time needs a completely different approach from someone who bought once two years ago and never came back.

The specific problem this project addresses: _"How do you allocate a limited marketing budget across thousands of customers when you have no systematic way to tell them apart?"_

RFM is the answer. Instead of guessing, you score every customer on three things: how recently they bought, how often they buy, and how much they spend, then group them into segments that actually mean something for business decisions.

## Dataset

Online Retail II dataset from Kaggle, real transaction data from a UK-based online retailer, 2009 to 2011. Around 1 million raw rows, each representing one line item from an invoice.

Fields: Invoice number, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country.

## What I Did

**Step 1: Data cleaning**

The raw data had several issues that would distort the analysis if left in:
- Negative quantities (cancelled orders): removed
- Rows with no Customer_ID: removed since RFM requires customer-level data
- Invalid prices: filtered using `TRY_CONVERT` to catch non-numeric values

After cleaning, calculated `TotalAmount = Quantity × Price` as the monetary value for each transaction.

**Step 2: Calculate RFM metrics per customer**

For each customer:
- Recency: days since last purchase (lower = more recent)
- Frequency: number of distinct invoices
- Monetary: total amount spent

**Step 3: Score each customer 1–5**

Used `NTILE(5)` window function to split customers into five equal groups per dimension. Higher score = better on that dimension. Each customer ends up with three scores (e.g. R=5, F=3, M=4) and a combined RFM_Total (max = 15).

**Step 4: Assign segments**

| Segment | Score Logic | What it means |
|---------|------------|---------------|
| VIP | R≥4, F≥4, M≥4 | High value, frequent, recent |
| Loyal | R≥3, F≥4 | Regular buyers still active |
| Potential | R≥4, F≤2 | Recent but low frequency |
| New Customer | R=5, F≤2 | Just made first purchase |
| At Risk | R≤2, F≥3, M≥3 | Used to be valuable, going quiet |
| Churn | R≤2, F≤2 | Inactive, low value |

**Step 5: Power BI dashboard**

Built a dashboard showing customer count per segment, revenue per segment, KPI cards for total customers, total revenue and average frequency. DAX used for calculated measures.

## Results

| Segment | Customers | % of Total | Total Revenue | Avg/Customer |
|---------|-----------|------------|---------------|-------------|
| Churn | 1,428 | 24.3% | $577,238 | $404 |
| Others | 1,393 | 23.7% | $1,220,608 | $876 |
| VIP | 1,271 | 21.6% | $12,062,615 | $9,491 |
| At Risk | 661 | 11.2% | $1,623,115 | $2,456 |
| Loyal | 625 | 10.6% | $1,834,419 | $2,935 |
| Potential | 314 | 5.3% | $154,462 | $492 |
| New Customer | 189 | 3.2% | $270,972 | $1,434 |
| Total | 5,881 | 100% | $17,743,429 | |

**The key finding:** VIP customers are only 21.6% of the base but generate $12M out of $17.7M total revenue, 68% of all revenue concentrated in roughly one in five customers. Meanwhile, Churn is the largest segment at 24.3%, meaning nearly a quarter of all customers have already gone quiet.

This pattern has a direct implication: if even a small portion of At Risk customers (avg $2,456 each) can be retained, the revenue impact is significant compared to spending the same budget trying to win back Churn customers (avg $404 each).

## What the Business Should Do Differently

VIP (21.6% of customers, 68% of revenue): These customers are the business. Losing one VIP ($9,491 avg) costs far more than retaining them.
Recommended actions: dedicated loyalty program, early access to new products, priority customer service. The goal is protection, not acquisition.

At Risk (11.2%, avg $2,456): Highest ROI segment to target with a win-back campaign. They have proven spending history, they just need a reason to come back. A personalized, time-limited offer (not a mass blast) is the right approach.

New Customer (3.2%, avg $1,434): Good potential based on initial spend. The first 30–60 days are make-or-break, a structured onboarding sequence (product recommendations, usage tips, follow-up) could meaningfully improve conversion to Loyal.

Potential (5.3%, avg $492): Bought recently but infrequently. Light-touch nudge campaigns and product recommendations could increase purchase frequency without heavy discounting.

Churn (24.3%, avg $404): At $404 average revenue, the cost of a win-back campaign likely exceeds the expected return for most of this segment. Better to let them go and redirect that budget toward At Risk and Potential.

## Files
```
├── rfm_query.sql        # Full SQL script
└── dashboard.pbix       # Power BI dashboard
```
