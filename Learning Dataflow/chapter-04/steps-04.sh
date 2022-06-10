#################################################################################
######################### Creating Jobs with Templates ##########################
#################################################################################


# Let's create a batch pipeline that allows to read files from Cloud storage
# Transform them using JavaScript UDF and append the result to BigQuery table

# Refer schema.json, transform.js

# For that we need to have a JSON file that describes the big query schema
# A javascript file with the UDF function

# Create a new folder within the loony-ll-bucket - 'config_files'
# Within that the folder - 'config_files' upload the schema.json and transform.js files
# Within the folder - 'input_data' upload Order Details.txt

# Now let's go to BigQuery
# Create a dataset - ecommerce_data
## Set it to exist in multiple US regions

# Let's also create our empty output table
# CLick on Create Table within the ecommerce_data dataset

# Give Table name as 'order_details'
# Schema: Give everything as string (if not it throws error. This template is only for loading text data with datatype string)
Order_ID:STRING,
Amount:STRING,
Profit:STRING,
Quantity:STRING,
Category:STRING,
Sub_Category:STRING

# Also note to remove the header from the text file (I have removed and uploaded the file)

# Now Go back to Dataflow and Click on Create Job From Template
# Give the job name as 'gcs_to_bq_batch_job'

## Pick the below template from the Batch section (there is a similar one under streaming)
# Dataflow template: 'Text Files on Cloud Storage to BigQuery'

# Fill the details
# Give the JS file path, json file path
    # JS UDF path: gs://loony-ll-bucket/config_files/transform.js
    # JSON path: gs://loony-ll-bucket/config_files/schema.json
# Udf name: 
    # transform
    # As this is the function name inside the js file

# Give output table name as :  loony-learn:ecommerce_data.order_details
# Give Cloud Storage input path: gs://loony-ll-bucket/input_data/Order Details.txt
# Give temp directory as: gs://loony-ll-bucket/temp_dir
# Give temp location as gs://loony-ll-bucket/staging

# Click on Create job
# We see the Job Graph once the job starts

# Go to BigQuery and there we can see the table has been created
# Now, click on the table and click on Preview


