-- =========================================================================
-- AZURE DATABASE FOR POSTGRESQL - SCHEMAS & CRUD VERIFICATION SCRIPT
-- =========================================================================
-- This script contains the DDL for creating the database objects (tables, 
-- primary keys, foreign keys) and the DML for standard CRUD operations 
-- to verify data persistence and referential integrity.
-- =========================================================================

-- 1. Create a dedicated database for lab workload (optional/reference)
-- CREATE DATABASE labdb;

-- 2. DDL - Create lookup table for Categories
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. DDL - Create Products table referencing Categories
CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(200)   NOT NULL,
    price         NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_qty     INT            NOT NULL DEFAULT 0,
    category_id   INT            REFERENCES categories(category_id) ON DELETE SET NULL,
    created_at    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- 4. DDL - Create Orders table referencing Products
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    product_id    INT            REFERENCES products(product_id) ON DELETE CASCADE,
    quantity      INT            NOT NULL CHECK (quantity > 0),
    order_date    DATE           DEFAULT CURRENT_DATE
);

-- =========================================================================
-- CRUD OPERATIONS (DATA MANIPULATION LANGUAGE - DML)
-- =========================================================================

-- ── CREATE (Insert Data) ─────────────────────────────────────────────────

-- Insert lookup values into categories
INSERT INTO categories (category_name) 
VALUES 
    ('Electronics'), 
    ('Office Supplies'), 
    ('Furniture');

-- Insert product records with category references
INSERT INTO products (product_name, price, stock_qty, category_id)
VALUES
    ('Laptop Pro 15',    899.99, 25, 1),
    ('Wireless Mouse',    29.99, 80, 1),
    ('Ergonomic Chair',  349.00, 10, 3),
    ('Notebook A4',        3.50, 200, 2);

-- Insert transactional order records
INSERT INTO orders (product_id, quantity) 
VALUES 
    (1, 2), 
    (2, 5), 
    (4, 20);

-- ── READ (Query and Join Data) ───────────────────────────────────────────

-- Read list of products and join category name, sorted by price descending
SELECT p.product_name, p.price, c.category_name
FROM   products p
JOIN   categories c USING (category_id)
ORDER  BY p.price DESC;

-- ── UPDATE (Modify Data) ─────────────────────────────────────────────────

-- Update pricing and stock levels for the 'Ergonomic Chair' product
UPDATE products
SET    price = 319.99, 
       stock_qty = 8
WHERE  product_name = 'Ergonomic Chair';

-- Verify the update succeeded
SELECT product_name, price, stock_qty 
FROM   products 
WHERE  product_id = 3;

-- ── DELETE (Remove Data & Verify Cascade Constraints) ────────────────────

-- Delete a product and test constraint checks
DELETE FROM products 
WHERE  product_name = 'Notebook A4';

-- Confirm deletion and check remaining count
SELECT COUNT(*) AS remaining_products 
FROM   products;
