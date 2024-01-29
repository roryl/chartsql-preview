-- @chart: column
-- @title: Baselines - Single Baseline
-- @subtitle: An example column chart with a default average baseline
-- @baselines: Sales
-- @series: SALES
-- @formats: currency
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales
FROM sales
GROUP BY Month
ORDER BY Month ASC;