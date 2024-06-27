-- @chart: column
-- @formats: integer
-- @title: Active Accounts
SELECT 
    CAST(DATE_FORMAT(LAST_DAY(DateCreated), '%Y-%m-01') AS DATE) AS month,
    COUNT(DISTINCT `Account Name`) AS active_accounts
FROM 
    sample_data_full_new
WHERE 
    Status != 'Lost'
GROUP BY 
     CAST(DATE_FORMAT(LAST_DAY(DateCreated), '%Y-%m-01') AS DATE)
ORDER BY 
    month;