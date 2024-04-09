/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the additional project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CRIME
-- [Q1] Which was the most frequent crime committed each week? 
-- Hint: Use a subquery and the windows function to find out the number of crimes reported each week and assign a rank. 
Then find the highest crime committed each week

Note: For reference, refer to question number 3 - mls_week-2_gl-beats_solution.sql. 
      You'll get an overview of how to use subquery and windows function from this question */

select  crime_type, week_number, crime_count
from (
	SELECT count(crime_type) as crime_count, crime_type, week_number, dense_rank() over (partition by week_number order by count(crime_type) desc) as crime_Rank
	FROM report_t
	GROUP BY week_number, crime_type) as Ranked_crimes
where crime_Rank = 1

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q2] Is crime more prevalent in areas with a higher population density, fewer police personnel, and a larger precinct area? 
-- Hint: Add the population density, count the total areas, total officers and cases reported in each precinct code and check the trend*/




SELECT COUNT(r.area_code) AS cases_reported,r.area_code,l.population_density,l.area_name,o.precinct_code,o.officer_code, oc.total_officers
FROM 
    report_t AS r 
JOIN 
    location_t AS l ON r.area_code = l.area_code
left JOIN 
    officer_t AS o ON r.officer_code = o.officer_code
join
 (select precinct_code,count(officer_code) as total_officers
from officer_t
group by precinct_code) as oc
ON o.precinct_code = oc.precinct_code
GROUP BY 
    r.area_code, l.population_density, l.area_name, o.precinct_code, o.officer_code
ORDER BY 
    cases_reported DESC;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q3] At what points of the day is the crime rate at its peak? Group this by the type of crime.
-- Hint: 
time day parts
[1] 00:00 to 05:00 = Midnight, 
[2] 05:01 to 12:00 = Morning, 
[3] 12:01 to 18:00 = Afternoon,
[4] 18:01 to 21:00 = Evening, 
[5] 21:00 to 24:00 = Night

Use a subquery, windows function to find the number of crimes reported each week and assign the rank.
Then find out at what points of the day the crime rate is at its peak.
 
 Note: For reference, refer to question number 3 - mls_week-2_gl-beats_solution.sql. 
      You'll get an overview of how to use subquery, windows function from this question */
      
SELECT 
    CrimePeriod,
    CRIME_TYPE,
    WeekNum,
    TotalCrimes,
    ⁠ Rank ⁠ AS Rank1
FROM (
    SELECT 
        CASE 
            WHEN TIME(INCIDENT_TIME) BETWEEN '00:00:00' AND '05:00:00' THEN 'Midnight'
            WHEN TIME(INCIDENT_TIME) BETWEEN '05:01:00' AND '12:00:00' THEN 'Morning'
            WHEN TIME(INCIDENT_TIME) BETWEEN '12:01:00' AND '18:00:00' THEN 'Afternoon'
            WHEN TIME(INCIDENT_TIME) BETWEEN '18:01:00' AND '21:00:00' THEN 'Evening'
            WHEN TIME(INCIDENT_TIME) BETWEEN '21:01:00' AND '23:59:59' THEN 'Night'
        END AS CrimePeriod,
        CRIME_TYPE,
        WEEK_NUMBER AS WeekNum,
        COUNT(*) AS TotalCrimes,
        RANK() OVER (PARTITION BY WEEK_NUMBER  ORDER BY COUNT(CRIME_TYPE) DESC) AS ⁠ Rank ⁠
    FROM report_t
    GROUP BY WEEK_NUMBER, CRIME_TYPE, CrimePeriod
) AS WeeklyCrimeData
WHERE ⁠ Rank ⁠ = 1
ORDER BY WeekNum, CrimePeriod;






-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q4] At what point in the day do more crimes occur in a different locality?
-- Hint: 
time day parts
[1] 00:00 to 05:00 = Midnight, 
[2] 05:01 to 12:00 = Morning, 
[3] 12:01 to 18:00 = Afternoon,
[4] 18:01 to 21:00 = Evening, 
[5] 21:00 to 24:00 = Night

Use a subquery and the windows function to find the number of crimes reported in each area and assign the rank.
Then find out at what point in the day more crimes occur in a different locality.
 
 Note: For reference, refer to question number 3 - mls_week-2_gl-beats_solution.sql. 
      You'll get an overview of how to use subquery, windows function from this question */


    
    
    select freq, time_parts, area_name
    from(SELECT 
    COUNT(time_parts) AS freq,
    time_parts,
    area_name,
    DENSE_RANK() OVER (PARTITION BY area_name ORDER BY COUNT(time_parts) DESC) AS R
FROM 
    (SELECT 
        CASE 
            WHEN incident_time BETWEEN '00:00' AND '05:00' THEN 'Midnight'
            WHEN incident_time BETWEEN '05:01' AND '12:00' THEN 'Morning'
            WHEN incident_time BETWEEN '12:01' AND '18:00' THEN 'Afternoon'
            WHEN incident_time BETWEEN '18:01' AND '21:00' THEN 'Evening'
            WHEN incident_time BETWEEN '21:01' AND '24:00' THEN 'Night'
        END AS time_parts,
        l.area_name,
        r.crime_type
    FROM 
        location_t AS l
    JOIN 
        report_t AS r ON r.area_code = l.area_code
    GROUP BY 
        time_parts, area_name, r.crime_type
    ORDER BY 
        area_name DESC, time_parts) AS subquery
GROUP BY 
    time_parts, area_name)sub_2
    
    where R=1



-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q5] Which age group of people is more likely to fall victim to crimes at certain points in the day?
-- Hint: Age 0 to 12 kids, 13 to 23 teenage, 24 to 35 Middle age, 36 to 55 Adults, 56 to 120 old.*/

SELECT TimeOfDay, AgeGroup, MAX(CrimeCount) AS CrimeCount
FROM (
    SELECT 
        CASE 
            WHEN TIME(INCIDENT_TIME) BETWEEN '00:00:00' AND '05:00:00' THEN 'Midnight'
            WHEN TIME(INCIDENT_TIME) BETWEEN '05:01:00' AND '12:00:00' THEN 'Morning'
            WHEN TIME(INCIDENT_TIME) BETWEEN '12:01:00' AND '18:00:00' THEN 'Afternoon'
            WHEN TIME(INCIDENT_TIME) BETWEEN '18:01:00' AND '21:00:00' THEN 'Evening'
            ELSE 'Night'
        END AS TimeOfDay,
        CASE 
            WHEN VICTIM_AGE BETWEEN 0 AND 12 THEN 'Kids'
            WHEN VICTIM_AGE BETWEEN 13 AND 23 THEN 'Teenage'
            WHEN VICTIM_AGE BETWEEN 24 AND 35 THEN 'Middle age'
            WHEN VICTIM_AGE BETWEEN 36 AND 55 THEN 'Adults'
            ELSE 'Old'
        END AS AgeGroup,
        COUNT(*) AS CrimeCount
    FROM report_t
    JOIN victim_t ON report_t.VICTIM_CODE = victim_t.VICTIM_CODE
    GROUP BY TimeOfDay, AgeGroup
) AS CrimeStats
GROUP BY TimeOfDay, AgeGroup
ORDER BY TimeOfDay, CrimeCount DESC;

/*above code give the output of all the crime count and below on seggeregates the most occuring one in the particular time of day*/

SELECT TimeOfDay, AgeGroup, CrimeCount
FROM (
    SELECT 
        TimeOfDay,
        AgeGroup,
        CrimeCount,
        RANK() OVER (PARTITION BY TimeOfDay ORDER BY CrimeCount DESC) AS Ranking
    FROM (
        SELECT 
            CASE 
                WHEN TIME(INCIDENT_TIME) BETWEEN '00:00:00' AND '05:00:00' THEN 'Midnight'
                WHEN TIME(INCIDENT_TIME) BETWEEN '05:01:00' AND '12:00:00' THEN 'Morning'
                WHEN TIME(INCIDENT_TIME) BETWEEN '12:01:00' AND '18:00:00' THEN 'Afternoon'
                WHEN TIME(INCIDENT_TIME) BETWEEN '18:01:00' AND '21:00:00' THEN 'Evening'
                ELSE 'Night'
            END AS TimeOfDay,
            CASE 
                WHEN VICTIM_AGE BETWEEN 0 AND 12 THEN 'Kids'
                WHEN VICTIM_AGE BETWEEN 13 AND 23 THEN 'Teenage'
                WHEN VICTIM_AGE BETWEEN 24 AND 35 THEN 'Middle age'
                WHEN VICTIM_AGE BETWEEN 36 AND 55 THEN 'Adults'
                ELSE 'Old'
            END AS AgeGroup,
            COUNT(*) AS CrimeCount
        FROM report_t
        JOIN victim_t ON report_t.VICTIM_CODE = victim_t.VICTIM_CODE
        GROUP BY TimeOfDay, AgeGroup
    ) AS CrimeStats
) AS RankedCrimeStats
WHERE Ranking = 1
ORDER BY TimeOfDay, CrimeCount DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q6] What is the status of reported crimes?.
-- Hint: Count the number of crimes for different case statuses. */

SELECT 
    case_status_desc, 
    week_number,
    COUNT(case_status_desc) AS NumberOfCrimes
FROM 
    report_t
GROUP BY 
    case_status_desc, week_number
ORDER BY 
    case_status_desc, week_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q7] Does the existence of CCTV cameras deter crimes from happening?
-- Hint: Check if there is a correlation between the number of CCTVs in each area and the crime rate.*/
	
      SELECT
    area_name,
    cctv_count,
    COUNT( r.area_code) AS num_crimes,
    COUNT( r.area_code) / population_density AS crime_rate_per_cctv,
    r.area_code
FROM
    location_t AS l
 JOIN
    report_t AS r ON l.area_code = r.area_code
GROUP BY
    area_name,r.area_code, cctv_count;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q8] How much footage has been recovered from the CCTV at the crime scene?
-- Hint: Use the case when function, add separately when cctv_flag is true and false and check whether in particular area how many cctv is there,
How much CCTV footage is available? How much CCTV footage is not available? */
SELECT 
    loc.AREA_CODE,
    loc.AREA_NAME,
    loc.CCTV_COUNT,
    SUM(CASE WHEN rep.CCTV_FLAG = 'true' THEN 1 ELSE 0 END) AS FootageAvailable,
    SUM(CASE WHEN rep.CCTV_FLAG = 'false' THEN 1 ELSE 0 END) AS FootageNotAvailable,
    COUNT(rep.REPORT_NO) AS TotalCases, -- Added total count of cases
    SUM(CASE WHEN rep.CCTV_FLAG = 'true' THEN 1 ELSE 0 END) / COUNT(rep.REPORT_NO) * 100 AS PercentageFootageAvailable
FROM 
    location_t loc
LEFT JOIN 
    report_t rep ON loc.AREA_CODE = rep.AREA_CODE
GROUP BY 
    loc.AREA_CODE, loc.AREA_NAME, loc.CCTV_COUNT
ORDER BY 
    loc.AREA_CODE;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q9] Is crime more likely to be committed by relation of victims than strangers?
-- Hint: Find the distinct crime type along with the count of crime when the offender is related to the victim.*/
(SELECT 
    CRIME_TYPE, 
    OFFENDER_RELATION,
    COUNT(*) AS CrimeCount
FROM 
    report_t
WHERE 
    OFFENDER_RELATION <> 'No' 
GROUP BY 
    CRIME_TYPE, OFFENDER_RELATION
ORDER BY 
    CRIME_TYPE, CrimeCount DESC)

UNION ALL

(SELECT 
    CRIME_TYPE,
     OFFENDER_RELATION,
    COUNT(*) AS CrimeCount
FROM 
    report_t
WHERE 
    OFFENDER_RELATION = 'No' 
GROUP BY 
    CRIME_TYPE
ORDER BY 
    CRIME_TYPE, CrimeCount DESC);



-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q10] What are the methods used by the public to report a crime? 
-- Hint: Find the complaint type along with the count of crime.*/
SELECT COMPLAINT_TYPE, COUNT(*) AS CrimeCount
FROM report_t
GROUP BY COMPLAINT_TYPE
ORDER BY CrimeCount DESC;


-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



