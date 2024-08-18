USE employees;

/*
	1) How many employees have left the company?
*/
SELECT  
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.expiry_date != '9999-01-01'
	AND
	historic_employee_records.event_order = 1;



/*
	2) What percentage of churn employees were male?
*/
--Method-1: Using sub Query with 'WHERE' Clause
SELECT 
	historic_employee_records.gender,
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count,
	CAST(
		(100*COUNT(DISTINCT historic_employee_records.employee_id))/
		SUM(COUNT(DISTINCT historic_employee_records.employee_id)) OVER ()
	AS DECIMAL(10, 0)) AS male_employee_churn
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.employee_id 
	NOT IN (SELECT DISTINCT current_employee_snapshot.employee_id FROM mv_employees.current_employee_snapshot)
	AND
	historic_employee_records.event_order = 1
GROUP BY historic_employee_records.gender;

--Method-2: Using Date filter
SELECT 
	historic_employee_records.gender,
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count,
	CAST(
		100*(COUNT(DISTINCT historic_employee_records.employee_id))/
		SUM(COUNT(DISTINCT historic_employee_records.employee_id)) OVER ()
	AS DECIMAL(10, 0)) AS male_employee_churn
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.expiry_date != '9999-01-01'
	AND
	historic_employee_records.event_order = 1
GROUP BY historic_employee_records.gender;


/*
	3) Which title had the most churn?
*/
--Method-1: Using sub Query with 'WHERE' Clause
SELECT TOP 1
	historic_employee_records.title,
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count,
	CAST(
		100*(COUNT(DISTINCT historic_employee_records.employee_id))/
		SUM(COUNT(DISTINCT historic_employee_records.employee_id)) OVER ()
 	AS DECIMAL(10, 0)) AS churn_rate_percentage
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.employee_id 
	NOT IN (SELECT DISTINCT current_employee_snapshot.employee_id FROM mv_employees.current_employee_snapshot)
	AND
	historic_employee_records.event_order = 1
GROUP BY historic_employee_records.title
ORDER BY 2 DESC;

--Method-2: Using Date filter
SELECT TOP 1
	historic_employee_records.title,
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count,
	CAST(
		100*(COUNT(DISTINCT historic_employee_records.employee_id))/
		SUM(COUNT(DISTINCT historic_employee_records.employee_id)) OVER ()
	AS DECIMAL(10, 0)) AS churn_rate_percentage
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.expiry_date != '9999-01-01'
	AND
	historic_employee_records.event_order = 1
GROUP BY historic_employee_records.title
ORDER BY 2 DESC;


/*
	4) Which department had the most churn?
*/
--Method-1: Using sub Query with 'WHERE' Clause
SELECT TOP 1
	historic_employee_records.dept_name,
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count,
	CAST(
		100*(COUNT(DISTINCT historic_employee_records.employee_id))/
		SUM(COUNT(DISTINCT historic_employee_records.employee_id)) OVER () 
	AS DECIMAL(10, 0)) AS churn_rate_percentage
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.employee_id 
	NOT IN (SELECT DISTINCT current_employee_snapshot.employee_id FROM mv_employees.current_employee_snapshot)
	AND
	historic_employee_records.event_order = 1
GROUP BY historic_employee_records.dept_name
ORDER BY 2 DESC;

--Method-2: Using Date filter
SELECT TOP 1
	historic_employee_records.dept_name,
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count,
	CAST(
		100*(COUNT(DISTINCT historic_employee_records.employee_id))/
		SUM(COUNT(DISTINCT historic_employee_records.employee_id)) OVER ()
	AS DECIMAL(10, 0)) AS churn_rate_percentage
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.expiry_date != '9999-01-01'
	AND
	historic_employee_records.event_order = 1
GROUP BY historic_employee_records.dept_name
ORDER BY 2 DESC;


/*
	5) Which year had the most churn?
*/
SELECT TOP 1
	YEAR(historic_employee_records.[expiry_date]) AS work_year,
	COUNT(DISTINCT historic_employee_records.employee_id) AS employee_churn_count,
	CAST(
		100*(COUNT(DISTINCT historic_employee_records.employee_id))/
		SUM(COUNT(DISTINCT historic_employee_records.employee_id)) OVER ()
	AS DECIMAL(10, 0)) AS churn_rate_percentage
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.employee_id 
	NOT IN (SELECT DISTINCT current_employee_snapshot.employee_id FROM mv_employees.current_employee_snapshot)
	AND
	historic_employee_records.event_order = 1
GROUP BY YEAR(historic_employee_records.[expiry_date])
ORDER BY 2 DESC;



/*
	6) What was the average salary for each employee who has left the company 
	rounded to the nearest integer?
*/
--Method-1: Using sub Query with 'WHERE' Clause
SELECT  
	AVG(historic_employee_records.salary_amount) average_salary
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.employee_id 
	NOT IN (SELECT DISTINCT current_employee_snapshot.employee_id FROM mv_employees.current_employee_snapshot)
	AND
	historic_employee_records.event_order = 1;

--Method-2: Using Date filter
SELECT  
	CAST(AVG(historic_employee_records.salary_amount) AS DECIMAL(10, 0)) average_salary
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.expiry_date != '9999-01-01'
	AND
	historic_employee_records.event_order = 1;


/*
	7) What was the median total company tenure for each churn employee just bfore they left?
*/
SELECT DISTINCT
FLOOR(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tenure_benchmark.company_tenure_years ASC) OVER())
FROM mv_employees.tenure_benchmark;

SELECT DISTINCT
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY historic_employee_records.company_tenure_years ASC) OVER ()
FROM mv_employees.historic_employee_records
WHERE historic_employee_records.expiry_date != '9999-01-01'
AND historic_employee_records.event_order = 1
ORDER BY 1 ASC;

/*
	8) On average, how many different titles did each churn employee hold rounded to 1 decimal place?
*/
WITH churn_employee AS (
SELECT  
	historic_employee_records.employee_id
FROM mv_employees.historic_employee_records 
WHERE 
	historic_employee_records.expiry_date != '9999-01-01'
	AND
	historic_employee_records.event_order = 1
),
title_count AS (
SELECT 
	T1.employee_id,
	COUNT(DISTINCT T1.title) AS titles_held
FROM mv_employees.historic_employee_records AS T1
WHERE EXISTS 
			( 
			SELECT 1
			FROM churn_employee AS T2 
			WHERE T1.employee_id = T2.employee_id
		)
GROUP BY T1.employee_id
)
SELECT 
	CAST(AVG(titles_held) AS DECIMAL(5, 2)) AS average_titles_held
FROM title_count;



/*
	9) What was the average last pay increase for churn employees?
*/
SELECT  
	ROUND(AVG(historic_employee_records.latest_salary_amount_change), 2) AS average_increment
FROM mv_employees.historic_employee_records
WHERE 
	historic_employee_records.employee_id 
	NOT IN (SELECT DISTINCT current_employee_snapshot.employee_id FROM mv_employees.current_employee_snapshot)
	AND
	historic_employee_records.event_order = 1
	AND 
	historic_employee_records.latest_salary_amount_change > 0;



/*
	10) What percentage of churn employees had a pay decrease event in their last 5 events?
*/
WITH decrease_cte AS (
  SELECT
    employee_id,
    MAX(
      CASE WHEN event_name = 'Salary Reduction' THEN 1
      ELSE 0 END
    ) AS salary_decrease_flag
  FROM mv_employees.employee_deep_dive AS t1
  WHERE EXISTS (
    SELECT 1
    FROM mv_employees.employee_deep_dive AS t2
    WHERE t2.event_order = 1
      AND t2.expiry_date != '9999-01-01'
      AND t1.employee_id = t2.employee_id
    )
  GROUP BY employee_id
)
SELECT
  CAST(100 * SUM(salary_decrease_flag) / COUNT(*) AS DECIMAL(10, 0)) AS percentage_decrease
FROM decrease_cte;

