USE ecommerce_analytics;

-- =============================================
-- STEP 3 : DATA VALIDATION & EXPLORATION
-- =============================================


-- 1. CHECK CUSTOMER COUNT

SELECT
    COUNT(*) AS total_customers
FROM customers;


-- 2. CHECK PRODUCT COUNT

SELECT
    COUNT(*) AS total_products
FROM products;


-- 3. CHECK ORDER COUNT

SELECT
    COUNT(*) AS total_orders
FROM orders;


-- 4. CHECK ORDER STATUS

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- 5. CHECK CUSTOMER STATES

SELECT
    state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;


-- 6. CHECK PRODUCT CATEGORIES

SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p
    ON c.category_id = p.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY product_count DESC;


-- 7. CHECK PRICE RANGE

SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    ROUND(AVG(price), 2) AS average_price
FROM products;


-- 8. CHECK ORDER VALUE

SELECT
    MIN(total_amount) AS minimum_order_value,
    MAX(total_amount) AS maximum_order_value,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled';


-- 9. CHECK CANCELLED ORDERS

SELECT
    COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'Cancelled';


-- 10. CHECK SUCCESSFUL ORDERS

SELECT
    COUNT(*) AS successful_orders
FROM orders
WHERE order_status <> 'Cancelled';


-- 11. CHECK MISSING CUSTOMER EMAILS

SELECT
    COUNT(*) AS missing_emails
FROM customers
WHERE email IS NULL
   OR email = '';


-- 12. CHECK DUPLICATE EMAILS

SELECT
    email,
    COUNT(*) AS email_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;


-- 13. CHECK PRODUCTS WITH LOW STOCK

SELECT
    product_id,
    product_name,
    stock_quantity
FROM products
WHERE stock_quantity < 50
ORDER BY stock_quantity;


-- 14. CHECK PRODUCTS WITH NO CATEGORY

SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
WHERE c.category_id IS NULL;


-- 15. BASIC BUSINESS SUMMARY

SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,

    (SELECT COUNT(*) FROM products) AS total_products,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status <> 'Cancelled') AS successful_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status = 'Cancelled') AS cancelled_orders,

    (SELECT SUM(total_amount)
     FROM orders
     WHERE order_status <> 'Cancelled') AS total_revenue,

    (SELECT ROUND(AVG(total_amount), 2)
     FROM orders
     WHERE order_status <> 'Cancelled') AS average_order_value;