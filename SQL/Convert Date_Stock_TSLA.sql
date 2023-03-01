
SELECT [date], CONVERT(date,[date]) as Date
FROM [Portfolio].[dbo].[TSLA$]


-- DATA STADARDIZED
-- CONVERT THE SALE DATETIME FROM '2015-06-30 00:00:00.000' TO DATE ONLY '2015-06-30'
ALTER TABLE TSLA$
ADD date_1 Date

UPDATE TSLA$
SET date_1 = CONVERT(date,[date]);
SELECT date_1
FROM [Portfolio].[dbo].[TSLA$]

--DROP COLUMN 
ALTER TABLE [Portfolio].[dbo].[TSLA$]
DROP COLUMN date

--RENAME THE COLUMN
sp_rename 'TSLA$.date_1', 'date', 'COLUMN';

SELECT *
FROM [Portfolio].[dbo].[TSLA$]