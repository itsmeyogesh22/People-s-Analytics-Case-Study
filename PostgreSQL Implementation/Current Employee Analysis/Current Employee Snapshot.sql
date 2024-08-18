DROP VIEW IF EXISTS mv_employees.current_employee_snapshot CASCADE;
CREATE VIEW mv_employees.current_employee_snapshot AS
WITH prev_year_salary AS (
SELECT *
FROM
(
SELECT 
	mv_salary.employee_id,
	mv_salary.to_date,
	LAG(mv_salary.amount) 
		OVER (
			PARTITION BY mv_salary.employee_id
			ORDER BY mv_salary.from_date
		) AS last_year_salary
FROM mv_employees.mv_salary
) AS V1
WHERE V1.to_date = '9999-01-01'
),
cte_joint_tables AS (
SELECT 
	--Table: mv_employee
	mv_employee.id AS employee_id,
	mv_employee.gender,
	mv_employee.hire_date,
	--Table: mv_title
	mv_title.title,
	mv_title.from_date AS title_from_date,
	--Table: mv_salary
	mv_salary.amount AS salary_amount,
	prev_year_salary.last_year_salary AS previous_year_salary,
	--Table: mv_department_employee
	mv_department_employee.department_id,
	mv_department.dept_name,
	mv_department_employee.from_date AS dept_from_date
FROM mv_employees.mv_employee
INNER JOIN mv_employees.mv_salary 
	ON mv_employee.id = mv_salary.employee_id
INNER JOIN prev_year_salary
	ON mv_employee.id = prev_year_salary.employee_id
INNER JOIN mv_employees.mv_department_employee
	ON mv_employee.id = mv_department_employee.employee_id
INNER JOIN mv_employees.mv_title
	ON mv_employee.id = mv_title.employee_id
INNER JOIN mv_employees.mv_department
	ON mv_department_employee.department_id = mv_department.id
WHERE 
	mv_title.to_date = '9999-01-01'
	AND
	mv_salary.to_date = '9999-01-01'
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
	ROUND(
	100*(salary_amount - previous_year_salary)/previous_year_salary::NUMERIC,
	2) AS salary_percentage_change, 
	(DATE_PART('YEAR', NOW()) - DATE_PART('YEAR', hire_date)) AS company_tenure,
	(DATE_PART('YEAR', NOW()) - DATE_PART('YEAR', title_from_date)) AS title_tenure,
	(DATE_PART('YEAR', NOW()) - DATE_PART('YEAR', dept_from_date)) AS department_tenure
FROM cte_joint_tables
)
SELECT * FROM cte_final_output;


SELECT * 
FROM mv_employees.current_employee_snapshot
LIMIT 5;