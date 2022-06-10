#################################################################################
####################### Running Jobs with Dataflow Prime ########################
#################################################################################

## Run the pipeline without Dataflow prime

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.WalmartSales  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --region=us-central1 \
    --numWorkers=8"


# Note that in this case we don't get the sdk logs
## Also, pull up Job Info from the Dataflow job information
## Note the Resource metrics - resource use is quite high when we compare with the
##      the use of Dataflow Prime a little later

# Once dataflow service is enabled, it by default uses runner v2 and so we get tke sdk logs too

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.WalmartSales  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --runner=DataflowRunner \
    --region=us-central1 \
    --numWorkers=8 \
    --dataflowServiceOptions=enable_prime"

## Head to the Job details and pull up the Resource metrics under Job Info
## Note that numVCPUs is less than the numWorkers set in the job arguments
