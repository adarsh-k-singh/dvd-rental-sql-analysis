/* ============================================================
   DVD Rental Database Project
   PostgreSQL — dvdrental sample database
   Author: Adarsh Kumar Singh
   ============================================================ */


/* ============================================================
   TASK 1 — Explore the Data
   Preview each table and identify primary/foreign keys.
   (See PK_FK_documentation.md for the full key breakdown.)
   ============================================================ */

SELECT * FROM film LIMIT 10;
SELECT * FROM customer LIMIT 10;
SELECT * FROM rental LIMIT 10;
SELECT * FROM payment LIMIT 10;
SELECT * FROM inventory LIMIT 10;
SELECT * FROM category LIMIT 10;
SELECT * FROM staff LIMIT 10;


/* ============================================================
   TASK 2 — Query Practice (Foundations)
   ============================================================ */

-- 2.1 First 10 film titles in alphabetical order
SELECT title
FROM film
ORDER BY title ASC
LIMIT 10;


-- 2.2 Titles and release years of films released in 2006, sorted by title
SELECT title, release_year
FROM film
WHERE release_year = 2006
ORDER BY title ASC;


-- 2.3 Titles and ratings of films rated PG or PG-13, reverse alphabetical order
SELECT title, rating
FROM film
WHERE rating IN ('PG', 'PG-13')
ORDER BY title DESC;


-- 2.4 All distinct film ratings
SELECT DISTINCT rating
FROM film;


-- 2.5 Total number of films
SELECT COUNT(*) AS total_films
FROM film;


-- 2.6 Number of films per rating, largest count first
SELECT rating, COUNT(*) AS film_count
FROM film
GROUP BY rating
ORDER BY film_count DESC;


-- 2.7 Ratings with at least 200 films
SELECT rating, COUNT(*) AS film_count
FROM film
GROUP BY rating
HAVING COUNT(*) >= 200
ORDER BY film_count DESC;


-- 2.8 10 longest films by length
SELECT title, length
FROM film
ORDER BY length DESC
LIMIT 10;


-- 2.9 Film count per category, largest to smallest
SELECT c.name AS category, COUNT(fc.film_id) AS film_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY film_count DESC;


-- 2.10 10 most frequently rented films with rental counts
SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 10;


-- 2.11 Each customer's full name and number of rentals, highest first
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY rental_count DESC;


-- 2.12 Each customer's total paid and number of payments, highest total first
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       SUM(p.amount) AS total_paid,
       COUNT(p.payment_id) AS payment_count
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_paid DESC;


-- 2.13 Customers who live in Canada, with city and email
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       ci.city,
       c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';


-- 2.14 Average payment amount per month, newest month first
SELECT DATE_TRUNC('month', payment_date) AS payment_month,
       ROUND(AVG(amount), 2) AS avg_payment
FROM payment
GROUP BY payment_month
ORDER BY payment_month DESC;


-- 2.15 Films with at least 5 actors, showing actor count
SELECT f.title, COUNT(fa.actor_id) AS actor_count
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title
HAVING COUNT(fa.actor_id) >= 5
ORDER BY actor_count DESC;


-- 2.16 Each store's total payment amount, highest first
SELECT s.store_id, SUM(p.amount) AS total_revenue
FROM store s
JOIN staff st ON s.store_id = st.store_id
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY s.store_id
ORDER BY total_revenue DESC;


/* ============================================================
   TASK 3 — Advanced Analysis (Deeper Joins, Grouping & Filters)
   ============================================================ */

-- 3.1 Top 5 customers by total payment amount
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       SUM(p.amount) AS total_paid
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_paid DESC
LIMIT 5;


-- 3.2 Top 3 most rented film categories
SELECT cat.name AS category, COUNT(r.rental_id) AS rental_count
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
GROUP BY cat.name
ORDER BY rental_count DESC
LIMIT 3;


-- 3.3 Average rental duration per film category
SELECT cat.name AS category,
       ROUND(AVG(f.rental_duration), 2) AS avg_rental_duration
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
GROUP BY cat.name
ORDER BY avg_rental_duration DESC;


-- 3.4 Monthly revenue per store for the most recent year in the dataset
SELECT s.store_id,
       DATE_TRUNC('month', p.payment_date) AS revenue_month,
       SUM(p.amount) AS monthly_revenue
FROM payment p
JOIN staff st ON p.staff_id = st.staff_id
JOIN store s ON st.store_id = s.store_id
WHERE EXTRACT(YEAR FROM p.payment_date) = (
    SELECT EXTRACT(YEAR FROM MAX(payment_date)) FROM payment
)
GROUP BY s.store_id, revenue_month
ORDER BY s.store_id, revenue_month;


-- 3.5 Films that were never rented
SELECT f.title
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;


-- 3.6 Customers who have spent over $100 in total
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
HAVING SUM(p.amount) > 100
ORDER BY total_spent DESC;


-- 3.7 Staff member with the highest total payments processed
SELECT st.first_name || ' ' || st.last_name AS staff_name,
       SUM(p.amount) AS total_processed
FROM staff st
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY st.first_name, st.last_name
ORDER BY total_processed DESC
LIMIT 1;


-- 3.8 Categories with above-average film length
SELECT cat.name AS category,
       ROUND(AVG(f.length), 2) AS avg_length
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
GROUP BY cat.name
HAVING AVG(f.length) > (SELECT AVG(length) FROM film)
ORDER BY avg_length DESC;
