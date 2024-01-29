-- @title: Auto Column
-- @subtitle: An example of an auto selected column chart
SELECT 
Channel,
count(*) as Won_Sales
FROM Sales
WHERE Status = 'Won'
GROUP BY Channel;