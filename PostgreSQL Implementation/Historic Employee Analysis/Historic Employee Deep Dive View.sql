DROP VIEW IF EXISTS mv_employees.historic_employee_records CASCADE;
CREATE VIEW mv_employees.historic_employee_records AS
WITH previous_salary_cte AS (
SELECT
	all_salaries_v1.employee_id,
	all_salaries_v1.salary_amount
FROM 
(
SELECT 
	mv_salary.employee_id,
	mv_salary.to_date,
	LAG(mv_salary.amount) 
		OVER (
			PARTITION BY mv_salary.employee_id
			ORDER BY mv_salary.from_date ASC
		) AS salary_amount,
	ROW_NUMBER() 
		OVER (
			PARTITION BY mv_salary.employee_id
			ORDER BY mv_salary.to_date DESC
		) AS record_rank
FROM mv_employees.mv_salary
) AS all_salaries_v1
WHERE all_salaries_v1.record_rank = 1
),
cte_joint_data AS (
SELECT 
	mv_employee.id AS employee_id,
	mv_employee.birth_date,
	DATE_PART('year', NOW()) - DATE_PART('year', mv_employee.birth_date) AS employee_age, 
	CONCAT_WS(
			' ',
			mv_employee.first_name, 
			mv_employee.last_name) AS employee_full_name,
	mv_employee.gender,
	mv_employee.hire_date,
	mv_title.title,
	mv_salary.amount AS salary_amount,
	previous_salary_cte.salary_amount AS previous_latest_salary,
	mv_department.dept_name,
	CONCAT_WS(
			' ',
			MGR.first_name, 
			MGR.last_name) AS manager_full_name,
	DATE_PART('year', NOW()) - DATE_PART('year', mv_employee.hire_date) AS company_tenure, 
	DATE_PART('year', NOW()) - DATE_PART('year', mv_title.from_date) AS title_tenure_years,
	DATE_PART('year', NOW()) - DATE_PART('year', mv_department_employee.from_date) AS department_tenure,
	DATE_PART('months', AGE(NOW(), mv_title.from_date)) AS title_tenure_months,
	GREATEST(
			 mv_title.from_date, 
			 mv_salary.from_date, 
			 mv_department_employee.from_date, 
			 mv_department_manager.from_date
	) AS effective_date,
	LEAST(
		  mv_title.to_date, 
		  mv_salary.to_date, 
		  mv_department_employee.to_date, 
		  mv_department_manager.to_date
	) AS expiry_date
FROM mv_employees.mv_employee
INNER JOIN mv_employees.mv_title
	ON mv_employee.id = mv_title.employee_id
INNER JOIN mv_employees.mv_salary
	on mv_employee.id = mv_salary.employee_id
INNER JOIN mv_employees.mv_department_employee
	ON mv_employee.id = mv_department_employee.employee_id
INNER JOIN mv_employees.mv_department
	ON mv_department_employee.department_id = mv_department.id
INNER JOIN mv_employees.mv_department_manager
	ON mv_department.id = mv_department_manager.department_id
INNER JOIN mv_employees.mv_employee AS MGR
	ON mv_department_manager.employee_id = MGR.id
INNER JOIN previous_salary_cte
	ON mv_employee.id = previous_salary_cte.employee_id
),
cte_ordered_transactions AS (
SELECT 
	employee_id,
    birth_date,
    employee_age,
    employee_full_name,
    gender,
    hire_date,
    title,
    LAG(title) OVER w AS previous_title,
    salary_amount,
    previous_latest_salary,
    LAG(salary_amount) OVER w AS previous_salary,
    dept_name,
    LAG(dept_name) OVER w AS previous_department,
    manager_full_name,
    LAG(manager_full_name) OVER w AS previous_manager,
    company_tenure,
    title_tenure_years,
    title_tenure_months,
    department_tenure,
    effective_date,
    expiry_date,
	ROW_NUMBER() 
		OVER (
			PARTITION BY employee_id
			ORDER BY effective_date DESC
		) AS event_order
FROM cte_joint_data
WHERE effective_date <= expiry_date
WINDOW 
		w AS (PARTITION BY employee_id ORDER BY effective_date ASC)
),
final_output_cte AS (
SELECT 
	BASE.employee_id,
    BASE.gender,
    BASE.birth_date,
    BASE.employee_age,
    BASE.hire_date,
    BASE.title,
    BASE.employee_full_name, 
    BASE.previous_title,
    BASE.salary_amount,
	BASE.previous_latest_salary,
	BASE.previous_salary,
	BASE.dept_name,
	BASE.previous_department,
	BASE.manager_full_name,
	BASE.previous_manager,
	BASE.company_tenure,
	BASE.title_tenure_years,
	BASE.title_tenure_months,
	BASE.department_tenure,
	BASE.event_order,
	(CASE 
		WHEN BASE.event_order = 1 
		THEN ROUND(100*(BASE.salary_amount - BASE.previous_latest_salary)/
		BASE.previous_latest_salary::NUMERIC, 2)
		ELSE NULL
	END) AS latest_salary_percentage_change,
	(CASE 
		WHEN BASE.event_order = 1 
		THEN (BASE.salary_amount - BASE.previous_latest_salary)
		ELSE NULL
	END) AS latest_salary_amount_change,
	(CASE 
		WHEN BASE.previous_salary > BASE.salary_amount
		THEN 'Salary Reduction'
		WHEN BASE.salary_amount > BASE.previous_salary
		THEN 'Salary Increment'
		WHEN BASE.dept_name <> BASE.previous_department
		THEN 'Department Transfer'
		WHEN BASE.manager_full_name <> BASE.previous_manager
		THEN 'Reporting Line Change'
		WHEN BASE.title <> BASE.previous_title
		THEN 'Title Changes'
		ELSE NULL
	END)  AS event_name,
	ROUND(BASE.salary_amount - BASE.previous_salary) AS salary_amount_change,
	ROUND(
		100*(BASE.salary_amount - BASE.previous_salary)/
		BASE.previous_salary::NUMERIC, 
	2) AS salary_percentage_change,
	ROUND(tenure_benchmark.tenure_benchmark_salary) AS tenure_benchmark_salary,
	ROUND(
		100*(BASE.salary_amount - tenure_benchmark.tenure_benchmark_salary)/
		tenure_benchmark.tenure_benchmark_salary::NUMERIC
	) AS tenure_comparison,
	ROUND(title_benchmark.title_benchmark_salary) AS title_benchmark_salary,
	ROUND(
		100*(BASE.salary_amount - title_benchmark.title_benchmark_salary)/
		title_benchmark.title_benchmark_salary::NUMERIC
	) AS title_comparison,
	ROUND(department_benchmark.department_benchmark_salary) AS department_benchmark_salary,
	ROUND(
		100*(BASE.salary_amount - department_benchmark.department_benchmark_salary)/
		department_benchmark.department_benchmark_salary::NUMERIC
	) AS department_comparison,
	ROUND(gender_benchmark.gender_benchmark_salary) AS gender_benchmark_salary,
	ROUND(
		100*(BASE.salary_amount - gender_benchmark.gender_benchmark_salary)/
		gender_benchmark.gender_benchmark_salary::NUMERIC
	) AS gender_comparison,
	BASE.effective_date,
	BASE.expiry_date
FROM cte_ordered_transactions AS BASE
INNER JOIN mv_employees.tenure_benchmark
	ON BASE.company_tenure = tenure_benchmark.company_tenure
INNER JOIN mv_employees.title_benchmark
	ON BASE.title = title_benchmark.title
INNER JOIN mv_employees.department_benchmark
	ON BASE.dept_name = department_benchmark.dept_name
INNER JOIN mv_employees.gender_benchmark
	ON BASE.gender = gender_benchmark.gender
)
SELECT *
FROM final_output_cte;




--employee deep dive tool
DROP VIEW IF EXISTS mv_employees.employee_deep_dive;
CREATE VIEW mv_employees.employee_deep_dive AS
SELECT *
FROM mv_employees.historic_employee_records
WHERE event_order <= 5;
