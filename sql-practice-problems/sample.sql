-- https://sqlpracticeproblems.com/wp-content/uploads/2018/06/SQLPracticeProblems_Sample.pdf

-- 8. Orders shipping to France or Belgium
-- Looking at the Orders table, there’s a field called ShipCountry. Write a query that shows the
-- OrderID, CustomerID, and ShipCountry for the orders where the ShipCountry is either France
-- or Belgium.

SELECT OrderID, CustomerID, ShipCountry
FROM Orders
WHERE ShipCountry = "France"
OR ShipCountry = "Belguim"
;


-- 11. Showing only the Date with a DateTime field
-- In the output of the query above, showing the Employees in order of BirthDate, we see the
-- time of the BirthDate field, which we don’t want. Show only the date portion of the BirthDate
-- field.

-- MS SQL Server version:
SELECT FirstName, LastName, Title,
  CONVERT(date, BirthDate, 23) AS DateOnlyBirthDate
FROM Employees
ORDER BY BirthDate
;


-- 18. Products with associated supplier names
-- We’d like to show, for each product, the associated Supplier. Show the ProductID,
-- ProductName, and the CompanyName of the Supplier.
-- Sort the result by ProductID.
-- This question will introduce what may be a new concept—the Join clause in SQL. The Join
-- clause is used to join two or more relational database tables together in a logical way.
-- Here’s a data model of the relationship between Products and Suppliers.

SELECT ProductID, ProductName, CompanyName AS Supplier
FROM Suppliers JOIN Products
ON Suppliers.SupplierID = Products.SupplierID
;


-- 24. Customer list by region
-- A salesperson for Northwind is going on a business trip to visit customers, and would like to
-- see a list of all customers, sorted by region, alphabetically.
-- However, he wants the customers with no region (null in the Region field) to be at the end,
-- instead of at the top, where you’d normally find the null values. Within the same region,
-- companies should be sorted by CustomerID.

SELECT CustomerID, CompanyName, Region
FROM Customers
ORDER BY CASE WHEN Region IS NULL THEN 1 ELSE 0 END,
  Region, CustomerID
;


-- 32. High-value customers
-- We want to send all of our high-value customers a special VIP gift. We're defining high-value
-- customers as those who've made at least 1 order with a total value (not including the discount)
-- equal to $10,000 or more. We only want to consider orders made in the year 2016.

SELECT
  Customers.CustomerID
  , Customers.CompanyName
  , Orders.OrderID
  , SUM(Quantity * UnitPrice) AS TotalOrderAmount
FROM Customers
  JOIN Orders
    ON Customers.CustomerID = Orders.CustomerID
  JOIN OrderDetails
    ON Orders.OrderId = OrderDetails.OrderID
WHERE OrderDate >= '2016-01-01'
  AND OrderDate <= '2016-12-31'
GROUP BY
  Customers.CustomerID
  , Customers.CompanyName
  , Orders.OrderID
HAVING SUM(Quantity * UnitPrice) >= 10000
ORDER BY TotalOrderAmount DESC
;
