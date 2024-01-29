-- @title: Auto Bubble
-- @subtitle: Auto generted bubble chart
SELECT 
  Profit,
  Amount,
  (CAST(Profit AS FLOAT) / Amount) * 500 as Margin
FROM Sales
WHERE Status = 'Won'
LIMIT 10;