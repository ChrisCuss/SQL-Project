# Final-Project-Transforming-and-Analyzing-Data-with-SQL

## Technology Used
	- PostgreSQL
	- PosgreSQL Documentation
	- pgAdmin
	- ChatGPT (For Syntax search and to help structure my readme writing Only)
	- Google Search

## Project/Goals

This project serves to show the application of the skills and concepts we learned throughout the first 6 weeks of the course. The objectives include:

	- Data Extraction: Retrieve data from a SQL database for further manipulation.
	- Data Transformation and Analysis: Clean and transform the raw data to facilitate analysis.
	- Data Loading: Import the transformed data back into a database.
	- Quality Assurance: Implement a robust QA process to validate the transformed data against its raw counterpart.

## Process
### Step 1: Import data to PGadmin
### Step 2: Clean the data (Missing Values, Duplicates, Formatting, Outliers, etc)
### Step 3: QA the data
### Step 4: Run queries to answer all the questions in starting_with_questions
### Step 5: Create 3 new questions and answer them using quieries in the starting_with_questions

## Results
	- This data is likely from an online store.
	- The countries with the most customers are US, Israel and Australia.
	- The top cities are San Francisco, Sunnyvale and Atlanta.
	- The category that has the most products sold is Home/Apparel/Men's/Men's-T-Shirts/.
	- Top products sold are Google Men's 100% Cotton Short Sleeve Hero Tee White and YouTube Custom Decals.
	- The USA representa over 85% of this website's revenue.

## Challenges 
	- Not knowing the context of the data.
	- Data was very ''dirty'' and unorganised.
	- The data contained way to many null values in a lot of columns.
	- Some columns in tables seemed like they belonged in a completely different table. i.e most of the columns from the all_sessions table.
	- Having to backup the database multiple times due to how many changes were needed to be made to a lot of the data.
	- Without context, it was difficult to assess the importance and impact of any outlier values that were found.

## Future Goals
	- If I had more time I'd create Views, Temp tables or just create new additional tables. This would have come in handy when cleaning the data and eliminating some of the columns without loosing the original data.
	- Some of the datatypes for my columns aren't the most efficient. If I had more time I'd go throughe every VARCHAR column and set the column to only accept a specific number of characters insead of the blanket VARCHACHAR(255). Specially in the analytics table where this could help optimize and speed up queries.

