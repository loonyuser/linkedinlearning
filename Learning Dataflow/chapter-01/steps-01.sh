
#################################################################################
##################### Setting up a GCP Project for Dataflow #####################
#################################################################################

# Go to "https://console.cloud.google.com/"
# Login and create a new project, or use one where you have owner privileges

# Project Name: loony-learn

# Go to "APIs & Services" 
# Now click on "ENABLE APIS AND SERVICES" and type the follwoing:

    # Compute Engine API, Dataflow API

# Enabling it will take some time and the apis will be enabled.
# Now go to "IAM & ADMIN" and click on "Service Accounts". 
# Click on "SERVICE ACCOUNTS" and file the below details and click on "Create Service Account":

# 	Service account name : loony-dataflow-account
# 	Service account ID : loony-dataflow-account
# 	Service account description : Dataflow jobs, allow access to other GCP services

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
export GOOGLE_APPLICATION_CREDENTIALS=~/LinkedInLearning/loony-dataflow-credentials.json

## Ensure the cloud shell instance has the latest Ubuntu packages
sudo apt-get update

## Check the Java and Maven versions
java -version

mvn -version




#################################################################################
################## Building and Running Apache Beam Pipelines ###################
#################################################################################



# Let's create our project
# Run following commands one by one:

mvn archetype:generate \
    -DarchetypeGroupId=org.apache.beam \
    -DarchetypeArtifactId=beam-sdks-java-maven-archetypes-examples \
    -DarchetypeVersion=2.37.0 \
    -DgroupId=LinkedInLearning \
    -DartifactId=GettingStartedWithDataflow \
    -Dversion="0.1" \
    -Dpackage=org.loony.dataflow \
    -DinteractiveMode=false

## cd into the directory
cd GettingStartedWithDataflow

# Open one more terminal so that we can open the editor
# Click on 'Open Editor'
# Once the editor comes up, Open the 'GettingStartedWithDataflow' directory
## To begin, view the pom.xml - under <profile> note the different
##      types of runners which are listed

# Click on src > main > java > org > loony > dataflow
# Within examples we can see 4 example java files
## In the org/loony/dataflow folder, create a new java file - 'DefaultAndCustomOptions.java'

# We can understand the default and custom options using a simple java code
# Refer to the DefaultAndCustomOptions.java source
# Run the code

# We can see the result in console

mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.DefaultAndCustomOptions

# Modify the signature and re-run the code
# We can see that the result now consist of the modified signature value

mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.DefaultAndCustomOptions \
    -Dexec.args="--project=loony-learn \
    --signature=Modified-Signature"


############

## Perform a simple transformation 
## Create a new file called PriceConversion.java in the org.loony.dataflow 
##      directory (refer to PriceConversion.java)

## Execute the code:
mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.PriceConversion

## Note how the converted prices show up in the output



