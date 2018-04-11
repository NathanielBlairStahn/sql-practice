-- From Job Club with Jack, Wed 3/7/18, 3-5pm

-- Order of operations:
-- FROM, JOIN, ON, WHERE, GROUP BY, HAVING, SELECT, ORDER, LIMIT
--
-- Problem 1: 2 tables:
-- buy: city, state, neighborhood, cost
-- rent: city, state, neighborhood, rent
--
-- Note: cost is average monthly cost to buy, rent is average monthly cost to rent.
--
-- Decide whether it's better (cheaper) to buy or to rent, and select that price.

-- Problem 2: 2 tables
-- neighborhoods: id, city, state, neighborhood
-- properties: id, neighborhood_id, cost
--
-- For each city and state, including those with no properties, find the number of properties and the average cost of properties. (If none, these will be 0 and Null, respectively.)

SELECT city, state, COUNT(properties.id), AVG(cost)
FROM neighborhoods LEFT JOIN properties
ON neighborhoods.id = properties.neighborhood_id
GROUP BY city, state

-- Problem 3: 2 tables:
-- people: id, name
-- friends: id1, id2
--
-- Note: Each friend pair shows up once, so either (1,3) or (3,1) could be in friends table, but not both.
--
-- Return all id's in friends of friends. Include both orderings of id pairs.

SELECT f1.id1, f2.id2
FROM friends AS f1 JOIN friends AS f2
ON f1.id1 = f2.id1 OR f1.id1 = f2.id2 OR f1.id2 = f2.id1 OR f1.id2 = f2.id2
WHERE f1.id1 != f2.id2


-- From http://www.programmerinterview.com/index.php/database-sql/practice-interview-question-1/

Salesperson
ID	Name	Age	Salary
1	Abe	61	140000
2	Bob	34	44000
5	Chris	34	40000
7	Dan	41	52000
8	Ken	57	115000
11	Joe	38	38000

Customer
ID	Name	City	Industry Type
4	Samsonic	pleasant	J
6	Panasung	oaktown	J
7	Samony	jackson	B
9	Orange	Jackson	B

Orders
Number	order_date	cust_id	salesperson_id	Amount
10	8/2/96	4	2	540
20	1/30/99	4	8	1800
30	7/14/95	9	1	460
40	1/29/98	7	2	2400
50	2/3/98	6	7	600
60	3/2/98	6	7	720
70	5/6/98	9	7	150

Given the tables above, find the following:

a. The names of all salespeople that have an order with Samsonic.

-- Using a double join:
SELECT Salesperson.Name
FROM Salesperson JOIN Customer JOIN Orders
ON Salesperson.ID = Orders.salesperson_id
AND Customer.ID = Orders.cust_id
WHERE Customer.Name = 'Samsonic';

-- Or using a subquery and one join:
SELECT Salesperson.Name
FROM Salesperson
WHERE Salesperson.ID
IN (SELECT Orders.salesperson_id
FROM Orders JOIN Customer
ON Orders.cust_id = Customer.ID
WHERE Customer.Name = 'Samsonic')

b. The names of all salespeople that do not have any order with Samsonic.

SELECT Salesperson.Name FROM Salesperson
WHERE Salesperson.ID
NOT IN (SELECT Orders.salesperson_id
FROM Orders JOIN Customer
ON Orders.cust_id = Customer.ID
WHERE Customer.Name = 'Samsonic');


c. The names of salespeople that have 2 or more orders.

SELECT Salesperson.Name
FROM Salesperson JOIN Ordres
ON Salesperson.ID = Orders.salesperson_id
GROUP BY Salesperson.ID, Salesperson.Name
HAVING COUNT(Order.Number) > 1;
-- Or: HAVING COUNT(Orders.salesperson_id) > 1;

d. Write a SQL statement to insert rows into a table called highAchiever(Name, Age), where a salesperson must have a salary of 100,000 or greater to be included in the table.

INSERT INTO highAchiever (Name, Age)
SELECT Salesperson.Name, Salesperson.Age
FROM Salesperson
WHERE Salesperson.Salary >= 100000;

-- Practice SQL Interview Question #2
-- https://www.programmerinterview.com/index.php/database-sql/practice-interview-question-2/

This question was asked in a Google interview: Given the 2 tables below, User and UserHistory:

User
user_id
name
phone_num

UserHistory
user_id
date
action

1. Write a SQL query that returns the name, phone number and most recent date for any user that has logged in over the last 30 days (you can tell a user has logged in if the action field in UserHistory is set to "logged_on").

Every time a user logs in a new row is inserted into the UserHistory table with user_id, current date and action (where action = "logged_on").

SELECT User.name, User.phone_num, UserHistory.date
FROM User JOIN UserHistory
ON User.user_id = UserHistory.user_id
WHERE DATEDIFF(CURRENT_DATE, UserHistory.date) <= 30
-- Or: WHERE UserHistory.date >= date_sub(curdate(), interval 30 day)
AND action = 'logged_on'
ORDER BY UserHistory.date DESC
LIMIT 1;

-- Or use MAX:
select User.name, User.phone_num, max(UserHistory.date)
from User, UserHistory
where User.user_id = UserHistory.user_id
and UserHistory.action = 'logged_on'
and UserHistory.date >= date_sub(curdate(), interval 30 day)
group by User.user_id, User.name, User.phone_num;


2. Write a SQL query to determine which user_ids in the User table are not contained in the UserHistory table (assume the UserHistory table has a subset of the user_ids in User table). Do not use the SQL MINUS statement. Note: the UserHistory table can have multiple entries for each user_id.

Note that your SQL should be compatible with MySQL 5.0, and avoid using subqueries.

SELECT User.user_id
FROM User LEFT OUTER JOIN UserHistory
ON User.user_id = UserHistory.user_id
WHERE UserHistory.date IS NULL;

-- This is their solution:
select distinct u.user_id
from User as u
left join UserHistory as uh on u.user_id=uh.user_id
where uh.user_id is null

-- https://www.programmerinterview.com/index.php/database-sql/advanced-sql-interview-questions-continued-part-2/

In the tables above, each order in the Orders table is associated with a given Customer through the cust_id foreign key column that references the ID column in the Customer table.

Here is the problem: find the largest order amount for each salesperson and the associated order number, along with the customer to whom that order belongs to. You can present your answer in any database’s SQL – MySQL, Microsoft SQL Server, Oracle, etc.

-- This won't work because there are columns that aren't aggregated:
SELECT Salesperson.ID, MAX(Orders.Amount), Orders.Number. Customers.Name
FROM Customers JOIN Orders JOIN Salesperson
ON Customers.ID = Orders.cust_id
AND Salesperson.ID = Orders.salesperson_id
GROUP BY Salesperson.ID;

-- This solution works; if a salesperson has more than one highest order,
-- it will return all of them.
SELECT m.salesperson_id, m.max_amt, Orders.Number, Customers.Name
FROM
  (SELECT salesperson_id, MAX(Orders.Amount) AS max_amt
  FROM Orders GROUP BY salesperson_id) AS m
JOIN Orders JOIN Customers
ON m.salesperson_id = Orders.salesperson_id
AND m.max_amt = Orders.Amount
AND Orders.cust_id = Customers.ID;
