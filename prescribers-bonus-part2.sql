-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT DISTINCT npi
FROM prescriber

EXCEPT

SELECT DISTINCT npi
FROM prescription;
-- 4458 prescribers who are not in the prescription table (0.0.116 seconds to run)

SELECT DISTINCT npi
FROM prescriber
WHERE npi NOT IN (
	SELECT DISTINCT npi
	FROM prescription);
-- same result (4458), runtime 0.094 seconds

WITH prescription_npi AS (
	SELECT npi
	FROM prescription
	GROUP BY 1
)

SELECT npi
FROM prescriber
WHERE npi NOT IN (
	SELECT npi
	FROM prescription_npi
);
-- same result, runtime 0.104 seconds

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT generic_name,
	SUM(total_claim_count) AS total_claims
FROM drug AS d
INNER JOIN prescription AS p1
	ON d.drug_name = p1.drug_name
INNER JOIN prescriber AS p2
	ON p1.npi = p2.npi
WHERE specialty_description = 'Family Practice'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT generic_name,
	SUM(total_claim_count) AS total_claims
FROM drug AS d
INNER JOIN prescription AS p1
	ON d.drug_name = p1.drug_name
INNER JOIN prescriber AS p2
	ON p1.npi = p2.npi
WHERE specialty_description = 'Cardiology'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? 
-- 	Combine what you did for parts a and b into a single query to answer this question.
SELECT specialty_description,
	generic_name,
	SUM(total_claim_count) AS total_claims
FROM drug AS d
INNER JOIN prescription AS p1
	ON d.drug_name = p1.drug_name
INNER JOIN prescriber AS p2
	ON p1.npi = p2.npi
WHERE specialty_description IN ('Cardiology', 'Family Practice')
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;
-- not sure this is the intended answer, try again with a window function

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) 
-- 	across all drugs. Report the npi, the total number of claims, and include a column showing the city.
    
--     b. Now, report the same for Memphis.
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, 
-- 	its population, and the percentage of the total population of Tennessee that is contained in that county.