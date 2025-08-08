CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE customers (
  CustomerID INT PRIMARY KEY,
  CustomerName VARCHAR(255),
  Country VARCHAR(100)
);

CREATE TABLE orders (
  OrderID INT PRIMARY KEY,
  CustomerID INT,
  OrderDate DATE,
  TotalAmount DECIMAL(12,2),
  FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);

CREATE TABLE products (
  ProductID INT PRIMARY KEY,
  ProductName VARCHAR(255),
  Price DECIMAL(12,2)
);

CREATE TABLE order_details (
  OrderDetailID INT PRIMARY KEY,
  OrderID INT,
  ProductID INT,
  Quantity INT,
  FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
  FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT * FROM customers LIMIT 5;
SELECT * FROM orders ORDER BY OrderDate LIMIT 5;

-- Total Sales
SELECT SUM(TotalAmount) AS Total_Sales FROM orders;

-- Sales by country
SELECT Country, SUM(o.TotalAmount) AS Sales_By_Country
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY Country
ORDER BY Sales_By_Country DESC;

-- Top customers
CREATE VIEW Top_Customers AS
SELECT c.CustomerName, SUM(o.TotalAmount) AS Total_Spent
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerName
ORDER BY Total_Spent DESC;
-- =========================
-- 1. Basic SELECT + WHERE + ORDER BY
-- =========================
SELECT CustomerName, Country
FROM customers
WHERE Country = 'USA'
ORDER BY CustomerName ASC;

-- =========================
-- 2. GROUP BY + Aggregate Function (SUM)
-- =========================
SELECT CustomerID, SUM(TotalAmount) AS TotalSpent
FROM orders
GROUP BY CustomerID
ORDER BY TotalSpent DESC;

-- =========================
-- 3. INNER JOIN Example
-- Orders with customer names
-- =========================
SELECT o.OrderID, c.CustomerName, o.OrderDate, o.TotalAmount
FROM orders o
INNER JOIN customers c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC;

-- =========================
-- 4. LEFT JOIN Example
-- All customers, even if no orders
-- =========================
SELECT c.CustomerName, o.OrderID, o.TotalAmount
FROM customers c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerName;

-- =========================
-- 5. RIGHT JOIN Example
-- All orders, even if customer deleted
-- (MySQL supports RIGHT JOIN but it's rare)
-- =========================
SELECT o.OrderID, c.CustomerName, o.TotalAmount
FROM orders o
RIGHT JOIN customers c ON o.CustomerID = c.CustomerID;

-- =========================
-- 6. Subquery Example
-- Customers who spent above average
-- =========================
SELECT CustomerName
FROM customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM orders
    GROUP BY CustomerID
    HAVING SUM(TotalAmount) > (
        SELECT AVG(TotalAmount) FROM orders
    )
);

-- =========================
-- 7. Aggregate Function (AVG) with GROUP BY
-- Average order amount per country
-- =========================
SELECT c.Country, AVG(o.TotalAmount) AS AvgOrderValue
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Country
ORDER BY AvgOrderValue DESC;

-- =========================
-- 8. Create View
-- =========================
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT c.CustomerID, c.CustomerName, COUNT(o.OrderID) AS TotalOrders, SUM(o.TotalAmount) AS TotalSpent
FROM customers c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName;

-- Check the view
SELECT * FROM customer_order_summary;

-- =========================
-- 9. Create Index for Optimization
-- =========================
CREATE INDEX idx_customer_id_orders ON orders(CustomerID);
CREATE INDEX idx_product_id_orderdetails ON order_details(ProductID);

-- =========================
-- 10. JOIN Multiple Tables
-- =========================
SELECT o.OrderID, c.CustomerName, p.ProductName, od.Quantity, p.Price, (od.Quantity * p.Price) AS LineTotal
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN order_details od ON o.OrderID = od.OrderID
JOIN products p ON od.ProductID = p.ProductID
ORDER BY o.OrderID;



