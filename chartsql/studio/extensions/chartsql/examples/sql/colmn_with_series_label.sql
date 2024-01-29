-- @chart: column
-- @title: Series Labels - Label at Top of Series
-- @subtitle: An example column chart with a series label above the top
-- @formats: currency
-- @series-labels: top
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales
FROM sales
-- Select just 1 year so that the labels are not too cluttered
WHERE year(date_closed) = 2017
GROUP BY Month
ORDER BY Month ASC;