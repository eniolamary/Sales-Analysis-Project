-- Data Cleaning and standardization
-- Remove duplicates
DELETE FROM merch_table
WHERE order_id IN (
    SELECT order_id FROM (
        SELECT order_id,
               ROW_NUMBER() OVER (
                   PARTITION BY order_id, product_id, product_category, buyer_gender,
                                buyer_age, order_location, international_shipping,
                                sales_price, shipping_charges, sales_per_unit,
                                quantity, total_sales, rating, review
                   ORDER BY order_date
               ) AS rn
        FROM merch_table
    ) t
    WHERE rn > 1
);

-- Validate numeric fields (Sales Price, Quantity, Total Sales)
SELECT
    SUM(CASE WHEN sales_price IS NULL OR sales_price < 0 THEN 1 ELSE 0 END) AS invalid_sales_price,
    SUM(CASE WHEN quantity IS NULL OR quantity < 0 THEN 1 ELSE 0 END) AS invalid_quantity,
    SUM(CASE WHEN total_sales IS NULL OR total_sales < 0 THEN 1 ELSE 0 END) AS invalid_total_sales
FROM merch_table;

-- Standardize date column
ALTER TABLE merch_table-- Add temporary clean date column 
ADD COLUMN clean_order_date DATE;

UPDATE merch_table -- Convert and populate dates
SET clean_order_date = STR_TO_DATE(order_date, '%d/%m/%Y');

ALTER TABLE merch_table -- Remove old column and rename clean column
DROP COLUMN order_date,
CHANGE clean_order_date order_date DATE;