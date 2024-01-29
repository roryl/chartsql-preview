-- @chart: pie
-- @title: Pie - Basic Pie Chart
-- @subtitle: Pie chart of sales won by channel
SELECT
	channel,
	count(*) as TotalSales
FROM sales
WHERE status = 'Won'
GROUP BY channel
ORDER BY TotalSales DESC;