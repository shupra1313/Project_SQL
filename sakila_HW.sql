
use sakila;


# 1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor.

select first_name, last_name
from actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select concat(first_name," ", last_name) as Actor_Name
from actor;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name 
from actor
where first_name = "Joe";


# 2b. Find all actors whose last name contain the letters GEN:

select last_name 
from actor
where last_name like "%GEN%" ;


# 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select first_name,last_name
from actor
where last_name like "%LI%"
order by last_name, first_name;


# 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China: 

select country_id,country
from country
where country in ("Afghanistan", "Bangladesh","China");

# 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

alter table actor
add column middle_name varchar(45) after first_name;

# 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

alter table actor
modify middle_name blob;

# 3c. Now delete the middle_name column.

alter table actor
delete middle_name;


# 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name) as 'Last Name Count'
from actor
group by last_name;


# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name, count(last_name) as 'Last Name Count'
from actor
group by last_name
having count(last_name) > 1 ;


# 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
# Write a query to fix the record.

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

#Just checking!
select * from actor
where first_name = 'Groucho' and last_name = 'Williams';


# 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query,
# if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, 
#as that is exactly what the actor will be with the grievous error.
# BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' and actor_id = 172;

#Just checking!
select * from actor
where actor_id = 172;

# 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;


# 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select * from address;
select* from staff;
select staff.first_name, staff.last_name,address.address
from staff
inner join address
on staff.address_id = address.address_id;

# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select * from payment; 
select staff.first_name, staff.last_name,sum(payment.amount) as 'Total Amount by Staff'
from staff
inner join payment
on staff.staff_id = payment.staff_id
group by staff.staff_id;


# 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select film.title, count(film_actor.actor_id) as no_of_actors
from film_actor
inner join film
on film_actor.film_id = film.film_id
group by film.film_id
order by no_of_actors desc;


# 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select title, count(title) as No_of_copies
from film
where  title = "Hunchback Impossible";


# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name,sum(payment.amount) as total_amount_paid
from customer
inner join payment
on customer.customer_id = payment.customer_id
group by customer.customer_id
order by customer.last_name asc;


# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title
from film
where language_id in (
	select language_id 
	from language
	where name = 'English') and (title like 'K%' or title like 'Q%');


# 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name 
from actor 
where actor_id in (
	select actor_id
    from film_actor
    where film_id in (
		select film_id 
        from film 
        where title = 'Alone Trip')); 

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select c.first_name, c.last_name, c.email
from customer c
left join address a 
on c.address_id = a.address_id
left join city ct
on ct.city_id = a.city_id
left join country co
on co.country_id = ct.country_id
where country = 'Canada';


# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select title
from film
where film_id in (
	select film_id
	from film_category 
	where category_id in (
		select category_id 
		from category 
		where name = 'Family'));
		

# 7e. Display the most frequently rented movies in descending order.

select f.title, count(rental_id) as 'Rental times'
from film f
right join inventory i
on f.film_id = i.film_id
left join rental r
on r.inventory_id = i.inventory_id
group by title
order by 'Rental times' desc ;
             

# 7f. Write a query to display how much business, in dollars, each store brought in.

select st.store_id, sum(p.amount) as 'Total Amount Earned (in Dollars)'
from store s
right join staff st
on s.store_id = st.store_id
left join payment p
on st.staff_id = p.staff_id
group by s.store_id;


# 7g. Write a query to display for each store its store ID, city, and country.

select s.store_id, c.city, co.country
from store s
right join address a
on s.address_id = a.address_id
right join city c 
on a.city_id = c.city_id
left join country co
on c.country_id = co.country_id
where store_id is not null;


# 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
#Doubt: The last join can be made on the customer_id too?

select c.name as Genres, sum(p.amount) as 'Gross Revenue'
from category c
join film_category fc
on c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on r.rental_id = p.rental_id
group by name
order by 'Gross Revenue' desc
limit 5;
 

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
# If you haven't solved 7h, you can substitute another query to create a view.

USE `sakila`;
CREATE  OR REPLACE VIEW `Top_5_Genres` AS
select c.name as Genres, sum(p.amount) as 'Gross Revenue'
from category c
join film_category fc
on c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on r.rental_id = p.rental_id
group by name
order by 'Gross Revenue' desc
limit 5;

# 8b. How would you display the view that you created in 8a?

select * from top_5_genres;

# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_5_genres;


