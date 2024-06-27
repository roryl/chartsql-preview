-- @chart: column
-- @category: status
-- @series: avg_time_to_close
-- @formats: decimal
-- @title: Time to Close
SELECT 
    CASE 
        WHEN Status IN ('Won', 'Lost') THEN Status
        ELSE 'All Deals'
    END AS Status,
    AVG(DATEDIFF(DateClosed, DateCreated)) AS avg_time_to_close
FROM 
    sample_data_full_new
WHERE 
    Status IN ('Won', 'Lost')
GROUP BY 
    CASE 
        WHEN Status IN ('Won', 'Lost') THEN Status
        ELSE 'All Deals'
    END
UNION ALL
SELECT 
    'All Deals' AS Status,
    AVG(DATEDIFF(DateClosed, DateCreated)) AS avg_time_to_close
FROM 
    sample_data_full_new
WHERE 
    Status IN ('Won', 'Lost')
ORDER BY 
    CASE 
        WHEN Status = 'All Deals' THEN 1
        WHEN Status = 'Won' THEN 2
        WHEN Status = 'Lost' THEN 3
    END;