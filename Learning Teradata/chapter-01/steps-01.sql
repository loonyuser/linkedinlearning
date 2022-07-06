-----------------------------------------
Chapter 01 - Installing Teradata Vantage
-----------------------------------------

Pre-requisites:
----------------
1- Windows OS
2- 35 - 40GB storage and CPU and RAM to be able to dedicate atleast one core and  6GB+ to the virtual machine

Installation:
--------------
-> Create an account at https://downloads.teradata.com/user/register and login to access the download
-> https://downloads.teradata.com/download/database/teradata-express-for-vmware-player

-> download the latest version of vantage express (7z zip file) for me this is VantageExpress17.10_Sles12_202108300444.7z
-> unzip the file(using 7zip or winrar) in a location of choice on your drive (C:/Tools/Teradata)


->	VMWare Workstation player
	-------------------------
	-> For downloading VMWare Workstation player go to: https://www.vmware.com/in/products/workstation-player/workstation-player-evaluation.html
	-> Choose the windows workstation player and click on download now.
	-> Follow the install instructions and keep the defaults

-> Open the VMWare Workstation Player
-> On the right pane select "Open a Virtual Machine"
-> Navigate to the unzipped VantageExpress17.10_Slez12(or similar for your version) folder 
-> Select the .vmx (VantageExpress17.10_Slez12.vmx) file and select OK
-> This will boot up the vantage express image on VMWare
-> Once the boot up is done vantage express will ask you to login to the system
	Login		: root
	password 	: root

Test the installation
----------------------
-> On logging on to vantage express you will be presented with a virtual desktop with the vantage apps such as "Gnome Terminal", "Start teradata", etc...
-> If the virtual desktop is scaled smaller then head to the down arrow next to the power and click on the settings icon on the popup that opens up.
-> Go to the unknown display and change the resolution to (1280 X 768) click on apply.
-> double click to launch the Gnome Terminal to check if teradata database is up and running. (here pde stands for Parallel database extension) 
-> type -> pdestate -a 
   at the VantageExpress1710-Sles12:~ # and hit enter
	If you get the following result it means the database is up and running
	PDE state is RUN/STARTED
	DBS state is 5: Logons are enabled - The system is quiescent.


To Start the database
---------------------
If the PDE State is not RUN/STARTED then you can start the database by

-> on the gnome terminal

->type -> /etc/init.d/tpa start

You can also start the database by double clicking on the "start teradata" application on the virtual desktop. 	


Teradata Studio on the host OS
-------------------------------

-> Now that the teradata database is up and running, head back to the virtual desktop to open up the teradata studio application by double clicking on the icon.
-> On the first start you will be presented with a quick tour, which gives a quick overview about the 3 perspectives of the teradata studio 1) Administration 2) Query development, and 3) Data transfer.
-> Once the tour is over you will be presented with a wizard window to add a new connection.
	fill in the details as follows:
	
	Connection profile types : teradata
	Name 					 : Loony Teradata
	Desc 					 : (leave blank)
	
-> Click on next

-> This opens up the teradata connection profile which asks to specify the driver and connection details
	fill in the details as follows:
	Database Server Name	: localhost
	User Name[Domain] 		: dbc
	password				: dbc
	
	rest remain default
	
	check the save password checkbox
	
	let the jdbc settings also remain as default.
	
	let the "connect when the wizard completes" checkbox remain checked.
	
	click the test connection to check if everything is configured correctly.
	
	Ping succeeded tells that the connection profile is configured correctly.
	
	Finally click on finish to connect to the database.
	
Write basic queries
--------------------

-> To start writing queries change the perspective from Administration to Query development. 
	
		-> Switch to the second tab named query development at top right of teradata studio.
		-> you can also change from window menu -> Query Development from the top menu.

-> If the connection to the database is not established already double click Loony teradata connection profile under database connections in the data source tab(left pane).

-> Expand the menu on the left DBC -> Databases
-> Note the list of databases - there is no Restaurants database. We will 

Create a database
------------------ 
-> To create a database use the following query.
	CREATE DATABASE Restaurants
	AS PERMANENT = 60e6, 
		SPOOL = 120e6;

-> Here, Permanent | Perm Space – Max amount of space available for Tables  60e6 equates to 60 MB  
		 Spool Space – Max amount of space available for query processing	120e6 equates to 120 MB
		 You can also use
		 Temp Space – Used for creating a temporary table.
		 
-> On the left menu, right-click on Databases and Refresh. Restaurants now shows up here

--> Expand Restaurants --> Tables - it is empty
		 
Create a Table
---------------
-> let''s create a table and populate it with some data
-> A SET table does not allow duplicates, as opposed to MULTISET TABLES which do

CREATE SET TABLE Restaurants.Michelin_Awarded (
   GlobalID INTEGER,
   Name VARCHAR(70),
   Address VARCHAR(150),
   Location VARCHAR(50),
   MinPrice INTEGER,
   MaxPrice INTEGER,
   Currency CHAR(3),
   Longitude INTEGER,
   Latitude INTEGER,
   PhoneNo BIGINT,
   MichelinLink VARCHAR(300),
   URL Varchar(300),
   Award VARCHAR(100)
)
UNIQUE PRIMARY INDEX ( GlobalID );


##
## Data source: https://www.kaggle.com/datasets/ngshiheng/michelin-guide-restaurants-2021

Insert values to the created table
-----------------------------------
INSERT INTO Restaurants.Michelin_Awarded (
   GlobalID,
   Name,
   Address,
   Location,
   MinPrice,
   MaxPrice,
   Currency,
   Longitude,
   Latitude,
   PhoneNo,
   MichelinLink,
   URL,
   Award
)
VALUES (
   1,
   'Aqua',
   'Parkstrasse 1, Wolfsburg, 38440, Germany',
   'Wolfsburg',
   225,
   225,
   'EUR',
   10.789999,
   52.4331722,
   495361606056,
   'https://guide.michelin.com/en/niedersachsen/wolfsburg/restaurant/aqua79029',
   'http://www.restaurant-aqua.com',
   '3 MICHELIN Stars'
);

Retrieve the data
------------------
SELECT * FROM Restaurants.Michelin_Awarded;

Basic Teradata Query (BTEQ)
---------------------------
-> On the Gnome Terminal type -> bteq
-> This will open up BTEQ for you and ask you to enter your logon
	type -> .logon 127.0.0.1/dbc
-> bteq will ask you for password next
	type -> dbc
-> once logged on you can run SQL requests or BTEQ commands here
-> to select a data from a table run the following query

	SELECT Name, Award FROM Restaurants.Michelin_Awarded;

-> Exit the BTEQ shell by typing this
.quit
	

Shutting down the database (Use TPA Reset only when absolutely necessary)
--------------------------------------------------------------------------
Please NOTE: I faced that the database once shutdown/ hardstop I could not start the database again. I had to reinstall again.

-> type -> tpareset -x {trying a shutdown}

tpareset -option {comment} where option can be one of
-xit
-exit
-stop
-force
-panic
-nodump
-dump
-yes

and
-help


TPA Reset can be used:

- after Teradata Database has been reconfigured
- to activate new versions of Teradata Database software
- to recover from a database hang
- in other situations that warrant a full database shutdown and restart


-> Power off the VM