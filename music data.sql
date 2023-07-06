
select * from employee;
select * from invoice;

select * from customer;
select * from genre;
select * from track;
select * from invoice_line;

alter table invoive_line
rename to invoice_line;


--1 who is the senior most employee base on job title
select * from employee
order by levels desc
fetch first 1 row only;

--2 which countries have the most invoices
select billing_country, count(billing_country) cnt
from invoice
group by billing_country
order by cnt desc;

--3what are the top 3 values of total invoice

select total from invoice
order by total desc
fetch first 3 rows only;

--4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals


select Billing_city , sum(total) sm
from invoice
group by billing_city
order by sm desc
fetch first 1 row only;

--5 Who is the best customer? The customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money

select c.customer_id, c.first_name,c.last_name ,tt
from customer  c
left join  (select customer_id,sum(total) tt from invoice
group by customer_id) i
on  i.customer_id=c.customer_id
order by tt desc
fetch first 1 row only;


--We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top Genre.
--For countries where the maximum number of purchases is shared return all Genres.


WITH CTE AS(
SELECT (I.billing_country)Country, (G.name)Genre_name, SUM(IL.quantity)No_of_purchase, DENSE_RANK() OVER(PARTITION BY I.billing_country ORDER BY SUM(IL.quantity) DESC)ran
FROM invoice I
INNER JOIN invoice_line IL
ON I.invoice_id = IL.invoice_id
INNER JOIN track T
ON IL.track_id = T.track_id
INNER JOIN genre G
ON T.genre_id = G.genre_id
GROUP BY I.billing_country, G.name)

SELECT Country, Genre_name FROM CTE
WHERE ran = 1;


--. Write query to return the first name, last name, email & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.


select distinct(c.first_name||' '||c.last_name),c.email,g.name
from track t 
inner join genre g
on g.genre_id=t.genre_id
inner join invoice_line il 
on t.track_id=il.track_id
inner join invoice i
on i.invoice_id=il.invoice_id
inner join customer c
on c.customer_id=i.customer_id
where g.name='Rock'
order by email;

-- Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.


select a.name,count(a.artist_id) count
from artist a
join album al
on a.artist_id=al.artist_id
join track t
on t.album_id=al.album_id
where t.genre_id in(select genre_id from genre where name='Rock')
group by al.artist_id,a.name,t.genre_id
order by count desc
fetch first 10 rows only;

--Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select name,milliseconds
from track where 
milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select c.first_name ,a.name artist,sum(i.total)total
from customer c 
join invoice i on
c.customer_id=i.customer_id
join invoice_line il on
i.invoice_id=il.invoice_id
join track t on
t.track_id=il.track_id
join album al on
al.album_id=t.album_id
join artist a on
a.artist_id=al.artist_id
group by i.customer_id,a.name,c.first_name
order by total desc;

--Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent.
--For countries where the top amount spent is shared, provide all customers who spent this amount.


with Cte as(select (c.first_name)customer,i.billing_country country,sum(i.total)purchase,dense_rank()over(partition by i.billing_country order by sum(i.total) desc) ran
from invoice i
inner join customer c on
c.customer_id=i.customer_id
group by i.billing_country,c.first_name)
select customer,country ,purchase from Cte
where ran=1
order by purchase desc;

