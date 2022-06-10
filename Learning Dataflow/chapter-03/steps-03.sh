#################################################################################
######################## Configuring and Monitoring Jobs ########################
#################################################################################


# Now let's understand different transform and monitor the pipeline
# Refer WalmartAvgSales_v1.java

# Run the code

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.WalmartSales  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --region=us-central1"

# While the job is running to go to Dataflow > Jobs and observe the Job Graph
# Click on Job Metrics we can see the number of target workers (only 1)
# On the resource metrics we can see now the Current vCPUs is 1
# Now let's go to Cloud storage and observe the output file generated
# Now let's try to increase the number of workers

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.WalmartSales  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --region=us-central1 \
    --maxNumWorkers=20 \
    --numWorkers=5"

# While the job is running, go to Dataflow > Jobs
# On the resource metrics we can see now the Current vCPUs is 5 and within Job info the current workers = 5
# Now click on Logs in the left bottom
# We can see Job Logs, Worker Logs and Diagnostics

# Scroll through Job Logs and WOrker logs
# Within worker logs we can see 'Starting 5 workers in us-central1-c..'

# While the job is running within Job Info - we can also see :
    # Autoscaling: Raised the number of workers to 5 based on the rate of progress in the currently running stage(s).

# If we click on One Block in the Job Graph, we can see it's corresponding Logs and Step Info

# Click on Job Metrics, there we can see the chart and the
# Click on Execution Details - there we can see the Graph View of Stage Workflow



############

# Now lets see GroupBy transformation
# Refer WalmartSales_v2.java
# Run the code

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.WalmartSales  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --region=us-central1 \
    --numWorkers=5"

# Go to output_data folder and view the output file
# Go to Jobs and view the execution job as well



#################################################################################
########################## Pipelines with Side Inputs ###########################
#################################################################################


# Now with the same dataset, let's extract understand how side input works
# Modify WalmartSales_v3.java

# In this we are finding the next avg sales of all the years, 
# save that as singletonview so we can feed it as side input
# Using the singletonview we can calculate the days with above average sales

# Run the code

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.WalmartSales  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --region=us-central1 \
    --numWorkers=5"

# After running the code, go to job graph and observe the execution details




