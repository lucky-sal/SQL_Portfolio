--1. Which product has the highest price? Only return a single row.

select product_name, price
from products
order by price desc
limit 1


--2. Which customer has made the most orders?
select c.customer_id
,   first_name || ' ' || last_name as Customer_name
,   email
,   count(order_id) as orders
from customers c
inner join orders o
    on o.customer_id = c.customer_id
group by 1,2,3
order by count(order_id) desc
limit 1



--3. What’s the total revenue per product?

SELECT p.product_name
, sum(o.quantity) * p.price as ttl_revenue 

from order_items o
left join products p
    on p.product_id = o.product_id
group by 1

--4. Find the day with the highest revenue.
SELECT ord.order_date
, sum(o.quantity * p.price) revenue

from order_items o
left join products p
    on p.product_id = o.product_id
left join orders ord
    on ord.order_id = o.order_id
group by 1
order by 1 desc
limit 1


--5. Find the first order (by date) for each customer.
select customers.customer_id
,   first_name || ' ' || last_name as Customer_name
,   min(order_date) as first_order
FROM customers
inner join orders
    on orders.customer_id = customers.customer_id

group by 1

--6. Find the top 3 customers who have ordered the most distinct products
select first_name || ' ' || last_name as Customer_name
,   count(distinct products.product_id) as distinct_product_cnt

FROM customers
inner join orders
    on orders.customer_id = customers.customer_id
inner join order_items
    on order_items.order_id = orders.order_id
inner join products
    on products.product_id = order_items.product_id
group by 1
order by 2 DESC
limit 3


--7. Which product has been bought the least in terms of quantity?

select product_name
,   sum(quantity) as quantity
from order_items o
left join products p
    on p.product_id = o.product_id
group by 1
order by 2 

--8. What is the median order total?
select num_orders
from (
select customer_id
    , count(customer_id) over (partition by customer_id) as num_orders
    , row_number() over(order by customer_id) as row_num
    , count(*) over () as ttl_rows
from orders) as median_base
where  row_num in (ttl_rows/2, (ttl_rows +1)/2)

--9. For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

SELECT o.order_id
,   case 
        when sum(o.quantity) * p.price > 300 then 'Expensive'
        when sum(o.quantity) * p.price > 100 then 'Affordable'
        else 'Cheap'
    end as cost_value
,   sum(o.quantity) * p.price as ttl_revenue 

from order_items o
left join products p
    on p.product_id = o.product_id
left join orders ord
    on ord.order_id = o.order_id
group by o.order_id
order by o.order_id

--10. Find customers who have ordered the product with the highest price.

select first_name || ' ' || last_name as Customer_name

FROM customers
inner join orders
    on orders.customer_id = customers.customer_id
inner join order_items
    on order_items.order_id = orders.order_id
inner join products
    on products.product_id = order_items.product_id

where products.price = (select max(price) from products)