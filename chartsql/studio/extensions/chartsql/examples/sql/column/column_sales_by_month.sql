-- @chart: column
-- @title: Column - Basic Column Chart
-- @subtitle: An example column chart showing sales by month
-- @formats: currency
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales
FROM sales
GROUP BY Month
ORDER BY Month ASC;