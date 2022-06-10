############################################################################
################### Window Operations on Streaming data ####################
############################################################################



## Now to build an app which reads JSON data published to the topic and writes to BigQuery table
# Refer StreamingStocks_v2.java

# In terminal, run the following 

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamingStocks  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputTopic=projects/loony-learn/topics/stockdata \
    --destTableName=streamingstocks_output \
    --runner=DataflowRunner \
    --region=us-central1"

## Once, this message below is seen
Workers have started successfully.

# Pass along the JSON data from a new cloud shell tab

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4300.01'}" \
--attribute=time='2022-02-01T10:30:00Z'

## Head to BigQuery and Check the preview of our table - the row has been added

## Publish one more message from the cloud shell

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4322.79'}" \
--attribute=time='2022-02-01T10:31:00Z'

# Once this is given go to Job and observe the details
# Go to Bigquery and refresh the dataset, we can see streamingstocks_output table
# Now let's add in more data 

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'DJIA', 'open': '34061.75','ltp': '34130.01'}" \
--attribute=time='2022-02-01T10:30:00Z'

gcloud --project=loony-dataflow-project \
pubsub topics publish stockdata \
--message="{'index': 'DJIA', 'open': '34061.75','ltp': '34116.01'}" \
--attribute=time='2022-02-01T10:31:00Z'

gcloud --project=loony-dataflow-project \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17023.00'}" \
--attribute=time='2022-02-01T10:30:00Z'

# Now, as so as we enter the below set in terminal - 2 and once we see both the message Id
# Click on the Job and click on STOP 


## Try to run this query while the job is still draining - it will fail

DELETE 
FROM `loony-learn.stock_data.streamingstocks_output` 
WHERE time IS NOT NULL

## The table cannot be updated or data removed for several minutes after the
##      streaming job has stopped
## The quick option is to delete and recreate the table before moving
##      on to the next demo




# First lest understand fixed window / tumbling windowing operation
# Let's take the stock example itself
# This time, with the price, let's compute the avg price as the time passes

# Let's use the same topic as before

# Refer StreamingStocks_v3.java

# Run the code - the default window size of 30 seconds will be used

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamingStocks  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputTopic=projects/loony-learn/topics/stockdata \
    --destTableName=streamingstocks_avg_output \
    --runner=DataflowRunner \
    --region=us-central1"

# Once the works are started up

# On terminal - 2 let's feed in the stock/index details
## The two trades of BANKNIFTY get aggregated and averaged
## The NIFTY data gets processed, but there is no aggregation to be done 

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'BANKNIFTY', 'open': '34051.33','ltp': '34060.00'}" \
--attribute=time='2022-02-01T10:35:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'BANKNIFTY', 'open': '34051.33','ltp': '34070.00'}" \
--attribute=time='2022-02-01T10:35:01Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17010'}" \
--attribute=time='2022-02-01T10:30:00Z'



## Observer from the table that the output has been generated

# Drain the job and again run the job with window size as 2 minutes (120 seconds)
## Note that the BANKNIFTY data gets aggregated but the NIFTY data does not

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamingStocks  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputTopic=projects/loony-learn/topics/stockdata \
    --runner=DataflowRunner \
    --windowSize=120 \
    --destTableName=streamingstocks_avg_output \
    --region=us-central1"

# We can feed in more data

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'BANKNIFTY', 'open': '34051.33','ltp': '34100.00'}" \
--attribute=time='2022-02-01T10:40:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'BANKNIFTY', 'open': '34051.33','ltp': '34070.00'}" \
--attribute=time='2022-02-01T10:41:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17000.35'}" \
--attribute=time='2022-02-01T10:42:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17003.89'}" \
--attribute=time='2022-02-01T10:45:00Z'

#############

# Now let's see sliding window operations

# Refer StreamingStocks_v4.java

# The only change is with the window operation
## Also note the change in default value for the window size and the 
##      default set for sliding window

# Run the code, this time let's give the window size as 60 seconds and a sliding window every 30 seconds

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamingStocks  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputSub=projects/loony-learn/subscriptions/stockdata-sub \
    --runner=DataflowRunner \
    --destTableName=streamingstocks_avg_output \
    --gcpTempLocation=gs://loony-ll-bucket/temp/ \
    --region=us-central1"


# On terminal - 2 give in the following data one by one
# The easier way to do this is to create a script (refer publish_messages.sh)
## Upload the scipt to the cloud shell
## Confirm it is present

ls -l

## Grant execute permissions on it

chmod +x publish_messages.sh

## Run it

./publish_messages.sh

## For reference, here are the messages in the script 

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4300.01'}" \
--attribute=time='2022-02-01T11:00:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4310.79'}" \
--attribute=time='2022-02-01T11:01:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17023.00'}" \
--attribute=time='2022-02-01T11:01:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4317.01'}" \
--attribute=time='2022-02-01T11:01:30Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4322.79'}" \
--attribute=time='2022-02-01T11:02:00Z'

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'NIFTY', 'open': '16920.27','ltp': '17024.00'}" \
--attribute=time='2022-02-01T11:02:00Z'

# Go to Bigquery and observe the table contents

# now let's try update the running stream job
# For that open a new terminal -  Terminal -3 and copy the jobname of the previous running job

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamingStocks  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputSub=projects/loony-learn/subscriptions/stockdata-sub \
    --runner=DataflowRunner \
    --destTableName=streamingstocks_avg_output \
    --gcpTempLocation=gs://loony-ll-bucket/temp/ \
    --jobName=streamingstocks-cloud0user-0607101349-c3b4f27 \
    --windowSize=180 \
    --slideWindowSize=120 \
    --region=us-central1 \
    --update"


# It shows: INFO: 2022-05-06T12:50:30.734Z: Sending UPDATE command to old job 2022-05-06_05_36_21-6575935908280108311. 
                    # Transitioning data and resources.

# And if we refresh the job page we can see both the jobs running

# If we wait a bit we see the old job gets terminated and the new job's workers are started
