############################################################
############### Creating Nested Fields #####################
############################################################

## The schema definition of the initial customers table, for reference
[
    {
        "name": "id",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "firstname",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "lastname",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "address",
        "type": "RECORD",
        "mode": "NULLABLE",
        "fields": [
            {
                "name": "street",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "city",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "county",
                "type": "STRING",
                "mode": "NULLABLE"
            }
        ]
    },
    {
        "name": "phonenumbers",
        "type": "STRING",
        "mode": "REPEATED"
    }
]

INSERT INTO `sales_data.customers` (id, firstname, lastname, address, phonenumbers)
VALUES (1, 'Lucy', 'Diamond', 
        STRUCT('40 Kingsley Road', 'Liverpool', 'Merseyside'), 
        ['555-1234', '555-1235'])

## Add a new field to hold payment modes
## For reference, here is the definition
[
    {
        "name": "paymentmodes",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "type",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "name",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "number",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "expiration",
                "type": "STRING",
                "mode": "NULLABLE"
            }
        ]
    }
]

## Insert a new row 
INSERT INTO `sales_data.customers` (id, firstname, lastname, address, phonenumbers, paymentmodes)
VALUES (2, 'Kyle', 'Weissman', 
        STRUCT('40 Kingsley Road', 'Liverpool', 'Merseyside'), 
        ['555-1234', '555-1235'],
        [STRUCT('credit', 'Kyle W', '1234', '2026-07-31'),
         STRUCT('ewallet', 'weissmankarl', '3451', NULL),
         STRUCT('credit', 'Kyle Weissman', '9876', '2027-11-30')])


## Note that structs can be specified with parentheses
## The STRUCT keyword is not necessary when inserting
INSERT INTO `sales_data.customers` (id, firstname, lastname, address, phonenumbers, paymentmodes)
VALUES (3, 'Sven', 'Frederiksson', 
        ('44 Kingsley Road', 'Liverpool', 'Merseyside'), 
        ['555-0000'],
        [('debit', 'Sven F', '9876', '2026-05-31'),
         STRUCT('ewallet', 'svenf', '1001', NULL)])


## View the contents of the table
SELECT * FROM `sales_data.customers`



############################################################
############### Querying Nested Fields #####################
############################################################


SELECT firstname, lastname,
       address.city, address.county,
       phonenumbers[OFFSET(0)] AS primaryphone
FROM `sales_data.customers`

## We'll get an ArrayIndexOutOfBounds error if we try to 
## 		access the payment mode info for Lucy Diamond
## We can filter out rows with no payment modes


SELECT firstname, lastname,
       address.city, address.county,
       phonenumbers[OFFSET(0)] AS primaryphone,
       (CASE WHEN ARRAY_LENGTH(paymentmodes) > 0 
             THEN paymentmodes[OFFSET(0)].type 
             ELSE NULL END) AS paymentmodetype, 
       (CASE WHEN ARRAY_LENGTH(paymentmodes) > 0 
             THEN paymentmodes[OFFSET(0)].number 
             ELSE NULL END) AS paymentmodenumber
FROM `sales_data.customers`


SELECT firstname, lastname,
       phonenumber
FROM `sales_data.customers`, 
    UNNEST(phonenumbers) AS phonenumber

SELECT firstname, lastname,
       paymentmode
FROM `sales_data.customers`, 
    UNNEST(paymentmodes) AS paymentmode

SELECT firstname, lastname,
       paymentmode.type, paymentmode.expiration
FROM `sales_data.customers`, 
    UNNEST(paymentmodes) AS paymentmode


INSERT INTO `sales_data.customers` (id, firstname, lastname, address, phonenumbers)
VALUES (6, 'Fatima', 'Ibrahim', 
        STRUCT('13 Crompton Road', 'Newcastle', 'Tyne and Wear'), 
        ['555-5555']),
        (7, 'Eva', 'Ivanova', 
        STRUCT('12 Crompton Road', 'Newcastle', 'Tyne and Wear'), 
        ['555-6666']),
        (11, 'Gbenga', 'Taibu', 
        STRUCT('8 Algiers Road', 'Portsmouth', 'Hampshire'), 
        ['555-6666'])


SELECT address.city, COUNT(*) AS custumercount
FROM `sales_data.customers`
GROUP BY address.city


SELECT address.city, 
       ARRAY_AGG(firstname) AS firstname,
       ARRAY_AGG(lastname) AS lastname
FROM `sales_data.customers`
GROUP BY address.city


SELECT address.city, 
       ARRAY_AGG(firstname) AS firstname,
       ARRAY_AGG(lastname) AS lastname,
       ARRAY_AGG(phonenumbers[OFFSET(0)]) AS primaryphones
FROM `sales_data.customers`
GROUP BY address.city




############################################################
################# Window Operations ########################
############################################################


CREATE TABLE `sales_data.automobiles_condensed`
AS
SELECT maker, model, body_type, mileage, date_created,
       engine_displacement, engine_power, price_eur
FROM `sales_data.automobiles`
WHERE maker IS NOT NULL 
    AND maker IS NOT NULL
    AND model IS NOT NULL
    AND body_type IS NOT NULL
    AND mileage IS NOT NULL
    AND engine_displacement IS NOT NULL
    AND engine_power IS NOT NULL
    AND manufacture_year = 2016
    AND price_eur BETWEEN 20000 AND 30000


SELECT maker, model, price_eur,
       RANK() OVER (PARTITION BY maker ORDER BY price_eur) AS rank
FROM `sales_data.automobiles_condensed`
ORDER BY maker, rank

SELECT * 
FROM (SELECT maker, model, price_eur,
        RANK() OVER (PARTITION BY maker ORDER BY price_eur) AS rank
        FROM `sales_data.automobiles_condensed`
)
WHERE rank <= 5
ORDER BY maker, rank



SELECT * 
FROM (SELECT maker, model, engine_power, price_eur,
        RANK() OVER (PARTITION BY maker ORDER BY engine_power DESC) AS rank
        FROM `sales_data.automobiles_condensed`
)
WHERE rank <= 10
ORDER BY maker, rank