
USE ecommerce_analytics;

-- =============================================
-- STEP 9 : INDEXING & QUERY OPTIMIZATION
-- MySQL 8.0
-- =============================================


-- 1. CHECK EXISTING INDEXES

SHOW INDEX FROM customers;
SHOW INDEX FROM products;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;


-- =============================================
-- 2. CREATE PERFORMANCE INDEXES
-- =============================================

CREATE INDEX idx_orders_status_date
ON orders(order_status, order_date);

CREATE INDEX idx_customers_city
ON customers(city);

CREATE INDEX idx_products_price
ON products(price);

CREATE INDEX idx_payments_status_method
ON payments(payment_status, payment_method);

CREATE INDEX idx_shipments_delivery
ON shipments(delivery_status, delivered_date);


-- =============================================
-- 3. VERIFY CREATED INDEXES
-- =============================================

SHOW INDEX FROM orders;
SHOW INDEX FROM customers;
SHOW INDEX FROM products;
SHOW INDEX FROM payments;
SHOW INDEX FROM shipments;


-- =============================================
-- 4. ANALYZE QUERY EXECUTION PLAN
-- =============================================

EXPLAIN
SELECT *
FROM orders
WHERE order_status = 'Delivered'
AND order_date BETWEEN
    '2024-05-01' AND '2024-10-31';


-- =============================================
-- 5. OPTIMIZED MONTHLY REVENUE QUERY
-- =============================================

SELECT
    DATE_FORMAT(order_date, '%Y-%m')
        AS sales_month,

    COUNT(*) AS total_orders,

    SUM(total_amount) AS total_revenue

FROM orders

WHERE order_status = 'Delivered'
AND order_date >= '2024-05-01'
AND order_date < '2024-11-01'

GROUP BY DATE_FORMAT(order_date, '%Y-%m')

ORDER BY sales_month;


-- =============================================
-- 6. EXPLAIN CUSTOMER SALES QUERY
-- =============================================

EXPLAIN
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)
        AS customer_name,
    SUM(o.total_amount) AS total_spent

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status = 'Delivered'

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_spent DESC;


-- =============================================
-- 7. EXPLAIN PRODUCT SALES QUERY
-- =============================================

EXPLAIN
SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price)
        AS revenue

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Delivered'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY revenue DESC;


-- =============================================
-- 8. UPDATE TABLE STATISTICS
-- =============================================

ANALYZE TABLE customers;
ANALYZE TABLE products;
ANALYZE TABLE orders;
ANALYZE TABLE order_items;
ANALYZE TABLE payments;
ANALYZE TABLE shipments;


-- =============================================
-- 9. VERIFY DATABASE INDEXES
-- =============================================

SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX

FROM information_schema.STATISTICS

WHERE TABLE_SCHEMA = 'ecommerce_analytics'

ORDER BY
    TABLE_NAME,
    INDEX_NAME,
    SEQ_IN_INDEX;


-- =============================================
-- STEP 9 COMPLETE
-- =============================================
