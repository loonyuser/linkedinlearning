.logon 192.168.221.128/dbc, dbc;

.export file = D:\Courses\Teradata\out.txt;

DATABASE Restaurants;

INSERT INTO Michelin_Awarded (GlobalID, Name, Address, Location, 
   MinPrice, MaxPrice, Currency, Longitude, 
   Latitude, PhoneNo, MichelinLink, URL, Award)
VALUES (2, 'Zoldering', 'Utrechtsestraat 141h Amsterdam, 1017 VM Netherlands', 'Amsterdam',
   65, 65, 'EUR', 4.8993625, 52.361354,   
   31207651212, 'https://guide.michelin.com/en/noord-holland/amsterdam/restaurant/zoldering',
   'https://www.zoldering.nl/',  '1 MICHELIN Star');

INSERT INTO Michelin_Awarded (GlobalID, Name, Address, Location, 
   MinPrice, MaxPrice, Currency, Longitude, 
   Latitude, PhoneNo, MichelinLink, URL, Award)
VALUES (3, 'R-Haan', '131 Soi Sukhumvit 53, Khlong Tan Nuea, Bangkok, 10110', 'Bangkok',
   3812, 3812, 'THB', 100.57972, 13.731805,   
   6620590433, 'https://guide.michelin.com/en/bangkok-region/bangkok/restaurant/r-haan',
   'https://www.r-haan.com/',  '2 MICHELIN Stars');

INSERT INTO Michelin_Awarded (GlobalID, Name, Address, Location, 
   MinPrice, MaxPrice, Currency, Longitude, 
   Latitude, PhoneNo, MichelinLink, URL, Award)
VALUES (4, 'Sumibi Kappo Ishii', '7-17-11 Fukushima, Fukushima-ku, Osaka, 553-0003, Japan', 'Osaka',
   20000, 33000, 'JPY', 135.484848, 34.699749,   
   81677084692, 'https://guide.michelin.com/en/osaka-region/osaka/restaurant/sumibi-kappo-ishii',
   NULL,  '1 MICHELIN Star');


.set width 65531
.set separator '|'

SELECT * FROM Michelin_Awarded;

.logoff
.exit




