USE ecommerce_analytics;

-- =============================================
-- STEP 7 : BUSINESS OPERATIONS ANALYSIS
-- =============================================


-- =================================================
-- 1. PRODUCT-WISE REVENUE & PROFIT
-- =================================================

SELECT
    p.product_id,
    p.product_name,

    SUM(oi.quantity) AS units_sold,

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

ORDER BY profit DESC;


-- =================================================
-- 2. PRODUCT PROFIT MARGIN %
-- =================================================

SELECT
    p.product_name,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity *
        (oi.unit_price - p.cost_price)
    ) AS profit,

    ROUND(
        (
            SUM(
                oi.quantity *
                (oi.unit_price - p.cost_price)
            )
            /
            SUM(
                oi.quantity * oi.unit_price
            )
        ) * 100,
        2
    ) AS profit_margin_percentage

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY profit_margin_percentage DESC;


-- =================================================
-- 3. CATEGORY-WISE PROFIT
-- =================================================

SELECT
    c.category_name,

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

JOIN categories c
    ON p.category_id = c.category_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.category_id,
    c.category_name

ORDER BY profit DESC;


-- =================================================
-- 4. BEST PROFIT-GENERATING PRODUCT
-- =================================================

SELECT
    p.product_name,

    SUM(
        oi.quantity *
        (oi.unit_price - p.cost_price)
    ) AS total_profit

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY total_profit DESC

LIMIT 1;


-- =================================================
-- 5. LOW STOCK PRODUCTS
-- =================================================

SELECT
    product_id,
    product_name,
    stock_quantity,

    CASE
        WHEN stock_quantity < 30
            THEN 'Critical Stock'

        WHEN stock_quantity < 50
            THEN 'Low Stock'

        ELSE 'Healthy Stock'
    END AS stock_status

FROM products

ORDER BY stock_quantity;


-- =================================================
-- 6. INVENTORY BY WAREHOUSE
-- =================================================

SELECT
    warehouse,
    COUNT(product_id) AS product_count,
    SUM(stock_quantity) AS total_stock
FROM inventory
GROUP BY warehouse
ORDER BY total_stock DESC;


-- =================================================
-- 7. TOP PRODUCTS BY AVAILABLE STOCK
-- =================================================

SELECT
    p.product_name,
    i.warehouse,
    i.stock_quantity
FROM inventory i

JOIN products p
    ON i.product_id = p.product_id

ORDER BY i.stock_quantity DESC
LIMIT 10;


-- =================================================
-- 8. PAYMENT METHOD ANALYSIS
-- =================================================

SELECT
    payment_method,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN payment_status = 'Success'
            THEN 1
            ELSE 0
        END
    ) AS successful_transactions,

    SUM(
        CASE
            WHEN payment_status = 'Failed'
            THEN 1
            ELSE 0
        END
    ) AS failed_transactions,

    SUM(
        CASE
            WHEN payment_status = 'Success'
            THEN amount
            ELSE 0
        END
    ) AS successful_amount

FROM payments

GROUP BY payment_method

ORDER BY successful_amount DESC;


-- =================================================
-- 9. PAYMENT SUCCESS RATE
-- =================================================

SELECT
    payment_method,

    COUNT(*) AS total_transactions,

    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Success'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS success_rate_percentage

FROM payments

GROUP BY payment_method

ORDER BY success_rate_percentage DESC;


-- =================================================
-- 10. DELIVERY PERFORMANCE
-- =================================================

SELECT
    delivery_status,
    COUNT(*) AS shipment_count
FROM shipments
GROUP BY delivery_status
ORDER BY shipment_count DESC;


-- =================================================
-- 11. AVERAGE DELIVERY DAYS
-- =================================================

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                delivered_date,
                shipped_date
            )
        ),
        2
    ) AS average_delivery_days

FROM shipments

WHERE delivered_date IS NOT NULL;


-- =================================================
-- 12. ORDER-WISE DELIVERY TIME
-- =================================================

SELECT
    s.order_id,

    s.shipped_date,

    s.delivered_date,

    DATEDIFF(
        s.delivered_date,
        s.shipped_date
    ) AS delivery_days,

    s.delivery_status

FROM shipments s

WHERE s.delivered_date IS NOT NULL

ORDER BY delivery_days DESC;


-- =================================================
-- 13. DELIVERIES TAKING MORE THAN 3 DAYS
-- =================================================

SELECT
    s.order_id,

    DATEDIFF(
        s.delivered_date,
        s.shipped_date
    ) AS delivery_days

FROM shipments s

WHERE s.delivered_date IS NOT NULL

AND DATEDIFF(
    s.delivered_date,
    s.shipped_date
) > 3

ORDER BY delivery_days DESC;


-- =================================================
-- 14. OVERALL BUSINESS KPI
-- =================================================

SELECT

    (
        SELECT SUM(total_amount)
        FROM orders
        WHERE order_status <> 'Cancelled'
    ) AS total_revenue,

    (
        SELECT SUM(
            oi.quantity *
            (oi.unit_price - p.cost_price)
        )
        FROM order_items oi

        JOIN orders o
            ON oi.order_id = o.order_id

        JOIN products p
            ON oi.product_id = p.product_id

        WHERE o.order_status <> 'Cancelled'
    ) AS total_profit,

    (
        SELECT COUNT(*)
        FROM orders
        WHERE order_status <> 'Cancelled'
    ) AS successful_orders,

    (
        SELECT COUNT(*)
        FROM customers
    ) AS total_customers,

    (
        SELECT COUNT(*)
        FROM products
    ) AS total_products;


-- =================================================
-- STEP 7 COMPLETE
-- =================================================