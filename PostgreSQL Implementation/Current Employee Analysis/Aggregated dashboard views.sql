--title level aggregation
DROP VIEW IF EXISTS mv_employees.title_level_dashboard;
CREATE VIEW mv_employees.title_level_dashboard AS
SELECT
  CES.gender,
  CES.title,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY CES.title
  )) AS employee_percentage,
  ROUND(AVG(CES.title_tenure)) AS title_tenure,
  ROUND(AVG(CES.salary_amount)) AS avg_salary,
  ROUND(AVG(CES.salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(CES.salary_amount)) AS min_salary,
  ROUND(MAX(CES.salary_amount)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CES.salary_amount)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CES.salary_amount) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CES.salary_amount)
  ) AS inter_quartile_range,
  ROUND(STDDEV(CES.salary_amount)) AS stddev_salary 
FROM mv_employees.current_employee_snapshot AS CES
GROUP BY 
	CES.gender, 
	CES.title;


-- department level aggregation
DROP VIEW IF EXISTS mv_employees.department_level_dashboard;
CREATE VIEW mv_employees.department_level_dashboard AS
SELECT
  CES.gender,
  CES.dept_name,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY CES.dept_name
  )) AS employee_percentage,
  ROUND(AVG(CES.department_tenure)) AS department_tenure,
  ROUND(AVG(CES.salary_amount)) AS avg_salary,
  ROUND(AVG(CES.salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(CES.salary_amount)) AS min_salary,
  ROUND(MAX(CES.salary_amount)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CES.salary_amount)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CES.salary_amount) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CES.salary_amount)
  ) AS inter_quartile_range,
  ROUND(STDDEV(CES.salary_amount)) AS stddev_salary
FROM mv_employees.current_employee_snapshot AS CES
GROUP BY
	CES.gender, 
	CES.dept_name;


-- company level aggregation
DROP VIEW IF EXISTS mv_employees.company_level_dashboard;
CREATE VIEW mv_employees.company_level_dashboard AS
SELECT
  CES.gender,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()) AS employee_percentage,
  ROUND(AVG(CES.company_tenure)) AS company_tenure,
  ROUND(AVG(CES.salary_amount)) AS avg_salary,
  ROUND(AVG(CES.salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(CES.salary_amount)) AS min_salary,
  ROUND(MAX(CES.salary_amount)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CES.salary_amount)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CES.salary_amount) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CES.salary_amount)
  ) AS inter_quartile_range,
  ROUND(STDDEV(CES.salary_amount)) AS stddev_salary
FROM mv_employees.current_employee_snapshot AS CES
GROUP BY
	CES.gender;