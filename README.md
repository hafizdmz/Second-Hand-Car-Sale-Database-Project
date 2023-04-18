# Second-Hand-Car-Sale-Database-Project

## Introduction and Project Objective
Welcome to the Second Hand Car Sale Database Project! The goal of this project is to design and implement a comprehensive database for managing the transactions of used cars. The database will store information about car products, sellers, buyers, cities, bids, and adverts, and will facilitate the tracking of car listings and bidding activities. 

The project will utilize PostgreSQL as the database management system and will be populated with realistic dummy data generated using Python and the Faker module. The database design will incorporate tables, relationships, and data types suitable for managing car sales transactions, and will provide a solid foundation for building a used car sales system. Through this project, we aim to create an efficient and scalable database solution that can be easily integrated with other components of a larger used car sales system.

## ERD
Graphical representation of the database schema, depicting the relationships between different entities and their attributes.
![used car ERD](https://user-images.githubusercontent.com/122255417/232669955-f6eb90aa-96e1-47e4-9ada-fe662dbf7e2a.png)

## Syntax DDL
SQL statements used to define the structure of the database, including creating tables, specifying column names and data types, setting primary and foreign keys, and defining constraints.
```
CREATE TABLE IF NOT EXISTS public.car_products
(
    car_id integer NOT NULL DEFAULT nextval('car_products_car_id_seq'::regclass),
    brand character varying COLLATE pg_catalog."default" NOT NULL,
    car_mode character varying COLLATE pg_catalog."default" NOT NULL,
    body_type character varying COLLATE pg_catalog."default" NOT NULL,
    prod_year integer NOT NULL,
    price double precision NOT NULL,
    CONSTRAINT car_pk PRIMARY KEY (car_id)
);
```

## Dummy dataset
The database is populated with realistic dummy data using Python and the Faker module. 
```
import psycopg2
from faker import Faker
import random
 
# Connect to PostgresSQL database
conn = psycopg2.connect(
    dbname="used_car_website",
    user="postgres",
    password="***",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

# Create am Indonesian data Faker object
fake = Faker('id_ID')

# Generate random data for adverts table
for i in range(50):  
    advert_id = i + 1  
    car_id = fake.unique.random_int(min=1, max=50)  
    date_posted = fake.date_between(start_date='-1y', end_date='today')
    seller_id = fake.random_int(min=1, max=15)  
    sql = """
            INSERT INTO adverts (advert_id, car_id, date_posted, seller_id)
            VALUES (%s, %s, %s, %s);
            """
    cursor.execute(sql, (advert_id, car_id, date_posted, seller_id))
    conn.commit()
```

## Transactional Query
Case : Finding all cars sold by seller 'Daru Pratiwi'
```
SELECT a.car_id, brand, car_mode, prod_year, price, date_posted
FROM sellers
         JOIN adverts a ON sellers.seller_id = a.seller_id
         JOIN car_products cp ON cp.car_id = a.car_id
WHERE seller_name = 'Daru Pratiwi';
```


Case : Nearest car sold from city_id 3173
```
SELECT a.car_id,
       brand,
       car_mode,
       prod_year,
       price,
       SQRT((latittude - (-6.1352)) ^ 2 + (longitude - (106.813301)) ^ 2) AS distance
FROM adverts a
         JOIN car_products cp ON a.car_id = cp.car_id
         JOIN sellers s ON s.seller_id = a.seller_id
         JOIN cities c ON c.city_id = s.city_id
ORDER BY distance;
```

## Analytical Query
Case : Price comparison based for each city
```
SELECT city_name, brand, car_mode AS model, prod_year AS year, price, AVG(price) OVER (PARTITION BY car_mode, prod_year)
FROM car_products
         JOIN adverts a ON car_products.car_id = a.car_id
         JOIN sellers s ON s.seller_id = a.seller_id
         JOIN cities c ON s.city_id = c.city_id
ORDER BY city_name, model;
```

Case: Percentage comparison of car price and bid price in the last 6 months
```
WITH average_price AS (SELECT car_mode, ROUND(AVG(price)) AS avg_price
                       FROM adverts a
                                JOIN car_products cp ON cp.car_id = a.car_id
                       GROUP BY car_mode),
     average_6months_bid AS (SELECT car_mode, ROUND(AVG(bid_price)) AS avg_bid_6months
                             FROM adverts a
                                      JOIN bids b ON a.advert_id = b.advert_id
                                      JOIN car_products c ON c.car_id = a.car_id
                             WHERE bid_date >= NOW() - INTERVAL '6 months'
                             GROUP BY car_mode)
SELECT am.car_mode                                     AS model,
       avg_price,
       avg_bid_6months,
       (avg_price - avg_bid_6months)                   AS difference,
       (avg_price - avg_bid_6months) / avg_price * 100 AS diff_percentage
FROM average_price ap
         JOIN average_6months_bid am ON am.car_mode = ap.car_mode
ORDER BY diff_percentage DESC;
```
