-- @chart: combo
-- @category: Month
-- @series: New_Value, New_Deals
-- @series-types: column, line
-- @formats: currency, integer
-- @title: New Value
WITH monthly_data AS (
    SELECT 
        CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE) AS Month,
        COUNT(*) AS New_Deals,
        AVG(CAST(REPLACE(Amount, ',', '') AS DECIMAL(10, 2))) AS Avg_Sale_Price,
        SUM(CASE WHEN Status = 'Won' THEN 1 ELSE 0 END) / COUNT(*) AS Conversion_Rate
    FROM 
        sample_data_full_new
    GROUP BY 
      CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE)
)
SELECT 
    Month,
    ROUND(New_Deals * Avg_Sale_Price * Conversion_Rate, 2) AS New_Value,
    New_Deals
FROM 
    monthly_data
ORDER BY 
    Month;
