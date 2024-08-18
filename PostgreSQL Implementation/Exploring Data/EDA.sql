--Columns count for each table in public schema
SELECT 
	TABLE_NAME,
	COUNT(COLUMN_NAME) AS column_count
FROM information_schema."columns" 
WHERE 
	TABLE_NAME NOT LIKE 'pg_%' 
	AND 
	TABLE_SCHEMA IN ('public')
GROUP BY TABLE_NAME;


--Size of each table in public schema
SELECT 
	TABLE_NAME,
	PG_SIZE_PRETTY(PG_RELATION_SIZE('public'|| ' . ' || TABLE_NAME)) AS TABLE_SIZE
FROM information_schema."tables" 
WHERE 
	TABLE_NAME NOT LIKE 'pg_%' 
	AND 
	TABLE_SCHEMA IN ('public')
	AND
	TABLE_TYPE = 'BASE TABLE';


--Rows count for each table in public schema
SELECT 
	PC.RELNAME AS _table_name_,
	PC.RELTUPLES::NUMERIC AS total_records
FROM PG_CLASS AS PC
JOIN PG_NAMESPACE AS PN ON PN.oid = PC.RELNAMESPACE
WHERE 
	PC.RELKIND = 'r'
	AND
	PN.NSPNAME 
		IN ('public')
	AND 
	PN.NSPNAME NOT LIKE 'pg_%'
ORDER BY PC.RELTUPLES DESC;


--Overview of each table
--Table: "employee"
SELECT 
	id,
	hire_date,
	(hire_date + INTERVAL '18 YEARS')::DATE AS adjusted_hire_date
FROM employee
WHERE hire_date <> '9999-01-01'::DATE
LIMIT 5;


--Table: "title"
SELECT 
	*
FROM title
WHERE employee_id = 10005
ORDER BY from_Date ASC;


--Table: "salary"
SELECT 
	*,
	(to_date + INTERVAL '18 YEARS')::DATE AS adjusted_to_date
FROM salary
WHERE to_date <> '9999-01-01'
ORDER BY from_Date ASC
LIMIT 5;


--Table: "department_employee"
SELECT 
	*,
	(to_date + INTERVAL '18 YEARS')::DATE AS adjusted_to_date
FROM department_employee
WHERE to_date <> '9999-01-01'
ORDER BY from_Date ASC
LIMIT 5;


--Table: "department"
SELECT *
FROM department;


--Table: "department_manager"
SELECT 
	*,
	(to_date + INTERVAL '18 YEARS')::DATE AS adjusted_to_date
FROM department_manager
WHERE to_date <> '9999-01-01'
ORDER BY from_Date ASC;