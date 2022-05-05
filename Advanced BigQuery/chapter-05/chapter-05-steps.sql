############################################################
########### Permissions on Datasets and Tables #############
############################################################


## Assume there is a separate user you have access to (e.g. alice@loonycorn.com)
## Grant the user (say, Alice) access to Browse resources in the project
## The user is able to view the project in BigQuery, but no datasets are visible

## Grant Alice BigQuery Data Viewer permissions on the sales_data dataset
## Alice is able to view the contents, but cannot edit any details
## Also, Alice is unable to run queries on the dataset tables

## Grant Alice the BigQuery Job User permission at the project level
## This allows Alice to create jobs in the project, thus run queries
## Confirm that Alice is able to execute a query against the supermarket_sales table 
## Still, Alice cannot edit the table details (e.g. add a label)

## We have explored project-level and dataset-level permissions so far
## Now, add the BigQuery Data Editor permission for Alice at the level of the
##      supermarket_sales table
## Check that Alice can now edit the table's labels
## However, other tables in the same dataset cannot be edited by Alice
## This is because this new permission only applies to the supermarket_sales table

## Remove the BigQuery Data Viewer permission for Alice from the sales_data dataset
## Remove the BigQuery Data Editor permission for Alice from supermarket_sales
## This will prepare us for the next demo



############################################################
########### Access to Specific Rows and Columns ############
############################################################


## In the Alice window, navigate to this URL
## https://console.cloud.google.com/bigquery?project=brioche-pudding


### Create a new table from the results of this query below
### This can be in a separate dataset called mandalay_data
### The name of the new table can be mandalay_supermarket_sales
SELECT Branch, City, Customer_type, Product_line, Unit_price, 
       Quantity, Tax_5_, Total, Date, Time, Payment, gross_income
FROM `loony-bigquery.sales_data.supermarket_sales`
WHERE City = 'Mandalay'


### Assign Alice View permissions only on the mandalay_data dataset
### Confirm that she is able to view the data 
### Note that she cannot view the sales_data dataset



############################################################
######################## Monitoring ########################
############################################################

## Navigate to the Monitoring service and to Overview
## View some of the pre-built dashboards for BigQuery



############################################################
######################## Snapshots #########################
############################################################

## Pick one of the tables in the sales_data dataset (e.g. supermarket_sales)
## Click on the Snapshot button and configure the snapshot
## Configurable details include
##      - snapshot name
##      - expiration date and time
##      - snapshot date and time (leave blank for current snapshot)

## A new snapshot table is created which can be used like any other table


