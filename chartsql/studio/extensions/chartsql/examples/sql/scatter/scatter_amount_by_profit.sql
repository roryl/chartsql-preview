-- @title: Auto Scatter
-- @subtitle: Auto generted scatter chart
SELECT 
  Profit,
  Amount
FROM Sales
WHERE Status = 'Won';