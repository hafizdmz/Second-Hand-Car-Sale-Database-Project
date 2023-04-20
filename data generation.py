import psycopg2
from faker import Faker
import random

# Connect to PostgresSQL database
conn = psycopg2.connect(
    dbname="used_car_website",
    user="postgres",
    password="onlyme",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

# Create am Indonesian data Faker object
fake = Faker('id_ID')

# generate random data for buyers table
for i in range(30):
    buyer_id = i + 1
    first_name = fake.first_name()
    last_name = fake.last_name()
    buyer_name = first_name + ' ' + last_name
    email = first_name.lower() + '.' + last_name.lower() + '@example.com'
    phone_number = fake.phone_number()
    city_id = random.choice([3171, 3172, 3173, 3174, 3175, 3573, 3578, 3471, 3273, 1371, 1375, 6471, 6472, 7371, 5171])

    sql = """
    INSERT INTO buyers (buyer_id, buyer_name, email, phone_number, city_id)
    VALUES (%s, %s, %s, %s, %s);
    """
    cursor.execute(sql, (buyer_id, buyer_name, email, phone_number, city_id))


# generate random data for seller table
for i in range(15):
    seller_id = i + 1
    first_name = fake.first_name()
    last_name = fake.last_name()
    seller_name = first_name + ' ' + last_name
    email = first_name.lower() + '.' + last_name.lower() + '@example.com'
    phone_number = fake.phone_number()
    city_id = random.choice([3171, 3172, 3173, 3174, 3175, 3573, 3578, 3471, 3273, 1371, 1375, 6471, 6472, 7371, 5171])

    sql = """
        INSERT INTO sellers (seller_id, seller_name, email, phone_number, city_id)
        VALUES (%s, %s, %s, %s, %s);
        """
    cursor.execute(sql, (seller_id, seller_name, email, phone_number, city_id))


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


# Commit and close the database connection
conn.commit()
cursor.close()
conn.close()
