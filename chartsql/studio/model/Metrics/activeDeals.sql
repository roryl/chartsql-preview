-- @chart: pie
-- @title: Active Deals
SELECT 
    CASE 
        WHEN Status IN ('Prospecting', 'Qualification', 'Value Proposition', 'Negotiating') 
AND DATEDIFF('2021-02-21', DATE_ADD(DateCreated, INTERVAL 30 DAY)) > 0 THEN 'Active Deals'        WHEN Status IN ('Won', 'Lost') THEN 'Closed Deals'
    END AS deal_status,
    COUNT(*) AS deal_count
FROM 
    sample_data_full_new
GROUP BY 
    deal_status;