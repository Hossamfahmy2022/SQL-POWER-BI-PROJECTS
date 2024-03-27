/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

select top(1)*
from [dbo].[employee]
order by [levels] desc
----------------------
-- count of employee in each title
select [title] , COUNT(*) as 'number of employees'
from [dbo].[employee]
group by [title]
order by 'number of employees' desc
---------------
/* Q2: Which countries have the most Invoices? */
select [billing_country],COUNT(*) #invoices,SUM([total]) as Total_Invoices
from [dbo].[invoice]
group by [billing_country]
order by #invoices desc,Total_Invoices desc
---------------------
/* Q3: What are top 3 values of total invoice? */
select top(3)[total] as Total_Invoices
from [dbo].[invoice]
order by Total_Invoices desc
---------------------
/* Q4: Which city has the best customers? 
We would like to throw a promotional Music Festival 
in the city we made the most money. 
Write a query that returns one city that has the highest
sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select [billing_city],SUM([total]) as Total_Invoices
from [dbo].[invoice]
group by [billing_city]
order by Total_Invoices desc
-------------------------------
/* Q5: Who is the best customer? 
The customer who has spent the most money 
will be declared the best customer. 
Write a query that returns the person who 
has spent the most money.*/

select top(1)CONCAT([first_name],' ',[last_name]) AS 'Full Name',[total] as Total_Invoices
from [dbo].[customer] C INNER JOIN [dbo].[invoice] I
ON C.[customer_id]=I.[customer_id]
order by Total_Invoices desc
----------------------------------------
/* Question Set 2 - Moderate */
/* Q1: Write query to return the email,
first name, last name, & Genre of all Rock Music
listeners. 
Return your list ordered alphabetically by email 
starting with A. */
select distinct([email]), [first_name],[last_name],G.name
from [dbo].[customer] C , [dbo].[invoice] I,[dbo].[invoice_line] L,[dbo].[track] T,[dbo].[genre] G
where C.[customer_id]=I.[customer_id] and I.[invoice_id]=L.[invoice_line_id] and L.[track_id]=T.[track_id] and T.[genre_id]=G.[genre_id]
and G.name='Rock'
order by email
-------------
/* Q2: Let's invite the artists who have written 
the most rock music in our dataset. 
Write a query that returns the Artist name and 
total track count of the top 10 rock bands. */

select TOP(10)R.[name],COUNT(*) 'total track'
from [dbo].[artist] R,[dbo].[album] A,[dbo].[track] T,[dbo].[genre] G
WHERE R.[artist_id]=A.[artist_id] AND A.[album_id]=T.[album_id]and T.[genre_id]=G.[genre_id]
and G.name='Rock'
GROUP BY R.[name]
ORDER BY 'total track' DESC
----------------------
/* Q3: Return all the track names that have a 
song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs 
listed first. */
declare @avg_milliseconds float 
select @avg_milliseconds=AVG([milliseconds]) from [dbo].[track]
SELECT [name] ,[milliseconds]
from [dbo].[track]
where [milliseconds] > @avg_milliseconds
order by [milliseconds] desc
--------------------
/* Question Set 3 - Advance */
/* Q1: Find how much amount spent by each customer 
on artists? 
Write a query to return customer name, artist name 
and total spent */

/* Steps to Solve: 
First, find which artist has earned the most according to the InvoiceLines. 
Now use this artist to find 
which customer spent the most on this artist. 
For this query, you will need to use the Invoice, 
InvoiceLine, Track, Customer, 
Album, and Artist tables. 
Note, this one is tricky because the Total spent in the Invoice table 
might not be on a single product, 
so you need to use the InvoiceLine table
to find out how many of each product was purchased, and then multiply this by the price
for each artist. */
------------
WITH best_selling_artist AS (
	SELECT TOP(1)artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id ,artist.name
	ORDER BY 3 DESC
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 5 DESC;

---------------

select CONCAT([first_name],' ',[last_name]) AS 'Full Name',R.[name] artist_name ,SUM(L.[unit_price]*L.[quantity]) as 'total'
from [dbo].[customer] C , [dbo].[invoice] I,[dbo].[invoice_line] L,[dbo].[track] T,[dbo].[artist] R,[dbo].[album] A
where C.[customer_id]=I.[customer_id] and I.[invoice_id]=L.[invoice_line_id] and L.[track_id]=T.[track_id] and  R.[artist_id]=A.[artist_id] AND A.[album_id]=T.[album_id]
group by C.customer_id, C.first_name, C.last_name,R.[name]
order by 'total' desc
----------------
DECLARE @id int 
SELECT TOP(1) @id=R.artist_id 
from [dbo].[artist] R,[dbo].[album] A,[dbo].[track] T,[dbo].[invoice_line] L
WHERE R.[artist_id]=A.[artist_id] AND A.[album_id]=T.[album_id]and L.[track_id]=T.[track_id]
GROUP BY R.artist_id
ORDER BY  SUM(L.[unit_price]*L.[quantity])  DESC
select C.customer_id, C.first_name, C.last_name,R.[name] ,SUM(L.[unit_price]*L.[quantity]) as 'total'
from [dbo].[customer] C , [dbo].[invoice] I,[dbo].[invoice_line] L,[dbo].[track] T,[dbo].[artist] R,[dbo].[album] A
where C.[customer_id]=I.[customer_id] and I.[invoice_id]=L.[invoice_line_id] and L.[track_id]=T.[track_id] and  R.[artist_id]=A.[artist_id] AND A.[album_id]=T.[album_id]
AND R.artist_id=@id
group by C.customer_id, C.first_name, C.last_name,R.[name]
order by 'total' desc
----------------------------------
/* Q2: We want to find out the most popular music Genre
for each country. We determine the most popular genre 
as the genre with the highest amount of purchases. 
Write a query that returns each country 
along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

-----------------
alter view country_gener
as
select  G.[name] as gener_name ,[billing_city],count(*) as total,SUM(L.[unit_price]*L.[quantity]) as 'total_prachs'
from [dbo].[customer] C , [dbo].[invoice] I,[dbo].[invoice_line] L,[dbo].[track] T,[dbo].[genre] G
where C.[customer_id]=I.[customer_id] and I.[invoice_id]=L.[invoice_line_id] and L.[track_id]=T.[track_id] and T.[genre_id]=G.[genre_id]
group by G.[name],[billing_city] 

select gener_name,[billing_city],MAX(total) as 'most-popular',SUM(total_prachs) as 'total_prachs'
from country_gener
group by gener_name,[billing_city]
order by 'total_prachs' desc,'most-popular' desc



