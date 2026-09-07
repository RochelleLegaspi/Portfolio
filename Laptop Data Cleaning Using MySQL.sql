CREATE TABLE raw_laptop_staging
LIKE raw_laptop;

SELECT*
FROM raw_laptop_staging;

INSERT raw_laptop_staging
SELECT *
FROM raw_laptop;

SELECT *,
ROW_NUMBER() OVER(
partition by 'MyUnknownColumn', Title, Rating, 'Rating Count and Reviews', 'Current Price', 'Original Price', 
Discount, Processor, 'RAM Capacity', 'Operating System', 'SSD Capacity', 'screen Size') AS row_num
FROM raw_laptop_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
partition by 'MyUnknownColumn', Title, Rating, 'Rating Count and Reviews', 'Current Price', 'Original Price', 
Discount, Processor, 'RAM Capacity', 'Operating System', 'SSD Capacity', 'Screen Size') AS row_num
FROM raw_laptop_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `raw_laptop_staging2` (
  `MyUnknownColumn` int DEFAULT NULL,
  `Title` text,
  `Rating` text,
  `Rating Count and Reviews` text,
  `Current Price` text,
  `Original Price` text, 
  `Discount` text,
  `Processor` text,
  `RAM Capacity` text,
  `Operating System` text,
  `SSD Capacity` text,
  `Screen Size` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO raw_laptop_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY 'MyUnknownColumn', Title, Rating, 'Rating Count and Reviews', 'Current Price', 'Original Price', 
Discount, Processor, 'RAM Capacity', 'Operating System', 'SSD Capacity', 'Screen Size' 
) AS row_num
FROM raw_laptop_staging;

SELECT *
FROM raw_laptop_staging2;

DELETE 
FROM raw_laptop_staging2
WHERE row_num > 1;

SELECT *
FROM raw_laptop_staging2
WHERE row_num > 1;

UPDATE raw_laptop_staging2
SET `Rating Count and Reviews` = REPLACE(`Rating Count and Reviews`, '', ' ');

SELECT `Rating Count and Reviews`,
	TRIM(SUBSTRING_INDEX(`Rating Count and Reviews`, '&', 1)) AS rating_count,
	TRIM(SUBSTRING_INDEX(`Rating Count and Reviews`, '&', -1)) AS reviews_count
FROM raw_laptop_staging2;

ALTER TABLE raw_laptop_staging2
ADD COLUMN rating_counts VARCHAR(20),
ADD COLUMN reviews_count VARCHAR(20);

UPDATE raw_laptop_staging2
SET rating_counts = TRIM(SUBSTRING_INDEX(`Rating Count and Reviews`, '&', 1));

UPDATE raw_laptop_staging2
SET reviews_count = TRIM(SUBSTRING_INDEX(`Rating Count and Reviews`, '&', -1));

ALTER TABLE raw_laptop_staging2
DROP COLUMN `Rating Count and Reviews`;

UPDATE raw_laptop_staging2
SET `Current Price` = REPLACE(`Current Price`, ',', '');

UPDATE raw_laptop_staging2
SET `Original Price` = REPLACE(`Original Price`, ',', '');

UPDATE raw_laptop_staging2
SET `Current Price` = REPLACE(`Current Price`, 'â‚¹', '');

UPDATE raw_laptop_staging2
SET `Original Price` = REPLACE(`Original Price`, 'â‚¹', '');

ALTER TABLE raw_laptop_staging2
ADD COLUMN brand VARCHAR(255)
AS (SUBSTRING_INDEX(Title, ' ', 1)) STORED;

 SELECT *
 FROM raw_laptop_staging2
 WHERE Discount IS NULL
 OR Discount = '';
 
 DELETE
 FROM raw_laptop_staging2
 WHERE Discount = '';

ALTER TABLE raw_laptop_staging2
DROP COLUMN MyUnknownColumn;

SELECT *
FROM raw_laptop_staging2;

UPDATE raw_laptop_staging2
SET `Discount` = REPLACE(REPLACE(`Discount`, '%', ''), 'off', '');

UPDATE raw_laptop_staging2
SET `rating_counts` = REPLACE(`rating_counts`, 'Ratings', '');

UPDATE raw_laptop_staging2
SET `reviews_count` = REPLACE(`reviews_count`, 'Reviews', '');

ALTER TABLE raw_laptop_staging2
DROP COLUMN row_num;

SELECT *
FROM raw_laptop_staging2;

DESCRIBE raw_laptop_staging2;

ALTER TABLE raw_laptop_staging2
MODIFY COLUMN `Original Price` INT;

ALTER TABLE raw_laptop_staging2
MODIFY `brand` VARCHAR(255) AFTER `Title`;

ALTER TABLE raw_laptop_staging2
MODIFY `Current Price` INT AFTER `Rating`; 

ALTER TABLE raw_laptop_staging2
MODIFY `rating_counts` VARCHAR(20) AFTER `Rating`;

ALTER TABLE raw_laptop_staging2
MODIFY `reviews_count` VARCHAR(20) AFTER `Rating`;

SELECT *
FROM raw_laptop_staging2
WHERE `Screen Size` NOT LIKE '%inch'
ORDER BY 1;

SELECT *
FROM raw_laptop_staging2
WHERE `Original Price` = '32990'
ORDER BY 1;

UPDATE raw_laptop_staging2
SET `brand` = 'ASUS'
WHERE  `brand` = 'bebi';

UPDATE raw_laptop_staging2
SET `Operating System` = CASE 
		WHEN `Operating System` = 'DOS Operating System' THEN 'Disk Operating System'
        WHEN `Operating System` = '32 bit Windows 11 Operating System' THEN 'Windows 11 Operating system'
        WHEN `Operating System` = '64 bit Windows 11 Operating System' THEN 'Windows 11 Operating system'
        WHEN `Operating System` = '64 bit Chrome Operating System' THEN 'Chrome Operating System'
        WHEN `Operating System` = 'Windows 10 Operating System' THEN 'Windows 10 Operating System' 
        WHEN `Operating System` = '64 bit Windows 10 Operating System' THEN 'Windows 10 Operating System'
        WHEN `Operating System` = 'Chrome Operating System' THEN 'Chrome Operating System'
        WHEN `Operating System` = 'Windows 11 Operating System' THEN 'Windows 11 Operating System'
		WHEN `Operating System` = '64 bit Windows 11 Home Operating System' THEN 'Windows 11 Home Operating system'
        WHEN `Operating System` = 'Windows 11 Home' THEN 'Windows 11 Home Operating System'
        WHEN `Operating System` = 'Windows 10' THEN 'Windows 10 Operating System'
		WHEN `Operating System` = 'Windows 11' THEN 'Windows 11 Operating System' 
		WHEN `Operating System` = 'Mac OS Operating System' THEN 'Mac OS Operating System'
		WHEN `Operating System` = 'Windows 10 Home' THEN 'Windows 10 Home Operating System'
        WHEN `Operating System` = 'Windows 11 Home Operating System' THEN 'Windows 11 Home Operating System'
        WHEN `Operating System` = 'Linux/Ubuntu Operating System' THEN 'Linux/Ubuntu Operating System'
        WHEN `Operating System` = 'Prime OS Operating System' THEN 'Prime OS Operating System'
        WHEN `Operating System` = 'Android Operating System' THEN 'Android Operating System'
END;

UPDATE raw_laptop_staging2
SET `RAM Capacity` = TRIM(`RAM Capacity`);

UPDATE raw_laptop_staging2
SET `SSD Capacity`= TRIM(SUBSTRING_INDEX(`SSD Capacity`, ' ', 2));

UPDATE raw_laptop_staging2 
SET `RAM Capacity`= TRIM(SUBSTRING_INDEX(`RAM Capacity`, ' ', 1));

UPDATE raw_laptop_staging2
SET `Screen Size` = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(`Screen Size`, '(', -1), ')', 1));

DELETE 
FROM raw_laptop_staging2
WHERE Rating = ''
AND reviews_count = ''
AND rating_counts = '';
