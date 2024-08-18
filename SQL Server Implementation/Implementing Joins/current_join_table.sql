USE employees;

DROP TABLE IF EXISTS #current_join_table;
CREATE TABLE #current_join_table
	(
	 employee_id BIGINT,
	 birth_date DATE,
	 first_name VARCHAR(50),
	 last_name VARCHAR(50),
	 gender CHAR(10),
	 hire_date DATE,
	 title VARCHAR(50),
	 title_from_date DATE,
	 title_to_date DATE,
	 salary_amount BIGINT,
	 salary_from_date DATE,
	 salary_to_date DATE,
	 dept_name VARCHAR(50),
	 dept_from_date DATE,
	 dept_to_date DATE
	)
INSERT INTO #current_join_table 
	(
	 employee_id,
	 birth_date,
	 first_name,
	 last_name,
	 gender,
	 hire_date,
	 title,
	 title_from_date,
	 title_to_date,
	 salary_amount,
	 salary_from_date,
	 salary_to_date,
	 dept_name,
	 dept_from_date,
	 dept_to_date
	)
SELECT
--Table: "mv_employee"
mv_employee.id AS [employee_id],
mv_employee.birth_date,
mv_employee.first_name,
mv_employee.last_name,
mv_employee.gender,
mv_employee.hire_date,
--Table: "mv_title"
mv_title.title,
mv_title.from_date AS [title_from_date],
mv_title.to_date AS [title_to_date],
--Table: "mv_salary"
mv_salary.amount AS [salary_amount],
mv_salary.from_date AS [salary_from_date],
mv_salary.to_date AS [salary_to_date],
--Table: "mv_department_employee" and "mv_department"
mv_department.dept_name,
mv_department_employee.from_date AS [dept_from_date],
mv_department_employee.to_date AS [dept_to_date]
FROM mv_employees.mv_employee
INNER JOIN mv_employees.mv_title
	ON mv_employee.id = mv_title.employee_id
INNER JOIN mv_employees.mv_salary
	ON mv_employee.id = mv_salary.employee_id
INNER JOIN mv_employees.mv_department_employee
	ON mv_employee.id = mv_department_employee.employee_id
INNER JOIN mv_employees.mv_department
	ON mv_department_employee.department_id = mv_department.id
WHERE 
	mv_salary.to_date = '9999-01-01'
	AND
	mv_title.to_date = '9999-01-01'
	AND
	mv_department_employee.to_date = '9999-01-01';

SELECT COUNT(*) AS [total_records] FROM #current_join_table;