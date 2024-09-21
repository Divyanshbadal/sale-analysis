UPDATE table1
SET Annual_Revenue = RIGHT(Annual_Revenue, LEN(Annual_Revenue) - 4) 

----Q1. Import all three tables & Join them---


select  t1.* ,t3.Acct_ID,Primary_Office,TRY_CONVERT(FLOAT, annual_revenue) AS Revenue
into table_final
from 
("table1" as t1
left join  table2 as t2
on t1.Primary_Producer = t2.Primary_Producer)
left join table3 as t3
on t1.account_name=t3.account_name




----Q2  What are the percentage of deals closed ----

select COUNT(stage_name)*100/ 180
from table1 
where Stage_Name ='3-Closed Won'


--- Q3 Replace missing values in  "Niche Affiliations" variable with "Others"


UPDATE table1
SET Niche_Affiliations = 'other'
WHERE Niche_Affiliations is null ;

select * from table1 


--  Q4 Select the deals with criteria 
---(Revenue should >5000 and Opportunity Name = Cyber Consultancy and office = "Office2")----

select * from table_final
where 
Opportunity_Name LIKE 'cyber consultancy%' AND
annual_revenue >'GBP 5000.00'
AND
Primary_Office  = 'Office 3'

--\OR 
--select * from table_final
--where Opportunity_Name = 'cyber consultancy' AND
--annual_revenue >'GBP 5000.00'AND
--Primary_Office  = 'Office 2'--/



--Q5 Select top 5 opportunities by revenue for each stage
--(Hint: Required to aggregate the data by "Stage Name" and rank)--
  
  
  SELECT *
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY Stage_Name ORDER BY Revenue DESC) AS RowNum
  FROM table_final
) AS RankedOpportunities
WHERE RowNum <= 5;



 ----OTHER ANSWER
--SELECT  top(5)
--[Stage_Name] ,Opportunity_Name,max(revenue) as sum_revenue
--from table_final 
--group by Stage_Name, Opportunity_Name
--order by sum_revenue DESC


 

----Q6 Find the number of opportunities and total opportunity amount (revenue) by each month? (Use Date field)


SELECT  MONTH(Date) AS Month, COUNT(*) AS NumOpportunities, SUM(Revenue) AS TotalRevenue
FROM table_final
GROUP BY  MONTH(Date);

 



 ----Q7. Create a separate file with accounts and Group the accounts based on revenue as Tier1 
 ------(having revenue > 10000), Tier 2(5000 to 10000), Teir 3 (<5000) 
 

 SELECT Account_name, Revenue,
  CASE
    WHEN Revenue > 10000 THEN 'Tier 1'
    WHEN Revenue BETWEEN 5000 AND 10000 THEN 'Tier 2'
    ELSE 'Tier 3'
  END AS Tier
FROM table_final
ORDER BY Revenue DESC;



----Q8. Calculate revenue contribution of each producer

SELECT primary_Producer, SUM(Revenue) AS TotalRevenue
  from table_final
  group by Primary_Producer



----Q9. Create a calculated column to derive stage numbers from Stage Name (ex: 3-Closed Won stage number is 3)


  ALTER TABLE table_final
ADD Stage_code AS CAST(SUBSTRING(Stage_Name, 1, CHARINDEX('-', Stage_Name) - 1) AS INT);
select * from table_final






---Q10. Compare quarterly sales for different years (Use Date field)--


SELECT YEAR(Date) AS Year, 
  CONCAT('Q', DATEPART(QUARTER, Date)) AS Quarter, 
  SUM(revenue) AS revenue
FROM table_final
GROUP BY YEAR(Date), DATEPART(QUARTER, Date);
