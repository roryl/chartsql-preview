-- @chart: column
-- @title: Directive Comments
-- @subtitle: An example of commenting out a directive
-- @formats: currency
-- @series: Sales
-- //@baselines: Sales
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales
FROM sales
GROUP BY Month
ORDER BY Month ASC;