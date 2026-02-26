
/*lets revise the concepts data modeling,indexes,explains and query optimization techniques 
  1. Data Modeling for BI — In Business Intelligence, the goal is fast analytics, not transaction safety.
That is why Star Schema is preferred over heavy normalization.
    # Star Schema Structure
A star schema has:
Fact Table (center) Contains measurable business events (numbers). like sales_amount,order_id,foreign keys to dimensions
Dimension Tables (surrounding) Contain descriptive information. like customer,product,date
   # normalized data modeling is separeting data in to many tables to avoid reputaions and to make data easy to manage.
 2. Indexes — Performance Acceleration
Indexes help database find data faster without scanning whole table. Think of index like a book index.
Instead of reading entire book → jump directly to page.
     Common Index Types in BI
  * B-Tree Index (default 90% of analysis uses)  Best for: WHERE filtering,JOIN keys,ORDER BY,GROUP BY
  * Composite Index  ex. CREATE INDEX idx_customer_dateON fact_sales(customer_id, order_date);
 3. EXPLAIN and EXPLAIN ANALYZE  Used to understand how database executes query.Very important for performance tuning.
EXPLAIN   Shows plan only.  but EXPLAIN ANALYZE Runs query and shows real execution time.

 4. Query Optimization Techniques 
1. Index Filtering Columns Columns used in WHERE or JOIN must be indexed.
2. Avoid SELECT *  Select only needed columns.
3. Use Proper Join Keys Join using indexed foreign keys.
4. Aggregate After Filtering Filter first, then aggregate.
5. Use Partitioning for Very Large Tables Split by date or region.
6. Use Materialized Views for Heavy Reports Precomputed results.
7. Check Execution Plan Always Never assume query is fast.*/



--normalized model separeting data into tables  to remove duplications and we usually use in transactions
/*1 — Order Revenue Calculation
Finance team wants to calculate total revenue generated from each order using normalized tables.*/
SELECT
    o.order_id,
    SUM(p.price * oi.quantity) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id;


/* 2— Top Customers by Revenue
Management wants to identify the highest-value customers contributing the most revenue.*/
SELECT *
FROM (
    SELECT
        o.customer_name,
        SUM(p.price * oi.quantity) AS total_spent,
        RANK() OVER (ORDER BY SUM(p.price * oi.quantity) DESC) AS rank
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.customer_name
) t
WHERE rank <= 3;


-- INTERMEDIATE STAR SCHEMA BUSINESS CHALLENGES 

/*3— Monthly Revenue Analysis
  Management wants monthly sales performance from the warehouse.*/
SELECT
    d.month,
    SUM(f.amount) AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.month
ORDER BY d.month;


/*4— Top Products by Revenue
  Product team wants best performing products.*/
SELECT
    p.product_name,
    SUM(f.amount) AS total_sales
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;


/*5— Customer Purchase Ranking
  Identify high value customers.*/
SELECT
    c.customer_name,
    SUM(f.amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(f.amount) DESC) AS rank
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_name;


/*6— Create Index on Fact Table Date
  Improve performance for date filtering queries.*/
CREATE INDEX idx_fact_date
ON fact_sales(date_id);


/*7— Analyze Query Performance Before Index
  Check execution cost before optimization.*/
EXPLAIN ANALYZE
SELECT *
FROM fact_sales
WHERE date_id = 2024-01;


/*8— Sales by Category
  Marketing wants category performance.*/
SELECT
    p.category,
    SUM(f.amount) AS revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category;


/*9— Orders per Customer Segment
  Business wants customer behavior insight.*/
SELECT
    c.segment,
    COUNT(*) AS orders_count
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.segment;


/*10— Running Revenue Trend
  Finance wants cumulative revenue.*/
SELECT
    d.full_date,
    SUM(f.amount) OVER (ORDER BY d.full_date) AS running_total
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id;


/*11— Composite Index for Join Optimization
  Improve join speed between customer and date.*/
CREATE INDEX idx_customer_date
ON fact_sales(customer_id, date_id);


    --COMPLEX STAR SCHEMA BUSINESS CHALLENGES

/
/*12— Detect Slow Query and Optimize with Index
  Investigate performance issue on customer filtering.*/
EXPLAIN ANALYZE      -- just to see and check every thing in plan 
SELECT *
FROM fact_sales
WHERE customer_id = 10;

CREATE INDEX idx_customer   --most of the time if the dashboard get slower then analysts create index(in foreign keys or generally frequently filtered rows.)  
ON fact_sales(customer_id);

EXPLAIN ANALYZE      -- then again see the plan and we can easily compare the diffrence. 
SELECT *              -- but in this case i am just trying to practice but it's not neede to use indexes for 
FROM fact_sales          -- small tables because the cost of index scan is much higher than sequental scan
WHERE customer_id = 10;


/*13— Top Customers per Region Using Window Function
  Regional managers want top customers.*/
SELECT *
FROM (
    SELECT
        c.customer_name,
        SUM(f.amount) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_name
            ORDER BY SUM(f.amount) DESC
        ) AS rn
    FROM fact_sales f
    JOIN dim_customer c ON f.customer_id = c.customer_id
    GROUP BY c.customer_name
) t
WHERE rn <= 3;


/*14— Execution Plan Comparison After Index Creation
  Compare performance improvement.*/
EXPLAIN ANALYZE
SELECT
    SUM(amount)
FROM fact_sales
WHERE date_id BETWEEN 2024-01 AND 2024-03;


/**/


