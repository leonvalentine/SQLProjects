/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM housing_db.nashvillehousing;


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, STR_TO_DATE(SaleDate, '%m/%d/%Y') AS SaleDateConverted
FROM nashvillehousing;


UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%m/%d/%Y');


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT *
FROM housing_db.nashvillehousing
#WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_db.nashvillehousing a
JOIN housing_db.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE nashvillehousing a, nashvillehousing b
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
	AND a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM housing_db.nashvillehousing
#WHERE PropertyAddress IS NULL
#ORDER BY ParcelID
;

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) AS Address, 
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS Address
FROM housing_db.nashvillehousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 );


ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress));



SELECT *
FROM housing_db.nashvillehousing;



SELECT OwnerAddress
FROM housing_db.nashvillehousing;


SELECT 
SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1) AS OwnAddress,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS OwnCity,
SUBSTRING(OwnerAddress, -2, LOCATE(',', OwnerAddress)) AS State
FROM housing_db.nashvillehousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);


ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING(OwnerAddress, -2, LOCATE(',', OwnerAddress));



SELECT *
FROM housing_db.nashvillehousing;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM housing_db.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;




SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM housing_db.nashvillehousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM housing_db.nashvillehousing
#ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



SELECT *
FROM housing_db.nashvillehousing;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM housing_db.nashvillehousing;


ALTER TABLE housing_db.nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;