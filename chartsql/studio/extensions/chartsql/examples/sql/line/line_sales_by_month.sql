-- @chart: Line
-- @title: Line - Simple Line Chart
-- @subtitle: An example line chart with a detected category and series
-- @formats: currency
SELECT
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales
FROM sales
GROUP BY Month
ORDER BY Month ASC;