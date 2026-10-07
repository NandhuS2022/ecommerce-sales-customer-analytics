USE ecommerce_analytics;

-- =============================================
-- STEP 10 : ADVANCED BUSINESS ANALYTICS
-- =============================================


-- =================================================
-- 1. CUSTOMER RFM-STYLE ANALYSIS
-- Recency + Frequency + Monetary
-- =================================================

WITH customer_metrics AS
(
    SELECT
        c.customer_id,

        CONCAT(
            c.first_name,
            ' ',
            c.last_name
        ) AS customer_name,

        MAX(o.order_date) AS last_order_date,

        COUNT(o.order_id) AS order_frequency,

        SUM(o.total_amount) AS total_spending

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
    last_order_date,
    order_frequency,
    total_spending,

    DATEDIFF(
        '2024-10-31',
        last_order_date
    ) AS recency_days,

    CASE
        WHEN order_frequency >= 3
             AND total_spending >= 20000
             AND DATEDIFF(
                    '2024-10-31',
                    last_order_date
                 ) <= 60
            THEN 'VIP Customer'

        WHEN order_frequency >= 2
             AND total_spending >= 10000
            THEN 'Loyal Customer'

        WHEN DATEDIFF(
                '2024-10-31',
                last_order_date
             ) > 90
            THEN 'At Risk Customer'

        ELSE 'Regular Customer'
    END AS customer_segment

FROM customer_metrics

ORDER BY total_spending DESC;


-- =================================================
-- 2. REPEAT CUSTOMERS
-- Customers with 2+ successful orders
-- =================================================

SELECT
    c.customer_id,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    COUNT(o.order_id) AS successful_orders

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

HAVING COUNT(o.order_id) >= 2

ORDER BY successful_orders DESC;


-- =================================================
-- 3. CUSTOMER RETENTION ANALYSIS
-- Customers who purchased in multiple months
-- =================================================

SELECT
    c.customer_id,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    COUNT(
        DISTINCT DATE_FORMAT(
            o.order_date,
            '%Y-%m'
        )
    ) AS active_months

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

HAVING COUNT(
    DISTINCT DATE_FORMAT(
        o.order_date,
        '%Y-%m'
    )
) >= 2

ORDER BY active_months DESC;


-- =================================================
-- 4. MONTHLY REVENUE GROWTH
-- =================================================

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(
            order_date,
            '%Y-%m'
        ) AS sales_month,

        SUM(total_amount) AS revenue

    FROM orders

    WHERE order_status <> 'Cancelled'

    GROUP BY
        DATE_FORMAT(
            order_date,
            '%Y-%m'
        )
),

revenue_growth AS
(
    SELECT
        sales_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue

    FROM monthly_sales
)

SELECT
    sales_month,
    revenue,
    previous_month_revenue,

    CASE
        WHEN previous_month_revenue IS NULL
            THEN NULL

        ELSE ROUND(
            (
                (
                    revenue -
                    previous_month_revenue
                )
                /
                previous_month_revenue
            ) * 100,
            2
        )
    END AS growth_percentage

FROM revenue_growth

ORDER BY sales_month;


-- =================================================
-- 5. TOP 3 CUSTOMERS IN EACH CITY
-- =================================================

WITH customer_sales AS
(
    SELECT
        c.customer_id,

        CONCAT(
            c.first_name,
            ' ',
            c.last_name
        ) AS customer_name,

        c.city,

        SUM(o.total_amount) AS total_spent

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.city
),

city_ranking AS
(
    SELECT
        customer_id,
        customer_name,
        city,
        total_spent,

        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY total_spent DESC
        ) AS city_rank

    FROM customer_sales
)

SELECT
    customer_id,
    customer_name,
    city,
    total_spent,
    city_rank

FROM city_ranking

WHERE city_rank <= 3

ORDER BY
    city,
    city_rank;


-- =================================================
-- 6. CATEGORY CONTRIBUTION TO TOTAL REVENUE
-- =================================================

WITH category_sales AS
(
    SELECT
        c.category_name,

        SUM(
            oi.quantity *
            oi.unit_price
        ) AS revenue

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
),

total_sales AS
(
    SELECT
        SUM(revenue) AS total_revenue

    FROM category_sales
)

SELECT
    cs.category_name,
    cs.revenue,

    ROUND(
        (
            cs.revenue /
            ts.total_revenue
        ) * 100,
        2
    ) AS revenue_contribution_percentage

FROM category_sales cs

CROSS JOIN total_sales ts

ORDER BY cs.revenue DESC;


-- =================================================
-- 7. PRODUCTS WITH HIGH REVENUE BUT LOW STOCK
-- =================================================

WITH product_sales AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity *
            oi.unit_price
        ) AS revenue

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
    ps.product_name,
    ps.revenue,
    p.stock_quantity

FROM product_sales ps

JOIN products p
    ON ps.product_id = p.product_id

WHERE p.stock_quantity < 60

ORDER BY ps.revenue DESC;


-- =================================================
-- 8. CUSTOMER ORDER VALUE CLASSIFICATION
-- =================================================

SELECT
    c.customer_id,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    ROUND(
        AVG(o.total_amount),
        2
    ) AS average_order_value,

    CASE
        WHEN AVG(o.total_amount) >= 30000
            THEN 'Premium'

        WHEN AVG(o.total_amount) >= 10000
            THEN 'High Value'

        WHEN AVG(o.total_amount) >= 5000
            THEN 'Medium Value'

        ELSE 'Low Value'
    END AS order_value_segment

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY average_order_value DESC;


-- =================================================
-- 9. FINAL BUSINESS KPI SUMMARY
-- Corrected repeat customer calculation
-- =================================================

SELECT

    -- Total customers
    (
        SELECT COUNT(*)
        FROM customers
    ) AS total_customers,

    -- Successful orders
    (
        SELECT COUNT(*)
        FROM orders
        WHERE order_status <> 'Cancelled'
    ) AS successful_orders,

    -- Total revenue
    (
        SELECT SUM(total_amount)
        FROM orders
        WHERE order_status <> 'Cancelled'
    ) AS total_revenue,

    -- Average order value
    (
        SELECT ROUND(
            AVG(total_amount),
            2
        )
        FROM orders
        WHERE order_status <> 'Cancelled'
    ) AS average_order_value,

    -- Customers who purchased
    (
        SELECT COUNT(DISTINCT customer_id)
        FROM orders
        WHERE order_status <> 'Cancelled'
    ) AS purchasing_customers,

    -- Customers with 2 or more successful orders
    (
        SELECT COUNT(*)
        FROM
        (
            SELECT
                customer_id

            FROM orders

            WHERE order_status <> 'Cancelled'

            GROUP BY customer_id

            HAVING COUNT(*) >= 2

        ) AS repeat_customers
    ) AS repeat_customer_count;


-- =================================================
-- STEP 10 COMPLETE
-- =================================================