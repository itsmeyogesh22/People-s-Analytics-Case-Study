DROP TABLE IF EXISTS naive_join_table;
CREATE TEMP TABLE naive_join_table AS
SELECT 
	--Table: mv_employee
	mv_employee.id,
	mv_employee.birth_date,
	mv_employee.first_name,
	mv_employee.last_name,
	mv_employee.gender,
	mv_employee.hire_date,
	--Table: mv_title
	mv_title.title,
	mv_title.from_date AS title_from_date,
	mv_title.to_date AS title_to_date,
	--Table: mv_salary
	mv_salary.amount AS salary_amount,
	mv_salary.from_date AS salary_from_date,
	mv_salary.to_date AS salary_to_date,
	--Table: mv_department_employee
	mv_department_employee.department_id,
	mv_department.dept_name,
	mv_department_employee.from_date AS dept_from_date,
	mv_department_employee.to_date AS dept_to_date
FROM mv_employees.mv_employee
INNER JOIN mv_employees.mv_salary 
	ON mv_employee.id = mv_salary.employee_id
INNER JOIN mv_employees.mv_department_employee
	ON mv_employee.id = mv_department_employee.employee_id
INNER JOIN mv_employees.mv_title
	ON mv_employee.id = mv_title.employee_id
INNER JOIN mv_employees.mv_department
	ON mv_department_employee.department_id = mv_department.id;


--Inspecting Individuals
--Georgi Facello
SELECT *
FROM naive_join_table
WHERE id = 10001
ORDER BY salary_to_date DESC;

--Leah Anguita
SELECT *
FROM naive_join_table
WHERE id = 11669
ORDER BY salary_to_date DESC;