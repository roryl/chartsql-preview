-- @chart: bar
-- @category: Account Name
-- @series: Remaining_Lifetime_Value
-- @formats: currency
WITH account_metrics AS (
    SELECT 
        `Account Name`,
        MAX(DateClosed) AS last_transaction_date,
        SUM(CAST(REPLACE(Amount, ',', '') AS DECIMAL(10, 2))) AS total_revenue,
        COUNT(*) AS transaction_count,
        DATEDIFF('2021-02-21', MIN(DateCreated)) AS account_age_days
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
        transaction_count,
        total_revenue / account_age_days * 365 AS yearly_revenue,
        GREATEST(0, 1095 - account_age_days) AS remaining_days 
    FROM 
        account_metrics
    WHERE 
        account_age_days > 0
)
SELECT 
    `Account Name`,
    ROUND((yearly_revenue * remaining_days / 365), 2) AS Remaining_Lifetime_Value
FROM 
    account_projections
ORDER BY 
    Remaining_Lifetime_Value DESC
LIMIT 10;
