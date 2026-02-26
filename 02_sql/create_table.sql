-- lets create table named orders_manual to practice views and data modeling
DROP TABLE IF EXISTS orders_manual;

CREATE TABLE orders_manual (
    order_id INT PRIMARY KEY,
    customer_name TEXT,
    email TEXT,
    phone TEXT,
    payment_method TEXT,
    product_name TEXT,
    category TEXT,
    amount NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(10,2),
    order_date TIMESTAMP,
    shipped_date TIMESTAMP
);

-- as you see this query is gonna create automatically the table and then we are going to insert real data values in isert folder...

-- lets break down the original table into the structure of star schema which is fact table and dimention table
-- to practice star schema with  real life  business questions  comes from many coworkers.

CREATE TABLE dim_product AS
SELECT DISTINCT
    product_name,
    category
FROM orders_manual;
-- we just have created the dimention(description)table  1

ALTER TABLE dim_product
ADD COLUMN product_id SERIAL PRIMARY KEY;

/* In this case we have to add id column because we are just refering the values already exist in another table
   so we don't have product_id   so using alter we can add  this column , so i did it like that.*/

CREATE TABLE dim_customer AS
SELECT DISTINCT
    customer_name,
    email,
    phone
FROM orders_manual;

--Again we have to add column customer_id
ALTER TABLE dim_customer
ADD COLUMN customer_id SERIAL PRIMARY KEY;


--Then here we  are going to create dimention table 3 which is dim_date.
CREATE TABLE dim_date AS
SELECT DISTINCT
    order_date::date AS full_date
FROM orders_manual
WHERE order_date IS NOT NULL;
 -- I've created dim_date table using select distnict to refer values from orders_manual  and i used null handling with filteration.


 -- here we are adding columns    like this...
ALTER TABLE dim_date
ADD COLUMN date_id SERIAL PRIMARY KEY;

ALTER TABLE dim_date
ADD COLUMN month DATE;

UPDATE dim_date
SET month = date_trunc('month', full_date);
/* Lets see one by one 1 add date id  to give primary key(unique row identifier) to distinct from othe rows
    2 add month and update using  date_trunc('month', full_date) to see the month from 1st date up to last date of that month 
    full date (i refered this column from the first creation) */






-- Now lets create fact  taable(numbers or metrix table)  
CREATE TABLE fact_sales AS
SELECT
    o.order_id,
    p.product_id,
    c.customer_id,
    d.date_id,
    o.amount,
    o.quantity,
    COALESCE(o.discount,0) AS discount,
    (o.amount * o.quantity - COALESCE(o.discount,0)) AS revenue
FROM orders_manual o
JOIN dim_product p
    ON o.product_name = p.product_name
JOIN dim_customer c
    ON o.customer_name = c.customer_name
JOIN dim_date d
    ON o.order_date::date = d.full_date;

--As we have showen here i  used  joins   to crate fact_sales     table


