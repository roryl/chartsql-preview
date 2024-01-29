-- @chart: bar
-- @title: Bar Stacking - Example bar chart with stacking
-- @groups: Owner, Channel
-- @subtitle: An example bar chart that has a single stack
-- @series: Sales
-- @stacks: Channel
-- @formats: currency
SELECT *
FROM (  
  SELECT 
      Owner,
      Channel,
      (
        SELECT sum(Amount)
        FROM Sales Sub
        WHERE Sub.Owner = Sales.Owner
      ) as OwnerTotal,
      sum(amount) as Sales
  FROM sales
  GROUP BY Owner, Channel
) as Final
ORDER BY Final.OwnerTotal DESC, Sales DESC;