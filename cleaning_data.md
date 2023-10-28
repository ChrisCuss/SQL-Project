What issues will you address by cleaning the data?

- Missing Values: Identify and/or remove missing values.
- Duplicate Records: Eliminate duplicate rows.
- Inconsistent Formatting: Standardize date formats, text casing, and numerical values for uniformity.
- Outliers: Identify outliers that could skew the analysis.
- Data Integrity: Make sure all the ''keys'' connect the tables properly for the data flow.

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

	-- This gave me an undesireable result as the column is now the last column in my table with no way of moving it without creating a whole new table. For next time, this would be easier below.

	UPDATE analytics
	SET unit_price = CAST(unit_price AS NUMERIC(10,2)) / 1000000;

	ALTER TABLE analytics
	ALTER COLUMN unit_price TYPE NUMERIC(10,2) USING CAST(unit_price AS NUMERIC(10,2));



-- The fullvisitorid column in all_sessions and analytics do not match. However, if I only keep the first 6 digits of each ID not counting zeros, they do match.

	-- First remove all the zeros from a.fullvisitorid
	UPDATE all_sessions
	SET fullvisitorID = ltrim(substring(fullvisitorID from 1 for 5), '0');

	-- Then we can remove the rest of the characters we don't need. I only need the first 6 characters that are not zeros in both columns.
	UPDATE analytics
	SET fullvisitorID = substring(ltrim(fullvisitorID, '0') from 1 for 6);

	UPDATE all_sessions
	SET fullvisitorID = substring(ltrim(fullvisitorID, '0') from 1 for 6);

	-- Finally, make the field a INT datatype
	ALTER TABLE all_sessions
	ALTER COLUMN fullvisitorid TYPE INT USING CAST(fullvisitorid AS INT);

-- Next, I started to tackle the SKU columns. I see that there are some SKUs that are only numbers and don't have letters. I decided to only keep the last 5 characters.

	UPDATE products
	SET sku = RIGHT(SKU, 6);
	
	-- Repeat for every sku or productsku columns in all tables

-- Now we're going to take a look at all the date columns that are currently VARCHAR and make them into DATE datatypes.
	
	-- Let's make sure the string values are compatible and can easily become a date.
	SELECT
		date,
		date::DATE
	FROM
		all_sessions

	-- Set the new datatype for the column
	ALTER TABLE all_sessions
	ALTER COLUMN date TYPE DATE USING date::DATE;

	-- Repeat for all tables with date columns

-- Change timeonsite to INT

	ALTER TABLE analytics
	ALTER COLUMN timeonsite TYPE INTEGER USING timeonsite::INTEGER;
	-- Repeat for all_sessions table

-- Changing totaltransactionsrevenue and transactionrevenue in the all_sessions table to a NUMERIC(10,2)

		UPDATE all_sessions
		SET totaltransactionrevenue = CAST(totaltransactionrevenue AS NUMERIC(10,2)) / 1000000;

	ALTER TABLE all_sessions
	ALTER COLUMN totaltransactionrevenue TYPE NUMERIC(10,2)USING CAST(totaltransactionrevenue AS NUMERIC(10,2));

-- Changing transactions to a SMALLINT

	ALTER TABLE all_sessions
	ALTER COLUMN transactions TYPE SMALLINT USING CAST(transactions AS SMALLINT);

-- Changing units_sold and pageviews in the analytics table to SMALLINT
		
		ALTER TABLE analytics
		ALTER COLUMN units_sold TYPE SMALLINT USING units_sold::SMALLINT;

-- Chaning total_ordered, restockingleadtime and stocklevel to SMALLINT from sales_report

	ALTER TABLE sales_report
	ALTER COLUMN stocklevel TYPE SMALLINT USING CAST(stocklevel AS SMALLINT);

-- Some of the names in the name column in products and sales_report have a whitespace at the begining. The below code removes it.

	UPDATE sales_report 
	SET name = ltrim(name);

-- Change the total_ordered column in sales_by_sku to SMALLINT

	ALTER TABLE sales_by_sku
	ALTER COLUMN total_ordered TYPE SMALLINT USING CAST(total_ordered AS SMALLINT);


4. Outliers

-- For this one, I knew it was going to get a bit tricker, so I asked ChatGPT to help me create two queries. One for the stats of each column and another to find the specific outliers in that column.

	WITH Stats AS (
	  SELECT 
	    MIN(your_column) AS min_value,
	    MAX(your_column) AS max_value,
	    AVG(your_column) AS avg_value,
	    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY your_column) AS q1,
	    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY your_column) AS q3
	  FROM your_table
	)
	SELECT 
	  min_value, 
	  max_value, 
	  avg_value,
	  q1,
	  q3,
	  q3 + 1.5 * (q3 - q1) AS upper_outlier_limit,
	  q1 - 1.5 * (q3 - q1) AS lower_outlier_limit
	FROM Stats;

	SELECT column_name
	FROM table_name
	WHERE column_name > (SELECT AVG(column_name) + 3 * STDDEV(column_name) FROM table_name)
	   OR column_name < (SELECT AVG(column_name) - 3 * STDDEV(column_name) FROM table_name);

5. Data Integrity

-- I created a new table called visitors in order to house the unique fullvisitorids.

		CREATE TABLE visitors (
	  fullvisitorid INT PRIMARY KEY,
	  country VARCHAR(21),
	  city VARCHAR(34),
	  totaltransactionrevenue NUMERIC(10,2),
	  transactions SMALLINT
);

	-- Then I copied the data from all_sessions

	INSERT INTO visitors (fullvisitorid, country, city, totaltransactionrevenue, transactions)
	SELECT DISTINCT ON (fullvisitorid) fullvisitorid,
										country,
										city,
										totaltransactionrevenue,
										transactions
	FROM all_sessions
	ORDER BY fullvisitorid;

	-- Removed those columns from all_sessions

	ALTER TABLE all_sessions
	DROP COLUMN country;

	-- Repeat for each column that exists in the new table

	-- Using the PGadmin GUI, I added primary keys and foreign keys to all the tables


-- Now that I have a visitors, I'm able to use this fullvisitorid as a Primary Key for this table and as a Foreign Key for my other tables like all_sessions and analytics.
	












