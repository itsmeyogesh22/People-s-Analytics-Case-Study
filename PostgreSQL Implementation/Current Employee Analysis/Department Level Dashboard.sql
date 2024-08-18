DROP VIEW IF EXISTS mv_employees.department_level_dashboard;
CREATE VIEW mv_employees.department_level_dashboard AS
SELECT
  gender,
  dept_name,
  COUNT(*) AS employee_count, 
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY dept_name
  )) AS employee_percentage,
  ROUND(AVG(department_tenure)) AS department_tenure,
  ROUND(AVG(salary_amount)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary_amount)) AS min_salary,
  ROUND(MAX(salary_amount)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_amount)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_amount) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_amount)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary_amount)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, dept_name;


SELECT * FROM mv_employees.department_level_dashboard;