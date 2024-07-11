-- @chart: radar
-- @title: Radar Chart
-- @category: Channel
-- @series: Won_Sales
-- @subtitle: An basic example of a radar chart
SELECT 
Channel,
count(*) as Won_Sales 
FROM Sales as ChannelSales
WHERE Status = 'Won'
GROUP BY Channel
ORDER BY Won_Sales DESC;