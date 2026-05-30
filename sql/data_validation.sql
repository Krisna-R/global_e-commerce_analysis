-- Check the amount of data in each table
SELECT COUNT(*) as "Total Customers" FROM customers;
SELECT COUNT(*) as "Total Seller" FROM sellers;
SELECT COUNT(*) as "Total Product" FROM products;
SELECT COUNT(*) as "Total Order" FROM orders;
SELECT COUNT(*) as "Total Order Items" FROM order_items;
SELECT COUNT(*) as "Total Payments" FROM order_payments;
SELECT COUNT(*) as "Order Reviews" FROM order_reviews;
SELECT COUNT(*) as "Total Geolocation" FROM geolocation_master;

-- Referential Integrity Check
SELECT o.order_id
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT oi.product_id
FROM order_items oi
LEFT JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT oi.seller_id
FROM order_items oi
LEFT JOIN sellers s
ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Invalid Value Check
SELECT *
FROM order_reviews
WHERE review_score < 1
OR review_score > 5;

SELECT *
FROM order_payments
WHERE payment_value < 0;

SELECT *
FROM order_items
WHERE freight_value < 0;

SELECT *
FROM products
WHERE product_weight_g < 0;

SELECT *
FROM products
WHERE product_length_cm < 0;

SELECT *
FROM products
WHERE product_height_cm < 0;

SELECT *
FROM products
WHERE product_width_cm < 0;

-- Missing Value Check
SELECT *
FROM customers
WHERE customer_id IS NULL
OR customer_unique_id IS NULL;

SELECT *
FROM orders
WHERE order_purchase_timestamp IS NULL;

SELECT COUNT(*)
FROM orders
WHERE order_purchase_timestamp IS NULL;
(Tidak ada yang NULL)

SELECT
COUNT(*) FILTER (
WHERE product_category_name IS NULL
) AS missing_category,

COUNT(*) FILTER (
WHERE product_weight_g IS NULL
) AS missing_weight,

COUNT(*) FILTER (
WHERE product_length_cm IS NULL
) AS missing_length

FROM products;

-- Duplicate Data Check
SELECT
customer_id,
COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
order_id,
COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
product_id,
COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Business Logic Validation
SELECT *
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

SELECT *
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;

SELECT *
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

-- Outlier Detection
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_translation t
ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL;

SELECT *
FROM order_payments
ORDER BY payment_value DESC
LIMIT 20;

SELECT *
FROM order_items
ORDER BY freight_value DESC
LIMIT 20;