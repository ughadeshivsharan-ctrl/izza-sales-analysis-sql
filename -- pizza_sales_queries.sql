-- Retrieve the total number of orders placed

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;



-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id



-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price AS highest_price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY highest_price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS total_orders
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY total_orders DESC
LIMIT 1;



# Top 5 Most Ordered Pizza Types

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS total_quantity
FROM orders_details
JOIN pizzas
    ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;




-- Orders Distribution by Hour

SELECT 
    HOUR(time) AS order_hour, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY order_hour
ORDER BY order_hour;




-- Category-wise Distribution of Pizzas

SELECT 
    pizza_types.category, COUNT(pizzas.pizza_id) AS total_pizzas
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY total_pizzas DESC;




-- Average Pizzas Ordered Per Day

SELECT 
    orders.date, SUM(orders_details.quantity) AS total_pizzas
FROM
    orders
        JOIN
    orders_details ON orders.order_id = orders_details.order_id
GROUP BY orders.date
ORDER BY orders.date;



-- Top 3 Pizza Types by Revenue

SELECT 
    pizza_types.name,
    ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS total_revenue
FROM orders_details
JOIN pizzas
    ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;





-- Percentage Contribution of Each Pizza Type to Total Revenue

SELECT 
    pizza_types.name,
    ROUND(SUM(orders_details.quantity * pizzas.price) * 100 / (SELECT 
                    SUM(orders_details.quantity * pizzas.price)
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id),
            2) AS revenue_percentage
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue_percentage DESC;







-- Cumulative Revenue Over Time

SELECT
    orders.date,
    SUM(orders_details.quantity * pizzas.price) AS daily_revenue,
    SUM(SUM(orders_details.quantity * pizzas.price))
        OVER (ORDER BY orders.date) AS cumulative_revenue
FROM orders
JOIN orders_details
    ON orders.order_id = orders_details.order_id
JOIN pizzas
    ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY orders.date
ORDER BY orders.date desc limit 5;




-- Top 3 Pizza Types by Revenue in Each Category

WITH pizza_revenue AS (
    SELECT
        pizza_types.category,
        pizza_types.name,
        SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM orders_details
    JOIN pizzas
        ON orders_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types
        ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    GROUP BY pizza_types.category, pizza_types.name
),
ranked_pizza AS (
    SELECT
        category,
        name,
        revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS pizza_rank
    FROM pizza_revenue
)
SELECT
    category,
    name,
    ROUND(revenue, 2) AS revenue
FROM ranked_pizza
WHERE pizza_rank <= 3
ORDER BY category, revenue DESC;










