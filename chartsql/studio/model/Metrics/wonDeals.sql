-- @chart: bar
-- @title: Won Deals
-- @category: Channel
SELECT 
    Channel, 
    COUNT(ID) AS WonDeals
FROM sample_data_full_new
WHERE Status = 'Won'
GROUP BY Channel;
