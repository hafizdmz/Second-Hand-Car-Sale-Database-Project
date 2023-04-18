--case 1: rank the car model based on total bid
with cte as (select car_mode, count(bid_id) as count_bid
             from adverts a
                      join bids b on a.advert_id = b.advert_id
                      join car_products cp on cp.car_id = a.car_id
             group by car_mode)

select cp.car_mode as model, count(cp.car_mode) as count_product, count_bid
from car_products cp
         join cte on cp.car_mode = cte.car_mode
group by cp.car_mode, cte.count_bid
order by count_bid desc
;
--case 2: price comparison based for each city
select city_name, brand, car_mode as model, prod_year as year, price, avg(price) over (partition by car_mode, prod_year)
from car_products
         join adverts a on car_products.car_id = a.car_id
         join sellers s on s.seller_id = a.seller_id
         join cities c on s.city_id = c.city_id
order by city_name, model;

--case 3:user bidding on single car model
select car_mode as model, buyer_id, bid_date, price
from adverts a
         join car_products cp on cp.car_id = a.car_id
         join bids b on a.advert_id = b.advert_id
order by buyer_id;

with buyers_bid as (select car_mode,
                           buyer_id,
                           bid_date,
                           bid_price,
                           row_number() over (partition by a.car_id, buyer_id order by bid_date) as bid_rank
                    from adverts a
                             join car_products cp on cp.car_id = a.car_id
                             join bids b on a.advert_id = b.advert_id)
select car_mode,
       buyer_id,
       max(case when bid_rank = 1 then bid_date end)  as first_bid_date,
       max(case when bid_rank = 2 then bid_date end)  as next_bid_date,
       max(case when bid_rank = 1 then bid_price end) as first_price,
       max(case when bid_rank = 2 then bid_price end) as next_price
from buyers_bid
group by car_mode, buyer_id
order by car_mode;

--case 4: percentage comparison of car price and bid price in the last 6 months
with average_price as (select car_mode, round(avg(price)) as avg_price
                       from adverts a
                                join car_products cp on cp.car_id = a.car_id
                       group by car_mode),
     average_6months_bid as (select car_mode, round(avg(bid_price)) as avg_bid_6months
                             from adverts a
                                      join bids b on a.advert_id = b.advert_id
                                      join car_products c on c.car_id = a.car_id
                             where bid_date >= now() - interval '6 months'
                             group by car_mode)
select am.car_mode                                     as model,
       avg_price,
       avg_bid_6months,
       (avg_price - avg_bid_6months)                   as difference,
       (avg_price - avg_bid_6months) / avg_price * 100 as diff_percentage
from average_price ap
         join average_6months_bid am on am.car_mode = ap.car_mode
order by diff_percentage desc
;

--case 5: window function of avg bid on specific brand and car model in the last 6 months
with avg_bid_price as (select brand,
                              car_mode                                                                         as model,
                              round(AVG(CASE WHEN bid_date >= NOW() - INTERVAL '6 months' THEN bid_price END)) AS m_min_6,
                              round(AVG(CASE WHEN bid_date >= NOW() - INTERVAL '5 months' THEN bid_price END)) AS m_min_5,
                              round(AVG(CASE WHEN bid_date >= NOW() - INTERVAL '4 months' THEN bid_price END)) AS m_min_4,
                              round(AVG(CASE WHEN bid_date >= NOW() - INTERVAL '3 months' THEN bid_price END)) AS m_min_3,
                              round(AVG(CASE WHEN bid_date >= NOW() - INTERVAL '2 months' THEN bid_price END)) AS m_min_2,
                              round(AVG(CASE WHEN bid_date >= NOW() - INTERVAL '1 month' THEN bid_price END))  AS m_min_1
                       from car_products
                                join adverts a on car_products.car_id = a.car_id
                                join bids b on a.advert_id = b.advert_id
                       WHERE bid_date >= NOW() - INTERVAL '6 months'
                       GROUP BY brand, car_mode)
select brand,
       model,
       m_min_6,
       m_min_5,
       m_min_4,
       m_min_3,
       m_min_2,
       m_min_1
from avg_bid_price
where brand = 'Toyota'
  and model = 'Toyota Yaris';


