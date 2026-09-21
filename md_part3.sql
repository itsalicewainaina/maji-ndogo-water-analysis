USE md_water_services;
Select * 
From visits
limit 15;

-- Query 1: Creating the auditor_report Table

CREATE TABLE `auditor_report` (
    `location_id` VARCHAR(32),
    `type_of_water_source` VARCHAR(64),
    `true_water_source_score` INT DEFAULT NULL,
    `statements` VARCHAR(255)
);
-- Query 2: Joining the Auditor's Report to the Visits Table 
SELECT 
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score,
    visits.location_id AS visit_location,
    visits.record_id
FROM 
    auditor_report
JOIN 
    visits ON auditor_report.location_id = visits.location_id;
    
  --  Query 3 & 4: Fetching the subjective scores from water_quality, Checking Clean Records (No Duplicates)
    SELECT 
    auditor_report.location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS employee_score
FROM 
    auditor_report
JOIN 
    visits ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality ON visits.record_id = water_quality.record_id
    
WHERE 
    visits.visit_count = 1
    AND auditor_report.true_water_source_score = water_quality.subjective_quality_score;
    
    -- Query 5: Isolating the Discrepancies (The 102 Errors)
    SELECT 
    auditor_report.location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS employee_score
FROM 
    auditor_report
JOIN 
    visits ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality ON visits.record_id = water_quality.record_id
WHERE 
    visits.visit_count = 1
    AND auditor_report.true_water_source_score != water_quality.subjective_quality_score;
    
    -- Query 6: Verifying Water Source Type Integrity
    SELECT 
    auditor_report.location_id,
    auditor_report.type_of_water_source AS auditor_source,
    water_source.type_of_water_source AS survey_source,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS employee_score
FROM 
    auditor_report
JOIN 
    visits ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality ON visits.record_id = water_quality.record_id
JOIN 
    water_source ON visits.source_id = water_source.source_id
WHERE 
    visits.visit_count = 1
    AND auditor_report.true_water_source_score != water_quality.subjective_quality_score;
    
    -- Query 7: Identifying Surveyors Responsible for Incorrect Records
    SELECT 
    auditor_report.location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS employee_score
FROM 
    auditor_report
JOIN 
    visits ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality ON visits.record_id = water_quality.record_id
JOIN 
    employee ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE 
    visits.visit_count = 1
    AND auditor_report.true_water_source_score != water_quality.subjective_quality_score;
    
    
    -- Query 8: Saving the Faulty Records as a VIEW
CREATE VIEW Incorrect_records AS (
    SELECT 
        auditor_report.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS employee_score,
        auditor_report.statements AS statements
    FROM 
        auditor_report
    JOIN 
        visits ON auditor_report.location_id = visits.location_id
    JOIN 
        water_quality AS wq ON visits.record_id = wq.record_id
    JOIN 
        employee ON employee.assigned_employee_id = visits.assigned_employee_id
    WHERE 
        visits.visit_count = 1
        AND auditor_report.true_water_source_score != wq.subjective_quality_score
);

Select *
from incorrect_records;

-- Query 9: Counting Mistakes per Employee
SELECT 
    employee_name,
    count(employee_name) AS number_of_mistakes
FROM 
    Incorrect_records
GROUP BY 
    employee_name
ORDER BY 
    number_of_mistakes DESC;
    
-- Query 10: Finding Above-Average Mistakes (Multi-CTE Suspect List)
WITH error_count AS (
    SELECT 
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM 
        Incorrect_records
    GROUP BY 
        employee_name
),
suspect_list AS (
    SELECT 
        employee_name,
        number_of_mistakes
    FROM 
        error_count
    WHERE 
        number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT 
    employee_name,
    location_id,
    statements
FROM 
    Incorrect_records
WHERE 
    employee_name IN (SELECT employee_name FROM suspect_list);

-- Query 11: Filtering Bribe Reports (Searching Statements for "Cash")

WITH error_count AS (
    SELECT 
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM 
        Incorrect_records
    GROUP BY 
        employee_name
),
suspect_list AS (
    SELECT 
        employee_name,
        number_of_mistakes
    FROM 
        error_count
    WHERE 
        number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT 
    employee_name,
    location_id,
    statements
FROM 
    Incorrect_records
WHERE 
    employee_name IN (SELECT employee_name FROM suspect_list)
    AND statements LIKE '%cash%';
    
-- Query 12: Integrity Cross-Check    
SELECT 
    employee_name,
    location_id,
    statements
FROM 
    Incorrect_records
WHERE 
    employee_name NOT IN (
        WITH error_count AS (
            SELECT 
                employee_name,
                COUNT(employee_name) AS number_of_mistakes
            FROM 
                Incorrect_records
            GROUP BY 
                employee_name
        ),
        suspect_list AS (
            SELECT 
                employee_name
            FROM 
                error_count
            WHERE 
                number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
        )
        SELECT employee_name FROM suspect_list
    )
    AND statements LIKE '%cash%';