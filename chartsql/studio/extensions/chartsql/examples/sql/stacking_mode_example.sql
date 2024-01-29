-- @chart: area
-- @title: Stacking-mode - 100% normalizing a stacked chart
-- @groups: Month, Channel
-- @subtitle: An example area chart that is 100% stacked
-- @formats: currency
-- @series: Sales
-- @stacks: Channel
-- @stacking-mode: percent
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
    Channel,
	sum(amount) as Sales
FROM sales
GROUP BY Month, Channel
ORDER BY Month ASC;