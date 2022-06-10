############################################################################
#################### Introduction to Stream Processing #####################
############################################################################

# Refer StreamingData_v2.java

# This time let's calculate the age of the car from current year
# Note that this time we have watchForNewFiles function to look for more csv files

# Run the code

mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.StreamingData

# Right after the first set of values get's printed out
# Go to streaming_data folder and put UsedCarsSA_3.csv and UsedCarsSA_4.csv

# We see after the first set of data is processed the process doesn't end, it waits for new files
# Once we add in those next 2 csv files we can see those files are also processed 
# And new output is printed out in the console

############

# Refer StreamingData_v3.java

# In this example let's find the mean age of the car per brand
# Run the code 
mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.StreamingData

# We see it throws error
# An exception occured while executing the Java class. GroupByKey cannot be applied to non-bounded PCollection in the GlobalWindow without a trigger. 
# Use a Window.into or Window.triggering transform prior to GroupByKey. -> [Help 1]

# We cannot use groupby transformation without window function
# Now we can solve this

############

# Refer StreamingData_v4.java

# Note we have added window functions in here
# Run the code
mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.StreamingData

# This time we see the output

# Add UsedCarsSA_5.csv

# We see the new mean is also printed as we add in new data
# In the console compare the old mean with the new mean for any brand

# Go to Jobs and observe the job graph again

############

# Refer StreamingData_v5.java

# In this lets undertand the GroupByKey 
# Run the code 
mvn compile exec:java \
    -Dexec.mainClass=org.loony.dataflow.StreamingData


    