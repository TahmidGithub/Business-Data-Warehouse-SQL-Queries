-- Task 1: Straightforward selects

-- Select ProductName from DimProduct;
-- Select ProductName from DimProduct where ProductType = 'Bread'; 
-- Select * from DimPromotion where PromotionPercentage > 0.10 order by PromotionType; 
-- Select * from DimDateTime where FullDateTime = '2019-01-21 09:00:00.000' ; 


-- 1 List all the active employees.
-- select * from DimEmployee


-- 2 List all the employees that work in production and are active.
-- select * from DimEmployee where EmployeeType = 'Production' ORDER BY EmployeeActive



-- Task 2: Wild Cards & Join Syntax

-- Select * from DimProduct where ProductType Like 'B%';

-- Select * from DimProduct where ProductType Like 'B%d'; 

-- SELECT 
--     SalesAmount, 
--     ProductType 
-- FROM 
--     FactSales, 
--     DimProduct 
-- WHERE 
--     FactSales.ProductCode = DimProduct.ProductCode 
--     and PromotionID IS NULL; 

-- SELECT 
--     SalesAmount, 
--     ProductType 
-- FROM 
--     FactSales, 
--     DimProduct 
-- WHERE 
--     FactSales.ProductCode = DimProduct.ProductCode 
--     and ProductName like '%bread%' 
-- Order by ProductType;

-- 1 List all the employees that their names start with the letter ‘B’ 
-- Select * from DimEmployee where EmployeeFirstName Like 'B%';


-- 2 List the waste transactions that were gifted. 
-- SELECT * FROM FactWaste WHERE ActionTaken = 'gift'


-- 3 List all the waste transactions that were gifted due to decorating problems. 
-- SELECT
--     Quantity,
--     Amount,
--     ActionTaken,
--     WasteType
-- FROM FactWaste, DimWaste
-- WHERE FactWaste.WasteID = DimWaste.WasteID 
-- AND ActionTaken = 'gift'
-- AND WasteType = 'decorating problems'


-- 4 List all the waste transactions that were gifted due to decorating problems that involved products, which their name starts with the letter C and ends with the letters ed.
-- SELECT
--     ProductName,
--     Quantity,
--     Amount,
--     ActionTaken,
--     WasteType
-- FROM 
--     FactWaste, DimWaste, DimProduct
-- WHERE 
--     FactWaste.WasteID = DimWaste.WasteID AND
--     FactWaste.ProductCode = DimProduct.ProductCode
-- AND ActionTaken = 'gift'
-- AND WasteType = 'decorating problems'
-- AND ProductName LIKE 'C%ed'



-- Task 3: Dates 
-- SELECT GETDATE()

-- Select Year(EmployeeDOB) from DimEmployee; 

-- Select Month(EmployeeDOB) from DimEmployee; 

-- Select Day(EmployeeDOB) from DimEmployee; 

-- Select DATEADD(YEAR,1, FullDateTime) from FactSales where PromotionID IS NOT NULL; 

-- Select Datediff(Year, EmployeeDOB, GETDATE()) from DimEmployee; 

-- Select * from DimEmployee Where (DATEDIFF(DAY, EmployeeDOB, GETDATE()) / 365.25) > 25;


-- 1 List all the names and ages of non-active employees. 
-- SELECT
--     EmployeeFirstName,
--     EmployeeLastName,
--     EmployeeDOB,
--     EmployeeActive
-- FROM
--     DimEmployee
-- WHERE EmployeeActive = 'No'


-- 2 List all the sales with a promotion from the year 2020.
-- SELECT
--     fs.FullDateTime,
--     fs.ProductCode,
--     fs.TransactionNo,
--     fs.EmployeeID,
--     fs.PromotionID,
--     dp.PromotionType,
--     fs.Quantity,
--     fs.SalesAmount,
--     fs.CostAmount
-- FROM FactSales fs,
--      DimDateTime ddt,
--      DimPromotion dp
-- WHERE fs.FullDateTime = ddt.FullDateTime
--     AND fs.PromotionID = dp.PromotionID
--     AND fs.PromotionID IS NOT NULL
--     AND YEAR(fs.FullDateTime) = 2020


-- 3 List all the sales without a promotion between September 2019 and November 2019 that happened on mid day.
-- SELECT
--     fs.FullDateTime,
--     fs.ProductCode,
--     fs.TransactionNo,
--     fs.EmployeeID,
--     fs.Quantity,
--     fs.SalesAmount,
--     fs.CostAmount
-- FROM FactSales fs,
--      DimDateTime ddt
-- WHERE fs.FullDateTime = ddt.FullDateTime
--   AND fs.PromotionID IS NULL
--   AND ddt.FullDateTime BETWEEN '2019-09-01' AND '2019-11-30'
--   AND ddt.DTHour = 12;


-- 4 List all the sales without a promotion from the year 2020 that their quantities are less than 20 if they happened on a Monday. 
-- SELECT
--     fs.FullDateTime,
--     fs.ProductCode,
--     fs.TransactionNo,
--     fs.EmployeeID,
--     fs.Quantity,
--     fs.SalesAmount,
--     fs.CostAmount
-- FROM FactSales fs,
--      DimDateTime ddt
-- WHERE fs.FullDateTime = ddt.FullDateTime
--   AND fs.PromotionID IS NULL
--   AND ddt.DTYear = 2020
--   AND (ddt.DTTheDayOfWeek <> 1 OR fs.Quantity < 20);



-- Task 4: Outer and Self Joins 
-- SELECT 
--     SalesAmount, 
--     ProductType 
-- FROM 
--     FactSales 
-- inner join 
--     DimProduct on FactSales.ProductCode = DimProduct.ProductCode 
-- where PromotionID IS NULL; 
-- -- simple join of two tables where the product code match the row is returned. 

 
-- SELECT 
--     SalesAmount 
-- FROM FactSales 
-- right outer join 
--     DimEmployee on FactSales.EmployeeID = DimEmployee.EmployeeID 
-- Where Quantity <2; 
-- -- would tell you the sales amount of every employee 


-- SELECT 
--     SalesAmount 
-- FROM FactSales 
-- left join 
--     DimEmployee on FactSales.EmployeeID = DimEmployee.EmployeeID 
-- Where Quantity <2;  


-- SELECT * FROM FactSales 
-- inner join 
--     DimProduct on FactSales.ProductCode = DimProduct.ProductCode 
-- inner join 
--     DimCategory on DimCategory.CategoryID = DimProduct.CategoryID 
-- where PromotionID IS NULL; 
-- -- join of more than 1 tables 


-- 1 List the date, category range, product name and employee first name and last name of every sale occurred in december in descending date order. 
-- SELECT 
--     dt.FullDateTime,
--     c.CategoryRange,
--     p.ProductName,
--     e.EmployeeFirstName,
--     e.EmployeeLastName
-- FROM FactSales f
-- JOIN DimDateTime dt ON f.FullDateTime = dt.FullDateTime
-- JOIN DimProduct p ON f.ProductCode = p.ProductCode
-- JOIN DimCategory c ON p.CategoryID = c.CategoryID
-- JOIN DimEmployee e ON f.EmployeeID = e.EmployeeID
-- WHERE dt.DTMonth = 12
-- ORDER BY dt.FullDateTime DESC;


-- 2 List all sale, transaction type, product, and waste records that have sales and waste recorded on the same days. (hint: try different joints)
-- SELECT 
--     fs.FullDateTime,
--     dt.TransactionType,
--     p.ProductName,
--     p.ProductType,
--     fs.Quantity AS SalesQuantity,
--     fs.SalesAmount,
--     fs.CostAmount,
--     fw.FullDate AS WasteDate,
--     fw.Quantity AS WasteQuantity,
--     fw.Amount AS WasteAmount,
--     w.WasteType,
--     fw.ActionTaken
-- FROM FactSales fs
-- INNER JOIN FactWaste fw
--     ON DATEDIFF(day, 0, fs.FullDateTime) = DATEDIFF(day, 0, fw.FullDate)
-- LEFT JOIN DimProduct p
--     ON fs.ProductCode = p.ProductCode
-- LEFT JOIN DimTransactionType dt
--     ON fs.TransactionNo = dt.TransactionNo
-- LEFT JOIN DimWaste w
--     ON fw.WasteID = w.WasteID
-- ORDER BY fs.FullDateTime;


-- 3 List all sale, transaction type, product, and waste records that have at least sales recorded on the common sale-waste days. (hint: try different joints)
-- SELECT 
--     fs.FullDateTime,
--     dt.TransactionType,
--     p.ProductName,
--     p.ProductType,
--     fs.Quantity AS SalesQuantity,
--     fs.SalesAmount,
--     fs.CostAmount
-- FROM FactSales fs
-- INNER JOIN FactWaste fw
--     ON DATEDIFF(day, 0, fs.FullDateTime) = DATEDIFF(day, 0, fw.FullDate)
-- INNER JOIN DimProduct p
--     ON fs.ProductCode = p.ProductCode
-- INNER JOIN DimTransactionType dt
--     ON fs.TransactionNo = dt.TransactionNo
-- ORDER BY fs.FullDateTime;


-- 4 List all sale, transaction type, product, and waste records that have at least wastes recorded on the common sale-waste days. (hint: try different joints) 
-- SELECT 
--     fw.FullDate AS WasteDate,
--     w.WasteType,
--     fw.Quantity AS WasteQuantity,
--     fw.Amount AS WasteAmount,
--     fw.ActionTaken,
--     fs.FullDateTime AS SaleDateTime,
--     dt.TransactionType,
--     p.ProductName,
--     p.ProductType
-- FROM FactWaste fw
-- INNER JOIN FactSales fs
--     ON DATEDIFF(day, 0, fs.FullDateTime) = DATEDIFF(day, 0, fw.FullDate)
-- LEFT JOIN DimWaste w
--     ON fw.WasteID = w.WasteID
-- LEFT JOIN DimProduct p
--     ON fw.ProductCode = p.ProductCode
-- LEFT JOIN DimTransactionType dt
--     ON fs.TransactionNo = dt.TransactionNo
-- ORDER BY fw.FullDate, fw.WasteID;



-- Task 5: Case statements 
-- Create a case statement that returns a list of all the bakery’s products and their range, as well as the word “sweet” if the product is sweet and “savoury” if the product is savoury. 

-- SELECT
--     p.ProductName,
--     c.CategoryRange,
--     CASE
--         -- SWEET items
--         WHEN LOWER(p.ProductName) LIKE '%chocolate%'
--           OR LOWER(p.ProductName) LIKE '%custard%'
--           OR LOWER(p.ProductName) LIKE '%apple%'
--           OR LOWER(p.ProductName) LIKE '%cherry%'
--           OR LOWER(p.ProductName) LIKE '%lemon%'
--           OR LOWER(p.ProductName) LIKE '%blueberry%'
--           OR LOWER(p.ProductName) LIKE '%cinnamon%'
--           OR LOWER(p.ProductName) LIKE '%raisin%'
--           OR LOWER(p.ProductName) LIKE '%oreo%'
--           OR LOWER(p.ProductName) LIKE '%strawberry%'
--           OR LOWER(p.ProductName) LIKE '%maple%'
--           OR LOWER(p.ProductName) LIKE '%treacle%'
--           OR LOWER(p.ProductName) LIKE '%glazed%'
--           OR LOWER(p.ProductName) LIKE '%icing%'
--           OR LOWER(p.ProductName) LIKE '%sweet%'
--         THEN 'sweet'
--         -- SAVOURY items
--         WHEN LOWER(p.ProductName) LIKE '%ham%'
--           OR LOWER(p.ProductName) LIKE '%cheese%'
--           OR LOWER(p.ProductName) LIKE '%chicken%'
--           OR LOWER(p.ProductName) LIKE '%steak%'
--           OR LOWER(p.ProductName) LIKE '%kidney%'
--           OR LOWER(p.ProductName) LIKE '%pork%'
--           OR LOWER(p.ProductName) LIKE '%onion%'
--           OR LOWER(p.ProductName) LIKE '%salt%'
--         THEN 'savoury'
--         -- DEFAULT (most breads)
--         ELSE 'savoury'
--     END AS ProductTaste
-- FROM DimProduct p
-- LEFT JOIN DimCategory c
--     ON p.CategoryID = c.CategoryID
-- ORDER BY p.ProductName;



-- Task 6: Non-Correlated & Correlated Subquery


-- 1 List the details of the sales that have more than the average cost amount.
-- SELECT
--     SalesAmount,
--     CostAmount
-- FROM FactSales fs
-- WHERE SalesAmount > 
--     (SELECT AVG(CostAmount) FROM FactSales)


-- 2 List the details of the sales that have more than the average sales amount for 2019.
-- SELECT
--     Quantity,
--     SalesAmount,
--     CostAmount
-- FROM FactSales
-- WHERE SalesAmount >
--     (SELECT AVG(SalesAmount) 
--     FROM FactSales 
--     WHERE YEAR(FullDateTime) = 2019)
-- ORDER BY Quantity;


-- 3 List the details of the sales that have equal or less than average quantity.
-- SELECT
--     SalesAmount,
--     CostAmount,
--     Quantity
-- FROM FactSales
-- WHERE Quantity <= 
--     (SELECT AVG(Quantity) 
--     FROM FactSales)
-- ORDER BY Quantity;


-- 4 List the details of the sales that have more or equal than the average SalesAmount of the top 25 sales in SalesAmount.
-- WITH Top25 AS (
--     SELECT TOP 25 SalesAmount
--     FROM FactSales
--     ORDER BY SalesAmount DESC
-- )
-- SELECT SalesAmount, CostAmount, Quantity
-- FROM FactSales
-- WHERE SalesAmount >= (SELECT AVG(SalesAmount) FROM Top25)
-- ORDER BY SalesAmount DESC;



-- Task 8: Changing data types 

-- SELECT CONVERT(CHAR, EmployeeID ) + EmployeeLastName as [Employee Profile] from DimEmployee; 

-- SELECT CAST(EmployeeID as CHAR) + EmployeeLastName as [Employee Profile] from DimEmployee; 



-- Task 9: Date and Language formats

-- DECLARE @yourDateString DATETIME = '12-09-2018'; 

-- SET DATEFORMAT dmy; 

-- SELECT CONVERT(DATE, @yourDateString) AS [DMY-Interpretation-of-input-format]; 

-- SET LANGUAGE us_english;   

-- SELECT DATENAME(month, GETDATE()) AS 'Month Name';

-- 1 List the date of birth of all the employees in dmy and mdy formats. 
-- SELECT
--     EmployeeFirstName,
--     EmployeeLastName,
--     CONVERT(VARCHAR(10), EmployeeDOB, 103) AS DOB_DMY, -- dd/mm/yyyy
--     CONVERT(VARCHAR(10), EmployeeDOB, 101) AS DOB_MDY  -- mm/dd/yyyy
-- FROM DimEmployee;

-- 2 List the month of birth of the top 3 employees, order ascending on their last name. 
-- SELECT TOP 3
--     EmployeeFirstName,
--     EmployeeLastName,
--     DATENAME(month, EmployeeDOB) AS MonthOfBirth
-- FROM DimEmployee
-- ORDER BY EmployeeLastName ASC;



-- 3 List the month of birth of the top 3 employees in any language that you like, ordering ascending on their last name. 
-- SET LANGUAGE Russian;
-- SELECT TOP 3
--     EmployeeFirstName,
--     EmployeeLastName,
--     DATENAME(month, EmployeeDOB) AS MonthOfBirth
-- FROM DimEmployee
-- ORDER BY EmployeeLastName ASC;



-- Task 10: String functions

-- SELECT CONCAT(EmployeeFirstName, ' ', EmployeeLastName) As [Full Name] FROM DimEmployee; 

-- SELECT REVERSE(CONCAT(EmployeeFirstName, ' ', EmployeeLastName)) as [Full Name] FROM DimEmployee;


-- 1 Concatenate the product name and product type in 1 column and name it CompleteProduct. 
-- SELECT CONCAT(ProductName, ' ', ProductType) As "CompleteProduct" 
-- FROM DimProduct; 


-- 2 Concatenate the product name, product type and category range  in 1 column and name it full product description. 
-- SELECT CONCAT(ProductName, ' ', ProductType) As [full product description] 
-- FROM DimProduct; 



-- Task 11: Group By & Having


-- 1 List the amount of waste per month that is gifted.
-- SELECT 
--     MONTH(FullDate) AS MonthNumber,
--     DATENAME(MONTH, FullDate) AS MonthName,
--     SUM(Amount) AS TotalWasteGifted
-- FROM FactWaste
-- WHERE ActionTaken = 'gift'
-- GROUP BY MONTH(FullDate), DATENAME(MONTH, FullDate)
-- ORDER BY MonthNumber ASC;


-- 2 List how many different waste actions occurred per month in 2020. 
-- SELECT
--     MONTH(FullDate) AS MonthNumber,
--     COUNT(DISTINCT ActionTaken) AS DifferentActions
-- FROM FactWaste
-- WHERE YEAR(FullDate) = 2020
-- GROUP BY MONTH(FullDate)
-- ORDER BY MonthNumber;


-- 3 What is the minimum and maximum amount of waste for January 2019 per different actions.  
-- SELECT
--     ActionTaken,
--     MIN(Amount) AS MinWaste,
--     MAX(Amount) AS MaxWaste
-- FROM FactWaste
-- WHERE MONTH(FullDate) = 1 AND YEAR(FullDate) = 2019
-- GROUP BY ActionTaken
-- ORDER BY ActionTaken;


-- 4 What is the amount of waste and the quantity of waste per month when the quantity of waste is at least 30. 
-- SELECT
--     MONTH(FullDate) AS MonthNumber,
--     DATENAME(MONTH, FullDate) AS MonthName,
--     SUM(Amount) AS TotalWasteAmount,
--     SUM(Quantity) AS TotalWasteQuantity
-- FROM FactWaste
-- WHERE Quantity >= 30
-- GROUP BY MONTH(FullDate), DATENAME(MONTH, FullDate)
-- ORDER BY MONTH(FullDate);



-- Task 13: Group By extensions or subtotal operators
-- Select 
--     Sum(SalesAmount) AS TotalSales, 
--     MONTH(FullDateTime) As PerMonth, 
--     Year(FullDateTime) As PerYear 
-- from FactSales 
-- Group by Rollup(MONTH(FullDateTime), YEAR(FullDateTime)); 


-- 1 List the amount of waste per month that is gifted grouped per month and year, as well as their grand totals.
-- SELECT
--     SUM(fw.Amount)     AS [Amount of Waste],
--     YEAR(fw.FullDate)  AS [Year],
--     MONTH(fw.FullDate) AS [Month]
-- FROM FactWaste fw
-- WHERE fw.ActionTaken = 'gift'
-- GROUP BY ROLLUP (YEAR(fw.FullDate), MONTH(fw.FullDate))
-- ORDER BY [Year], [Month];


-- 2 What is the amount of waste and the quantity of waste per month and year when the quantity of waste is at least 30, as well as their grand totals. 
-- SELECT
--     SUM(fw.Amount)      AS [Amount of Waste],
--     SUM(fw.Quantity)    AS [Quantity of Waste],
--     YEAR(fw.FullDate)   AS [Year],
--     MONTH(fw.FullDate)  AS [Month]
-- FROM FactWaste fw
-- GROUP BY ROLLUP (YEAR(fw.FullDate), MONTH(fw.FullDate))
-- HAVING
--     SUM(fw.Quantity) >= 30
-- ORDER BY
--     [Year], [Month];


-- Select 
--     Sum(SalesAmount) AS TotalSales,
--     MONTH(FullDateTime) As PerMonth, 
--     Year(FullDateTime) As PerYear 
-- from FactSales 
-- Group by Cube(MONTH(FullDateTime), YEAR(FullDateTime)); 

-- total -> grandtotal with rollup it uses the second column, but Cube uses first column to show grandtotal. But it also at the end shows grandtotal of each item.






-- SELECT
--     TABLE_NAME,
--     COLUMN_NAME,
--     DATA_TYPE,
--     IS_NULLABLE
-- FROM INFORMATION_SCHEMA.COLUMNS
-- ORDER BY TABLE_NAME, ORDINAL_POSITION;