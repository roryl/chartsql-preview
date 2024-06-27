-- @chart: combo
-- @category: Month
-- @series: Originated, Churned, Ratio
-- @series-types: column, line
-- @formats: integer, integer, percent
-- @title: Originated To Churned
WITH monthly_accounts AS (
    SELECT 
        CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE)AS Month,
        `Account Name`
    FROM 
        sample_data_full_new
    GROUP BY 
        CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE),
        `Account Name`
),
account_status AS (
    SELECT 
        Month,
        `Account Name`,
        LAG(Month) OVER (PARTITION BY `Account Name` ORDER BY Month) AS PreviousMonth
    FROM 
        monthly_accounts
),
monthly_metrics AS (
    SELECT 
        Month,
        COUNT(CASE WHEN PreviousMonth IS NULL THEN 1 END) AS Originated,
        COUNT(CASE WHEN PreviousMonth = DATE_SUB(Month, INTERVAL 1 MONTH) THEN 1 END) AS Churned
    FROM 
        account_status
    GROUP BY 
        Month
)
SELECT 
    Month,
    Originated,
    Churned,
    CASE 
        WHEN Churned = 0 THEN NULL
        ELSE ROUND(Originated / Churned, 2)
    END AS Ratio
FROM 
    monthly_metrics
WHERE 
    Month >= '2012-01-01'
ORDER BY 
    Month;
