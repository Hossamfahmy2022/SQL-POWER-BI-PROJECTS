select * from [dbo].[pizza_sales]
-- data quality 
-- data is valid as type and ranges
-- check (missing values)nulls
select COUNT(*)-COUNT (pizza_id) as 'pizza_id nulls', 
COUNT(*)-COUNT ([order_id]) as 'order_id nulls',
COUNT(*)-COUNT ([pizza_name_id]) as 'pizza_name_id nulls',
COUNT(*)-COUNT ([quantity]) as 'quantity nulls',
COUNT(*)-COUNT ([order_date]) as 'order_date nulls',
COUNT(*)-COUNT ([order_time]) as 'order_time nulls',
COUNT(*)-COUNT ([unit_price]) as 'unit_price nulls',
COUNT(*)-COUNT ([total_price]) as 'total_price nulls',
COUNT(*)-COUNT ([pizza_size]) as 'pizza_size nulls',
COUNT(*)-COUNT ([pizza_category]) as 'pizza_category nulls',
COUNT(*)-COUNT ([pizza_ingredients]) as 'pizza_ingredients nulls',
COUNT(*)-COUNT ([pizza_name]) as 'pizza_name nulls'
from [dbo].[pizza_sales]

-- no missing values in data
-- 2-ckeck duplicates
select *,COUNT(*)
from [dbo].[pizza_sales]
group by [pizza_id],[order_id],[pizza_name_id],[quantity],[order_date],[order_time],[unit_price],[total_price],[pizza_size],[pizza_category],[pizza_ingredients],[pizza_name]
having COUNT(*) >1
-- no duplictes in table on rows
-- no problem to slove it
-- Answer questions
-- 1. Total Revenue:
select Round(SUM([total_price]),2) as 'Total Revenue'
from [dbo].[pizza_sales]
--2 Average Order Value
select SUM([total_price])/count(distinct(order_id)) as 'Average Order Value'
from [dbo].[pizza_sales]
--3. Total Pizzas Sold
select SUM([quantity]) as 'Total Pizzas Sold'
from [dbo].[pizza_sales]
--4. Total Orders
select count(distinct(order_id)) as 'Total Orders'
from [dbo].[pizza_sales]
--5 Average Pizzas Per Order
select CAST(CAST(SUM([quantity]) AS decimal(10,2))/CAST(count(distinct(order_id))AS decimal(10,2)) AS decimal(10,2) ) as 'Average Pizzas Per Order'
from [dbo].[pizza_sales]
--6- Daily Trend for Total Orders
select DATENAME(DW,[order_date]) AS day,count(distinct(order_id)) as 'Total Orders'
from [dbo].[pizza_sales]
GROUP BY DATENAME(DW,[order_date])
ORDER BY 'Total Orders' desc
--7- Monthly Trend for Orders
select DATENAME(MONTH,[order_date]) AS month,count(distinct(order_id)) as 'Total Orders'
from [dbo].[pizza_sales]
GROUP BY DATENAME(MONTH,[order_date])
ORDER BY 'Total Orders' desc
--8- % of Sales by Pizza Category
select pizza_category,
cast(SUM([total_price]) AS decimal(10,2)) as 'total_revenue',
cast(SUM([total_price])*100/((select SUM([total_price]) from [dbo].[pizza_sales] ) ) AS decimal(10,2))as '% of Sales by Pizza Category'
from [dbo].[pizza_sales]
GROUP BY pizza_category
ORDER BY 'total_revenue' desc
--9- . % of Sales by Pizza Size
select pizza_size,
cast(SUM([total_price]) AS decimal(10,2)) as 'total_revenue',
cast(SUM([total_price])*100/((select SUM([total_price]) from [dbo].[pizza_sales] ) ) AS decimal(10,2))as '% of Sales by Pizza Category'
from [dbo].[pizza_sales]
GROUP BY pizza_size
ORDER BY 'total_revenue' desc
--10-Total Pizzas Sold by Pizza Category
select pizza_category,
sum(quantity)as 'quantity'
from [dbo].[pizza_sales]
GROUP BY pizza_category
ORDER BY 'quantity' desc
--11-Top 5 Pizzas by Revenue
select top(5) pizza_name,
sum(total_price)as 'total_price'
from [dbo].[pizza_sales]
GROUP BY pizza_name
ORDER BY 'total_price' desc
--12- Bottom 5 Pizzas by Revenue
select top(5) pizza_name,
sum(total_price)as 'total_price'
from [dbo].[pizza_sales]
GROUP BY pizza_name
ORDER BY 'total_price' asc
--13-Top 5 Pizzas by Quantity
select top(5) pizza_name,
sum(quantity)as 'quantity'
from [dbo].[pizza_sales]
GROUP BY pizza_name
ORDER BY 'quantity' desc
--14-Bottom 5 Pizzas by Quantity
select top(5) pizza_name,
sum(quantity)as 'quantity'
from [dbo].[pizza_sales]
GROUP BY pizza_name
ORDER BY 'quantity' asc
--15-Top 5 Pizzas by Total Orders
select top(5) pizza_name,
count(distinct(order_id)) as 'quantity'
from [dbo].[pizza_sales]
GROUP BY pizza_name
ORDER BY 'quantity' desc
--16-Borrom 5 Pizzas by Total Orders
select top(5) pizza_name,
count(distinct(order_id)) as 'quantity'
from [dbo].[pizza_sales]
GROUP BY pizza_name
ORDER BY 'quantity' asc

