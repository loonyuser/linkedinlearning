############################################################################
################## Pub/Sub to BigQuery with a Template #####################
############################################################################


## 
# Go to BigQuery and create a empty table called historic_close_prices
# This is in the stock_data dataset

            # Field name    Type    Mode
            # close_date DATE  NULLABLE
            # ticker STRING NULLABLE    
            # price FLOAT   NULLABLE    

# Click on Create Job From Template in Jobs
# Give Job Name: pubsub-topic-to-bq
# In Dataflow Template, choose Pub/Sub Topic to BigQuery

# We already have a StockData topic so let's use that

# Give the Input Pub/Sub topic:
    # projects/loony-learn/topics/stockdata
# Give the BigQuery output table:
    # loony-learn:stock_data.historic_close_prices
# Give Temporary location as:
    # gs://loony-ll-bucket/temp/

# Click on Run Job

# We see the job is starting
# Go to the StockData topic and let's publish messgaes now
## Publish the following messages one at a time 
# 

{'close_date': '2022-01-23', 'ticker': 'GOOGL', 'price': 2330.40}
{'close_date': '2022-01-23', 'ticker': 'AMZN', 'price': 2290.40}

# Wait for a bit and go to BIgquery and see the historic_close_prices table
# We see the table is empty
# We can see a new table is created - historic_close_prices_error_records
# Click on Preview and we see the error records there
# It says: Failed to serialize json to table row:...

# Now in the topic publish the records like the below format

{"close_date": "2022-01-23", "ticker": "GOOGL", "price": 2330.40}
{"close_date": "2022-01-23", "ticker": "AMZN", "price": 2290.40}
{"close_date": "2022-01-23", "ticker": "NFLX", "price": 190.93}

# Now if we go to bigquery and reload we can see the rows in pubsub_to_bq_table

