USE ecommerce_analytics;

-- =============================================
-- STEP 8 : VIEWS, STORED PROCEDURES & TRIGGERS
-- =============================================


-- =================================================
-- 1. CUSTOMER SALES VIEW
-- =================================================

DROP VIEW IF EXISTS customer_sales_view;

CREATE VIEW customer_sales_view AS

SELECT
    c.customer_id,

    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    c.city,
    c.state,

    COUNT(o.order_id) AS total_orders,

    SUM(o.total_amount) AS total_spent,

    ROUND(
        AVG(o.total_amount),
        2
    ) AS average_order_value

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state;


-- TEST VIEW

SELECT *
FROM customer_sales_view

ORDER BY total_spent DESC;


-- =================================================
-- 2. PRODUCT PERFORMANCE VIEW
-- =================================================

DROP VIEW IF EXISTS product_performance_view;

CREATE VIEW product_performance_view AS

SELECT

    p.product_id,
    p.product_name,
    c.category_name,

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

JOIN categories c
    ON p.category_id = c.category_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    p.product_id,
    p.product_name,
    c.category_name;


-- TEST VIEW

SELECT *
FROM product_performance_view

ORDER BY profit DESC;


-- =================================================
-- 3. MONTHLY SALES VIEW
-- =================================================

DROP VIEW IF EXISTS monthly_sales_view;

CREATE VIEW monthly_sales_view AS

SELECT

    DATE_FORMAT(
        order_date,
        '%Y-%m'
    ) AS sales_month,

    COUNT(*) AS total_orders,

    SUM(total_amount) AS revenue,

    ROUND(
        AVG(total_amount),
        2
    ) AS average_order_value

FROM orders

WHERE order_status <> 'Cancelled'

GROUP BY
    DATE_FORMAT(
        order_date,
        '%Y-%m'
    );


-- TEST VIEW

SELECT *
FROM monthly_sales_view

ORDER BY sales_month;


-- =================================================
-- 4. INVENTORY STATUS VIEW
-- =================================================

DROP VIEW IF EXISTS inventory_status_view;

CREATE VIEW inventory_status_view AS

SELECT

    p.product_id,
    p.product_name,

    i.warehouse,
    i.stock_quantity,

    CASE

        WHEN i.stock_quantity < 30
            THEN 'Critical'

        WHEN i.stock_quantity < 50
            THEN 'Low'

        WHEN i.stock_quantity <= 100
            THEN 'Normal'

        ELSE 'High'

    END AS stock_status

FROM inventory i

JOIN products p
    ON i.product_id = p.product_id;


-- TEST VIEW

SELECT *
FROM inventory_status_view

ORDER BY stock_quantity;


-- =================================================
-- 5. STORED PROCEDURE
-- Get Customer Sales
-- =================================================

DROP PROCEDURE IF EXISTS GetCustomerSales;

DELIMITER $$

CREATE PROCEDURE GetCustomerSales(
    IN p_customer_id INT
)

BEGIN

    SELECT

        c.customer_id,

        CONCAT(
            c.first_name,
            ' ',
            c.last_name
        ) AS customer_name,

        COUNT(o.order_id) AS total_orders,

        SUM(o.total_amount) AS total_spent

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    WHERE c.customer_id = p_customer_id

    AND o.order_status <> 'Cancelled'

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name;

END $$

DELIMITER ;


-- TEST PROCEDURE

CALL GetCustomerSales(1);


-- =================================================
-- 6. STORED PROCEDURE
-- Get Sales Between Dates
-- =================================================

DROP PROCEDURE IF EXISTS GetSalesByDate;

DELIMITER $$

CREATE PROCEDURE GetSalesByDate(
    IN start_date DATE,
    IN end_date DATE
)

BEGIN

    SELECT

        order_id,
        customer_id,
        order_date,
        order_status,
        total_amount

    FROM orders

    WHERE order_date
    BETWEEN start_date AND end_date

    AND order_status <> 'Cancelled'

    ORDER BY order_date;

END $$

DELIMITER ;


-- TEST PROCEDURE

CALL GetSalesByDate(
    '2024-05-01',
    '2024-06-30'
);


-- =================================================
-- 7. TRIGGER
-- Prevent Negative Product Stock
-- =================================================

DROP TRIGGER IF EXISTS prevent_negative_stock;

DELIMITER $$

CREATE TRIGGER prevent_negative_stock

BEFORE UPDATE ON products

FOR EACH ROW

BEGIN

    IF NEW.stock_quantity < 0 THEN

        SIGNAL SQLSTATE '45000'

        SET MESSAGE_TEXT =
        'Stock quantity cannot be negative';

    END IF;

END $$

DELIMITER ;


-- =================================================
-- 8. TEST TRIGGER
-- =================================================

-- DO NOT RUN THIS TEST.
-- It intentionally causes an error.

-- UPDATE products
-- SET stock_quantity = -10
-- WHERE product_id = 1;


-- =================================================
-- 9. TRIGGER
-- Automatically Update Inventory Date
-- =================================================

DROP TRIGGER IF EXISTS update_inventory_date;

DELIMITER $$

CREATE TRIGGER update_inventory_date

BEFORE UPDATE ON inventory

FOR EACH ROW

BEGIN

    SET NEW.last_updated = CURDATE();

END $$

DELIMITER ;


-- =================================================
-- 10. TEST INVENTORY TRIGGER
-- =================================================

UPDATE inventory

SET stock_quantity = stock_quantity

WHERE product_id = 1;


-- Check updated date

SELECT *

FROM inventory

WHERE product_id = 1;


-- =================================================
-- STEP 8 COMPLETE
-- =================================================