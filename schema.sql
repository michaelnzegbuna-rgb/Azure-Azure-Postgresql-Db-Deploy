-- =========================================================================
-- POSTGRESQL LAB DATABASE — TABLE SETUP AND CRUD VALIDATION
-- =========================================================================
-- Defines the core tables for the lab's inventory/order schema (DDL),
-- then runs through a full set of insert/read/update/delete operations
-- (DML) to confirm the data persists correctly and the foreign key
-- relationships hold up as expected.
-- =========================================================================

-- Reference only — uncomment if the target database hasn't been created yet
-- CREATE DATABASE labdb;

-- --------------------------------------------------------------
-- Table: categories
-- Simple lookup table; every product belongs to one category.
-- --------------------------------------------------------------
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- --------------------------------------------------------------
-- Table: products
-- Each row links back to a category. If that category is ever
-- deleted, category_id falls back to NULL rather than blocking
-- the delete.
-- --------------------------------------------------------------
CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(200)   NOT NULL,
    price         NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_qty     INT            NOT NULL DEFAULT 0,
    category_id   INT            REFERENCES categories(category_id) ON DELETE SET NULL,
    created_at    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------------
-- Table: orders
-- Tracks individual order line items against a product. Deleting
-- a product here cascades and removes its associated orders too.
-- --------------------------------------------------------------
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    product_id    INT            REFERENCES products(product_id) ON DELETE CASCADE,
    quantity      INT            NOT NULL CHECK (quantity > 0),
    order_date    DATE           DEFAULT CURRENT_DATE
);

-- =========================================================================
-- CRUD WALKTHROUGH
-- =========================================================================

-- ── INSERT: seed the lookup table first ─────────────────────────────────
INSERT INTO categories (category_name)
VALUES
    ('Electronics'),
    ('Office Supplies'),
    ('Furniture');

-- ── INSERT: products, each tagged with its category_id from above ──────
INSERT INTO products (product_name, price, stock_qty, category_id)
VALUES
    ('Laptop Pro 15',    899.99, 25, 1),
    ('Wireless Mouse',    29.99, 80, 1),
    ('Ergonomic Chair',  349.00, 10, 3),
    ('Notebook A4',        3.50, 200, 2);

-- ── INSERT: a handful of order records against existing products ───────
INSERT INTO orders (product_id, quantity)
VALUES
    (1, 2),
    (2, 5),
    (4, 20);

-- ── READ: join products to their category name, priciest first ────────
SELECT p.product_name, p.price, c.category_name
FROM   products p
JOIN   categories c USING (category_id)
ORDER  BY p.price DESC;

-- ── UPDATE: adjust price and stock on a single product ─────────────────
UPDATE products
SET    price = 319.99,
       stock_qty = 8
WHERE  product_name = 'Ergonomic Chair';

-- Sanity check that the update actually landed
SELECT product_name, price, stock_qty
FROM   products
WHERE  product_id = 3;

-- ── DELETE: remove a product and confirm referential integrity holds ───
DELETE FROM products
WHERE  product_name = 'Notebook A4';

-- Confirm the row count dropped as expected after the delete
SELECT COUNT(*) AS remaining_products
FROM   products;
