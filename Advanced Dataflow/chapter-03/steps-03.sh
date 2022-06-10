############################################################################
########################### Writing to Pub/Sub #############################
############################################################################



## In the GCS bucket's streaming_data folder, start with 2 files -
##      UsedCarsSA_1.csv and UsedCarsSA_2.csv

# In this demo we introduce PubSub
# Click on PubSub in console and click on Topics
# Let's create 'autosales' topic
# Give the name and click on Create
# We see the topic is created

# Now, just scroll through the page and we can see we have export options to BigQuery, Cloud Storage etc
# We can also see the message info, charts
# Down below we have Subscriptions option

# If you notice, automatically an autosales-sub subscription is been created
# Click on that and just scroll through the page
# View the info in the Details tab - Delivery Type, Subscription expiration etc..

# Now let's move to editor and let's read the data from GCS, 
#       transform the data and write the result to PubSub

# Refer StreamingData_v6.java

# Here we are reading streaming data, but the problem is when the messages are 
#       pulled from PubSub there is a delay
# So adding new files and pulling the output won't be clear under messages
## However, the number of messages processed is clear from the Metrics section
##      where there is a graph for Unpacked message count

# Run the code

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamingData  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputFilesLocation=gs://loony-ll-bucket/streaming_data/UsedCarsSA_*.csv \
    --topicName=autosales \
    --runner=DataflowRunner \
    --gcpTempLocation=gs://loony-ll-bucket/temp/ \
    --region=us-central1"

## Once you see the message "Workers have started successfully",
##      head to Dataflow --> Jobs --> <the current streaming job>
## Head to Execution Details and pull up the Worker logs
## Watch for a log message which reads
## gs://loony-ll-bucket/streaming_data/UsedCarsSA_*.csv - current round of polling took 173 ms and returned 2 results, of which 2 were new

## Then head to Pub/Sub and over to the autosales topic and autosales-sub subscription
## In Overview take a watch for the "Unacked message count" graph to spike
## Once it does, head to Pull and pull for some messages
## Pull receives messages with a delay, so not all will be available immediately

## Head to the GCS bucket and upload UsedCarsSA_3.csv to the streaming_data folder
## Head to the worker logs and watch for a message like:
## gs://loony-ll-bucket/streaming_data/UsedCarsSA_*.csv - current round of polling took 43 ms and returned 3 results, of which 1 were new.

# Back to the Pub/Sub autosales-sub where the "Unacked message count" graph spikes again





############################################################################
########################### Reading From Pub/Sub ###########################
############################################################################


## The focus of this demo is to read data from a pub/sub Topic

## Head to the Pub/Sub console and create a new topic called stockdata
## The default subscription will be created along with the topic
# If needed we can delete all the Topics created on the previous module 

## The output will be written to a BigQuery table - we'll now create that
## Create a dataset in your project called stock_data
## The dataset can be mapped to multiple US regions

## In the dataset, create two tables - 'streamingstocks_output', 'streamingstocks_avg_output'

## The streamingstocks_output table will have 3 columns:
##      - time of type TIMESTAMP
##      - index of type STRING
##      - ltp of type NUMERIC

## The streamingstocks_avg_output table will have 3 columns:
##      - time of type TIMESTAMP
##      - index of type STRING
##      - average_price of type NUMERIC

## Now to work on the code...

## We will publish data to the Pub/Sub topic in the JSON format
# To work with json objects add in the following dependency in pom.xml file
# Refer to attached POM file

    <!-- https://mvnrepository.com/artifact/org.json/json -->
    <dependency>
        <groupId>org.json</groupId>
        <artifactId>json</artifactId>
        <version>20220320</version>
    </dependency>

## Now to build an app which reads JSON data published to the topic
# Refer StreamingStocks_v1.java
## This is a simple version which simply extracts the index and ltp fields
##      from the JSON and publishes it to the console


mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamingStocks  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputTopic=projects/loony-learn/topics/stockdata \
    --runner=DataflowRunner \
    --region=us-central1"

## Once, this message below is seen, open up a second tab in the cloud shell
Workers have started successfully.

# Pass along the JSON data from a new cloud shell tab

gcloud --project=loony-learn \
pubsub topics publish stockdata \
--message="{'index': 'S&P 500', 'open': '4250.75','ltp': '4320.91'}" \
--attribute=time='2022-02-01T10:29:00Z'

## Wait a few seconds and head to Pub/Sub --> Subscriptions
## Observe that a new subscription has been created 
## For now, head to the default subscription (stockdata-sub)
## Go to Messages and hit PULL - you will see the full JSON message

## Head to the newly auto-created subscription 
## Name will be something like stockdata.subscription-9025924783760798976

## Head to the Metrics and then look at the Unacked Message count
## This may have spiked up to 1 and then back to zero
## It looks like the message was read




