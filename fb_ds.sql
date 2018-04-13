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
