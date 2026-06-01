USE retail_db;
GO

DROP TABLE IF EXISTS online_retail_clean;
DROP TABLE IF EXISTS online_retail_final;
DROP TABLE IF EXISTS rfm_result;

-- CLEAN DATA
SELECT 
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    TRY_CONVERT(float, Price) AS Price,
    Customer_ID,
    Country
INTO online_retail_clean
FROM online_retail_II
WHERE Quantity > 0
  AND Customer_ID IS NOT NULL
  AND TRY_CONVERT(float, Price) IS NOT NULL;


-- TẠO FINAL TABLE
SELECT *,
       Quantity * Price AS TotalAmount
INTO online_retail_final
FROM online_retail_clean;


-- TÍNH RFM + SEGMENT
WITH rfm AS (
    SELECT 
        Customer_ID,
        DATEDIFF(DAY, MAX(InvoiceDate), 
            (SELECT MAX(InvoiceDate) FROM online_retail_final)) AS Recency,
        COUNT(DISTINCT Invoice) AS Frequency,
        SUM(TotalAmount) AS Monetary 
    FROM online_retail_final
    GROUP BY Customer_ID
),
rfm_score AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_score,
        NTILE(5) OVER (ORDER BY Frequency)    AS F_score,
        NTILE(5) OVER (ORDER BY Monetary)     AS M_score 
    FROM rfm
),
rfm_combined AS (
    SELECT *,
        CAST(R_score AS VARCHAR) + 
        CAST(F_score AS VARCHAR) + 
        CAST(M_score AS VARCHAR) AS RFM_Code,
        R_score + F_score + M_score AS RFM_Total
    FROM rfm_score
)
SELECT *,
    CASE 
        -- VIP: cả 3 chiều đều cao
        WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4 THEN 'VIP'
        -- Loyal: mua thường xuyên, gần đây vẫn active
        WHEN R_score >= 3 AND F_score >= 4 THEN 'Loyal'
        -- New Customer: mới mua lần đầu, chưa có lịch sử
        WHEN R_score = 5 AND F_score <= 2 THEN 'New Customer'
        -- At Risk: từng mua nhiều nhưng đang rời xa
        WHEN R_score <= 2 AND F_score >= 3 AND M_score >= 3 THEN 'At Risk'
        -- Churn: lâu không mua, tần suất thấp
        WHEN R_score <= 2 AND F_score <= 2 THEN 'Churn'
        -- Potential: mua gần đây nhưng chưa thường xuyên
        WHEN R_score >= 4 AND F_score <= 2 THEN 'Potential'
        ELSE 'Others'
    END AS Segment
INTO rfm_result
FROM rfm_combined;

-- XEM KẾT QUẢ
SELECT TOP 10 * FROM rfm_result ORDER BY RFM_Total DESC;

-- PHÂN BỔ KHÁCH THEO SEGMENT
SELECT 
    Segment,
    COUNT(*) AS Total_Customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS Pct
FROM rfm_result
GROUP BY Segment
ORDER BY Total_Customers DESC;


-- DOANH THU THEO SEGMENT
SELECT 
    Segment,
    ROUND(SUM(Monetary), 0) AS Total_Revenue,
    ROUND(AVG(Monetary), 0) AS Avg_Revenue_Per_Customer
FROM rfm_result
GROUP BY Segment
ORDER BY Total_Revenue DESC;


-- TỔNG OVERVIEW
SELECT 
    COUNT(*)                 AS Total_Customers,
    ROUND(SUM(Monetary), 0)  AS Total_Revenue,
    ROUND(AVG(Recency), 0)   AS Avg_Recency_Days,
    ROUND(AVG(Frequency), 1) AS Avg_Frequency
FROM rfm_result;