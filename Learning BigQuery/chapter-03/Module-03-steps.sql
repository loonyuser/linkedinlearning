####################################################################
########## Executing Queries and Visualizing Results  ##############
####################################################################


###############
### Accessing Public Datasets
###############

## GCP public datasets project:
#####  bigquery-public-data

## Access the following dataset in the bigquery-public-data project:
#####  world_bank_global_population
## View this table:
#####  population_by_country



###############
### Caching in BigQuery
###############

SELECT * 
FROM `bigquery-public-data.world_bank_global_population.population_by_country`


SELECT country, country_code, year_1960, year_2018 
FROM `bigquery-public-data.world_bank_global_population.population_by_country`
ORDER BY year_2018 DESC



SELECT country, country_code, year_1960, year_2018, (year_2018-year_1960) AS abs_change
FROM `bigquery-public-data.world_bank_global_population.population_by_country`
ORDER BY abs_change DESC


SELECT country, (year_2018-year_1960) AS abs_change
FROM `bigquery-public-data.world_bank_global_population.population_by_country`
ORDER BY abs_change DESC



###############
### Creating an External Table and Visualizing Data with Data Studio 
###############


## Upload the "Honey Production.xlsx" file from the course materials
## Name the external table created honey_production_usa




###############
### Generating and Visualizing Geospatial Data 
###############

SELECT ST_GeogPoint(longitude, latitude) AS geog, population, median_house_value 
FROM `loony-bigquery.loony_university.housing_data`

Domain: 1, 10000, 100000, 1000000
Range: 1, 10, 100, 1000

