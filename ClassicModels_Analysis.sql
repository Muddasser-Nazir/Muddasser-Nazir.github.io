--Renaming and giving appropriate names to the columns of all the tables.

ALTER TABLE classicmodels.customers CHANGE customerNumber Customer_ID INT;
ALTER TABLE classicmodels.customers CHANGE customerName Cusomter_Name VARCHAR(50);
ALTER TABLE classicmodels.customers CHANGE contactLastName Last_Name VARCHAR(30);
ALTER TABLE classicmodels.customers CHANGE contactFirstName First_Name VARCHAR(30);
ALTER TABLE classicmodels.customers CHANGE phone Phone VARCHAR(30);
ALTER TABLE classicmodels.customers CHANGE addressLine1 First_Address VARCHAR(50);
ALTER TABLE classicmodels.customers CHANGE addressLine2 Second_Address VARCHAR(50);
ALTER TABLE classicmodels.customers CHANGE city City VARCHAR(50);
ALTER TABLE classicmodels.customers CHANGE state State VARCHAR(50);
ALTER TABLE classicmodels.customers CHANGE postalCode Postal_Code VARCHAR(20);
ALTER TABLE classicmodels.customers CHANGE country Country VARCHAR(30);
ALTER TABLE classicmodels.customers CHANGE salesRepEmployeeNumber Sales_Rep_ID INT;
ALTER TABLE classicmodels.customers CHANGE creditlimit Credit_Limit DECIMAL (9,2);

ALTER TABLE classicmodels.employees CHANGE employeeNumber Employee_ID INT;
ALTER TABLE classicmodels.employees CHANGE lastName Last_Name VARCHAR(30);
ALTER TABLE classicmodels.employees CHANGE firstName First_Name VARCHAR(30);
ALTER TABLE classicmodels.employees CHANGE extension Extension VARCHAR(30);
ALTER TABLE classicmodels.employees CHANGE email Email_ID VARCHAR (50);
ALTER TABLE classicmodels.employees CHANGE reportsTo Reports_To INT;
ALTER TABLE classicmodels.employees CHANGE jobTitle Job_Title VARCHAR (50);

ALTER TABLE classicmodels.offices CHANGE city City VARCHAR (50);
ALTER TABLE classicmodels.offices CHANGE phone Phone VARCHAR(30);
ALTER TABLE classicmodels.offices CHANGE addressLine1 First_Address VARCHAR(50);
ALTER TABLE classicmodels.offices CHANGE addressLine2 Second_Address VARCHAR(50);
ALTER TABLE classicmodels.offices CHANGE state State VARCHAR(50);
ALTER TABLE classicmodels.offices CHANGE country Country VARCHAR(50);
ALTER TABLE classicmodels.offices CHANGE postalCode Postal_Code VARCHAR(50);
ALTER TABLE classicmodels.offices CHANGE territory Territory VARCHAR(50);

ALTER TABLE classicmodels.orderdetails CHANGE orderNumber Order_ID INT;
ALTER TABLE classicmodels.orderdetails CHANGE productCode Product_Code VARCHAR(30);
ALTER TABLE classicmodels.orderdetails CHANGE quantityOrdered Quantity_Ordered INT;
ALTER TABLE classicmodels.orderdetails CHANGE priceEach Price_Per_Unit FLOAT;
ALTER TABLE classicmodels.orderdetails CHANGE orderLineNumber Order_Line_Number INT;

ALTER TABLE classicmodels.orders CHANGE orderNumber Order_ID INT;
ALTER TABLE classicmodels.orders CHANGE orderDate Order_Date DATE;
ALTER TABLE classicmodels.orders CHANGE requiredDate Required_Date DATE;
ALTER TABLE classicmodels.orders CHANGE shippedDate Shipped_Date DATE;
ALTER TABLE classicmodels.orders CHANGE status Status VARCHAR(20);
ALTER TABLE classicmodels.orders CHANGE comments Comments VARCHAR(250);
ALTER TABLE classicmodels.orders CHANGE customerNumber Customer_ID INT;

ALTER TABLE classicmodels.payments CHANGE customerNumber Customer_ID INT;
ALTER TABLE classicmodels.payments CHANGE checkNumber Cheque_Number VARCHAR(50);
ALTER TABLE classicmodels.payments CHANGE paymentDate Payment_Date DATE;
ALTER TABLE classicmodels.payments CHANGE amount Amount FLOAT;

ALTER TABLE classicmodels.productlines CHANGE productLine Product_Line VARCHAR (50);
ALTER TABLE classicmodels.productlines CHANGE textDescription Text_Description LONGTEXT;

ALTER TABLE classicmodels.products CHANGE productCode Product_Code VARCHAR(50);
ALTER TABLE classicmodels.products CHANGE productName Product_Name VARCHAR(50);
ALTER TABLE classicmodels.products CHANGE productLine Product_Line VARCHAR(50);
ALTER TABLE classicmodels.products CHANGE productScale Product_Scale VARCHAR(50);
ALTER TABLE classicmodels.products CHANGE productVendor Product_Vendor VARCHAR(50);
ALTER TABLE classicmodels.products CHANGE productDescription Product_Description LONGTEXT;
ALTER TABLE classicmodels.products CHANGE quantityInStock Quantity_In_Stock INT;
ALTER TABLE classicmodels.products CHANGE buyPrice Purchase_Price FLOAT;

--Deleting unwanted columns in the productlines table.

ALTER TABLE classicmodels.productlines DROP COLUMN htmlDescription;
ALTER TABLE classicmodels.productlines DROP COLUMN image;

USE classicmodels

--Q1). What countries are the customers of classicmodels located in?

SELECT DISTINCT country FROM classicmodels.customers;

--Q2). Which country has the highest number of orders between 2003 and 2005?

SELECT Country, COUNT(Country) AS Count
FROM classicmodels.orders o
JOIN classicmodels.customers c
ON o.Customer_ID = c.Customer_ID
GROUP BY Country
ORDER BY Count DESC;

--Q3). What is the hierarchy of the company--'s employees and how an organizational chart be generated?


SELECT e.employee_ID,
CONCAT(e.First_Name, '', e.Last_Name) AS Employee_Name,
CONCAT(em.First_Name, '', em.Last_Name) AS Supervisor_Name
FROM employees e
JOIN employees em
ON e.Reports_To = em.Employee_ID;

--Q4). What countries are the company branches situated in and which employee(s) work there?

SELECT e.Employee_ID,
e.First_Name,
e.Last_Name,
e.Job_Title,
o.City,
o.First_Address as Address,
o.State,
o.Country
FROM employees e
JOIN offices o
ON e.officeCode = o.officeCode
ORDER BY Employee_ID;

--Q5). What is the list of orders that have been shipped successfully from 2003-2005?

SELECT Order_ID, Customer_ID, Shipped_Date, Status
FROM orders
WHERE Status = 'Shipped'
ORDER BY Customer_id;

--Q6). What is the total number of products/orders that have been shipped from 2003-2005?

SELECT COUNT(Status) AS Total_Shipped
FROM orders
Where Status = 'Shipped';

--Q7). Taking the orders of customers into context, what product(s) did they actually request for?

SELECT od.Product_Code,
od.Order_ID,
o.Order_Date,
od.Quantity_Ordered,
od.Price_Per_Unit,
p.Product_Name,
p.Product_Line
FROM orderdetails od
JOIN products p
USING (Product_Code)
JOIN orders o
USING (Order_ID)
ORDER BY Order_ID;

--Q8). What is the list of total sales, the total amount of sales and the total number of sales for the year 2003?

SELECT Customer_ID,
Payment_Date,
Amount
FROM payments
Where Payment_Date <= '2003-12-31';

SELECT SUM(Amount) AS Total_Sales_For_2003
FROM payments
WHERE Payment_Date <= '2003-12-31';

SELECT COUNT(Amount) AS Number_of_Payments
FROM payments
WHERE Payment_Date <= '2003-12-31';

--Q9). What is the list of total sales, the total amount of sales and the total number of sales for the year 2004?

SELECT Customer_ID, Payment_Date, Amount
FROM payments
WHERE Payment_Date BETWEEN '2004-01-01' AND '2004-12-31';

SELECT SUM(Amount) AS Total_Sales_for_2004
FROM payments
WHERE payment_Date Between '2004-01-01' AND '2004-12-31';

SELECT SUM(od.Quantity_Ordered) AS Total_Products_Sold_2004
FROM orderdetails od
JOIN orders o
USING (Order_ID)
JOIN payments p
USING (Customer_ID)
WHERE YEAR(p.Payment_Date) = 2004;

--Q10). What is the lsit of total sales, the total amount of sales and the total number of sales for the year 2005?

SELECT Customer_ID, Payment_Date, Amount
FROM payments
WHERE Payment_Date BETWEEN '2005-01-01' AND '2005-12-31';

SELECT SUM(Amount) AS Total_Sales_for_2005
FROM payments
WHERE Payment_Date BETWEEN '2005-01-01' AND '2005-12-31';

SELECT SUM(od.Quantity_Ordered) AS Total_Products_Sold_2005
FROM orderdetails od
JOIN orders o
USING(Order_ID)
JOIN payments p
USING (Customer_ID)
WHERE YEAR (p.Payment_Date) = 2005;

--Q11). What products are currently in stock, purchase price, sale price, and estimated profit?

SELECT p.Product_Code,
p.Product_Name,
pl.Product_Line,
p.Quantity_In_Stock,
p.Purchase_price,
p.MSRP,
(p.MSRP-p.Purchase_Price) AS estimated_profit
FROM products p
JOIN productlines pl
USING (Product_Line)
ORDER BY Product_Code;

SELECT SUM(p.MSRP-p.Purchase_Price) AS Total_Estimated_Profit
FROM products p
JOIN productlines pl
USING (Product_Line);

--Q12). Which productline has highest orders?

SELECT COUNT(od.Product_Code) AS Num_of_Sales, 
p.Product_Line
FROM products p
JOIN orderdetails od
ON p.Product_Code = od.Product_Code
GROUP BY p.Product_Line
ORDER BY Num_of_Sales DESC;

--Conclusions
--1. The customers of classicmodels automobile are located in 27 countries.
--2. The USA has the highest number of orders amounting to 112, followed by France(37) and Spain(36).
--3. The hierarchy of organizational power (employees and their supervisors) has also been extracted from the data.
--4. List of employees, city, state, country and address where they work have also been extracted.
--5. List of orders shipped from 2003 to 2005 (303 in total).
--6. Most sales by productline with classic cars topping the list (1010 in total).
--7. Most sales were made in 2004 with $ 4,313,328.25 and 136 by count.
--8. The least sales were made in 2005 with only $1,290,293.28 and 37 by count.
--9. Total sales recorded from 2003-2005 were $ 8,853,839.23.

