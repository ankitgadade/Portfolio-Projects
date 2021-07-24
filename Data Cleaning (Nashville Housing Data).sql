SELECT * FROM housing_data

--Converting datetime format to date

SELECT SaleDate, CONVERT(DATE, SaleDate) FROM housing_data

ALTER TABLE housing_data
ADD SaleDateConverted date

UPDATE housing_data
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--Filling in null values in PropertyAddress

SELECT * FROM housing_data
WHERE PropertyAddress is null

SELECT *FROM housing_data
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_data a 
JOIN housing_data b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_data a 
JOIN housing_data b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Splitting PropertyAddress for separtate address and city columns

SELECT PropertyAddress FROM housing_data

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM housing_data

ALTER TABLE housing_data
ADD Address nvarchar(255)

ALTER TABLE housing_data
ADD City nvarchar(255)

UPDATE housing_data
SET Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE housing_data
SET City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Splitting Owner's Address in address, city, state format

SELECT OwnerAddress FROM housing_data

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM housing_data

ALTER TABLE housing_data
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE housing_data
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE housing_data
ADD OwnerSplitState nvarchar(255)

UPDATE housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE housing_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE housing_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Getting consistency in SoldASVacant

SELECT SoldAsVacant, COUNT(SoldAsVacant) as instances
FROM housing_data
GROUP BY SoldAsVacant
ORDER BY instances DESC

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM housing_data

Update housing_data
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num

FROM dbo.housing_data)

SELECT * FROM RowNumCTE
WHERE row_num > 1

-- Deleting unused columns

SELECT * FROM housing_data

ALTER TABLE housing_data
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict





