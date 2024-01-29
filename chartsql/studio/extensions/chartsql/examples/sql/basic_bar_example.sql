-- @chart: bar
-- @title: Bar Chart
-- @subtitle: An basic example of a bar chart
SELECT 
Channel,
count(*) as Won_Sales
FROM Sales
WHERE Status = 'Won'
GROUP BY Channel
ORDER BY Won_Sales DESC;