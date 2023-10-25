What issues will you address by cleaning the data?

-- Missing Values: Identify and/or remove missing values.
-- Duplicate Records: Eliminate duplicate rows.
-- Inconsistent Formatting: Standardize date formats, text casing, and numerical values for uniformity.
-- Outliers: Identify outliers that could skew the analysis.
-- Data Integrity: Make sure all the ''keys'' connect the tables properly for the data flow.

Queries:
Below, provide the SQL queries you used to clean your data.

1. Missing values.

-- First I started by going through all of the important columns in every table and running a simple query to find any null values.

SELECT
	COUNT() AS null_count
FROM
	all_sessions
WHERE fullvisitorid IS NULL;

-- From here, depending on the table & column, I make a choice to remove the rows from the dataset or to fill them with default data (AVG, default string, etc).
-- For example, I removed all rows from the all_sessions data that had country as '(not set)'. All 24 of those rows did not complete a transaction and most spent 0 time on the site, so they could have been bots. Not useful to me and wouldn't contribute to my analysis.

DELETE FROM all_sessions
WHERE country = '(not set)';

-- In the analytics table, there's a column named 'userid' where all the values are null. I decided to delete that column entirely since there was not data in it and it was redundant due to the 'fullvisitorid' column.

ALTER TABLE analytics
DROP COLUMN userid;

-- In the all_sessions table, there are rows in the currencycode column that are null. I set them to the default value of 'USD'.

UPDATE all_sessions
SET currencycode = 'USD'
WHERE currencycode IS NULL;

-- Just for fun, I set all the NULL values in the timeonsite column of all_sessions to the AVG value of that column.

SELECT AVG(CAST(timeonsite AS NUMERIC))
FROM	all_sessions

UPDATE all_sessions
SET timeonsite = '224'
WHERE timeonsite IS NULL;

2. Duplicates

-- Second, I went through all the tables to find duplicate rows where there shouldn't be any.

SELECT visitid, COUNT(*)
FROM all_sessions
GROUP BY 1
HAVING COUNT(*) > 1;

-- Its difficult to tell if fullvisitorid and visitid are supposed to be unique or not due to the nature of the data in the tables. I feel like both these tables record every session from every visitor as well as every page they looked at.

-- Many products have the same name but different SKU. It's possible there are different sizes and models.

-- Removing any rows from all sessions

3. Formatting

-- Now I go through all of the columns from each table and ensure the formatting is correct and each column is the correct/relevant datatype.

-- I'm having a lot of trouble with the time column in all_sessions. Without reference to the metadata, it's hard to tell what these numbers mean. Leaving it for now.

-- in the city column of all_sessions, I standardized the NULL , (not set) and 'Not available in demodataset' values as 'N/A' for standardisation.

UPDATE all_sessions
SET city = 'N/A'
WHERE 
	city = '(not set)' 
	OR city = 'not available in demo dataset';

-- As per the hint in assignments.md, the unitprice and productprice need to be divided by 1,000,000.

	-- Start by creating a new FLOAT column
	ALTER TABLE all_sessions
	ADD COLUMN new_product_price FLOAT;

	-- Then I populated the new column
	UPDATE all_sessions
	SET new_product_price = CAST(productprice AS FLOAT) / 1000000;

	-- After that, we delete the old column
	ALTER TABLE all_sessions
	DROP COLUMN productprice;

	-- Rename the new column
	ALTER TABLE all_sessions
	RENAME COLUMN new_product_price TO productprice;

















