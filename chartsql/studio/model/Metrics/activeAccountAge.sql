-- @chart: bar
-- @formats: integer
-- @title: Active Accounts Age
SELECT 
    `Account Name`,
    DATEDIFF(MAX(DateClosed), MIN(DateCreated)) AS active_account_age_days
FROM 
    sample_data_full_new
WHERE 
    Status != 'Lost'
GROUP BY 
    `Account Name`
ORDER BY 
    active_account_age_days DESC
LIMIT 10;
