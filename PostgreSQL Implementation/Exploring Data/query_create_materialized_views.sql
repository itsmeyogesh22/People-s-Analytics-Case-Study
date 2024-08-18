DROP SCHEMA IF EXISTS mv_employees CASCADE;
CREATE SCHEMA mv_employees;


DROP MATERIALIZED VIEW IF EXISTS mv_employees.mv_department;
CREATE MATERIALIZED VIEW mv_employees.mv_department AS
SELECT *
FROM department;


DROP MATERIALIZED VIEW IF EXISTS mv_employees.mv_department_employee;
CREATE MATERIALIZED VIEW mv_employees.mv_department_employee AS
SELECT 
	employee_id,
	department_id,
	(from_date + INTERVAL '18 YEARS')::DATE AS from_date,
	CASE 
		WHEN to_date <> '9999-01-01'::DATE THEN (to_date + INTERVAL '18 YEARS')::DATE 
		ELSE to_date
		END AS to_date
FROM department_employee;


DROP MATERIALIZED VIEW IF EXISTS mv_employees.mv_department_manager;
CREATE MATERIALIZED VIEW mv_employees.mv_department_manager AS
SELECT 
	employee_id,
	department_id,
	(from_date + INTERVAL '18 YEARS')::DATE AS from_date,
	CASE 
		WHEN to_date <> '9999-01-01'::DATE THEN (to_date + INTERVAL '18 YEARS')::DATE 
		ELSE to_date
		END AS to_date
FROM department_manager;


DROP MATERIALIZED VIEW IF EXISTS mv_employees.mv_employee;
CREATE MATERIALIZED VIEW mv_employees.mv_employee AS
SELECT 
	id,
	(birth_date + INTERVAL '18 YEARS')::DATE AS birth_date, 
	first_name, 
	last_name, 
	gender,
	(hire_date + INTERVAL '18 YEARS')::DATE AS hire_date
FROM employee;


DROP MATERIALIZED VIEW IF EXISTS mv_employees.mv_salary;
CREATE MATERIALIZED VIEW mv_employees.mv_salary AS
SELECT 
	employee_id,
	amount,
	(from_date + INTERVAL '18 YEARS')::DATE AS from_date,
	CASE 
		WHEN to_date <> '9999-01-01'::DATE THEN (to_date + INTERVAL '18 YEARS')::DATE 
		ELSE to_date
		END AS to_date
FROM salary;


DROP MATERIALIZED VIEW IF EXISTS mv_employees.mv_title;
CREATE MATERIALIZED VIEW mv_employees.mv_title AS
SELECT 
	employee_id,
	title,
	(from_date + INTERVAL '18 YEARS')::DATE AS from_date,
	CASE 
		WHEN to_date <> '9999-01-01'::DATE THEN (to_date + INTERVAL '18 YEARS')::DATE 
		ELSE to_date
		END AS to_date
FROM title;

--Testing performence 
CREATE INDEX ON mv_employees.mv_salary (employee_id);
REFRESH MATERIALIZED VIEW mv_employees.mv_salary;
EXPLAIN ANALYSE SELECT * FROM mv_employees.mv_salary WHERE employee_id = 10001;




--Setting indexes 
CREATE UNIQUE INDEX 
	ON mv_employees.mv_employee USING btree (id);

CREATE UNIQUE INDEX 
	ON mv_employees.mv_department_employee USING btree (employee_id, department_id);

CREATE INDEX       
	ON mv_employees.mv_department_employee USING btree (department_id);

CREATE UNIQUE INDEX 
	ON mv_employees.mv_department USING btree (id);

CREATE UNIQUE INDEX 
	ON mv_employees.mv_department USING btree (dept_name);

CREATE UNIQUE INDEX 
	ON mv_employees.mv_department_manager USING btree (employee_id, department_id);

CREATE INDEX        
	ON mv_employees.mv_department_manager USING btree (department_id);

CREATE UNIQUE INDEX 
	ON mv_employees.mv_salary USING btree (employee_id, from_date);

CREATE UNIQUE INDEX 
	ON mv_employees.mv_title USING btree (employee_id, title, from_date);