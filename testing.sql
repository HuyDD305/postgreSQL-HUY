-- DATA TYPE
CREATE TABLE people1 (
	id integer GENERATED ALWAYS AS IDENTITY,
	person_name varchar(100)
);


CREATE TABLE teachers (
	id bigseriaal,
	first_name varchar(25),
	last_name varchar(50),
	school varchar(50),
	hire_date date,
	salary numeric
);

--This is select example
SELECT first_name, last_name, salary
FROM teachers
ORDER BY salary DESC;

SELECT last_name, first_name, school, hire_Date
FROM teachers
ORDER BY school ASC, hire_date DESC;

--Distinct
SELECT DISTINCT school
FROM teachers
ORDER BY school;

SELECT DISTINCT school, salary
FROM teachers
ORDER BY school, salary;


select * from teachers;

SELECT first_name, last_name, school
FROM teachers
WHERE school <> 'F.D. Roosevelt HS';

SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '2000-01-01';


--LIKE and ILIKE
SELECT first_name
FROM teachers
WHERE first_name Like 'sam%';

SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam_';


CREATE TABLE number_data_types (
	numeric_column numeric(20, 5),
	real_column real,
	double_column double precision
);
ALTER TABLE number_data_types
ADD COLUMN double_column double precision;

INSERT INTO number_data_types
VALUES
(.7, .7, .7),
(2.13579, 2.13579, 2.13579),
(2.1357987654, 2.1357987654, 2.1357987654);

SELECT * FROM number_data_types;

SELECT
numeric_column * 10000000 AS fixed,
real_column * 10000000 AS  floating
FROM number_data_types
WHERE numeric_column = .7;

-- This is DATE data type
CREATE TABLE date_time_types (
	timestamp_column timestamp with time zone,
	interval_column interval
);

INSERT INTO date_time_types
VALUES
('2022-12-31 01:00 EST', '2 days'),
('2022-12-31 01:00 -8', '1 month'),
('2022-12-31 01:00 Australia/Melbourne', '1 century'),
(now(), '1 week');

SELECT * FROM date_time_types;

SELECT timestamp_column, interval_column, timestamp_column - interval_column AS new_date
FROM date_time_types;

-- Transforming values from one type to another with cast
SELECT timestamp_column, CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT timestamp_column::varchar(10)
FROM date_time_types;

SELECT numeric_column, CAST(numeric_column AS integer), CAST(numeric_column AS text)
FROM number_data_types;

SELECT CAST(char_column AS integer) FROM char_data_types;
