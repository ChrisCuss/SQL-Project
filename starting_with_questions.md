Answer the following questions and provide the SQL queries used to find the answer.

    
## **Question 1: Which cities and countries have the highest level of transaction revenues on the site?**


### SQL Queries:

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


### Answer:

-- Top 3 Countries:

	#1. United States
	#2. Israel
	#3. Australia

-- Top 5 Cites:

	#1. San Francisco
	#2. Sunnyvale
	#3. Atlanta
	#4. Palo Alto
	#5. Tel Aviv-Yafo

## **Question 2: What is the average number of products ordered from visitors in each city and country?**


### SQL Queries:

	-- Overall averages Country w/ City

	WITH sku_count AS (
		SELECT
			al.fullvisitorid,
			country,
			city,
			COUNT(productsku) AS total_products
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
			COUNT(productsku) AS total_products
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
			COUNT(productsku) AS total_products
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

### Answer:

-- Top 3 countries averages

	#1. United States
	#2. India
	#3. United Kingdom

-- Top 5 city averages

	#1. Mountain View
	#2. New York
	#3. San Francisco
	#4. Sunnyvale
	#5. San Jose


## **Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**


### SQL Queries:

	--First, I wanted to start by taking a look at the number of orders each category got in each city & country.

	SELECT
	v.city,
	v.country,
	al.v2productcategory,
	COUNT(*) as order_count
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	WHERE 	city != 'N/A'
			AND country != 'N/A'
	GROUP BY 1,2,3
	ORDER BY 4 DESC;

	--Then, I took a deeper dive to see what is the top category in each city & country.

	WITH ranked_categories AS (
	SELECT
		city,
		country,
		v2productcategory,
		COUNT(v2productcategory) as order_count,
		RANK() OVER (PARTITION BY v.city, v.country ORDER BY COUNT(v2productcategory) DESC) AS catRank
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1, 2, 3
	ORDER BY 2, 1, 5
	)
	SELECT 
			city,
			country,
			v2productcategory,
			order_count
	FROM ranked_categories
	WHERE catRank = 1
			AND city != 'N/A'
			AND country != 'N/A'
	GROUP BY
		1,2,3,
		ranked_categories.city,
		ranked_categories.country,
		ranked_categories.v2productcategory,
		ranked_categories.order_count
	ORDER BY 4 DESC,2,1

-- Cities only

	WITH ranked_categories AS (
		SELECT
			v.city,
			al.v2productcategory,
			COUNT(al.v2productcategory) as order_count,
			RANK() OVER (PARTITION BY v.city ORDER BY COUNT(al.v2productcategory) DESC) AS catRank
		FROM all_sessions al
		JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
		GROUP BY 1, 2
		ORDER BY 1, 4
	)
	SELECT 
			city,
			v2productcategory,
			order_count
	FROM ranked_categories
	WHERE catRank = 1
			AND city != 'N/A'
	GROUP BY
		1,2,3,
		ranked_categories.city,
		ranked_categories.v2productcategory,
		ranked_categories.order_count
	ORDER BY 3 DESC,1

-- Countries only

	WITH ranked_categories AS (
		SELECT
			v.country,
			al.v2productcategory,
			COUNT(v2productcategory) as order_count,
			RANK() OVER (PARTITION BY v.country ORDER BY COUNT(v2productcategory) DESC) AS catRank
		FROM all_sessions al
		JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
		GROUP BY 1, 2
		ORDER BY 1, 4
	)
	SELECT 
			country,
			v2productcategory,
			order_count
	FROM ranked_categories
	WHERE catRank = 1
			AND country != 'N/A'
	GROUP BY
		1,2,3,
		ranked_categories.country,
		ranked_categories.v2productcategory,
		ranked_categories.order_count
	ORDER BY 3 DESC,1

-- Categories only

	WITH ranked_categories AS (
	SELECT
		al.v2productcategory,
		COUNT(v2productcategory) as order_count,
		RANK() OVER (ORDER BY COUNT(al.v2productcategory) DESC) AS catRank
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1
	ORDER BY 1, 3
	)
	SELECT 
			v2productcategory,
			order_count,
			catRank
	FROM ranked_categories
	GROUP BY
		1,
		ranked_categories.v2productcategory,
		ranked_categories.order_count,
		ranked_categories.catrank
	ORDER BY 2 DESC,1

### Answer:

-- In most cities, the top category is "Home/Apparel/Men's/Men's-T-Shirts/", but when you start to look at things a bit wider by country or overall category sales, you can clearly see that the top selling category is "Home/Shop by Brand/YouTube/".


## **Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**


### SQL Queries: 

-- Taking the same approach as above, I'm going to take a look at top sales in all cities and countries.

	SELECT
	v.city,
	v.country,
	al.v2productname,
	COUNT(*) as order_count
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	WHERE 	city != 'N/A'
			AND country != 'N/A'
	GROUP BY 1,2,3
	ORDER BY 4 DESC;

-- Now let's take a deeper dive by only looking at #1 ranking products.

	WITH ranked_products AS (
	SELECT
		v.city,
		v.country,
		al.v2productname,
		COUNT(al.v2productname) AS order_count,
		RANK() OVER (PARTITION BY v.city, v.country ORDER BY COUNT(al.v2productname) DESC) AS prodRank
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1, 2, 3
	ORDER BY 2, 1, 5
	)
	SELECT 
			city,
			country,
			v2productname,
			order_count,
			prodRank
	FROM ranked_products
	WHERE prodRank = 1
			AND city != 'N/A'
			AND country != 'N/A'
	GROUP BY
		1,2,3,
		ranked_products.order_count,
		ranked_products.city,
		ranked_products.country,
		ranked_products.v2productname,
		ranked_products.prodrank
	ORDER BY 4 DESC,2,1

-- Cities only

	WITH ranked_products AS (
	SELECT
		v.city,
		al.v2productname,
		COUNT(al.v2productname) AS order_count,
		RANK() OVER (PARTITION BY v.city ORDER BY COUNT(al.v2productname) DESC) AS prodRank
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1, 2
	ORDER BY 1, 4
	)
	SELECT 
			city,
			v2productname,
			order_count,
			prodRank
	FROM ranked_products
	WHERE prodRank = 1
			AND city!= 'N/A'
	GROUP BY
		1,2,3,
		ranked_products.order_count,
		ranked_products.city,
		ranked_products.v2productname,
		ranked_products.prodrank
	ORDER BY 3 DESC,1

-- Countries only

	WITH ranked_products AS (
	SELECT
		v.country,
		al.v2productname,
		COUNT(al.v2productname) AS order_count,
		RANK() OVER (PARTITION BY v.country ORDER BY COUNT(al.v2productname) DESC) AS prodRank
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1, 2
	ORDER BY 1, 4
	)
	SELECT 
			country,
			v2productname,
			order_count,
			prodRank
	FROM ranked_products
	WHERE prodRank = 1
			AND country != 'N/A'
	GROUP BY
		1,2,3,
		ranked_products.order_count,
		ranked_products.country,
		ranked_products.v2productname,
		ranked_products.prodrank
	ORDER BY 3 DESC,1

-- Products only

	WITH ranked_products AS (
	SELECT
		al.v2productname,
		COUNT(al.v2productname) AS order_count,
		RANK() OVER (ORDER BY COUNT(al.v2productname) DESC) AS prodRank
	FROM all_sessions al
	JOIN visitors v ON al.fullvisitorid = v.fullvisitorid
	GROUP BY 1
	ORDER BY 1, 3
	)
	SELECT
			v2productname,
			order_count,
			prodRank
	FROM ranked_products
	GROUP BY
		1,
		ranked_products.order_count,
		ranked_products.v2productname,
		ranked_products.prodrank
	ORDER BY 3,1


### Answer:

-- I want to start by saying that there's someone in Mountain View USA hoarding wayyy to many Nest Security Cameras. Also, the "Google Men's 100% Cotton Short Sleeve Hero Tee White" appears to be the most popular products, especially in the United States. For India, the most popular product is "YouTube Custom Decals" and for Canada it's "YouTube Twill Cap". The most popular products overall are the most popular products in our top cities and countries from the data but when you start to look at the cities and countries with fewer orders, the top products shift. My suspision is that more orders from those countries is needed to properly assess a patern.


## **Question 5: Can we summarize the impact of revenue generated from each city/country?**

### SQL Queries:

-- Impact overall by looking at what percentage each city & country represent of the overall revenue.

	WITH total_revenue AS (
		SELECT SUM(revenue) AS total_revenue
		FROM visitors v
		JOIN analytics a ON v.fullvisitorid = a.fullvisitorid
		WHERE revenue IS NOT NULL
				AND city != 'N/A'
	),
	city_country_revenue AS (
		SELECT 
			country, 
			city, 
			SUM(revenue) AS city_country_revenue
		FROM visitors v
		JOIN analytics a ON v.fullvisitorid = a.fullvisitorid
		WHERE revenue IS NOT NULL
				AND city != 'N/A'
		GROUP BY 1,2
	)
	SELECT
		ccr.country, 
	    ccr.city, 
	    ccr.city_country_revenue,
	    (ccr.city_country_revenue / tr.total_revenue) * 100 AS percentage_of_total
	FROM
		city_country_revenue ccr,
		total_revenue tr
	ORDER BY 3 DESC, 1, 2

-- Cities Only

	WITH total_revenue AS (
	SELECT SUM(revenue) AS total_revenue
	FROM visitors v
	JOIN analytics a ON v.fullvisitorid = a.fullvisitorid
	WHERE revenue IS NOT NULL
			AND city != 'N/A'
	),
	city_revenue AS (
		SELECT 
			city, 
			SUM(revenue) AS city_revenue
		FROM visitors v
		JOIN analytics a ON v.fullvisitorid = a.fullvisitorid
		WHERE revenue IS NOT NULL
				AND city != 'N/A'
		GROUP BY 1
	)
	SELECT 
	    cr.city, 
	    cr.city_revenue,
	    (cr.city_revenue / tr.total_revenue) * 100 AS percentage_of_total
	FROM
		city_revenue cr,
		total_revenue tr
	ORDER BY 2 DESC, 1

-- Countries only

	WITH total_revenue AS (
		SELECT SUM(revenue) AS total_revenue
		FROM visitors v
		JOIN analytics a ON v.fullvisitorid = a.fullvisitorid
		WHERE revenue IS NOT NULL
				AND city != 'N/A'
	),
	country_revenue AS (
		SELECT 
			country, 
			SUM(revenue) AS country_revenue
		FROM visitors v
		JOIN analytics a ON v.fullvisitorid = a.fullvisitorid
		WHERE revenue IS NOT NULL
				AND city != 'N/A'
		GROUP BY 1
	)
	SELECT 
	    cr.country, 
	    cr.country_revenue,
	    (cr.country_revenue / tr.total_revenue) * 100 AS percentage_of_total
	FROM
		country_revenue cr,
		total_revenue tr
	ORDER BY 2 DESC, 1

### Answer:

-- No surprises here. The USA represents over 86% of the revenue. 





