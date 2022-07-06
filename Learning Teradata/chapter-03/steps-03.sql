------------------------------------------------
Chapter 03 - Running Queries on Teradata Studio
------------------------------------------------



-- Read CSV data into a table
---------------------
-> Change the perspective from Query Development to Data Transfer.
-> from the Data Source Explorer on the left go to the Restaurants database
-> Right click on the Tables subfolder of the Restaurants database and select Teradata -> Smart Load Data...
-> this opens up the Data transfer wizard
-> click on launch to open up the "Smart Load Wizard"
-> click on browse and navigate to select the michelin18.csv file
-> let the file type be delimited text. the other options are xls and xlsx for excel
-> Check the box for "Column Labels in First Row"
-> keep the other fields as default and click on Next

-> in the "Table Column Data Types"
-> Change Primary Index from "No Primary Index" to "Unique" in the dropdown.
-> Set the Table Type to SET rather than MULTISET
-> Leave the table name as-is - we will modify that a little later
-> click Next to see the generated sql. It should look something like this:

CREATE SET  TABLE "Restaurants"."michelin18"  (
          "ID" SMALLINT,
          "Name" VARCHAR(61),
          "Address" VARCHAR(115),
          "Location" VARCHAR(38),
          "MinPrice" INTEGER,
          "MaxPrice" INTEGER,
          "Currency" VARCHAR(3),
          "Longitude" DECIMAL(11 , 7),
          "Latitude" DECIMAL(10 , 7),
          "PhoneNumber" BIGINT,
          "Url" VARCHAR(136),
          "WebsiteUrl" VARCHAR(126),
          "Award" VARCHAR(16)
     )
UNIQUE PRIMARY INDEX ("ID");


-> Click on Finish

-> Repeat the procedure with cuisine_mapping.csv without a primary index and as a MULTISET
-> Repeat the procedure with cuisine.csv with unique index and as SET.

-> expand the tables in the Data Source Explorer and show that the tables exist.

Head back to the Query Development perspective.

Rename Table
-------------
RENAME TABLE michelin18 to Michelin_Awarded;

Limit 
----- 
-> there is no limit in teradata use top 'x' instead

SELECT TOP 5 * 
FROM Michelin_Awarded;


--------------------------------------------------------------------------------------------------	
Result:
-------

ID Name                                     Address                                             Location      MinPrice MaxPrice Currency Longitude  Latitude   PhoneNumber  Url                                                                                                  WebsiteUrl                          Award            
 -- ---------------------------------------- --------------------------------------------------- ------------- -------- -------- -------- ---------- ---------- ------------ ---------------------------------------------------------------------------------------------------- ----------------------------------- ---------------- 
  4 Victor''s Fine Dining by christian bau   Schlossstrasse 27, Perl, 66706, Germany             Perl               205      295 EUR       6.3872109 49.5351732  49686679118 https://guide.michelin.com/en/saarland/perl/restaurant/victor-s-fine-dining-by-christian-bau         https://www.victors-fine-dining.de/ 3 MICHELIN Stars
  1 Aqua                                     Parkstrasse 1, Wolfsburg, 38440, Germany            Wolfsburg          225      225 EUR      10.7899990 52.4331722 495361606056 https://guide.michelin.com/en/niedersachsen/wolfsburg/restaurant/aqua79029                           http://www.restaurant-aqua.com      3 MICHELIN Stars
  2 The Table Kevin Fehling                  Shanghaiallee 15, Hamburg, 20457, Germany           Hamburg            230      230 EUR      10.0029797 53.5426229 494022867422 https://guide.michelin.com/en/hamburg-region/hamburg/restaurant/the-table-kevin-fehling              http://www.the-table-hamburg.de/    3 MICHELIN Stars
  5 Rutz                                     Chausseestrasse 8, Berlin, 10115, Germany           Berlin             198      245 EUR      13.3860867 52.5283507 493024628760 https://guide.michelin.com/en/berlin-region/berlin/restaurant/rutz                                   https://www.rutz-restaurant.de/     3 MICHELIN Stars
  3 Restaurant Ueberfahrt Christian Juergens Ueberfahrtstrasse 10, Rottach-Egern, 83700, Germany Rottach-Egern      259      319 EUR      11.7582292 47.6966846   4980226690 https://guide.michelin.com/en/bayern/rottach-egern/restaurant/restaurant-uberfahrt-christian-jurgens http://www.althoffcollection.com    3 MICHELIN Stars
--------------------------------------------------------------------------------------------------	


WHERE CLAUSE
--------------

 -> This query returns over 160 rows

SELECT Name, Location, Currency, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB';

 -> The OR clause
SELECT Name, Location, Currency, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     OR Location = 'Singapore';

 -> The AND clause

SELECT Name, Location, Currency, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location = 'Chiang Mai';

 -> The EXPLAIN keyword
 -> This gives an indication of how the query will be executed
 -> Just add the keyword EXPLAIN before any query

EXPLAIN
SELECT Name, Location, Currency, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location = 'Chiang Mai';


 -> Multiple WHERE conditions

SELECT Name, Location, Currency, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND ( Location = 'Chiang Mai' 
               OR Location = 'Phuket'
               OR Location = 'Nonthaburi');

SELECT Name, Location, Currency, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location IN ('Chiang Mai', 'Phuket', 'Nonthaburi');

SELECT Name, Location, Currency, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location NOT IN ('Chiang Mai', 'Phuket', 'Nonthaburi');


 -> NOT operator

SELECT Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location <> 'Bangkok';



 -> Range conditions, first less than, then less-than-equal-to

SELECT Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location <> 'Bangkok'
     AND MinPrice < 30;

SELECT Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location <> 'Bangkok'
     AND MinPrice <= 30;

 -> The BETWEEN Operator
SELECT Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='THB'
     AND Location <> 'Bangkok'
     AND MinPrice BETWEEN 30 AND 50;


 -> DISTINCT Operator

SELECT Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='SGD';

 -> Distinct award types for Singapore match those globally

SELECT DISTINCT Award
FROM Michelin_Awarded
WHERE Currency ='SGD';

SELECT DISTINCT Award
FROM Michelin_Awarded;

 -> LIKE Operator

SELECT Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='SGD'
     AND Award LIKE 'Bib%';

SELECT Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='SGD'
     AND Award LIKE '%MICHELIN%';



ORDER BY
--------

 -> Check the 10 cheapest restaurants in the Euro zone based on min price
 -> Observe that there are multiple restaurants with 10 and 12 as the MinPrice

SELECT TOP 10 Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='EUR' 
ORDER BY MinPrice;

SELECT TOP 10 Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='EUR' 
ORDER BY MinPrice ASC;


SELECT TOP 10 Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='EUR' 
ORDER BY MinPrice DESC;


 -> Set a second ordering key to set the ordering in case of a tie in the primary order by key

SELECT TOP 10 Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='EUR' 
ORDER BY MinPrice ASC, MaxPrice ASC;

 -> We can have mixed ordering for the different order by keys
SELECT TOP 10 Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='EUR' 
ORDER BY MinPrice ASC, MaxPrice DESC;

 -> Get the plan by using EXPLAIN

EXPLAIN
SELECT TOP 10 Name, Location, MinPrice, MaxPrice, Award
FROM Michelin_Awarded 
WHERE Currency ='EUR' 
ORDER BY MinPrice ASC, MaxPrice DESC;

--------------------------------------------------------------------------------------------------------

 -> Confirm there are multiple restaurants in New York, but none in New York City

SELECT Name, Location, MinPrice, MaxPrice
FROM Michelin_Awarded
WHERE Location = 'New York';

SELECT Name, Location, MinPrice, MaxPrice
FROM Michelin_Awarded
WHERE Location = 'New York City';

 -> Update query

UPDATE Michelin_Awarded
SET Location = 'New York City'
WHERE Location = 'New York';

 -> Confirm there is no entry for New York, but that New York City returns the same results as before

 SELECT Name, Location, MinPrice, MaxPrice
FROM Michelin_Awarded
WHERE Location = 'New York';

SELECT Name, Location, MinPrice, MaxPrice
FROM Michelin_Awarded
WHERE Location = 'New York City';


 -> Get all restaurants in Birmingham, UK

SELECT Name, Location, MinPrice, MaxPrice
FROM Michelin_Awarded
WHERE Location = 'Birmingham'
     AND Currency = 'GBP';

UPDATE Michelin_Awarded
SET MinPrice = 50
WHERE Location = 'Birmingham'
     AND Currency = 'GBP';

SELECT Name, Location, MinPrice, MaxPrice
FROM Michelin_Awarded
WHERE Location = 'Birmingham'
     AND Currency = 'GBP';

 -> Updating multiple values

UPDATE Michelin_Awarded
SET MinPrice = 60, 
    MaxPrice = 100
WHERE Location = 'Birmingham'
     AND Currency = 'GBP';

SELECT Name, Location, MinPrice, MaxPrice
FROM Michelin_Awarded
WHERE Location = 'Birmingham'
     AND Currency = 'GBP';


 -> Before a delete, we query for restaurants where the Phone number field is NULL Observe the restaurant Atomix in New York City

SELECT Name, Location, MinPrice, MaxPrice, PhoneNumber
FROM Michelin_Awarded
WHERE PhoneNumber IS NULL; 

DELETE FROM Michelin_Awarded
WHERE PhoneNumber IS NULL;

SELECT Name, Location, MinPrice, MaxPrice, PhoneNumber
FROM Michelin_Awarded
WHERE PhoneNumber IS NULL; 