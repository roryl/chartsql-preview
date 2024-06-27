-- @chart: bar
-- @title: Lost Deals
-- @category: Channel
SELECT 
    Channel, 
    COUNT(ID) AS LostDeals
FROM sample_data_full_new
WHERE Status = 'Lost'
GROUP BY Channel;
