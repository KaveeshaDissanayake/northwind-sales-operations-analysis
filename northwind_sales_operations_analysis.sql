-- ==================================================
-- NORTHWIND SALES & OPERATIONS ANALYSIS
-- SQL Engine: DuckDB
-- Author: Kaveesha Dissanayake
-- ==================================================

-- ==================================================
-- SECTION 1: CUSTOMER ANALYSIS
-- ==================================================

-- Q1. Which countries have the most customers?

SELECT
	c.Country,
	COUNT(*) AS CustomerCount
FROM
	Customers AS c
GROUP BY
	c.Country
ORDER BY
	CustomerCount DESC;


-- Q2.Which customers placed the most orders?

SELECT
	c.CustomerName,
	COUNT(o.OrderID) AS TotalOrders
FROM
	Orders AS o
INNER JOIN Customers AS c
    ON
	o.CustomerID = c.CustomerID
GROUP BY
	c.CustomerID,
	c.CustomerName
ORDER BY
	TotalOrders DESC;


-- Q3.Which customers purchased the most units?

SELECT
	c.CustomerName,
	SUM(od.Quantity) AS TotalUnitsPurchased
FROM
	Customers AS c
INNER JOIN Orders AS o
    ON
	c.CustomerID = o.CustomerID
INNER JOIN OrderDetails AS od
    ON
	o.OrderID = od.OrderID
GROUP BY
	c.CustomerID,
	c.CustomerName
ORDER BY
	TotalUnitsPurchased DESC;


-- Q4.Customer groups based on number of orders

SELECT
	c.CustomerName,
	COUNT(o.OrderID) AS TotalOrders,
	CASE
		WHEN COUNT(o.OrderID) >= 7 THEN 'High Activity'
		WHEN COUNT(o.OrderID) >= 4 THEN 'Medium Activity'
		ELSE 'Low Activity'
	END AS CustomerSegment
FROM
	Customers AS c
LEFT JOIN Orders AS o
    ON
	c.CustomerID = o.CustomerID
GROUP BY
	c.CustomerID,
	c.CustomerName
ORDER BY
	TotalOrders DESC;


-- ==================================================
-- SECTION 2: PRODUCT ANALYSIS
-- ==================================================

-- Q5.How many products are available in each product category?

SELECT
	c.CategoryName,
	COUNT(p.ProductID) AS ProductCount
FROM
	Categories AS c
LEFT JOIN Products AS p
    ON
	c.CategoryID = p.CategoryID
GROUP BY
	c.CategoryID,
	c.CategoryName
ORDER BY
	ProductCount DESC;


--Q6.What are the 10 most expensive products?

SELECT
	ProductName,
	Price
FROM
	Products
ORDER BY
	Price Desc
LIMIT 10;


--Q7.Which products sold the highest total number of units?

SELECT
	p.ProductName,
	SUM(od.Quantity) AS TotalUnitSold
FROM
	OrderDetails AS od
JOIN Products AS p
    ON
	p.ProductID = od.ProductID
GROUP BY
	p.ProductID,
	p.ProductName
ORDER BY
	TotalUnitSold DESC
LIMIT 10;


--Q8.Which product categories sold the largest quantity of products?

SELECT
	c.CategoryName,
	SUM(od.Quantity) AS TotalUnitsSold
FROM
	Categories AS c
INNER JOIN Products AS p
    ON
	c.CategoryID = p.CategoryID
INNER JOIN OrderDetails AS od
    ON
	p.ProductID = od.ProductID
GROUP BY
	c.CategoryID,
	c.CategoryName
ORDER BY
	TotalUnitsSold DESC;


--Q9.Which products have sold more than 100 units in total?

SELECT
	p.ProductName,
	SUM(od.Quantity) AS TotalUnitsSold
FROM
	Products AS p
INNER JOIN OrderDetails AS od
    ON
	p.ProductID = od.ProductID
GROUP BY
	p.ProductID,
	p.ProductName
HAVING
	SUM(od.Quantity) > 100
ORDER BY
	TotalUnitsSold DESC;


-- ==================================================
-- SECTION 3: SUPPLIER ANALYSIS
-- ==================================================

--Q10.Which countries have the highest number of suppliers?

SELECT
	Country,
	count(*) AS SupplierCount
FROM
	Suppliers
GROUP BY
	Country
ORDER BY
	SupplierCount DESC;


--Q11.Which suppliers provide the largest number of different products?

SELECT
	s.SupplierName,
	COUNT(DISTINCT p.ProductID) AS NumberOfProducts
FROM
	Suppliers AS s
INNER JOIN Products AS p
    ON
	s.SupplierID = p.SupplierID
GROUP BY
	s.SupplierID,
	s.SupplierName
ORDER BY
	NumberOfProducts DESC;


-- ==================================================
-- SECTION 4: OPERATIONS ANALYSIS
-- ==================================================

--Q12.Which employees handled the highest number of orders?

SELECT
	e.EmployeeID,
	CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
	COUNT(o.OrderID) AS OrderCount
FROM
	Employees AS e
INNER JOIN Orders AS o
    ON
	e.EmployeeID = o.EmployeeID
GROUP BY
	e.EmployeeID,
	e.FirstName,
	e.LastName
ORDER BY
	OrderCount DESC;


--Q13.Which shipping company handled the most orders?

SELECT
	s.ShipperName,
	COUNT(o.OrderID) AS OrdersHandled
FROM
	Shippers AS s
INNER JOIN Orders AS o
    ON
	s.ShipperID = o.ShipperID
GROUP BY
	s.ShipperID,
	s.ShipperName
ORDER BY
	OrdersHandled DESC;


--Q14.Which customer countries account for the highest total quantity of products ordered?

SELECT
	c.Country,
	SUM(od.Quantity) AS TotalUnitsPurchased
FROM
	Customers AS c
INNER JOIN Orders AS o
    ON
	c.CustomerID = o.CustomerID
INNER JOIN OrderDetails AS od
    ON
	o.OrderID = od.OrderID
GROUP BY
	c.Country
ORDER BY
	TotalUnitsPurchased DESC
LIMIT 5;


--Q15.For each employee, which customer countries did they handle the most orders from?

WITH EmployeeCountryOrders AS (
SELECT
	e.EmployeeID,
	CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
	c.Country AS CustomerCountry,
	COUNT(o.OrderID) AS OrdersHandled
FROM
	Employees AS e
INNER JOIN Orders AS o
    ON e.EmployeeID = o.EmployeeID
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
GROUP BY
	e.EmployeeID,
	e.FirstName,
	e.LastName,
	c.Country
),
RankedCountries AS (
SELECT *,
	RANK() OVER (
            PARTITION BY EmployeeID
ORDER BY
	OrdersHandled DESC
        ) AS CountryRank
FROM
	EmployeeCountryOrders
)
SELECT
	EmployeeID,
	EmployeeName,
	CustomerCountry,
	OrdersHandled
FROM
	RankedCountries
WHERE
	CountryRank = 1
ORDER BY
	EmployeeID;