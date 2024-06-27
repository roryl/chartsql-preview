-- @chart: column
-- @title: Closed Deals
-- @subtitle: Finalized deals
SELECT Status, COUNT(*) AS ClosedDeals
FROM sample_data_full_new
WHERE Status IN ('Won', 'Lost')
GROUP BY Status;
