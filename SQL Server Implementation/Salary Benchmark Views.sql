USE employees;


CREATE VIEW mv_employees.tenure_benchmark AS
SELECT
  current_employee_snapshot.company_tenure_years,
  AVG(current_employee_snapshot.salary_amount) AS tenure_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY current_employee_snapshot.company_tenure_years;


CREATE VIEW mv_employees.gender_benchmark AS
SELECT
  current_employee_snapshot.gender,
  AVG(current_employee_snapshot.salary_amount) AS gender_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY current_employee_snapshot.gender;


CREATE VIEW mv_employees.department_benchmark AS
SELECT
  current_employee_snapshot.dept_name,
  AVG(current_employee_snapshot.salary_amount) AS department_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY current_employee_snapshot.dept_name;


CREATE VIEW mv_employees.title_benchmark AS
SELECT
  current_employee_snapshot.title,
  AVG(current_employee_snapshot.salary_amount) AS title_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY current_employee_snapshot.title;