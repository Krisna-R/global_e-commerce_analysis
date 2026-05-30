-- Create a Customers table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Create a Orders table and Connect it to Customers table using a Foreign Key
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY(customer_id)
        REFERENCES customers(customer_id)
);

-- Create a Products table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- Create a Sellers table
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- Create a Order Items table and Connect it to Orders table, Products table, and Sellers table using a Foreign Key
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),

    PRIMARY KEY(order_id, order_item_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_items_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id),
    CONSTRAINT fk_items_seller
        FOREIGN KEY(seller_id)
        REFERENCES sellers(seller_id)
);

-- Create a Order Payments table and Connect it to Orders table using a Foreign Key
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(12,2),

    PRIMARY KEY(order_id, payment_sequential),
    CONSTRAINT fk_payment_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id)
);

-- Create a Order Reviews table and Connect it to Orders table using a Foreign Key
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    PRIMARY KEY(review_id),
    CONSTRAINT fk_review_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id)
);

-- Create a Geolocation Master table 
CREATE TABLE geolocation_master (
    zip_code_prefix INTEGER PRIMARY KEY,
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    city VARCHAR(100),
    state VARCHAR(10)
);

-- Connect a Customers table to Geolocation Master table using a Foreign Key
ALTER TABLE customers
ADD CONSTRAINT fk_customer_geo
FOREIGN KEY(customer_zip_code_prefix)
REFERENCES geolocation_master(zip_code_prefix);

-- Connect a Sellers table to Geolocation Master table using a Foreign Key
ALTER TABLE sellers
ADD CONSTRAINT fk_seller_geo
FOREIGN KEY(seller_zip_code_prefix)
REFERENCES geolocation_master(zip_code_prefix);

-- Create a Product Category Translation table
CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- Connect a Products table to Product Category Translation table using a Foreign Key
ALTER TABLE products
ADD CONSTRAINT fk_product_translation
FOREIGN KEY(product_category_name)
REFERENCES product_category_translation(product_category_name);