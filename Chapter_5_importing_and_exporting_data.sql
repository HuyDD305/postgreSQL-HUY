-- I’ve seen all kinds of characters used as delimiters,
--  from ampersands to pipes, but the comma is most commonly used; hence the
-- name of a file type you’ll see often is comma-separated values (CSV). The
-- --  terms CSV and comma-delimited are interchangeable.
--  John,Doe,123 Main St.,Hyde Park,NY,845-555-1212
 -- A feature you’ll often find inside a delimited text file is a header row. As the
 -- name implies, it’s a single row at the top, or head, of the file that lists the
 -- name of each data column. Often, a header is added when data is exported
 -- from a database or a spreadsheet.
 --  delimited files use an arbitrary character called a
 -- text qualifier to enclose a column that includes the delimiter character. This
 -- acts as a signal to ignore that delimiter and treat everything between the text
 -- qualifiers as a single column.
--   FIRSTNAME,LASTNAME,STREET,CITY,STATE,PHONE 
-- John,Doe,"123 Main St., Apartment 200",Hyde Park,NY,845
-- 555-1212
-- To import data from an external file into our database, we first create a table
--  in our database that matches the columns and data types in our source file.
--  Once that’s done, the COPY statement for the import is just the three lines of
--  code in 

-- Listing 5-1.
--  1 COPY table_name
--  2 FROM 'C:\YourDirectory\your_file.csv' 
-- 3 WITH (FORMAT CSV, HEADER);

-- Input and output file format
-- Use the FORMAT format_name option to specify the type of file you’re
--  reading or writing. Format names are CSV, TEXT, or BINARY.
 -- In the TEXT format, a tab character is the
 -- delimiter by default (although you can specify another character), and
 -- backslash characters such as \r are recognized as their ASCII equivalents—
 -- in this case, a carriage return. The TEXT format is used mainly by
 -- PostgreSQL’s built-in backup programs.

 --Presence of a header row
 -- On import, use HEADER to specify that the source file has a header row that
 -- you want to exclude. The database will start importing with the second line
 -- of the file so that the column names in the header don’t become part of the
 -- data in the table. (Be sure to check your source CSV to make sure this is what
 -- you want; not every CSV comes with a header row!) On export, using
 -- HEADER tells the database to include the column names as a header row in the
 -- output file, which helps a user understand the file’s contents

 -- Delimiter
 -- The DELIMITER 'character' option lets you specify which character your
 -- import or export file uses as a delimiter. The delimiter must be a single
 -- character and cannot be a carriage return. If you use FORMAT CSV, the
 -- assumed delimiter is a comma. I include DELIMITER here to show that you
 -- have the option to specify a different delimiter if that’s how your data
 -- arrived. For example, if you received pipe-delimited data, you would treat
 -- the option this way: DELIMITER '|'.

 CREATE TABLE us_counties_pop_est_2019 (
	state_fips text,
	county_fips text,
	region smallint,
	state_name text,
	county_name text,
	area_land bigint,
	area_water bigint,
	internal_point_lat numeric(10,7),
	internal_point_lon numeric(10, 7),
	pop_est_2018 integer,
	pop_est_2019 integer,
	births_2019 integer,
	deaths_2019 integer,
	international_migr_2019 integer,
	domestic_migr_2019 integer,
	residual_2019 integer,
	CONSTRAINT counties_2019_key PRIMARY KEY (state_fips, county_fips)
 );




COPY us_counties_pop_est_2019
FROM 'E:\learning_stuff\study\database\demo_code\practical-sql-2-main\practical-sql-2-main\Chapter_05\us_counties_pop_est_2019.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM us_counties_pop_est_2019;


SELECT county_name, state_name, area_land
FROM us_counties_pop_est_2019
ORDER BY area_land DESC
LIMIT 3;

SELECT county_name, state_name, internal_point_lat, internal_point_lon
FROM us_counties_pop_est_2019
ORDER BY internal_point_lon DESC
LIMIT 5;

-- If a CSV file doesn’t have data for all the columns in your target database
--  table, you can still import the data you have by specifying which columns are
--  present in the data.  
CREATE TABLE supervisor_salaries (
 id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 town text,
 county text,
 supervisor text,
 start_date date,
 salary numeric(10,2),
 benefits numeric(10,2)
);

-- You want columns for the town and county, the supervisor’s name, the date
--  they started, and salary and benefits (assuming you just care about current
--  levels). You’re also adding an auto-incrementing id column as a primary key.
--  However, the first county clerk you contact says, “Sorry, we only have town,
--  supervisor, and salary. You’ll need to get the rest from elsewhere.” You tell
--  them to send a CSV anyway. You’ll import what you can.
-- You could try to import it using this basic COPY syntax:
--  COPY supervisor_salaries 
-- FROM 'C:\YourDirectory\supervisor_salaries.csv' 
-- WITH (FORMAT CSV, HEADER);
--  But if you do, PostgreSQL will return an error:
--  ERROR: invalid input syntax for type integer: "Anytown" 
-- Context: COPY supervisor_salaries, line 2, column id: 
-- "Anytown" 
-- SQL state: 22P04
-- The problem is that your table’s first column is the auto-incrementing id,
--  but your CSV file begins with the text column town. Even if your CSV file
--  had an integer present in its first column, the GENERATED ALWAYS AS
--  IDENTITY keywords would prevent you from adding a value to id. 
COPY supervisor_salaries (town, supervisor, salary)
FROM 'E:\learning_stuff\study\database\demo_code\practical-sql-2-main\practical-sql-2-main\Chapter_05\supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

select * from supervisor_salaries;

DELETE FROM supervisor_salaries;

DROP TABLE supervisor_salaries;

COPY supervisor_salaries (town, supervisor, salary)
FROM 'E:\learning_stuff\study\database\demo_code\practical-sql-2-main\practical-sql-2-main\Chapter_05\supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER)
WHERE town = 'New Brillig';

-- Adding a Value to a Column During Import:
--  What if you know that “Mills” is the name that should be added to the
--  county column during the import, even though that value is missing from the
--  CSV file? One way to modify your import to include the name is by loading
--  your CSV into a temporary table before adding it to supervisors_salary.
DELETE FROM supervisor_salaries;

CREATE TEMPORARY TABLE supervisor_salaries_temp
(
	LIKE supervisor_salaries INCLUDING ALL
);

select * from supervisor_salaries_temp;

COPY supervisor_salaries_temp (town, supervisor, salary)
FROM 'E:\learning_stuff\study\database\demo_code\practical-sql-2-main\practical-sql-2-main\Chapter_05\supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

INSERT INTO supervisor_salaries (town, county, supervisor, salary)
SELECT town, 'Mills', supervisor, salary
FROM supervisor_salaries_temp;

SELECT * FROM supervisor_salaries;


-- Using COPY to Export Data
--  When exporting data with COPY, rather than using FROM to identify the source
--  data, you use TO for the path and name of the output file. You control how
--  much data to export—an entire table, just a few columns, or the results of a
--  query.

COPY us_counties_pop_est_2019
to 'E:\learning_stuff\study\database\demo_code\self-learning\postgreSQL\testing_chapter5.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');



COPY us_counties_pop_est_2019 (county_name, internal_point_lat, internal_point_lon)
to 'E:\learning_stuff\study\database\demo_code\self-learning\postgreSQL\testing_chapter5_some_column.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '?');
