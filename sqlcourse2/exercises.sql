SELECT Statement

http://www.sqlcourse2.com/select2.html

--Format:
--SELECT [ALL | DISTINCT] column1[,column2] FROM table1[,table2] [WHERE "conditions"] [GROUP BY "column-list"] [HAVING "conditions] [ORDER BY "column-list" [ASC | DESC] ]

Review Exercises (SELECT)
1. From the items_ordered table, select a list of all items purchased for customerid 10449. Display the customerid, item, and price for this customer.
2. Select all columns from the items_ordered table for whoever purchased a Tent.
3. Select the customerid, order_date, and item values from the items_ordered table for any items in the item column that start with the letter "S".
4. Select the distinct items in the items_ordered table. In other words, display a listing of each of the unique items from the items_ordered table.
5. Make up your own select statements and submit them.

Answers:
1.
SELECT customerid, item, price FROM items_ordered
WHERE customerid = 10449;

2.
SELECT * FROM items_ordered
WHERE item='Tent';

3.
SELECT customerid, order_date, item  FROM items_ordered
WHERE item LIKE 'S%';

4.
SELECT DISTINCT item  FROM items_ordered
ORDER BY item;

5. Find all customers who have made more than one order. List their customer id, first name, last name, and the number of orders they made.
SELECT customers.customerid, customers.firstname, customers.lastname,  COUNT(items_ordered.order_date)
FROM customers JOIN items_ordered
ON customers.customerid = items_ordered.customerid
GROUP BY items_ordered.customerid, customers.firstname, customers.lastname
HAVING COUNT(items_ordered.order_date)>1;

6. -- List all items ordered, and who ordered them. Order by the customer's last name.
SELECT customers.customerid, customers.firstname, customers.lastname, items_ordered.item
FROM customers JOIN items_ordered
ON customers.customerid = items_ordered.customerid
ORDER BY customers.lastname;

7. List all items and how many customers ordered that item.
SELECT item, COUNT(customerid)
FROM items_ordered
GROUP BY item;

8. Find all people who ordered a Flashlight.
SELECT customers.firstname, customers.lastname, items_ordered.item
FROM customers JOIN items_ordered
ON customers.customerid = items_ordered.customerid
WHERE items_ordered.item = 'Flashlight'

-- Or:
SELECT c.firstname, c.lastname
FROM customers as c
WHERE EXISTS
(SELECT i.customerid FROM items_ordered AS i
WHERE c.customerid = i.customerid
AND item = 'Flashlight');

Shawn	Dalton
Isabela	Moore

8. Find all people who ordered a Flashlight, and list all the items they ordered.
SELECT customers.firstname, items_ordered.item FROM
(SELECT customerid FROM items_ordered
WHERE item = 'Flashlight') AS c
JOIN customers JOIN items_ordered
ON c.customerid = customers.customerid
AND items_ordered.customerid = customers.customerid;

9. Find all people who did not order a Flashlight.
SELECT firstname, lastname FROM customers
WHERE customerid NOT IN
(SELECT customerid FROM items_ordered
WHERE item = 'Flashlight')
ORDER BY lastname, firstname;

-- Or:
SELECT c.firstname, c.lastname
FROM customers AS c
WHERE NOT EXISTS
(SELECT i.customerid FROM items_ordered AS i
WHERE c.customerid = i.customerid
AND item = 'Flashlight')
ORDER BY c.lastname, c.firstname;

-- Or:
SELECT c.firstname, c.lastname
FROM customers AS c
LEFT OUTER JOIN
(SELECT i.customerid AS id FROM items_ordered AS i
WHERE item = 'Flashlight') AS f
ON c.customerid = f.id
WHERE f.id IS NULL
ORDER BY c.lastname, c.firstname;

Leroy	Brown
Elroy	Cleaver
Donald	Davids
Conrad	Giles
Sarah	Graham
John	Gray
Mary Ann	Howell
Michael	Howell
Lisa	Jones
Elroy	Keller
Kelly	Mendoza
Linda	Sakahara
Anthony	Sanchez
Ginger	Schultz
Kevin	Smith

10. Find the names of all customers who did not order anything.
SELECT c.firstname, c.lastname
FROM customers as c
LEFT OUTER JOIN items_ordered as i
ON c.customerid = i.customerid
WHERE i.customerid IS NULL;

Ginger  Schultz
Kelly	Mendoza
Michael	Howell
Elroy	Cleaver
Linda	Sakahara
Sarah	Graham

Aggregate Functions

http://www.sqlcourse2.com/agg_functions.html

MIN	returns the smallest value in a given column
MAX	returns the largest value in a given column
SUM	returns the sum of the numeric values in a given column
AVG	returns the average value of a given column
COUNT	returns the total number of values in a given column
COUNT(*)	returns the number of rows in a table

Review Exercises (Aggregate functions)

1. Select the maximum price of any item ordered in the items_ordered table. Hint: Select the maximum price only.
2. Select the average price of all of the items ordered that were purchased in the month of Dec.
3. What are the total number of rows in the items_ordered table?
4. For all of the tents that were ordered in the items_ordered table, what is the price of the lowest tent? Hint: Your query should return the price only.

1.
SELECT MAX(price) FROM items_ordered;

2.
SELECT AVG(price) FROM items_ordered
WHERE order_date LIKE '%Dec%';

3.
SELECT COUNT(*) FROM items_ordered;

4.
SELECT MIN(price) FROM items_ordered
WHERE item='Tent';



GROUP BY clause

http://www.sqlcourse2.com/groupby.html

The GROUP BY clause will gather all of the rows together that contain data in the specified column(s) and will allow aggregate functions to be performed on the one or more columns. This can best be explained by an example:

GROUP BY clause syntax:

SELECT column1,
SUM(column2)

FROM "list-of-tables"

GROUP BY "column-list";

Review Exercises (GROUP BY)
1.How many people are in each unique state in the customers table? Select the state and display the number of people in each. Hint: count is used to count rows in a column, sum works on numeric data only.
2. From the items_ordered table, select the item, maximum price, and minimum price for each specific item in the table. Hint: The items will need to be broken up into separate groups.
3. How many orders did each customer make? Use the items_ordered table. Select the customerid, number of orders they made, and the sum of their orders. Click the Group By answers link below if you have any problems.

1.
SELECT state, COUNT(customerid)
FROM customers
GROUP BY state;

2.
SELECT item, MAX(price), MIN(price)
FROM items_ordered
GROUP BY item;

3.
SELECT customerid, COUNT(order_date), SUM(price)
FROM items_ordered
GROUP BY customerid;


HAVING clause

http://www.sqlcourse2.com/having.html

The HAVING clause allows you to specify conditions on the rows for each group - in other words, which rows should be selected will be based on the conditions you specify. The HAVING clause should follow the GROUP BY clause if you are going to use it.

HAVING clause syntax:

SELECT column1,
SUM(column2)

FROM "list-of-tables"

GROUP BY "column-list"

HAVING "condition";

Review Exercises (note: yes, they are similar to the group by exercises, but these contain the HAVING clause requirements

-- 1. How many people are in each unique state in the customers table that have more than one person in the state? Select the state and display the number of how many people are in each if it's greater than 1.
-- 2. From the items_ordered table, select the item, maximum price, and minimum price for each specific item in the table. Only display the results if the maximum price for one of the items is greater than 190.00.
-- 3. How many orders did each customer make? Use the items_ordered table. Select the customerid, number of orders they made, and the sum of their orders if they purchased more than 1 item.

1.
SELECT state, COUNT(customerid)
FROM customers
GROUP BY state
HAVING COUNT(customerid) > 1;

2.
SELECT item, MAX(price), MIN(price)
FROM items_ordered
GROUP BY item
HAVING MAX(price) > 190.00;

3. Two options:
SELECT customerid, COUNT(order_date), SUM(price)
FROM items_ordered
GROUP BY customerid
HAVING COUNT(order_date) > 1;

10101	6	320.75
10298	5	118.88
10299	2	1288.00
10330	3	72.75
10410	2	281.72
10438	3	95.24
10439	2	113.50
10449	6	930.79

SELECT customerid, COUNT(customerid), SUM(price)
FROM items_ordered
GROUP BY customerid
HAVING COUNT(customerid) > 1;

10101	6	320.75
10298	5	118.88
10299	2	1288.00
10330	3	72.75
10410	2	281.72
10438	3	95.24
10439	2	113.50
10449	6	930.79

ORDER BY clause

http://www.sqlcourse2.com/orderby.html

ORDER BY is an optional clause which will allow you to display the results of your query in a sorted order (either ascending order or descending order) based on the columns that you specify to order by.

ORDER BY clause syntax:

SELECT column1, SUM(column2) FROM "list-of-tables" ORDER BY "column-list" [ASC | DESC];

[ ] = optional

Review Exercises (ORDER BY)

1. Select the lastname, firstname, and city for all customers in the customers table. Display the results in Ascending Order based on the lastname.
2. Same thing as exercise #1, but display the results in Descending order.
3. Select the item and price for all of the items in the items_ordered table that the price is greater than 10.00. Display the results in Ascending order based on the price.

1.
SELECT lastname, firstname, city
FROM customers
ORDER BY lastname;

2.
SELECT lastname, firstname, city
FROM customers
ORDER BY lastname DESC;

3.
SELECT item, price FROM items_ordered
WHERE PRICE > 10.00
ORDER BY price ASC;

Combining Conditions & Boolean Operators

http://www.sqlcourse2.com/boolean.html

Review Exercises

1. Select the customerid, order_date, and item from the items_ordered table for all items unless they are 'Snow Shoes' or if they are 'Ear Muffs'. Display the rows as long as they are not either of these two items.
2. Select the item and price of all items that start with the letters 'S', 'P', or 'F'.

1.
SELECT customerid, order_date, item
FROM items_ordered
WHERE (item <> 'Snow Shoes') AND (item <> 'Ear Muffs');

2.
SELECT item, price FROM items_ordered
WHERE item LIKE 'S%' OR item LIKE 'P%' OR item LIKE 'F%';

IN & BETWEEN

http://www.sqlcourse2.com/setoper.html

The IN conditional operator is really a set membership test operator. That is, it is used to test whether or not a value (stated before the keyword IN) is "in" the list of values provided after the keyword IN.

For example:

SELECT employeeid, lastname, salary
FROM employee_info
WHERE lastname IN ('Hernandez', 'Jones', 'Roberts', 'Ruiz');

This statement will select the employeeid, lastname, salary from the employee_info table where the lastname is equal to either: Hernandez, Jones, Roberts, or Ruiz. It will return the rows if it is ANY of these values.

The IN conditional operator can be rewritten by using compound conditions using the equals operator and combining it with OR - with exact same output results:

SELECT employeeid, lastname, salary
FROM employee_info
WHERE lastname = 'Hernandez' OR lastname = 'Jones' OR lastname = 'Roberts'
OR lastname = 'Ruiz';


As you can see, the IN operator is much shorter and easier to read when you are testing for more than two or three values.

You can also use NOT IN to exclude the rows in your list.

The BETWEEN conditional operator is used to test to see whether or not a value (stated before the keyword BETWEEN) is "between" the two values stated after the keyword BETWEEN.

For example:

SELECT employeeid, age, lastname, salary
FROM employee_info
WHERE age BETWEEN 30 AND 40;

This statement will select the employeeid, age, lastname, and salary from the employee_info table where the age is between 30 and 40 (including 30 and 40).

This statement can also be rewritten without the BETWEEN operator:

SELECT employeeid, age, lastname, salary
FROM employee_info
WHERE age >= 30 AND age <= 40;

You can also use NOT BETWEEN to exclude the values between your range.



Review Exercises (IN & BETWEEN)

1. Select the date, item, and price from the items_ordered table for all of the rows that have a price value ranging from 10.00 to 80.00.
2. Select the firstname, city, and state from the customers table for all of the rows where the state value is either: Arizona, Washington, Oklahoma, Colorado, or Hawaii.

1.
SELECT order_date, item, price
FROM items_ordered
WHERE price BETWEEN 10 AND 80;

2.
SELECT firstname, city, state
FROM customers
WHERE state IN ('Arizona', 'Washington', 'Oklahoma', 'Colorado', 'Hawaii');


Mathematical Functions

http://www.sqlcourse2.com/math.html

Standard ANSI SQL-92 supports the following first four basic arithmetic operators:

+	addition
-	subtraction
*	multiplication
/	division
%	modulo

The modulo operator determines the integer remainder of the division. This operator is not ANSI SQL supported, however, most databases support it. The following are some more useful mathematical functions to be aware of since you might need them. These functions are not standard in the ANSI SQL-92 specs, therefore they may or may not be available on the specific RDBMS that you are using. However, they were available on several major database systems that I tested. They WILL work on this tutorial.

ABS(x)	returns the absolute value of x
SIGN(x)	returns the sign of input x as -1, 0, or 1 (negative, zero, or positive respectively)
MOD(x,y)	modulo - returns the integer remainder of x divided by y (same as x%y)
FLOOR(x)	returns the largest integer value that is less than or equal to x
CEILING(x) or CEIL(x)	returns the smallest integer value that is greater than or equal to x
POWER(x,y)	returns the value of x raised to the power of y
ROUND(x)	returns the value of x rounded to the nearest whole integer
ROUND(x,d)	returns the value of x rounded to the number of decimal places specified by the value d
SQRT(x)	returns the square-root value of x

For example:

SELECT round(salary), firstname
FROM employee_info

This statement will select the salary rounded to the nearest whole value and the firstname from the employee_info table.

Review Exercises (Mathematical Functions)

1. Select the item and per unit price for each item in the items_ordered table. Hint: Divide the price by the quantity.

1.
SELECT item, price/quantity
FROM items_ordered;

2. Average price per item over all orders:
SELECT item, SUM(price) / SUM(quantity)
FROM items_ordered
GROUP BY item;



Table Joins, a must

http://www.sqlcourse2.com/joins.html

Review Exercises (Joins)

1. Write a query using a join to determine which items were ordered by each of the customers in the customers table. Select the customerid, firstname, lastname, order_date, item, and price for everything each customer purchased in the items_ordered table.
2. Repeat exercise #1, however display the results sorted by state in descending order.

1.
SELECT customers.customerid, customers.firstname, customers.lastname, items_ordered.order_date, items_ordered.item, items_ordered.price
FROM customers INNER JOIN items_ordered
ON customers.customerid = items_ordered.customerid;

2. --Note that you can order by state even though state isn't selected
SELECT customers.customerid, customers.firstname, customers.lastname, items_ordered.order_date, items_ordered.item, items_ordered.price
FROM customers INNER JOIN items_ordered
ON customers.customerid = items_ordered.customerid
ORDER BY customers.state DESC, customers.lastname;
