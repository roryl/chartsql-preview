-- @chart: combo
-- @title: Combo - Column Chart with Secondary Line
-- @subtitle: A combo chart with a column series and a secondary line series
-- @category: Channel
-- @series: TotalDeals
-- @secondary-series: ConversionRate
-- @series-types: column, line
-- @formats: currency, percent
SELECT 
	Sub.*,
    ROUND(WonDeals / TotalDeals * 100, 1) as ConversionRate
FROM (
  SELECT 
  Channel,
  CAST(count(*) AS FLOAT) as TotalDeals,
  SUM(CASE WHEN Status = 'Won' THEN 1 ELSE 0 END) as WonDeals
  FROM Sales
  WHERE Status = 'Won' or Status = 'Lost'
  GROUP BY Channel
) as Sub;
