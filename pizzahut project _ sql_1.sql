-- retrive the total number of oredrs placed
select count(order_id) as total_orders
from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum(o.quantity * p.price),2)as total_revenue
from order_details o
inner join pizzas p
on p .pizza_id =o.pizza_id;

-- Identify the highest-priced pizza
SELECT 
    p.price, p1.name
FROM
    pizzas p
        INNER JOIN
    pizza_types p1 ON p.pizza_type_id = p1.pizza_type_id
order by p.price desc
limit 1;

-- Identify the most common pizza size ordered
SELECT 
    p.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas p
        INNER JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    p1.name, SUM(o.quantity) AS total_quantity_order
FROM
    pizzas p
        INNER JOIN
    pizza_types p1 ON p.pizza_type_id = p1.pizza_type_id
        INNER JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p1.name
order by total_quantity_order desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select p.category,sum(o.quantity) as total_quantity 
from pizza_types p
inner join pizzas p1
on p.pizza_type_id = p1.pizza_type_id 
inner join order_details o 
on o.pizza_id =	p1.pizza_id
group by p.category;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hours;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS pizzas_count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS average_order_per_day
FROM
    (SELECT 
        o.order_date, SUM(o1.quantity) AS quantity
    FROM
        orders o
    INNER JOIN order_details o1 ON o.order_id = o1.order_id
    GROUP BY order_date) AS temp_table;
    
-- Determine the top 3 most ordered pizza types based on revenue.
select p1.name , sum(p.price * o.quantity) as total_revenue
from pizzas p
inner join order_details o
on p.pizza_id = o.pizza_id
inner join pizza_types p1
on p.pizza_type_id = p1.pizza_type_id
group by p1.name
order by total_revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
                FROM
                    order_details o
                        INNER JOIN
                    pizzas p ON p.pizza_id = o.pizza_id)) * 100,
            0) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.
select order_date , revenue, 
sum(revenue) over (order by order_date ) as cum_revenue
from(select o1.order_date,sum(p.price * o.quantity) as revenue
from pizzas p
inner join order_details o
on p.pizza_id = o.pizza_id
inner join orders o1
on o.order_id = o1.order_id 
group by o1.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , name , revenue 
from (select category , name , revenue,
rank() over(partition by category order by revenue desc) as ranks
from (select  p1.category , p1.name, sum(o.quantity * p.price) as revenue
from order_details o
inner join pizzas p
on p.pizza_id = o.pizza_id
inner join pizza_types p1
on p.pizza_type_id = p1.pizza_type_id
group by p1.category , p1.name) as sales_table) ranks_table 
where ranks <= 3;

