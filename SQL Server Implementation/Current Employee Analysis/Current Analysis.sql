USE employees;

/*
	1) What is the full name of the employee with the highest salary?
*/
SELECT TOP 1
current_employee_snapshot.employee_id,
CONCAT_WS(
		  mv_employee.first_name, 
		  mv_employee.last_name, 
		  ' ') AS full_name,
current_employee_snapshot.salary_amount
FROM mv_employees.current_employee_snapshot
INNER JOIN mv_employees.mv_employee
	ON current_employee_snapshot.employee_id = mv_employee.id
ORDER BY current_employee_snapshot.salary_amount DESC;


/*
	2) How many current employees have the equal longest tenure years in their current title?
*/
SELECT TOP 1
current_employee_snapshot.title_tenure_years,
COUNT(current_employee_snapshot.employee_id) AS total_employees
FROM mv_employees.current_employee_snapshot
GROUP BY current_employee_snapshot.title_tenure_years
ORDER BY 1 DESC;


/*
	3) Which department has the highest number of current employees?
*/
SELECT TOP 1
current_employee_snapshot.dept_name,
COUNT(current_employee_snapshot.employee_id) AS total_employees
FROM mv_employees.current_employee_snapshot
GROUP BY current_employee_snapshot.dept_name
ORDER BY 2 DESC;


/*
	4) What is the largest difference between minimimum and maximum salary values for all current employees?
*/
SELECT 
MAX(current_employee_snapshot.salary_amount) -
MIN(current_employee_snapshot.salary_amount) AS amount_difference
FROM mv_employees.current_employee_snapshot;


/*
	5) How many male employees are above the overall average salary value for the `Production` department?
	Hint: You might want to use a window function in a CTE first before using a SUM CASE WHEN
*/
WITH avg_cte AS (
SELECT employee_id,
current_employee_snapshot.dept_name,
AVG(current_employee_snapshot.salary_amount) 
	OVER () AS overall_average_amount
FROM mv_employees.current_employee_snapshot
WHERE
	current_employee_snapshot.dept_name = 'Production'
)
SELECT 
current_employee_snapshot.employee_id,
SUM(
CASE 
	WHEN current_employee_snapshot.salary_amount > avg_cte.overall_average_amount
	THEN 1
	ELSE 0
	END
	) AS total_male_employees
FROM 
	mv_employees.current_employee_snapshot,
	avg_cte
WHERE 
	current_employee_snapshot.gender = 'M'
GROUP BY current_employee_snapshot.employee_id;


/*
	6) Which title has the highest average salary for male employees?
*/
SELECT TOP 1
current_employee_snapshot.title,
AVG(current_employee_snapshot.salary_amount) AS average_salary
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
GROUP BY current_employee_snapshot.title
ORDER BY 2 DESC;



/*
	7) Which department has the highest average salary for female employees?
*/
SELECT TOP 1
current_employee_snapshot.dept_name,
AVG(current_employee_snapshot.salary_amount) AS average_salary
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
GROUP BY current_employee_snapshot.dept_name
ORDER BY 2 DESC;


/*
	8) Which department has the most female employees?
*/
SELECT TOP 1
current_employee_snapshot.dept_name,
COUNT(current_employee_snapshot.employee_id) AS total_female_employees
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
GROUP BY current_employee_snapshot.dept_name
ORDER BY 2 ASC;



/*
	9) What is the gender ratio in the department which has the highest average 
	male salary and what is the average male salary value rounded to the nearest integer?
*/
WITH male_avg_pay AS (
SELECT 
current_employee_snapshot.dept_name,
AVG(current_employee_snapshot.salary_amount) AS average_amount
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
GROUP BY current_employee_snapshot.dept_name
)
SELECT TOP 1
SUM(CASE WHEN current_employee_snapshot.gender = 'F' THEN 1 ELSE 0 END) AS female_employees, 
SUM(CASE WHEN current_employee_snapshot.gender = 'M' THEN 1 ELSE 0 END) AS male_employees,
male_avg_pay.average_amount AS [average_male_employee_salary],
male_avg_pay.dept_name
FROM mv_employees.current_employee_snapshot
INNER JOIN male_avg_pay 
	ON current_employee_snapshot.dept_name = male_avg_pay.dept_name
GROUP BY male_avg_pay.average_amount, male_avg_pay.dept_name
ORDER BY 3 DESC;


/*
	10) HR Analytica want to change the average salary increase percentage 
	value to 2 decimal places - what should the new value be for males for the 
	company level dashboard?
*/
SELECT 
CAST(AVG(current_employee_snapshot.salary_percentage_change) AS DECIMAL(5, 2)) AS salary_percentage_change_adjusted,
ROUND(AVG(current_employee_snapshot.salary_percentage_change), 2)
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M';


/*
	11) How many current employees have the equal longest overall time in their current positions (not in years)?
	Hint: You may want to recalculate the tenure value directly from the `mv_employees.department_employee` table!
*/
--Days
SELECT TOP 1
DATEDIFF(DAY, mv_department_employee.from_date, mv_department_employee.to_date) AS dept_tenure_days,
COUNT(mv_department_employee.employee_id) AS total_employees
FROM mv_employees.mv_department_employee
GROUP BY  DATEDIFF(DAY, mv_department_employee.from_date, mv_department_employee.to_date)
ORDER BY 1 DESC;

--Months
SELECT TOP 1
DATEDIFF(MONTH, mv_department_employee.from_date, mv_department_employee.to_date)/30.417 AS dept_tenure_months,
COUNT(DISTINCT mv_department_employee.employee_id) AS total_employees
FROM mv_employees.mv_department_employee
GROUP BY  DATEDIFF(MONTH, mv_department_employee.from_date, mv_department_employee.to_date)/30.417
ORDER BY 1 DESC;

--Years
SELECT TOP 1
DATEDIFF(YEAR, mv_department_employee.from_date, mv_department_employee.to_date)/365 AS dept_tenure_years,
COUNT(mv_department_employee.employee_id) AS total_employees
FROM mv_employees.mv_department_employee
GROUP BY  DATEDIFF(YEAR, mv_department_employee.from_date, mv_department_employee.to_date)/365
ORDER BY 1 DESC;