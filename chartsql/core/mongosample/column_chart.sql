-- @chart: column
-- @mongodb-query: {"collection":"sales","find":{"match":{"Status":"Lost" },"projection":{"Amount":1,"DateClosed":1,"Name":1},"sort":{},"limit":0,     "skip":0}}
SELECT
strftime('%Y-%m-01', DateClosed) as MonthStart,
sum(Amount) as Amount
FROM sales
GROUP BY MonthStart
ORDER BY MonthStart asc;