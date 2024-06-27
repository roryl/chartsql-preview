-- @chart: column
-- @category: month
-- @formats: integer
    -- @title: New Deal Flow
SELECT 
    CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE) AS month,
    COUNT(*) AS new_deal_count
FROM 
    sample_data_full_new
WHERE 
    DateCreated BETWEEN '2015-01-01' AND '2019-12-31'
GROUP BY 
    CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE)
ORDER BY 
    month;