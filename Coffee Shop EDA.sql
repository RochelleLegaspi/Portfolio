CREATE TABLE coffeeshop_staging
LIKE coffeeshop;

INSERT coffeeshop_staging
SELECT *
FROM coffeeshop;

SELECT *
FROM coffeeshop_staging; 

SELECT *,
ROW_NUMBER() OVER(partition by `ï»¿transaction_id`, transaction_date, transaction_time, transaction_qty, store_id, 
store_location, product_id, unit_price, product_category, product_type, product_detail) AS row_num
FROM coffeeshop_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
partition by `ï»¿transaction_id`, transaction_date, transaction_time, transaction_qty, store_id, 
store_location, product_id, unit_price, product_category, product_type, product_detail) AS row_num
FROM coffeeshop_staging
)
SELECT row_num
FROM duplicate_cte
Order by 1 DESC;

CREATE TABLE `coffeeshop_staging2` (
  `ï»¿transaction_id` int DEFAULT NULL,
  `transaction_date` text,
  `transaction_time` text,
  `transaction_qty` int DEFAULT NULL,
  `store_id` int DEFAULT NULL,
  `store_location` text,
  `product_id` int DEFAULT NULL,
  `unit_price` double DEFAULT NULL,
  `product_category` text,
  `product_type` text,
  `product_detail` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO coffeeshop_staging2
SELECT *,
ROW_NUMBER() OVER(
partition by `ï»¿transaction_id`, transaction_date, transaction_time, transaction_qty, store_id, 
store_location, product_id, unit_price, product_category, product_type, product_detail) AS row_num
FROM coffeeshop_staging;

ALTER TABLE coffeeshop_staging2
DROP row_num;

-- no duplicate, proceed to analyzing data

SELECT *
FROM coffeeshop_staging2;

-- Which products are sold most and least often? Which drive the most revenue for the business?

ALTER TABLE coffeeshop_staging2
ADD COLUMN revenue DECIMAL(10.2) AFTER unit_price;

UPDATE coffeeshop_staging2
SET revenue = unit_price*transaction_qty;

WITH product_cte AS (
	SELECT product_category,
		   COUNT(*) AS products,
           SUM(transaction_qty) AS total_items_sold
	FROM coffeeshop_staging2
    GROUP BY product_category
),
revenue_cte AS (
	SELECT product_category,
           ROUND(SUM(unit_price*transaction_qty),0) as total_revenue
    FROM coffeeshop_staging2
    GROUP BY product_category
),
ranked_revenue AS(
	SELECT product_category,
           total_revenue, 
		   RANK() OVER(ORDER BY total_revenue DESC) AS highest_revenue
	FROM revenue_cte
)
SELECT *
FROM product_cte AS pr
JOIN ranked_revenue AS rr
	ON pr.product_category = rr.product_category
ORDER BY total_items_sold DESC;

-- What times of day tend to be most popular? Does the same trend hold across all locations?

WITH hourly_traffic AS 
(
	SELECT store_location,
    HOUR(transaction_time) AS hour_of_day,
    COUNT(*) AS total_transactions
	FROM coffeeshop_staging2
    GROUP BY store_location, HOUR(transaction_time)
),
ranked_traffic AS (
	SELECT store_location,
           hour_of_day,
           total_transactions, 
    RANK() OVER(PARTITION BY store_location ORDER BY total_transactions DESC) AS popularity_rank
    FROM hourly_traffic
)
SELECT store_location, 
	   hour_of_day,
	   total_transactions,
	   popularity_rank
FROM ranked_traffic
WHERE popularity_rank = 1
ORDER BY store_location, popularity_rank;

-- The 10 in the evening tend to be the most popular among all three store locations.--

-- Which days of the week tend to be the busiest, and why do you think that’s the case?

SELECT transaction_date,
STR_TO_DATE(transaction_date, '%m/%d/%Y')
FROM coffeeshop_staging2;

UPDATE coffeeshop_staging2
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

SELECT DAYNAME(transaction_date) AS day_of_week,
	   COUNT(*) AS total_orders
FROM coffeeshop_staging2
GROUP BY DAYOFWEEK(transaction_date), day_of_week
ORDER BY total_orders DESC;

-- How have coffee shop sales trended over time?

SELECT DATE_FORMAT(transaction_date, '%Y/%m')AS sale_month, 
	   SUM(revenue) AS total_revenue
FROM coffeeshop_staging2
GROUP BY sale_month
ORDER BY sale_month ASC;

-- the first month of 2023 had 83888, but there was a decline at the second month to 78246. 
-- However, we can observe significant growth over the next four consecutive months. 

-- What happened to the 2nd month that makes the revenue decline?

SELECT DATE_FORMAT(transaction_date, '%Y/%m')AS sale_month,
       COUNT(`ï»¿transaction_id`) as customers,
       product_category,
       SUM(revenue) AS total_revenue
FROM coffeeshop_staging2
WHERE MONTH(transaction_date) = 2
GROUP BY sale_month, product_category
ORDER BY total_revenue ASC;

-- February of 2023 had a fewer customer visits than the other months, which explains why the revenue was lower.
       
       