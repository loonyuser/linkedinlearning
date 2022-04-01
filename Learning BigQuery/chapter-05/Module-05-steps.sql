####################################################################
################ Using the bq Command-line Tool ####################
####################################################################

###############
### Working with the bq Command Line Utility
###############


gcloud config set project loony-bigquery

bq help | less

bq ls

bq ls loony_university

bq ls bigquery-public-data:fdic_banks

bq show loony_university

bq show \
    loony_university.honey_production_usa 

bq show --format=prettyjson \
    loony_university.honey_production_usa

bq query \
    'SELECT state, year, totalprod, prodvalue 
    FROM loony_university.honey_production_usa 
    WHERE state = "AZ" and year > 2005'

bq query --dry_run \
   'SELECT state, SUM(totalprod)
   FROM loony_university.honey_production_usa
   GROUP BY state
   ORDER BY state'

bq query \
    'SELECT state, SUM(totalprod)
    FROM loony_university.honey_production_usa
    GROUP BY state
    ORDER BY state'


bq query \
    --use_legacy_sql=false \
    --parameter=state::CA \
    --parameter=year:INT64:2008 \
    'SELECT state, year, totalprod, yieldpercol, prodvalue
    FROM `brioche-pudding.loony_university.honey_production_usa`
    WHERE state = @state
    AND year = @year'

cat honeyprod_query.sql

bq query \
    --use_legacy_sql=false \
    --parameter=state::CA \
    --parameter=year:INT64:2008 \
    --flagfile=honeyprod_query.sql


