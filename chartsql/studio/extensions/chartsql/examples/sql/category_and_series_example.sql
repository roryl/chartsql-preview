-- @chart: line
-- @title: Manual Category and Series
-- @subtitle: An example chart manually setting the category and series
-- @category: Date_Closed
-- @series: Profit
SELECT 
	Sub.*,
    (
      SELECT channel
      FROM Sales
      WHERE Sales.Date_Closed = Sub.Date_Closed
      GROUP BY Channel
      ORDER BY count(*) DESC
      LIMIT 1
    ) as TopChannel
FROM (
    SELECT 
      Date_Closed,
      sum(Amount) as Amount,
      sum(Profit) as Profit
    FROM Sales
    WHERE Status = 'Won'
    GROUP BY Date_Closed
    ORDER BY Date_Closed ASC
) as Sub;