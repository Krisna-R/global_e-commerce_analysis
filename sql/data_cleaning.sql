-- Clean a Duplicate data on Geolocation Master Table 
CREATE TEMP TABLE stage_geolocation_master (
    zip_code_prefix INTEGER,
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    city VARCHAR(100),
    state VARCHAR(10)
);

COPY stage_geolocation_master
FROM '...\data\raw\olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO geolocation_master (zip_code_prefix, latitude, longitude, city, state)
SELECT zip_code_prefix, latitude, longitude, city, state 
FROM stage_geolocation_master
ON CONFLICT (zip_code_prefix) DO NOTHING;

DROP TABLE stage_geolocation_master 

-- Copying customers data
CREATE TEMP TABLE staging_customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

COPY staging_customers
FROM '...\data\raw\olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO geolocation_master (zip_code_prefix)
SELECT DISTINCT s.customer_zip_code_prefix
FROM staging_customers s
LEFT JOIN geolocation_master g ON s.customer_zip_code_prefix = g.zip_code_prefix
WHERE g.zip_code_prefix IS NULL;

INSERT INTO customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
FROM staging_customers;

DROP TABLE staging_customer;

-- Copying sellers data
CREATE TEMP TABLE staging_seller(
    seller_id VARCHAR(50),
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
)

COPY staging_seller
FROM '...\data\raw\olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
FROM staging_seller;

DROP TABLE staging_seller;

-- Copying Product Category Translation data
COPY order_items
FROM '...\data\raw\product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;

-- Copying products data
CREATE TEMP TABLE staging_products(
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
)

COPY staging_products
FROM '...\data\raw\olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO product_category_translation (product_category_name, product_category_name_english)
SELECT DISTINCT s.product_category_name, s.product_category_name
FROM staging_products s
LEFT JOIN product_category_translation t ON s.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL 
  AND s.product_category_name IS NOT NULL;

INSERT INTO products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm
FROM staging_products;

DROP TABLE staging_products;

-- Copying Orders data
COPY orders
FROM '...\data\raw\olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Copying Order Reviews data
CREATE TEMP TABLE staging_or(
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY staging_or
FROM '...\data\raw\olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
SELECT review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp 
FROM staging_or
ON CONFLICT (review_id) DO NOTHING;

drop table staging_or

-- Copying Order Payments data
COPY order_payments
FROM '...\data\raw\olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Copying Orders Items data
COPY order_items
FROM '...\data\raw\olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Change unfilled categories to uncategorized
INSERT INTO product_category_translation
(
    product_category_name,
    product_category_name_english
)
VALUES
(
    'uncategorized',
    'Uncategorized'
);
UPDATE products
SET product_category_name = 'uncategorized'
WHERE product_category_name IS NULL;

-- Make an Uncategorized Product as a View
CREATE VIEW uncategorized_product AS
SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products
WHERE product_category_name = 'uncategorized';

-- Changing null data in Product Dimension
UPDATE products
SET product_weight_g =
(
SELECT AVG(product_weight_g)
FROM products
)
WHERE product_weight_g IS NULL;

UPDATE products
SET product_length_cm = (
SELECT AVG(product_length_cm)
FROM products
)
WHERE product_length_cm IS NULL;

UPDATE products
SET product_height_cm = (
SELECT AVG(product_height_cm)
FROM products
)
WHERE product_height_cm IS NULL;

UPDATE products
SET product_width_cm = (
SELECT AVG(product_width_cm)
FROM products
)
WHERE product_width_cm IS NULL;

-- Geolocation Cleaning
SELECT zip_code_prefix,
COUNT(*)
FROM geolocation_master
GROUP BY zip_code_prefix
HAVING COUNT(*) > 1;

-- Validate that the geolocation is in the location of Brazil
SELECT COUNT(*)
FROM geolocation_master
WHERE latitude < -33.75
OR latitude > 5.27
OR longitude < -73.99
OR longitude > -34.79;

-- Performing Data Log on invalid geolocation data
ALTER TABLE geolocation_master
ADD COLUMN geo_validation_status VARCHAR(20);

UPDATE geolocation_master
SET geo_validation_status =
CASE
    WHEN latitude < -33.75
      OR latitude > 5.27
      OR longitude < -73.99
      OR longitude > -34.79
    THEN 'suspect'
    ELSE 'valid'
END;