############################################################
########### BigQuery Data Transfer Service #################
############################################################

## Create a table called laptops in BigQuery in the sales_data dataset
## Use laptops_01.json to create the table
## This will set the schema for future file loads

## Open up the AWS console and pull up the S3 and IAM services
##		in separate tabs

## It is assumed that you already have an S3 bucket to work with
## e.g.
s3://loony-source-bucket/

## Upload one of the laptop files to the bucket
## We'll need to wait about 15 minutes before we can kick off a 
##		transfer job from the S3 bucket

## From IAM, create a new user with at least S3 read access
## Note the access key ID and secret key - these will be used
##		when we set up a transfer service job from AWS to BigQuery


## Navigate to the data transfer service in GCP 
##		and create a new transfer

## Transfer name: S3-To-LaptopsTable

## Schedule a time in the future:
##		- make sure it starts after the transfer is created
##		- it should run 15 minutes after the upload to S3

## Once the transfer is defined, wait for it to kick off
## Reload the page a few minutes later, and the job should have run
## View the job details

## Head to BigQuery and bring up the laptops table
## It should now have additional rows

## Head to S3 and upload 2 new files
## Head to the transfer page in BigQuery
## Wait 15 minutes and kick off the transfer again

## Wait a few minutes for the transfer to complete
## Refresh the page - another transfer job has kicked off
## View the job details
## Head to the laptops table and confirm new rows have been added




