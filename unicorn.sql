/* 

--------- UNICORN ONLINE MARKETPLACE DATA ANALYTICS PROJECT --------

Project Overview:
    This SQL project is designed to perform comprehensive data analysis for the
    Unicorn Online Marketplace. The analysis covers sales data from 2015 to 2018 across various product categories. 
Database Tables:
    - customer: Contains customer details such as customer_id, customer_name, and customer_segment.
    - orders: Contains order information such as order_id, customer_id, order_date, and shipping details.
    - order_details: Details of each order including product_id, quantity, discounts, and sales figures.
    - product: Product information including product_id, name, category, and manufacturer.
*/ 



/* 
This sql query uses Common Table Expressions (CTEs) to systematically gather and present 
information about the database's tables primary key.

- total rows
- non null values 
- unique values 
- duplicate values 
*/ 


WITH Customer_Info AS (
    SELECT 
        'customer' AS table_name,
        'customer_id' AS primary_key,
        COUNT(*) AS total_rows,
        COUNT(customer_id) AS non_null_values,
        COUNT(DISTINCT customer_id) AS unique_values,
        (SELECT COUNT(*) FROM (SELECT customer_id, COUNT(*) FROM customers GROUP BY customer_id HAVING COUNT(*) > 1) AS dup) AS duplicates
    FROM customers

),

orderdetails_info AS (
  
  SELECT
  	'order_detail' AS table_name,
  	'order_details_id' AS primary_key,
  	COUNT(*) AS total_rows,
  	COUNT(order_details_id) AS non_null_values,
  	COUNT(DISTINCT order_details_id) AS unique_values,
  	(SELECT COUNT(*) FROM (SELECT order_details_id, COUNT(*) FROM order_details GROUP BY order_details_id HAVING COUNT(*) > 1)as dup) AS duplicates
  	FROM order_details
),

Orders_Info AS (
    SELECT 
        'orders' AS table_name,
        'order_id' AS primary_key,
        COUNT(*) AS total_rows,
        COUNT(order_id) AS non_null_values,
        COUNT(DISTINCT order_id) AS unique_values,
        (SELECT COUNT(*) FROM (SELECT order_id, COUNT(*) FROM orders GROUP BY order_id HAVING COUNT(*) > 1) AS dup) AS duplicates
    FROM orders

  
),

product_info AS (
  SELECT 
  	'product' AS table_name,
  	'product_id' AS primary_key,
  	COUNT(*) AS total_rows,
  	COUNT(product_id) AS non_null_values,
  	COUNT(DISTINCT product_id) AS unique_values,
  	(SELECT COUNT(*) FROM (SELECT product_id, COUNT(*) FROM product GROUP BY product_id HAVING COUNT(*) > 1) AS dup) AS duplicates
    FROM product
  
) 

select * from customer_info
union all 
select * from orderdetails_info
union all 
select * from orders_info 
union all 
select * from product_info;

  
  
-- This SQL query finds the total number of customers in each customer segment.  
  
  
SELECT customer_segment,
			COUNT(distinct customer_id) As total_customer
FROM customers
GROUP BY 1 
ORDER BY 2 DESC;


-- This sql query provide an analysis of the yearly customer( who ordered) data  broken down by segment

SELECT 
		c.customer_segment,
    EXTRACT( YEAR FROM o.order_date) as year,
    COUNT(DISTINCT c.customer_id) AS total_customer
FROM
		customers c 
JOIN 
		orders o 
ON c.customer_id = o.customer_id
GROUP BY 1,2
ORDER BY 2;

  
-- What was the city with the most profit for the company in 2015?

  
SELECT 
    o.shipping_city AS city, 
    SUM(od.order_profits) AS total_profit
FROM 
    order_details od
JOIN 
    orders o ON o.order_id = od.order_id
WHERE 
    EXTRACT(YEAR FROM o.order_date) = 2015
GROUP BY 
    o.shipping_city
ORDER BY 
    total_profit DESC;
  
  
  
-- identify the  customers with the lowest and highest total spending

-- Query to find the customer with the lowest spending

(SELECT 
 		'lowest spend' AS stuation,
    c.customer_name,
    SUM(o.order_sales) AS total_spending
FROM 
    order_details o
JOIN 
 		orders ord ON o.order_id = ord.order_id
JOIN 
 		customers c ON c.customer_id = ord.customer_id
GROUP BY 
    customer_name
ORDER BY 
    total_spending ASC
LIMIT 1)

UNION ALL

-- Query to find the customer with the highest spending
(SELECT
 		'highest spend' AS stuation,
    c.customer_name,
    SUM(o.order_sales) AS total_spending
FROM 
    order_details o
JOIN 
 		orders ord ON o.order_id = ord.order_id
JOIN 
 		customers c ON c.customer_id = ord.customer_id
GROUP BY 
    customer_name
ORDER BY 
    total_spending DESC
LIMIT 1);
  

 

-- What is the most profitable City in the State of Tennessee?

SELECT 
		shipping_city AS city,
    SUM(order_profits) AS total_profit
FROM 
    order_details
JOIN 
    orders ON orders.order_id = order_details.order_id
WHERE 
    shipping_state = 'Tennessee'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;
        

-- What is the average profit from orders in the city of Lebanon, Tennessee

SELECT
    shipping_city AS city,
    
    AVG(order_profits) AS avg_annual_profit
FROM
    orders
JOIN
    order_details ON orders.order_id = order_details.order_id
WHERE
    shipping_state = 'Tennessee' AND
    shipping_city = 'Lebanon'
GROUP BY
    shipping_city
   
ORDER BY
    2 DESC;

-- What’s the most profitable product category on average in Iowa across all years?


SELECT
    p.product_category,
    AVG(od.order_profits) AS profit_avg
FROM
    order_details od
JOIN
    orders o ON o.order_id = od.order_id
JOIN
    product p ON p.product_id = od.product_id
WHERE
    o.shipping_state = 'Iowa'
GROUP BY
    p.product_category
ORDER BY
    profit_avg DESC
LIMIT 1;



-- What is the most popular product in Furniture category across all states in 2016?

SELECT
    product_name,
    SUM(quantity) AS amount_of_items
FROM
    order_details
JOIN
    orders ON orders.order_id = order_details.order_id
JOIN
    product ON order_details.product_id = product.product_id
WHERE
    EXTRACT(YEAR FROM order_date) = 2016 AND
    product_category = 'Furniture'
GROUP BY
    product_name
ORDER BY
    amount_of_items DESC
LIMIT 1;


-- Which customer got the most discount in the data? (in total amount)

SELECT
    customers.customer_name,
    SUM((order_sales/(1-order_discount))-order_sales) AS total_discount
FROM
    order_details
JOIN
    orders ON orders.order_id = order_details.order_id
JOIN
    customers ON orders.customer_id = customers.customer_id
GROUP BY
    1
ORDER BY
    total_discount DESC
LIMIT 1;





--  how monthly profits varied throughout the year 2018. 


WITH cte AS (
    SELECT
        to_char(order_date, 'MM-YYYY') AS month,  
        SUM(order_profits) AS month_total        
    FROM
        order_details
    JOIN
        orders ON orders.order_id = order_details.order_id
    WHERE
        date_part('year', order_date) = '2018'  
    GROUP BY
        1                                      
    ORDER BY
        1                                      
)
SELECT
    *,
    (month_total - LAG(month_total, 1, 0) OVER ()) AS month_diff -- Calculating the difference in profits from the previous month
FROM
    cte;



-- top-selling products during the high-profit months of March and September for the year 2018

SELECT 
    p.product_name,
    SUM(od.quantity) AS total_quantity_sold
FROM 
    order_details od
JOIN 
    orders o ON o.order_id = od.order_id
JOIN 
    product p ON p.product_id = od.product_id
WHERE 
    EXTRACT(YEAR FROM o.order_date) = 2018 AND 
    (EXTRACT(MONTH FROM o.order_date) = 3 OR EXTRACT(MONTH FROM o.order_date) = 9)
GROUP BY 
    p.product_name
ORDER BY 
    total_quantity_sold DESC
LIMIT 3;


-- most profitable products during the high-profit months of March and September 2018

SELECT 
    p.product_name,
    SUM(od.order_profits) AS total_profit
FROM 
    order_details od
JOIN 
    orders o ON o.order_id = od.order_id
JOIN 
    product p ON p.product_id = od.product_id
WHERE 
    EXTRACT(YEAR FROM o.order_date) = 2018 AND 
    (EXTRACT(MONTH FROM o.order_date) = 3 OR EXTRACT(MONTH FROM o.order_date) = 9)
GROUP BY 
    p.product_name
ORDER BY 
    total_profit DESC
LIMIT 3;


-- Calculate the percent of products category.


SELECT 
    product_category,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS percentage_of_total
FROM 
    product
GROUP BY 
    product_category;



--  What product manufacturers have more than 10 products?


SELECT 
    product_manufacturer, 
    COUNT(product_id) AS product_count
FROM 
    product
GROUP BY 
    1
HAVING 
    COUNT(product_id) > 100;
    
    


-- What is the average profitability of products by top 3 manufacturer?('Canon', '3D Systems', 'Ativa')


SELECT 
    product_manufacturer,
    AVG(order_profits) AS average_profit
FROM 
    product p
JOIN 
    order_details o ON o.product_id = p.product_id
GROUP BY 
    1
ORDER BY 
    average_profit DESc
LIMIT 3;

-- Count the number of products listed under each of the top three manufacturers 'Canon', '3D Systems', 'Ativa'

SELECT 
    product_manufacturer,
    COUNT(distinct p.product_id) AS number_of_products,
    SUM(od.quantity) AS total_quantity_sold
FROM 
    product p
JOIN 
    order_details od ON p.product_id = od.product_id
WHERE 
    product_manufacturer IN ('Canon', '3D Systems', 'Ativa')
GROUP BY 
    1;



-- Create a table that has calculated  price for each product 


    
    
WITH per_product_price AS (
    SELECT 
        p.product_manufacturer,
        p.product_name,
        (od.order_sales / (1 - od.order_discount)) / od.quantity AS price_per_product
    FROM 
        order_details od
    JOIN 
        product p ON od.product_id = p.product_id
)
-- Select top three manufacturer product and selling price and average product price for each manufacturer
SELECT 
    product_manufacturer,
    product_name,
    price_per_product,
    AVG(price_per_product) OVER (PARTITION BY product_manufacturer) AS avg_price_per_manufacturer
FROM 
    per_product_price
WHERE 
    product_manufacturer IN ('Canon', '3D Systems', 'Ativa')
ORDER BY 
    product_manufacturer, product_name;







-- join tables for tableau data visiualization

SELECT
    c.customer_name,
    c.customer_segment,
    c.customer_id,
    o.order_id,
   
    o.order_date,
    o.shipping_city,
    o.shipping_state,
    o.shipping_region,
    o.shipping_country,
    o.shipping_postal_code,
    o.shipping_date,
    o.shipping_mode,
    od.order_details_id,
    od.product_id,
    od.quantity,
    od.order_discount,
    od.order_profits,
    od.order_profit_ratio,
    od.order_sales,
    p.product_name,
    p.product_category,
    p.product_subcategory,
    p.product_manufacturer
FROM
    customers c  
LEFT JOIN  orders o ON c.customer_id = o.customer_id
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN product p ON od.product_id = p.product_id;