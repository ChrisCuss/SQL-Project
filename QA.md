### What are your risk areas? Identify and describe them.

-- Although I made backups of the database often, I now realise that it would have been safer to create Views, Temp tables or just create new additional tables. This would have come in handy when cleaning the data and eliminating some of the columns without loosing the original data.

-- There many null values in many columns. Sure, I can change some of them to 0 or the avg of the column but its a risk when I don't know the context of the data or any explanation of where the data comes from, how it was aquired and etc.

-- For data integrity, I have a risk in the all_sessions and Analytics tables since they don't seem to have PRIMARY KEYS. I would have to create a new column for that or figure out a way to make visitid unique to each rows in those tables without breaking the connection between the two columns.

-- I hope not because I double checked, but there's always the chance of duplicate records still existing.

## QA Process:
### Describe your QA process and include the SQL queries used to execute it.

-- I started by running the below query to evaluate all my columns in all my tables.

	SELECT 		table_name,
				column_name,
				data_type,
				is_nullable
	FROM		information_schema.columns
	WHERE		table_schema = 'public'
	ORDER BY	table_name

-- This was also in my cleaning_data process. But I used this code to verify there were no more nulls in the important columns.

		SELECT
		COUNT() AS null_count
	FROM
		all_sessions
	WHERE fullvisitorid IS NULL;

-- Used the below code to remove rows that won't be useful due to nulls or missing values.

	DELETE FROM all_sessions
	WHERE country = '(not set)';

-- Then, of course, we check for duplicates.

	SELECT visitid, COUNT(*)
	FROM all_sessions
	GROUP BY 1
	HAVING COUNT(*) > 1;

-- Make sure none of of my columns have anymore unecessary white spaces.

SELECT name
FROM sales_report
WHERE name LIKE ' %'

-- If I had more time, I would probably create new tables and re-assign the columns to tables where it makes more sense to keep them. I would have used code similar to the code I used to create the new 'visitors' table.

		CREATE TABLE visitors (
	  fullvisitorid INT PRIMARY KEY,
	  country VARCHAR(21),
	  city VARCHAR(34),
	  totaltransactionrevenue NUMERIC(10,2),
	  transactions SMALLINT
	);
	
	INSERT INTO visitors (fullvisitorid, country, city, totaltransactionrevenue, transactions)
	SELECT DISTINCT ON (fullvisitorid) fullvisitorid,
										country,
										city,
										totaltransactionrevenue,
										transactions
	FROM all_sessions
	ORDER BY fullvisitorid; 

