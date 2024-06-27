-- @chart: pie
-- @title: Open Deals
SELECT 
    Status,
    COUNT(*) AS open_deals
FROM 
    sample_data_full_new
WHERE 
    Status IN ('Prospecting', 'Qualification')
GROUP BY 
    Status;