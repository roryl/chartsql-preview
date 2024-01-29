-- @chart: bar
-- @title: Bar Chart With Formats
-- @subtitle: An example bar chart with formats
-- @formats: currency
SELECT 
Channel,
sum(Amount) as Total_Sales
FROM Sales
WHERE Status = 'Won'
GROUP BY Channel
ORDER BY Total_Sales DESC;