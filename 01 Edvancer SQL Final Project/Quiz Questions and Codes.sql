-- Q1. How can you create an identity column in SQL Server?
--  A. Using the IDENTITY() function


-- Q2. The post_code column has two strings separated by spaces, can you get the values after the space (which is 3 characters long). 
--	   Which of these code you think would work?
--  A. select substring('xxxx_yyy', len('xxxx_yyy')-2, 3) 
	   WRONG


-- Q3. Which SQL JOIN type returns all records when there is a match in one of the tables?
--  A. FULL JOIN


-- Q4. What will below code would do in SQL Server:
	   select count(*) as cnt from (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'bd_train' )as b;
--  A. Count columns in bd_train


-- Q5. What is the purpose of the SQL Server function FORMAT()?
--  A. Converts a date or time to a specified format


-- Q6. How many customers have neither the medical insurance not the life insurance from bd_train?
	A. 1445
	   select count(*) from bd_train as cnt where Medical_Insurance = 0 and Life_Insurance = 0


-- Q7. Which age band have highest average balance transfer from the table?
--  A. 41-45
	   select age_band as Age_Band, sum(Balance_Transfer) as Total_Balance_Transfer, count(*) as Total_No, sum(Balance_Transfer)/count(*) as Average_Balance_Transfer
	   from bd_train group by age_band order by Average_Balance_Transfer desc;

-- Q8. What is the primary key used for in a SQL table?
--  A. Identifies each record uniquely in a table.

-- Q9. What does the SQL CASE statement do?
--  A. Performs conditional logic within a query.


-- Q10. What is the default schema name when user doesn't create one in SQL SERVER?
--   A. dbo 


-- Q11. Which SQL Server function is used to remove leading and trailing spaces from a string?
--   A. TRIM()

-- Q12. Which SQL command is used to remove a table from the database?
--   A. DROP TABLE

-- Q13. How can you concatenate two columns in SQL Server?
--   A. Using the CONCAT() function.

-- Q14. What is the purpose of the SQL SELECT statement?
--   A. Retrieves data from one or more tables

-- Q15. Which SQL clause is used to filter the results of a query?
--   A. WHERE

-- Q16. What does select 1/12 will return ?
--   A. 0

-- Q17. What is the purpose of the SQL Server function LEAD()?
--   A. Retrieves the next value in a column

-- Q18. Which is 4th best region in bd_train dataset in terms of online_purchase_amount?
--   A. Scotland
		select region as Region, sum(online_purchase_amount) as Total_Online_Purchase from bd_train 
		group by region order by Total_Online_Purchase desc;

-- Q19. What does the SQL term "NULL" represent?
--   A. Missing or unknown value

-- Q20. How many customers and their partners are both retired in bd_train data?
--   A. 1119
		select count(*) as No_of_Both_Retired_couples from bd_train 
		where occupation = 'Retired' and occupation_partner = 'Retired'

-- Q21. What is the purpose of the SQL ORDER BY clause?
--   A. Sorts the results in ascending or descending order

-- Q22. What is the purpose of the SQL Server function ROW_NUMBER()?
--   A. Assigns a unique number to each row within a partition

-- Q23. How can you obtain the current date and time in SQL Server?
--   A. Using the GETDATE() function

-- Q24. What is the purpose of the SQL Server function COALESCE()?
--   A. Returns the first non-null expression among its arguments

-- Q25. The column year_last_moved has a minimum value of 0 , if we ignore 0 as minimum value then what is the min year given in the data bd_train?
--   A. 1901
		select year_last_moved as Year_Last_Moved from bd_train where year_last_moved <> 0 order by year_last_moved

-- Q26. In how many cases balance transfer and term deposit are both zero?
--   A. 2344
		select count(*) from bd_train where Term_Deposit = 0 and Balance_Transfer = 0

-- Q27. What does the SQL Server function STUFF() do?
--   A. Replaces part of a string with another string

-- Q28. Which SQL statement is used to add new records to a table?
--   A. INSERT INTO()

-- Q29. What does select 1/0 will return? (choose the best)
--   A. Divide by Zero Error

-- Q30. How many people have no life insurance from bd_train?
--   A. 2443
		select count(*) No_of_People_Without_Life_Insurance from bd_train where Life_Insurance = 0;
