-- ========================================================================================
-- SQL JOB MARKET ANALYSIS
-- Dataset: jobs_data
-- Skills used: SELECT, WHERE, GROUP BY, HAVING, CASE, SUBQUERY, JOIN, AGGREGATE FUNCTIONS
-- ========================================================================================


-- ========================
-- BASIC DATA EXPLORATION
-- ========================

-- Preview first 10 records
SELECT *
FROM jobs_data
LIMIT 10;

-- Count job postings by job title
SELECT job_title_short,
COUNT(*) AS total_jobs
FROM jobs_data
GROUP BY job_title_short
ORDER BY total_jobs DESC;

-- Count job postings by country
SELECT job_country,
COUNT(*) AS total_jobs
FROM jobs_data
GROUP BY job_country
ORDER BY total_jobs DESC;

-- ================
-- SALARY ANALYSIS
-- ================

-- Average salary by job title
SELECT job_title_short,
CAST(AVG(salary_year_avg) AS INT) AS avg_salary
FROM jobs_data
GROUP BY job_title_short
ORDER BY avg_salary DESC;

-- Highest paying jobs above 150k
SELECT job_title_short,
CAST(salary_year_avg AS INT) AS salary
FROM jobs_data
WHERE salary_year_avg > 150000
ORDER BY salary DESC;

-- Highest paying job titles in India
SELECT job_title_short,
CAST(AVG(salary_year_avg) AS INT) AS avg_salary
FROM jobs_data
WHERE job_country = 'India'
GROUP BY job_title_short
ORDER BY avg_salary DESC;

-- ==============================
-- COUNTRY LEVEL SALARY ANALYSIS
-- ==============================

-- Average salary by country
SELECT job_country,
CAST(AVG(salary_year_avg) AS INT) AS avg_salary
FROM jobs_data
GROUP BY job_country
ORDER BY avg_salary DESC;

-- Countries with at least 20 job postings
SELECT job_country,
COUNT(*) AS total_jobs
FROM jobs_data
GROUP BY job_country
HAVING COUNT(*) >= 20
ORDER BY total_jobs DESC;

-- ======================
-- JOB PLATFORM ANALYSIS
-- ======================

-- Platform posting the most jobs
SELECT REPLACE(job_via,'via ','') AS platform,
COUNT(*) AS total_jobs
FROM jobs_data
GROUP BY job_via
ORDER BY total_jobs DESC;

-- ========================
-- CASE STATEMENT PRACTICE
-- ========================

-- Salary band classification for individual jobs
SELECT salary_band,
COUNT(*) AS job_count
FROM
(
SELECT
CASE
WHEN salary_year_avg > 150000 THEN 'High'
WHEN salary_year_avg > 80000 THEN 'Medium'
ELSE 'Low'
END AS salary_band
FROM jobs_data
WHERE salary_year_avg IS NOT NULL
)
GROUP BY salary_band;

-- Salary band by job title
SELECT job_title_short,
CAST(AVG(salary_year_avg) AS INT) AS avg_salary,
CASE
WHEN AVG(salary_year_avg) > 150000 THEN 'High'
WHEN AVG(salary_year_avg) > 100000 THEN 'Medium'
ELSE 'Low'
END AS salary_band
FROM jobs_data
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
ORDER BY avg_salary DESC;

-- ==================
-- SUBQUERY PRACTICE
-- ==================

-- Job titles earning above overall average salary
SELECT job_title_short,
CAST(AVG(salary_year_avg) AS INT) AS avg_salary
FROM jobs_data
GROUP BY job_title_short
HAVING AVG(salary_year_avg) >
(
SELECT AVG(salary_year_avg)
FROM jobs_data
)
ORDER BY avg_salary DESC;

-- ==================================
-- JOIN PRACTICE
-- Creating department mapping table
-- ==================================

DROP TABLE IF EXISTS company_info;

CREATE TABLE company_info (
job_title_short TEXT,
department TEXT
);

INSERT INTO company_info VALUES ('Data Scientist','AI');
INSERT INTO company_info VALUES ('Data Engineer','Engineering');
INSERT INTO company_info VALUES ('Data Analyst','Analytics');
INSERT INTO company_info VALUES ('Senior Data Analyst','Analytics');
INSERT INTO company_info VALUES ('Machine Learning Engineer','AI');

-- ==============
-- JOIN ANALYSIS
-- ==============

-- View job title with department
SELECT jobs_data.job_title_short,
company_info.department
FROM jobs_data
JOIN company_info
ON jobs_data.job_title_short = company_info.job_title_short;

-- Average salary by department
SELECT company_info.department,
CAST(AVG(jobs_data.salary_year_avg) AS INT) AS avg_salary
FROM jobs_data
JOIN company_info
ON jobs_data.job_title_short = company_info.job_title_short
GROUP BY company_info.department
ORDER BY avg_salary DESC;

-- Job count by department
SELECT company_info.department,
COUNT(*) AS total_jobs
FROM jobs_data
JOIN company_info
ON jobs_data.job_title_short = company_info.job_title_short
GROUP BY company_info.department
ORDER BY total_jobs DESC;

-- Jobs above 150k salary by department
SELECT company_info.department,
COUNT(*) AS job_count
FROM jobs_data
JOIN company_info
ON jobs_data.job_title_short = company_info.job_title_short
WHERE jobs_data.salary_year_avg > 150000
GROUP BY company_info.department
ORDER BY job_count DESC;

-- Average salary by department with salary band
SELECT company_info.department,
'$' || printf('%, d',
CAST(AVG(jobs_data.salary_year_avg) AS INT)) AS avg_salary,
CASE
WHEN AVG(jobs_data.salary_year_avg) > 135000 THEN 'High'
WHEN AVG(jobs_data.salary_year_avg) > 130000 THEN 'Medium'
ELSE 'Low'
END AS salary_band
FROM jobs_data
JOIN company_info
ON jobs_data.job_title_short = company_info.job_title_short
GROUP BY company_info.department
ORDER BY AVG(jobs_data.salary_year_avg) DESC;

-- Departments with more than 5000 jobs
SELECT company_info.department,
COUNT(*) AS job_count
FROM jobs_data
JOIN company_info
ON jobs_data.job_title_short = company_info.job_title_short
GROUP BY company_info.department
HAVING COUNT(*) > 5000
ORDER BY job_count DESC;