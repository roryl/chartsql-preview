-- @chart: column
-- @title: Conversion Rate
-- @formats: percent
SELECT 
    Channel, 
    (SUM(CASE WHEN Status = 'Won' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS ConversionRate
FROM sample_data_full_new
WHERE Status IN ('Won', 'Lost')
GROUP BY Channel;
