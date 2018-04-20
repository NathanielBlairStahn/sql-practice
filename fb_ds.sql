-- Suppose you have two tables: 
--
-- Event-level data: an attendance log for every student in a school district 
--
-- attendance_log:
-- date | student_id | attendance
--
-- Dimension-level data: a summary table with demographics for each student in the district 
--
-- students:
-- student_id | school_id | grade_level | date_of_birth | hometown 
--
-- Using this data, you could answer questions like the following: 
--  What was the overall attendance rate for the school district yesterday? 
--  Which grade level currently has the most students in this school district? 
--  Which school had the highest attendance rate? The lowest? 
--
-- You will be expected to write code that would answer the data processing questions given based on a
-- schema or set of schemas that will be provided to you. Whether you choose SQL, Python, or R, please
-- follow standard coding style and best practices for easy readability. 
--
-- If using SQL, you can expect to be assessed on some subset of the following: 
--  Write a query or set of queries to derive insights based on the given log(s) or schema(s) 
--  Work with aggregate functions 
--  Utilize different types of Joins (IE: Left, Inner, Outer, etc.)  
--
--  Utilize Union and Union All.  
--  Work with concepts including Distinct, Random Sampling, De-Duplication, Optimization. 
--  Apply the results of your analysis to make product decisions or suggestions.

-- 1. What was the overall attendance rate for the school district yesterday?
-- Assume attendance = 1 if the student attended and attendance = 0 if not.

SELECT AVG(attendance) AS attendance_rate
FROM attendance_log
WHERE attendance_log.date = DATE_SUB(CURRENT_DATE, INTERVAL 1 day)

-- or assume attendance = 'Y' or 'N'

SELECT  SUM(CASE WHEN attendance='Y' THEN 1 ELSE 0 END) / COUNT(student_id)
FROM attendance_log
WHERE attendance_log.date = DATE_SUB(CURRENT_DATE, INTERVAL 1 day)

-- 2. Which grade level currently has the most students in this school district?

SELECT grade_level, COUNT(student_id) AS num_students
FROM students
GROUP BY grade_level
ORDER BY num_students DESC
LIMIT 1

-- 3. Which school had the highest attendance rate? The lowest?

-- Highest attendance:
SELECT students.school_id, AVG(attendance_log.attendance) AS attendance_rate
FROM students
JOIN attendance_log
ON students.student_id = attendance_log.student_id
GROUP BY students.school_id
ORDER BY attendance_rate DESC
LIMIT 1

-- Lowest attendance:
SELECT students.school_id, AVG(attendance_log.attendance) AS attendance_rate
FROM students
JOIN attendance_log
ON students.student_id = attendance_log.student_id
GROUP BY students.school_id
ORDER BY attendance_rate ASC
LIMIT 1

-- More Sample Questions:

-- - Given timestamps of logins, figure out how many people on Facebook
--   were active all seven days of a week on a mobile phone.

-- logins: timestamp, userid, device

-- SELECT userid, COUNT(DATE(logins.timestamp)) AS num_days
SELECT COUNT(*) -- or COUNT(userid)
FROM logins
WHERE DATE(logins.timestamp) BETWEEN '2018-04-07' AND '2018-04-13'
AND device = 'mobile'
GROUP BY userid
HAVING COUNT(DATE(logins.timestamp)) = 7

-- This should count the number of users active on ANY day during the week
SELECT COUNT(*) -- or COUNT(userid)
FROM logins
WHERE DATE(logins.timestamp) BETWEEN '2018-04-07' AND '2018-04-13'
AND device = 'mobile'
GROUP BY userid

-- - How do you determine what product in Facebook was used most by the
--   non-employee users for the last quarter? [Required parameters will be given]

-- users: userid, name, is_employee
-- products: productid, name
-- use_log: productid, userid, time_start, time_stop

-- This finds the product id that had the most 'initiations' of use
-- by non-employee users in the 1st quarter of 2018:
SELECT l.productid, COUNT(l.time_start)
FROM users AS u
JOIN use_log AS l
ON users.userid = use_log.userid
WHERE u.is_employee = 'False'
DATE(l.time_start) BETWEEN '2018-01-01' AND '2018-03-31'
GROUP BY l.productid
ORDER BY COUNT(l.time_start)
LIMIT 1

-- A different interpretation would be the product with the most
-- total time in use, which would require subtracting start times
-- from stop times, and adding up all the differences...
SELECT l.productid, SUM(l.time_stop - l.time_start)
FROM users AS u
JOIN use_log AS l
ON users.userid = use_log.userid
WHERE u.is_employee = 'False'
DATE(l.time_start) >= '2018-01-01'
AND DATE(l.time_stop) <= '2018-03-31'
GROUP BY l.productid
ORDER BY SUM(l.time_stop - l.time_start)
LIMIT 1


------------------------------------------------------------
Table: confirmation
------------------------------------------------------------
column  example values
ds    2018-02-01
country  us, uk
carrier    verizon, sprint
phone    650-100-8000
type    confirmation, pw_recovery
------------------------------------------------------------

Question 1: Number of phone numbers we sent confirmation SMSs to yesterday for each carrier, country

SELECT carrier, country, COUNT(DISTINCT phone)
FROM confirmation
WHERE type = 'confirmation'
AND ds = '2018-04-15'
GROUP BY carrier, country

------------------------------------------------------------
Table: confirmers
------------------------------------------------------------
column  example values
date    2018-02-01
contact   rocky@gmail.com, 650-100-8000
------------------------------------------------------------

Question 2: Find the 5 carriers with lowest confirmation rate last week

SELECT confirmation.carrier, COUNT(DISTINCT confirmers.contact) / COUNT(DISTINCT confirmation.phone) AS conf_rate
FROM confirmation
LEFT JOIN confirmers
ON confirmation.phone = confirmers.contact
WHERE
GROUP BY confirmation.carrier


HAVING COUNT(confirmers.contact) / COUNT(confirmation.phone)
