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

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the 
-- 	percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal 
-- 	places. Google ROUND to see how this works.**

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for 
-- 	drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and 
-- 	says 'neither' for all other drugs.

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids 
-- 	or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.