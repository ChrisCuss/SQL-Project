-- Part 1 --
-- Importing Data --

-- Importing all_sessions file --
-- 1. Create Table
CREATE TABLE all_sessions (
  fullVisitorId INTEGER,
  channelGrouping TEXT,
  time INTEGER,
  country TEXT,
  city TEXT,
  totalTransactionRevenue FLOAT,
  transactions FLOAT,
  timeOnSite FLOAT,
  pageviews INTEGER,
  sessionQualityDim FLOAT,
  date INTEGER,
  visitId INTEGER,
  type TEXT,
  productRefundAmount FLOAT,
  productQuantity FLOAT,
  productPrice INTEGER,
  productRevenue FLOAT,
  productSKU TEXT,
  v2ProductName TEXT,
  v2ProductCategory TEXT,
  productVariant TEXT,
  currencyCode TEXT,
  itemQuantity FLOAT,
  itemRevenue FLOAT,
  transactionRevenue FLOAT,
  transactionId FLOAT,
  pageTitle TEXT,
  searchKeyword FLOAT,
  pagePathLevel1 TEXT,
  eCommerceAction_type INTEGER,
  eCommerceAction_step INTEGER,
  eCommerceAction_option TEXT
);

-- 2. Import Data into table

COPY all_sessions
FROM '/Users/chriscuss/documents/data_science/LHL Projects/SQL-Project/Project_Data/all_sessions.csv'
DELIMITER ','
CSV HEADER;

/* Could not import using code due to some sort of permissions issues. Instead I'm going to import using
PGadmin's GUI. Having issues with the fullVisitorId column in the CSV file. Going to have to make into an int in the CSV before importing.
*/

/* Now getting an error that FullVisitorID is too big for an INT data type. Switching everything to VarChar for now.*/

DROP TABLE all_sessions;

CREATE TABLE all_sessions (
  fullVisitorId VARCHAR(22),
  channelGrouping VARCHAR(16),
  time VARCHAR(8),
  country VARCHAR(21),
  city VARCHAR(34),
  totalTransactionRevenue VARCHAR(13),
  transactions VARCHAR(3),
  timeOnSite VARCHAR(7),
  pageviews VARCHAR(2),
  sessionQualityDim VARCHAR(4),
  date VARCHAR(9),
  visitId VARCHAR(12),
  type VARCHAR(6),
  productRefundAmount VARCHAR(3),
  productQuantity VARCHAR(4),
  productPrice VARCHAR(10),
  productRevenue VARCHAR(3),
  productSKU VARCHAR(16),
  v2ProductName VARCHAR(70),
  v2ProductCategory VARCHAR(55),
  productVariant VARCHAR(21),
  currencyCode VARCHAR(3),
  itemQuantity VARCHAR(3),
  itemRevenue VARCHAR(3),
  transactionRevenue VARCHAR(3),
  transactionId VARCHAR(3),
  pageTitle VARCHAR(87),
  searchKeyword VARCHAR(3),
  pagePathLevel1 VARCHAR(20),
  eCommerceAction_type VARCHAR(1),
  eCommerceAction_step VARCHAR(1),
  eCommerceAction_option VARCHAR(24)
);

-- Now I need to make other columns accept more characters.

ALTER TABLE all_sessions
ALTER COLUMN productRevenue
TYPE VARCHAR(20);

ALTER TABLE all_sessions 
  ALTER COLUMN pageTitle TYPE TEXT;
  
SELECT *
FROM all_sessions

-- Importing Products File

-- 1. Create Table

CREATE TABLE products (
  SKU VARCHAR(255),
  name VARCHAR(255),
  orderedQuantity VARCHAR(255),
  stockLevel VARCHAR(255),
  restockingLeadTime VARCHAR(255),
  sentimentScore VARCHAR(255),
  sentimentMagnitude VARCHAR(255)
);
-- 2. Imported the data using PDadmin's GUI.

-- Import Sales_By_SKU

-- 1. Create Table
CREATE TABLE sales_by_sku (
	productSKU VARCHAR(255),
	total_ordered VARCHAR(255)
	);
-- 2. Imported the data using PDadmin's GUI.

-- Import Sales_Report
-- 1. Create Table
CREATE TABLE sales_report(
	productSKU VARCHAR(255),
	total_ordered VARCHAR(255),
	name VARCHAR(255),
	stockLevel VARCHAR(255),
	restockingLeadTime VARCHAR(255),
	sentimentScore VARCHAR(255),
	sentimentMagnitude VARCHAR(255),
	ratio VARCHAR(255)	
	);
	
-- 2. Imported the data using PDadmin's GUI.

-- Import Analytics FILE	
-- 1. Create the table

CREATE TABLE analytics (
	visitNumber VARCHAR(255),
	visitid VARCHAR(255),
	visitStartTime VARCHAR(255),
	date VARCHAR(255),
	fullvisitorId VARCHAR(255),
	userid VARCHAR(255),
	channelGrouping VARCHAR(255),
	socialEngagementType VARCHAR(255),
	units_sold VARCHAR(255),
	pageviews VARCHAR(255),
	timeonsite VARCHAR(255),
	bounces VARCHAR(255),
	revenue VARCHAR(255),
	unit_price VARCHAR(255)
	);
	
-- 2. Imported the data using PDadmin's GUI.

-- Test and make sure data was imported into tables

-- Find null values

SELECT 	currencycode
FROM	all_sessions
limit 5000


SELECT
	COUNT(*) AS null_count
FROM
	all_sessions
WHERE date IS NULL

-- Remove duplicates

SELECT 	*
FROM	sales_report
limit 5000

SELECT productsku, COUNT(*)
FROM sales_report
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 1

-- Formatting

SELECT *
FROM all_sessions
WHERE CAST(productprice AS NUMERIC) BETWEEN 0 AND 100
LIMIT 1000

SELECT (CAST(productprice AS FLOAT)/1000000)
FROM all_sessions

