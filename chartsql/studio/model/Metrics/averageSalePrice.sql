-- @chart: combo
-- @category: Account Name
-- @series: average_sale_price, deal_count
-- @series-types: column
-- @formats: currency, integer
SELECT 
    `Account Name`,
    AVG(CAST(REPLACE(Amount, ',', '') AS DECIMAL(10, 2))) AS average_sale_price,
    COUNT(*) AS deal_count
FROM 
    sample_data_full_new
WHERE 
    Status IN ('Won')
    AND `Account Name` IN ('Sempra Energy', 'US Foods', 'Danaher Corporation', 'General Mills')
GROUP BY 
    `Account Name`
ORDER BY 
    `Account Name`;
  
