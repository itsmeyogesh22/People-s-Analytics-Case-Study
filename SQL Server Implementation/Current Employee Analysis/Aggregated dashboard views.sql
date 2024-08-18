USE employees;


-- company level aggregation view
CREATE VIEW mv_employees.company_level_dashboard AS
WITH median_union_cte AS (
SELECT DISTINCT
current_employee_snapshot.gender, 
PERCENTILE_CONT(0.5) 
	WITHIN GROUP 
			(ORDER BY salary_amount) OVER ()  AS [median_salary]
FROM mv_employees.current_employee_snapshot 
WHERE current_employee_snapshot.gender = 'M'
UNION
SELECT DISTINCT
current_employee_snapshot.gender, 
PERCENTILE_CONT(0.5) 
	WITHIN GROUP 
			(ORDER BY salary_amount) OVER ()  AS [median_salary]
FROM mv_employees.current_employee_snapshot 
WHERE current_employee_snapshot.gender = 'F'
),
inter_quartile_union_cte AS (
SELECT DISTINCT
current_employee_snapshot.gender,
(
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_amount) OVER () -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_amount) OVER ()
) AS inter_quartile_range
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
UNION
SELECT DISTINCT
current_employee_snapshot.gender,
CEILING
(
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_amount) OVER () -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_amount) OVER ()
) AS inter_quartile_range
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
)
SELECT 
current_employee_snapshot.gender,
COUNT(*) AS total_employees,
ROUND(100*COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS ratio,
CEILING(AVG(current_employee_snapshot.company_tenure_years)) AS average_company_tenure,
CAST(AVG(current_employee_snapshot.salary_amount) AS DECIMAL(5, 0)) AS average_salary,
CAST(AVG(current_employee_snapshot.salary_percentage_change) AS DECIMAL(5, 0)) AS average_salary_percentage_change, 
MIN(current_employee_snapshot.salary_amount) AS minimum_salary,
MAX(current_employee_snapshot.salary_amount) AS maximum_salary,
median_union_cte.median_salary,
inter_quartile_union_cte.inter_quartile_range,
CAST(STDEV(current_employee_snapshot.salary_amount) AS DECIMAL(10, 0))  AS stddev_salary
FROM mv_employees.current_employee_snapshot
INNER JOIN median_union_cte
	ON current_employee_snapshot.gender = median_union_cte.gender
INNER JOIN inter_quartile_union_cte
	ON current_employee_snapshot.gender = inter_quartile_union_cte.gender
GROUP BY 
	current_employee_snapshot.gender, 
	median_union_cte.median_salary,
	inter_quartile_union_cte.inter_quartile_range;




CREATE VIEW mv_employees.department_level_dashboard AS
WITH median_union_cte AS (
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.dept_name,
CAST(
PERCENTILE_CONT(0.5) 
	WITHIN GROUP (ORDER BY current_employee_snapshot.salary_amount) 
	OVER (PARTITION BY current_employee_snapshot.dept_name) 
AS DECIMAL(10, 0)) AS [median_salary]
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
UNION
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.dept_name,
CAST(
PERCENTILE_CONT(0.5) 
	WITHIN GROUP (ORDER BY current_employee_snapshot.salary_amount) 
	OVER (PARTITION BY current_employee_snapshot.dept_name) 
AS DECIMAL(10, 0))AS [median_salary]
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
),
inter_quartile_union_cte AS (
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.dept_name,
CAST(
(
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.dept_name) -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.dept_name)
) AS DECIMAL(10, 0)) AS inter_quartile_range
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
UNION
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.dept_name,
CAST(
(
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.dept_name) -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.dept_name)
)
AS DECIMAL(10, 0)) AS inter_quartile_range
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
)
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.dept_name,
COUNT(*) AS total_employees,
100*COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY current_employee_snapshot.dept_name) AS ratio,
CEILING(AVG(current_employee_snapshot.department_tenure_years)) AS average_department_tenure,
CAST(AVG(current_employee_snapshot.salary_amount) AS DECIMAL(5, 0)) AS average_salary,
CAST(AVG(current_employee_snapshot.salary_percentage_change) AS DECIMAL(5, 0)) AS average_salary_percentage_change, 
MIN(current_employee_snapshot.salary_amount) AS minimum_salary,
MAX(current_employee_snapshot.salary_amount) AS maximum_salary,
median_union_cte.median_salary,
inter_quartile_union_cte.inter_quartile_range,
CAST(STDEV(current_employee_snapshot.salary_amount) AS DECIMAL(10, 0))  AS stddev_salary
FROM mv_employees.current_employee_snapshot
INNER JOIN median_union_cte 
	ON current_employee_snapshot.gender = median_union_cte.gender
	AND
	current_employee_snapshot.dept_name = median_union_cte.dept_name
INNER JOIN inter_quartile_union_cte
	ON current_employee_snapshot.gender = inter_quartile_union_cte.gender
	AND
	current_employee_snapshot.dept_name = inter_quartile_union_cte.dept_name
GROUP BY 
	current_employee_snapshot.gender,
	current_employee_snapshot.dept_name,
	median_union_cte.median_salary,
	inter_quartile_union_cte.inter_quartile_range;


-- title level aggregation view
CREATE VIEW mv_employees.title_level_dashboard AS
WITH median_union_cte AS (
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.title,
CAST(
PERCENTILE_CONT(0.5) 
	WITHIN GROUP (ORDER BY current_employee_snapshot.salary_amount) 
	OVER (PARTITION BY current_employee_snapshot.title) 
AS DECIMAL(10, 0)) AS [median_salary]
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
UNION
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.title,
CAST(
PERCENTILE_CONT(0.5) 
	WITHIN GROUP (ORDER BY current_employee_snapshot.salary_amount) 
	OVER (PARTITION BY current_employee_snapshot.title) 
AS DECIMAL(10, 0))AS [median_salary]
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
),
inter_quartile_union_cte AS (
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.title,
CAST(
(
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.title) -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.title)
) AS DECIMAL(10, 0)) AS inter_quartile_range
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'M'
UNION
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.title,
CAST(
(
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.title) -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_amount) OVER (PARTITION BY current_employee_snapshot.title)
)
AS DECIMAL(10, 0)) AS inter_quartile_range
FROM mv_employees.current_employee_snapshot
WHERE current_employee_snapshot.gender = 'F'
)
SELECT DISTINCT
current_employee_snapshot.gender,
current_employee_snapshot.title,
COUNT(*) AS total_employees,
100*COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY current_employee_snapshot.title) AS ratio,
CEILING(AVG(current_employee_snapshot.title_tenure_years)) AS average_title_tenure,
CAST(AVG(current_employee_snapshot.salary_amount) AS DECIMAL(5, 0)) AS average_salary,
CAST(AVG(current_employee_snapshot.salary_percentage_change) AS DECIMAL(5, 0)) AS average_salary_percentage_change, 
MIN(current_employee_snapshot.salary_amount) AS minimum_salary,
MAX(current_employee_snapshot.salary_amount) AS maximum_salary,
median_union_cte.median_salary,
inter_quartile_union_cte.inter_quartile_range,
CAST(STDEV(current_employee_snapshot.salary_amount) AS DECIMAL(10, 0))  AS stddev_salary
FROM mv_employees.current_employee_snapshot
INNER JOIN median_union_cte 
	ON current_employee_snapshot.gender = median_union_cte.gender
	AND current_employee_snapshot.title = median_union_cte.title
INNER JOIN inter_quartile_union_cte
	ON current_employee_snapshot.gender = inter_quartile_union_cte.gender
	AND current_employee_snapshot.title = inter_quartile_union_cte.title
GROUP BY 
	current_employee_snapshot.gender,
	current_employee_snapshot.title,
	median_union_cte.median_salary,
	inter_quartile_union_cte.inter_quartile_range;


