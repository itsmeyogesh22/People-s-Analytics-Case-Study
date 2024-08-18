DROP DATABASE IF EXISTS employees;
CREATE DATABASE employees;
USE employees;



--Overview of each table
--Table: "employee"
SELECT TOP 5
id,
hire_date,
DATEADD(YEAR, 18, hire_date) AS [adjusted_hire_date]
FROM employee
WHERE hire_date <> '9999-01-01';


--Table: "title"
SELECT TOP 5 
*
FROM title
WHERE employee_id = 10005;


--Table: "salary"
SELECT TOP 5 *,
DATEADD(YEAR, 18, to_date) AS [adjusted_to_date]
FROM salary
WHERE to_date <> '9999-01-01'
ORDER BY from_date ASC;


--Table: "department_employee"
SELECT TOP 5 *,
DATEADD(YEAR, 18, to_date) AS [adjusted_to_Date]
FROM department_employee
WHERE to_date <> '9999-01-01'
ORDER BY from_date ASC;


--Table: "department"
SELECT *
FROM department;


--Table: "department_manager"
SELECT TOP 5 *,
DATEADD(YEAR, 18, to_date) AS [adjusted_to_date]
FROM department_manager
WHERE to_date <> '9999-01-01'
ORDER BY from_date ASC;


