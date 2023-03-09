
------------------------------------------------------------------------------ Cleaning Data in SQL--------------------------------------------------------------------------------

--Standardize Sale Date by removing time from the column

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Nashville Housing Data].dbo.NashvilleHousing --Selected Data Before Replacing to Avoid Mistakes

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [Nashville Housing Data].dbo.NashvilleHousing --Removes Times from Sale Date to Create Standardized Date


Update NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; --Adds a new Column so that we can insert reformatted sales dates

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Property Address fixing null values

Select *
FROM [Nashville Housing Data].dbo.NashvilleHousing --Used to find missing property addresses from dataset
WHERE propertyaddress is null
order by parcelid

Select y.parcelid, y.propertyaddress, z.parcelid, z.propertyaddress, ISNULL(y.propertyaddress,z.propertyaddress) -- Makes a copy of Nashvillehousing Table and creates
FROM [Nashville Housing Data].dbo.NashvilleHousing Y															 -- a new column to match property addresses to missing values
JOIN [Nashville Housing Data].dbo.NashvilleHousing Z															-- in table Y
	ON y.parcelid = z.parcelid
	AND y.[UniqueID] != z.[UniqueID]
WHERE Y.propertyaddress is null

UPDATE y
SET PropertyAddress = ISNULL(y.propertyaddress,z.propertyaddress) --Updates table Y with address FROM Table z that corresponf with the parcelid
FROM [Nashville Housing Data].dbo.NashvilleHousing Y
JOIN [Nashville Housing Data].dbo.NashvilleHousing Z
	ON y.parcelid = z.parcelid
	AND y.[UniqueID] != z.[UniqueID]
WHERE table is null

--Property Address Using SUBSTRING and CHARINDEX to split Address into individual(Method 1)

SELECT *
FROM [Nashville Housing Data].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',propertyaddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress)) as Address
FROM [Nashville Housing Data].dbo.NashvilleHousing

/*ALTER TABLE NashvilleHousing -- mistakenly asssigned wrong variable type to street address
Add StreetAddress Date;*/

/*ALTER TABLE NashvilleHousing --Dropped the street address due to wrong variable , then renamed the column in object explorer from 'Streetaddress2' to 'streetaddress'
DROP COLUMN StreetAddress;*/

ALTER TABLE NashvilleHousing --Adds City to table so that we can insert city
Add PropertyStreetAddress VarChar(255);


UPDATE NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',propertyaddress) -1)

ALTER TABLE NashvilleHousing --Adds City to table so that we can insert city
Add PropertyCityAddress VarChar(255);

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress))

--OwnerAddress Column Cleanup: Using Parsename to split columns(Method 2)

  
/*SELECT *
FROM [Nashville Housing Data].dbo.NashvilleHousing*/ -- used to check if Altered Columns are added


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM [Nashville Housing Data].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing --Adds City to table so that we can insert city
Add OwnerStreetAddress VarChar(255);

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing --Adds City to table so that we can insert city
Add OwnerCityAddress VarChar(255);

UPDATE NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing --Adds City to table so that we can insert city
Add OwnerStateAddress VarChar(255);

UPDATE NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



--Make 'Y and N', 'Yes and No' for consitency in 'Sold as Vacant Field'


SELECT DISTINCT(soldasvacant), COUNT(soldasvacant) -- Getting a distinct count as soldasvacant
FROM [Nashville Housing Data].dbo.NashvilleHousing
GROUP BY SoldasVacant 
ORDER By 2

/*SELECT SoldAsVacant, Tests Case Statemnt Before Updating
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM [Nashville Housing Data].dbo.NashvilleHousing*/

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

--Removing Duplicates FROM Table

/*SELECT DISTINCT UniqueID, Count(uniqueid) --used to find duplicate unique IDS
FROM [Nashville Housing Data].dbo.NashvilleHousing
Group by uniqueid
Order by 2 desc*/

WITH RowNumCTE AS(
SELECT *, ROW_Number() OVER(
    Partition BY ParcelId, 
				 uniqueid,
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
ORDER BY UniqueId) row_num
FROM [Nashville Housing Data].dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--proportion of property types