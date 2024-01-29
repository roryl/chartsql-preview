-- @chart: bar
-- @title: Groups - Multiple category groups
-- @subtitle: An example of multiple category groups
-- @groups: Channel, Owner
-- @series: TotalSales
-- @formats: currency
SELECT 
	Final.*
FROM (  
  SELECT 
  	Channel,    
  	Owner,
    (
      SELECT sum(Sub.Amount)
      FROM Sales Sub
      WHERE Sub.Channel = Sales.Channel
    ) as TotalChannelSales,
    sum(Amount) as TotalSales
  FROM Sales
  WHERE Owner IN (
    SELECT Owner
    FROM Sales
    GROUP BY Owner
    ORDER BY sum(Amount)
    LIMIT 10
  )
  GROUP BY Channel, Owner
) as Final
ORDER BY TotalChannelSales DESC, TotalSales DESC
