############################################################################
##################### Creating Jobs with Dataflow SQL ######################
############################################################################



## Head to APIs and Services
# Enable Data Catalog API for Dafaflow SQL
# And let's create a service account with permissions to work with BigQuery and Dataflow

# Go to IAM and Roles > Service Accounts
# Click on Create Service Account
# Give account name : dataflow-sql-sa
# Click on Create and Continue

# WIthin roles give 3 roles:
    # Dataflow > Dataflow Worker
    # Dataflow > Dataflow Admin
    # Bigquery > Bigquery Admin
    # Cloud Storage > Storage Admin

# Note the mail of the service account - dataflow-sql-sa@<project_name>.iam.gserviceaccount.com

# Go to Dataflow > SQL WOrkspace
# Now in here we can write queries

# On the left side we can see the datasets in Bigquery
# On the search bar - search for 'stock_data' (we had created this in Bigquery in our previous demos)

# Once that table is on top of the searh we can strat writing query

# The syntax for Dataflow SQL is a bit different
# So, on the left hand side where the table is seen, click on the copy clipboard to copy the resouce id
# Paste that id after FROM 

SELECT * 
FROM FROM bigquery.table.`loony-learn`.stock_data.streamingstocks_avg_output
WHERE index = 'NIFTY'

# We see this validates
# Now let's move on to create the job
# Click on Create Job

# Give the job name as : first-dataflow-sql-job
## Set the region to us-central1 (Iowa)

# Now in the optional parameters, under Service account email give in the email of the account we created
# Below choose destination as Big Query
# Give the dataset and give the tabel name as 'stockdata_query_output'

# Click on Equivalent command line
# There we can see the gcloud command for creating a SQL job

# Click on Create 
# We see the job is starting
# Go to Jobs and click on the Job just created
# View the Graph

# Once it starts running, go to BigQuery and refresh
# We can see the new stockdata_query_output table is created and is populated with rows




## Parametrized queries

## In the Dataflow SQL interface, replace the current query with this

SELECT * 
FROM bigquery.table.`loony-learn`.stock_data.streamingstocks_avg_output
WHERE index = @index_name

## This will show a validation error - we'll have to ignore it
## Choose to create a new job
## Set the job to overwrite the current data in the destination table

## In the SQL parameters section, add a new param
## Set the param name to index_name, the type to STRING
## Set the value of the param to: S&P 500
## Check the box to Ignore Validation Errors
## The above step will enable the Create button - hit that

## The new job is created - in a few minutes, check the contents of the
##      stockdata_query_output table in BQ - the S&P 500 data is there