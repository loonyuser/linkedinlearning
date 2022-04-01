####################################################################
###### Creating and Working with Datasets and Tables  ##############
####################################################################

###############
### Setting up BigQuery in a GCP Project
###############

### Login to GCP and enable the Compute Engine API for your Project
### This will allow BigQuery to provision the compute resources it needs


###############
### Creating a BigQuery Dataset
###############

## Create a BigQuery dataset called loony_university 
## (or any name you prefer)



###############
### Defining Tables in BigQuery
###############

## Create a table called students with the schema below

## Table columns: 
=> filedname            type         mode               description                maximum

=> id                  integer      Requried        The student ID   
=> name                string       Requried                                          64
=> email               string       nullable                                         128
=> dob                 date         nullable
=> dueamt              numeric      nullable         



###############
### Querying BigQuery Tables
###############


INSERT INTO `loony_university.students`
(id, name, email, dob, dueamt)
VALUES (1001, "Erica", "erica@loonycorn.com", 
		"2004-06-02", 2200);

SELECT * FROM `loony_university.students`;

SELECT name, dueamt FROM `loony_university.students`;




###############
### Importing Data from a CSV File
###############

## Upload the movies_info.csv file into a table called movies_info
## Let BigQuery auto-detect the schema



###############
### Loading Data from Google Cloud Storage
###############

## Upload the laptops_info.json file to a Google Cloud Storage bucket
## Createa table called laptops_info out of the laptops_info.json file




###############
### Exporting Query Results into a Table
###############
 

SELECT name, company, country, genre, director, 
gross, budget, (gross-budget) AS profit,
released, runtime, year 
FROM `loony_university.movies_info`
WHERE budget > 100000000;

SELECT name, company, country, genre, director, 
gross, budget, (gross-budget) AS profit,
released, runtime, year 
FROM `loony_university.big_budget_movies`
WHERE budget > 200000000;




###############
### Building a New Table with a SELECT Query
###############


CREATE TABLE `loony_university.lossmaking_movies`
AS
SELECT name, company, country, genre, director, 
gross, budget, (budget-gross) AS loss,
released, runtime, year 
FROM `loony_university.movies_info`
WHERE budget > gross;

SELECT name, director, genre, year, loss 
FROM `loony_university.lossmaking_movies`
ORDER BY loss DESC;







