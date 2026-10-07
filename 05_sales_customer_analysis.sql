USE ecommerce_analytics;

-- =============================================
-- STEP 4 : SALES & CUSTOMER ANALYSIS
-- =============================================


-- 1. TOTAL REVENUE
-- Cancelled orders excluded

SELECT
    SUM(total_amount) AS total_revenue
FROM orders
WHERE order_status <> 'Cancelled';


-- =============================================
-- 2. TOTAL SUCCESSFUL ORDERS
-- =============================================

SELECT
    COUNT(*) AS successful_orders
FROM orders
WHERE order_status <> 'Cancelled';


-- =============================================
-- 3. AVERAGE ORDER VALUE
-- =============================================

SELECT
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled';


-- =============================================
-- 4. MONTHLY REVENUE
-- =============================================

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- =============================================
-- 5. CITY-WISE CUSTOMER COUNT
-- =============================================

SELECT
    city,
    COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;


-- =============================================
-- 6. CUSTOMER-WISE ORDER COUNT
-- =============================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_orders DESC;


-- =============================================
-- 7. CUSTOMER-WISE TOTAL SPENDING
-- =============================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_spent DESC;


-- =============================================
-- 8. HIGH-VALUE CUSTOMERS
-- Customers who spent more than Rs.10,000
-- =============================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING SUM(o.total_amount) > 10000
ORDER BY total_spent DESC;


-- =============================================
-- 9. TOP 5 CUSTOMERS BY SPENDING
-- =============================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_spent DESC
LIMIT 5;


-- =============================================
-- 10. CATEGORY-WISE REVENUE
-- =============================================

SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN categories c
    ON p.category_id = c.category_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.category_id,
    c.category_name

ORDER BY revenue DESC;


-- =============================================
-- 11. TOP 5 PRODUCTS BY QUANTITY SOLD
-- =============================================

SELECT
    p.product_name,
    SUM(oi.quantity) AS quantity_sold
FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY quantity_sold DESC

LIMIT 5;


-- =============================================
-- 12. TOP 5 PRODUCTS BY REVENUE
-- =============================================

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY revenue DESC

LIMIT 5;


-- =============================================
-- 13. PAYMENT METHOD ANALYSIS
-- =============================================

SELECT
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM payments
WHERE payment_status = 'Success'
GROUP BY payment_method
ORDER BY total_amount DESC;


-- =============================================
-- 14. ORDER STATUS ANALYSIS
-- =============================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- =============================================
-- 15. CUSTOMER SEGMENTATION
-- =============================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COALESCE(SUM(
        CASE
            WHEN o.order_status <> 'Cancelled'
            THEN o.total_amount
            ELSE 0
        END
    ), 0) AS total_spent,

    CASE
        WHEN COALESCE(SUM(
            CASE
                WHEN o.order_status <> 'Cancelled'
                THEN o.total_amount
                ELSE 0
            END
        ), 0) >= 50000
            THEN 'VIP Customer'

        WHEN COALESCE(SUM(
            CASE
                WHEN o.order_status <> 'Cancelled'
                THEN o.total_amount
                ELSE 0
            END
        ), 0) >= 10000
            THEN 'High Value Customer'

        WHEN COALESCE(SUM(
            CASE
                WHEN o.order_status <> 'Cancelled'
                THEN o.total_amount
                ELSE 0
            END
        ), 0) > 0
            THEN 'Regular Customer'

        ELSE 'No Purchase'
    END AS customer_segment

FROM customers c

LEFT JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_spent DESC;