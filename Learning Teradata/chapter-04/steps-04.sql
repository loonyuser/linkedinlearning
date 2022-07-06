------------------------------------
Chapter 04 - Aggregations and Joins
------------------------------------




GROUP BY
---------

 -> View all locations with CNY (Chinese Yuan) as the currency. There are a total of 4.

SELECT DISTINCT Location
FROM Michelin_Awarded
WHERE Currency = 'CNY';

 -> Count the total number of China-based restaurants

SELECT COUNT(ID) 
FROM Michelin_Awarded 
WHERE Currency = 'CNY';

SELECT COUNT(*) 
FROM Michelin_Awarded 
WHERE Currency = 'CNY';

 -> Count the number of restaurants in each location

SELECT Location, COUNT(ID) 
FROM Michelin_Awarded 
WHERE Currency = 'CNY'
GROUP BY Location;


SELECT Location, COUNT(ID) AS RestCount 
FROM Michelin_Awarded 
WHERE Currency = 'CNY'
GROUP BY Location;

 -> The HAVING clause

SELECT Location, COUNT(ID) AS RestCount 
FROM Michelin_Awarded 
WHERE Currency = 'CNY'
GROUP BY Location
HAVING RestCount >= 50;

 -> Remove the currency clause, so we now operate at a global level

SELECT Location, COUNT(ID) AS RestCount 
FROM Michelin_Awarded 
GROUP BY Location
HAVING RestCount >= 50

 -> Apply an ordering

SELECT Location, COUNT(ID) AS RestCount 
FROM Michelin_Awarded 
GROUP BY Location
HAVING RestCount >= 50
ORDER BY RestCount DESC;

 -> Back to the China-based restaurants. Compute an Average, Min, and Max of prices

SELECT Location, 
	   COUNT(ID) AS RestCount, 
	   AVG(MinPrice) AS AvgMin, 
	   AVG(MaxPrice) AS AvgMax
FROM Michelin_Awarded
WHERE Currency = 'CNY'
GROUP BY Location
ORDER BY RestCount DESC;


SELECT Location, 
	   COUNT(ID) AS RestCount, 
	   MIN(MinPrice) AS MinMin, 
	   MIN(MaxPrice) AS MinMax
FROM Michelin_Awarded
WHERE Currency = 'CNY'
GROUP BY Location
ORDER BY RestCount DESC;

SELECT Location, 
	   COUNT(ID) AS RestCount, 
	   MAX(MinPrice) AS MaxMin, 
	   MAX(MaxPrice) AS MaxMax
FROM Michelin_Awarded
WHERE Currency = 'CNY'
GROUP BY Location
ORDER BY RestCount DESC;


--------------------------------------------------------------------------------------------------

 -> We prepare for joins by looking at the two other tables we have loaded

SELECT * FROM cuisine;

 -> Truncate to 2000 rows when the message pops up

SELECT * FROM cuisine_mapping;

 -> View just the Munich-based restaurants
SELECT Name, Location, Award
FROM Michelin_Awarded
WHERE Location = 'Munich';

 -> INNER JOIN with the Cuisine_Mapping table. This gives us the Cuisine ID which is not quite meaningful

SELECT Name, Location, Award, Cuisine_Id
FROM Michelin_Awarded RestTable
	 INNER JOIN Cuisine_Mapping CMap
	 	ON RestTable.ID = CMap.Restaurant_ID
WHERE Location = 'Munich'
ORDER BY Cuisine_Id;


SELECT Name, Location, Award, Cuisine
FROM Michelin_Awarded RestTable
	 RIGHT JOIN Cuisine_Mapping CMap
	 	ON RestTable.ID = CMap.Restaurant_ID
	 INNER JOIN Cuisine
	 	ON CMap.Cuisine_Id = Cuisine.Cuisine_Id
WHERE Location = 'Munich'
ORDER BY Cuisine;



SELECT Cuisine_Id, Name, Award
FROM Michelin_Awarded RestTable
	 INNER JOIN Cuisine_Mapping CMap
	 	ON CMap.Restaurant_ID = RestTable.ID
WHERE Location = 'Munich'
ORDER BY Cuisine_Id;


------------------------------------------------------------------------------------

 -> To demonstrate outer joins, we will load a new dataset in a new database

CREATE DATABASE Movies
	AS PERMANENT = 60e6, 
		SPOOL = 120e6;

 -> Create 2 new tables - movies and directors - by smart loading data
 	- for movies, set a UNIQUE index and choose a type of SET
 	- for directors, there is no index, and the type is MULTISET 

 -> The source for the data is https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows

DATABASE Movies;

 -> Perform INNER, LEFT OUTER, and RIGHT OUTER joins

SELECT m.Series_Title, Released_Year, IMDB_Rating, Director
FROM movies m INNER JOIN directors d
	ON m.Series_Title = d.Series_Title;

SELECT m.Series_Title, Released_Year, IMDB_Rating, Director
FROM movies m LEFT OUTER JOIN directors d
	ON m.Series_Title = d.Series_Title;

SELECT m.Series_Title, Released_Year, IMDB_Rating, Director, d.Series_Title
FROM movies m RIGHT OUTER JOIN directors d
	ON m.Series_Title = d.Series_Title;


 -> Get the plan of execution

EXPLAIN
SELECT m.Series_Title, Released_Year, IMDB_Rating, Director
FROM movies m INNER JOIN directors d
	ON m.Series_Title = d.Series_Title;




