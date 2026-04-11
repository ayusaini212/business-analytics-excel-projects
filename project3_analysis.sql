-- =============================================
-- INVENTORY PROFITABILITY ANALYSIS — SQL
-- Author: Ayush Saini
-- Project: Inventory & Operations Dashboard
-- Tool: SQL (compatible with MySQL / PostgreSQL)
-- =============================================


-- =============================================
-- SECTION 1 — TABLE SETUP
-- =============================================

CREATE TABLE products (
  product_id INT,
  product_name TEXT,
  category TEXT,
  supplier_id INT,
  cost INT,
  selling_price INT,
  quantity INT,
  sales_per_month INT
);

CREATE TABLE suppliers (
  supplier_id INT,
  supplier_name TEXT,
  location TEXT,
  lead_time_days INT,
  on_time_delivery_percent INT
);

INSERT INTO products VALUES (1, 'Wireless Mouse', 'Electronics', 1, 500, 800, 200, 50);
INSERT INTO products VALUES (2, 'Keyboard', 'Electronics', 2, 700, 1000, 150, 40);
INSERT INTO products VALUES (3, 'Notebook', 'Stationary', 3, 50, 120, 500, 200);
INSERT INTO products VALUES (4, 'Office Chair', 'Furniture', 4, 3000, 5000, 50, 10);
INSERT INTO products VALUES (5, 'Pen Pack', 'Stationary', 3, 20, 60, 1000, 300);
INSERT INTO products VALUES (6, 'Monitor', 'Electronics', 1, 5000, 7000, 80, 20);
INSERT INTO products VALUES (7, 'Hard Disk', 'Electronics', 1, 600, 660, 700, 250);
INSERT INTO products VALUES (8, 'Gaming Desk', 'Furniture', 4, 7000, 9000, 60, 15);
INSERT INTO products VALUES (9, 'Webcam', 'Electronics', 1, 450, 850, 100, 30);
INSERT INTO products VALUES (10, 'Screen Protector', 'Electronics', 2, 50, 90, 10, 0);

INSERT INTO suppliers VALUES (1, 'Supplier A', 'Delhi', 7, 95);
INSERT INTO suppliers VALUES (2, 'Supplier B', 'Mumbai', 10, 88);
INSERT INTO suppliers VALUES (3, 'Supplier C', 'Bangalore', 5, 92);
INSERT INTO suppliers VALUES (4, 'Supplier D', 'Gurgaon', 15, 78);


-- =============================================
-- SECTION 2 — PROFITABILITY ANALYSIS
-- =============================================

-- Query 1: Full product profitability report with tier classification
SELECT product_name,
       category,
       cost,
       selling_price,
       selling_price - cost AS profit_per_unit,
       (selling_price - cost) * 100 / selling_price AS margin_percent,
       CASE
         WHEN (selling_price - cost) * 100 / selling_price >= 40 THEN 'High'
         WHEN (selling_price - cost) * 100 / selling_price >= 20 THEN 'Medium'
         ELSE 'Low'
       END AS profit_tier
FROM products
ORDER BY margin_percent DESC;


-- Query 2: Category performance summary
SELECT category,
       COUNT(*) AS total_products,
       SUM(cost * quantity) AS total_inventory_value,
       AVG((selling_price - cost) * 100 / selling_price) AS avg_margin_percent,
       SUM((selling_price - cost) * sales_per_month) AS monthly_profit
FROM products
GROUP BY category
ORDER BY monthly_profit DESC;


-- Query 3: Top 5 products by total monthly profit
SELECT product_name,
       category,
       (selling_price - cost) * sales_per_month AS monthly_profit,
       (selling_price - cost) * 100 / selling_price AS margin_percent
FROM products
ORDER BY monthly_profit DESC
LIMIT 5;


-- Query 4: Products above average profit per unit
SELECT product_name,
       selling_price - cost AS profit_per_unit
FROM products
WHERE selling_price - cost > (
    SELECT AVG(selling_price - cost) FROM products
)
ORDER BY profit_per_unit DESC;


-- =============================================
-- SECTION 3 — INVENTORY HEALTH
-- =============================================

-- Query 5: Stock status and movement classification
SELECT product_name,
       quantity,
       sales_per_month,
       CASE
         WHEN sales_per_month > 0
         THEN quantity / sales_per_month
         ELSE 999
       END AS months_of_stock,
       CASE
         WHEN sales_per_month = 0 THEN 'Dead Stock'
         WHEN sales_per_month < 20 THEN 'Slow Mover'
         WHEN sales_per_month < 100 THEN 'Normal'
         ELSE 'Fast Mover'
       END AS movement_type,
       CASE
         WHEN sales_per_month = 0 THEN 'Critical'
         WHEN quantity / sales_per_month <= 2 THEN 'Restock Now'
         WHEN quantity / sales_per_month <= 4 THEN 'Monitor'
         ELSE 'OK'
       END AS stock_status
FROM products
ORDER BY sales_per_month ASC;


-- Query 6: Dead and slow stock with capital tied up
SELECT product_name,
       category,
       quantity,
       sales_per_month,
       cost * quantity AS capital_tied_up
FROM products
WHERE sales_per_month < 20
ORDER BY capital_tied_up DESC;


-- =============================================
-- SECTION 4 — SUPPLIER PERFORMANCE
-- =============================================

-- Query 7: Full supplier scorecard
SELECT s.supplier_name,
       s.location,
       s.lead_time_days,
       s.on_time_delivery_percent,
       COUNT(p.product_id) AS total_products,
       SUM((p.selling_price - p.cost) * p.sales_per_month) AS total_monthly_profit,
       AVG((p.selling_price - p.cost) * 100 / p.selling_price) AS avg_margin_percent,
       CASE
         WHEN s.lead_time_days <= 7 AND s.on_time_delivery_percent >= 90 THEN 'Reliable'
         WHEN s.lead_time_days <= 10 AND s.on_time_delivery_percent >= 85 THEN 'Average'
         ELSE 'At Risk'
       END AS supplier_rating
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_name, s.location, s.lead_time_days, s.on_time_delivery_percent
ORDER BY total_monthly_profit DESC;


-- Query 8: Products from reliable suppliers only
SELECT p.product_name,
       p.category,
       s.supplier_name,
       s.lead_time_days,
       s.on_time_delivery_percent
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IN (
    SELECT supplier_id FROM suppliers
    WHERE lead_time_days <= 7
    AND on_time_delivery_percent >= 90
)
ORDER BY p.category;


-- =============================================
-- SECTION 5 — BUSINESS INSIGHTS SUMMARY
-- =============================================

-- Query 9: High cost low margin problem products
SELECT product_name,
       cost,
       selling_price,
       (selling_price - cost) * 100 / selling_price AS margin_percent
FROM products
WHERE cost > 500
AND (selling_price - cost) * 100 / selling_price < 20
ORDER BY cost DESC;


-- Query 10: Overall business KPIs
SELECT COUNT(*) AS total_products,
       SUM(cost * quantity) AS total_inventory_value,
       SUM((selling_price - cost) * sales_per_month) AS total_monthly_profit,
       AVG((selling_price - cost) * 100 / selling_price) AS avg_margin_percent,
       SUM(CASE WHEN sales_per_month = 0
           THEN cost * quantity ELSE 0 END) AS dead_stock_value
FROM products;