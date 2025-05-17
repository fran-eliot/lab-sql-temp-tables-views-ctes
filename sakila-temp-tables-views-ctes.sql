--- Step 1: Create a View

-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW customer_view AS
SELECT customer_id, CONCAT_WS(' ',first_name,last_name) customer_name, email, count(rental_id) rental_count
FROM rental
JOIN customer USING(customer_id)
GROUP BY customer_id;

--- Step 2: Create a Temporary Table

-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE temp_customer AS
SELECT 
    customer_id, 
    SUM(amount) AS total_paid
FROM customer_view 
JOIN payment USING(customer_id)
GROUP BY customer_id;

--- Step 3: Create a CTE and the Customer Summary Report

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid. 

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
CREATE TEMPORARY TABLE temp_rental_payment AS
SELECT customer_name, email, rental_count, total_paid
FROM customer_view
JOIN temp_customer USING(customer_id);

WITH customer_summary AS (
    SELECT 
        customer_name, 
        email, 
        rental_count, 
        total_paid,
        ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
    FROM temp_rental_payment
)
SELECT * FROM customer_summary
ORDER BY average_payment_per_rental DESC;