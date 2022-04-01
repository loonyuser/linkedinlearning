####################################################################
############### Creating and Working with Views  ###################
####################################################################

###############
### Creating and Querying Views
###############

SELECT institutions.institution_name, institutions.state_name AS home_state,
        locations.branch_name, locations.branch_city
FROM `bigquery-public-data.fdic_banks.institutions` AS institutions
    JOIN `bigquery-public-data.fdic_banks.locations` AS locations
        ON institutions.fdic_certificate_number = locations.fdic_certificate_number


### Save as fdic_bank_locations_view

SELECT institution_name, home_state, branch_city 
FROM `loony-bigquery.loony_university.fdic_bank_locations_view`
WHERE branch_city = 'Singapore'

## Run this query twice
## The second time to show that the result was cached
SELECT institution_name, home_state, COUNT(*) AS branch_count
FROM `loony-bigquery.loony_university.fdic_bank_locations_view`
WHERE branch_city = 'Singapore'
GROUP BY institution_name, home_state


SELECT institutions.institution_name, institutions.state_name AS home_state, 
       COUNT(*) AS branch_count
FROM `bigquery-public-data.fdic_banks.institutions` AS institutions
    JOIN `bigquery-public-data.fdic_banks.locations` AS locations
        ON institutions.fdic_certificate_number = locations.fdic_certificate_number
WHERE locations.branch_city = 'Singapore'
GROUP BY institutions.institution_name, home_state




###############
### Working with Materialized Views
###############



SELECT institutions.institution_name, 
       institutions.state AS home_state,
       COUNT(*) AS branch_count
FROM `loony_university.institutions` AS institutions
    JOIN `loony_university.locations` AS locations
        ON institutions.fdic_certificate_number = locations.fdic_certificate_number
GROUP BY institutions.institution_name, home_state
ORDER BY institutions.institution_name


CREATE MATERIALIZED VIEW 
`loony_university.fdic_bank_branch_counts` AS


SELECT * 
FROM `loony_university.fdic_bank_branch_counts`
WHERE branch_count > 100
ORDER BY branch_count DESC


SELECT institutions.institution_name, 
       institutions.state AS home_state,
       COUNT(*) AS branch_count
FROM `loony_university.institutions` AS institutions
    JOIN `loony_university.locations` AS locations
        ON institutions.fdic_certificate_number = locations.fdic_certificate_number
GROUP BY institutions.institution_name, home_state
HAVING branch_count > 100
ORDER BY branch_count DESC



###############
### Setting up an Authorized View
###############

### Create a dataset called 
loony_analysts

## Same query as used for materialized view

SELECT institutions.institution_name, 
       institutions.state AS home_state,
       COUNT(*) AS branch_count
FROM `loony_university.institutions` AS institutions
    JOIN `loony_university.locations` AS locations
        ON institutions.fdic_certificate_number = locations.fdic_certificate_number
GROUP BY institutions.institution_name, home_state
ORDER BY institutions.institution_name


SELECT * 
FROM `loony_analysts.bank_branch_counts`
WHERE branch_count > 100
ORDER BY branch_count DESC












