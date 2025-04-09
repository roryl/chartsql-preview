-- @title: Select List - Dynamic SQL query from user selection
-- @subtitle: An example SQL query which uses a dynaic SQL query from user selection
-- @formats: currency
-- @select-list-channel: all, referral, coldcall, search, event
-- @chart: line
SELECT
TRUNC(date_closed, 'MONTH') as Month,
sum(amount) as Sales
FROM sales
{{#unless (eq select-list-channel.selected "all")}}
  WHERE Channel = '{{select-list-channel.selected}}'
{{/unless}}
GROUP BY Month
ORDER BY Month ASC;