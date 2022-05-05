############################################################
############ Creating a Dataset and Table ##################
############################################################


## Dataset name: sales_data
## Table name: supermarket_sales


SELECT *
FROM `loony-bigquery.sales_data.supermarket_sales`


############################################################
############ Creating a Partitioned Table ##################
############################################################

## Consider Date as a partition column
SELECT MAX(Date), MIN(Date)
FROM `loony-bigquery.sales_data.supermarket_sales`

## Look at the size of the results - this will be the size of 
##		a partitioned table we will soon create
SELECT Branch, City, Customer_type, Product_line, Unit_price, 
       Quantity, Tax_5_, Total, Date, Time, Payment, gross_income
FROM `loony-bigquery.sales_data.supermarket_sales`

## Create a table partitioned by Date
CREATE TABLE `loony-bigquery.sales_data.supermarket_sales_part`
PARTITION BY Date
AS
SELECT Branch, City, Customer_type, Product_line, Unit_price, 
       Quantity, Tax_5_, Total, Date, Time, Payment, gross_income
FROM `loony-bigquery.sales_data.supermarket_sales`

 
## Check the size of the data processed for this query
## The entire table is scanned
SELECT Branch, City, Customer_type, Product_line, Unit_price, 
       Quantity, Tax_5_, Total, Date, Time, Payment, gross_income
FROM `loony-bigquery.sales_data.supermarket_sales`
WHERE Date BETWEEN '2019-02-01' AND '2019-02-28'


## Run an identical query against the partitioned table
## the amount of data processed is less than 1/3rd of the full table
SELECT Branch, City, Customer_type, Product_line, Unit_price, 
       Quantity, Tax_5_, Total, Date, Time, Payment, gross_income
FROM `loony-bigquery.sales_data.supermarket_sales_part`
WHERE Date BETWEEN '2019-02-01' AND '2019-02-28'

## Querying based on a non-partitioned column does involves a full scan
SELECT Branch, City, Customer_type, Product_line, Unit_price, 
       Quantity, Tax_5_, Total, Date, Time, Payment, gross_income
FROM `loony-bigquery.sales_data.supermarket_sales_part`
WHERE Payment = 'Cash'


############################################################
########### Partitioning on Integer Field #################
############################################################


## Create a table based on an integer partition column
## In the options, we leave out the expiration - that is only
##		supported for date-based partitions
CREATE TABLE `sales_data.customers` (id INT64, 
                                     firstname STRING, 
                                     lastname STRING,
                                     city STRING,
                                     level INT64)
PARTITION BY 
    RANGE_BUCKET(level, GENERATE_ARRAY(1, 10, 5))
OPTIONS(
  require_partition_filter=true
)


INSERT INTO `sales_data.customers` (id, firstname, lastname, city, level)
VALUES
(1, 'Lucy', 'Diamond', 'Liverpool', 2),
(2, 'Kyle', 'Weissman', 'Liverpool', 4),
(3, 'Sven', 'Frederiksson', 'Liverpool', 7),
(4, 'Elaine', 'Wood', 'Liverpool', 8),
(5, 'Reggie', 'Sellers', 'Newcastle', 3),
(6, 'Fatima', 'Ibrahim', 'Newcastle', 6),
(7, 'Eva', 'Ivanova', 'Newcastle', 9),
(8, 'Andy', 'Shearer', 'Newcastle', 7)

## This does not reference the level column, so is not permitted
SELECT * FROM `sales_data.customers`

SELECT * FROM `sales_data.customers`
WHERE level  = 3

SELECT * FROM `sales_data.customers`
WHERE level > 5

## This is also not permitted
SELECT * FROM `sales_data.customers`
WHERE city = 'Liverpool'

DROP TABLE `sales_data.customers`


############################################################
########### Partitioning on Ingestion Time #################
############################################################


CREATE TABLE `sales_data.customers` (id INT64, 
                                     firstname STRING, 
                                     lastname STRING,
                                     city STRING,
                                     level INT64)
PARTITION BY _PARTITIONDATE
OPTIONS(
  partition_expiration_days=30
)



INSERT INTO `sales_data.customers` (id, firstname, lastname, city, level)
VALUES
(1, 'Lucy', 'Diamond', 'Liverpool', 2),
(2, 'Kyle', 'Weissman', 'Liverpool', 4),
(3, 'Sven', 'Frederiksson', 'Liverpool', 7),
(4, 'Elaine', 'Wood', 'Liverpool', 8)


INSERT INTO `sales_data.customers` (id, firstname, lastname, city, level)
VALUES
(5, 'Reggie', 'Sellers', 'Newcastle', 3),
(6, 'Fatima', 'Ibrahim', 'Newcastle', 6),
(7, 'Eva', 'Ivanova', 'Newcastle', 9),
(8, 'Andy', 'Shearer', 'Newcastle', 7)


SELECT * FROM `sales_data.customers`

SELECT * FROM `sales_data.customers`
WHERE city = 'Liverpool'

### Insert this the next day
INSERT INTO `sales_data.customers` (id, firstname, lastname, city, level)
VALUES
(9, 'Ravi', 'Gupta', 'Portsmouth', 1),
(10, 'Jermaine', 'Williams', 'Portsmouth', 5),
(11, 'Gbenga', 'Taibu', 'Portsmouth', 2),
(12, 'Ellen', 'Sheringham', 'Portsmouth', 2)


SELECT * FROM `sales_data.customers`

SELECT * FROM `sales_data.customers`
WHERE city = 'Portsmouth'

SELECT * FROM `sales_data.customers`
WHERE _PARTITIONDATE = '2022-03-29'

DROP TABLE `sales_data.customers`
