-- Step 1: Data Overview
SELECT *
FROM merch_table
LIMIT 10;

-- Step 2: Overall business performance
SELECT
	COUNT(order_id) AS Total_no_of_Orders, -- Total number of orders
    SUM(total_sales) AS Total_sum_of_Sales, -- Total Sales
    SUM(quantity) AS Total_no_of_Quantity, -- Total quantity sold
	ROUND(SUM(total_sales) /  SUM(quantity), 2) AS Average_Order_Value, -- Average order value
	COUNT(DISTINCT product_id) AS Total_no_of_unique_products-- Number of unique products (customer ID not available in dataset)
FROM merch_table;

-- Step 3: Revenue analysis
-- Total Revenue metric using available price, shipping, and quantity data
SELECT
    SUM(total_sales) AS estimated_revenue
FROM merch_table;

-- Total revenue by Product Category
SELECT
    product_category,
    ROUND(SUM(total_sales), 2) AS revenue,
    COUNT(*) AS total_orders
FROM merch_table
GROUP BY product_category
ORDER BY revenue DESC;

-- Revenue contribution by Product ID
SELECT
    product_id,
    SUM(total_sales) AS revenue,
    COUNT(*) AS total_orders
FROM merch_table
GROUP BY product_id
ORDER BY revenue DESC;

-- Revenue per order location
SELECT
    order_location,
    SUM(total_sales) AS revenue,
    COUNT(*) AS total_orders
FROM merch_table
GROUP BY order_location
ORDER BY revenue DESC;
    
-- Highest and lowest performing products
WITH Product_performance AS (
    SELECT 
		product_id,
		SUM(total_sales) AS Total_sum_of_Sales
    FROM merch_table
    GROUP BY product_id
    )
    SELECT *
    FROM Product_performance
    WHERE Total_sum_of_Sales = (SELECT MAX(Total_sum_of_Sales) FROM Product_performance)
    OR Total_sum_of_Sales = (SELECT MIN(Total_sum_of_Sales) FROM Product_performance);
    
-- Step 4: Buyer behavior analysis
-- Sales distribution by Buyer Gender
SELECT
    buyer_gender,
    product_category,
    SUM(total_sales) AS Total_sum_of_Sales
FROM merch_table
GROUP BY buyer_gender, product_category
ORDER BY product_category;

-- Average spending by age groups
SELECT
    CASE 
	WHEN buyer_age BETWEEN 18 AND 21 THEN '18–21 (Students)'
    WHEN buyer_age BETWEEN 22 AND 25 THEN '22–25 (Early Adults)'
    WHEN buyer_age BETWEEN 26 AND 30 THEN '26–30 (Young Professionals)'
    ELSE '31–35 (Established Adults)'
    END AS age_group,
    ROUND(AVG(total_sales), 2) AS avg_spending
FROM merch_table
GROUP BY age_group
ORDER BY age_group;

-- Identify top spending customer segments
SELECT 
    CASE 
	WHEN buyer_age BETWEEN 18 AND 21 THEN '18–21 (Students)'
    WHEN buyer_age BETWEEN 22 AND 25 THEN '22–25 (Early Adults)'
    WHEN buyer_age BETWEEN 26 AND 30 THEN '26–30 (Young Professionals)'
    ELSE '31–35 (Established Adults)'
    END AS age_group,
    product_category,
    buyer_gender,
    order_location,
    SUM(total_sales) AS total_spending
FROM merch_table
GROUP BY age_group, buyer_gender, order_location, product_category
ORDER BY total_spending DESC;

-- Step 5: Customer segmentation layer
-- Group customers into spending tiers (Low, Medium, High value) Based on total spend
SELECT 
	age_group,
    buyer_gender,
    CASE
		WHEN tile = 1 THEN 'LOW'
		WHEN tile = 2 THEN 'MEDIUM'
		ELSE 'HIGH'
    END AS customer_tier
FROM (
    SELECT 
		buyer_gender,
		CASE 
		WHEN buyer_age BETWEEN 18 AND 21 THEN '18–21 (Students)'
		WHEN buyer_age BETWEEN 22 AND 25 THEN '22–25 (Early Adults)'
		WHEN buyer_age BETWEEN 26 AND 30 THEN '26–30 (Young Professionals)'
		ELSE '31–35 (Established Adults)'
		END AS age_group,
		SUM(total_sales) AS total_spending,

        NTILE(3) OVER (ORDER BY SUM(total_sales)) AS tile
		FROM 
			merch_table
		GROUP BY buyer_gender, age_group
	) AS t 
ORDER BY customer_tier;

-- Step 6: Location-based insights
-- Total sales by Order Location
SELECT
	order_location,
	SUM(total_sales) AS Total_sum_of_Sales
FROM
	merch_table
GROUP BY order_location
ORDER BY Total_sum_of_Sales DESC;

-- Domestic vs international shipping performance
SELECT
	international_shipping,
	SUM(total_sales) AS Total_sum_of_Sales
FROM
	merch_table
GROUP BY international_shipping
ORDER BY Total_sum_of_Sales desc;

-- Top performing regions
SELECT
	order_location,
	SUM(total_sales) AS Total_sum_of_Sales
FROM
	merch_table
GROUP BY order_location
ORDER BY Total_sum_of_Sales DESC
LIMIT 3;

-- Underperforming regions
SELECT
	order_location,
	SUM(total_sales) AS Total_sum_of_Sales
FROM
	merch_table
GROUP BY order_location
ORDER BY Total_sum_of_Sales
LIMIT 3;

-- Step 7: Shipping analysis
-- International Shipping vs local orders
SELECT
	international_shipping,
    product_category,
	SUM(total_sales) AS Total_sum_of_Sales
FROM
	merch_table
GROUP BY international_shipping, product_category
ORDER BY product_category, international_shipping;

-- Shipping_charges range distribution
SELECT
    shipping_charges,
    COUNT(*) AS frequency
FROM merch_table
WHERE shipping_charges > 0
GROUP BY shipping_charges
ORDER BY shipping_charges;

-- Relationship between shipping cost and order volume
SELECT
    CASE 
        WHEN shipping_charges < 40 THEN 'Low Shipping Charge'
        WHEN shipping_charges BETWEEN 40 AND 65 THEN 'Medium Shipping Charge'
        ELSE 'High Shipping Charge'
    END AS shipping_range,
    COUNT(*) AS total_orders,
    ROUND(AVG(total_sales), 2) AS avg_sales,
    ROUND(SUM(total_sales), 2) AS total_revenue
FROM merch_table
WHERE shipping_charges > 0
GROUP BY shipping_range
ORDER BY total_revenue DESC;

-- Step 8: Product satisfaction analysis
-- Average rating per product category
SELECT
	product_category,
    AVG(rating) AS average_rating
FROM merch_table
GROUP BY product_category
ORDER BY average_rating DESC;

-- Correlation between rating and sales
SELECT
    SUM(total_sales) AS sales_per_product_rating,
    rating
FROM merch_table
GROUP BY rating
ORDER BY rating DESC;

-- Correlation between rating and orders
SELECT
    rating,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(total_sales), 2) AS avg_sales
FROM merch_table
GROUP BY rating
ORDER BY rating DESC;

-- Products with high sales but low ratings
SELECT
    product_category,
    COUNT(*) AS low_rating_orders,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(SUM(total_sales), 2) AS total_sales
FROM merch_table
WHERE rating <= 2
GROUP BY product_category
ORDER BY low_rating_orders DESC;    

-- Products with high ratings but low sales (hidden opportunities)
SELECT
    product_category,
    COUNT(*) AS high_rating_orders,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(SUM(total_sales), 2) AS total_sales
FROM merch_table
WHERE rating > 3
GROUP BY product_category
ORDER BY high_rating_orders DESC;

-- Step 9: Time series analysis
-- Daily order patterns
SELECT
    DAYNAME(order_date) AS day_of_week,
    SUM(total_sales) AS revenue,
    COUNT(*) AS total_orders,
    ((SUM(total_sales)) / (COUNT(*))) AS avg_order_value
FROM merch_table
GROUP BY day_of_week
ORDER BY revenue DESC;

-- Weekly sales trends
SELECT 
	YEAR(order_date) AS order_year,
	WEEK(order_date) AS order_week,
    SUM(total_sales) AS weekly_revenue,
    COUNT(*) AS total_orders
FROM merch_table
GROUP BY  order_year, order_week
ORDER BY  weekly_revenue DESC;

-- Monthly sales trends
SELECT
	YEAR(order_date) AS order_year,
    MONTHNAME(order_date) AS month,
    SUM(total_sales) AS monthly_revenue,
    COUNT(*) AS monthly_orders
FROM merch_table
GROUP BY month, order_year
ORDER BY monthly_revenue DESC;

-- Seasonal performance changes
WITH monthly_totals AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS month,
        SUM(total_sales) AS monthly_revenue
    FROM merch_table
    GROUP BY order_year, month
)
SELECT *,
       LAG(monthly_revenue) OVER (ORDER BY order_year, month) AS prev_revenue,
       monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_year, month) AS rev_diff
FROM monthly_totals;