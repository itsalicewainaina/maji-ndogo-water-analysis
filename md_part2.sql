Use md_water_services;
SELECT *
FROM employee
LIMIT 5;
-- Change 1
SELECT 
CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email
FROM
employee;

UPDATE employee
SET email = CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');

-- Change 2
SELECT LENGTH
(phone_number)
FROM employee;

SELECT LENGTH(RTRIM(phone_number)) AS phone_length
FROM employee;

UPDATE employee
SET phone_number = (RTRIM(phone_number));

-- Change 3
SELECT town_name,
COUNT(assigned_employee_id) AS employee_count
FROM employee
GROUP BY town_name;

SELECT DISTINCT position
FROM employee;

-- The top 3 Field Surveyor
SELECT
    e.assigned_employee_id,
    e.employee_name,
    e.email,
    e.phone_number,
    COUNT(v.visit_count) AS number_of_visits,
    e.position
FROM employee e
JOIN visits v
    ON e.assigned_employee_id = v.assigned_employee_id
WHERE e.position = 'Field Surveyor'
GROUP BY
	e.assigned_employee_id,
    e.employee_name,
    e.position
ORDER BY number_of_visits DESC
LIMIT 3;

-- Analysing Locations
-- Records per town
SELECT 
l.town_name,
COUNT(v.record_id) AS records_per_town
FROM location l 
JOIN visits v
   ON l.location_id = v.location_id
GROUP BY l.town_name
order by records_per_town DESC;

-- Records per province
SELECT 
l.province_name,
COUNT(v.record_id) AS records_per_province
FROM location l 
JOIN visits v
   ON l.location_id = v.location_id
GROUP BY l.province_name
order by records_per_province DESC;

-- Records per location type
SELECT 
l.location_type,
COUNT(v.record_id) AS records_per_location_type
FROM location l 
JOIN visits v
   ON l.location_id = v.location_id
GROUP BY l.location_type;

-- SQL the powerful calculator
SELECT
38741/(21405+38741) * 100;

-- Exploring the water_source table
SELECT *
FROM water_source
Limit 15;


-- How many people did we survey in total? 
SELECT 
sum(number_of_people_served) as total_people_surveyed
From water_source;

-- How many wells, taps and rivers are there?
SELECT 
type_of_water_source,
COUNT(*) AS number_of_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY 
    type_of_water_source ASC;

-- How many people share particular types of water sources on average?
SELECT 
type_of_water_source,
round(avg(number_of_people_served),0) AS average_people_served
FROM water_source
GROUP BY type_of_water_source;

--  How many people are getting water from each type of source? ( Represented in percentage format)
SELECT 
type_of_water_source,
Round(SUM(number_of_people_served)/27628140 * 100,0) AS total_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY total_people_served DESC;

-- Window Functions
SELECT 
type_of_water_source,
SUM(number_of_people_served) AS total_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY total_people_served DESC;


-- QUIZ QUERIES
SELECT location_id, SUM(visit_count) AS total_visits, CASE WHEN time_in_queue <= 30 THEN 'Acceptable' ELSE 'Too Long' END AS queue_status FROM visits GROUP BY location_id, queue_status;

SELECT
    l.province_name,
    COUNT(DISTINCT ws.source_id) AS total_water_sources
FROM water_source ws
JOIN visits v
    ON ws.source_id = v.source_id
JOIN location l
    ON v.location_id = l.location_id
GROUP BY
    l.province_name
ORDER BY
    total_water_sources DESC;
    
SELECT DISTINCT
      employee_name,
      CONCAT(LEFT(employee_name, 2), '-', RIGHT(phone_number, 2), '-', LEFT(province_name, 3)) AS custom_id
FROM employee
WHERE employee_name = "Hasani Pili";

SELECT
    HOUR(time_of_record) AS hour_of_day,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue ELSE NULL END), 0) AS Sunday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue ELSE NULL END), 0) AS Monday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue ELSE NULL END), 0) AS Tuesday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue ELSE NULL END), 0) AS Wednesday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue ELSE NULL END), 0) AS Thursday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue ELSE NULL END), 0) AS Friday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue ELSE NULL END), 0) AS Saturday
FROM 
    visits
WHERE 
    time_in_queue != 0 -- Excludes visits where there was no queue
GROUP BY 
    hour_of_day
ORDER BY 
    hour_of_day;
