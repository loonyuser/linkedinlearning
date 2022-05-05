############################################################
############# Creating a Clustered Table ###################
############################################################

## Data source:
## https://www.kaggle.com/datasets/mirosval/personal-cars-classifieds

## Clustered table name: automobiles_clust

## Cluster columns: maker, manufacture_year

SELECT COUNT(*)
FROM `sales_data.automobiles_clust`
WHERE engine_power > 1000

DELETE FROM `sales_data.automobiles_clust`
WHERE engine_power > 1000

CREATE TABLE `sales_data.automobiles`
AS
SELECT * 
FROM `sales_data.automobiles_clust`


############################################################
############# Querying a Clustered Table ###################
############################################################


SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur
FROM `sales_data.automobiles`

SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur
FROM `sales_data.automobiles_clust`

SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles`
WHERE maker = 'bmw'

SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles_clust`
WHERE maker = 'bmw'

SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles_clust`
WHERE manufacture_year = 2010

SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles_clust`
WHERE maker = 'bmw'
	AND manufacture_year = 2010


############################################################
######## Combining Partitioning and Clustering #############
############################################################


CREATE TABLE `sales_data.automobiles_part_clust`
PARTITION BY 
    RANGE_BUCKET(engine_power, GENERATE_ARRAY(1, 1000, 100))
CLUSTER BY maker, manufacture_year
AS
SELECT * 
FROM `sales_data.automobiles`


SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles_part_clust`


SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles_part_clust`
WHERE maker = 'bmw'


SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles_part_clust`
WHERE engine_power > 200
    AND maker = 'bmw'


SELECT maker, model, manufacture_year, 
       engine_displacement, engine_power, price_eur 
FROM `sales_data.automobiles_part_clust`
WHERE engine_power > 200

