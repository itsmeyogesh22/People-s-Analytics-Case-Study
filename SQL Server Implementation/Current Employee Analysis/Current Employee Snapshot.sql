USE employees;

CREATE VIEW mv_employees.current_employee_snapshot
AS
WITH prev_year_Salary AS (
SELECT *
FROM
(
SELECT 
mv_salary.employee_id,
mv_salary.to_date,
LAG(mv_salary.amount) 
	OVER (
		PARTITION BY mv_salary.employee_id
		ORDER BY mv_salary.from_date ASC
	) AS previous_salary
FROM mv_employees.mv_salary
) AS all_salary
WHERE all_salary.to_date = '9999-01-01'
),
cte_joint_tables AS (
SELECT
--Table: "mv_employee"
mv_employee.id AS [employee_id],
mv_employee.gender,
mv_employee.hire_date,
mv_title.title,
mv_salary.amount AS [salary_amount],
prev_year_Salary.previous_salary,
mv_department.dept_name,
mv_title.from_date AS [title_from_date],
mv_department_employee.from_date AS [dept_from_date]
FROM mv_employees.mv_employee
INNER JOIN mv_employees.mv_title
	ON mv_employee.id = mv_title.employee_id
INNER JOIN mv_employees.mv_salary
	ON mv_employee.id = mv_salary.employee_id
INNER JOIN prev_year_Salary
	ON mv_employee.id = prev_year_Salary.employee_id
INNER JOIN mv_employees.mv_department_employee
	ON mv_employee.id = mv_department_employee.employee_id
INNER JOIN mv_employees.mv_department
	ON mv_department_employee.department_id = mv_department.id
WHERE 
	mv_salary.to_date = '9999-01-01'
	AND
	mv_title.to_date = '9999-01-01'
	AND
	mv_department_employee.to_date = '9999-01-01'
),
cte_final_output AS (
SELECT
employee_id,
gender,
title,
salary_amount,
dept_name,
-- salary change percentage
CAST(
	100*(salary_amount - previous_salary)/CAST(previous_salary AS FLOAT)
	AS DECIMAL(5, 2))   AS salary_percentage_change,
-- tenure calculations
DATEDIFF(YEAR, hire_date, GETDATE()) AS company_tenure_years,
DATEDIFF(YEAR, title_from_date, GETDATE()) AS title_tenure_years,
DATEDIFF(YEAR, dept_from_date, GETDATE()) AS department_tenure_years
FROM cte_joint_tables
)
SELECT *
FROM cte_final_output
GO;