-- @title: Auto Grouped Column
-- @subtitle: Auto grouping columns when there is one category and two values  
SELECT
Channel,
SUM(
CASE WHEN Sales.Status = 'Won' OR Sales.Status = 'Lost' THEN 1 ELSE 0 END
) as "Sales_Closed",
SUM(
CASE WHEN Sales.Status = 'Won' THEN 1 ELSE 0 END
) as "Sales_Won"
FROM sales
GROUP BY Channel;