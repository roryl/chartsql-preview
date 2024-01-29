-- @chart: column
-- @title: Baselines - Multiple Baseline for one series
-- @subtitle: An example column chart showing sales by month
-- @formats: currency
-- @series: Sales
-- @baselines: Sales, Sales, Sales
-- @baseline-types: average, min, max
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales
FROM sales
GROUP BY Month
ORDER BY Month ASC;