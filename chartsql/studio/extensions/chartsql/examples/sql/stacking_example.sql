-- @chart: column
-- @title: Stacking - Example column chart with stacking
-- @groups: Month, Channel
-- @subtitle: An example column chart that has a single stack
-- @formats: currency
-- @series: Sales
-- @stacks: Channel
SELECT 
	TRUNC(date_closed, 'MONTH') as Month,
    Channel,
	sum(amount) as Sales
FROM sales
GROUP BY Month, Channel
ORDER BY Month ASC;