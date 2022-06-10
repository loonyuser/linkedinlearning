############################################################################
###################### Join Operations on Batch Data #######################
############################################################################


# First, let's see an example of joins with sdk extension
# For that add in the dependency in POM.xml file

    <!-- https://mvnrepository.com/artifact/org.apache.beam/beam-sdks-java-extensions-join-library -->
    <dependency>
        <groupId>org.apache.beam</groupId>
        <artifactId>beam-sdks-java-extensions-join-library</artifactId>
        <version>2.38.0</version>
    </dependency>

# In this demo we can see different kinds of join operations
# First we can see static static join, then streaming-streaming join

# Refer StaticStaticJoin_v1.java
# This uses sdk extension to do inner join

# Open movies.csv and directors.csv file
# directors.csv has 40 entries where as movies has 28 entires

# Upload directors.csv file and movies.csv file within the storage 

# Run this simple example 

mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.StaticStaticJoin

# We see the joined results gets printed out in the console
# And we see all the directors are not printed out
# Only the common ones does, which is what inner join does



############################################################################
#################### Join Operations on Streaming Data #####################
############################################################################


# Create two Pub/Sub topics for this next demo: moviesinfo and actorsinfo
# This time let's join two streams (Refer to StreamStreamJoin.java)

# Run the code

mvn -Pdataflow-runner compile exec:java  \
    -Dexec.mainClass=org.loony.dataflow.StreamStreamJoin  \
    -Dexec.args="--project=loony-learn \
    --stagingLocation=gs://loony-ll-bucket/staging/ \
    --inputTopicActors=projects/loony-learn/topics/actorsinfo \
    --inputTopicMovies=projects/loony-learn/topics/moviesinfo \
    --output=gs://loony-ll-bucket/join_data/movieactors \
    --runner=DataflowRunner \
    --gcpTempLocation=gs://loony-ll-bucket/temp/ \
    --region=us-central1" 

# In terminal - 2 give in the data

gcloud --project=loony-learn \
pubsub topics publish actorsinfo \
--message="The Shawshank Redemption,Tim Robbins,Morgan Freeman,Bob Gunton,William Sadler"

gcloud --project=loony-learn \
pubsub topics publish actorsinfo \
--message="The Godfather: Part II,Al Pacino,Robert De Niro,Robert Duvall,Diane Keaton"

gcloud --project=loony-learn \
pubsub topics publish moviesinfo \
--message="The Shawshank Redemption,1994,9.3,80,2343110"

gcloud --project=loony-learn \
pubsub topics publish moviesinfo \
--message="The Godfather,1972,9.2,100,1620367"

gcloud --project=loony-learn \
pubsub topics publish actorsinfo \
--message="The Matrix,Lana Wachowski,Keanu Reeves,Laurence Fishburne"

gcloud --project=loony-learn \
pubsub topics publish actorsinfo \
--message="The Matrix,Lana Wachowski,Carrie-Anne Moss,Lana Wachowski"

gcloud --project=loony-learn \
pubsub topics publish actorsinfo \
--message="Inception,Christopher Nolan,Leonardo DiCaprio,Joseph Gordon-Levitt"

gcloud --project=loony-learn \
pubsub topics publish moviesinfo \
--message="The Matrix,1999,8.7,73,1676426"

gcloud --project=loony-learn \
pubsub topics publish moviesinfo \
--message="Star Wars: Episode V - The Empire Strikes Back,1980,8.7,82,1159315"

gcloud --project=loony-learn \
pubsub topics publish moviesinfo \
--message="Hamilton,2020,8.6,90,55291"

# Go to jobs and view the graph and the worker log output