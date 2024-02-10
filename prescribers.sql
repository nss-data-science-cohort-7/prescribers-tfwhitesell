-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? 
-- 	Report the npi and the total number of claims.
SELECT p1.npi, p2.nppes_provider_last_org_name, p2.nppes_provider_first_name, SUM(total_claim_count) AS total_claims
FROM prescription AS p1
LEFT JOIN prescriber AS p2
ON p1.npi = p2.npi
GROUP BY 1, 2, 3
ORDER BY 4 DESC
LIMIT 1;
-- Bruce Pendley (npi 1881634483) had the highest number of claims across all drugs.
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, 
-- 	specialty_description, and the total number of claims.
SELECT p1.npi, 
	p2.nppes_provider_first_name, 
	p2.nppes_provider_last_org_name, 
	p2.specialty_description, 
	SUM(total_claim_count) AS total_claims
FROM prescription AS p1
LEFT JOIN prescriber AS p2
ON p1.npi = p2.npi
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC
LIMIT 1;
-- Bruce Pendley's specialty description is Family Practice.

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT p2.specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescription AS p1
LEFT JOIN prescriber AS p2
ON p1.npi = p2.npi
GROUP BY 1
ORDER BY 2 DESC;
-- Family practice prescribers had the most total claims followed by Internal Medicine.

--     b. Which specialty had the most total number of claims for opioids?
SELECT p2.specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescription AS p1
LEFT JOIN prescriber AS p2
ON p1.npi = p2.npi
LEFT JOIN drug AS d
ON p1.drug_name = d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY 1
ORDER BY 2 DESC;
-- Nurse Practitioner is the specialty with the most total claims for opioids.

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated 
-- 	prescriptions in the prescription table?
SELECT specialty_description
-- 	, COUNT(drug_name)
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING(npi)
GROUP BY 1
HAVING COUNT(drug_name) = 0;
-- There are 15 specialties with no associated prescriptions.

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the 
-- 	percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- new approach: use CASE statements to define new columns for non-opioid and opioid claims in CTE
-- then do math in main query
WITH claims AS (
	SELECT p1.specialty_description,
		CASE WHEN opioid_drug_flag = 'Y'
				THEN total_claim_count
			ELSE 0 END AS opioid_claims,
		CASE WHEN opioid_drug_flag = 'N'
				THEN total_claim_count
			ELSE 0 END AS non_opioid_claims
	FROM prescriber AS p1
	INNER JOIN prescription AS p2
		ON p1.npi = p2.npi
	INNER JOIN drug AS d
		ON p2.drug_name = d.drug_name
)

SELECT specialty_description,
	SUM(opioid_claims) AS opioid_claims,
	SUM(non_opioid_claims) AS non_opioid_claims,
	ROUND((SUM(opioid_claims * 1.0) / (SUM(opioid_claims) + SUM(non_opioid_claims)) * 100), 2) AS percent_opioid
FROM claims
GROUP BY 1
ORDER BY 4 DESC;
-- Case Manager/Care Coordinator is the specialty with the highest percentage of opioid claims at 72%, but that specialty only has 50
-- prescription claims total. The highest percentage of opioid claims for a specialty with a significant number of claims is
-- Intervention Pain Management at 59.47%.

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT d.generic_name, SUM(total_drug_cost) AS total_drug_cost
FROM drug AS d
LEFT JOIN prescription AS p
ON d.drug_name = p.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
-- Insulin Glargine, HUM.Rec.Anlog has the highest total drug cost at $104264066.35.

--     b. Which drug (generic_name) has the highest total cost per day? **Bonus: Round your cost per day column to 2 decimal 
-- 	places. Google ROUND to see how this works.**
SELECT d.generic_name, ROUND(SUM(total_drug_cost) / SUM(total_day_supply), 2) AS cost_per_day
FROM drug AS d
LEFT JOIN prescription AS p
ON d.drug_name = p.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
-- C1 Esterase Inhibitor had the highest total cost per day at $3495.22.

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for 
-- 	drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and 
-- 	says 'neither' for all other drugs.
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y'
			THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y'
			THEN 'antibiotic'
		ELSE 'neither' END AS drug_type
FROM drug
GROUP BY 1, 2
ORDER BY 2 DESC;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids 
-- 	or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
WITH drug_flag AS (
	SELECT drug_name,
		CASE WHEN opioid_drug_flag = 'Y'
				THEN 'opioid'
			WHEN antibiotic_drug_flag = 'Y'
				THEN 'antibiotic'
			ELSE 'neither' END AS drug_type
	FROM drug
	GROUP BY 1, 2
)

SELECT d.drug_type,
	SUM(CAST(p.total_drug_cost AS MONEY)) AS total_drug_cost
FROM drug_flag AS d
LEFT JOIN prescription AS p
	ON d.drug_name = p.drug_name
GROUP BY 1;
-- Total cost of opioid prescriptions is approximately 3 times the total cost of antibiotic prescriptions.

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT state,
	COUNT(cbsa) AS num_cbsa
FROM fips_county
INNER JOIN cbsa
USING(fipscounty)
WHERE state = 'TN'
GROUP BY 1;
-- There are 42 CBSAs in Tennessee

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
(SELECT cbsaname,
	SUM(population) AS total_cbsa_population
FROM cbsa
INNER JOIN population
USING(fipscounty)
GROUP BY 1
ORDER BY 2
LIMIT 1)

UNION

(SELECT cbsaname,
	SUM(population) AS total_cbsa_population
FROM cbsa
INNER JOIN population
USING(fipscounty)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1);
-- Morristown, TN has the smallest CBSA population.
-- Nashville-Davidson-Murfreesboro-Franklin, TN has the largest CBSA population.

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county,
	population
FROM fips_county AS f
INNER JOIN population AS p
USING(fipscounty)
WHERE fipscounty NOT IN (
	SELECT fipscounty
	FROM cbsa)
ORDER BY 2 DESC
LIMIT 1;
-- The largest county by population not in a CBSA is Sevier County.

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name,
	total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT p.drug_name,
	total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y'
			THEN 'Y'
		ELSE 'N' END AS opioid_indicator
FROM prescription AS p
INNER JOIN drug AS d
	ON p.drug_name = d.drug_name
WHERE total_claim_count >= 3000;

--     c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) AS provider_name,
	p.drug_name,
	total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y'
			THEN 'Y'
		ELSE 'N' END AS opioid_indicator
FROM prescription AS p
INNER JOIN drug AS d
	ON p.drug_name = d.drug_name
INNER JOIN prescriber AS p2
	ON p.npi = p2.npi
WHERE total_claim_count >= 3000
ORDER BY 1;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of 
-- 	claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain 
-- 	Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). 
-- 	**Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't 
-- 	need the claims numbers yet.

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber 
-- 	had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.
-- 	Hint - Google the COALESCE function.