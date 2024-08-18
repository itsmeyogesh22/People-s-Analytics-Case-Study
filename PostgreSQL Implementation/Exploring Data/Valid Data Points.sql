/*
	5) For each employee who no longer has a valid salary data point - 
	which year had the most employee churn and how many employees left that year?
*/
DROP TABLE IF EXISTS annual_churn_report;
CREATE TEMP TABLE annual_churn_report AS 
WITH valid_dates AS (
SELECT DISTINCT
	mv_salary.employee_id,
	LAST_VALUE(mv_salary.to_date) 
		OVER (
			PARTITION BY mv_salary.employee_id 
			ORDER BY mv_salary.employee_id
	) AS most_recent_working_date 
FROM mv_employees.mv_salary
),
churn_rate_cte AS (
SELECT 
	working_year,
	employee_count, 
	COALESCE(LAG(employee_count) OVER (ORDER BY working_year ASC), 0) AS prev_year_count,
	CASE 
		WHEN (LAG(employee_count) OVER (ORDER BY working_year ASC)) IS NULL 
			THEN 0
		WHEN employee_count > (LAG(employee_count) OVER (ORDER BY working_year ASC)) 
			THEN (employee_count - (LAG(employee_count) OVER (ORDER BY working_year ASC)))
		ELSE ((LAG(employee_count) OVER (ORDER BY working_year ASC)) - employee_count)
		END AS total_churn
FROM 
	(
	SELECT 
	EXTRACT(
		YEAR 
		FROM valid_dates.most_recent_working_date) AS working_year,
	COUNT(*) AS employee_count
	FROM valid_dates
	WHERE valid_dates.most_recent_working_date <> '9999-01-01'
	GROUP BY 1
	) AS V1
)
SELECT 
	working_year,
	employee_count,
	CASE 
		WHEN prev_year_count = 0 THEN '0 not churned -OR- churned'
		WHEN prev_year_count > employee_count THEN CONCAT('-', total_churn, ' less')
		ELSE CONCAT('+', total_churn, ' more churned')
		END AS comparison_to_prev_year
FROM churn_rate_cte;

--Year with highest employee churn:
SELECT 
	working_year,
	employee_count,
	comparison_to_prev_year
FROM annual_churn_report
ORDER BY 2 DESC
LIMIT 1;


/*
	6) What is the average latest percentage and dollar amount change in salary for each employee who 
	has a valid current salary record?
*/
--Method-1: Using 'ROW_NUMBER()' Window function in CTE
DROP TABLE IF EXISTS recent_average_metrics_1;
CREATE TEMP TABLE recent_average_metrics_1 AS
WITH valid_preceding_dates AS (
SELECT *
FROM 
	(
	 SELECT 
	*,
	ROW_NUMBER() 
		OVER (
			PARTITION BY mv_salary.employee_id 
			ORDER BY mv_salary.to_date DESC
		) AS preceding_dates
	FROM mv_employees.mv_salary
	WHERE mv_salary.to_date <= '9999-01-01'::DATE
	) AS V2
WHERE preceding_dates <= 2
)
SELECT *
FROM valid_preceding_dates;


SELECT
	CONCAT('$ ', ROUND(AVG(T1.amount - T2.amount), 2)) AS average_amount_change,
	CONCAT(ROUND(AVG(100*(T1.amount - T2.amount)/(T2.amount)::NUMERIC), 2), '%') AS average_rate_of_change
FROM recent_average_metrics_1 AS T1
INNER JOIN recent_average_metrics_1 AS T2 
	ON T1.employee_id = T2.employee_id
	AND 
	T1.preceding_dates = 1 AND T2.preceding_dates = 2;
