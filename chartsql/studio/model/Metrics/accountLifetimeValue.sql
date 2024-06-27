-- @chart: bar
-- @category: Account Name
-- @series: Estimated_Lifetime_Value
-- @formats: currency
WITH account_metrics AS (
    SELECT 
        `Account Name`,
        SUM(CAST(REPLACE(Amount, ',', '') AS DECIMAL(10, 2))) AS total_revenue,
        DATEDIFF('2021-02-21', MIN(DateCreated)) AS account_age_days,
        DATEDIFF(MAX(DateClosed), MIN(DateCreated)) AS active_period_days
    FROM 
        sample_data_full_new
    WHERE 
        Status = 'Won'
    GROUP BY 
        `Account Name`
),
account_projections AS (
    SELECT 
        `Account Name`,
        total_revenue,
        account_age_days,
        active_period_days,
        CASE 
            WHEN active_period_days > 0 THEN total_revenue / active_period_days * 365 * 3    
        END AS Estimated_Lifetime_Value
    FROM 
        account_metrics
)
SELECT 
    `Account Name`,
    ROUND(Estimated_Lifetime_Value, 2) AS Estimated_Lifetime_Value
FROM 
    account_projections

ORDER BY 
    Estimated_Lifetime_Value DESC
LIMIT 10;
