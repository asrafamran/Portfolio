--DATA CLEANING PROCESS
--DATA TAKEN FROM NASHVILLE HOUSING 
--LINK : https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

SELECT *
FROM Portfolio.dbo.HousingNashville$

--------------------------------------------------------------------------------------------------------------

--SALE DATE

SELECT SaleDate, CONVERT(date,SaleDate) as Date
FROM Portfolio.dbo.HousingNashville$

-- DATA STADARDIZED
-- CONVERT THE SALE DATETIME FROM '2015-06-30 00:00:00.000' TO DATE ONLY '2015-06-30'
ALTER TABLE HousingNashville$
ADD SaleDateConverted Date

UPDATE HousingNashville$
SET SaleDateConverted = CONVERT(date,SaleDate);

SELECT SaleDateConverted
FROM Portfolio.dbo.HousingNashville$


--------------------------------------------------------------------------------------------------------------

--PROPERTY ADDRESS

SELECT *
FROM Portfolio..HousingNashville$
ORDER BY ParcelID

--CHECK FOR NULL IN THE PROPERTY ADDRESS

--CHECK THE DUPLICATE ADDRESS
SELECT *
FROM Portfolio..HousingNashville$ t1
JOIN Portfolio..HousingNashville$ t2
    ON t1.[ParcelID] = t2.[ParcelID]
    AND t1.[PropertyAddress] = t2.[PropertyAddress]
    AND t1.[UniqueID] <> t2.[UniqueID]
ORDER BY t1.ParcelID

--CHECK THE NULL ADDRESS BUT HAVE ANOTHER SAME 'ParcelID'
SELECT t1.[UniqueID], t1.[ParcelID] as IDt1, t2.[ParcelID] as IDt2, t1.[PropertyAddress] as Addrt1, t2.[PropertyAddress] as Addrt2, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM Portfolio..HousingNashville$ t1
JOIN Portfolio..HousingNashville$ t2
    ON t1.[ParcelID] = t2.[ParcelID]
    AND t1.[UniqueID] <> t2.[UniqueID]
WHERE t1.PropertyAddress IS NULL
ORDER BY t1.ParcelID

--UPDATE THE VALUE AND INPUT THE COPY THE ADDRESS
UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM Portfolio..HousingNashville$ t1
JOIN Portfolio..HousingNashville$ t2
    ON t1.[ParcelID] = t2.[ParcelID]
    AND t1.[UniqueID] <> t2.[UniqueID]
WHERE t1.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------

-- SEPERATED THE ADDRESS INTO INDIVIDUAL COLLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM Portfolio.dbo.HousingNashville$

-- -1 IN THE CHARINDEX TO OUTPUT BEFORE THE COMMA
-- ABS() IS BEING USED BECAUSE THE CHARINDEX RETURN -ve VALUE
SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as address,
--LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(' ',PropertyAddress), ABS(CHARINDEX(',', PropertyAddress))))  as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2 , LEN(PropertyAddress)) as city
FROM Portfolio.dbo.HousingNashville$

-- UPDATE THE TABLE WITH THE SPLIT ADDRESS FOR PROPERTY

ALTER TABLE Portfolio.dbo.HousingNashville$
ADD propertySplitAddress VARCHAR(255)

UPDATE Portfolio.dbo.HousingNashville$
SET propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 );

ALTER TABLE Portfolio.dbo.HousingNashville$
ADD  propertySplitCity VARCHAR(255)

UPDATE Portfolio.dbo.HousingNashville$
SET propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2 , LEN(PropertyAddress));

SELECT *
FROM Portfolio.dbo.HousingNashville$


--CHECK THE OWNER ADDRESS
SELECT OwnerAddress
FROM Portfolio..HousingNashville$
WHERE OwnerAddress IS NOT NULL

--PARSENAME() ONLY CAN BE USED WITH '.' INSTEAD OF ',' THEREFORE NEEDF TO REPLACE()
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM Portfolio..HousingNashville$
WHERE OwnerAddress IS NOT NULL


-- UPDATE THE TABLE WITH THE SPLIT ADDRESS FOR OWNER ADDRESS

ALTER TABLE Portfolio.dbo.HousingNashville$
ADD ownerSplitAddress VARCHAR(255), 
ownerSplitCity VARCHAR(255),
ownerSplitState VARCHAR(255)

UPDATE Portfolio.dbo.HousingNashville$
SET ownerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
ownerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
ownerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);


SELECT *
FROM Portfolio.dbo.HousingNashville$




--------------------------------------------------------------------------------------------------------------


--CHANGE PROPERTIES FROM 'Y' AND 'N' TO 'YES','NO' in [SoldAsVacant]

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as counter
FROM HousingNashville$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
END
FROM HousingNashville$
ORDER BY 1

UPDATE HousingNashville$
SET SoldAsVacant = 
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
END
FROM HousingNashville$

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as counter
FROM HousingNashville$
GROUP BY SoldAsVacant
ORDER BY 2




--------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES // AVOID TO DELETE DATA IN THE MAIN DB, JUST MAKE A FILTER TO AVOID ANY LOSS OF DATA EVEN DUPLICATES.

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SaleDate,
                 SalePrice,
                 LegalReference
                 ORDER BY ParcelID
) row_num
FROM Portfolio.dbo.HousingNashville$

)

--CHECK THE DUPLICATES

--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

-- CHECK IF THERE IS DUPLICATES

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY propertyAddress



--------------------------------------------------------------------------------------------------------------

--REMOVE UNUSED COLLUMN

ALTER TABLE HousingNashville$
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

SELECT *
FROM HousingNashville$