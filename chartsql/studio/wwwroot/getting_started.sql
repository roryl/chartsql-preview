-- -----------------------
-- GETTING STARTED
-- -----------------------
-- ChartSQL Studio is an editor for visualizing SQL queries using the
-- ChartSQL visualization language. You can write SQL queries in this
-- editor area and see your visualizations to the right --->

-- -----------------------
-- EXAMPLE SQL CHART
-- -----------------------
-- Below is a SQL query with 'at directives' that define how to
-- chart your SQL query

-- @chart: column
-- @title: Getting Started
-- @subtitle: Getting started with ChartSQL
-- @formats: currency
SELECT
	TRUNC(date_closed, 'MONTH') as Month,
	sum(amount) as Sales
FROM sales
GROUP BY Month
ORDER BY Month ASC;

-- -----------------------
-- FOLDERS
-- -----------------------
-- SQL files are stored in folders on your file system. Each
-- unique folder path is called a 'Folder'. We added a default folder
-- 'Scratchpad' for you. You can add additional folders
-- from your filesystem for other projects from the settings.

-- -----------------------
-- DATASOURCES:
-- -----------------------
-- You can connect to more SQL datasources. Go to settings to add additional
-- datasources. You can switch your actively running datasource at the top
-- right of the editor.

-- -----------------------
-- SHORTCUTS:
-- -----------------------
-- You can use the following shortcuts:
-- ctrl (cmd) + s: Save and run the query
-- ctrl (cmd) + p: Open global search
-- ctrl (cmd) + f: Search package files

-- -----------------------
-- EXAMPLES:
-- -----------------------
-- We have added some example SQL queries in the 'Examples' folder.