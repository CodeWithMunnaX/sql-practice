/* =====================================================================
   SQL OPERATORS PRACTICE  (SQL Server)
   Dataset : customer.csv  (1000 rows, 12 columns)
   5 questions per operator -> question first, then the solution

   Operators:
     1. Comparison : =  <>  !=  >  >=  <  <=
     2. Logical    : AND  OR  NOT
     3. Range      : BETWEEN
     4. Membership : IN  NOT IN
     5. Search     : LIKE
   ===================================================================== */


/* ---------------------------------------------------------------------
   STEP 0 : Create the table and load data from the CSV
   --------------------------------------------------------------------- */
CREATE TABLE customer (
    order_id        VARCHAR(10)   PRIMARY KEY,
    order_date      DATE,
    customer_name   VARCHAR(50),
    gender          VARCHAR(10),
    age             INT,
    city            VARCHAR(30),
    category        VARCHAR(30),
    product_name    VARCHAR(50),
    quantity        INT,
    unit_price      INT,
    total_amount    INT,
    payment_method  VARCHAR(30)
);

BULK INSERT customer
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\customer.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,          -- skip the header line
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a'
);

-- Check: should return 1000 rows
SELECT COUNT(*) AS total_rows FROM customer;
SELECT TOP 10 * FROM customer;



/* =====================================================================
   1. COMPARISON OPERATORS
   ===================================================================== */

/* ---------------------------  =  (Equal To)  ------------------------- */

-- Q1. Show all orders from Mumbai.
SELECT * FROM customer
WHERE city = 'Mumbai';

-- Q2. List all orders paid using UPI.
SELECT order_id, customer_name, total_amount, payment_method
FROM customer
WHERE payment_method = 'UPI';

-- Q3. Show all orders in the 'Electronics' category.
SELECT order_id, product_name, unit_price, total_amount
FROM customer
WHERE category = 'Electronics';

-- Q4. Show orders where the quantity is exactly 3.
SELECT order_id, customer_name, product_name, quantity
FROM customer
WHERE quantity = 3;

-- Q5. Show all orders placed on 1 January 2024.
SELECT * FROM customer
WHERE order_date = '2024-01-01';


/* ----------------------  <>  or  !=  (Not Equal To)  ----------------- */
-- Note: <> and != do the same thing (the image shows "=!",
--       but the correct syntax is "!=")

-- Q1. Show orders from all cities except Delhi.
SELECT order_id, customer_name, city
FROM customer
WHERE city <> 'Delhi';

-- Q2. Show orders where the payment method is NOT 'Cash on Delivery'.
SELECT order_id, customer_name, payment_method
FROM customer
WHERE payment_method != 'Cash on Delivery';

-- Q3. Show orders from customers who are not Female (i.e. Male).
SELECT order_id, customer_name, gender
FROM customer
WHERE gender <> 'Female';

-- Q4. Show orders where the quantity is not 1 (more than one item bought).
SELECT order_id, product_name, quantity
FROM customer
WHERE quantity != 1;

-- Q5. Show all orders except those in the 'Grocery' category.
SELECT order_id, category, product_name
FROM customer
WHERE category <> 'Grocery';


/* -------------------------  >  (Greater Than)  ----------------------- */

-- Q1. Show orders with a total_amount greater than 50,000.
SELECT order_id, customer_name, product_name, total_amount
FROM customer
WHERE total_amount > 50000;

-- Q2. Show orders from customers older than 40.
SELECT order_id, customer_name, age
FROM customer
WHERE age > 40;

-- Q3. Show products with a unit_price greater than 20,000.
SELECT order_id, product_name, unit_price
FROM customer
WHERE unit_price > 20000;

-- Q4. Show orders where more than 2 items were bought.
SELECT order_id, product_name, quantity
FROM customer
WHERE quantity > 2;

-- Q5. Show all orders from 2025 (placed after 31 Dec 2024).
SELECT order_id, order_date, total_amount
FROM customer
WHERE order_date > '2024-12-31';


/* --------------------  >=  (Greater Than or Equal)  ------------------ */

-- Q1. Show orders from customers aged 30 or above.
SELECT order_id, customer_name, age
FROM customer
WHERE age >= 30;

-- Q2. Show orders with a total_amount of 10,000 or more.
SELECT order_id, product_name, total_amount
FROM customer
WHERE total_amount >= 10000;

-- Q3. Show orders where the quantity is 4 or more.
SELECT order_id, customer_name, product_name, quantity
FROM customer
WHERE quantity >= 4;

-- Q4. Show orders placed on or after 1 July 2025.
SELECT order_id, order_date, customer_name
FROM customer
WHERE order_date >= '2025-07-01';

-- Q5. Show products with a unit_price of 5,000 or more.
SELECT order_id, product_name, unit_price
FROM customer
WHERE unit_price >= 5000;


/* ---------------------------  <  (Less Than)  ------------------------ */

-- Q1. Show orders with a total_amount less than 500.
SELECT order_id, product_name, total_amount
FROM customer
WHERE total_amount < 500;

-- Q2. Show orders from customers younger than 25.
SELECT order_id, customer_name, age
FROM customer
WHERE age < 25;

-- Q3. Show cheap products with a unit_price less than 300.
SELECT order_id, product_name, unit_price
FROM customer
WHERE unit_price < 300;

-- Q4. Show orders placed before 1 April 2024 (first quarter of 2024).
SELECT order_id, order_date, total_amount
FROM customer
WHERE order_date < '2024-04-01';

-- Q5. Show orders where the quantity is less than 2 (only 1 item).
SELECT order_id, product_name, quantity
FROM customer
WHERE quantity < 2;


/* ----------------------  <=  (Less Than or Equal)  ------------------- */

-- Q1. Show orders from customers aged 20 or younger.
SELECT order_id, customer_name, age
FROM customer
WHERE age <= 20;

-- Q2. Show orders with a total_amount of 1,000 or less.
SELECT order_id, product_name, total_amount
FROM customer
WHERE total_amount <= 1000;

-- Q3. Show products with a unit_price of 999 or less.
SELECT order_id, product_name, unit_price
FROM customer
WHERE unit_price <= 999;

-- Q4. Show orders placed on or before 31 January 2024.
SELECT order_id, order_date, customer_name
FROM customer
WHERE order_date <= '2024-01-31';

-- Q5. Show orders where the quantity is 2 or less.
SELECT order_id, product_name, quantity
FROM customer
WHERE quantity <= 2;



/* =====================================================================
   2. LOGICAL OPERATORS
   ===================================================================== */

/* -------------------  AND  (both conditions true)  ------------------- */

-- Q1. Show orders from Female customers in Mumbai.
SELECT order_id, customer_name, gender, city
FROM customer
WHERE city = 'Mumbai' AND gender = 'Female';

-- Q2. Show Electronics orders paid by Credit Card.
SELECT order_id, product_name, total_amount, payment_method
FROM customer
WHERE category = 'Electronics' AND payment_method = 'Credit Card';

-- Q3. Show orders from customers older than 30 with a total_amount above 20,000.
SELECT order_id, customer_name, age, total_amount
FROM customer
WHERE age > 30 AND total_amount > 20000;

-- Q4. Show Fashion orders where the quantity is 2 or more.
SELECT order_id, product_name, quantity, total_amount
FROM customer
WHERE category = 'Fashion' AND quantity >= 2;

-- Q5. Show orders from Male customers in Bengaluru who paid by UPI.
SELECT order_id, customer_name, city, payment_method
FROM customer
WHERE city = 'Bengaluru' AND gender = 'Male' AND payment_method = 'UPI';


/* ------------------  OR  (at least one condition true)  -------------- */

-- Q1. Show orders from Delhi OR Kolkata.
SELECT order_id, customer_name, city
FROM customer
WHERE city = 'Delhi' OR city = 'Kolkata';

-- Q2. Show orders in the Books OR Sports category.
SELECT order_id, category, product_name
FROM customer
WHERE category = 'Books' OR category = 'Sports';

-- Q3. Show orders with a total_amount above 60,000 OR a quantity of 5.
SELECT order_id, product_name, quantity, total_amount
FROM customer
WHERE total_amount > 60000 OR quantity = 5;

-- Q4. Show orders paid by Net Banking OR Debit Card.
SELECT order_id, customer_name, payment_method
FROM customer
WHERE payment_method = 'Net Banking' OR payment_method = 'Debit Card';

-- Q5. Show orders from very young (age < 20) OR senior (age > 55) customers.
SELECT order_id, customer_name, age
FROM customer
WHERE age < 20 OR age > 55;

-- Bonus: AND + OR together -> always use brackets!
-- Show orders from Pune or Chennai with an amount above 5,000.
SELECT order_id, city, total_amount
FROM customer
WHERE (city = 'Pune' OR city = 'Chennai') AND total_amount > 5000;


/* ------------------  NOT  (reverses a condition)  -------------------- */

-- Q1. Show orders that are NOT in the Electronics category.
SELECT order_id, category, product_name
FROM customer
WHERE NOT category = 'Electronics';

-- Q2. Show orders that were NOT paid by UPI.
SELECT order_id, customer_name, payment_method
FROM customer
WHERE NOT payment_method = 'UPI';

-- Q3. Show orders whose total_amount is NOT greater than 1,000.
SELECT order_id, product_name, total_amount
FROM customer
WHERE NOT total_amount > 1000;

-- Q4. Show orders that are from neither Mumbai nor Delhi.
SELECT order_id, customer_name, city
FROM customer
WHERE NOT (city = 'Mumbai' OR city = 'Delhi');

-- Q5. Show orders from Female customers that are NOT in the Grocery category.
SELECT order_id, customer_name, gender, category
FROM customer
WHERE gender = 'Female' AND NOT category = 'Grocery';



/* =====================================================================
   3. RANGE OPERATOR  ->  BETWEEN  (both end values are included)
   ===================================================================== */

-- Q1. Show orders from customers aged between 25 and 35.
SELECT order_id, customer_name, age
FROM customer
WHERE age BETWEEN 25 AND 35;

-- Q2. Show orders with a total_amount between 5,000 and 15,000.
SELECT order_id, product_name, total_amount
FROM customer
WHERE total_amount BETWEEN 5000 AND 15000;

-- Q3. Show orders from the first quarter of 2024 (January to March).
SELECT order_id, order_date, customer_name, total_amount
FROM customer
WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31';

-- Q4. Show products with a unit_price between 1,000 and 3,000.
SELECT order_id, product_name, unit_price
FROM customer
WHERE unit_price BETWEEN 1000 AND 3000;

-- Q5. Show festive season orders (Oct-Nov 2025) from customers aged 18-30.
SELECT order_id, order_date, customer_name, age, total_amount
FROM customer
WHERE order_date BETWEEN '2025-10-01' AND '2025-11-30'
  AND age BETWEEN 18 AND 30;

-- Bonus: NOT BETWEEN -> values outside the range
SELECT order_id, customer_name, age
FROM customer
WHERE age NOT BETWEEN 20 AND 50;



/* =====================================================================
   4. MEMBERSHIP OPERATORS  ->  IN  /  NOT IN
   ===================================================================== */

/* -------------------  IN  (matches any value in the list)  ----------- */

-- Q1. Show orders from Mumbai, Delhi and Bengaluru.
SELECT order_id, customer_name, city
FROM customer
WHERE city IN ('Mumbai', 'Delhi', 'Bengaluru');

-- Q2. Show orders in the Fashion, Beauty and Books categories.
SELECT order_id, category, product_name
FROM customer
WHERE category IN ('Fashion', 'Beauty', 'Books');

-- Q3. Show orders paid by card (Credit Card or Debit Card).
SELECT order_id, customer_name, payment_method
FROM customer
WHERE payment_method IN ('Credit Card', 'Debit Card');

-- Q4. Show orders for Smartphone, Laptop and Smartwatch.
SELECT order_id, product_name, unit_price, total_amount
FROM customer
WHERE product_name IN ('Smartphone', 'Laptop', 'Smartwatch');

-- Q5. Show orders where the quantity is 3, 4 or 5.
SELECT order_id, product_name, quantity
FROM customer
WHERE quantity IN (3, 4, 5);


/* ----------------  NOT IN  (matches none of the values)  ------------- */

-- Q1. Show orders from all cities except Mumbai, Delhi and Bengaluru.
SELECT order_id, customer_name, city
FROM customer
WHERE city NOT IN ('Mumbai', 'Delhi', 'Bengaluru');

-- Q2. Show orders from all categories except Electronics and Grocery.
SELECT order_id, category, product_name
FROM customer
WHERE category NOT IN ('Electronics', 'Grocery');

-- Q3. Show orders that were NOT paid by UPI or Cash on Delivery.
SELECT order_id, customer_name, payment_method
FROM customer
WHERE payment_method NOT IN ('UPI', 'Cash on Delivery');

-- Q4. Show orders where the quantity is not 1 or 2.
SELECT order_id, product_name, quantity
FROM customer
WHERE quantity NOT IN (1, 2);

-- Q5. Excluding South Indian cities (Chennai, Hyderabad, Bengaluru, Kochi),
--     show orders with a total_amount above 10,000.
SELECT order_id, city, total_amount
FROM customer
WHERE city NOT IN ('Chennai', 'Hyderabad', 'Bengaluru', 'Kochi')
  AND total_amount > 10000;



/* =====================================================================
   5. SEARCH OPERATOR  ->  LIKE
      %  = any number of characters (zero or more)
      _  = exactly one character
   ===================================================================== */

-- Q1. Find customers whose name starts with 'A'.
SELECT DISTINCT customer_name
FROM customer
WHERE customer_name LIKE 'A%';

-- Q2. Find customers whose surname is 'Sharma' (name ends with 'Sharma').
SELECT DISTINCT customer_name, city
FROM customer
WHERE customer_name LIKE '%Sharma';

-- Q3. Find products whose name contains the word 'Book'.
SELECT DISTINCT product_name, category
FROM customer
WHERE product_name LIKE '%Book%';

-- Q4. Find cities whose second letter is 'u' (e.g. Mumbai, Pune).
SELECT DISTINCT city
FROM customer
WHERE city LIKE '_u%';

-- Q5. Find customers whose first name ends with 'a' (e.g. Priya, Neha, Pooja)
--     -> the letter 'a' must come right before the first space.
SELECT DISTINCT customer_name
FROM customer
WHERE customer_name LIKE '%a %';

-- Bonus: NOT LIKE -> customers whose name does NOT start with 'S'
SELECT DISTINCT customer_name
FROM customer
WHERE customer_name NOT LIKE 'S%';


/* =========================== END OF FILE ============================= */
