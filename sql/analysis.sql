-- Calculating Total Revenue
SELECT ROUND(SUM(payment_value),2)
AS "Total Revenue"
FROM order_payments;

-- Calculating Total Order
SELECT COUNT(DISTINCT order_id) as "Total Orders"
FROM orders;

-- Calculating Average Order Value
SELECT ROUND(SUM(payment_value)/COUNT(DISTINCT order_id),2)
AS "Average Order Value"
FROM order_payments;

-- Select the 10 most sold product data
SELECT product_id,
COUNT(*) total_sales
FROM order_items
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

-- Select 10 sellers data with the most sales
SELECT seller_id, SUM(price) revenue
FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;

-- Shows total sales in each country
SELECT c.customer_state, SUM(p.payment_value)
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY SUM(p.payment_value) DESC;

-- Displays total sales for each month
SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
SUM(p.payment_value) AS revenue
FROM orders o
JOIN order_payments p
ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- Customer Satisfaction
SELECT AVG(review_score) as "Customer Satisfaction"
FROM order_reviews;

-- Average performance in delivery time
SELECT AVG( order_delivered_customer_date - order_purchase_timestamp )
AS "Delivery Performance"
FROM orders;

-- Calculate each customer segment
WITH customer_orders AS (
SELECT customer_id, COUNT(order_id) total_orders
FROM orders
GROUP BY customer_id
)
SELECT CASE
WHEN total_orders = 1
THEN 'One-Time'
WHEN total_orders BETWEEN 2 AND 5
THEN 'Repeat'
ELSE 'Loyal'
END AS segment, COUNT(*)
FROM customer_orders
GROUP BY segment;

-- Ranking sellers by sales
SELECT seller_id, SUM(price) revenue, RANK() OVER(ORDER BY SUM(price) DESC)
FROM order_items
GROUP BY seller_id;