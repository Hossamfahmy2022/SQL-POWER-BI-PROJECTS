CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);
---------------------------
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;
----------------------
-- total amount each customer spent on zomata
select users.userid,SUM(price) as total
from sales,users,product
where sales.userid=users.userid and sales.product_id=product.product_id
group by users.userid
-- how many days each customer visited zomata
select users.userid,count(distinct created_date) as total_visits
from sales,users
where sales.userid=users.userid
group by users.userid
---------
--- what first product purchased by each customer
select userid,product_name from(
select users.userid,product.product_name,
ROW_NUMBER() over(partition by users.userid  order by sales.created_date asc ) as rn
from sales,users,product
where sales.userid=users.userid and sales.product_id=product.product_id
) as new_table
where rn=1
-----------------
-- what is most purchased item and how many items was sold by all customers
select users.userid,count(distinct created_date) as total_sold
from sales,users,product
where sales.userid=users.userid and sales.product_id=product.product_id
and
product.product_id= (select top(1) product.product_id  
from sales,product
where sales.product_id=product.product_id
group by product.product_id
order by count(*)desc)
group by users.userid
------------------
-- which item is most popular with customer ?
create view most_popular 
as
select *,
ROW_NUMBER() over(partition by userid order by total_sold desc) as rn
from
(select users.userid,product.product_id,count(*) as total_sold
from sales,users,product
where sales.userid=users.userid and sales.product_id=product.product_id
group by users.userid,product.product_id
) as new_table

select userid,product_id,total_sold
from most_popular
where rn=1
-------------------
-- which item was purchased first by customer after become member
select userid,product_name 
from
(select users.userid,product_name ,ROW_NUMBER() over(PARTITION by users.userid order by signup_date,created_date) as rn
from sales,users,product,goldusers_signup
where sales.userid=users.userid and sales.product_id=product.product_id
and goldusers_signup.userid=users.userid 
and created_date>=goldusers_signup.gold_signup_date) as new_table
where rn=1
------------
-- purchased after became a member
select userid,product_name 
from
(select users.userid,product_name ,ROW_NUMBER() over(PARTITION by users.userid order by signup_date,created_date) as rn
from sales,users,product,goldusers_signup
where sales.userid=users.userid and sales.product_id=product.product_id
and goldusers_signup.userid=users.userid 
and created_date<goldusers_signup.gold_signup_date) as new_table
where rn=1