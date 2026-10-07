USE ecommerce_analytics;

-- =============================================
-- STEP 5 : SUBQUERIES & CTE
-- =============================================


-- =================================================
-- 1. CUSTOMERS WHO SPENT MORE THAN AVERAGE CUSTOMER
-- =================================================

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
HAVING SUM(o.total_amount) >
(
    SELECT AVG(customer_total)
    FROM
    (
        SELECT
            customer_id,
            SUM(total_amount) AS customer_total
        FROM orders
        WHERE order_status <> 'Cancelled'
        GROUP BY customer_id
    ) AS customer_summary
)
ORDER BY total_spent DESC;


-- =================================================
-- 2. PRODUCTS WITH PRICE ABOVE AVERAGE PRODUCT PRICE
-- =================================================

SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price >
(
    SELECT AVG(price)
    FROM products
)
ORDER BY price DESC;


-- =================================================
-- 3. CUSTOMERS WHO HAVE NEVER PLACED AN ORDER
-- =================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- =================================================
-- 4. PRODUCTS THAT HAVE NEVER BEEN SOLD
-- =================================================

SELECT
    p.product_id,
    p.product_name,
    p.price
FROM products p
WHERE NOT EXISTS
(
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);


-- =================================================
-- 5. SECOND HIGHEST PRODUCT PRICE
-- =================================================

SELECT
    MAX(price) AS second_highest_price
FROM products
WHERE price <
(
    SELECT MAX(price)
    FROM products
);


-- =================================================
-- 6. TOP CUSTOMER USING SUBQUERY
-- =================================================

SELECT
    customer_id,
    customer_name,
    total_spent
FROM
(
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
) AS customer_sales
ORDER BY total_spent DESC
LIMIT 1;


-- =================================================
-- 7. CTE - CUSTOMER SALES
-- =================================================

WITH customer_sales AS
(
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
)

SELECT *
FROM customer_sales
ORDER BY total_spent DESC;


-- =================================================
-- 8. CTE - HIGH VALUE CUSTOMERS
-- =================================================

WITH customer_sales AS
(
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
)

SELECT
    customer_id,
    customer_name,
    total_spent
FROM customer_sales
WHERE total_spent > 10000
ORDER BY total_spent DESC;


-- =================================================
-- 9. CTE - CATEGORY REVENUE
-- =================================================

WITH category_sales AS
(
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
)

SELECT
    category_name,
    revenue
FROM category_sales
ORDER BY revenue DESC;


-- =================================================
-- 10. CTE - PRODUCT PROFIT ANALYSIS
-- =================================================

WITH product_profit AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity *
            (oi.unit_price - p.cost_price)
        ) AS profit

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY
        p.product_id,
        p.product_name
)

SELECT
    product_name,
    revenue,
    profit
FROM product_profit
ORDER BY profit DESC;


-- =================================================
-- 11. MULTIPLE CTEs - BUSINESS SUMMARY
-- =================================================

WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
),

overall_sales AS
(
    SELECT
        SUM(total_spent) AS total_revenue,
        AVG(total_spent) AS average_customer_spending
    FROM customer_sales
)

SELECT
    cs.customer_id,
    cs.total_spent,
    os.total_revenue,
    ROUND(os.average_customer_spending, 2)
        AS average_customer_spending
FROM customer_sales cs
CROSS JOIN overall_sales os
ORDER BY cs.total_spent DESC;


-- =================================================
-- STEP 5 COMPLETE
-- =================================================