# Customer Segmentation using RFM Model
Tools: SQL Server, Power BI

## What's this about

Most businesses treat all customers the same when it comes to marketing: same email blast, same promotion, same message. But a customer who bought last week and spends $500 each time is very different from one who bought once two years ago and never came back.

RFM is a straightforward way to tell these customers apart. Instead of guessing, you score every customer on three things: how recently they bought, how often they buy, and how much they spend. From there, you can group them into segments and decide where to actually focus your retention and marketing effort.

This project applies RFM segmentation to an e-commerce dataset using SQL Server for all the data work, and Power BI for the dashboard.

## Dataset

Online Retail II dataset from Kaggle, real transaction data from a UK-based online retailer covering 2009 to 2011. The raw data has around 1 million rows. Each row is one line item from an invoice, with fields for: Invoice number, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, and Country.

## What I did

Step 1: Data cleaning

The raw data had a few issues that needed fixing before any analysis:
- Negative quantities (these are cancellations, not real purchases) - removed
- Rows with no Customer_ID - removed, since RFM needs to be tied to a customer
- Invalid prices - filtered using `TRY_CONVERT` to catch any non-numeric values

After cleaning, I created a `TotalAmount` column (Quantity × Price) to use as the monetary value for each transaction.

Step 2: Calculate RFM metrics per customer

For each customer, I calculated:
- Recency: number of days between their last purchase and the most recent date in the dataset
- Frequency: count of distinct invoices (i.e. distinct purchase occasions)
- Monetary: total amount spent across all transactions

Step 3: Score each customer 1–5 on each dimension

I used `NTILE(5)` window function to split customers into five equal groups for each RFM dimension:
- R score: higher score = bought more recently
- F score: higher score = buys more often
- M score: higher score = spends more

Each customer ends up with three scores (e.g. R=5, F=3, M=4) and a combined total (RFM_Total, max = 15).

Step 4: Assign segments based on score combinations

| Segment | Score Logic | What it means |
|---------|------------|---------------|
| VIP | R≥4, F≥4, M≥4 | High value, buys often, bought recently |
| Loyal | R≥3, F≥4 | Regular buyers still active |
| Potential | R≥4, F≤2 | Recent but haven't bought much yet |
| New Customer | R=5, F≤2 | Just made their first purchase |
| At Risk | R≤2, F≥3, M≥3 | Used to be valuable, going quiet |
| Churn | R≤2, F≤2 | Haven't bought in a long time, low frequency |

Step 5: Power BI dashboard

Built a dashboard showing customer count per segment, revenue contribution per segment, and KPI cards for total customers, total revenue, and average order frequency. DAX used for the calculated measures.

## Results

| Segment | Customers | % of Total | Total Revenue | Avg Revenue/Customer |
|---------|-----------|------------|---------------|----------------------|
| Churn | 1,428 | 24.3% | $577,238 | $404 |
| Others | 1,393 | 23.7% | $1,220,608 | $876 |
| VIP | 1,271 | 21.6% | $12,062,615 | $9,491 |
| At Risk | 661 | 11.2% | $1,623,115 | $2,456 |
| Loyal | 625 | 10.6% | $1,834,419 | $2,935 |
| Potential | 314 | 5.3% | $154,462 | $492 |
| New Customer | 189 | 3.2% | $270,972 | $1,434 |
| Total | 5,881 | 100% | $17,743,429 | |

A few things stand out from these numbers:

"VIP customers punch way above their weight": They're only 21.6% of the customer base but generate $12M out of $17.7M total revenue, that's 68% of all revenue coming from roughly one in five customers. Keeping these customers happy should be the top priority.

"Churn is the largest segment": 1,428 customers (24.3%) have gone quiet. At $404 average revenue, most of them aren't worth a heavy win-back investment individually but collectively they represent a meaningful pool if even a fraction can be re-engaged.

"At Risk is worth watching": 661 customers who used to spend well ($2,456 average) are showing signs of dropping off. This is probably the highest-ROI segment to target with a re-engagement campaign. They've proven they'll spend, they just need a reason to come back.

## Recommendations

1. "Protect VIP customers": Priority service, early access to new products, loyalty rewards. The cost of losing one VIP customer ($9,491 avg) is much higher than the cost of keeping them.
2. "Run a win-back campaign for At Risk": Personalized outreach, maybe a time-limited offer. Their spending history makes them worth the effort.
3. "Nurture New Customers early". They average $1,434 which suggests good potential. A strong onboarding experience in the first 30-60 days could convert them into Loyal buyers.
4. "Don't over-invest in Churn": At $404 average, a mass re-engagement campaign is probably not worth it. Better to let them go and focus budget on At Risk and Potential.

## Files
```
├── rfm_query.sql       
└── dashboard.pbix
```
