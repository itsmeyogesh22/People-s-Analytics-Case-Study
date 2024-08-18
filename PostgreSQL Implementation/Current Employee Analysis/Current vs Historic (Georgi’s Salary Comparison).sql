--1) What was Georgi’s starting salary at the beginning of 2009?
SELECT 
	mv_salary.employee_id,
	mv_salary.amount
FROM mv_employees.mv_salary
WHERE mv_salary.employee_id = 10001
	AND mv_salary.from_date < '2008-12-31'::DATE
	AND mv_salary.to_date > '2008-12-31'::DATE;


--2) What is Georgi’s current salary?
SELECT
	mv_salary.employee_id,
	mv_salary.amount
FROM mv_employees.mv_salary
WHERE 
	mv_salary.to_date = '9999-01-01'::DATE
	AND
	mv_salary.employee_id = 10001;

--3) Georgi received a raise on 23rd of June in 2014 - how much of a percentage increase was it?
WITH salary_cte1 AS (
SELECT 
	mv_salary.employee_id,
	mv_salary.amount,
	mv_salary.from_date,
	mv_salary.to_date
FROM mv_employees.mv_salary
WHERE 
	mv_salary.from_date < '2014-06-30'::DATE
	AND mv_salary.employee_id = 10001
)
SELECT
	salary_cte1.amount, 
	salary_cte1.from_date, 
	ROUND(
	100*(
		 salary_cte1.amount - LAG(salary_cte1.amount) 
			OVER(ORDER BY salary_cte1.from_date ASC))::NUMERIC/
	LAG(salary_cte1.amount) OVER (ORDER BY salary_cte1.from_date ASC), 
	2) AS percentage_increment
FROM salary_cte1
ORDER BY 2 DESC
LIMIT 1;


--4) What is the dollar amount difference between Georgi’s salary at date '2012-06-25' and '2020-06-21'
SELECT 
	FIRST_VALUE(mv_salary.amount) OVER (ORDER BY mv_salary.from_date ASC) AS amount_dated_2012,
	LAST_VALUE(mv_salary.amount) OVER (ORDER BY mv_salary.to_date ASC) AS amount_dated_2020, 
	(
	LAST_VALUE(mv_salary.amount) OVER (ORDER BY mv_salary.to_date ASC) -
	FIRST_VALUE(mv_salary.amount) OVER (ORDER BY mv_salary.from_date ASC) 
	) AS amount_difference
FROM mv_employees.mv_salary
WHERE 
	mv_salary.employee_id = 10001
	AND
	mv_salary.from_date >= '2012-06-24'::DATE AND mv_salary.to_date <= '2020-06-22'::DATE
ORDER BY mv_salary.to_date DESC
LIMIT 1;