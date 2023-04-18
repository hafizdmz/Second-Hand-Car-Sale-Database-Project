--case 1: car produced on 2015 onwards
select *
from car_products
where prod_year >= 2015;

--case 2: add new data on bids table
insert into bids (bid_id, advert_id, buyer_id, bid_price, bid_date, bid_status)
values (51, 15, 4, 115000000, '2023-02-17', 'pending');

--case 3: all cars sold by seller 'Daru Pratiwi'
select a.car_id, brand, car_mode, prod_year, price, date_posted
from sellers
         join adverts a on sellers.seller_id = a.seller_id
         join car_products cp on cp.car_id = a.car_id
where seller_name = 'Daru Pratiwi';

--case 4:
select *
from car_products
where car_mode like '%Yaris'
order by price;

--case 5: nearest car sold from city_id 3173
select a.car_id,
       brand,
       car_mode,
       prod_year,
       price,
       sqrt((latittude - (-6.1352)) ^ 2 + (longitude - (106.813301)) ^ 2) as distance
from adverts a
         join car_products cp on a.car_id = cp.car_id
         join sellers s on s.seller_id = a.seller_id
         join cities c on c.city_id = s.city_id
order by distance;