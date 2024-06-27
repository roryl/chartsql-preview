-- @chart: column
-- @formats: integer
-- @title: Churned Accounts
SELECT 
    CAST(DATE_FORMAT(DateClosed, '%Y-%m-01') AS DATE) AS month,
    COUNT(DISTINCT `Account Name`) AS churned_accounts
FROM 
    sample_data_full_new
WHERE 
    Status = 'Lost'
    AND DateClosed BETWEEN '2016-01-01' AND '2017-01-01'
GROUP BY 
        CAST(DATE_FORMAT(DateClosed, '%Y-%m-01') AS DATE)
ORDER BY 
    month;