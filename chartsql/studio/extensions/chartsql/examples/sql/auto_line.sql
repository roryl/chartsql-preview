-- @title: Auto Line - Auto Generated Date Line Chart
-- @subtitle: An example chart which is auto detected to be a line
-- @formats: currency
SELECT
TRUNC(date_closed, 'MONTH') as Month,
sum(amount) as Sales
FROM sales
GROUP BY Month
ORDER BY Month ASC;