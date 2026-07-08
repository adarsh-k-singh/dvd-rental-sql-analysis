# Task 1 — Database Exploration: Primary & Foreign Keys

Before writing any queries, I explored the `dvdrental` schema using `SELECT * FROM table_name LIMIT 10;` on each core table, then mapped out the relationships using the ER diagram. Below are the primary and foreign keys for 7 key tables (more than the required 5), showing how the schema connects.

| Table | Primary Key | Foreign Key(s) | References |
|---|---|---|---|
| **film** | `film_id` | `language_id` | `language(language_id)` |
| **inventory** | `inventory_id` | `film_id`, `store_id` | `film(film_id)`, `store(store_id)` |
| **rental** | `rental_id` | `inventory_id`, `customer_id`, `staff_id` | `inventory(inventory_id)`, `customer(customer_id)`, `staff(staff_id)` |
| **payment** | `payment_id` | `customer_id`, `staff_id`, `rental_id` | `customer(customer_id)`, `staff(staff_id)`, `rental(rental_id)` |
| **customer** | `customer_id` | `store_id`, `address_id` | `store(store_id)`, `address(address_id)` |
| **film_category** | `(film_id, category_id)` composite | `film_id`, `category_id` | `film(film_id)`, `category(category_id)` |
| **staff** | `staff_id` | `address_id`, `store_id` | `address(address_id)`, `store(store_id)` |

## Key observations

- **`rental` and `payment` are the two central "fact" tables** — nearly every business question (revenue, customer behaviour, staff performance) flows through one or both of these, since they're the only tables that connect customers, staff, and films to actual transactions.
- **`film_category` is a junction table** with a composite primary key rather than its own surrogate key — this exists because the relationship between films and categories is many-to-many (a film can belong to more than one category).
- **`store` has a circular-feeling relationship with `staff`**: a store references a `manager_staff_id` (a staff member), while staff themselves reference which `store_id` they work at. This is a common but easy-to-miss pattern in relational schemas — two tables referencing each other.
- **Geography cascades through 3 levels**: `address → city → country`, meaning any query filtering customers by country (e.g. Task 2, Query 13) has to join through all three tables, not just one.
