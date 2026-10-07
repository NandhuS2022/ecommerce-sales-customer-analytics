USE ecommerce_analytics;

-- =============================================
-- STEP 6 : WINDOW FUNCTIONS
-- =============================================


-- =================================================
-- 1. RANK CUSTOMERS BY TOTAL SPENDING
-- =================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spent,

    RANK() OVER (
        ORDER BY SUM(o.total_amount) DESC
    ) AS customer_rank

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY customer_rank;


-- =================================================
-- 2. DENSE RANK PRODUCTS BY REVENUE
-- =================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue,

    DENSE_RANK() OVER (
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
    ) AS revenue_rank

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY revenue_rank;


-- =================================================
-- 3. ROW_NUMBER FOR CUSTOMERS
-- =================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spent,

    ROW_NUMBER() OVER (
        ORDER BY SUM(o.total_amount) DESC
    ) AS row_number_position

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY row_number_position;


-- =================================================
-- 4. RANK PRODUCTS WITHIN EACH CATEGORY
-- =================================================

SELECT
    c.category_name,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue,

    RANK() OVER (
        PARTITION BY c.category_id
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
    ) AS category_rank

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
    c.category_name,
    p.product_id,
    p.product_name

ORDER BY
    c.category_name,
    category_rank;


-- =================================================
-- 5. TOP PRODUCT FROM EACH CATEGORY
-- =================================================

WITH product_ranking AS
(
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue,

        RANK() OVER (
            PARTITION BY c.category_id
            ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        ) AS category_rank

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
        c.category_name,
        p.product_id,
        p.product_name
)

SELECT
    category_name,
    product_name,
    revenue
FROM product_ranking
WHERE category_rank = 1
ORDER BY revenue DESC;


-- =================================================
-- 6. MONTHLY REVENUE
-- =================================================

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue

    FROM orders

    WHERE order_status <> 'Cancelled'

    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    month,
    revenue
FROM monthly_sales
ORDER BY month;


-- =================================================
-- 7. MONTHLY REVENUE + PREVIOUS MONTH
-- =================================================

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue

    FROM orders

    WHERE order_status <> 'Cancelled'

    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    month,
    revenue,

    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue

FROM monthly_sales

ORDER BY month;


-- =================================================
-- 8. MONTH-OVER-MONTH REVENUE GROWTH
-- =================================================

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue

    FROM orders

    WHERE order_status <> 'Cancelled'

    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),

revenue_comparison AS
(
    SELECT
        month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_revenue

    FROM monthly_sales
)

SELECT
    month,
    revenue,
    previous_revenue,

    ROUND(
        (
            (revenue - previous_revenue)
            / previous_revenue
        ) * 100,
        2
    ) AS growth_percentage

FROM revenue_comparison

ORDER BY month;


-- =================================================
-- 9. RUNNING TOTAL OF REVENUE
-- =================================================

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue

    FROM orders

    WHERE order_status <> 'Cancelled'

    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    month,
    revenue,

    SUM(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_total

FROM monthly_sales

ORDER BY month;


-- =================================================
-- 10. RUNNING CUSTOMER SPENDING
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
    total_spent,

    SUM(total_spent) OVER (
        ORDER BY total_spent DESC
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_customer_spending

FROM customer_sales

ORDER BY total_spent DESC;


-- =================================================
-- 11. COMPARE CUSTOMER SPENDING WITH PREVIOUS
-- CUSTOMER
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
    customer_name,
    total_spent,

    LAG(total_spent) OVER (
        ORDER BY total_spent DESC
    ) AS next_lower_spending_customer

FROM customer_sales

ORDER BY total_spent DESC;


-- =================================================
-- STEP 6 COMPLETE
-- =================================================