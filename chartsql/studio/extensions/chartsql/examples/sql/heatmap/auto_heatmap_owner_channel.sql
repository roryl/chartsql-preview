-- @title: Auto Heatmap
-- @subtitle: An example auto generated heatmap comparing two categories
SELECT
Owner,
Channel,
count(*) as Sales
FROM Sales
WHERE Sales.Status = 'Won'
GROUP BY Owner, Channel;