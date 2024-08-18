CREATE TABLE department (
    id character(4) NOT NULL,
    dept_name character varying(40) NOT NULL
);

CREATE TABLE department_employee (
    employee_id bigint NOT NULL,
    department_id character(4) NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL
);

CREATE TABLE department_manager (
    employee_id bigint NOT NULL,
    department_id character(4) NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL
);


CREATE TABLE employee (
    id bigint NOT NULL,
    birth_date date NOT NULL,
    first_name character varying(14) NOT NULL,
    last_name character varying(16) NOT NULL,
    gender employee_gender NOT NULL,
    hire_date date NOT NULL
);


CREATE TABLE salary (
    employee_id bigint NOT NULL,
    amount bigint NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL
);

CREATE TABLE title (
    employee_id bigint NOT NULL,
    title character varying(50) NOT NULL,
    from_date date NOT NULL,
    to_date date
);


ALTER TABLE ONLY department
    ADD CONSTRAINT idx_16979_primary PRIMARY KEY (id);


ALTER TABLE ONLY department_employee
    ADD CONSTRAINT idx_16982_primary PRIMARY KEY (employee_id, department_id);


ALTER TABLE ONLY department_manager
    ADD CONSTRAINT idx_16985_primary PRIMARY KEY (employee_id, department_id);


ALTER TABLE ONLY employee
    ADD CONSTRAINT idx_16988_primary PRIMARY KEY (id);


ALTER TABLE ONLY salary
    ADD CONSTRAINT idx_16991_primary PRIMARY KEY (employee_id, from_date);



ALTER TABLE ONLY title
    ADD CONSTRAINT idx_16994_primary PRIMARY KEY (employee_id, title, from_date);


CREATE UNIQUE INDEX idx_16979_dept_name ON department USING btree (dept_name);
CREATE INDEX idx_16982_dept_no ON department_employee USING btree (department_id);
CREATE INDEX idx_16985_dept_no ON department_manager USING btree (department_id);

ALTER TABLE ONLY department_employee
    ADD CONSTRAINT dept_emp_ibfk_1 FOREIGN KEY (employee_id) REFERENCES employee(id) ON UPDATE RESTRICT ON DELETE CASCADE;

ALTER TABLE ONLY department_employee
    ADD CONSTRAINT dept_emp_ibfk_2 FOREIGN KEY (department_id) REFERENCES department(id) ON UPDATE RESTRICT ON DELETE CASCADE;

ALTER TABLE ONLY department_manager
    ADD CONSTRAINT dept_manager_ibfk_1 FOREIGN KEY (employee_id) REFERENCES employee(id) ON UPDATE RESTRICT ON DELETE CASCADE;

ALTER TABLE ONLY department_manager
    ADD CONSTRAINT dept_manager_ibfk_2 FOREIGN KEY (department_id) REFERENCES department(id) ON UPDATE RESTRICT ON DELETE CASCADE;

ALTER TABLE ONLY salary
    ADD CONSTRAINT salaries_ibfk_1 FOREIGN KEY (employee_id) REFERENCES employee(id) ON UPDATE RESTRICT ON DELETE CASCADE;

ALTER TABLE ONLY title
    ADD CONSTRAINT titles_ibfk_1 FOREIGN KEY (employee_id) REFERENCES employee(id) ON UPDATE RESTRICT ON DELETE CASCADE;