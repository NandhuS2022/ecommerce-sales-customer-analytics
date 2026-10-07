USE ecommerce_analytics;

-- =====================================================
-- STEP 11 : POWER BI READY ANALYTICS LAYER
-- =====================================================


-- =====================================================
-- 1. EXECUTIVE KPI VIEW
-- =====================================================

DROP VIEW IF EXISTS vw_executive_kpi;

CREATE VIEW vw_executive_kpi AS

SELECT

    (SELECT COUNT(*)
     FROM customers) AS total_customers,

    (SELECT COUNT(*)
     FROM products) AS total_products,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status <> 'Cancelled') AS successful_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status = 'Cancelled') AS cancelled_orders,

    (SELECT COALESCE(SUM(total_amount), 0)
     FROM orders
     WHERE order_status <> 'Cancelled') AS total_revenue,

    (SELECT COALESCE(
        ROUND(AVG(total_amount), 2), 0
     )
     FROM orders
     WHERE order_status <> 'Cancelled') AS average_order_value,

    (SELECT COALESCE(
        SUM(
            oi.quantity *
            (oi.unit_price - p.cost_price)
        ), 0
     )
     FROM order_items oi
     JOIN orders o
         ON oi.order_id = o.order_id
     JOIN products p
         ON oi.product_id = p.product_id
     WHERE o.order_status <> 'Cancelled') AS total_profit;


-- TEST

SELECT *
FROM vw_executive_kpi;


-- =====================================================
-- 2. MONTHLY SALES VIEW
-- =====================================================

DROP VIEW IF EXISTS vw_monthly_sales;

CREATE VIEW vw_monthly_sales AS

SELECT

    DATE_FORMAT(
        o.order_date,
        '%Y-%m'
    ) AS sales_month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT o.customer_id) AS unique_customers,

    SUM(o.total_amount) AS revenue,

    ROUND(
        AVG(o.total_amount),
        2
    ) AS average_order_value

FROM orders o

WHERE o.order_status <> 'Cancelled'

GROUP BY
    DATE_FORMAT(
        o.order_date,
        '%Y-%m'
    );


-- TEST

SELECT *
FROM vw_monthly_sales
ORDER BY sales_month;


-- =====================================================
-- 3. PRODUCT PERFORMANCE VIEW
-- =====================================================

DROP VIEW IF EXISTS vw_product_performance;

CREATE VIEW vw_product_performance AS

SELECT

    p.product_id,

    p.product_name,

    c.category_name,

    p.price,

    p.cost_price,

    p.stock_quantity,

    COALESCE(
        SUM(oi.quantity),
        0
    ) AS units_sold,

    COALESCE(
        SUM(
            oi.quantity *
            oi.unit_price
        ),
        0
    ) AS revenue,

    COALESCE(
        SUM(
            oi.quantity *
            (
                oi.unit_price -
                p.cost_price
            )
        ),
        0
    ) AS profit,

    CASE

        WHEN p.stock_quantity < 30
            THEN 'Critical Stock'

        WHEN p.stock_quantity < 50
            THEN 'Low Stock'

        ELSE 'Healthy Stock'

    END AS stock_status

FROM products p

JOIN categories c
    ON p.category_id = c.category_id

LEFT JOIN order_items oi
    ON p.product_id = oi.product_id

LEFT JOIN orders o
    ON oi.order_id = o.order_id
    AND o.order_status <> 'Cancelled'

GROUP BY

    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.cost_price,
    p.stock_quantity;


-- TEST

SELECT *
FROM vw_product_performance
ORDER BY revenue DESC;


-- =====================================================
-- 4. CUSTOMER PERFORMANCE VIEW
-- =====================================================

DROP VIEW IF EXISTS vw_customer_performance;

CREATE VIEW vw_customer_performance AS

SELECT

    c.customer_id,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    c.city,

    c.state,

    c.signup_date,

    COUNT(
        CASE
            WHEN o.order_status <> 'Cancelled'
            THEN o.order_id
        END
    ) AS total_orders,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status <> 'Cancelled'
                THEN o.total_amount
                ELSE 0
            END
        ),
        0
    ) AS total_spent,

    COALESCE(
        ROUND(
            AVG(
                CASE
                    WHEN o.order_status <> 'Cancelled'
                    THEN o.total_amount
                END
            ),
            2
        ),
        0
    ) AS average_order_value,

    MAX(
        CASE
            WHEN o.order_status <> 'Cancelled'
            THEN o.order_date
        END
    ) AS last_order_date,

    CASE

        WHEN COALESCE(
            SUM(
                CASE
                    WHEN o.order_status <> 'Cancelled'
                    THEN o.total_amount
                    ELSE 0
                END
            ), 0
        ) >= 50000
            THEN 'VIP'

        WHEN COALESCE(
            SUM(
                CASE
                    WHEN o.order_status <> 'Cancelled'
                    THEN o.total_amount
                    ELSE 0
                END
            ), 0
        ) >= 10000
            THEN 'High Value'

        WHEN COALESCE(
            SUM(
                CASE
                    WHEN o.order_status <> 'Cancelled'
                    THEN o.total_amount
                    ELSE 0
                END
            ), 0
        ) > 0
            THEN 'Regular'

        ELSE 'No Purchase'

    END AS customer_segment

FROM customers c

LEFT JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY

    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state,
    c.signup_date;


-- TEST

SELECT *
FROM vw_customer_performance
ORDER BY total_spent DESC;


-- =====================================================
-- 5. CATEGORY PERFORMANCE VIEW
-- =====================================================

DROP VIEW IF EXISTS vw_category_performance;

CREATE VIEW vw_category_performance AS

SELECT

    c.category_id,

    c.category_name,

    COUNT(
        DISTINCT p.product_id
    ) AS total_products,

    COALESCE(
        SUM(oi.quantity),
        0
    ) AS units_sold,

    COALESCE(
        SUM(
            oi.quantity *
            oi.unit_price
        ),
        0
    ) AS revenue,

    COALESCE(
        SUM(
            oi.quantity *
            (
                oi.unit_price -
                p.cost_price
            )
        ),
        0
    ) AS profit

FROM categories c

LEFT JOIN products p
    ON c.category_id = p.category_id

LEFT JOIN order_items oi
    ON p.product_id = oi.product_id

LEFT JOIN orders o
    ON oi.order_id = o.order_id
    AND o.order_status <> 'Cancelled'

GROUP BY

    c.category_id,
    c.category_name;


-- TEST

SELECT *
FROM vw_category_performance
ORDER BY revenue DESC;


-- =====================================================
-- 6. DELIVERY PERFORMANCE VIEW
-- =====================================================

DROP VIEW IF EXISTS vw_delivery_performance;

CREATE VIEW vw_delivery_performance AS

SELECT

    s.shipment_id,

    s.order_id,

    o.customer_id,

    o.order_date,

    s.shipped_date,

    s.delivered_date,

    s.delivery_status,

    CASE

        WHEN s.delivered_date IS NOT NULL

        THEN DATEDIFF(
            s.delivered_date,
            s.shipped_date
        )

        ELSE NULL

    END AS delivery_days,

    CASE

        WHEN s.delivered_date IS NULL
            THEN 'In Transit'

        WHEN DATEDIFF(
            s.delivered_date,
            s.shipped_date
        ) <= 3
            THEN 'On Time'

        ELSE 'Delayed'

    END AS delivery_category

FROM shipments s

JOIN orders o
    ON s.order_id = o.order_id

WHERE o.order_status <> 'Cancelled';


-- TEST

SELECT *
FROM vw_delivery_performance
ORDER BY delivery_days DESC;


-- =====================================================
-- 7. FINAL VIEW CHECK
-- =====================================================

SELECT 'Executive KPI' AS view_name;

SELECT * FROM vw_executive_kpi;


SELECT 'Monthly Sales' AS view_name;

SELECT * FROM vw_monthly_sales;


SELECT 'Product Performance' AS view_name;

SELECT * FROM vw_product_performance;


SELECT 'Customer Performance' AS view_name;

SELECT * FROM vw_customer_performance;


SELECT 'Category Performance' AS view_name;

SELECT * FROM vw_category_performance;


SELECT 'Delivery Performance' AS view_name;

SELECT * FROM vw_delivery_performance;


-- =====================================================
-- STEP 11 COMPLETE
-- =====================================================