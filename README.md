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

## Analytical Query
