-- @chart: column
-- @title: Series - Basic chart
-- @subtitle: An example of explicitly defining the series
-- @series: Sales
-- @formats: currency
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales,
    sum(Profit) as Profit
FROM sales
GROUP BY Month
ORDER BY Month ASC;