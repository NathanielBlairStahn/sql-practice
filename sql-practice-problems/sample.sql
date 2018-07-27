-- https://sqlpracticeproblems.com/wp-content/uploads/2018/06/SQLPracticeProblems_Sample.pdf

-- 8. Orders shipping to France or Belgium
-- Looking at the Orders table, there’s a field called ShipCountry. Write a query that shows the
-- OrderID, CustomerID, and ShipCountry for the orders where the ShipCountry is either France
-- or Belgium.

SELECT OrderID, CustomerID, ShipCountry
FROM Orders
WHERE ShipCountry = "France"
OR ShipCountry = "Belguim"

11. Showing only the Date with a DateTime field
In the output of the query above, showing the Employees in order of BirthDate, we see the
time of the BirthDate field, which we don’t want. Show only the date portion of the BirthDate
field.

-- MS SQL Server version:
SELECT FirstName, LastName, Title,
  CONVERT(date, BirthDate, 23) AS DateOnlyBirthDate
FROM Employees
ORDER BY BirthDate
