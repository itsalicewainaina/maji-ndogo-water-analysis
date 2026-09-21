# 🚰 Maji Ndogo Water Access & Infrastructure Analysis

### Turning 60,000 survey records into actionable insights on water access and infrastructure
Maji Ndogo faces challenges related to water accessibility, infrastructure reliability, and the distribution of water sources across rural and urban communities.

In this end-to-end analytics project, I analyzed 60,000 survey records using MySQL and Power BI to understand where communities obtain water, how infrastructure conditions vary across locations, and where potential access and reliability challenges exist.

## Project Overview
This project explores how water access differs across provinces and towns, highlighting the relationship between population, source type, and infrastructure reliability. It combines SQL-based data cleaning and analysis with a Power BI dashboard for easy exploration and decision-making.

## What I Did
### SQL & Data Engineering
- Cleaned and audited relational survey data
- Used multi-table JOINs and aggregations to connect population, location, visits, and water-source information
- Applied window functions and filtering to investigate patterns and anomalies
- Built reusable analysis tables and logic for water-source and queue-time evaluation

### Power BI & Analytics
- Built a structured data model connecting demographic, geographic, and infrastructure data
- Developed DAX measures and interactive KPIs
- Created province- and town-level views for exploring water-source and infrastructure patterns

## Key Findings
- 63.85% of the analyzed population lives in rural areas
- Rural communities rely heavily on approximately 10,900 wells and 4,300 shared taps
- Approximately 2,900 broken in-home taps were identified
- Approximately 2,400 unmonitored river sources were identified

These findings highlight differences in water-source dependency and infrastructure conditions across communities and provide a basis for further investigation, maintenance planning, and resource prioritization.

## Project Files
- [data/access_to_basic_services.csv](data/access_to_basic_services.csv) — supplemental access and services dataset
- [sql/md_part1.sql](sql/md_part1.sql) — initial data cleaning and audit queries
- [sql/md_part2.sql](sql/md_part2.sql) — employee and location analysis
- [sql/md_part3.sql](sql/md_part3.sql) — audit discrepancy analysis and quality checks
- [sql/md_part4.sql](sql/md_part4.sql) — final water access analysis and infrastructure prioritization logic

## Outcome
The final Power BI dashboard turns a large relational dataset into an interactive reporting tool that allows users to move from population-level patterns to town-level detail.

- View the dashboard → https://app.powerbi.com/view?r=eyJrIjoiMGJlZGNmZGMtZWQ4MS00ZGMzLThiYTQtM2I4NjNlMTQ2MzJmIiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9
- View the SQL analysis → [sql](sql)
- View the case study → https://docs.google.com/presentation/d/1gK0qHd0UORU4savh08oTgbo3-uhLKaZ49CgCm0NB1qs/edit?usp=sharing
