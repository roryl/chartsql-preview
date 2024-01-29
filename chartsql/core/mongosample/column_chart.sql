-- @chart: column
-- @mongodb-query: {"collection":"sales","find":{"match":{"Status":"Lost" },"projection":{"Amount":1,"DateClosed":1,"Name":1},"sort":{},"limit":0,"skip":0}}
SELECT
TRUNC(DateClosed, 'MONTH') AS DateClosed,
sum(Amount) as Amount
FROM sales
GROUP BY TRUNC(DateClosed, 'MONTH')
ORDER BY TRUNC(DateClosed, 'MONTH') asc;