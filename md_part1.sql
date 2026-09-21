USE md_water_services;

CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);
-- 1. Turn off safe updates temporarily
SET SQL_SAFE_UPDATES = 0;

-- 2. Run your updates on the copy table
UPDATE well_pollution_copy 
SET description = 'Bacteria: E. coli' 
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution_copy 
SET description = 'Bacteria: Giardia Lamblia' 
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution_copy 
SET results = 'Contaminated:Biological' 
WHERE biological > 0.01 AND results = 'Clean';

-- 3. Turn safety back on when finished
SET SQL_SAFE_UPDATES = 1;

SELECT
*
FROM
well_pollution
WHERE
description LIKE "Clean_%"
OR (results= "Clean"AND biological>0.01);

-- Question 1
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;

-- Question 2
SELECT employee_name, phone_number, position
FROM employee
WHERE position = 'Field Surveyor'
  AND (phone_number LIKE '%86%' OR phone_number LIKE '%11%')
  AND (employee_name LIKE 'A%' OR employee_name LIKE 'M%' 
       OR employee_name LIKE '% A%' OR employee_name LIKE '% M%');

-- Question 3
SELECT * FROM data_dictionary WHERE column_name = 'number_of_people_served';
SELECT SUM(number_of_people_served) AS total_population
FROM water_source;

-- Question 4
SELECT DISTINCT description
FROM well_pollution
WHERE biological >= 400
AND description LIKE '%Bacteria%'

-- Question 7
SELECT employee_name, phone_number
FROM employee
WHERE position = 'Micro Biologist' OR position LIKE '%Microbiologist%';

-- Question 8
SELECT
    l.location_type,
    COUNT(*) AS occurrences
FROM visits v
JOIN location l ON v.location_id = l.location_id
WHERE v.time_in_queue >= 538
GROUP BY l.location_type;

SELECT l.location_type, COUNT(*) AS count
FROM visits v
JOIN location l ON v.location_id = l.location_id
WHERE v.time_in_queue >= 538
GROUP BY l.location_type;

-- Question 9
SELECT DISTINCT description
FROM well_pollution 
WHERE description LIKE '%Virus%' OR description LIKE '%virus%';

-- Question 10
SELECT *
FROM well_pollution
WHERE description IN ('Parasite: Cryptosporidium', 'biologically contaminated')
   OR (results = 'Clean' AND biological > 0.01);
   
-- Question 11
SELECT employee_name, position, province_name
FROM employee
WHERE position = 'Field Surveyor'
  AND province_name = 'Kilimani';
  
  -- Question 12
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%'
  AND biological > 0.01;
  
-- Question 13
SELECT employee_name, phone_number, email
FROM employee
WHERE position = 'Data Scientist';

-- Question 15
SELECT source_id, number_of_people_served
FROM water_source
ORDER BY number_of_people_served DESC
LIMIT 1;

-- Question 16
SELECT COUNT(DISTINCT province_name) AS number_of_provinces
FROM location;

-- Question 17
SELECT source_id
FROM md_water_services.visits
WHERE time_of_record BETWEEN '2021-01-15' AND '2021-01-18';

-- Question 18
SELECT address 
FROM employee 
WHERE employee_name = 'Bello Azibo';

-- Question 20
SELECT COUNT(*) 
FROM water_source ws
LEFT JOIN visits v ON ws.source_id = v.source_id
WHERE v.source_id IS NULL;


  
