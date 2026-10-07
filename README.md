# E-Commerce Sales & Customer Analytics using MySQL

## 📌 Project Overview

This project analyzes an e-commerce business using MySQL 8.0 to identify
sales performance, customer behavior, product profitability, inventory
status, payment performance, and delivery efficiency.

The project is designed as a real-world SQL analytics project and covers
SQL fundamentals, advanced SQL, business analytics, query optimization,
stored procedures, triggers, and Power BI-ready analytical views.

---

## 🎯 Business Objectives

- Analyze overall e-commerce sales performance
- Identify high-value and repeat customers
- Analyze monthly revenue trends
- Identify top-performing products and categories
- Calculate product-level profit and profit margins
- Monitor inventory and low-stock products
- Analyze payment success and failure
- Measure delivery performance
- Segment customers based on purchasing behavior
- Prepare analytical datasets for Power BI dashboards

---

## 🗄️ Database

**Database:** `ecommerce_analytics`

**Database Engine:** MySQL 8.0

---

## 📊 Database Tables

The project contains 8 relational tables:

### 1. customers
Stores customer demographic and registration information.

### 2. categories
Stores product category information.

### 3. products
Stores product details, pricing, cost, and stock information.

### 4. orders
Stores customer order transactions and order status.

### 5. order_items
Stores products and quantities associated with each order.

### 6. payments
Stores payment method, status, date, and amount.

### 7. shipments
Stores shipping and delivery information.

### 8. inventory
Stores warehouse-level inventory information.

---

## 🔗 Database Relationships

```text
Customers
    |
    | 1 : Many
    v
Orders
    |
    | 1 : Many
    v
Order_Items
    |
    | Many : 1
    v
Products
    |
    | Many : 1
    v
Categories

Orders
    |
    +---- Payments
    |
    +---- Shipments

Products
    |
    +---- Inventory
