1  select * from artist;
2  select * from customer;
3  select * from employee;
4  select * from genre;
5  select * from invoice;
6  select * from invoice_line;
7  select * from media_type;
8  select * from playlist;
9  select * from playlist_track;
10 select * from track;
11 select * from album;

USE [music database ] ;

----------
/* Q1: Who is the senior most employee based on job title? */

SELECT  TOP 1 * FROM employee
ORDER BY levels DESC;


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*)  as c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

/* Q3: What are top 3 values of total invoice? */

SELECT TOP 3 * FROM invoice 
ORDER BY total DESC;

/* Q4: Which city has the best customers?
-- We would like to throw a promotional Music Festival in the city we made the most money. 
---Write a query that returns one city that has the highest sum of invoice totals. 
---Return both the city name & sum of all invoice totals */

SELECT  sum ( total) as invoice_total , billing_city 
FROM invoice 
GROUP BY billing_city 
ORDER BY invoice_total DESC;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT TOP 1 c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total DESC;


/*....*/

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN (SELECT track_id 
                      FROM track t 
                      JOIN genre g ON genre_id = g.genre_id 
                      WHERE g.name LIKE 'rock')
ORDER BY c.email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


SELECT TOP 10 (A.name)ArtistName, COUNT(P.playlist_id)total_track_count
FROM artist A
INNER JOIN album AL
ON A.artist_id = AL.artist_id
INNER JOIN track T
ON AL.album_id = T.album_id
INNER JOIN playlist_track P
ON T.track_id = P.track_id
INNER JOIN genre G
ON T.genre_id = G.genre_id
WHERE G.name ='Rock'
GROUP BY A.name
ORDER BY total_track_count DESC


/* Q8: Return all the track names that have a song length longer than the average song length. 
-------Return the Name and Milliseconds for each track. 
-------Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds)  AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC;



/*....... */

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT CONCAT_WS(' ', C.first_name, C.last_name)cust_name, (A.name)artist_name, SUM(IL.unit_price * IL.quantity)total_spent
FROM customer C
INNER JOIN invoice I
ON C.customer_id = I.customer_id
INNER JOIN invoice_line IL
ON I.invoice_id = IL.invoice_id
INNER JOIN track T
ON IL.track_id = T.track_id
INNER JOIN album AL
ON T.album_id = AL.album_id
INNER JOIN artist A
ON AL.artist_id = A.artist_id
GROUP BY C.first_name, C.last_name, A.name
ORDER BY total_spent DESC


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

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
WHERE ran = 1


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH CTE AS(
SELECT (I.billing_country)country,CONCAT_WS(' ',C.first_name, C.last_name)cust_name ,SUM(I.total)total_spendings, 
DENSE_RANK() OVER(PARTITION BY I.billing_country ORDER BY SUM(I.total) DESC)ran
FROM customer C
INNER JOIN invoice I
ON C.customer_id = I.customer_id
GROUP BY I.billing_country, C.first_name, C.last_name)

SELECT country, cust_name, total_spendings
FROM CTE
WHERE ran = 1;
