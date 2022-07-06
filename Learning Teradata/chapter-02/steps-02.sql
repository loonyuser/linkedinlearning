----------------------------------------------------------------------
Chapter 02 - Install Tools and Utilities for Teradata Vantage Express
----------------------------------------------------------------------


-> Instead of using tools in the virtual environment we can get them installed on the windows machine and point to vantage express to use them.

-> Go to https://downloads.teradata.com/download/tools/teradata-tools-and-utilities-windows-installation-package and download 
		TTU 17.10.16.00 Windows - Base
		 
-> After the download completes unzip the file to a location of choice (C:\Tools\Teradata)

-> Open the unzipped TeradataToolsAndUtilitiesBase__windows_indep.17.10.15.00\TeradataToolsAndUtilitiesBase folder and install using the setup.bat
-> When the installation wizards asks select the following features:
	ODBC Driver for Teradata
	BTEQ
	FastExport
	MultiLoad
	and, TPump
-> Click the install button to install these features.


-> to check if the installation is working properly lets open bteq in the command prompt.

-> for this firstly we need the ip address of vantage express.

IP Address of vantage express
------------------------------
-> Open up the teradata virtual desktop on your VMware Workstation
-> Go to the gnome terminal and type ifconfig 
	-> the result will contain values each for eth0 and lo(localhost)
	-> in the eth0 settings on the second line copy the value for inet addr: 192.168.221.128 (for me)
	-> Save/Note this value as it will be used to connect to the teradata tools.



Access BTEQ from command prompt
--------------------------------
-> once you have installed Teradata Tools and Utilities you can access BTEQ from the command prompt.
-> open command prompt navigate to C:\Users\admin\teradata\ and Type in bteq
-> This will open the bteq prompt and ask you to enter your logon simalar to what we saw in Gnome terminal on the virtual desktop
	
	type -> .logon 192.168.221.128/dbc 
	(This is the inet addr value you got for eth0 in the previous step)
	hit enter
	
-> you will be asked to provide the password
	type -> dbc
	
-> now you will be logged in and can interact with the teradata database
-> you can interact with teradata with 2 bteq modes.

1) interactive mode - write the command and get the result

BTEQ -- Enter your SQL request or BTEQ command:
Database Restaurants;


 *** New default database accepted.
 *** Total elapsed time was 1 second.
----------------------------------------------------------------------------------------------------------------------------------------------
 BTEQ -- Enter your SQL request or BTEQ command:
SELECT Name, Location, URL, Award FROM Michelin_Awarded;

SELECT Name, Location, URL, Award FROM Michelin_Awarded;

 *** Query completed. One row found. 4 columns returned.
 *** Total elapsed time was 1 second.

Name                                                                   Loca
---------------------------------------------------------------------- ----
Aqua                                                                   Wolf

-> The default screen width is 75 characters which will limit the size of result printed on the screen. 
-----------------------------------------------------------------------------------------------------------------------------------------------
BTEQ -- Enter your SQL request or BTEQ command:
.set width 65531

.set width 65531
----------------------------------------------------------------------------------------------------------------------------------------------- 
BTEQ -- Enter your SQL request or BTEQ command:
.set separator '|'

.set separator '|'
-----------------------------------------------------------------------------------------------------------------------------------------------
BTEQ -- Enter your SQL request or BTEQ command:
SELECT Name, Location, URL, Award FROM Michelin_Awarded;

SELECT Name, Location, URL, Award FROM Michelin_Awarded;

 *** Query completed. One row found. 4 columns returned.
 *** Total elapsed time was 1 second.

Name                                                                  |Location                                          |URL                                                                                                                                                                                                                                                                                                         |Award
---------------------------------------------------------------------- -------------------------------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ ----------------------------------------------------------------------------------------------------
Aqua                                                                  |Wolfsburg                                         |http://www.restaurant-aqua.com                                                                                                                                                                                                                                                                              |3 MICHELIN Stars
-------------------------------------------------------------------------------------------------------------------------------------------------

 BTEQ -- Enter your SQL request or BTEQ command:
.logoff

.logoff
 *** You are now logged off from the DBC.
 Teradata BTEQ 17.10.00.07 (64-bit) for WIN64. 
-------------------------------------------------------------------------------------------------------------------------------------------------- 
 Enter your logon or BTEQ command:
.exit

.exit
 *** Exiting BTEQ...
 *** RC (return code) = 8


2) batch mode
-> we can also run the commands in a batch from a file. Let''s run the following file and export the result to another file named out.txt

restaurants_batch_insert.sql
-------------------  

-> These details in the file may need to be modified:
    - The IP address of the Teradata Vantage host
    - The Location of the output file

--------------------------------------------------------------------------------------------------------------------------------------------------

-> In command prompt type -> bteq

 .run file D:\Courses\Teradata\demos\restaurants_batch_insert.sql

Output on command prompt is as follows:
---------------------------------------

 Teradata BTEQ 17.10.00.07 (64-bit) for WIN64. Enter your logon or BTEQ command:

.logon 192.168.1.9/dbc,

 *** Logon successfully completed.
 *** Teradata Database Release is 17.10.03.01
 *** Teradata Database Version is 17.10.03.01
 *** Transaction Semantics are BTET.
 *** Session Character Set Name is 'ASCII'.

 *** Total elapsed time was 1 second.

 BTEQ -- Enter your SQL request or BTEQ command:

.export file = C:\Users\admin\teradata\out.txt;
 *** Warning: No data format given. Assuming REPORT carries over.
 *** To reset export, type .EXPORT RESET
 BTEQ -- Enter your SQL request or BTEQ command:

.EXPORT RESET
 *** Output returned to console.
 BTEQ -- Enter your SQL request or BTEQ command:

.export file = C:\Users\admin\teradata\out.txt;
 *** Warning: No data format given. Assuming REPORT carries over.
 *** To reset export, type .EXPORT RESET
 BTEQ -- Enter your SQL request or BTEQ command:


.set width 65531
 BTEQ -- Enter your SQL request or BTEQ command:

.set separator '|'
 BTEQ -- Enter your SQL request or BTEQ command:


Database Restaurants;

 *** New default database accepted.
 *** Total elapsed time was 1 second.


 BTEQ -- Enter your SQL request or BTEQ command:

SELECT * FROM Michelin_Awarded;

 *** Query completed. One row found. 13 columns returned.
 *** Total elapsed time was 1 second.


 BTEQ -- Enter your SQL request or BTEQ command:


.logoff
 *** You are now logged off from the DBC.
 Teradata BTEQ 17.10.00.07 (64-bit) for WIN64. Enter your logon or BTEQ command:

.exit
 *** Exiting BTEQ...
 *** RC (return code) = 0
 ---------------------------------------------------------------------------------------------------------------------------------------------
 
 -> open the out.txt file in Sublime Text or a text editor of your choice
 -> It will contain the output of the SELECT query 

 -------------------------------------------------------------------------------------------------------------------------------------------------


 ->  Head to Teradata -> Generate SQL -> SELECT Statement
  -> Run the generated query which should look like the one below (and returns no data:

SELECT "GlobalID",
    "Name",
    "Address",
    "Location",
    "MinPrice",
    "MaxPrice",
    "Currency",
    "Longitude",
    "Latitude",
    "PhoneNo",
    "MichelinLink",
    "URL",
    "Award"
FROM "Restaurants"."Michelin_Awarded";



-> Modify the FROM clause in the above query so that it no longer references the Restaurants database:

SELECT "GlobalID",
    "Name",
    "Address",
    "Location",
    "MinPrice",
    "MaxPrice",
    "Currency",
    "Longitude",
    "Latitude",
    "PhoneNo",
    "MichelinLink",
    "URL",
    "Award"
FROM "Michelin_Awarded";


-> Running the query will return a message like "Object Michelin_Awarded not found"

-> Set the database:

DATABASE Restaurants;

-> Re-run the same SELECT query without the database mentioned explicitly. Now it works


DDL Statements - defining databases and tables


 -> View the definition of the table

SHOW TABLE Michelin_Awarded;

 -> You will likely need to right-click on the "Request Text" in the query result and paste it in a text editor (such as Sublime Text) to view clearly
 -> It will look something like this:

CREATE SET TABLE Restaurants.Michelin_Awarded ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO,
     MAP = TD_MAP1
     (
      GlobalID INTEGER,
      Name VARCHAR(70) CHARACTER SET LATIN CASESPECIFIC,
      Address VARCHAR(150) CHARACTER SET LATIN CASESPECIFIC,
      Location VARCHAR(50) CHARACTER SET LATIN CASESPECIFIC,
      MinPrice INTEGER,
      MaxPrice INTEGER,
      Currency CHAR(3) CHARACTER SET LATIN CASESPECIFIC,
      Longitude INTEGER,
      Latitude INTEGER,
      PhoneNo BIGINT,
      MichelinLink VARCHAR(300) CHARACTER SET LATIN CASESPECIFIC,
      URL VARCHAR(300) CHARACTER SET LATIN CASESPECIFIC,
      Award VARCHAR(100) CHARACTER SET LATIN CASESPECIFIC)
UNIQUE PRIMARY INDEX ( GlobalID );


 -> to View schema information, run the HELP command

HELP TABLE Michelin_Awarded;


 -> Add a new column to the table

ALTER TABLE Michelin_Awarded 
ADD Cuisine varchar(32)
DEFAULT 'Yet to be added';

 -> Confirm the change to the schema using both HELP and SHOW commands

HELP TABLE Michelin_Awarded;

SHOW TABLE Michelin_Awarded;

 -> Confirm the use of the default value for the Cuisine column

SELECT Name, Location, Cuisine 
FROM Michelin_Awarded;


 -> Dropping a column from a table
 -> Run the ALTER query below and confirm the schema

ALTER TABLE Michelin_Awarded 
DROP MichelinLink;

SHOW TABLE Michelin_Awarded;

 -> Drop the longitude and latitude columns as well (dropping multiple columns) and confirm the schema

ALTER TABLE Michelin_Awarded 
DROP Longitude, 
DROP Latitude;

SHOW TABLE Michelin_Awarded;


 -> Change the type of an existing column

ALTER TABLE Michelin_Awarded 
ADD Location VARCHAR(80);

-> things to keep in mind when altering 
1 Length of the datatype cannot be reduced and user can only increase the length of datatype. Users will get below error if they try to reduce length.
*** Failure 3558 Cannot alter the specified attribute(s) for column_name
2 Datatype of columns cannot be changed if old datatype of column and new datatype of column are not compatible. Users will get below error if they try to change datatype.
*** Failure 3558 Cannot alter the specified attribute(s) for column_name
3 Primary index can be changed only for an empty table. Users will get below error if they try to change primary index of populated table.
*** Failure 5735 The primary index columns may not be altered for a nonempty table.
4 Column must be 'NOT NULL' to define primary key on that column of table, otherwise it will fail with below error.
*** Failure 5323 The PRIMARY KEY column 'order_id' must be NOT NULL.

SHOW TABLE Michelin_Awarded;


 -> Rename column

ALTER TABLE Michelin_Awarded 
RENAME Location TO City;

SHOW TABLE Michelin_Awarded;



 -> Confirm the contents of the table

SELECT * FROM Michelin_Awarded;

 -> Clear out the table and confirm its emptiness (an alternate delete query is "DELETE FROM Michelin_Awarded")

DELETE FROM Michelin_Awarded ALL;

SELECT * FROM Michelin_Awarded;


DROP TABLE
----------

DROP TABLE Michelin_Awarded;

Go to the data source explorer on the left and refresh the Restaurants database. Now under the tables there should be no entity









--------------------------------------------------------------------------------------------------
