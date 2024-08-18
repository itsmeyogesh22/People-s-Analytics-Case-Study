/*
	1) What is the full name of the employee with the highest salary?
*/
SELECT 
	V1.employee_id,
	V1.salary_amount,
	CONCAT(EMP.first_name, ' ', EMP.last_name) AS employee_full_name
FROM 
(
SELECT 
	current_employee_snapshot.employee_id,
	current_employee_snapshot.salary_amount
FROM mv_employees.current_employee_snapshot
ORDER BY current_employee_snapshot.salary_amount DESC
LIMIT 1) AS V1
INNER JOIN mv_employees.mv_employee AS EMP
	ON V1.employee_id = EMP.id;


/*
	2) How many current employees have the equal longest time in their current positions?
*/
WITH title_tenure_cte AS (
SELECT 
	current_employee_snapshot.employee_id,
	current_employee_snapshot.title,
	current_employee_snapshot.title_tenure
FROM mv_employees.current_employee_snapshot
ORDER BY 3 DESC
)
SELECT 
	title_tenure_cte.title_tenure,
	COUNT(*) AS total_employees
FROM title_tenure_cte
GROUP BY title_tenure_cte.title_tenure
ORDER BY 1 DESC
LIMIT 1;


/*
	3) Which department has the highest number of current employees?
*/
SELECT 
	current_employee_snapshot.dept_name,
	COUNT(*) AS total_employees
FROM mv_employees.current_employee_snapshot
GROUP BY current_employee_snapshot.dept_name
ORDER BY 2 DESC
LIMIT 1;


/*
	4) What is the largest difference between minimimum and maximum salary values for all current employees?
*/
--Method-1: Lengthy Approach
WITH high_low_salary AS (
SELECT 
	MAX(current_employee_snapshot.salary_amount) AS maximum_amount_abserved,
	MIN(current_employee_snapshot.salary_amount) AS lowest_amount_observed
FROM mv_employees.current_employee_snapshot
)
SELECT 
	MAX(difference_recorded) AS maximum_difference_obsereved
FROM  
(
SELECT 
	current_employee_snapshot.employee_id,
	current_employee_snapshot.salary_amount,
	(high_low_salary.maximum_amount_abserved-current_employee_snapshot.salary_amount)-
	(current_employee_snapshot.salary_amount-high_low_salary.lowest_amount_observed) AS difference_recorded
FROM 
	mv_employees.current_employee_snapshot,
	high_low_salary
) AS salary_metric_4;

--Method-2: Short Approach
SELECT 
	MAX(current_employee_snapshot.salary_amount) -
	MIN(current_employee_snapshot.salary_amount)
FROM mv_employees.current_employee_snapshot;


/*
	5) How many male employees are above the overall average salary value for the `Production` department?
	Hint: You might want to use a window function in a CTE first before using a SUM CASE WHEN
*/
WITH salary_averages AS (
SELECT 
	current_employee_snapshot.employee_id,
	current_employee_snapshot.gender,
	current_employee_snapshot.salary_amount AS current_salary_amount,
	current_employee_snapshot.dept_name,
	AVG(current_employee_snapshot.salary_amount)
		OVER () AS overall_average_salary
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.dept_name = 'Production'
)
SELECT 
	SUM(
	CASE 
		WHEN salary_averages.current_salary_amount > salary_averages.overall_average_salary
		THEN 1 
	ELSE 0
	END 
	) AS total_male_employees
FROM salary_averages
WHERE salary_averages.gender = 'M';


/*
	6) Which title has the highest average salary for male employees?
*/
SELECT 
	current_employee_snapshot.title,
	ROUND(
		AVG(current_employee_snapshot.salary_amount), 
	2) AS average_amount
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
GROUP BY 
	current_employee_snapshot.title
ORDER BY 2 DESC
LIMIT 1;


/*
	7. Which department has the highest average salary for female employees?
*/
SELECT 
	current_employee_snapshot.dept_name,
	ROUND(
		AVG(current_employee_snapshot.salary_amount), 
	2) AS average_amount
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
GROUP BY 
	current_employee_snapshot.dept_name
ORDER BY 2 DESC
LIMIT 1;


/*
	8) Which department has the most female employees?
*/
SELECT 
	current_employee_snapshot.dept_name,
	COUNT(*) AS total_female_workers
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
GROUP BY 
	current_employee_snapshot.dept_name
ORDER BY 2 DESC
LIMIT 1;

/*
	9) What is the gender ratio in the department which has the 
	highest average male salary and what is the average male salary 
	value rounded to the nearest integer?
*/
WITH highest_male_salary AS (
SELECT 
	current_employee_snapshot.dept_name,
	ROUND(
		AVG(current_employee_snapshot.salary_amount)) AS average_amount
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
GROUP BY 
	current_employee_snapshot.dept_name
ORDER BY 2 DESC
LIMIT 1
)
SELECT 
	SUM(
	CASE WHEN T1.gender = 'F' THEN 1 ELSE 0 END
	) AS female_employees,
	SUM(
	CASE WHEN T1.gender = 'M' THEN 1 ELSE 0 END
	) AS male_employees,
	T2.average_amount
FROM mv_employees.current_employee_snapshot AS T1
INNER JOIN highest_male_salary AS T2 
	ON T1.dept_name = T2.dept_name
GROUP BY T2.average_amount;


/*
	10) HR Analytica want to change the average salary increase percentage 
	value to 2 decimal places - what should the new value be for males for the 
	company level dashboard?
*/
SELECT 
	CONCAT(
	ROUND(
	AVG(current_employee_snapshot.salary_percentage_change),
	2), '', '%') AS salary_percentage_change_adjusted
FROM mv_employees.current_employee_snapshot;


/*
	11) How many current employees have the equal longest overall time in their 
	current positions (not in years)?
	Hint: You may want to recalculate the tenure value directly from the 
	`mv_employees.department_employee` table!
*/
SELECT   
	CURRENT_DATE - mv_department_employee.from_date AS tenure_interval,
	COUNT(DISTINCT mv_department_employee.employee_id) AS employee_count
FROM mv_employees.mv_department_employee
WHERE mv_department_employee.to_date = '9999-01-01'::DATE
GROUP BY DISTINCT mv_department_employee.from_date
ORDER BY 1 DESC
LIMIT 10;