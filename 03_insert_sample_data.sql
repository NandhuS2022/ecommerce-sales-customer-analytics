USE ecommerce_analytics;

-- =============================================
-- STEP 2 : INSERT SAMPLE DATA
-- =============================================


-- =============================================
-- 1. CATEGORIES
-- =============================================

INSERT INTO categories (category_name)
VALUES
('Electronics'),
('Clothing'),
('Home Appliances'),
('Books'),
('Sports');


-- =============================================
-- 2. CUSTOMERS
-- =============================================

INSERT INTO customers
(first_name, last_name, email, city, state, signup_date)
VALUES
('Arun', 'Kumar', 'arun@gmail.com', 'Chennai', 'Tamil Nadu', '2024-01-15'),
('Priya', 'Sharma', 'priya@gmail.com', 'Bangalore', 'Karnataka', '2024-02-10'),
('Rahul', 'Verma', 'rahul@gmail.com', 'Mumbai', 'Maharashtra', '2024-03-05'),
('Divya', 'Raj', 'divya@gmail.com', 'Coimbatore', 'Tamil Nadu', '2024-03-20'),
('Karthik', 'S', 'karthik@gmail.com', 'Madurai', 'Tamil Nadu', '2024-04-12'),
('Vijay', 'Kumar', 'vijay@gmail.com', 'Chennai', 'Tamil Nadu', '2024-04-20'),
('Sneha', 'R', 'sneha@gmail.com', 'Hyderabad', 'Telangana', '2024-05-01'),
('Ajay', 'M', 'ajay@gmail.com', 'Chennai', 'Tamil Nadu', '2024-05-10'),
('Meena', 'Krishnan', 'meena@gmail.com', 'Bangalore', 'Karnataka', '2024-05-15'),
('Suresh', 'P', 'suresh@gmail.com', 'Madurai', 'Tamil Nadu', '2024-06-01'),
('Naveen', 'Raj', 'naveen@gmail.com', 'Salem', 'Tamil Nadu', '2024-06-10'),
('Harini', 'K', 'harini@gmail.com', 'Erode', 'Tamil Nadu', '2024-06-15'),
('Ramesh', 'Babu', 'ramesh@gmail.com', 'Trichy', 'Tamil Nadu', '2024-07-01'),
('Anitha', 'S', 'anitha@gmail.com', 'Bangalore', 'Karnataka', '2024-07-05'),
('Manoj', 'Kumar', 'manoj@gmail.com', 'Chennai', 'Tamil Nadu', '2024-07-10');


-- =============================================
-- 3. PRODUCTS
-- =============================================

INSERT INTO products
(product_name, category_id, price, cost_price, stock_quantity)
VALUES
('iPhone 15', 1, 69999, 60000, 50),
('Samsung Galaxy S24', 1, 64999, 55000, 40),
('Sony Headphones', 1, 8999, 6000, 60),
('Dell Wireless Mouse', 1, 1499, 900, 120),
('HP Keyboard', 1, 2499, 1500, 100),

('Levis Jeans', 2, 2999, 1800, 80),
('Adidas T-Shirt', 2, 1999, 1200, 90),
('Puma Hoodie', 2, 3499, 2200, 70),
('Roadster Shirt', 2, 1599, 900, 100),

('Mixer Grinder', 3, 3499, 2500, 70),
('Air Fryer', 3, 5999, 4200, 45),
('Electric Kettle', 3, 1999, 1200, 80),

('Atomic Habits', 4, 599, 350, 150),
('Rich Dad Poor Dad', 4, 499, 280, 120),
('The Psychology of Money', 4, 699, 400, 100),

('Nike Running Shoes', 5, 5999, 4000, 100),
('Adidas Sports Shoes', 5, 4999, 3200, 80),
('Yonex Badminton Racket', 5, 2499, 1600, 60);


-- =============================================
-- 4. ORDERS
-- =============================================

INSERT INTO orders
(customer_id, order_date, order_status, total_amount)
VALUES
(1,  '2024-05-01', 'Delivered', 69999),
(2,  '2024-05-03', 'Delivered', 5999),
(3,  '2024-05-05', 'Cancelled', 2999),
(1,  '2024-05-10', 'Delivered', 8999),
(4,  '2024-05-12', 'Shipped', 3499),
(5,  '2024-05-15', 'Delivered', 1198),
(6,  '2024-05-20', 'Delivered', 64999),
(7,  '2024-06-01', 'Delivered', 5999),
(8,  '2024-06-05', 'Shipped', 1999),
(9,  '2024-06-10', 'Delivered', 5999),
(10, '2024-06-15', 'Cancelled', 499),
(2,  '2024-06-20', 'Delivered', 8999),
(1,  '2024-07-01', 'Delivered', 5999),
(4,  '2024-07-05', 'Delivered', 3499),
(6,  '2024-07-10', 'Delivered', 2999),
(11, '2024-07-15', 'Delivered', 2499),
(12, '2024-07-20', 'Delivered', 1599),
(13, '2024-08-01', 'Shipped', 4999),
(14, '2024-08-05', 'Delivered', 699),
(15, '2024-08-10', 'Delivered', 2499),
(3,  '2024-08-15', 'Delivered', 3499),
(5,  '2024-08-20', 'Delivered', 5999),
(7,  '2024-09-01', 'Delivered', 69999),
(8,  '2024-09-05', 'Cancelled', 1599),
(9,  '2024-09-10', 'Delivered', 4999),
(10, '2024-09-15', 'Delivered', 5999),
(1,  '2024-09-20', 'Delivered', 3499),
(2,  '2024-10-01', 'Delivered', 8999),
(4,  '2024-10-05', 'Shipped', 2499),
(6,  '2024-10-10', 'Delivered', 5999);


-- =============================================
-- 5. ORDER ITEMS
-- =============================================

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1,  1, 1, 69999),
(2,  16, 1, 5999),
(3,  6, 1, 2999),
(4,  3, 1, 8999),
(5,  10, 1, 3499),
(6,  13, 2, 599),
(7,  2, 1, 64999),
(8,  16, 1, 5999),
(9,  7, 1, 1999),
(10, 16, 1, 5999),
(11, 14, 1, 499),
(12, 3, 1, 8999),
(13, 16, 1, 5999),
(14, 10, 1, 3499),
(15, 6, 1, 2999),
(16, 5, 1, 2499),
(17, 9, 1, 1599),
(18, 17, 1, 4999),
(19, 15, 1, 699),
(20, 18, 1, 2499),
(21, 8, 1, 3499),
(22, 16, 1, 5999),
(23, 1, 1, 69999),
(24, 9, 1, 1599),
(25, 17, 1, 4999),
(26, 16, 1, 5999),
(27, 10, 1, 3499),
(28, 3, 1, 8999),
(29, 5, 1, 2499),
(30, 16, 1, 5999);


-- =============================================
-- 6. PAYMENTS
-- =============================================

INSERT INTO payments
(order_id, payment_date, payment_method, payment_status, amount)
VALUES
(1,  '2024-05-01', 'Credit Card', 'Success', 69999),
(2,  '2024-05-03', 'UPI', 'Success', 5999),
(3,  '2024-05-05', 'UPI', 'Failed', 2999),
(4,  '2024-05-10', 'Credit Card', 'Success', 8999),
(5,  '2024-05-12', 'Cash', 'Success', 3499),
(6,  '2024-05-15', 'UPI', 'Success', 1198),
(7,  '2024-05-20', 'Debit Card', 'Success', 64999),
(8,  '2024-06-01', 'UPI', 'Success', 5999),
(9,  '2024-06-05', 'Credit Card', 'Success', 1999),
(10, '2024-06-10', 'UPI', 'Success', 5999),
(11, '2024-06-15', 'UPI', 'Failed', 499),
(12, '2024-06-20', 'Credit Card', 'Success', 8999),
(13, '2024-07-01', 'UPI', 'Success', 5999),
(14, '2024-07-05', 'Cash', 'Success', 3499),
(15, '2024-07-10', 'Credit Card', 'Success', 2999),
(16, '2024-07-15', 'UPI', 'Success', 2499),
(17, '2024-07-20', 'UPI', 'Success', 1599),
(18, '2024-08-01', 'Debit Card', 'Success', 4999),
(19, '2024-08-05', 'UPI', 'Success', 699),
(20, '2024-08-10', 'Credit Card', 'Success', 2499),
(21, '2024-08-15', 'Cash', 'Success', 3499),
(22, '2024-08-20', 'UPI', 'Success', 5999),
(23, '2024-09-01', 'Credit Card', 'Success', 69999),
(24, '2024-09-05', 'UPI', 'Failed', 1599),
(25, '2024-09-10', 'Debit Card', 'Success', 4999),
(26, '2024-09-15', 'UPI', 'Success', 5999),
(27, '2024-09-20', 'Cash', 'Success', 3499),
(28, '2024-10-01', 'Credit Card', 'Success', 8999),
(29, '2024-10-05', 'UPI', 'Success', 2499),
(30, '2024-10-10', 'UPI', 'Success', 5999);


-- =============================================
-- 7. SHIPMENTS
-- =============================================

INSERT INTO shipments
(order_id, shipped_date, delivered_date, delivery_status)
VALUES
(1,  '2024-05-02', '2024-05-05', 'Delivered'),
(2,  '2024-05-04', '2024-05-07', 'Delivered'),
(4,  '2024-05-11', '2024-05-14', 'Delivered'),
(5,  '2024-05-13', NULL, 'In Transit'),
(6,  '2024-05-16', '2024-05-18', 'Delivered'),
(7,  '2024-05-21', '2024-05-24', 'Delivered'),
(8,  '2024-06-02', '2024-06-05', 'Delivered'),
(9,  '2024-06-06', NULL, 'In Transit'),
(10, '2024-06-11', '2024-06-14', 'Delivered'),
(12, '2024-06-21', '2024-06-24', 'Delivered'),
(13, '2024-07-02', '2024-07-05', 'Delivered'),
(14, '2024-07-06', '2024-07-09', 'Delivered'),
(15, '2024-07-11', '2024-07-14', 'Delivered'),
(16, '2024-07-16', '2024-07-19', 'Delivered'),
(17, '2024-07-21', '2024-07-24', 'Delivered'),
(18, '2024-08-02', NULL, 'In Transit'),
(19, '2024-08-06', '2024-08-08', 'Delivered'),
(20, '2024-08-11', '2024-08-14', 'Delivered'),
(21, '2024-08-16', '2024-08-19', 'Delivered'),
(22, '2024-08-21', '2024-08-24', 'Delivered'),
(23, '2024-09-02', '2024-09-05', 'Delivered'),
(25, '2024-09-11', '2024-09-14', 'Delivered'),
(26, '2024-09-16', '2024-09-19', 'Delivered'),
(27, '2024-09-21', '2024-09-24', 'Delivered'),
(28, '2024-10-02', '2024-10-05', 'Delivered'),
(29, '2024-10-06', NULL, 'In Transit'),
(30, '2024-10-11', '2024-10-14', 'Delivered');


-- =============================================
-- 8. INVENTORY
-- =============================================

INSERT INTO inventory
(product_id, warehouse, stock_quantity, last_updated)
VALUES
(1,  'Chennai Warehouse', 50, '2024-10-15'),
(2,  'Bangalore Warehouse', 40, '2024-10-15'),
(3,  'Chennai Warehouse', 60, '2024-10-15'),
(4,  'Mumbai Warehouse', 120, '2024-10-15'),
(5,  'Chennai Warehouse', 100, '2024-10-15'),
(6,  'Mumbai Warehouse', 80, '2024-10-15'),
(7,  'Chennai Warehouse', 90, '2024-10-15'),
(8,  'Bangalore Warehouse', 70, '2024-10-15'),
(9,  'Chennai Warehouse', 100, '2024-10-15'),
(10, 'Bangalore Warehouse', 70, '2024-10-15'),
(11, 'Chennai Warehouse', 45, '2024-10-15'),
(12, 'Mumbai Warehouse', 80, '2024-10-15'),
(13, 'Bangalore Warehouse', 150, '2024-10-15'),
(14, 'Chennai Warehouse', 120, '2024-10-15'),
(15, 'Mumbai Warehouse', 100, '2024-10-15'),
(16, 'Chennai Warehouse', 100, '2024-10-15'),
(17, 'Bangalore Warehouse', 80, '2024-10-15'),
(18, 'Chennai Warehouse', 60, '2024-10-15');


-- =============================================
-- VERIFY DATA
-- =============================================

SELECT 'Customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'Categories', COUNT(*)
FROM categories

UNION ALL

SELECT 'Products', COUNT(*)
FROM products

UNION ALL

SELECT 'Orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'Order Items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'Payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'Shipments', COUNT(*)
FROM shipments

UNION ALL

SELECT 'Inventory', COUNT(*)
FROM inventory;