## Question 1: How many products were designed for women and how many products were designed for men?

### SQL Queries:

	WITH men_products AS(
	SELECT
		COUNT(*) AS men_product
	FROM products
	WHERE name LIKE 'Men%'
	),
	women_products AS(
		SELECT
			COUNT(*) AS women_product
		FROM products
		WHERE name LIKE 'Women%'
	)
	SELECT
		men_product AS total_men_products,
		women_product AS total_women_products
	FROM
		men_products,
		women_products

### Answer: 
-- There are 275 products for men and 250 products for women


## Question 2: What are the 3 products that have the highest stock levels and the 3 products with the lowest.

### SQL Queries:

	(SELECT
	name,
	stocklevel,
	'Top 3'
	FROM products
	ORDER BY stocklevel DESC
	LIMIT 3)
	UNION ALL
	(SELECT
		name,
		stocklevel,
		'Lowest 3'
	FROM products
	WHERE stocklevel > 0
	ORDER BY stocklevel ASC
	LIMIT 3)

### Answer:

-- Top 3
- "22 oz Water Bottle"
- "22 oz Water Bottle"
- "Sunglasses"

-- Lowest 3
- "Women's Short Sleeve Tri-blend Badge Tee Grey"
- "Women's Recycled Fabric Tee"
- "Vintage Henley Grey/Black"


## Question 3: Are there customers who have purchased more than once and bought pen's more than once?

### SQL Queries:

	SELECT fullvisitorid, COUNT(*)
	FROM all_sessions
	WHERE v2productname LIKE '%Pen%'
	GROUP BY 1
	HAVING COUNT(*) > 1

	SELECT COUNT(*)
	FROM 	(SELECT fullvisitorid, COUNT(*)
			FROM all_sessions
			WHERE v2productname LIKE '%Pen%'
			GROUP BY 1
			HAVING COUNT(*) > 1)

### Answer:

-- There are 15 customers who have purchased more than once and bought pen's more than once.

