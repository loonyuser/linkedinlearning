############################################################################
#################### Batch Processing with Apache Beam #####################
############################################################################



# Go to "https://console.cloud.google.com/"
# Login and create project

# Project Name: loony-dataflow-project

# Go to "APIs & Services" 
# Now click on "ENABLE APIS AND SERVICES" and type the follwoing:

    # Compute Engine API, Dataflow API, StackDriver API and PubSub API

# Enabling it will take some time and the apis will be enabled.
# Now go to "IAM & ADMIN" and click on "Service Accounts". 
# Click on "SERVICE ACCOUNTS" and file the below details and click on "Create Service Account":

#   Service account name : loony-dataflow-account
#   Service account ID : loony-dataflow-account
#   Service account description : Dataflow jobs, allow access to other GCP services

# Click on Continue

# Now click on "Select a role" -> "Project" -> "Owner" and click on "Continue".
# This field is optional so do not fill anything and click on "Done".

# From the dashboard click on the three dots in "Actions" for the created dataflow account and click on "Manage key".
# Click on ADD KEY > Create new key
# Key type is "JSON" and click on "Create".
# Once the key will be created it will be downloaded automatically.
## Give the credentials file a name of loony-dataflow-credentials.json

# Open cloud shell and click on three dots. Click on upload file and upload the key that we just downloaded.
# The Google Cloud shell is a transient instance running the Debian OS

# Confirm that the file has been uploaded
ls -l

## Create an environment variable pointing to the file
export GOOGLE_APPLICATION_CREDENTIALS=~/loony-dataflow-credentials.json

## Ensure the cloud shell instance has the latest Ubuntu packages
sudo apt-get update

## Check the Java and Maven versions
java -version

mvn -version


# Go to Cloud Storage > Browse
# Click on Create Bucket
# Give the bucket name 'loony-ll'
# Choose the location and click on Create
# We see the bucket is created

# Within the bucket create a folder named 'streaming_data'

# Let's create our project
# Run following commands one by one:

mvn archetype:generate \
    -DarchetypeGroupId=org.apache.beam \
    -DarchetypeArtifactId=beam-sdks-java-maven-archetypes-examples \
    -DarchetypeVersion=2.37.0 \
    -DgroupId=LinkedInLearning \
    -DartifactId=AdvancedDataflow \
    -Dversion="0.1" \
    -Dpackage=org.loony.dataflow \
    -DinteractiveMode=false

## cd into the directory
cd AdvancedDataflow
 
# Open one more terminal so that we can open the editor
# Click on 'Open Editor'
# Once the editor comes up, Open the 'AdvancedDataflow' directory
## To begin, view the pom.xml - under <profile> note the different
##      types of runners which are listed

# Click on src > main > java > org > loony > dataflow
# Within examples we can see 4 example java files
## In the org/loony/dataflow folder, create a new java file - 'StreamingData.java'



# In this demo we read in streaming data from GCS using watchForNewFiles function
# Refer StreamingData_v1.java

# https://www.kaggle.com/datasets/turkibintalib/saudi-arabia-used-cars-dataset

# Open the csv file in sublime text and show
# Within streaming_data folder upload UsedCarsSA_1.csv and UsedCarsSA_2.csv

# Come to the editor within mydataflowexamples folder create a new java file - 'StreamingData.java'
# Run the code

mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.StreamingData

# This time let's print out the result to the console
# We see all the data get's printed out in the console (both the files are read)
