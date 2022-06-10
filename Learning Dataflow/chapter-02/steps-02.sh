#################################################################################
######################### Running Pipelines on Dataflow #########################
#################################################################################



# Now let's write a design and create a pipeline and run it using direct runner and using dataflow runner

# We can create it using either gsutil or via the UI
# If creating using UI :
    # Go to Cloud Storage > Browse
    # Click on Create Bucket
    # Give the bucket name 'loony-ll-bucket'
    # Choose the location and click on Create
    # We see the bucket is created


# Now inside the bucket create 2 folders - input_data and output_data
# Within input_data upload all the dataset that we need for this course
## These include Sales_April_2019.csv, Walmart.csv and Order Details.txt

# https://www.kaggle.com/datasets/knightbearr/sales-product-data

# Now let's use this data and extract certain fields from this
# I have filtered out the data as this data had some bugs
# Please use the data within TLL datasets folder

# Refer ExtractDetails_v1.java
# Create a new java file within mydataflowexamples - ExtractDetails.java

# Here are just extracting certain fields from the original dataset
# Run the pipeline locally ie using direct runner. So it runs in the cloud shell vm

mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.ExtractDetails

# Go to output_data folder in gcp storage as there we can we multiple files are been generated
# And the file type is text
# Open the file and show

############

# Now we can run the same on Cloud Dataflow
# Before that delete files within output_data folder

# For that use dataflow runner

mvn -Pdataflow-runner compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.ExtractDetails \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --region=us-central1"

# It takes some time for the job to run
# Go to Dataflow > jobs
# There we can see 'extractdetails-cloud0user-0326133215-f4c91593' job and Status as running
# We can see:
#   Job Graph, Execution Details, Job Metrics, Recommendations
# Within Job Graph observe the Graph View
# CLick on Job Steps View and change it to Table View
# On the right hand side, we can see the Job Info
# Click on Execution Details
# We can see Stage Progress, Stage Workflow and Worker Progress
# Click on a stage and observe the details

## Expand Job Info on the right and take a look at the Resource metrics
## These are what enable us to estimate the cost of using Dataflow

# Go back to Cloud Storage
# There we can see a new dataflow-staging bucket has been created
# Click on that and within that we have a temp folder and that's empty
# Now go back to loony-ll
# There also we can see a new folder named 'staging'
# Click on the staging folder and we can see multiple files in there

# Go back to output_data folder and observe the files

############

# Now let's see another example where we get the count of each product purchased using aggregations
# Refer ExtractDetails_v2.java

# In this version we are using pipeline options for input and output files
# Run it using dataflow runner and observe the jobs like before

mvn -Pdataflow-runner compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.ExtractDetails \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --experiments=use_runner_v2 \
    --region=us-central1"

# Note that here we are using Dataflow Runner v2 
# So here in the logs we'll be able to see the  logs from the runner harness process as well as logs from the SDK processes
# For Dataflow it's optional to use Runner v2 but for Dataflow Prime, it's by default uses Runner v2 

############

# Now let's get the count of each product

# Refer ExtractDetails_v3.java

mvn -Pdataflow-runner compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.ExtractDetails \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --experiments=use_runner_v2 \
    --region=us-central1"

# After it is run go to storage and open the file
# Note that same products has different total price as the quantity is different

# End of the each demo just delete the contents within output_data folder as we'll using the same folder for all the demos

