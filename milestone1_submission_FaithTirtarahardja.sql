/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the milestone-1. Follow the instructions and take the necessary steps to finish
the milestone-1 in the SQL file			
-----------------------------------------------------------------------------------------------------------------------------------

						                        Database Creation
                                               
-----------------------------------------------------------------------------------------------------------------------------------
*/

-- [1] To begin with the milestone-1, you need to create the database first.
-- Write the query below to create a database named mydb.

DROP DATABASE IF EXISTS mydb;
CREATE DATABASE mydb;


-- [2] Now, after creating the database, you need to tell MYSQL which database is to be used.
-- Write the query below to call your database.
USE mydb;

/*-----------------------------------------------------------------------------------------------------------------------------------

                                               Importing the SQL Dump
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
-- [3] Select the created database, i.e., mydb, and go to Server > Select Data Import.
-- Choose Import from Self-Contained File and navigate to the dump file "AlphaKart_dump.sql"
-- Select the created database in the "Default Schema to be Imported"
-- Go to Import Progress and click on Start Import.
-- Once the import is completed, refresh the SCHEMAS.
-- You will be able to see three tables: customer_t, order_t, and warehouse_t.
/*
-----------------------------------------------------------------------------------------------------------------------------------

                                                         Questions
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
/*-- Questions related to customer_t
     [Q1] What is the age of each customer who has placed an order ?
     Note*--> Create a function to get the age of each customer
		  -->this function would help you to create a view in the end of this module
     Hint-->Use extract function to get the year from customer_dob
		--> If necessary, watch the SQL Week 2 "Creating User-Defined Functions" video.
*/
-- Code for function
/* Function for age calcualtion

*/
DELIMITER $$  
CREATE FUNCTION age_f (CUSTOMER_DOB DATE)
RETURNS INTEGER
DETERMINISTIC  
BEGIN 
	DECLARE age INTEGER;
	SET age = (YEAR(NOW())) - (YEAR(CUSTOMER_DOB)) + 0;
RETURN age;
END;

-- Run the following code to check whether the function is giving the right output or not. Keep the function name as you have defined.
select age_f(customer_dob) as age
from customer_t;

/*-- Questions related to orders_t
     [Q2] What is the total bill for each order placed?
     Note*--> Create a function to get the total_bill of each customer.
		  --> this function would help you to create a view at the end of this module.
     Hint--> Use data dictionary to understand which columns are to be used for total bill calculation.
	     --> order_price,delivery_charges,coupon_discount to be used for calculating the total bill for each order.
         --> If necessary, watch the SQL Week 2 "Creating User-Defined Functions" video.
*/

/* function to calculate total_bill

*/
DELIMITER $$  
CREATE FUNCTION total_bill_f (order_price bigint, delivery_charges double, coupon_discount int) 
RETURNS DECIMAL(10,2)
DETERMINISTIC  
BEGIN  
  DECLARE total_bill DECIMAL(10,2);
      SET total_bill = order_price + delivery_charges - (coupon_discount/100) * order_price;
  RETURN total_bill;
END;

-- -- Run the following code to check whether the function is giving the right output or not. Keep the function name as you have defined.
select total_bill_f (order_price, delivery_charges , coupon_discount) as total_bill
from order_t;

/*-- Questions related to warehouse_t
     [Q3] Classify the warehouse into warehouse_size for each order based upon warehouse_employee_strength as per the following criterion:

	warehouse_employee_strength=300 THEN  warehouse_size= 'Small'
	warehouse_employee_strength=500 THEN  warehouse_size='Medium'
	warehouse_employee_strength=900 THEN  warehouse_size='Large'
	otherwise warehouse_size='Unknown'
    
   Note*--> Create a function to get the warehouse_size of each order using the above criterion.
		  --> this function would help you to create a view at the end of this module.
     Hint--> Use warehouse_employee_strength column to classify warehouse_size
          --> If necessary, watch the SQL Week 2 "Creating User-Defined Functions" video.
	*/

/* function to get the warehouse_size for each order.

*/
DELIMITER $$  
CREATE FUNCTION warehouse_size_f (warehouse_employee_strength bigint) 
RETURNS varchar(16)
DETERMINISTIC  
BEGIN  
  DECLARE warehouse_size varchar(16);
		if warehouse_employee_strength=300 THEN set warehouse_size= 'Small';
		elseif warehouse_employee_strength=500 THEN set warehouse_size='Medium';
		elseif warehouse_employee_strength=900 THEN set warehouse_size='Large';
		ELSE set warehouse_size='Unknown';
  END IF;
  RETURN warehouse_size;
END;

-- Run the following code to check whether the function is giving the right output or not. Keep the function name as you have defined.
select warehouse_size_f(warehouse_employee_strength) as warehouse_size
from warehouse_t;


/*-- Questions related to warehouse_t
     [Q4] Classify the warehouse into warehouse_area_type for each order based upon warehouse_employee_strength as per the following criterion:
	
	warehouse_employee_strength=300 THEN  warehouse_area_type= 'Residential'
	warehouse_employee_strength=500 THEN  warehouse_area_type='Commercial'
	warehouse_employee_strength=900 THEN  warehouse_area_type='Industrial'
	otherwise warehouse_area_type='Unknown'
    
   Note*--> Create a function to get the warehouse_area_type of each order using the above criterion.
		  --> This function would help you to create a view at the end of this module.
     Hint--> Use warehouse_employee_strength column to classify warehouse_area_type.
		--> If necessary, watch the SQL Week 2 "Creating User-Defined Functions" video.
	*/

/* Function for warehouse_area_type

*/
DELIMITER $$
CREATE FUNCTION warehouse_area_type_f (warehouse_employee_strength bigint)
RETURNS varchar (16)
DETERMINISTIC
BEGIN
	DECLARE warehouse_area_type varchar (16);
		if warehouse_employee_strength=300 then set warehouse_area_type= 'Residential';
		elseif warehouse_employee_strength=500 then set warehouse_area_type= 'Commercial';
		elseif warehouse_employee_strength=900 then set warehouse_area_type= 'Industrial';
		else set warehouse_area_type= 'Unknown';
	END IF;
RETURN warehouse_area_type;
END;

-- Run the following code to check whether the function is giving the right output or not. Keep the function name as you have defined.
select warehouse_area_type_f(warehouse_employee_strength) as warehouse_area_type
from warehouse_t;

/*-----------------------------------------------------------------------------------------------------------------------------------

                                               Views Creation
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/


-- ------------------------------------------Create Final view using the functions---------------------------------------------------------
/*
Note -->Refer to the ER diagram of the final view which needs to be created.
     -->select the required columns for the final view.
*/

--  Sample Code to create view using functions

CREATE VIEW final_view AS
    SELECT
      cust.customer_id,
      cust.marital_status,
      cust.occupation,
      cust.education,
      wareh.warehouse_name,
      ord.order_id,
      ord.order_date,
      ord.order_price,
      ord.delivery_charges,
      ord.coupon_discount,
      ord.order_type,
      ord.order_payment,
      ord.is_expedited_delivery, 
      ord.distance_to_nearest_warehouse, 
      ord.customer_satisfaction,
      age_f(cust.customer_dob) as age,
      warehouse_area_type_f(wareh.warehouse_employee_strength) as warehouse_area_type,
      warehouse_size_f(wareh.warehouse_employee_strength) as warehouse_size,
      total_bill_f (ord.order_price, ord.delivery_charges , ord.coupon_discount) as total_bill
from 
customer_t as cust inner join
order_t as ord
on cust.customer_id=ord.customer_id
inner join warehouse_t as wareh
on wareh.warehouse_name=ord.warehouse_name;
 
 -- code to check whether final_view is the same as expected.
 -- Run the following query 
 select *
 from final_view;
 
 
 /*-----------------------------------------------------------------------------------------------------------------------------------

                                              Exporting the csv file
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
 -- Note: Export the output of the following query and save it as AlphaKart_sql_output.csv
 select *
 from final_view;
 
