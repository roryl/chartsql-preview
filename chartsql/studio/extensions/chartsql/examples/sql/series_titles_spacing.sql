-- @chart: Line
-- @title: Series Title Spacing
-- @subtitle: Spacing on series titles is determined by underscores
-- @formats: currency
SELECT
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as total_sales_amount
FROM sales
GROUP BY Month
ORDER BY Month ASC;