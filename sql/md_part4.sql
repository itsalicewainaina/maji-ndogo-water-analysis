use md_water_services;

-- Query 1: Initial Cross-Table Join (Slides 4–9)
SELECT 
    location.province_name, 
    location.town_name, 
    water_source.type_of_water_source, 
    water_source.number_of_people_served, 
    visits.visit_count, 
    visits.location_id
FROM 
    visits
INNER JOIN 
    water_source ON visits.source_id = water_source.source_id
INNER JOIN 
    location ON visits.location_id = location.location_id
WHERE 
    visits.visit_count = 1;
    
    
-- Query 2: Incorporating Queue Times and Well Pollution (Slides 10–11)
SELECT
    water_source.type_of_water_source, 
    location.town_name, 
    location.province_name, 
    location.location_type, 
    water_source.number_of_people_served, 
    visits.time_in_queue, 
    well_pollution.results
FROM 
    visits
LEFT JOIN 
    well_pollution ON well_pollution.source_id = visits.source_id
INNER JOIN 
    location ON location.location_id = visits.location_id
INNER JOIN 
    water_source ON water_source.source_id = visits.source_id
WHERE 
    visits.visit_count = 1;
    
-- Query 3: Saving the Join as a VIEW (Slide 13)
CREATE VIEW combined_analysis_table AS 
SELECT
    water_source.type_of_water_source AS source_type, 
    location.town_name, 
    location.province_name, 
    location.location_type, 
    water_source.number_of_people_served AS people_served, 
    visits.time_in_queue, 
    well_pollution.results
FROM 
    visits
LEFT JOIN 
    well_pollution ON well_pollution.source_id = visits.source_id
INNER JOIN 
    location ON location.location_id = visits.location_id
INNER JOIN 
    water_source ON water_source.source_id = visits.source_id
WHERE 
    visits.visit_count = 1;
    
-- Query 4: Provincial Water Access Percentages (Slides 14–16)
WITH province_totals AS (
    SELECT
        province_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        combined_analysis_table
    GROUP BY 
        province_name
)
SELECT
    ct.province_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
    combined_analysis_table ct
JOIN
    province_totals pt ON ct.province_name = pt.province_name
GROUP BY
    ct.province_name
ORDER BY
    ct.province_name;

-- Query 5: Town Water Aggregation Temporary Table (Slides 21–22)
CREATE TEMPORARY TABLE town_aggregated_water_access AS
WITH town_totals AS (
    SELECT 
        province_name, 
        town_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        combined_analysis_table
    GROUP BY 
        province_name, town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
    combined_analysis_table ct
JOIN
    town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY
    ct.province_name, ct.town_name;

-- Query 6: Town Broken Tap Ratio (Slide 23)
SELECT 
    province_name, 
    town_name, 
    ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100, 0) AS Pct_broken_taps
FROM 
    town_aggregated_water_access
ORDER BY 
    Pct_broken_taps DESC;

-- Query 7: Creating the Project_progress Table (Slides 28–29)
CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
);

-- Query 8: Crafting the Upgrade Logic (Slides 33–44)

SELECT 
    location.address, 
    location.town_name, 
    location.province_name, 
    water_source.source_id, 
    water_source.type_of_water_source, 
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter' 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter' 
        WHEN type_of_water_source = 'river' THEN 'Drill well' 
        WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 
            THEN CONCAT("Install ", FLOOR(visits.time_in_queue / 30), " taps nearby") 
        WHEN type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure' 
        ELSE NULL
    END AS Improvement 
FROM 
    water_source 
LEFT JOIN 
    well_pollution ON water_source.source_id = well_pollution.source_id 
INNER JOIN 
    visits ON water_source.source_id = visits.source_id 
INNER JOIN 
    location ON location.location_id = visits.location_id 
WHERE 
    visits.visit_count = 1 
    AND (well_pollution.results != 'Clean'
         OR type_of_water_source IN ('tap_in_home_broken', 'river') 
         OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30));
         
-- Query 9: Populating the Project Progress Tracker (Slide 46)
INSERT INTO Project_progress (source_id, Address, Town, Province, Source_type, Improvement)
SELECT 
    water_source.source_id, 
    location.address, 
    location.town_name, 
    location.province_name, 
    water_source.type_of_water_source, 
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter' 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter' 
        WHEN type_of_water_source = 'river' THEN 'Drill well' 
        WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 
            THEN CONCAT("Install ", FLOOR(visits.time_in_queue / 30), " taps nearby") 
        WHEN type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure' 
        ELSE NULL
    END AS Improvement 
FROM 
    water_source 
LEFT JOIN 
    well_pollution ON water_source.source_id = well_pollution.source_id 
INNER JOIN 
    visits ON water_source.source_id = visits.source_id 
INNER JOIN 
    location ON location.location_id = visits.location_id 
WHERE  visits.visit_count = 1 
    and (well_pollution.results != 'Clean'
         OR type_of_water_source IN ('tap_in_home_broken', 'river') 
         OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30));
         
SELECT *
FROM project_progress;

-- Calculate the percentage of river water dependency per province
WITH province_totals AS (
    SELECT
        province_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        combined_analysis_table
    GROUP BY 
        province_name
)
SELECT
    ct.province_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river_pct
FROM
    combined_analysis_table ct
JOIN
    province_totals pt ON ct.province_name = pt.province_name
GROUP BY
    ct.province_name
ORDER BY
    river_pct DESC;
    
-- 
SELECT
project_progress.Project_id, 
project_progress.Town, 
project_progress.Province, 
project_progress.Source_type, 
project_progress.Improvement,
Water_source.number_of_people_served,
RANK() OVER(PARTITION BY Province ORDER BY number_of_people_served)
FROM  project_progress 
JOIN water_source 
ON water_source.source_id = project_progress.source_id
WHERE Improvement = "Drill Well"
ORDER BY Province DESC, number_of_people_served;

-- Select towns and sum their total home tap access (working + broken)

CREATE TEMPORARY TABLE town_aggregated_water_access AS
WITH town_totals AS (
    SELECT 
        province_name, 
        town_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        combined_analysis_table
    GROUP BY 
        province_name, town_name
)
SELECT 
    province_name, 
    town_name, 
    (tap_in_home + tap_in_home_broken) AS total_home_tap_access
FROM 
    town_aggregated_water_access
ORDER BY 
    province_name, 
    total_home_tap_access DESC;
    
SELECT 
    province_name,
    town_name,
    ROUND(AVG(time_in_queue)) AS avg_wait_time
FROM 
    combined_analysis_table
WHERE 
    source_type = 'shared_tap'
GROUP BY 
    province_name, town_name
ORDER BY 
    avg_wait_time DESC;
    
CREATE TEMPORARY TABLE town_aggregated_water_access AS
WITH town_totals AS (
    SELECT 
        province_name, 
        town_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        combined_analysis_table
    GROUP BY 
        province_name, town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' AND results != "Clean"THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
    combined_analysis_table ct
JOIN
    town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY
    ct.province_name, ct.town_name;
    
SELECT town_name, river 
FROM town_aggregated_water_access 
WHERE province_name = 'Amanzi' 
ORDER BY river DESC;   


Select 
count(*) AS total_uv_filters
from project_progress
where Improvement like "%UV%";

SELECT COUNT(*) 
FROM Project_progress 
WHERE Improvement = 'Install UV and RO filter';