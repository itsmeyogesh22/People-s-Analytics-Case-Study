CREATE DATABASE employees;
USE employees;

DROP SCHEMA IF EXISTS mv_employees
GO
--CREATE SCHEMA mv_employees;
--GO

--Table: "department"
CREATE TABLE mv_employees.mv_department(id VARCHAR(50), dept_name VARCHAR(50))
INSERT INTO mv_employees.mv_department(id, dept_name)
SELECT *
FROM department;


--Table: "title"
CREATE TABLE mv_employees.mv_title(employee_id BIGINT, 
								   title VARCHAR(50), 
								   from_date DATE, 
								   to_date DATE
								   )
INSERT INTO mv_employees.mv_title(employee_id, 
								   title, 
								   from_date, 
								   to_date
								   )
SELECT 
employee_id,
title,
DATEADD(YEAR, 18, from_date) AS [from_date],
CASE
	WHEN to_date <> '9999-01-01' THEN DATEADD(YEAR, 18, to_date)
	ELSE to_date 
	END AS [to_date]
FROM title;


CREATE TABLE mv_employees.mv_salary(employee_id BIGINT, 
								   amount BIGINT, 
								   from_date DATE, 
								   to_date DATE
								   )
INSERT INTO mv_employees.mv_salary(employee_id, 
								   amount, 
								   from_date, 
								   to_date
								   )
SELECT 
employee_id,
amount,
DATEADD(YEAR, 18, from_date) AS [from_date],
CASE
	WHEN to_date <> '9999-01-01' THEN DATEADD(YEAR, 18, to_date)
	ELSE to_date 
	END AS [to_date]
FROM salary;


--Table: "department_employee"
CREATE TABLE mv_employees.mv_department_employee
	(employee_id BIGINT, 
	 department_id VARCHAR(50), 
	 from_date DATE, 
	 to_date DATE
	 )
INSERT INTO mv_employees.mv_department_employee
	(employee_id, 
	department_id, 
	from_date, 
	to_date
	)
SELECT 
employee_id,
department_id,
DATEADD(YEAR, 18, from_date) AS [from_date],
CASE
	WHEN to_date <> '9999-01-01' THEN DATEADD(YEAR, 18, to_date)
	ELSE to_date 
	END AS [to_date]
FROM department_employee;


--Table: "department_manager"
CREATE TABLE mv_employees.mv_department_manager
	(employee_id BIGINT, 
	 department_id VARCHAR(50), 
	 from_date DATE, 
	 to_date DATE
	 )
INSERT INTO mv_employees.mv_department_manager
	(employee_id, 
	department_id, 
	from_date, 
	to_date
	)
SELECT 
employee_id,
department_id,
DATEADD(YEAR, 18, from_date) AS [from_date],
CASE
	WHEN to_date <> '9999-01-01' THEN DATEADD(YEAR, 18, to_date)
	ELSE to_date 
	END AS [to_date]
FROM department_manager;


CREATE TABLE mv_employees.mv_employee 
	(
	 id BIGINT,
	 birth_date DATE,
	 first_name VARCHAR(50),
	 last_name VARCHAR(50),
	 gender CHAR(10),
	 hire_date DATE
	)
INSERT INTO mv_employees.mv_employee
	(
	 id,
	 birth_date,
	 first_name,
	 last_name,
	 gender,
	 hire_date
	)
SELECT 
id,
DATEADD(YEAR, 18, birth_date) AS [birth_date],
first_name,
last_name,
gender,
DATEADD(YEAR, 18, hire_date) AS [hire_date]
FROM employee;




SELECT *
FROM mv_employees.mv_title
WHERE mv_title.employee_id = 10001;

CREATE UNIQUE INDEX index1 ON mv_employees.mv_employee (id);
CREATE UNIQUE INDEX index2 ON mv_employees.mv_department_employee (department_id, employee_id);
CREATE UNIQUE INDEX index3 ON mv_employees.mv_department (id);
CREATE UNIQUE INDEX index4 ON mv_employees.mv_department (dept_name);
CREATE UNIQUE INDEX index5 ON mv_employees.mv_department_manager (employee_id, department_id);
CREATE UNIQUE INDEX index6 ON mv_employees.mv_salary (employee_id, from_date);
CREATE UNIQUE INDEX index7 ON mv_employees.mv_title (employee_id, title, from_date);