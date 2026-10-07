
USE ecommerce_analytics;

-- =============================================
-- STEP 1 : CREATE ALL TABLES
-- =============================================

-- 1. CUSTOMERS
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE
);


-- 2. CATEGORIES
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE NOT NULL
);


-- 3. PRODUCTS
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT,
    price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    stock_quantity INT,

    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);


-- 4. ORDERS
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(30),
    total_amount DECIMAL(10,2),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- 5. ORDER ITEMS
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


-- 6. PAYMENTS
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATE,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),
    amount DECIMAL(10,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


-- 7. SHIPMENTS
CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    shipped_date DATE,
    delivered_date DATE,
    delivery_status VARCHAR(30),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


-- 8. INVENTORY
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    warehouse VARCHAR(100),
    stock_quantity INT,
    last_updated DATE,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


-- =============================================
-- VERIFY TABLES
-- =============================================

SHOW TABLES;