Answer the following questions and provide the SQL queries used to find the answer.

    
**Question 1: Which cities and countries have the highest level of transaction revenues on the site?**


SQL Queries:

-- I created a new table called visitors to house the fullvisitorids and their respective country, city and transcation columns.

-- I just realized that I never replaced the null values in the totaltransactionrevenue and transcations columns.

UPDATE visitors
SET totaltransactionrevenue = 0 WHERE totaltransactionrevenue IS NULL;
UPDATE visitors 
SET transactions = 0 WHERE transactions IS NULL;

-- Countries

SELECT 	country,
		SUM(totaltransactionrevenue)
FROM visitors
GROUP BY 1
ORDER BY 2 DESC

-- Cities

SELECT 	city,
		SUM(totaltransactionrevenue)
FROM visitors
WHERE city != 'N/A'
GROUP BY 1
ORDER BY 2 DESC


Answer:

-- Top 3 Countries:
#1. United States
#2. Israel
#3. Australia3

-- Top 5 Cites:
#1. San Francisco
#2. Sunnyvale
#3. Atlanta
#4. Palo Alto
#5. Tel Aviv-Yafo

**Question 2: What is the average number of products ordered from visitors in each city and country?**


SQL Queries:

-- Overall averages

WITH sku_count AS (
	SELECT
		al.fullvisitorid,
		country,
		city,
		COUNT(DISTINCT productsku) AS total_products
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1,2,3
)

SELECT
	city,
	country,
	CAST(AVG(total_products) AS NUMERIC(10,2))
FROM
	sku_count
GROUP BY 1,2
ORDER BY 3 DESC

-- By city averages

WITH sku_count AS (
	SELECT
		city,
		COUNT(DISTINCT productsku) AS total_products
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1
)

SELECT
	city,
	CAST(AVG(total_products) AS NUMERIC(10,2))
FROM
	sku_count
GROUP BY 1
ORDER BY 2 DESC

-- By country averages

WITH sku_count AS (
	SELECT
		country,
		COUNT(DISTINCT productsku) AS total_products
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1
)

SELECT
	country,
	CAST(AVG(total_products) AS NUMERIC(10,2))
FROM
	sku_count
GROUP BY 1
ORDER BY 2 DESC

Answer:

-- Top 3 countries averages
#1. United States 494
#2. Canada 244
#3. India 216

-- Top 5 city averages
#1 Mountain View 326
#2 New York 276
#3 San Francisco 227
#4 Sunnyvale 202
#5 San Jose 169


**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**


SQL Queries:



Answer:





**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**


SQL Queries:



Answer:





**Question 5: Can we summarize the impact of revenue generated from each city/country?**

SQL Queries:



Answer:







