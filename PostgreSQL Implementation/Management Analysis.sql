/*
	1) How many managers are there currently in the company?
*/
SELECT 
	COUNT(mv_department_manager.employee_id) AS total_managers
FROM mv_employees.mv_department_manager
WHERE mv_department_manager.to_date = '9999-01-01';


/*
	2) How many employees have ever been a manager?
*/
SELECT 
	COUNT(mv_department_manager.employee_id) AS total_managers
FROM mv_employees.mv_department_manager;


/*
	3) On average - how long did it take for an employee 
	to first become a manager from their the date they were originally hired in days?
*/
WITH first_change_date AS (
SELECT 
	mv_title.employee_id,
	MIN(mv_title.from_date) AS appointed_on
FROM mv_employees.mv_title
WHERE mv_title.title = 'Manager'
GROUP BY mv_title.employee_id
)
SELECT
	ROUND(AVG((T1.appointed_on - T2.hire_date))) AS days_tenure
FROM first_change_date AS T1
INNER JOIN mv_employees.mv_employee AS T2
	ON T1.employee_id = T2.id;


/*
	4) What was the most common titles that managers had just before before they became a manager?
*/
SELECT 
	historic_employee_records.previous_title,
	COUNT(historic_employee_records.employee_id) AS employee_count
	FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.title = 'Manager'
	AND 
	historic_employee_records.previous_title != 'Manager' 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


/*
	5) How many managers were first hired by the company as a manager?
*/
SELECT 
	COUNT(*) AS initial_manager_count
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.title = 'Manager'
	AND 
	historic_employee_records.hire_date = historic_employee_records.effective_date;


/*
	6) On average - how much more do current managers make on average 
	compared to all other employees rounded to the nearest dollar?
*/
WITH mgr_cte AS (
SELECT 
	title_benchmark.title_benchmark_salary AS manager_salary
FROM mv_employees.title_benchmark
WHERE title_benchmark.title = 'Manager'
)
SELECT 
	ROUND(
		AVG(T2.manager_salary - T1.salary_amount)
	) AS average_difference
FROM 
	mv_employees.current_employee_snapshot AS T1,
	mgr_cte AS T2
WHERE T1.title != 'Manager';
	

/*
	7) Which current manager has the most employees in their department?
*/
SELECT 
	historic_employee_records.manager_full_name,
	SUM(CASE 
			WHEN historic_employee_records.title = 'Manager' 
			THEN 0
			ELSE 1
			END
		) AS employees_working
FROM mv_employees.historic_employee_records
WHERE historic_employee_records.expiry_date = '9999-01-01'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;



/*
	8) What is the difference in employee count between the 3rd and 4th 
	ranking departments by size?
*/
SELECT 
	dept_size_rank.employee_count -
	LEAD(dept_size_rank.employee_count)
		OVER (
			ORDER BY dept_size_rank.size_ranking
		) AS size_difference
FROM
(
SELECT 
	current_employee_snapshot.dept_name,
	COUNT(current_employee_snapshot.employee_id) AS employee_count,
	ROW_NUMBER()
		OVER (
			ORDER BY COUNT(current_employee_snapshot.employee_id) DESC
		) AS size_ranking
FROM mv_employees.current_employee_snapshot
GROUP BY 1
) AS dept_size_rank
WHERE 
	dept_size_rank.size_ranking 
	BETWEEN 3 AND 4 
LIMIT 1;