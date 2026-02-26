
--normalized model separeting data into tables  to remove duplications and we usually use in transactions
/*1 — Order Revenue Calculation
Scenario: Finance team wants to calculate total revenue generated from each order using normalized tables.*/
SELECT
    o.order_id,
    SUM(p.amount * oi.quantity) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id;


/* — Top Customers by Revenue
Scenario: Management wants to identify the highest-value customers contributing the most revenue.*/
SELECT *
FROM (
    SELECT
        o.customer_name,
        SUM(p.amount * oi.quantity) AS total_spent,
        RANK() OVER (ORDER BY SUM(p.amount * oi.quantity) DESC) AS rank
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.customer_name
) t
WHERE rank <= 3;


-- star schema 

/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/



/**/
/**/

