-- @chart: column
-- @category: Month
-- @formats: integer
    -- @title: New Deal Month

SELECT
    CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE) AS Month,
    COUNT(*) AS 'New Deals'
FROM
    sample_data_full_new
GROUP BY
    CAST(DATE_FORMAT(DateCreated, '%Y-%m-01') AS DATE)
ORDER BY
    Month ASC;